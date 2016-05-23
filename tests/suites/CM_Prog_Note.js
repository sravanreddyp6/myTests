var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("CM_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["CM_DON"];
  var saveurl;
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
   .execUtil("convert_referral", {
      operatingGroup: "Care Meridian",flavor: "AZ"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - Care Meridian")
		.scroll("a=C. AZ - SA1 - 114160 - ABI")
		.click("a=C. AZ - SA1 - 114160 - ABI")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Add Nurses Shift Documentation']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "sdfgsdfgsdfgsdfg")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user.username)
		.fillInputText("Password",user.password)
		.click("input[name$=esignButton]")
		.pause(3000)
		.alertDismiss()
		}
});
