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
  }
};