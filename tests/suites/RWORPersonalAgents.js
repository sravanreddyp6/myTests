var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("RWORPersonalAgents", suiteTimeout, {
  "should Add/Edit/Cancel a Redwood OR Brokerage Personal Agents successfully": function(client, done) {     
     
	  return client
	       .execUtil("convert_referral", {
	        operatingGroup: "Redwood",
	        flavor: "OR"
			
	   }) 
	     
	   // Navigating to Admission Page
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
      .windowHandleMaximize() 
       
      // Navigating to Service Assignment Page
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")  
	  
	  /* Manage Personal Agents */
	  .windowHandleMaximize()
	  .waitForVisible("input[value='Add Personal Agent']", defaultOperationTimeout)
	  .scroll("input[value='Add Personal Agent']", 0 , -300)
	  .click("input[value='Add Personal Agent']") 
	  
	  // Cancel Personal Agent
	  .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
	  .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
	  .pause(4000)   
	  .click("input[value='Add Personal Agent']")   
	  	  
	  // Save Personal Agent
	  .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)	  
	  .getSelectOptions('Status')
      .then(function(St) {
        assert.deepEqual([
          "", "Active", "Inactive"
        ], St);
      })
      .fillInputText("From", "04/07/2016") 
      .chooseSelectOption("Status", "Active")
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("table[id$='casemanagerTable'] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save and New']")
      
	  // Save and New Personal Agent
	  .pause(4000)
	  .fillInputText("From", "04/07/2016") 
      .chooseSelectOption("Status", "Active")
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("table[id$='casemanagerTable'] tbody tr:nth-child(1) td:nth-child(1) a")
 	  .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save']")
      
      // Edit Personal Agent
      .pause(4000)
      .click("table[id$='pAgentTable'] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      
      // Cancel the edited one
	  .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
	  .pause(4000)
      .click("table[id$='pAgentTable'] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)      
      .chooseSelectOption("Status", "Inactive")
      .pause(2000)
      .fillInputText("To", "04/08/2016") 
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
      .pause(3000)
      //.waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save and New']", defaultOperationTimeout)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save and New']")
      
	  // Save and New in edited Personal Agent
	  .pause(3000)
	  .fillInputText("From", "04/07/2016") 
      .chooseSelectOption("Status", "Active")
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("table[id$='casemanagerTable'] tbody tr:nth-child(1) td:nth-child(1) a")
 	  .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save']")
      .pause(2000)
      .fillInputText("From", "04/09/2016") 
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
	  .pause(3000)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save']")
      .pause(3000)
      
      .click("table[id$='pAgentTable'] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)      
      .chooseSelectOption("Status", "Inactive")
      .pause(2000)
      .fillInputText("To", "04/08/2016") 
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
      .pause(3000)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save']")
      .pause(2000)
      .fillInputText("To", "04/10/2016") 
      .click("[id$='pAgentModalBlock'] img[class='lookupIcon']")
      .waitForVisible("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']", defaultOperationTimeout)
      .click("[id$='caseManagerModalBlock:pAgentButtons:bottom'] input[Value='Cancel']")
      .pause(3000)
      .click("[id$='pAgentModalBlock:pAgentButtons:bottom'] input[Value='Save']")
      .pause(3000)
      
      /* Negative Testing - Non-OR Brokerage */
      
      .execUtil("convert_referral", {
	        operatingGroup: "Redwood",
	        flavor: "OR",
	        hooks: {
				"create_referral_before_save_referral": function (client) {
					return client
					.click("a[id$=originlookup]")
					.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
					.setValue("input[id$=nameFilter2]","038030")
				    .setValue("input[id$=originstate]","OR")
					.click("span[id$=searchDialog2] input[value='Search!']")
					.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
					.element("span[id$=searchDialog2] a")
					.then(function (el) {
					  return this.elementIdClick(el.value.ELEMENT);
					})
				}
			}
			
	   })   
	   
      // Navigating to Admission Page
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
        
      // Navigating to Service Assignment Page
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")  
      
      // Add Personal Agent button should NOT exist on the Page
	  	 
	  .isExisting("input[value='Add Personal Agent']")
	      .then(function(isExist){
	    	  assert(!isExist);
	  }) 
	  
}
});
     