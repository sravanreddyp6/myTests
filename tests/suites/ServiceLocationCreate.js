var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 100 * 1000;
var prog = '';

testSuite("Service Location Create", suiteTimeout, {
  "should create a new service location": function(client, done) {
    return client
      .logInAs(users["RW_MN_L3"])
      .click("a=Manage Service Locations")
      .click("input[value='Create New Service Location']")
      .waitForExist("[id$=cancelBTN]", defaultOperationTimeout)
      .click("[id$=cancelBTN]")
      	.url()
      	.then(function (url) {assert.include(url.value, 'manageServiceLocations');})
      .waitForExist("input[value='Create New Service Location']", defaultOperationTimeout)	
      .click("input[value='Create New Service Location']")
      .waitForExist("#newServiceLocation", defaultOperationTimeout)
        .click(".lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "360621")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#Alias__c_body tr.dataRow th a")
        .switchToNextWindow()
        .waitForExist("label=Program Code", defaultOperationTimeout)
        .waitForExist("label=ZIP Code", defaultOperationTimeout)
        
      //.fillInputText("Program Code", "newcode")
      .fillInputText("Location Nickname", "my name")
      .fillInputText("Street", "my street")
      .fillInputText("City", "my city")
      .fillInputText("State", "MN")
      .fillInputText("ZIP Code", "12345")
      .chooseSelectOption("Physical Location", "Clinic")
      .chooseSelectOption("TMN Scope", "Non-Residential")
      .chooseSelectOption("Service Type", "ADOPT - Adoption Services")
      .chooseSelectOption("Residential Property Status", "Network Leased")
      .chooseSelectOption("Network Service Line Offering", "IDD")
      .chooseSelectOption("Population Served", "Adult")
      .click("[id$=saveBTN]")  
      .waitForExist("#viewServiceLocation", defaultOperationTimeout)  
      .getOutputText("Program Code").then(function (val) {		    
		    prog = val;
  		})  
	  .getOutputText("Location Nickname")
		  .then(function (item) {
		    assert.equal("my name", item);
		  }) 
		  
		  			  		  		  	        
	  .getOutputText("Physical Location")
		  .then(function (item) {
		    assert.equal("Clinic", item);
		  })
	  .getOutputText("TMN Scope")
		  .then(function (item) {
		    assert.equal("Non-Residential", item);
		  }) 
	  .getOutputText("Service Type")
		  .then(function (item) {
		    assert.equal("ADOPT - Adoption Services", item);
		  }) 		  		 
	  .getOutputText("Residential Property Status")
		  .then(function (item) {
		    assert.equal("Network Leased", item);
		  }) 
	  .getOutputText("Physical Location")
		  .then(function (item) {
		    assert.equal("Clinic", item);
		  }) 
	  .getOutputText("Network Service Line Offering")
		  .then(function (item) {
		    assert.equal("IDD", item);
		  })
	  .getOutputText("Population Served")
		  .then(function (item) {
		    assert.equal("Adult", item);
		  }) 
	  .getOutputText("Location Nickname")
		  .then(function (item) {
		    assert.equal("my name", item);
		  }) 		  		           

      .click("a=Manage Service Locations")      
     .waitForExist("input[value='Create New Service Location']", defaultOperationTimeout)	
      .click("input[value='Create New Service Location']")
      .waitForExist("#newServiceLocation", defaultOperationTimeout)
        .click(".lookupInput a")
        .switchToNextWindow()
        .waitForExist("#searchFrame", defaultOperationTimeout)
        .element("#searchFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .setValue("input#lksrch", "360621")
        .click("input[value*='Go']")
        .frameParent()
        .waitForExist("#resultsFrame", defaultOperationTimeout)
        .element("#resultsFrame")
        .then(function (frame) { return frame.value; })
        .then(client.frame)
        .click("#Alias__c_body tr.dataRow th a")
        .switchToNextWindow()
        .waitForExist("label=Program Code", defaultOperationTimeout)
        .waitForExist("label=ZIP Code", defaultOperationTimeout)        
      .then(function () { return client.fillInputText("Program Code", prog) })
      //.fillInputText("Program Code", prog)      
      .fillInputText("Location Nickname", "my name")
      .fillInputText("Street", "my street")
      .fillInputText("City", "my city")
      .fillInputText("State", "MN")
      .fillInputText("ZIP Code", "12345")
      .chooseSelectOption("Physical Location", "Clinic")
      .chooseSelectOption("TMN Scope", "Non-Residential")
      .chooseSelectOption("Service Type", "ADOPT - Adoption Services")
      .chooseSelectOption("Residential Property Status", "Network Leased")
      .chooseSelectOption("Network Service Line Offering", "IDD")
      .chooseSelectOption("Population Served", "Adult")
      .click("[id$=saveBTN]")            
      .waitForExist(".messageText", defaultOperationTimeout)
      .getPageMessages("msgs")
		  .then(function (item) {
		    assert.equal("Another Service Location exists with this Program Code and Facility ID", item);
		  })      	

  }
})