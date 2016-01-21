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
  testConversionCancel: function (client) {
    // Assume we're on the conversion page
    return client
      .click("input[value='Edit Referral']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout);
  },
  commonDetailedPbsAssertions: function (client, operatingGroup, flavor, data) {
    const module = this;
    const nbsp = String.fromCharCode(160);
    return client
      .unstickPbsCard()  // this messes with .click() too much, so we'll just unstick it first
      .then(function () {
        return module.commonDetailedAssertions(client);
      })
      .getOutputText("Home Phone").should.eventually.equal("(000) 000-0000")
      .getOutputText("Primary Language")
      .then(function (language) {
        language.split("\n")[0].trim().should.equal("English");
      })
      .getCheckboxOutputBySelector("[id$=nonverb]").should.eventually.be.true
      .getCheckboxOutputBySelector("[id$=signLan").should.eventually.be.true
      .getOutputText("Billing ID").should.eventually.equal("Sample ID")
      .getOutputText("Guardianship Type")
      .then(function (guardianship) {
        guardianship.split("\n")[0].trim().should.equal("Partial Guardianship/Conservatorship");
      })
      .getOutputText("Partial Guardianship/Conservatorship")
      .then(function (partial) {
        partial.split("\n")[4].trim().should.equal("Financial; Medical");
      })
//      .getOutputText("Current Medications").should.eventually.equal("Sample Medications")  // right now this doesn't show up, should check w/ Jean first
      .getText("span#compScore").should.eventually.equal("10/12(83%)")
      .tableToJSON("table[id$=adminsId]")
      .then(function (admissions) {
        assert.equal(1, admissions.length);
        assert.equal("Admission 1 - " + data["first_name"] + " " + flavor, admissions[0]["Admission Name"]);
        assert.equal("01/12/2016 18:00", admissions[0]["Admission Date"]);
        assert.equal("Active", admissions[0]["Admission Status"], "Admission should be Active after Referral Conversion");
      })
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  // clicking on the Admission
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)

      // Admission assertions
      .unstickPbsCard()
      .getText("span#compScore").should.eventually.equal("4/4(100%)")
      .getOutputText("Admission Name").should.eventually.equal("Admission 1 - " + data["first_name"] + " " + flavor)
      .getOutputText("Network Offering").then(function (offering) {
        // Since we can't find out the network offering from the alias number alone, we'll just
        // make sure that it's part of a defined list
        ["ABI", "ARY", "IDD", "MH"].should.include(offering);
      })
      .getOutputText("State").should.eventually.equal(flavor)
      .getOutputText("Admission Date").should.eventually.equal("01/12/2016 18:00")

      .tableToJSON("table[id$=servAssignId]")
      .then(function (serviceAssignments) {
        assert.equal(1, serviceAssignments.length);
        assert.include(serviceAssignments[0]["Name"], data["alias"]);
        assert.equal("Active", serviceAssignments[0]["Service Assignment Status"], "Service Assignment should be Active after Referral Conversion");
        assert.equal("01/12/2016 18:00", serviceAssignments[0]["Start Date"]);
      })
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")  // clicking on the SA
      .waitForVisible("h3=Service Assignment")

      // Service Assignment assertions
      .unstickPbsCard()
      .getText("span#compScore")
      .then(function (score) {
        if (operatingGroup != "Care Meridian") {
          score.should.equal("4/7(57%)");
        } else {
          score.should.equal("3/7(43%)");  // since CM doesn't take Highest Level of Education into account
        }
      })
      .getOutputText("Service Assignment Status").should.eventually.equal("Active")
      .getOutputText("Start Date").should.eventually.equal("01/12/2016 18:00")
      .getText("[id$=slAlias]").should.eventually.equal(data["alias"])
      .getOutputText("Program Detail").should.eventually.not.equal("")  // Can't think of a way to get this yet
      .getOutputText("Highest Level of Education at Start of Service").should.eventually.equal("4+ Years College")
      .isExisting("a[id$=originalReferral]").should.eventually.be.true
      .click("a[id$=originalReferral]")
      .waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)

      // Original referral assertions
      .getOutputText("Referral Status").should.eventually.equal("Closed")
      .getOutputText("Close Reason").should.eventually.equal("Admitted")
      .isExisting("input[value='Edit']").should.eventually.be.false
      .isExisting("input[value='Convert']").should.eventually.be.false;
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
  commonDetailedAssertions: function (client) {
    return client
      .getOutputText("Middle Name").should.eventually.equal("MN")
      .getOutputText("Race").should.eventually.equal("Caucasian")
      .getOutputText("Ethnicity").should.eventually.equal("European")
      .getOutputText("Marital Status").should.eventually.equal("Single")
      .getOutputText("Mailing Street 1").should.eventually.equal("Sample Mailing Street 1")
      .getOutputText("Mailing Street 2").should.eventually.equal("Sample Mailing Street 2")
      .getOutputText("Mailing Zip/Postal Code").should.eventually.equal("00000")
      .getOutputText("Mailing County").should.eventually.equal("Sample Mailing County")
      .getOutputText("Email").should.eventually.equal("test_email@thementornetwork.com")
  },
  commonDetailedReferralAssertions: function (client) {
    return this.commonDetailedAssertions(client)
      .getOutputText("Phone").should.eventually.equal("(000) 000-0000")
      .getOutputText("Primary Language")
      .then(function (language) {
        language.split("\n")[0].trim().should.equal("English");  // because the Sign Language & Non Verbal checkbox are on the same row
      })
      .getCheckboxOutputBySelector("[id$=nonverb]").should.eventually.be.true
      .getCheckboxOutputBySelector("[id$=signLan]").should.eventually.be.true
      .getOutputText("Billing ID").should.eventually.equal("Sample ID")
      .getOutputText("Current Medications").should.eventually.equal("Sample Medications")
      .getOutputText("Guardianship Type")
      .then(function (guardianship) {
        guardianship.split("\n")[0].trim().should.equal("Partial Guardianship/Conservatorship");
      })
      .getOutputText("Partial Guardianship/Conservatorship Type")
      .then(function (partial) {
        partial.split("\n")[2].trim().should.equal("Financial; Medical");
      });
  },
  commonDetailedConversionAssertions: function (client) {
    return this.commonDetailedAssertions(client)
      .getOutputText("Phone").should.eventually.equal("(000) 000-0000")
      .getOutputText("Primary Language")
      .then(function (language) {
        const nbsp = String.fromCharCode(160);
        language.should.equal("English" + nbsp + nbsp + "Non-Verbal" + nbsp + "Sign Language");
      })
      .getOutputText("Guardianship Type").should.eventually.equal("Partial Guardianship/Conservatorship")
  },
  testConversionWithoutRequiredFields: function (client, data) {
    return client
      .fillInputText("First Name", "")
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout)
      .getPageMessages().should.eventually.deep.equal(["Please fill in the following fields to convert to an admission.", "First Name"])
      .click("input[value='Edit']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .then(function () {
        return this.fillInputText("First Name", data["first_name"]);
      });
  },
  closeServiceAssignment: function (client, admissionDischarged) {
    // If admissionDischarged is true, it will also discharge the admission after closing the
    // Service Assignment; otherwise, it will leave the admission be
    const answer = admissionDischarged ? "Yes" : "No";
    client = client
      .unstickPbsCard()
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  // clicking on the Admission
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)

      .unstickPbsCard()
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(1) a")  // clicking on the SA edit
      .waitForVisible("h3=Service Assignment Edit", defaultOperationTimeout)

      .unstickPbsCard()
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .fillInputText("End Date", "01/15/2016")
      .chooseSelectOption("Model", "MENTOR")
      .chooseSelectOption("End of Service Circumstances", "Relocation")
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
      .waitForVisible("[id$=SaveStatus1] input[value='Save']", defaultOperationTimeout)
      .click("[id$=SaveStatus1] input[value='Save']")
      .waitForVisible("[id$=blockAfterEsign] input[value='Yes']", defaultOperationTimeout)  // the dialog asking whether we want to discharge the admission
      .click("[id$=blockAfterEsign] input[value='" + answer + "']");
      if (admissionDischarged) {
        return client
          .waitForVisible("h3=Admission Edit", defaultOperationTimeout)
          .click("input[value='Save']")
          .waitForVisible("input[value='Add New Admission']", defaultOperationTimeout);
      } else {
        return client
          .waitForVisible("[id$=blockAfterEsign]", defaultOperationTimeout, true)  // wait for the dialog to disappear
          .waitForVisible("input[value=Edit]", defaultOperationTimeout);  // then wait for the page to load
      }
  }
};