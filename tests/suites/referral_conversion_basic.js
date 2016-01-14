var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

const stateMap = require("../data/state_map.js");
const userMap = require("../data/referral_user_map.js");

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

const commonAssertions = function (client, operatingGroup, flavor) {
  return client
    .getOutputText("First Name")
    .then(function (firstName) {
      assert.include(firstName, operatingGroup);
    })
    .getOutputText("Last Name")
    .then(function (lastName) {
      assert.equal(flavor, lastName);
    })
    .getOutputText("Date of Birth")
    .then(function (dob) {
      assert.equal("1/1/1970", dob);
    })
    .getOutputText("Gender")
    .then(function (gender) {
      assert.equal("Male", gender);
    })
    .getOutputText("Mailing State/Province")
    .then(function (state) {
      assert.equal(stateMap()[flavor], state);
    })
    .getOutputText("Anticipated Admission DateTime")
    .then(function (admissionDateTime) {
      assert.equal("01/12/2016 18:00", admissionDateTime);
    })
    .getOutputText("Alias")
    .then(function (alias) {
      assert.notEqual("", alias);
    });
}

/**
 * This suite tests the basic convert_referral util (by extension, it also tests the create_referral
 * util). It does all the assertions to make sure those utils do the right things.
 */
testSuite("Basic Referral Conversion", suiteTimeout, {
  "should convert a referral successfully for Redwood": function(client, done) {
    return client
      .execUtil("convert_referral", {
        operatingGroup: "Redwood",
        flavor: "AZ",
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonAssertions(client, "Redwood", "AZ");
          }
        }
      });
  },
  "should convert a referral successfully for Care Meridian": function(client, done) {
    var operatingGroup = "Care Meridian";
    var flavor = "GA";

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonAssertions(client, operatingGroup, flavor)
              .getOutputText("Current Location")
              .then(function (location) {
                assert.equal("Home", location);
              })
              .getOutputText("Referral Source")
              .then(function (source) {
                assert.equal("Sample Source", source);
              })
              .getOutputText("Evaluated By")
              .then(function (evaluatedBy) {
                var user = userMap.getUserForReferralCreation(operatingGroup, flavor);
                assert.equal(user["first_name"] + " " + user["last_name"], evaluatedBy);
              })
              .tableToJSON("[id$=fundingSources] table.list")
              .then(function (fundingSources) {
                assert.equal(1, fundingSources.length);
                assert.equal("Primary", fundingSources[0]["Coverage Level"]);
              });
          }
        }
      });
  },
  "should convert a referral successfully for NeuroRestorative": function(client, done) {
    return client
      .execUtil("convert_referral", {
        operatingGroup: "NeuroRestorative",
        flavor: "MA",
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonAssertions(client, "NeuroRestorative", "MA");
          }
        }
      });
  },
  "should convert a referral successfully for Hastings": function(client, done) {
    return client
      .execUtil("convert_referral", {
        operatingGroup: "Cambridge",
        flavor: "GA",
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonAssertions(client, "Cambridge", "GA")
              .getOutputText("Program Category")
              .then(function (category) {
                assert.equal("IDD", category);
              })
              .getOutputText("Service Line")
              .then(function (serviceLine) {
                assert.equal("Group Home", serviceLine)
              })
              .getOutputText("Services Requested")
              .then(function (services) {
                assert.equal("Host Home", services);
              });
          }
        }
      });
  },
});
