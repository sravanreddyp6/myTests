var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');
var auth = require("../configs/auth.json");
var execJobs = require("../main").execJobs;


var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

execJobs({"PRD-11": function(client, done) {
        var sa = JSON.parse(stripJsonComments(fs.readFileSync("./jobs/json/all-caremeridian-sas.json", "utf8")));
        var pbs_admissions = JSON.parse(stripJsonComments(fs.readFileSync("./jobs/json/all-caremeridian-pbs-admissions.json", "utf8")));

	var user = {
		username: "shaun.wood@thementornetwork.com.staging",
		password: "Deploy!2345"	
	};

   client =  client

	.logInAs(user)

	//.then(function() {console.log("Logged in as an Administrator.."); })

	//log in as Tina Richter
	.url("https://cs4.salesforce.com/005U0000002AzvSIAS?noredirect=1&isUserEntityOverride=1")
	.pause(5000)
	.click("input[value=' Login ']")
	.pause(5000)

	//.then(function() {console.log("..Performed a Login *As* Jessica Black."); })
	//.then(function() {console.log("...We have " + sa.length + " Service Assignment pages to process."); })
	//.then(function() {console.log("...We also have " + pbs_admissions.length + " PBS's and Admissions pages to process."); })


	sa.forEach(function (a) {
		client = client
	     //.then(function() {console.log("....Go to Service Assignment-->" + a.SAID); })
	     .url("https://c.cs4.visual.force.com/apex/ServiceAssignmentView?id=" + a.SAID)
	     .pause(5000)
	});

	pbs_admissions.forEach(function (b) {
		client = client
	     //.then(function() {console.log("....Go to PBS-->" + b.ContactID); })
	     .url("https://c.cs4.visual.force.com/apex/PersonBeingServedEditNew?id=" + b.ContactID + "&sfdc.override=1")
	     .pause(5000)
	     //.then(function() {console.log("....Go to Admission-->" + b.AdmissionID); })
	     .url("https://c.cs4.visual.force.com/apex/AdmissionView?id=" + b.AdmissionID)
	     .pause(5000)
	});


	  return client;

	}
});
