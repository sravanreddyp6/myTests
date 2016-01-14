/**
 * This utility is responsible for creating a referral.
 *
 * Options:
 * - operatingGroup: either Care Meridian, NeuroRestorative, Redwood or Cambridge
 * - flavor: the flavor within the operating group - usually this is the abbreviation of the state
 * name.
 * - bypassPbrCreation: bypass the PBR creation process. This assumes that you are on a referral
 * Edit/Create page before you call this util function. By default, this is false.
 * - bypassCreationUser: bypass logging in as the creation user. This will run the util as
 * the current user in context. By default, this is false.
 *
 * Hooks available:
 * - create_referral_initial_pbr: is called when the PBR creation page is first loaded.
 * - create_referral_before_pbr_submit: is called before the Create PBR button is clicked on the
 * referral page.
 * - create_referral_initial_referral: is called after the PBR has been created, but before any
 * referral info has been filled in.
 * - create_referral_before_save_referral: is called before the Save button is clicked on the
 * referral page.
 * - create_referral_after_save_referral: is called after the save button is clicked on the
 * referral page
 *
 */

const assert = require('chai').assert;
const stripJsonComments = require("strip-json-comments");
const fs = require('fs');
const _ = require('lodash');
const url = require('url');

const userMap = require("../data/referral_user_map.js");

const defaultOperationTimeout = 3 * 60 * 1000;
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
  if (opts.bypassPbrCreation === undefined) {
    opts.bypassPbrCreation = false;
  }
  if (opts.bypassCreationUser === undefined) {
    opts.bypassCreationUser = false;
  }
  var user = userMap.getUserForReferralCreation(opts.operatingGroup, opts.flavor);
  var initialUrl;
  if (opts.bypassPbrCreation && !opts.bypassCreationUser) {
    client = client
      .url()
      .then(function (currentUrl) {
        initialUrl = currentUrl.value;
      })
      .logInAs(user)
      .then(function () {
        return this.url(initialUrl);
      });
  }
  if (!opts.bypassPbrCreation) {
    if (!opts.bypassCreationUser) {
      client = client.logInAs(user);
    }
    client = client
      .url()
      .then(function (currentUrl) {
        if (currentUrl.value.indexOf("/apex/Home") !== -1) {
          return;
        }
        return url.resolve(currentUrl.value, "/apex/Home").then(client.url);
      })
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .callHook("create_referral_initial_pbr")
      .fillInputsWithData(require("../data/pbr_data_basic.js")(opts.operatingGroup, opts.flavor))
      .callHook("create_referral_before_pbr_submit")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
  }

  client = client
    .callHook("create_referral_initial_referral")
    .click("a[id$=originlookup]")
    .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
    .setValue("input[id$=originstate]", opts.operatingGroup == "Care Meridian" ? "AZ" : opts.flavor)
    .click("span[id$=searchDialog2] input[value='Search!']")
    .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
    .element("span[id$=searchDialog2] a")
    .then(function (el) {
      return this.elementIdClick(el.value.ELEMENT);
    })
    .fillInputsWithData(require("../data/referral_data_basic.js")(opts.operatingGroup, opts.flavor));
    if (opts.operatingGroup == "Care Meridian") {
      client = client
        .selectLookup("Evaluated By")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", user["first_name"] + " " + user["last_name"])
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#TMN_User__c_body tr.dataRow th a")
        .switchToNextWindow()
        .click("input[value='Add Funding Source']")
        .waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
        .chooseSelectOption("Coverage Level", "Primary")
        .click("span[id$=FundingSourceModal] input[value='Save']")
        .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
        .click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "AZ")
        .click("span[id$=searchDialog] input[value='Search!']")
        .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
        .element("span[id$=searchDialog] a")
        .then(function (el) {
          return this.elementIdClick(el.value.ELEMENT);
        })
        .chooseSelectOption("Rank", "Primary")
        .chooseSelectOption("Status", "New")
        .click("span[id$=ReferralLocationModal] input[value='Save']")
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout);
    }
    if (opts.operatingGroup == "NeuroRestorative") {
      client = client
        .click("input[value='Add Funding Source']")
        .waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
        .chooseSelectOption("Coverage Level", "Primary")
        .chooseSelectOption("Payer Type", "Auto")
        .click("span[id$=FundingSourceModal] input[value='Save']")
        .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)

        .click("input[value='Add Diagnosis']")
        .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
        .click("[id$=diagnosisEntry] .lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "A00")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#ICD__c_body tr.dataRow th a")
        .switchToNextWindow()

        .fillInputText("Date and Time of Diagnosis", "01/12/2016 18:00")
        .click("span[id$=diagnosisModal] input[value='Save']")
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)

        .selectLookup("Evaluated By (Internal)")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", user["first_name"] + " " + user["last_name"])
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#TMN_User__c_body tr.dataRow th a")
        .switchToNextWindow()
    }

    return client
      .callHook("create_referral_before_save_referral")
      .click("input[value='Save Referral']")
      .waitForVisible("input[value=Edit]", defaultOperationTimeout)
      .callHook("create_referral_after_save_referral")
};