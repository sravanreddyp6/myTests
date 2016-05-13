var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');
var user = users["ADH_MA_Referral"];
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("ADHMAServiceAssignment", suiteTimeout, {
  "Should Create/Edit/View/Close/promptFullDischarge a ADH MA Service Assignment successfully": function(client, done) {
    return client
      //Referral Conversion
      .execUtil("convert_referral", {
             operatingGroup: "Adult Day Health",
             flavor: "MA",
       hooks: {
    	   "create_referral_after_save_referral": function (client) {
				return client
				.pause(3000)
				.click("[id$=confirmId]")
				.pause(3000)
			    .click("[id$=esignId]")
			    .pause(3000)
			    
			    .waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
		        .fillInputText("Username",user.username)
			    .fillInputText("Password",user.password)
		        .click("input[value='E-Sign']") 
		        .pause(6000)
			    .alertDismiss()  
			    .pause(4000)
       }
       }
      })
      .scroll("[id$=adminsId]", 0 , -300)
	  .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
	  .windowHandleMaximize()  
	  .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
	  .scroll("input[value='New Standard Service']", 0 , -300)
	  .click("input[value='New Standard Service']")      
	  .waitForVisible("span[id$=buttons] input[value='Cancel']", defaultOperationTimeout)
	  .click("span[id$=buttons] input[value='Cancel']")
  
      //Creating SA with Active Status and Editing to Created in Error
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("input[value='New Standard Service']", 0 , -300)
      .click("input[value='New Standard Service']")      
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      //.click("span[id$=sl] a")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","155100")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:nth-child(2) a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .getSelectOptions('Service Assignment Status')
      .then(function(saStatus) {
        assert.deepEqual([
          "", "Active", "Inactive", "Created in Error"
        ], saStatus);
      })
      .chooseSelectOption("Service Assignment Status", "Created in Error")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .fillInputText("Specify Error", "Testing") 
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300) 
	     
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
       //Creating SA with Active Status and Editing to Inactive(Close SA)
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("input[value='New Standard Service']", 0 , -300)
      .click("input[value='New Standard Service']")      
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","155100")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:nth-child(2) a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .getSelectOptions('Service Ended via Business Divested?')
      .then(function(sEndBu) {
        assert.deepEqual([
          "", "Yes", "No"
        ], sEndBu);
      })
      .getSelectOptions('End of Service Circumstances')
      .then(function(endSC) {
        assert.deepEqual([
          "", "PBS has not showed up for 6 months", "PBS has expressed that they are not interested in the program", "PBS deceased"
        ], endSC);
      }) 
      .getSelectOptions('Was dissatisfaction the reason for service ending?')
      .then(function(wasSE) {
        assert.deepEqual([
          "", "Yes", "No"
        ], wasSE);
      })
      .fillInputText("End Date", "1/14/2016") 
      .chooseSelectOption("Service Ended via Business Divested?", "No")     
      .chooseSelectOption("End of Service Circumstances", "PBS has expressed that they are not interested in the program")
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
      
      // Prompt Full Discharge
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")     
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(1) a") 
      .waitForVisible("input[value='Save']", defaultOperationTimeout) 
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      
      .fillInputText("End Date", "1/14/2016")  
      .chooseSelectOption("Service Ended via Business Divested?", "No")     
      .chooseSelectOption("End of Service Circumstances", "PBS has expressed that they are not interested in the program")
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
      
      .click("span[id$=buttons] input[value='Save']")
	  .waitForVisible("input[value='No']", defaultOperationTimeout) 
	  .click("[id$=blockAfterEsign] input[value='No']")
	  .waitForVisible("input[value='Edit']", defaultOperationTimeout)
	  
	  .url()
      .then(function (url) {
        assert.include(url.value, "ServiceAssignmentEditNew");
      })
      .getOutputText("Service Assignment Status")
      .then(function (saStatus) {
        assert.equal("Inactive", saStatus.trim());
      })
      .getOutputText("End Date")
      .then(function (enddate) {
        assert.equal("1/14/2016", enddate.trim());
      })
      .getOutputText("Was this a transfer from another Service Assignment?")
      .then(function (wtASA) {
        assert.equal("No", wtASA.trim());
      })
      .getOutputText("Service Began via Acquisition Company (as of 2016)?")
      .then(function (servBAC) {
        assert.equal("No", servBAC.trim());
      })
      .getOutputText("Is this a transfer to another Service Assignment?")
      .then(function (transToSA) {
        assert.equal("No", transToSA.trim());
      })
      .getOutputText("Service Ended via Business Divested?")
      .then(function (serveEndBD) {
        assert.equal("No", serveEndBD.trim());
      })
      .getOutputText("End of Service Circumstances")
      .then(function (eoSerC) {
        assert.equal("PBS has expressed that they are not interested in the program", eoSerC.trim());
      })      
      .getOutputText("Was dissatisfaction the reason for service ending?")
      .then(function (dservEnd) {
        assert.equal("No", dservEnd.trim());
      })
  }
});