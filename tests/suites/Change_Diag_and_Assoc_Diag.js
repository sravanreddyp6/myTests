var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
//Should cover Test Case: Change Diagnosis Info/Status/Ranking 1-5
testSuite("Change_Diag_and_Assoc_Diag", suiteTimeout, {
  "should associate a diagnosis with a PBS successfully": function(client, done) {
  var user = users["HS_AL_Auburn_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
  var people = "people"
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
      //.element("#resultsFrame")
      //.then(function (frame) { return frame.value; })
      //.then(client.frame)
      //.click("tr.dataRow th a:first-child")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
	  .click("table[id$=diagTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      
      .click("a[id$=diagnosisEntry_icd_lkwgt]")
      //.selectLookup("ICD-10 Code")
      .switchToNextWindow()
      .element("#searchFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .setValue("input#lksrch", "02")
      .click("input[value*='Go']")
      .frameParent()
      .waitForExist("#resultsFrame", defaultOperationTimeout)
      .element("#resultsFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .click("tr.dataRow th a:first-child")
      .switchToNextWindow()
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Date and Time of Diagnosis", "12/31/2015 15:00")
      .selectByValue("select[id$=diagnosisEntry_status]", "Active")
      .click("span[id$=diagnosisModal] input[value='Save']")
      //.waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
      .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
      //.waitForExist("span[id$=AdddiagStatus] img[class=dialogLoadingSpinner]", 2000, true)
      .refresh()
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .click("input[value='Add Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      .getSelectOptionsBySelector("[id$=diagnosisEntry_type]")
	  .then(function(digtype) {
        assert.deepEqual([
          "", "Admission", "Discharge", "Onset", "Update"  ], digtype);
      })
      
      .click("a[id$=diagnosisEntry_icd_lkwgt]")
      //.selectLookup("ICD-10 Code")
      .switchToNextWindow()
      .element("#searchFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .setValue("input#lksrch", "01")
      .click("input[value*='Go']")
      .frameParent()
      .waitForExist("#resultsFrame", defaultOperationTimeout)
      .element("#resultsFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .click("tr.dataRow th a:first-child")
      .switchToNextWindow()
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Date and Time of Diagnosis", "12/30/2015 12:00")
      .selectByValue("select[id$=diagnosisEntry_status]", "Active")
      .selectByValue("select[id$=diagnosisEntry_type]", "Admission")
      .click("span[id$=diagnosisModal] input[value='Save']")
	  .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	  .waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
	  .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
	  .refresh()
      .click("a*=Admission 1 - ")
	  .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
	  .refresh()
	  .scroll("input[value='New Standard Service']", 0, -500)
      .click("a*=C. GA - SA1 - 011030 -")
	  .waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
	  .scroll("input[value='Associate Diagnosis']", 0, -500)
	  .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.01 - Typhoid meningitis", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .selectCheckbox("ABI Diagnosis")
      .fillInputText("Injury Date", "12/25/2015")
      .selectCheckbox("Billable")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      .click("a=Edit")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.02 - Typhoid fever with heart involvement", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Secondary")
      .selectCheckbox("Billable")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.01 - Typhoid meningitis", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .selectCheckbox("ABI Diagnosis")
      .fillInputText("Injury Date", "12/25/2015")
      .selectCheckbox("Billable")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      .click("a*=View Admission")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .click("a=Edit")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      .selectByValue("select[id$=diagnosisEntry_status]", "Void")
      .selectByValue("select[id$=diagnosisEntry_type]", "Admission")
	  .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .click("span[id$=diagnosisModal] input[value='Save']")
	  isExisting("li*=You cannot inactivate this Diagnosis as it is associated with an Active Service Assignment.")
      
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