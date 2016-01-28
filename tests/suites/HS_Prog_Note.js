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
  var saveurl;
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
				.element("span[id$=searchDialog2] tbody tr:nth-child(4) td:nth-child(1)")
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
		.click("img[class='unstickPbs']")
		.getUrl().then(function(url) {
        saveurl=url;
		})
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
		.setValue("input[id=serviceStartTime]", "01/25/2016 00:54")
		.setValue("input[id=serviceEndTime]", "01/25/2016 00:55")
      .chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Service Location")
      .then(function(ServLoc) {
        assert.deepEqual([
          "", "Home", "Scroll", "Office", "Community", "Community Mental Health Center", "Court", "Day Program", "Medical Facility", "MR Intermediate Care", "Other"
        ], ServLoc);
      })
      .chooseSelectOption("Type of Contact", "Phone")
		.getSelectOptions("Type of Contact")
      .then(function(Contact) {
        assert.deepEqual([
          "", "Face-To-Face", "Phone", "Collateral", "Team", "Other"
        ], Contact);
      })
      .selectCheckbox("Purpose/Service is Billable")
		.fillInputText("Unit(s)","2")
		.fillInputText("People Present","2")
		.fillInputText("Number of Required Signatures","1")
		.scroll("input[value='Save and Continue']")
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Create PDF']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[id$=isbillable]", defaultOperationTimeout)
      .chooseSelectOption("Service Location", "Community")
		.click("input[value='Save']")
		.waitForVisible("input[value='Create PDF']", defaultOperationTimeout)
		.click("input[value='Create PDF']")
		.getUrl().then(function(url) {
        saveurl=url;
		})	
		.click("input[name$='esign']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.fillInputText("Username",user.username)
		.fillInputText("Password",user.password)
		.click("input[name$=esignButton]")
		.pause(3000)
		.alertDismiss()
		.click("img[class='lookupIcon']")
		.switchToNextWindow()
		.waitForExist("#searchFrame", defaultOperationTimeout)
		.element("#searchFrame")
		.then(function (frame) { return frame.value; })
		.then(client.frame)
		.setValue("input#lksrch", user["first_name"] + " " + user["last_name"])
		.click("input[value*='Go']")
		.frameParent()
		.waitForExist("#resultsFrame", defaultOperationTimeout)
		.element("#resultsFrame")
		.then(function (frame) { return frame.value; })
		.then(client.frame)
		.click(".lookup tr.dataRow th a")
		.switchToNextWindow()
		.click("input[value='Submit for Approval']")
		.waitForVisible("input[value='Create PDF']", defaultOperationTimeout)
		.logInAs(users["RW_AZ_Prog_Note_Approv"])
		.then(function () {
			return client.url(saveurl)
		})
		.click("a=Approve / Reject")
		.waitForVisible("input[value='Reject']", defaultOperationTimeout)
		.click("input[value='Approve']")
		}
});
