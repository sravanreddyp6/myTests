var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 1000 * 1000;

testSuite("Service Location Search", suiteTimeout, {
  "should create a new service location": function(client, done) {
  var user = users["RW_MN_L3"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
    
     .execUtil("create_referral", {
      operatingGroup: "Redwood",
      flavor: "AZ" ,
      hooks: {
      		"create_referral_initial_referral": function (client) {
      		return client
      	/*
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
        .waitForExist("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']") 
        
        .click("#originlookup") 
        .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
        */
        	}
        }
      })
        .waitForExist("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']") 
        
    .click("a[id$=originlookup]")
    .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
    .setValue("input[id$=nameFilter2]", "122035")
    .setValue("input[id$=cityFilter]", "Phoenixa")
    .setValue("input[id$=originstate]", "AZ")
    .click("span[id$=searchDialog2] input[value='Search!']")
    .waitForVisible("span[id$=searchDialog2] .messageText", defaultOperationTimeout)
    .click("span[id$=searchDialog2] input[value='Cancel']")
    
    
    .click("a[id$=originlookup]")
    .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
    .setValue("input[id$=nameFilter2]", "020055")
    .click("span[id$=searchDialog2] input[value='Search!']")
    .waitForVisible("span[id$=searchDialog2] .messageText", defaultOperationTimeout)
    .click("span[id$=searchDialog2] input[value='Cancel']")   
     
    .click("a[id$=originlookup]")
    .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
    .setValue("input[id$=nameFilter2]", "122035")
    .setValue("input[id$=cityFilter]", "Phoenix")
    .setValue("input[id$=originstate]", "AZ")
    .click("span[id$=searchDialog2] input[value='Search!']")    
    .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
    .element("span[id$=searchDialog2] a")
    .then(function (el) {
      return this.elementIdClick(el.value.ELEMENT);
    })

  }
})
