"use strict";

const chai = require('chai');
const assert = chai.assert;

const userMap = require("../data/referral_user_map.js");

const defaultOperationTimeout = 30 * 1000;

/**
 * The referral conversion suites share many similar actions, so we refactor them here for
 * code reuse.
 */

module.exports = {
  testConvertButtonVisibility: function (client, operatingGroup, flavor) {
    // The Convert button only shows up in referrals with certain statuses. We check for that here.
    // This assumes that the starting page is the Referral Edit page
    const saveButtonSelector = "input[value='Save Referral']";
    const convertButtonSelector = "input[value='Convert']";
    const editButtonSelector = "input[value='Edit']";
    const attachButtonSelector = "input[value='Attach File']";

    let initialUrl;

    client = client
      .execUtil("create_referral", {
        operatingGroup: operatingGroup,
        flavor: flavor,
        hooks: {
          "create_referral_before_save_referral": function (client) {
            return client.chooseSelectOption("Referral Status", "New");
          }
        }
      })
      .url()
      .then(function (currentUrl) {
        initialUrl = currentUrl.value;
      })
      .logInAs(userMap.getUserForReferralConversion(operatingGroup, flavor))
      .then(function () {
        return this.url(initialUrl);
      })
      .isVisible(convertButtonSelector).should.eventually.equal(true, "Convert button should be visible for New Referral")
      .click(editButtonSelector)
      .waitForVisible(saveButtonSelector, defaultOperationTimeout)
      .chooseSelectOption("Referral Status", "Active")
      .click(saveButtonSelector)
      .waitForVisible(attachButtonSelector, defaultOperationTimeout)
      .isVisible(convertButtonSelector).should.eventually.equal(true, "Convert button should be visible for Active Referral")
      .click(editButtonSelector)
      .waitForVisible(saveButtonSelector, defaultOperationTimeout)
      .chooseSelectOption("Referral Status", "On Hold")
      .waitForVisible("select[id$=holdReason]", defaultOperationTimeout)
      .chooseSelectOption("Hold Reason", "Wait List")
      .fillInputText("Review On", "1/13/2016")
      .click(saveButtonSelector)
      .waitForVisible(attachButtonSelector, defaultOperationTimeout)
      .isVisible(convertButtonSelector).should.eventually.equal(true, "Convert button should be visible for On Hold Referral")
      .click(editButtonSelector)
      .waitForVisible(saveButtonSelector, defaultOperationTimeout)
      .chooseSelectOption("Referral Status", "Closed")
      .waitForVisible("select[id$=closeReason]", defaultOperationTimeout)
      .chooseSelectOption("Close Reason", "Other")
      .click(saveButtonSelector);
    if (operatingGroup == "Care Meridian") {
      client = client.alertAccept();  // it will ask whether we want to close the open Service Locations
    }
    return client.waitForVisible(attachButtonSelector, defaultOperationTimeout)
      .isVisible(convertButtonSelector).should.eventually.equal(false, "Convert button should not be visible for Closed Referral");
  },
  testPbs: function (client, operatingGroup, flavor, data) {
    return client
      .isVisible("img.unstickPbs")  // this messes with .click() too much, so we'll just unstick it first
      .then(function (unstickNeeded) {
        if (unstickNeeded) {
          return this.click("img.unstickPbs");
        }
      })
      .tableToJSON("table[id$=adminsId]")
      .then(function (admissions) {
        assert.equal(1, admissions.length);
        assert.equal("Admission 1 - " + data["first_name"] + " " + flavor, admissions[0]["Admission Name"]);
        assert.equal("01/12/2016 18:00", admissions[0]["Admission Date"]);
        assert.equal("Active", admissions[0]["Admission Status"], "Admission should be Active after Referral Conversion");
      })
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  // clicking on the Admission
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
      .tableToJSON("table[id$=servAssignId]")
      .then(function (serviceAssignments) {
        assert.equal(1, serviceAssignments.length);
        assert.include(serviceAssignments[0]["Name"], data["alias"]);
        assert.equal("Active", serviceAssignments[0]["Service Assignment Status"], "Service Assignment should be Active after Referral Conversion");
        assert.equal("01/12/2016 18:00", serviceAssignments[0]["Start Date"]);
      });
  },
  getCommonReferralData: function (data) {
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
  },
};