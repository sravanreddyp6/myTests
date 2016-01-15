/**
 * This suite tests the basic convert_referral util (by extension, it also tests the create_referral
 * util). It does all the assertions to make sure those utils do the right things. It does *NOT*
 * do anything more than. For more specific tests, look at the operating group specific test suites.
 */
var chai = require('chai');

var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

const stateMap = require("../data/state_map.js");
const userMap = require("../data/referral_user_map.js");

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

// Some assertions are similar for different operating groups, so factor them out
const commonReferralAssertions = function (client, operatingGroup, flavor) {
  return client
    .getOutputText("First Name").should.eventually.include(operatingGroup)
    .getOutputText("Last Name").should.eventually.equal(flavor)
    .getOutputText("Date of Birth").should.eventually.equal("1/1/1970")
    .getOutputText("Gender").should.eventually.equal("Male")
    .getOutputText("Mailing State/Province").should.eventually.equal(stateMap()[flavor])
    .getOutputText("Anticipated Admission DateTime").should.eventually.equal("01/12/2016 18:00")
    .getOutputText("Alias").should.eventually.not.equal("");
};
const commonConversionAssertions = function (client, operatingGroup, flavor) {
  return client
    .getOutputText("First Name").should.eventually.include(operatingGroup)
    .getOutputText("Last Name").should.eventually.equal(flavor)
    .getOutputText("Date of Birth").should.eventually.equal("1/1/1970")
    .getOutputText("Gender").should.eventually.equal("Male")
    .getOutputText("Mailing State/Province").should.eventually.equal(stateMap()[flavor])
    .getOutputText("Effective Date").should.eventually.equal("1/12/2016")
    .getOutputText("Start Date").should.eventually.equal("1/12/2016");
};

testSuite("Basic Referral Conversion", suiteTimeout, {
  "should convert a referral successfully for Redwood": function(client, done) {
    var operatingGroup = "Redwood";
    var flavor = "AZ";

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor);
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor);
          }
        }
      });
  },
  "should convert a referral successfully for Care Meridian": function(client, done) {
    var operatingGroup = "Care Meridian";
    var flavor = "GA";

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "convert_referral_initial_referral": function (client) {
            var user = userMap.getUserForReferralCreation(operatingGroup, flavor);
            return commonReferralAssertions(client, operatingGroup, flavor)
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
            return commonConversionAssertions(client, operatingGroup, flavor);
          }
        }
      });
  },
  "should convert a referral successfully for NeuroRestorative": function(client, done) {
    var operatingGroup = "NeuroRestorative";
    var flavor = "MA";

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor)
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
            return commonConversionAssertions(client, operatingGroup, flavor);
          }
        }
      });
  },
  "should convert a referral successfully for Hastings": function(client, done) {
    var operatingGroup = "Cambridge";
    var flavor = "GA";

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "convert_referral_initial_referral": function (client) {
            return commonReferralAssertions(client, operatingGroup, flavor)
              .getOutputText("Program Category").should.eventually.equal("IDD")
              .getOutputText("Service Line").should.eventually.equal("Group Home")
              .getOutputText("Services Requested").should.eventually.equal("Host Home");
          },
          "convert_referral_before_conversion": function (client) {
            return commonConversionAssertions(client, operatingGroup, flavor);
          }
        }
      });
  },
});
