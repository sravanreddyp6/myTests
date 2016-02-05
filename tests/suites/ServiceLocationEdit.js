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
        .setValue("input#lksrch", "330705")
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
      // we want to make sure TMN scope is set to Residential so we can predict the -none- salesforce adds to service type when scope is changed
	  .chooseSelectOption("TMN Scope", "Residential")      
      .click("[id$=btnSave]")
      .waitForExist("#viewServiceLocation", defaultOperationTimeout)        
      .waitForExist("[id$=editBTN]", defaultOperationTimeout)
      .click("[id$=editBTN]")       
      //.fillInputText("Program Code", "newcode")
      .fillInputText("Location Nickname", "n")
      .fillInputText("Street", "s")
      .fillInputText("City", "c")
      .fillInputText("State", "AZ")
      .fillInputText("Zip", "12345")
      .fillInputText("Phone", "111-222-3333")
      .fillInputText("TIN", "12345")
      .fillInputText("NPI", "1")
      .fillInputText("Capacity", "1")
      .fillInputText("Facility Number (Oracle Fixed Assets)", "1")        
      
      .chooseSelectOption("Physical Location", "Facility")
      .getSelectOptions('Physical Location')
      .then(function(items) {
        assert.deepEqual([ 
          "Center Based", 
		  "Clinic",
		  "Community Based",
		  "Facility",
		  "Group Home",
		  "Host Home",
		  "In-Home",
		  "Office - Non-Service",
		  "School"
        ], items);
      })       
      .chooseSelectOption("TMN Scope", "Residential")
	      .getSelectOptions('TMN Scope')
	      .then(function(items) {
	        assert.deepEqual([ 
	          "Residential",
	          "Non-Residential"
	        ], items);
	      })        
	      .getSelectOptions('Service Type')
	      .then(function(items) {
	        assert.deepEqual([ 
	          "AFC - Adult Family Care",
	          "FC - Foster Care",
	          "ICFCN - Intermediate Care Facility Continuous Nursing",
	          "ICFH - Intermediate Care Facility Habilitative",
	          "ICFIDD - ICFIDD",
	          "ICFN - Intermediate Care Facility Nursing",
	          "LC - Life Care",
	          "NB - Neurobehavioral",
	          "NRR - Neurorehab",
	          "OS - Offender Services",
	          "PCH - Personal Care Home",
	          "RS - Respite Service",
	          "RTC - Residential Treatment Center",
	          "SL - Supported Living",
	          "TA - Transition to Adulthood",
	          "TFC - Therapeutic Foster Care",
	          "TGH - Therapeutic Group Home",
	          "TL - Transitional Living",
	          "TransC - Transitional Care"
	          
	        ], items);
	      })  
          
      .chooseSelectOption("TMN Scope", "Non-Residential")
	      .getSelectOptions('Service Type')
	      .then(function(states) {
	        assert.deepEqual([ 
	          "",
	          "ADOPT - Adoption Services", 
	          "BSS - Behavior Support Services", 
	          "CI - Crisis Intervention", 
	          "CM - Case Management", 
	          "CSS - Community Support Services", 
	          "DA - Diagnostic Assessment", 
	          "DayAct - Day Activity",
	          "DayVoc - Day Vocational", 
	          "EI - Early Intervention", 
	          "FBS - Family Behavioral Services", 
	          "FCT - Family Centered Treatment", 
	          "FTS - Family Therapeutic Services", 
	          "IIH - Intensive In Home", 
	          "NRN - Neurorehab",
	          "OPT - Outpatient Therapy", 
	          "SE - Supported Employment", 
	          "SIL - Supported Independent Living", 
	          "TransP - Transportation", 
	          "WRAP - Wrap Around Services/Supports"
	        ], states);
	      })
            
      .chooseSelectOption("Service Type", "ADOPT - Adoption Services")    
      .chooseSelectOption("Residential Property Status", "PBS Leased")
	      .getSelectOptions('Residential Property Status')
	      .then(function(items) {
	        assert.deepEqual([ 
	          "",
	          "Network Leased",
	          "Network Owned",
	          "PBS Leased",
	          "PBS Owned"
	        ], items);
	      })         
      .chooseSelectOption("Network Service Line Offering", "ARY")
	      .getSelectOptions('Network Service Line Offering')
	      .then(function(items) {
	        assert.deepEqual([ 
	          "ABI",
	          "ADH",
	          "ARY",
	          "IDD",
	          "MH"
	        ], items);
	      })         
      .chooseSelectOption("Population Served", "Child")  
	      .getSelectOptions('Population Served')
	      .then(function(items) {
	        assert.deepEqual([ 
	          "Child",
	          "Adult",
	          "Senior"
	        ], items);
	      })           
      .click("[id$=btnSave]")
      .waitForExist("#viewServiceLocation", defaultOperationTimeout)  
	  .getOutputText("Location Nickname")
		  .then(function (item) {
		    assert.equal("n", item);
		  }) 
		  /*
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include("my street", item);
		  })
		  */ 			  		  		  	        
	  .getOutputText("Physical Location")
		  .then(function (item) {
		    assert.equal("Facility", item);
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
		    assert.equal("PBS Leased", item);
		  })  
	  .getOutputText("Network Service Line Offering")
		  .then(function (item) {
		    assert.equal("ARY", item);
		  })
	  .getOutputText("Population Served")
		  .then(function (item) {
		    assert.equal("Child", item);
		  }) 	   
	  .getOutputText("TIN")
		  .then(function (item) {
		    assert.equal("12345", item);
		  }) 	  
	  .getOutputText("NPI")
		  .then(function (item) {
		    assert.equal("1", item);
		  }) 	
	  .getOutputText("Capacity")
		  .then(function (item) {
		    assert.equal("1", item);
		  }) 	 
	  .getOutputText("Facility Number (Oracle Fixed Assets)")
		  .then(function (item) {
		    assert.equal("1", item);
		  }) 	 	
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include(item, "s");
		  })		  	  		   
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include(item, "c");
		  })
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include(item, "AZ");
		  })		  		  		
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include(item, "12345");
		  })		    
	  .getOutputText("Address")
		  .then(function (item) {
		    assert.include(item, "111-222-3333");
		  })		  
      
      
      
      
      
      .waitForExist("[id$=editBTN]", defaultOperationTimeout)
      .click("[id$=editBTN]") 


      .fillInputText("Location Nickname", "Hutchinson")
      .fillInputText("Street", "2441 Hutchinson Road")
      .fillInputText("City", "Duluth")
      .fillInputText("State", "MN")
      .fillInputText("Zip", "55811-3215")
      .fillInputText("Phone", "218-724-3731")
      .fillInputText("TIN", "41-1910302")
      .fillInputText("NPI", "")
      .fillInputText("Capacity", "")
      .fillInputText("Facility Number (Oracle Fixed Assets)", "")
      .chooseSelectOption("Physical Location", "Clinic")
      .chooseSelectOption("TMN Scope", "Residential")   
      .chooseSelectOption("Service Type", "SL - Supported Living")
      .chooseSelectOption("Residential Property Status", "Network Leased")
      .chooseSelectOption("Network Service Line Offering", "IDD")
      .chooseSelectOption("Population Served", "Adult") 
      .click("[id$=btnSave]")      
      

  }
})