var jsforce = require('jsforce');
var auth = require("./configs/auth.json");
var _ = require("lodash");
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');
var util = require('util');

var users = JSON.parse(stripJsonComments(fs.readFileSync("./configs/users.json", "utf8")));
var sandboxName = auth.username.split(".").pop();
var usernameMap = {};
var userIdMap = {};

// While it makes sense for the public interface to have a Name => User map, internally it
// makes more sense to have a Username => User map, because most of the time we use Usernames
// as a unique id for a user.
_.forEach(users, function (user, name) {
  // We will also inject the sandbox name into the usernames
  user.username = (user.username + "." + sandboxName).toLowerCase();
  // ... And lowercasing profiles, permission sets, roles, public groups
  if (!user.profile) {
    throw new Error("Profile cannot be blank");
  }
  user.profile = user.profile.toLowerCase();
  user.role = user.role? user.role.toLowerCase() : "";
  user.permission_sets = _.map(user.permission_sets, function (permissionSet) {
    return permissionSet.toLowerCase();
  });
  user.public_groups = _.map(user.public_groups, function (publicGroup) {
    return publicGroup.toLowerCase();
  });
  user.name = name;
  usernameMap[user.username] = user;
});

var profileMap = {};
var permissionSetMap = {};
var roleMap = {};
var publicGroupMap = {};
// We only create new users, and not modify existing ones. Therefore the users specified in
// users.json must not be modified out-of-band.
var usersToCreate = [];
_.forEach(Object.keys(usernameMap), function (username) {
  usersToCreate.push(username);
});

var manageUsers = function (cb, forced) {
  var usersCreated = false;
  var conn = new jsforce.Connection({
    loginUrl: "https://test.salesforce.com/",
    maxRequest: 1000  // otherwise we'll run into max concurrent request error very soon (it defaults to 10)
  });
  conn
    .login(auth.username, auth.password)
    .then(function () {
      return conn.sobject("User").select("Id, Username, IsActive")
        .where({ Username: Object.keys(usernameMap) }).execute();
    })
    .then(function (existingUsers) {
      if (forced)  {
        _.forEach(existingUsers, function (user) {
          user["Username"] = user["Username"] + "." + _.random(100000);
          user["IsActive"] = false;
        })
        return conn.sobject("User").update(existingUsers);
      }
      return existingUsers;
    })
    .then(function (existingUsers) {
      if (!forced) {
        _.forEach(existingUsers, function (user) {
          _.pull(usersToCreate, user["Username"].toLowerCase());
        });
      }
      if (usersToCreate.length === 0) {
        throw {
          name: "NoNewUserException",
          message: "No new user to create"
        };
      } else {
        console.log("Creating new users... " + usersToCreate);
      }
    })
    .then(function () {
      return conn.query("SELECT Id, Name, Label FROM PermissionSet LIMIT 2000");
    })
    .then(function (permissionSets) {
      _.forEach(permissionSets.records, function (permissionSet) {
        permissionSetMap[permissionSet["Label"].toLowerCase()] = permissionSet["Id"];
      });
    })
    .then(function () {
      return conn.query("SELECT Id, Name FROM Profile LIMIT 2000");
    })
    .then(function (profiles) {
      _.forEach(profiles.records, function (profile) {
        profileMap[profile["Name"].toLowerCase()] = profile["Id"];
      });
    })
    .then(function () {
      return conn.query("SELECT Id, DeveloperName, Name FROM UserRole LIMIT 2000");
    })
    .then(function (roles) {
      _.forEach(roles.records, function (role) {
        roleMap[role["Name"].toLowerCase()] = role["Id"];
      });
    })
    .then(function () {
      return conn.query("SELECT Id, DeveloperName, Name FROM Group LIMIT 2000");
    })
    .then(function (groups) {
      _.forEach(groups.records, function (group) {
        if (!group["Name"]) {
          return;
        }
        publicGroupMap[group["Name"].toLowerCase()] = group["Id"];
      });
    })
    .then(function () {
      var userSObjects = _.map(usersToCreate, function (username) {
        var user = usernameMap[username];
        var permissionSets = _.map(user.permission_sets, function (permissionSet) {
          if (!permissionSetMap[permissionSet]) {
            throw new Error("Permission set " + permissionSet + " does not exist");
          }
          return permissionSetMap[permissionSet];
        });
        var publicGroups = _.map(user.public_groups, function (publicGroup) {
          if (!publicGroupMap[publicGroup]) {
            throw new Error("Public Group " + publicGroup + " does not exist");
          }
          return publicGroupMap[publicGroup];
        });
        if (!profileMap[user.profile]) {
          throw new Error("Profile " + user.profile + " does not exist");
        }
        if (!roleMap[user.role]) {
          throw new Error("Role " + user.role + " does not exist");
        }
        return {
            FirstName: user.first_name,
            LastName: user.last_name,
            Alias: user.alias,
            Username: user.username,
            Email: user.email,
            EmailEncodingKey: 'UTF-8',
            LanguageLocaleKey: 'en_US',
            LocaleSidKey: 'en_US',
            TimeZoneSidKey: 'America/New_York',
            ProfileId: profileMap[user.profile],
            UserRoleId: roleMap[user.role]
        };
      });
      return conn.sobject("User").create(userSObjects);
    })
    .then(function (users) {
      var newUserIds = _.map(users, function (user) {
        if (!user.success) {
          throw new Error("Error creating new user: " + user.errors);
        }
        usersCreated = true;
        return user.id;
      });
      return conn.sobject("User").select("Id, Username")
        .where({ Id: newUserIds }).execute();
    })
    .then(function (users) {
      _.forEach(users, function (user) {
        userIdMap[user["Id"]] = usernameMap[user["Username"].toLowerCase()];
      });
      // There's not really an easy way to set passwords for users in JSForce, so we'll use the
      // Tooling API to run an anonymous Apex code snippet here.
      var apexCode = _.reduce(userIdMap, function (result, userObj, userId) {
        return result + "System.setPassword('" + userId + "', '" + userObj.password + "'); ";
      }, "");
      console.log("Apex code to set password: " + apexCode);
      return conn.tooling.executeAnonymous(apexCode);
    })
    .then(function (result) {
      if (!result.compiled || !result.success) {
        throw new Error(result);
      }
      console.log("Anonymouse Apex code result: " + util.inspect(result));
      var permissionSetAssignments = [];
      _.forEach(userIdMap, function (userObj, userId) {
        _.forEach(userObj.permission_sets, function (permissionSet) {
          permissionSetAssignments.push({
            AssigneeId: userId,
            PermissionSetId: permissionSetMap[permissionSet]
          });
        });
      });
      return conn.sobject("PermissionSetAssignment").create(permissionSetAssignments);
    })
    .then(function (results) {
      var groupMembers = [];
      _.forEach(userIdMap, function (userObj, userId) {
        _.forEach(userObj.public_groups, function (publicGroup) {
          groupMembers.push({
            UserOrGroupId: userId,
            GroupId: publicGroupMap[publicGroup]
          });
        });
      });
      return conn.sobject("GroupMember").create(groupMembers);
    })
    .then(function () {
      var tmnUsers = _.map(userIdMap, function (userObj, userId) {
        return {
          Salesforce_User_Account__c: userId,
          First_Name__c: userObj.first_name,
          Last_Name__c: userObj.last_name,
          Name: userObj.first_name + " " + userObj.last_name,
          Operating_Group__c: userObj.operating_group
        };
      });
      return conn.sobject("TMN_User__c").create(tmnUsers);
    })
    .fail(function (err) {
      if (err.name === "NoNewUserException") {
        console.log(err.message);
      } else {
        throw err;
      }
    })
    .done(function () {
      if (usersCreated) {
        console.log("... Creating new users done!");
      }
      cb();
    });
};

module.exports = {
    accounts: users,
    manageUsers: manageUsers
};