var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("CarbondaleHomePage", suiteTimeout, {
"CarbondaleHomePage": function(client, done) {
	var Carbondale = users["NR_carbondale"];
	var userLook="NeuroRestorative";
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
	var date1 = ("0" + (d.getMonth()+1)).slice(-2) + ("0" + d.getDate()).slice(-2) + d.getFullYear();
	var time = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
	return client
/*		.execUtil("convert_referral", {
			operatingGroup: "NeuroRestorative",
			flavor: "MA",
			hooks: {
				"create_referral_initial_referral": function (client) {
					return client
					.waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
					.chooseSelectOption("Highest Level of Education", "Graduate School")
				}
			}
		})
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
*/		.logInAs(Carbondale)
/*		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=MA, NeuroRestorative")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		//.click("a=Add Therapy Note")
		//.waitForVisible("input[value=Save]", defaultOperationTimeout)
		//.url("https://c.cs20.visual.force.com/apex/Home")
*/		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Funding Sources")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)

	}
});
