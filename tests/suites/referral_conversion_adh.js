"use strict";

const chai = require('chai');
const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const helper = require("../helpers/referral_conversion.js");
const userMap = require("../data/referral_user_map.js");

const suiteTimeout = 5 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

const operatingGroup = "Adult Day Health";
const flavor = "MA";

testSuite("Referral Conversion for " + operatingGroup, suiteTimeout, {
  "should convert new Admission and Service Assignment for non existing PBS": function(client, done) {
    const data = {};
    var user = userMap.getUserForReferralCreation(operatingGroup, flavor);
    return client
      .then(function () { console.log('Starting ADH Process'); })
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": function (client) {
             return helper.getCommonReferralData(data)(client)
               // fill in other things that need to be tested, but not included in the basic tests
               .then(function () { console.log('Starting filling in inputs'); })
               .fillInputsWithData(require("../data/referral_data_detailed.js")(operatingGroup, flavor));
          },          
          "create_referral_after_save_referral": function (client) {
            return helper.commonDetailedReferralAssertions(client, operatingGroup, flavor)
                         .then(function () { console.log('e-signing'); })
                         .click("input[id='confirmId']")
                        .waitForVisible("input[id='esignId']", defaultOperationTimeout)
                        .click("input[id='esignId']") 
                        .waitForVisible("input[id$='esignButton']", defaultOperationTimeout)
                        .fillInputText("Username", user["username"])
                        .fillInputText("Password", user["password"])                       
                        .click("input[id$='esignButton']")                        
                        .pause(10000)
                        .alertAccept()
                        .then(function () { console.log('finished commonDetailedReferralAssertions'); })
                         
          },
          "convert_referral_initial_referral": function (client) {
            return helper.testConversionWithoutRequiredFields(client, operatingGroup, flavor, data)
                        .then(function () { console.log('testConversionWithoutRequiredFields'); });
          },
          "convert_referral_before_conversion": function (client) {
            client = helper.commonDetailedConversionAssertions(client).then(function () { console.log('finished commonDetailedConversionAssertions'); });
            return helper.testConversionCancel(client, operatingGroup, flavor).then(function () { console.log('testConversionCancel'); });
          },
          "convert_referral_after_conversion": function (client) {
            return helper.commonDetailedPbsAssertions(client, operatingGroup, flavor, data).then(function () { console.log('commonDetailedPbsAssertions'); });
          },
        }
      }).then(function () { console.log('finished all'); });
  },

});