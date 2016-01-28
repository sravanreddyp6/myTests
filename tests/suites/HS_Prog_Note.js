var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("HS_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["HS_GA_Referral_Cans"];
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
    .execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "GA" , hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.click("a[id$=originlookup]")
				.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","028010")
				.setValue("input[id$=originstate]","nc")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] tbody tr:nth-child(4) td:nth-child(1) a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
        	}
      }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - Cambridge")
		.scroll("a=C. GA - SA1 - 028010 - Clinical/Outpatient Therapy")
		.click("a=C. GA - SA1 - 028010 - Clinical/Outpatient Therapy")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
      .chooseSelectOption("Episode", "17")
      .chooseSelectOption("Model", "MENTOR")
		.click("input[value='Add']")
		.click("img[class='unstickPbs']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")	
		.click("input[value='New Plan']")
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date","1/12/2016")
		.fillInputText("Target Date","1/14/2016")
		.setValue("textarea[id$=txtaoe]", "sdfgsdfgsdfgsdfg")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForActionStatusDisappearance("myStatus",defaultOperationTimeout)
		.click("input[value='Acknowledge']")	
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.click("div[class='pbSubsection'] input[value='Acknowledge']")	
		.waitForActionStatusDisappearance("myStatus",defaultOperationTimeout)
		.click("a=C. GA - SA1 - 028010 - Clinical/Outpatient Therapy")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.scroll("input[value='Associate Diagnosis']")	
		.click("input[value='New Note']")
		.waitForVisible("input[id$=isbillable]", defaultOperationTimeout)
		.click("input[id$='TypeOfNoteField:0']")
		.fillInputText("Start Time","1/14/2016 3:00 PM")
		.fillInputText("End Time","1/14/2016 3:01 PM")
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
		.waitForVisible("input[value='Create PDF']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
      .chooseSelectOption("Service Location", "Community")
		.fillInputText("Interventions","Test1")
		.fillInputText("Progress","Test2")
		.fillInputText("Notes For Next Visit","Test3")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Create PDF']", defaultOperationTimeout)
		.click("input[value='Create PDF']")
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.frame("066U0000000odhz")
		.waitForVisible("input[id$=goal]", defaultOperationTimeout)
		.click("input[id$=goal]")
		.frameParent()
		.click("input[value='E-Signature']")
		.switchToNextWindow()
		.waitForVisible("input[value='Electronically Sign']", defaultOperationTimeout)
		.setValue("input[id='UserNme']",user.username)
		.click("input[value='Electronically Sign']")
		.pause(3000)
		.alertDismiss()
		.switchToNextWindow()
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='1']", defaultOperationTimeout)
		.click("input[value='1']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		
		}
});
