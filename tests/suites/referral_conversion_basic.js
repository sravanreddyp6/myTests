var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

/**
 * This suite tests the basic convert_referral util (by extension, it also tests the create_referral
 * util). It does all the assertions to make sure those utils do the right things.
 */
testSuite("Basic Referral Conversion", suiteTimeout, {
  "should convert a referral successfully for Redwood": function(client, done) {
    return client
      .execUtil("convert_referral", {
        operatingGroup: "Redwood",
        flavor: "AZ",
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return client
              .getOutputText("First Name")
              .then(function (firstName) {
                assert.include(firstName, "Redwood");
              })
              .getOutputText("Last Name")
              .then(function (lastName) {
                assert.equal("AZ", lastName);
              })
              .getOutputText("Date of Birth")
              .then(function (dob) {
                assert.equal("1/1/1970", dob);
              })
              .getOutputText("Gender")
              .then(function (gender) {
                assert.equal("Male", gender);
              })
              .getOutputText("Mailing State/Province")
              .then(function (state) {
                assert.equal("Arizona", state);
              })
              .getOutputText("Anticipated Admission DateTime")
              .then(function (admissionDateTime) {
                assert.equal("01/12/2016 18:00", admissionDateTime);
              })
          }
        }
      })
  },
  "should convert a referral successfully for Care Meridian": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "Care Meridian", flavor: "GA" })
  },
  "should convert a referral successfully for NeuroRestorative": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "NeuroRestorative", flavor: "MA" })
  },
  "should convert a referral successfully for Hastings": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "Cambridge", flavor: "GA" })
  },
});
