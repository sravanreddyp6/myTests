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
  testConversionCancel: function (client, operatingGroup, flavor) {
    // Assume we're on the conversion page
    client = client
      .click("input[value='Edit Referral']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']");
    if (operatingGroup == "Care Meridian") {
      client = client
        .waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout)
        .click("input[value='Save and Continue']")
        .waitForActionStatusDisappearance("convertStatus2", defaultOperationTimeout);
    }
    return client
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout);
  },
  commonDetailedPbsAssertions: function (client, operatingGroup, flavor, data) {
    const module = this;
    const nbsp = String.fromCharCode(160);

    var pbsScore;
    var admitScore;
    var saScore;

    if (operatingGroup == "Care Meridian") {
      pbsScore = "10/13(77%)";
      saScore = "3/4(75%)";
      admitScore = "4/4(100%)";
    } else if (operatingGroup == "NeuroRestorative") {
      pbsScore = "11/13(85%)";
      saScore = "4/7(57%)";
      admitScore = "4/4(100%)";
    } else if (operatingGroup == "Redwood") {
      pbsScore = "10/12(83%)";
      saScore = "4/6(67%)";
      admitScore = "4/4(100%)";
    } else {
      pbsScore = "10/12(83%)";
      saScore = "4/8(50%)";
      admitScore = "4/5(80%)";
    }
    client = client
      .unstickPbsCard()  // this messes with .click() too much, so we'll just unstick it first
      .then(function () {
        return module.commonDetailedAssertions(this);
      })
      .getOutputText("Home Phone").should.eventually.equal("(000) 000-0000")
      .getOutputText("Primary Language")
      .then(function (language) {
        language.split("\n")[0].trim().should.equal("English");
      })
      .getCheckboxOutputBySelector("[id$=nonverb]").should.eventually.be.true
      .getCheckboxOutputBySelector("[id$=signLan").should.eventually.be.true
    if (operatingGroup != "Care Meridian" && (operatingGroup != "Redwood" || flavor == "CAFSS")) {
      client = client.getOutputText("Billing ID").should.eventually.equal("Sample ID")
    }
    return client
      .getOutputText("Guardianship Type")
      .then(function (guardianship) {
        guardianship.split("\n")[0].trim().should.equal("Partial Guardianship/Conservatorship");
      })
      .getOutputText("Partial Guardianship/Conservatorship")
      .then(function (partial) {
        partial.split("\n")[4].trim().should.equal("Financial; Medical");
      })
//      .getOutputText("Current Medications").should.eventually.equal("Sample Medications")  // right now this doesn't show up, should check w/ Jean first
      .getText("span#compScore").should.eventually.equal(pbsScore, "Score should be calculated correctly")
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
      .getText("span#compScore").should.eventually.equal(admitScore)
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
      .getText("span#compScore").should.eventually.equal(saScore, "SA score should be calculated correctly")
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
      .getOutputText("Email").should.eventually.equal("test_email@thementornetwork.com");
  },
  commonDetailedReferralAssertions: function (client, operatingGroup, flavor) {
    client = this.commonDetailedAssertions(client)
      .getOutputText("Phone", "[id$=ContactSection]").should.eventually.equal("(000) 000-0000")
      .getOutputText("Primary Language")
      .then(function (language) {
        language.split("\n")[0].trim().should.equal("English");  // because the Sign Language & Non Verbal checkbox are on the same row
      })
      .getCheckboxOutputBySelector("[id$=nonverb]").should.eventually.be.true
      .getCheckboxOutputBySelector("[id$=signLan]").should.eventually.be.true
      .getOutputText("Guardianship Type")
      .then(function (guardianship) {
        guardianship.split("\n")[0].trim().should.equal("Partial Guardianship/Conservatorship");
      })
      .getOutputText("Partial Guardianship/Conservatorship Type")
      .then(function (partial) {
        partial.split("\n")[2].trim().should.equal("Financial; Medical");
      });
    if (operatingGroup == "Cambridge" || (operatingGroup == "Redwood" && (flavor == "CAFSS" || flavor == "IL"))) {
      client = client.getOutputText("Current Medications").should.eventually.equal("Sample Medications");
    }
    if (operatingGroup != "Care Meridian" && (operatingGroup != "Redwood" || flavor == "CAFSS")) {
      client = client.getOutputText("Billing ID").should.eventually.equal("Sample ID");
    }
    return client;
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
  testConversionWithoutRequiredFields: function (client, operatingGroup, flavor, data) {
    // Assuming we're on the referral view page

    // Neuro Referral actually doesn't even let us save a referral without a first name, so we use
    // a different field required for conversion instead
    const fieldToRemove = (operatingGroup == "NeuroRestorative" ? "Anticipated Admission DateTime" : "First Name");
    const fieldToAssert = (operatingGroup == "NeuroRestorative" ? "Anticipated Admission Date Time" : "First Name");
    var fieldValue;
    client = client
      .click("input[value='Edit']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .getOutputTextFromInput(fieldToRemove)
      .then(function (value) {
        fieldValue = value;
      })
      .fillInputText(fieldToRemove, "")
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout);
    return client
      .getPageMessages().should.eventually.deep.equal(["Please fill in the following fields to convert to an admission.", fieldToAssert])
      .click("input[value='Edit']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .then(function () {
        return this.fillInputText(fieldToRemove, fieldValue);
      })
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
  },
  closeServiceAssignment: function (client, operatingGroup, flavor, admissionDischarged) {
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
      .fillInputText("End Date", "01/15/2016");
    if (operatingGroup != "Care Meridian" && operatingGroup != "Cambridge") {
        client = client.chooseSelectOption("End of Service Circumstances", "No longer in need of services");  
       
    }
    if (operatingGroup == "Cambridge") {
      client = client.chooseSelectOption("Model", "MENTOR")
      .chooseSelectOption("Was Child Service or Permanency Goal met at End of Service?", "Yes")
      //.waitForVisible("label[value='End of Service Circumstances']", defaultOperationTimeout)              
      .chooseSelectOption("Educational Involvement at Start of Service", "Unknown")
      .chooseSelectOption("Educational Involvement at End of Service", "Unknown")
      .chooseSelectOption("Highest Level of Education at End of Service", "Grade 12") 
      .chooseSelectOption("Highest Level of Education at Start of Service", "Grade 12")
      .chooseSelectOption("Child Service Goal at Start of Service", "GED")
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No");
    }
    if (operatingGroup == "NeuroRestorative") {
      client = client
        .chooseSelectOption("Rancho Score at Start of Service", "10")
        .chooseSelectOption("Was this a transfer from another Service Assignment?", "No")
        .chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "No");
    }
    client = client
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
      .waitForVisible("[id$=SaveStatus1] input[value='Save']", defaultOperationTimeout)
      .click("[id$=SaveStatus1] input[value='Save']")
      .waitForVisible("[id$=blockAfterEsign] input[value='Yes']", defaultOperationTimeout)  // the dialog asking whether we want to discharge the admission
      .click("[id$=blockAfterEsign] input[value='" + answer + "']");
      if (admissionDischarged) {
        client = client
          .waitForVisible("h3=Admission Edit", defaultOperationTimeout);
        if (operatingGroup == "Care Meridian" || operatingGroup == "NeuroRestorative") {
          client = client.chooseSelectOption("Discharged To", "Home");
        }
        if (operatingGroup == "Care Meridian") {
          client = client
            .chooseSelectOption("Planned Discharge", "Yes")
            .chooseSelectOption("Discharged Reason", "Goals Achieved");
        }
        if (operatingGroup == "Cambridge") {
          client = client
           .chooseSelectOption("Admitted From (ROLES Scale at Admission)", "Hotel/Motel")
           .chooseSelectOption("Discharged To (ROLES Scale at Discharge)", "Hotel/Motel")
        }        
        
        return client
          .click("input[value='Save']")
          .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout);
      } else {
        return client
          .waitForVisible("[id$=blockAfterEsign]", defaultOperationTimeout, true)  // wait for the dialog to disappear
          .waitForVisible("input[value=Edit]", defaultOperationTimeout);  // then wait for the page to load
      }
  },
  testConvertingReferralFromExistingPbs: function (client, operatingGroup, flavor, data, admissionDischarged) {
    // If admissionDischarged is true, we will discharge the admission after closing the Service
    // Assignment; otherwise we'll leave the admission be
    if (operatingGroup != "Redwood") {
      // Apparently the intaker user for RW can't create Referral from an existing PBS, so we'll
      // just use the conversion user instead
      client = client.logInAs(userMap.getUserForReferralCreation(operatingGroup, flavor));
    } else {
      client = client.logInAs(userMap.getUserForReferralConversion(operatingGroup, flavor));
    }
    return client
      .waitForVisible("a=Search Referrals", defaultOperationTimeout)
      .click("a=Search Referrals")
      .waitForVisible("input[id$=rid]", defaultOperationTimeout)
      .then(function () {
        // We search using referral number instead of the PBS name because the referral search
        // uses Soundex to find similar-sounding names instead of exact search, while also limiting
        // the number of results to 50. This means that inevitably as the list of PBS grows, we
        // won't be able to find the PBS even though we put their exact name in the search
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
        bypassCreationUser: true,  // since we already logged in above
        hooks: {
          "create_referral_before_save_referral": function (client) {
            if (admissionDischarged) {
              return client
                // This is here to make sure the Admission dates don't overlap
                .fillInputText("Anticipated Admission DateTime", "01/16/2016 18:00");
            } else {
              return client;
            }
          }
        }
      })
      .unstickPbsCard()
      .tableToJSON("table[id$=adminsId]")
      .then(function (admissions) {
        let activeAdmission;
        if (admissionDischarged) {
          assert.equal(2, admissions.length, "There should be 2 Admissions, 1 discharged and 1 active");
          assert.equal("Discharged", admissions[0]["Admission Status"]);
          assert.equal("Active", admissions[1]["Admission Status"]);
          activeAdmission = 2;
        } else {
          assert.equal(1, admissions.length, "There should be only 1 Admission");
          assert.equal("Active", admissions[0]["Admission Status"]);
          activeAdmission = 1;
        }
        return this.click("table[id$=adminsId] tbody tr:nth-child(" + activeAdmission + ") td:nth-child(2) a")  // clicking on the active Admission
      })
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)

      .unstickPbsCard()
      .tableToJSON("table[id$=servAssignId]")
      .then(function (serviceAssignments) {
        if (admissionDischarged) {
          assert.equal(1, serviceAssignments.length, "There should be only 1 Service Assignment");
          assert.equal("Active", serviceAssignments[0]["Service Assignment Status"], "The Service Assignment should be Active");
        } else {
          assert.equal(2, serviceAssignments.length, "There should be 2 Service Assignments, 1 active and 1 inactive");
          assert.equal("Active", serviceAssignments[0]["Service Assignment Status"]);
          assert.equal("Inactive", serviceAssignments[1]["Service Assignment Status"]);
        }
      });
  }
};