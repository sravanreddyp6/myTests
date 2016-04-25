var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 15 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("RW_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user1 = users["RW_CA_DSP"];
  var user2 = users["RW_CA_L3"];
  var user3 = users["RW_IA_DSP"];
  var user4 = users["RW_IA_L3"];
  var user5 = users["RW_IA_Management"];
  var user6 = users["RW_IN_DSP"];
  var user7 = users["RW_IN_L3"];
  var user8 = users["RW_IN_Management"];
  var user9 = users["RW_WI_DSP"];
  var user10 = users["RW_WI_L3"];
  var user11 = users["RW_MN_L3"];
  var user12 = users["RW_MN_Management"];
  var user13 = users["RW_OR_L3"];
  var saveurl;
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
		//CA
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "CA"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. CA - SA1 - ")
		.click("a*=R. CA - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user1)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		
		//IA
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "IA"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. IA - SA1 - ")
		.click("a*=R. IA - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user3)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user5)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")		
		
		//IN
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "IN"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. IN - SA1 - ")
		.click("a*=R. IN - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user6)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user8)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")		
		
		//MN
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "MN"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. MN - SA1 - ")
		.click("a*=R. MN - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		.logInAs(user12)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Shift Start Time","2/1/2016 01:01 AM")
		.fillInputText("Shift End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.fillInputText("Narrative","Testing")
		.click("img[class='unstickPbs']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")
		
		//WI
		.execUtil("create_referral", {operatingGroup: "Redwood",flavor: "WI"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. WI - SA1 - ")
		.click("a*=R. WI - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.click("input[value='Save and Continue']")
		.logInAs(user9)
		.then(function () {
			return client.url(saveurl)
		})		
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2017 01:02 AM")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home", "School", "Office", "Community", "Community Mental Health Center", "Court", "Day Program", "Medical Facility", "MR Intermediate Care", "Other", "Office/TRAC"
			], ServLoc);
		})
		.chooseSelectOption("Service Location", "Home")
		.getSelectOptions("Type of Contact")
		.then(function(Contact) {
		assert.deepEqual([
			"", "No-Show", "Face-To-Face", "Phone","Collateral", "Team","Other", "Conference", "Telehealth", "Indirect"
			], Contact);
		})
		.chooseSelectOption("Type of Contact", "Phone")		
		.fillInputText("Number of Required Signatures","1")
		.click("input[value='Save and Continue']")
		
		//OR
		.execUtil("convert_referral", {operatingGroup: "Redwood",flavor: "OR"})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=R. OR - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=R. OR - SA1 - ")
		.getUrl().then(function(url) {
			saveurl=url;
		})	
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
		.setValue("input[id$=tar1]","1/14/2017")
		.setValue("div[id$=theAction] textarea", "Testing1")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
		.waitForVisible("input[value='Finalize']", defaultOperationTimeout)
		.click("input[value='Finalize']")	
		.waitForVisible("input[value='Acknowledge']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2017 01:02 AM")
		.fillInputText("Number of Required Signatures","1")
		.click("input[value='Save and Continue']")
		}
});
