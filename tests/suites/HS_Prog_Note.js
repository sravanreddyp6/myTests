var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("HS_Prog_Note", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user1 = users["HS_MA"];
  var user2 = users["HS_MA_2_Referral_Intaker"];
  var user3 = users["HS_OH"];
  var user4 = users["HS_OH_Ary2_Referral_Intaker"];
  var user5 = users["HS_OH_Ary1_Referral_Intaker"];
  var user6 = users["HS_MD"];
  var user7 = users["HS_MD_1_Referral_Intaker"];
  var user8 = users["HS_MD_2_Referral_Intaker"];
  var user9 = users["HS_MD_3_Referral_Intaker"];
  var user10 = users["HS_PA_Referral_Cans"];
  var user11 = users["HS_GA_Referral_Cans"];
  var today =new Date().getDate() + new Date().getMilliseconds();
  var saveurl;
    return client
	//MA
	.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "MA" , hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.click("a[id$=originlookup]")
				.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","020612")
				.setValue("input[id$=originstate]","ma")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] tbody tr:nth-child(1) td:nth-child(1) a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
        	}
      }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=C. MA - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=C. MA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add']")
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.chooseSelectOption("Model", "MENTOR")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
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
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		
		.logInAs(user2)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.pause(1000)
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		//OH
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "OH" , hooks: {
				"create_referral_before_save_referral": function (client) {
				return client
					.click("a[id$=originlookup]")
					.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
					.setValue("input[id$=nameFilter2]","036318")
					.setValue("input[id$=originstate]","OH")
					.click("span[id$=searchDialog2] input[value='Search!']")
					.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
					.element("span[id$=searchDialog2] tbody tr:nth-child(1) td:nth-child(1) a")
					.then(function (el) {
					return this.elementIdClick(el.value.ELEMENT);
					})
				}
		  }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=C. OH - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=C. OH - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add']")
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.chooseSelectOption("Model", "MENTOR")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
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
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user3.first_name+" "+user3.last_name)
		.fillInputText("Staff Credentials","OH")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","OH")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		
		.logInAs(user4)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user4.first_name+" "+user4.last_name)
		.fillInputText("Staff Credentials","OH")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","OH")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		.logInAs(user5)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user5.first_name+" "+user5.last_name)
		.fillInputText("Staff Credentials","OH")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","OH")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")	
/*		//MD
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "MD" , hooks: {
			"create_referral_before_save_referral": function (client) {
			return client
				.click("a[id$=originlookup]")
				.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
				.setValue("input[id$=nameFilter2]","036318")
				.setValue("input[id$=originstate]","MD")
				.click("span[id$=searchDialog2] input[value='Search!']")
				.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
				.element("span[id$=searchDialog2] tbody tr:nth-child(1) td:nth-child(1) a")
				.then(function (el) {
				return this.elementIdClick(el.value.ELEMENT);
				})
			}
		  }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=C. MD - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=C. MD - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add']")
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.chooseSelectOption("Model", "MENTOR")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
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
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user6.first_name+" "+user6.last_name)
		.fillInputText("Staff Credentials","MD")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","MD")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		
		.logInAs(user7)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user7.first_name+" "+user7.last_name)
		.fillInputText("Staff Credentials","MD")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","MD")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		.logInAs(user8)
		.then(function () {
			return client.url(saveurl)
		})	
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='New Note']")
		.click("input[value='New Note']")
		.waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user8.first_name+" "+user8.last_name)
		.fillInputText("Staff Credentials","MD")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","MD")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")	
		
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
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user9.first_name+" "+user9.last_name)
		.fillInputText("Staff Credentials","MD")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","MD")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")	
		//PA
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "PA" , hooks: {
				"create_referral_before_save_referral": function (client) {
				return client
					.click("a[id$=originlookup]")
					.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
					.setValue("input[id$=nameFilter2]","036318")
					.setValue("input[id$=originstate]","PA")
					.click("span[id$=searchDialog2] input[value='Search!']")
					.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
					.element("span[id$=searchDialog2] tbody tr:nth-child(1) td:nth-child(1) a")
					.then(function (el) {
					return this.elementIdClick(el.value.ELEMENT);
					})
				}
		  }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=C. PA - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=C. PA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add']")
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.chooseSelectOption("Model", "MENTOR")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
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
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Primary Diagnosis","1")
		.fillInputText("Staff Name",user10.first_name+" "+user10.last_name)
		.fillInputText("Staff Credentials","PA")
		.pause(1000)
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.click("input[value='Finalize this Progress Note']")
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout)
		.fillInputText("Staff Credentials","PA")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)		
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
*/		//GA
		.execUtil("convert_referral", {operatingGroup: "Cambridge",flavor: "GA" , hooks: {
				"create_referral_before_save_referral": function (client) {
				return client
					.click("a[id$=originlookup]")
					.waitForVisible("span[id$=searchDialog2] input[value='Search!']", defaultOperationTimeout)
					.setValue("input[id$=nameFilter2]","028010")
					.setValue("input[id$=originstate]","nc")
					.click("span[id$=searchDialog2] input[value='Search!']")
					.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
					.element("span[id$=searchDialog2] tbody tr:nth-child(1) td:nth-child(1) a")
					.then(function (el) {
					return this.elementIdClick(el.value.ELEMENT);
					})
				}
		  }})
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 -")
		.scroll("a*=C. GA - SA1 - ")
		.click("img[class='unstickPbs']")
		.click("a*=C. GA - SA1 - ")
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Edit']")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Add']")
		.click("input[value='Add']")
		.waitForVisible("input[value='Remove']", defaultOperationTimeout)
		.chooseSelectOption("Episode", "1")
		.chooseSelectOption("Model", "MENTOR")
		.chooseSelectOption("Was this a transfer from another Service Assignment?", "Yes")
		.chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "Yes")
		.waitForVisible("input[value='Save']", defaultOperationTimeout)
		.click("span[id$='buttons'] input[value='Save']")	
		.waitForVisible("input[value='Edit']", defaultOperationTimeout)
		.getUrl()
		.then(function(url) {
			saveurl=url;
		})	
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
		.click("input[id$='TypeOfNoteField:0']")
		.fillInputText("Start Time","2/1/2016 01:01 AM")
		.fillInputText("End Time","2/1/2016 01:02 AM")
		.fillInputText("Number of Required Signatures","0")
		.unselectCheckbox("Purpose/Service is Billable")
		.getSelectOptions("Service Location")
		.then(function(ServLoc) {
		assert.deepEqual([
			"", "Home","School","Office","Community","Community Mental Health Center","Court","Day Program","Medical Facility","MR Intermediate Care","Other"
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
		.click("input[value='Save and Continue']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.frame("066U0000000TJv5")
		.waitForVisible("select[title='Service Code']", defaultOperationTimeout)
		.selectByIndex("select[title='Service Code']",1)
		.frameParent()
		.frame("066U0000000odhz")
		.click("input[id$='goal']")
		.frameParent()
		.click("input[value=' Edit ']")
		.waitForVisible("input[value='Save & New']", defaultOperationTimeout) 
		.fillInputText("Interventions","Interventions")
		.fillInputText("Progress","Progress")
		.click("input[value=' Save ']")
		.waitForVisible("input[value='Finalize this Progress Note']", defaultOperationTimeout)
		.click("input[value='Finalize this Progress Note']")
		.waitForVisible("input[value='Submit for Approval']", defaultOperationTimeout)
		.click("table[class='detailList'] input[type='checkbox']")
		.waitForVisible("input[value='Mark Final']", defaultOperationTimeout)
		.click("input[value='Mark Final']")
		.waitForVisible("input[value='Disregard Note']", defaultOperationTimeout)
		.click("input[value='Disregard Note']")
		}
});
