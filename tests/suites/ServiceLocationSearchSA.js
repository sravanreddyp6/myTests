var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("Service Location Search", suiteTimeout, {
  "should search an SL on the SA page": function(client, done) {
    return client
      //Referral Convertion
      .execUtil("convert_referral", {
             operatingGroup: "Redwood",
             flavor: "AZ"
       })
      //Navigating to Admission Page
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
      .windowHandleMaximize()   
      

	  
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")    
      .waitForVisible("input[value='Save']", defaultOperationTimeout)

      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","122035")
      .setValue("input[class=inp_City]","Phoenix")
      .setValue("input[class=inp_State]","MN")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] .messageText", defaultOperationTimeout)
      .click("span[id$=searchDialog] input[value='Cancel']")
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","020055")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] .messageText", defaultOperationTimeout)
      .click("span[id$=searchDialog] input[value='Cancel']")      
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)      
      .setValue("input[id$=nameFilter]","122035")
      .setValue("input[class=inp_City]","Phoenix")
      .setValue("input[class=inp_State]","AZ")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      .element("span[id$=searchDialog] tr:first-child a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      

  }
});