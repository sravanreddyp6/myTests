var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 100 * 1000;

testSuite("Service Location Create", suiteTimeout, {
  "should edit a service location": function(client, done) {
    return client
      .logInAs(users["RW_MN_L3"])
      .click("a=Manage Service Locations")
        .click(".lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "11223")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#Alias__c_body tr.dataRow th a")
        .switchToNextWindow()
      .waitForExist(".editSL", defaultOperationTimeout) 
      .click(".editSL")  
      .fillInputText("Program Code", "newcode")
      .fillInputText("Location Nickname", "newcode")
      .fillInputText("Street", "newcode")
      .fillInputText("City", "newcode")
      .fillInputText("State", "AZ")
      .fillInputText("Zip", "newcode")
      .chooseSelectOption("Physical Location", "Clinic")
      .chooseSelectOption("TMN Scope", "Non-Residential")
      /*
      .getSelectOptions('Service Type')
      .then(function(states) {
        assert.deepEqual([
          "", "ADOPT - Adoption Services", "BSS - Behavior Support Services", "CI - Crisis Intervention", "CM - Case Management", "CSS - Community Support Services", "DA - Diagnostic Assessment", "DayAct - Day Activity",
          "DayVoc - Day Vocational", "EI - Early Intervention", "FBS - Family Behavioral Services", "FCT - Family Centered Treatment", "FTS - Family Therapeutic Services", "IIH - Intensive In Home", "NRN - Neurorehab",
          "OPT - Outpatient Therapy", "SE - Supported Employment", "SIL - Supported Independent Living", "TransP - Transportation", "WRAP - Wrap Around Services/Supports"
        ], states);
      })
       */     
      .chooseSelectOption("Service Type", "ADOPT - Adoption Services")
      .chooseSelectOption("Residential Property Status", "Network Leased")
      .chooseSelectOption("Network Service Line Offering", "IDD")
      .chooseSelectOption("Population Served", "Adult") 
      .click("[id$=btnSave]")
      .waitForExist(".somethingthatwontbeheresoicalook", defaultOperationTimeout) 
      

  }
})