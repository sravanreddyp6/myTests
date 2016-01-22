var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
//Should cover Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7 for HS
//Should cover Test Case: View Diagnosis 2, 3, 4, 5, and 6 for HS
testSuite("Assoc_Diagnosis_PBS", suiteTimeout, {
  "Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7 and Test Case: View Diagnosis 2, 3, 4, 5, and 6 for HS. Also, should associate a diagnosis with a PBS successfully": function(client, done) {
  var user = users["HS_AL_Auburn_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .execUtil("create_referral", {
      operatingGroup: "Cambridge",
      flavor: "GA" ,
      hooks: {
      		"create_referral_initial_referral": function (client) {
      		return client.click("input[value='Add Diagnosis']")
        .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
        .click("[id$=diagnosisEntry] .lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "A00")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#ICD__c_body tr.dataRow th a")
        .switchToNextWindow()

        .fillInputText("Date and Time of Diagnosis", "01/12/2016 18:00")
        .click("span[id$=diagnosisModal] input[value='Save']")
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
        	}
        }
      })
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .isExisting("input[value='PRE 10/1/2015']")
      .then(function (isExisting) {
      		if(isExisting==false)
      	return true;
      		else
      	return this.click("input[value='PRE 10/1/2015']");
      })
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .isExisting("input[value='PRE 10/1/2015']")
      .then(function (isExisting) {
      		if(isExisting==false)
      	return true;
      		else
      	return this.click("input[value='PRE 10/1/2015']");
      })
      .waitForVisible("a[title='iServe Home Tab']", defaultOperationTimeout)
      .click("img[class='unstickPbs']")
      //.scroll("a[title='iServe Home Tab']", 0 , 7)
      //.click("a[title='iServe Home Tab']")
      .click("a*=Admission 1 -")
	  .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
      .click("a=C. GA - SA1 - 011030 - Clinical/Outpatient Therapy")
      //.click("a=My Recently Viewed Persons Being Served")
      //.waitForVisible("input[value='Refresh']", defaultOperationTimeout)
      //.click("table#persons_table tbody tr:nth-child(1) td:nth-child(3) a")
      //.element("#resultsFrame")
      //.then(function (frame) { return frame.value; })
      //.then(client.frame)
      //.click("tr.dataRow th a:first-child")
      .waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Associate Diagnosis']", 0, -500)
      .isExisting("input[value='PRE 10/1/2015']")
      .then(function (isExisting) {
      		if(isExisting==false)
      	return true;
      		else
      	return this.click("input[value='PRE 10/1/2015']");
      })
      .waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
	  .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A00 - Cholera"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A00 - Cholera", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .selectCheckbox("ABI Diagnosis")
      .fillInputText("Injury Date", "12/25/2015")
      .selectCheckbox("Billable")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      //.isExisting("input[value='Convert']")
      //.then(function(isExisting) {
      //  assert.Ok(isExisting, "Convert Button exists.");
      //})
       .element("label=Primary Active Diagnosis:")
       client.elementIdElement(el.value, "//..", function (err, res) {
  if (err) {
    throw new Error("Element not found");
  }
  return res;
})
       .then(function (el) { return client.elementIdText(el.value); })
       .then(function (pad) {
        assert.equal("1) A00-Cholera", pad );
        })
      //.getOutputText("Primary Active Diagnosis:")
      //.then(function (pad) {
      //  assert.equal("1) A01.01-Typhoid meningitis", pad );
      //})
      
      //.getOutputText("ICD-10 Code")
      //.then(function (icd10code) {
      //  assert.equal("A01.01", icd10code);
      //})
      //.getOutputText("Date and Time of Diagnosis")
      //.then(function (dateantime) {
      //  assert.equal("12/30/2015 13:21", dateantime);
      //})
        }
});