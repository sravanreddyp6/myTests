"use strict";

/**
 * This suite tests the basic convert_referral util (by extension, it also tests the create_referral
 * util). It does all the assertions to make sure those utils do the right things. It does *NOT*
 * do anything more than. For more specific tests, look at the operating group specific test suites.
 */
const chai = require('chai');

const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const stateMap = require("../data/state_map.js");
const userMap = require("../data/referral_user_map.js");

const suiteTimeout = 3 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

// Some assertions/actions are similar for different operating groups, so factor them out
const commonReferralAssertions = function (client, operatingGroup, flavor, data) {
  return client
    .getOutputText("First Name").should.eventually.equal(data["first_name"])
    .getOutputText("Last Name").should.eventually.equal(flavor)
    .getOutputText("Date of Birth").should.eventually.equal("1/1/1970")
    .getOutputText("Gender").should.eventually.equal("Male")
    .getOutputText("Mailing State/Province").should.eventually.equal(stateMap()[flavor])
    .getOutputText("Anticipated Admission DateTime").should.eventually.equal("01/12/2016 18:00")
    .getOutputText("Alias").should.eventually.equal(data["alias"]);
};
const commonConversionAssertions = function (client, operatingGroup, flavor, data) {
  return client
    .getOutputText("First Name").should.eventually.equal(data["first_name"])
    .getOutputText("Last Name").should.eventually.equal(flavor)
    .getOutputText("Date of Birth").should.eventually.equal("1/1/1970")
    .getOutputText("Gender").should.eventually.equal("Male")
    .getOutputText("Mailing State/Province").should.eventually.equal(stateMap()[flavor])
    .getOutputText("Effective Date").should.eventually.equal("1/12/2016")
    .getOutputText("Start Date").should.eventually.equal("1/12/2016")
    .getOutputText("Program", "div[id$=SASection]").should.eventually.equal(data["alias"]);
};
const getCommonReferralData = function (data) {
  // This takes in the empty data object, so that we can reuse across different test cases with
  // the guarantee that it can be run in parallel (if needed later on)
  return function (client) {
    // Get some data that was filled in that we don't know before hand (e.g. first name,
    // alias)
    return client
      .getOutputTextFromInput("First Name")
      .then(function (firstName) {
        data["first_name"] = firstName;
      })
      .getOutputTextFromInput("Alias")
      .then(function (alias) {
        data["alias"] = alias;
      });
  };
};

testSuite("Basic Referral Conversion", suiteTimeout, {
  "should convert a referral successfully for Redwood": function(client, done) {
    const operatingGroup = "Redwood";
    const flavor = "AZ";
    const data = {};

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": getCommonReferralData(data),
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor, data);
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor, data);
          }
        }
      });
  },
  "should convert a referral successfully for Care Meridian": function(client, done) {
    const operatingGroup = "Care Meridian";
    const flavor = "GA";
    const data = {};

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": getCommonReferralData(data),
          "convert_referral_initial_referral": function (client) {
            const user = userMap.getUserForReferralCreation(operatingGroup, flavor);
            return commonReferralAssertions(client, operatingGroup, flavor, data)
              .getOutputText("Current Location").should.eventually.equal("Home")
              .getOutputText("Referral Source").should.eventually.equal("Sample Source")
              .getOutputText("Evaluated By").should.eventually.equal(user["first_name"] + " " + user["last_name"])
              .tableToJSON("[id$=fundingSources] table.list")
              .then(function (fundingSources) {
                assert.equal(1, fundingSources.length);
                assert.equal("Primary", fundingSources[0]["Coverage Level"]);
              });
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor, data);
          }
        }
      });
  },
  "should convert a referral successfully for NeuroRestorative": function(client, done) {
    const operatingGroup = "NeuroRestorative";
    const flavor = "MA";
    const data = {};

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": getCommonReferralData(data),
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor, data)
              .getOutputText("Referral Source").should.eventually.equal("Sample Source")
              .getOutputText("Referral Source Type").should.eventually.equal("Administrator")
              .getOutputText("How did referrer learn about us?").should.eventually.equal("Internet Search")
              .getOutputText("Referrer Name").should.eventually.equal("Sample Name")
              .getOutputText("Date of Injury").should.eventually.equal("1/13/2016")
              .getOutputText("Cause of Injury").should.eventually.equal("Fall")
              .getOutputText("Current Location Type").should.eventually.equal("Home")
              .getOutputText("Services Requested").should.eventually.equal("Community; In-Patient")
              .tableToJSON("[id$=fundingSources] table.list")
              .then(function (fundingSources) {
                assert.equal(1, fundingSources.length);
                assert.equal("Primary", fundingSources[0]["Coverage Level"]);
              })
              .tableToJSON("[id$=diagTable]")
              .then(function (diagnoses) {
                assert.equal(1, diagnoses.length);
                assert.equal("A00", diagnoses[0]["ICD-10 Code"]);
                assert.equal("01/12/2016 18:00", diagnoses[0]["Date and Time of Diagnosis"]);
              });
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor, data);
          }
        }
      });
  },
  "should convert a referral successfully for Hastings": function(client, done) {
    const operatingGroup = "Cambridge";
    const flavor = "GA";
    const data = {};

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": getCommonReferralData(data),
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor, data)
              .getOutputText("Program Category").should.eventually.equal("IDD")
              .getOutputText("Service Line").should.eventually.equal("Group Home")
              .getOutputText("Services Requested").should.eventually.equal("Host Home");
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor, data);
          }
        }
      });
  },
});
