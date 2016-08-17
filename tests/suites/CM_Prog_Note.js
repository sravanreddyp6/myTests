var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("CM_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user1 = users["CM_CNA"];
  var user2 = users["CM_DON"];
  var user3 = users["CM_Nurse"];
  var user4 = users["CM_LVN"];
  var user5 = users["CM_CaseManager"];
  var saveurl;
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
		.execUtil("convert_referral", {operatingGroup: "Care Meridian",flavor: "AZ"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - ")
		.scroll("a*=C. AZ - SA1 - ")
		.click("a*=C. AZ - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add CNA Workbook']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "Testing")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user2.username)
		.fillInputText("Password",user2.password)
		.click("input[name$=esignButton]")
		.pause(5000)
		.alertDismiss()
		.logInAs(user1)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add CNA Workbook']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "Testing")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user1.username)
		.fillInputText("Password",user1.password)
		.click("input[name$=esignButton]")
		.pause(5000)
		.alertDismiss()
		.logInAs(user3)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add CNA Workbook']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "Testing")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user3.username)
		.fillInputText("Password",user3.password)
		.click("input[name$=esignButton]")
		.pause(5000)
		.alertDismiss()
		.logInAs(user4)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add CNA Workbook']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "Testing")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user4.username)
		.fillInputText("Password",user4.password)
		.click("input[name$=esignButton]")
		.pause(5000)
		.alertDismiss()
		.logInAs(user5)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add CNA Workbook']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Cancel']", defaultOperationTimeout)
		.setValue("textarea[id$=narr]", "Testing")
		.click("input[value='E-sign']")
		.waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		.fillInputText("Username",user5.username)
		.fillInputText("Password",user5.password)
		.click("input[name$=esignButton]")
		.pause(5000)
		.alertDismiss()	
		}
});
