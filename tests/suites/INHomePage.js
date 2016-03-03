var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("INHomePage", suiteTimeout, {
"INHomePage": function(client, done) {
	var APPuser = users["RW_IN_DSP1APP"];
	var Lvl1user = users["RW_IN_DSP"];
	var Lvl3user = users["RW_IN_L3"];
	var userLook="Redwood";
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
	var date1 = ("0" + (d.getMonth()+1)).slice(-2) + ("0" + d.getDate()).slice(-2) + d.getFullYear();
	var time = ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2);
	return client
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "IN" })
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
		.scroll("a*=R. IN - SA1 - ")
		.click("a*=R. IN - SA1 - ")
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
/*		
		//1 APP
		.deleteCookie()
		.url("https://test.salesforce.com")
		.setValue("input#username", APPuser.username)
		.setValue("input#password", APPuser.password)
		.click("input#Login")
		.pause(2000)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.click("a*=IN, Redwood")
		.waitForVisible("div[class=thinking]",defaultOperationTimeout, true)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")
//		.click("a=Add Behavior Data")
//		.waitForVisible("input[value='Save']", defaultOperationTimeout)
//		.click("input[value='Save']")
//		.waitForVisible("input[value='Save']", defaultOperationTimeout)
//		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.waitForVisible("div[class=thinking]",defaultOperationTimeout, true)
		.click("a=Add Skill Data")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("input[value='Save']")
		.waitForVisible("div[class=thinking]",defaultOperationTimeout, true)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.waitForVisible("a=Add Shift Note",defaultOperationTimeout)
		.click("a=Add Shift Note")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=actionlist]","Record Seizure")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value='Add Seizure']", defaultOperationTimeout)
		.click("input[value='Add Seizure']")
		.switchToNextWindow()
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Start Time", date + " " + time+":10")
		.fillInputText("End Time", date + " " + time+":11")
		.fillInputText("Comments", "Test comments")
		.click("select[id$=seizureEntry_serviceAssignmentId]")
		.click("input[value=Save]")
		.waitForVisible("input[value='Add Seizure']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.waitForVisible("select[id$=actionlist]", defaultOperationTimeout)
		.selectByVisibleText("select[id$=actionlist]","View Behavior Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("img[name='Skill']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=actionlist]","View Skill Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("img[name='Skill']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=actionlist]","View Shift Notes")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("h2=Shift Notes", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=actionlist]","Acknowledge Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("a=Acknowledge", defaultOperationTimeout)
		.fillInputText("Initials","TS")
		.click("a=Acknowledge")
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
//		.selectByVisibleText("select[id$=actionlist]","Record Time Log")
//		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
//		.waitForVisible("", defaultOperationTimeout)
//		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("table[id$=acktbl] tbody tr:nth-child(1) td:nth-child(1)", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/DSPHome")
		.selectByVisibleText("select[id$=navigationList]","Shift Note Summary")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value=Run]", defaultOperationTimeout)
*/
		//Level 1
		.logInAs(Lvl1user)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=IN, Redwood")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.click("a=Add Behavior Data")
		.waitForVisible("span[id$=behaviorWS]", defaultOperationTimeout)
		.click("span[id$=behaviorWS]")
		.click("a=12/1/2016")
		.waitForVisible("input[id$=formSave]", defaultOperationTimeout)
		.click("input[id$=formSave]")
		.url("https://c.cs20.visual.force.com/apex/Home")
		.waitForActionStatusDisappearance("start", defaultOperationTimeout)
		.click("a=Add Skill Data")
		.waitForVisible("span[id$=skillsWS]", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.click("span[id$=skillsWS]")
		.click("a*=2016")
		.waitForVisible("input[id$=formSave]", defaultOperationTimeout)
		.click("input[id$=formSave]")
		.url("https://c.cs20.visual.force.com/apex/Home")
		.click("a=Add Shift Note")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time",date+" 01:01 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("input[value=Save]")
		.waitForVisible("input[value=E-sign]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.waitForVisible("input[value='Add Task']", defaultOperationTimeout)	
		.selectByVisibleText("select[id$=actionList]","Acknowledge Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.click("input[value=Acknowledge]")
		.switchToNextWindow()
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.fillInputText("Initials","TS")
		.click("form[id$=myAck] input[value=Acknowledge]")
		.waitForVisible("div[class=thinking]",defaultOperationTimeout, true)	
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=actionList]","View Behavior Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("span[id$=behaviorWS]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=actionList]","View Skill Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("span[id$=skillsWS]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[type='search']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Allergy")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Allergy']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Risk Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Shift Note Summary Report")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value=Run]", defaultOperationTimeout)	

		//Level 3
		.logInAs(Lvl3user)
		.then(function () {
			return client.setValue("input[id$=PbsSearchFirstName]", userLook)
		})
		.click("input[value=Find]")
		.switchToNextWindow()
		.waitForVisible("input[value='Done']", defaultOperationTimeout)
		.setValue("input[type='search']","Served")
		.click("a*=IN, Redwood")
		.waitForActionStatusDisappearance("pageProcessing" , defaultOperationTimeout)
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(1) a")	
		.click("a=Add Behavior Data")
		.waitForVisible("span[id$=behaviorWS]", defaultOperationTimeout)
		.click("span[id$=behaviorWS]")
		.click("a=12/1/2016")
		.waitForVisible("input[id$=formSave]", defaultOperationTimeout)
		.click("input[id$=formSave]")
		.url("https://c.cs20.visual.force.com/apex/Home")
		.waitForActionStatusDisappearance("start", defaultOperationTimeout)
		.click("a=Add Skill Data")
		.waitForVisible("span[id$=skillsWS]", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.click("span[id$=skillsWS]")
		.click("a*=2016")
		.waitForVisible("input[id$=formSave]", defaultOperationTimeout)
		.click("input[id$=formSave]")
		.url("https://c.cs20.visual.force.com/apex/Home")
		.click("a=Add Shift Note")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time",date+" 01:01 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("input[value=Save]")
		.waitForVisible("input[value=E-sign]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.waitForVisible("input[value='Add Task']", defaultOperationTimeout)	
		.selectByVisibleText("select[id$=actionList]","Acknowledge Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.click("input[value=Acknowledge]")
		.switchToNextWindow()
		.waitForVisible("input[value=Cancel]", defaultOperationTimeout)
		.fillInputText("Initials","TS")
		.click("form[id$=myAck] input[value=Acknowledge]")
		.waitForVisible("div[class=thinking]",defaultOperationTimeout, true)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=actionList]","View Behavior Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("span[id$=behaviorWS]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=actionList]","View Skill Data")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(5) input")
		.waitForVisible("span[id$=skillsWS]", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Action Plan")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Acknowledgment Overview']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Admission Documents")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[type='search']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Allergy")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Allergy']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Assistive Devices")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Add Assistive Device']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Diagnosis")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Risk Assessment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Service Assignment")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")
		.selectByVisibleText("select[id$=navigationList]","Summaries")
		.click("table[id$=serviceAssignmentTable] tbody tr:nth-child(1) td:nth-child(6) input")
		.waitForVisible("input[value='New Action Plan Summary']", defaultOperationTimeout)
		.url("https://c.cs20.visual.force.com/apex/Home")

	}
});
