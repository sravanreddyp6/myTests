"use strict";

const chai = require('chai');
const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const helper = require("../helpers/referral_conversion.js");

const suiteTimeout = 5 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

const operatingGroup = "Cambridge";
const flavor = "GA";

testSuite("Referral Conversion for Hastings", suiteTimeout, {
  "should have correct Convert button visibility on different Referral statuses": function(client, done) {
    return helper.testConvertButtonVisibility(client, operatingGroup, flavor);
  },
  "should convert new Admission and Service Assignment for non existing PBS": function(client, done) {
    const data = {};

    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": function (client) {
             return helper.getCommonReferralData(data)(client)
               // fill in other things that need to be tested, but not included in the basic tests
               .fillInputsWithData(require("../data/referral_data_detailed.js")(operatingGroup, flavor))
               .then(function () {
                 return helper.testConversionWithoutRequiredFields(this, data);
               });
          },
          "create_referral_after_save_referral": function (client) {
            return helper.commonDetailedReferralAssertions(client);
          },
          "convert_referral_before_conversion": function (client) {
            client = helper.commonDetailedConversionAssertions(client)
            return helper.testConversionCancel(client);
          },
          "convert_referral_after_conversion": function (client) {
            return helper.commonDetailedPbsAssertions(client, operatingGroup, flavor, data);
          },
        }
      });
  },
  // For the next test cases with existing PBS, we can't depend on the data being there when the
  // suite is run. Because of that, we'll create a PBS then close his Service Assignment. This will
  // parallel the test case (search for an existing no Active Service Assignment)
  "should convert new Admission and Service Assignment for an existing PBS": function (client, done) {
    const data = {};
    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": function (client) {
            return client
              // Since we'll create and convert another referral after this one, we need to make
              // sure that the Admissions created from those do not overlap date-wise. Because of
              // that we'll take over the dates here manually
              .fillInputText("Referral Date", "01/15/2016");
          },
          "create_referral_after_save_referral": function (client) {
            return client
              .getOutputText("Referral Number")
              .then(function (referralNumber) {
                data["referral_number"] = referralNumber;
              });
          }
        }
      })
      .then(function () {
        return helper.closeServiceAssignment(this, true);
      })
      .then(function () {
        return helper.testConvertingReferralFromExistingPbs(this, operatingGroup, flavor, data, true);
      });
  },
  "should convert new Service Assignment for an existing PBS": function (client, done) {
    const data = {};
    return client
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_after_save_referral": function (client) {
            return client
              .getOutputText("Referral Number")
              .then(function (referralNumber) {
                data["referral_number"] = referralNumber;
              });
          }
        }
      })
      .then(function () {
        return helper.closeServiceAssignment(this, false);
      })
      .then(function () {
        return helper.testConvertingReferralFromExistingPbs(this, operatingGroup, flavor, data, false);
      });
  },
});