var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
 
testSuite("RWPercentComplete", suiteTimeout, {
	"Test Case - Calculate Percent Complete for Redwood User": function(client, done) {
	return client
		.execUtil("convert_referral",{
			operatingGroup: "Redwood",
			flavor: "MN"
		})
	//check for percent complete display
	.waitForVisible("span#frmProgress")
	.getText("span#compScore")
	//check score
	.then(function (cscore) {
		assert.equal("5/13(38%)",cscore);	
	})
	//edit field taken into account for percent complete calculation
	.click("input[value='Edit Person Being Served']")
	.waitForVisible("input[value='Save']", defaultOperationTimeout)
	.chooseSelectOption("Race", "American Indian/Alaskan")
	.click("input[value='Save']")
	.waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	.getText("span#compScore")
	//confirm score changes with field edit
	.then(function (cscore) {
		assert.equal("6/13(46%)",cscore);	
	})
	//confirm fields for percent complete are displayed for PBS page
	.moveToObject("span#frmProgress")
	.getText("#progressTable tbody tr:nth-child(1) td:nth-child(1)")
	.then(function (fname) {
		assert.equal("First Name",fname);	
	})
	.getText("#progressTable tbody tr:nth-child(2) td:nth-child(1)")
	.then(function (lname) {
		assert.equal("Last Name",lname);	
	})
	.getText("#progressTable tbody tr:nth-child(3) td:nth-child(1)")
	.then(function (pcRace) {
		assert.equal("Race",pcRace);	
	})
	.getText("#progressTable tbody tr:nth-child(4) td:nth-child(1)")
	.then(function (pcEth) {
		assert.equal("Ethnicity",pcEth);	
	})
	.getText("#progressTable tbody tr:nth-child(5) td:nth-child(1)")
	.then(function (pcMartial) {
		assert.equal("Marital Status",pcMartial);	
	})
	.getText("#progressTable tbody tr:nth-child(6) td:nth-child(1)")
	.then(function (pcDoB) {
		assert.equal("Date of Birth",pcDoB);	
	})
	.getText("#progressTable tbody tr:nth-child(7) td:nth-child(1)")
	.then(function (pcLang) {
		assert.equal("Primary Language",pcLang);	
	})
	.getText("#progressTable tbody tr:nth-child(8) td:nth-child(1)")
	.then(function (pcGender) {
		assert.equal("Gender",pcGender);	
	})
	.getText("#progressTable tbody tr:nth-child(9) td:nth-child(1)")
	.then(function (pcGenId) {
		assert.equal("Does the person Identify with a gender other than legal gender selected?",pcGenId);	
	})
	.getText("#progressTable tbody tr:nth-child(10) td:nth-child(1)")
	.then(function (pcGuard) {
		assert.equal("Guardianship Type",pcGuard);	
	})
	.getText("#progressTable tbody tr:nth-child(11) td:nth-child(1)")
	.then(function (pcRelated) {
		assert.equal("At least one Related Party",pcRelated);	
	})
	.getText("#progressTable tbody tr:nth-child(12) td:nth-child(1)")
	.then(function (pcDiag) {
		assert.equal("At least one Diagnosis",pcDiag);	
	})
	//move to Admission page
	.scroll("[id$=adminsId]", 0 , -300)
    .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")
	.waitForVisible("span#frmProgress")
	//confirm score is correct for percent complete on admission page
	.getText("span#compScore")
	.then(function (ascore) {
		assert.equal("4/4(100%)",ascore);	
	})
	//confirm correct fields are displayed in percent complete for admission
	.moveToObject("span#frmProgress")
	.getText("#progressTable tbody tr:nth-child(1) td:nth-child(1)")
	.then(function (pcAdStat) {
		assert.equal("Admission Status",pcAdStat);
	})
	.getText("#progressTable tbody tr:nth-child(2) td:nth-child(1)")
	.then(function (pcNetOff) {
		assert.equal("Network Offering",pcNetOff);	
	})
	.getText("#progressTable tbody tr:nth-child(4) td:nth-child(1)")
	.then(function (pcAdDate) {
		assert.equal("Admission Date",pcAdDate);
	})
	.getText("#progressTable tbody tr:nth-child(3) td:nth-child(1)")
	.then(function (pcState) {
		assert.equal("State",pcState);	
	})
	//move to service assignment
	.scroll("[id$=servAssignId]", 0 , -300)
    .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")
	//confirm percent complete for service assignment is showing with score
	.waitForVisible("span#frmProgress", defaultOperationTimeout)
	.getText("span#compScore")
	.then(function (cscore) {
		assert.equal("3/6(50%)",cscore);	
	})
	//edit field to show score change
	.click("input[value='Edit']")
	.waitForVisible("span#frmProgress", defaultOperationTimeout)
	.chooseSelectOption("Highest Level of Education at Start of Service", "Grade 1")
	.click("[id$=SaveStatus1] input[value='Save']")
	.waitForVisible("input[value='Edit']", defaultOperationTimeout)
	.getText("span#compScore")
	.then(function (cscore) {
		assert.equal("4/6(67%)",cscore);	
	})
	//confirm fields to be shown for percent complete are shown on service assignment.
	.moveToObject("span#frmProgress")
	.getText("#progressTable tbody tr:nth-child(1) td:nth-child(1)")
	.then(function (saStat) {
		assert.equal("Service Assignment Status",saStat);	
	})
	.getText("#progressTable tbody tr:nth-child(2) td:nth-child(1)")
	.then(function (startDate) {
		assert.equal("Start Date",startDate);	
	})
	.getText("#progressTable tbody tr:nth-child(3) td:nth-child(1)")
	.then(function (servBegan) {
		assert.equal("Service Began via Acquisition Company (as of 2016)?",servBegan);	
	})
	.getText("#progressTable tbody tr:nth-child(4) td:nth-child(1)")
	.then(function (edSOS) {
		assert.equal("Educational Involvement at Start of Service",edSOS);	
	})
	.getText("#progressTable tbody tr:nth-child(5) td:nth-child(1)")
	.then(function (highEd) {
		assert.equal("Highest Level of Education at Start of Service",highEd);	
	})
	.getText("#progressTable tbody tr:nth-child(6) td:nth-child(1)")
	.then(function (pcDiag) {
		assert.equal("At least one Diagnosis",pcDiag);	
	})
	}	
})

