var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 15 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("HSNoteHomePage", suiteTimeout, {
"HSNoteHomePage": function(client, done) {
	var HSMA = users["HS_MA"];
	var HSMAIntaker = users["HS_MA_2_Referral_Intaker"];
	var HSPACans = users["HS_PA_Referral_Cans"];
	var HSGACans = users["HS_GA_Referral_Cans"];
	var HSMD = users["HS_MD"];
	var HSOH = users["HS_OH"];
	var userLook="Redwood";
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
	var date1 = ("0" + (d.getMonth()+1)).slice(-2) + ("0" + d.getDate()).slice(-2) + d.getFullYear();
	var time = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
	return client
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "MA" })
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
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. MA - SA1 - ")
		.click("a*=C. MA - SA1 - ")
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
		.setValue("input[id$=tar1]","1/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		
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
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		
		.logInAs(HSMAIntaker)
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
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)

		.logInAs(HSPACans)
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
        .setValue("input#lksrch", HSPACans["first_name"] + " " + HSPACans["last_name"])
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
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add Diagnosis']")
		.click("a*=Admission 1 - ")	  
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. PA - SA1 - ")
		.click("a*=C. PA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Plan']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date",date)
		.fillInputText("Target Date","1/14/2017")
		.setValue("textarea[id$=txtaoe]", "Testing")
		.selectByValue("select[id$=stat1]", "New")
		.setValue("input[id$=effe1]",date)
		.setValue("input[id$=tar1]","12/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")

		.waitForVisible("input[value='Revise']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
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
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)

		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "GA" })
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
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. GA - SA1 - ")
		.click("a*=C. GA - SA1 - ")
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
		.setValue("input[id$=tar1]","1/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")

		.logInAs(HSGACans)
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
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)

		.logInAs(HSMD)
		.waitForVisible("a=Create New Referral", defaultOperationTimeout)
		.click("a=Create New Referral")
		.waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
		.fillInputText("First Name", "Cambridge"+(new Date().getTime()))
		.fillInputText("Last Name", "MD")
		.fillInputText("Date of Birth", "1/1/1990")
		.chooseSelectOption("Gender", "Male")
		.chooseSelectOption("Mailing State/Province", "Pennsylvania")
		.click("input[value='Create Person Being Referred']")
		.waitForVisible("input[value='Save Referral']", defaultOperationTimeout)	
		.click("a[id$=originlookup]")
		.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
		.setValue("input[id$=originstate]","MD")
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
        .setValue("input[id$=addlocationstate]", "MD")
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
        .setValue("input#lksrch", HSMD["first_name"] + " " + HSMD["last_name"])
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
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add Diagnosis']")
		.click("a*=Admission 1 - ")	  
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. MD - SA1 - ")
		.click("a*=C. MD - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Plan']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date",date)
		.fillInputText("Target Date","1/14/2017")
		.setValue("textarea[id$=txtaoe]", "Testing")
		.selectByValue("select[id$=stat1]", "New")
		.setValue("input[id$=effe1]",date)
		.setValue("input[id$=tar1]","12/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.waitForVisible("input[value='Revise']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})		

		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=MD, Cambridge")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)

		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "OH" })
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
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. OH - SA1 - ")
		.click("a*=C. OH - SA1 - ")
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
		.setValue("input[id$=tar1]","1/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "OH" })
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
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("a*=C. OH - SA1 - ")
		.click("a*=C. OH - SA1 - ")
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
		.setValue("input[id$=tar1]","1/14/2016")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")			

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
		.click("a=Add Progress Note")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.click("input[value=Cancel]")
		.selectByVisibleText("select[id$=actionList]","Create New CANS Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Authorizations")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Case Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","CANS Assessments")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New CANS Assessment']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Fidelity Checklist")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("a*=Admission 1 - ", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Progress Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
	}
});
