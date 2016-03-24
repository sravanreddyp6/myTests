var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("RW_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["RW_AZ_handler"];
  var userApprov = users["RW_AZ_Prog_Note_Approv"];
  var saveurl;
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
    .execUtil("convert_referral", {
      operatingGroup: "Redwood",
      flavor: "AZ" ,
      hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.click("a[id$=originlookup]")
				.waitForVisible("input[id$=originstate]", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","122874")
				.setValue("input[id$=originstate]","AZ")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
        	}
      }
      })
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - Redwood")
		.scroll("a=R. AZ - SA1 - 122874 - Non-Residential Supported Living/IHSS/Ind Living")
		.click("a=R. AZ - SA1 - 122874 - Non-Residential Supported Living/IHSS/Ind Living")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Add']", defaultOperationTimeout)
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.getUrl().then(function(url) {
        saveurl=url;
		})
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
		.waitForActionStatusDisappearance("myStatus",defaultOperationTimeout)
		.click("input[value='Acknowledge']")	
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.click("div[class='pbSubsection'] input[value='Acknowledge']")	
		.waitForActionStatusDisappearance("myStatus",defaultOperationTimeout)
		.click("a=R. AZ - SA1 - 122874 - Non-Residential Supported Living/IHSS/Ind Living")
		.waitForVisible("input[value='New Note']", defaultOperationTimeout)
		.scroll("input[value='Associate Diagnosis']")	
		.click("input[value='New Note']")
		.waitForVisible("input[id$=isbillable]", defaultOperationTimeout)
		.setValue("input[id=serviceStartTime]", "01/25/2016 00:42")
		.setValue("input[id=serviceEndTime]", "01/25/2016 00:43")
      .chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Service Location")
      .then(function(ServLoc) {
        assert.deepEqual([
          "", "Home", "Community", "Community Mental Health Center"
        ], ServLoc);
      })
      .chooseSelectOption("Type of Contact", "Phone")
		.getSelectOptions("Type of Contact")
      .then(function(Contact) {
        assert.deepEqual([
          "", "Face-To-Face", "Phone"
        ], Contact);
      })
      .selectCheckbox("Purpose/Service is Billable")
		.fillInputText("Unit(s)","2")
		.fillInputText("People Present","2")
		.fillInputText("Number of Required Signatures","1")
		.selectByIndex("select[title='Service Code']",1)
		.fillInputText("Interventions","dfghsdfgh")
		.fillInputText("Progress","rgsertge")
		.fillInputText("Notes For Next Visit","sdfgsdth")
		.click("span[class='fancytree-checkbox']")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
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
		.setValue("input#lksrch", userApprov["first_name"] + " " + userApprov["last_name"])
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
		.logInAs(userApprov)
		.then(function () {
			return client.url(saveurl)
		})
		.scroll("a=Approve / Reject")
		.click("a=Approve / Reject")
		.waitForVisible("input[value='Reject']", defaultOperationTimeout)
		.click("input[value='Approve']")
		}
});
