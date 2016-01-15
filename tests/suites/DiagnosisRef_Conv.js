var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
var diagn = [{"Action": "Edit", "ICD-10 Code":"A00","Code Type":"","ICD/DSM-VDescription/Axis-IV Description":"Cholera", "Date and Time of Diagnosis": "01/12/2016 18:00", "Status": "Active", "Type": ""}];
//Should cover Test Case: Add Diagnosis(Referral, New Referral, Referral to PBS Conversion) 5 and 7
testSuite("DiagnosisRef_Conv", suiteTimeout, {
  "should add a diagnosis and then convert to PBS successfully": function(client, done) {
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
      .click("input[value='Convert']")
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .tableToJSON("[id$=diagTable]")
      .then(function (icd10code) {
        assert.deepEqual(diagn, icd10code);
      })
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