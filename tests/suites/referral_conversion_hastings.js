"use strict";

const chai = require('chai');
const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const helper = require("../helpers/referral_conversion.js");

const suiteTimeout = 5 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

testSuite("Referral Conversion for Hastings", suiteTimeout, {
  "should have correct Convert button visibility on different Referral statuses": function(client, done) {
    return helper.testConvertButtonVisibility(client, "Cambridge", "GA");
  },
  "should convert correctly with necessary fields passed to PBS, Admission and Service Assignment": function(client, done) {
    const operatingGroup = "Cambridge";
    const flavor = "GA";
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
  "should convert correctly for an existing PBS": function (client, done) {
    const operatingGroup = "Cambridge";
    const flavor = "GA";

    client = client
      // Since we can't depend on the data being there when this suite is run, we'll create a PBS
      // then close his Service Assignment. This will parallel the test case (search for an existing
      // no Active Service Assignment)
      .execUtil("convert_referral", { operatingGroup: operatingGroup, flavor: flavor })
    return helper.closeServiceAssignment(client);

  }
});