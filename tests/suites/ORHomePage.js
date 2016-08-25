var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("ORHomePage", suiteTimeout, {
"ORHomePage": function(client, done) {
	var Lvl1user = users["RW_ORREF"];
	var Lvl3user = users["RW_OR_L3"];
	var userLook="Redwood";
	var d=new Date();
	var saveurl;
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
	var date1 = ("0" + (d.getMonth()+1)).slice(-2) + ("0" + d.getDate()).slice(-2) + d.getFullYear();
	var time = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
	return client
		.execUtil("convert_referral", {
		operatingGroup: "Redwood",
		flavor: "OR"
		})
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add Diagnosis']")
		.click("a*=Admission 1 - ")
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("h3=Authorizations")
		.click("input[value='New Risk Assessment']")	  
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	  
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Approval Date","1/12/2016")
		.click("input[value='Save']")	  
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=R. OR - SA1 - ")
		.click("a*=R. OR - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Plan']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date","1/12/2016")
		.fillInputText("Target Date","1/14/2017")
		.setValue("textarea[id$=txtaoe]", "Testing")
		.selectByValue("select[id$=stat1]", "New")
		.setValue("input[id$=effe1]","1/12/2016")
		.setValue("input[id$=tar1]","1/14/2017")
		.selectByValue("select[id$=type1]", "Behavior - Duration")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		/*
		//Level 1
		.logInAs(Lvl1user)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=CA, Redwood")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[id$=navigationList]","Allergy")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Allergy']", defaultOperationTimeout)
		*/
		//Level 3
		.logInAs(Lvl3user)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=OR, Redwood")
		.waitForVisible("input[value='Done']", defaultOperationTimeout,true)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission Packet")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Allergy")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Allergy']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Diagnosis")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
	}
});
