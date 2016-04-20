var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("NR_Prog_Note", suiteTimeout, {
  "Progress Note": function(client, done) {
	var user=users["NR_carbondale"];
	var d=new Date();
	var saveurl;
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
    .execUtil("convert_referral", {operatingGroup: "NeuroRestorative",flavor: "MA" , hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.chooseSelectOption("Highest Level of Education", "Graduate School")
				.click("a[id$=originlookup]")
				.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","131015")
				.setValue("input[id$=originstate]","MA")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] tbody tr:nth-child(2) td:nth-child(1) a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
        	}
      }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - ")
		.scroll("a*=N. MA - SA1 - ")
		.click("a*=N. MA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
	//	.click("input[value='Add']")
		.chooseSelectOption("Rancho Score at Start of Service", "1")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.click("img[class='unstickPbs']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Note']")
		.waitForVisible("input[id$=isBillable]", defaultOperationTimeout)
	//	.click("input[id$='TypeOfNoteField:0']")
		.fillInputText("Start Time","1/12/2016 6:00 PM")
		.fillInputText("End Time","1/12/2016 6:01 PM")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home", "School", "Community", "Other", "Office/TRAC"
			], ServLoc);
		})
		.chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Type of Contact")
		.then(function(Contact) {
		assert.deepEqual([
			"", "No-Show", "Face-To-Face", "Phone", "Team", "Conference", "Telehealth", "Indirect"
			], Contact);
		})
		.chooseSelectOption("Type of Contact", "Phone")
		.selectCheckbox("Purpose/Service is Billable")
	//	.fillInputText("Unit(s)","2")
		.fillInputText("People Present","2")
		.fillInputText("Number of Required Signatures","1")
		.unselectCheckbox("Purpose/Service is Billable")
		.selectByIndex("select[title='Service Code']",1)
		.getSelectOptions("Type of Treatment")
		.then(function(Treatment) {
		assert.deepEqual([
			"", "Individual", "Co-Treatment", "Group", "Indirect"
			], Treatment);
		})
		.chooseSelectOption("Type of Treatment", "Group")
		.getSelectOptions("Therapy Discipline")
		.then(function(Discipline) {
		assert.deepEqual([
			"", "PT", "OT", "SLP", "Counseling", "BIT", "Recreation Therapy", "Woodshop", "Productive Activity"
			], Discipline);
		})
		.chooseSelectOption("Therapy Discipline", "OT")
		.scroll("div[class='pbBottomButtons'] input[value='Save']")
		.click("div[class='pbBottomButtons'] input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.switchToNextWindow()
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.selectCheckboxBySelector ("div[class='custPopup'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard']", defaultOperationTimeout)
		.click("input[value='Disregard']")
		.waitForVisible("input[value='Disregard']", defaultOperationTimeout,true)

		.execUtil("convert_referral", {operatingGroup: "NeuroRestorative",flavor: "MA" , hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.chooseSelectOption("Highest Level of Education", "Graduate School")
				.click("a[id$=originlookup]")
				.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","131015")
				.setValue("input[id$=originstate]","MA")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] tbody tr:nth-child(2) td:nth-child(1) a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
        	}
      }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - ")
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
		.logInAs(user)
		.then(function () {
			return client.url(saveurl)
		})
		.scroll("a*=N. MA - SA1 - ")
		.click("a*=N. MA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
	//	.click("input[value='Add']")
		.chooseSelectOption("Rancho Score at Start of Service", "1")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.click("img[class='unstickPbs']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Note']")
		.waitForVisible("input[id$=isBillable]", defaultOperationTimeout)
	//	.click("input[id$='TypeOfNoteField:0']")
		.fillInputText("Start Time","1/12/2016 6:00 PM")
		.fillInputText("End Time","1/12/2016 6:01 PM")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home", "School", "Community", "Other", "Office/TRAC"
			], ServLoc);
		})
		.chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Type of Contact")
		.then(function(Contact) {
		assert.deepEqual([
			"", "No-Show", "Face-To-Face", "Phone", "Team", "Conference", "Telehealth", "Indirect"
			], Contact);
		})
		.chooseSelectOption("Type of Contact", "Phone")
		.selectCheckbox("Purpose/Service is Billable")
	//	.fillInputText("Unit(s)","2")
		.fillInputText("People Present","2")
		.fillInputText("Number of Required Signatures","1")
		.unselectCheckbox("Purpose/Service is Billable")
		.selectByIndex("select[title='Service Code']",1)
		.getSelectOptions("Type of Treatment")
		.then(function(Treatment) {
		assert.deepEqual([
			"", "Individual", "Co-Treatment", "Group", "Indirect"
			], Treatment);
		})
		.chooseSelectOption("Type of Treatment", "Group")
		.getSelectOptions("Therapy Discipline")
		.then(function(Discipline) {
		assert.deepEqual([
			"", "PT", "OT", "SLP", "Counseling", "BIT", "Recreation Therapy", "Woodshop", "Productive Activity"
			], Discipline);
		})
		.chooseSelectOption("Therapy Discipline", "OT")
		.scroll("div[class='pbBottomButtons'] input[value='Save']")
		.click("div[class='pbBottomButtons'] input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.switchToNextWindow()
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.selectCheckboxBySelector ("div[class='custPopup'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard']", defaultOperationTimeout)
		.click("input[value='Disregard']")
		.waitForVisible("input[value='Disregard']", defaultOperationTimeout,true)		
		
		
		}
});
