var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("NR_Prog_Note", suiteTimeout, {
  "Progress Note": function(client, done) {
	var d=new Date();
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
		.click("input[value='Add']")
		.chooseSelectOption("Rancho Score at Start of Service", "1")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.click("img[class='unstickPbs']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.waitForVisible("input[id$=isbillable]", defaultOperationTimeout)
		.click("input[id$='TypeOfNoteField:0']")
		.fillInputText("Start Time","1/12/2016 6:00 PM")
		.fillInputText("End Time","1/12/2016 6:01 PM")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home", "School", "Office", "Community", "Community Mental Health Center", "Court", "Day Program", "Medical Facility", "MR Intermediate Care", "Other"
			], ServLoc);
		})
		.chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Type of Contact")
		.then(function(Contact) {
		assert.deepEqual([
			"", "Face-To-Face", "Phone", "Collateral", "Team", "Other"
			], Contact);
		})
		.chooseSelectOption("Type of Contact", "Phone")
		.selectCheckbox("Purpose/Service is Billable")
		.fillInputText("Unit(s)","2")
		.fillInputText("People Present","2")
		.fillInputText("Number of Required Signatures","1")
		.unselectCheckbox("Purpose/Service is Billable")
		.scroll("input[value='Save and Continue']")
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.chooseSelectOption("Service Location", "Community")
		.fillInputText("Interventions","Test1")
		.fillInputText("Progress","Test2")
		.fillInputText("Notes For Next Visit","Test3")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value=' Save ']", defaultOperationTimeout)
		.click("input[value=' Save ']")
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.pause(1000)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[id$=approver]", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		}
});
