var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 100 * 1000;

testSuite("Service Location Create", suiteTimeout, {
  "should create a new service location": function(client, done) {
    return client
      .logInAs(users["RW_MN_L3"])
      .click("a=Manage Service Locations")
      .click("input[value='Create New Service Location']")
      .waitForExist("#newServiceLocation", defaultOperationTimeout)
        .click(".lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "12345")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#Alias__c_body tr.dataRow th a")
        .switchToNextWindow()
        .waitForExist("label=Program Code", defaultOperationTimeout)
        
      .fillInputText("Program Code", "newcode")
      .fillInputText("Location Nickname", "newcode")
      .fillInputText("Street", "newcode")
      .fillInputText("City", "newcode")
      .fillInputText("State", "AZ")
      .fillInputText("Zip", "newcode")
      .chooseSelectOption("Physical Location", "Clinic")
      .chooseSelectOption("TMN Scope", "Non-Residential")
      .chooseSelectOption("Service Type", "ADOPT - Adoption Services")
      .chooseSelectOption("Residential Property Status", "Network Leased")
      .chooseSelectOption("Network Service Line Offering", "IDD")
      .chooseSelectOption("Population Served", "Adult")
      .click("[id$=btnSave]")        
           
      .waitForExist("#searchFrame2", defaultOperationTimeout)

  }
})