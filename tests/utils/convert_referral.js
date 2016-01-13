/**
 * This utility is responsible for converting a referral.
 *
 * Options:
 * - operatingGroup: either Care Meridian, NeuroRestorative, Redwood or Cambridge
 * - flavor: the flavor within the operating group - usually this is the abbreviation of the state
 * name.
 *
 * Hooks available:
 * - create_referral_initial_referral: is called when the referral creation page is first loaded.
 * - All the hooks for create_referral util is also available here.
 */


var assert = require('chai').assert;
var stripJsonComments = require("strip-json-comments");
var fs = require('fs');
var _ = require('lodash');
var url = require('url');

const userMap = require("../data/referral_user_map.js");

var defaultOperationTimeout = 3 * 60 * 1000;

module.exports = function (client, opts) {
  if (!opts.operatingGroup) {
    throw new Error("Operating group is required to create a referral!");
  }
  if (!opts.flavor) {
    switch (opts.operatingGroup) {
      case "Care Meridian":
        flavor = "AZ";
      case "NeuroRestorative":
        flavor = "MA";
      case "Redwood":
        flavor = "AZ";
      case "Cambridge":
        flavor = "GA";
      default:
        throw new Error("Operating group " + opts.operatingGroup + " is not valid!");
    }
  }
  var referralUrl;
  client = client
    .execUtil("create_referral", {
      operatingGroup: opts.operatingGroup,
      flavor: opts.flavor
    })
    .url()
    .then(function (currentUrl) {
      referralUrl = currentUrl.value;
    })
    .logInAs(userMap.getUserForReferralConversion(opts.operatingGroup, opts.flavor))
    .then(function () {
      console.log("After logInAs, referralUrl: " + referralUrl);
      return this.url(referralUrl);
    })
    .callHook("convert_referral_initial_referral")
    .click("input[value='Convert']");
  if (opts.operatingGroup == "Care Meridian") {
    client = client
      .waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout)
      .click("input[value='Save and Continue']")
      .waitForActionStatusDisappearance("convertStatus2", defaultOperationTimeout);
  }

  return client.waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
    .click("input[value='Confirm Conversion']")
    .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
}