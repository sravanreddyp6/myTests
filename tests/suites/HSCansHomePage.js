var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 20 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("HSCansHomePage", suiteTimeout, {
"HSCansHomePage": function(client, done) {
	var HSNJ = users["HS_NJ_Referral_Cans"];
	var HSMA = users["HS_MA_Referral_Cans"];
	var HSPA = users["HS_PA_Referral_Cans"];
	var HSGA = users["HS_GA_Referral_Cans"];
	var HSSC = users["HS_SC_Referral_Cans"];
	var HSOH = users["HS_OH_Referral_Cans"];
	var userLook="Cambridge";
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
	var date1 = ("0" + (d.getMonth()+1)).slice(-2) + ("0" + d.getDate()).slice(-2) + d.getFullYear();
	var time = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
	return client
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "NJ" })
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		.logInAs(HSNJ)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=NJ, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)

		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "MA" })
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})		
		.logInAs(HSMA)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=MA, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Save]", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)
		
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "GA" })
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		
		.logInAs(HSGA)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=GA, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Save]", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)
	
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "OH" })
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		.logInAs(HSOH)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=OH, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Save]", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)
		
		.logInAs(HSPA)
		.waitForVisible("a=Create New Referral", defaultOperationTimeout)
		.click("a=Create New Referral")
		.waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
		.fillInputText("First Name", "Cambridge"+(new Date().getTime()))
		.fillInputText("Last Name", "PA")
		.fillInputText("Date of Birth", "1/1/1990")
		.chooseSelectOption("Gender", "Male")
		.chooseSelectOption("Mailing State/Province", "Pennsylvania")
		.click("input[value='Create Person Being Referred']")
		.waitForVisible("input[value='Save Referral']", defaultOperationTimeout)	
		.click("a[id$=originlookup]")
		.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
		.setValue("input[id$=originstate]","pa")
		.click("span[id$=searchDialog2] input[value='Search!']")
		.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
		.element("span[id$=searchDialog2] a")
		.then(function (el) {
			return this.elementIdClick(el.value.ELEMENT);
		})
		 .click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "PA")
        .click("span[id$=searchDialog] input[value='Search!']")
        .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
        .element("span[id$=searchDialog] a")
        .then(function (el) {
          return this.elementIdClick(el.value.ELEMENT);
        })
		.selectLookup("User Assigned")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", HSPA["first_name"] + " " + HSPA["last_name"])
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click(".list tbody tr.dataRow th a")
        .switchToNextWindow()
		
        .chooseSelectOption("Status", "New")
        .click("span[id$=ReferralLocationModal] input[value='Save']")
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
		.selectByIndex("select[id$=servicesRequested_unselected]",0)
		.click("img[id$=servicesRequested_right_arrow]")
		.fillInputText("Anticipated Admission DateTime","1/1/2016")
		.click("input[value='Save Referral']")
		.waitForVisible("input[value='Convert']", defaultOperationTimeout)
		.click("input[value='Convert']")
		.waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
		.click("input[value='Confirm Conversion']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		.url("https://c.cs4.visual.force.com/apex/Home")
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=PA, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Save]", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)
		
		.logInAs(HSSC)
		.waitForVisible("a=Create New Referral", defaultOperationTimeout)
		.click("a=Create New Referral")
		.waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
		.fillInputText("First Name", "Cambridge"+(new Date().getTime()))
		.fillInputText("Last Name", "SC")
		.fillInputText("Date of Birth", "1/1/1990")
		.chooseSelectOption("Gender", "Male")
		.chooseSelectOption("Mailing State/Province", "South Carolina")
		.click("input[value='Create Person Being Referred']")
		.waitForVisible("input[value='Save Referral']", defaultOperationTimeout)	
		.click("a[id$=originlookup]")
		.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
		.setValue("input[id$=originstate]","SC")
		.click("span[id$=searchDialog2] input[value='Search!']")
		.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
		.element("span[id$=searchDialog2] a")
		.then(function (el) {
			return this.elementIdClick(el.value.ELEMENT);
		})
		 .click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "SC")
        .click("span[id$=searchDialog] input[value='Search!']")
        .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
        .element("span[id$=searchDialog] a")
        .then(function (el) {
          return this.elementIdClick(el.value.ELEMENT);
        })
		.selectLookup("User Assigned")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", HSPA["first_name"] + " " + HSPA["last_name"])
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click(".list tbody tr.dataRow th a")
        .switchToNextWindow()
		
        .chooseSelectOption("Status", "New")
        .click("span[id$=ReferralLocationModal] input[value='Save']")
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
		.selectByIndex("select[id$=servicesRequested_unselected]",0)
		.click("img[id$=servicesRequested_right_arrow]")
		.fillInputText("Anticipated Admission DateTime","1/1/2016")
		.click("input[value='Save Referral']")
		.waitForVisible("input[value='Convert']", defaultOperationTimeout)
		.click("input[value='Convert']")
		.waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
		.click("input[value='Confirm Conversion']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit Person Being Served']")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.getOutputTextFromInput("First Name")
		.getValue("input[id$=FirstNameInput]")
		.then(function(FName) {
			userLook=FName;
		})
		.url("https://c.cs4.visual.force.com/apex/Home")
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=SC, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.selectByVisibleText("select[class=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Save]", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Admission Detail", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Annual Health and Wellness Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Annual Health and Wellness Checklist", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs4.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("h3=Service Assignment", defaultOperationTimeout)
	}
});
