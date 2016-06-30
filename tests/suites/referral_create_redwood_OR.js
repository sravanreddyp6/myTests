"use strict";

const chai = require('chai');
const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const helper = require("../helpers/referral_conversion.js");
const userMap = require("../data/referral_user_map.js");

const suiteTimeout = 5 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

const operatingGroup = "Redwood";
const flavor = "OR";

testSuite("Referral Conversion for " + operatingGroup, suiteTimeout, {
  "should convert new Admission and Service Assignment for non existing PBS": function(client, done) {
    const data = {};
    var user = userMap.getUserForReferralCreation(operatingGroup, flavor);
    return client
      .then(function () { console.log('Starting RW create Process'); })
      .execUtil("create_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": function (client) {
             return helper.getCommonReferralData(data)(client)
               // fill in other things that need to be tested, but not included in the basic tests
              .getSelectOptions("Referral Source Type")
              .then(function(rct) {
                assert.deepEqual([
                  "", "Attorney", "Brokerage", "County", "Family", "Hospital Case Manager", "Independent Case Manager", "Internal",
                  "Payor Case Manager", "Physician", "Rehab/Hospital", "School", "Self",
                  "Social Worker", "Unknown", "Other"], rct);
              })  
               .chooseSelectOption("Referral Source Type", "Brokerage") 
               .getSelectOptions("Brokerage")
                  .then(function(broke) {
                    assert.deepEqual([
                      "", "Community Pathways, Inc.", "Creative Supports, Inc.", "Eastern Oregon Support Services Brokerage", "Full Access", "Full Access- High Desert",
                      "Inclusion, Inc.", "Independence Northwest", "Integrated Services Network", "Mentor Oregon Broekrage- Mid Valley", "Mentor Oregon Brokerage- Metro",
                      "Resource Connections of Oregon", "Self Determination Resources, Inc.", "Southern Oregon Regional Brokerage","UCP Connections"], broke);
                  })
               .click("input[value='Save Referral']")
               .pause(10000)
               .getPageMessages().should.eventually.deep.equal(["Brokerage: Brokerage - Please Enter a Value"]) 
               .chooseSelectOption("Referral Source Type", "County") 
               .getSelectOptions("County")
                  .then(function(County) {
                    assert.deepEqual([
                      "", "Baker","Benton","Clackamas","Clatsop","Columbia","Coos","Crook",
                      "Curry","Deschutes","Douglas","Gilliam","Grant",
                      "Harney","Hood River","Jackson","Jefferson","Josephine",
                      "Klamath","Lake","Lane","Lincoln","Linn","Malheaur","Marion","Morrow","Multnomah","Polk","Sherman","Tillamook","Umatilla","Union",
                      "Wallowa","Warm Springs","Wasco","Washington","Wheeler","Yamhill"], County);
                  })  
               .click("input[value='Save Referral']")
               .pause(10000)
               .getPageMessages().should.eventually.deep.equal(["County: County - Please Enter a Value"])                   
               .chooseSelectOption("Referral Source Type", "")                     
               .then(function () { console.log('Starting filling in inputs'); })
               .fillInputsWithData(require("../data/referral_data_detailed.js")(operatingGroup, flavor));
               
          },          
        }
      }).then(function () { console.log('finished all'); });
  },

});