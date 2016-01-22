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
    return helper.testConvertButtonVisibility(client, "Cambridge", "GA");
  },
  "should convert correctly with necessary fields passed to PBS, Admission and Service Assignment": function(client, done) {
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
  "should convert new Admission and Service Assignment for an existing PBS": function (client, done) {
    const data = {};
    client = client
      // Since we can't depend on the data being there when this suite is run, we'll create a PBS
      // then close his Service Assignment. This will parallel the test case (search for an existing
      // no Active Service Assignment)
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
      });
    return helper.closeServiceAssignment(client, true)
      .click("a=ESD Home")
      .waitForVisible("a=Search Referrals", defaultOperationTimeout)
      .click("a=Search Referrals")
      .waitForVisible("input[id$=rid]", defaultOperationTimeout)
      .then(function () {
        return this.fillInputText("Referral Number", data["referral_number"]);
      })
      .click("[id$=PBRSection] input[value=Search]")
      .waitForVisible("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a", defaultOperationTimeout)
      .click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")  // New Referral button
      .waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        bypassPbrCreation: true,
        hooks: {
          "create_referral_before_save_referral": function (client) {
            return client
              // Again, this is here to make sure the Admission dates don't overlap
              .fillInputText("Anticipated Admission DateTime", "01/16/2016 18:00");
          }
        }
      })
      .unstickPbsCard()
      .tableToJSON("table[id$=adminsId]")
      .then(function (admissions) {
        assert.equal(2, admissions.length);
        assert.equal("Discharged", admissions[0]["Admission Status"]);
        assert.equal("Active", admissions[1]["Admission Status"]);
      })
      .click("table[id$=adminsId] tbody tr:nth-child(2) td:nth-child(2) a")  // clicking on the active Admission
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)

      .unstickPbsCard()
      .tableToJSON("table[id$=servAssignId]")
      .then(function (serviceAssignments) {
        assert.equal(1, serviceAssignments.length);
        assert.equal("Active", serviceAssignments[0]["Service Assignment Status"]);
      })
  },
  "should convert new Service Assignment for an existing PBS": function (client, done) {
    const data = {};
    client = client
      // Since we can't depend on the data being there when this suite is run, we'll create a PBS
      // then close his Service Assignment. This will parallel the test case (search for an existing
      // no Active Service Assignment)
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
      });
    return helper.closeServiceAssignment(client, false)
      .click("a=ESD Home")
      .waitForVisible("a=Search Referrals", defaultOperationTimeout)
      .click("a=Search Referrals")
      .waitForVisible("input[id$=rid]", defaultOperationTimeout)
      .then(function () {
        return this.fillInputText("Referral Number", data["referral_number"]);
      })
      .click("[id$=PBRSection] input[value=Search]")
      .waitForVisible("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a", defaultOperationTimeout)
      .click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")  // New Referral button
      .waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)
      .execUtil("convert_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        bypassPbrCreation: true
      })
      .unstickPbsCard()
      .tableToJSON("table[id$=adminsId]")
      .then(function (admissions) {
        assert.equal(1, admissions.length);
        assert.equal("Active", admissions[0]["Admission Status"]);
      })
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  // clicking on the active Admission
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)

      .unstickPbsCard()
      .tableToJSON("table[id$=servAssignId]")
      .then(function (serviceAssignments) {
        assert.equal(2, serviceAssignments.length);
        assert.equal("Active", serviceAssignments[0]["Service Assignment Status"]);
        assert.equal("Inactive", serviceAssignments[1]["Service Assignment Status"]);
      })
  },
});