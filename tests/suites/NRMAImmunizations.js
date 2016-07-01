var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("NRMAImmunizations", suiteTimeout, {
  "should Create/Edit/E-Sign/Disregard a NeuroRestorative MA Adult and Child Immunizations successfully": function(client, done) {
  
   var user = users["NR_funding"];
   
	  return client
	       .execUtil("convert_referral", {
	        operatingGroup: "NeuroRestorative",
	        flavor: "MA"
	   })   
	      
       // Adult Immunizations for Person Being Served
      .windowHandleMaximize()        
      .waitForVisible("input[value='Add Immunization - Adult']", defaultOperationTimeout)
	  .scroll("input[value='Add Immunization - Adult']", 0 , -300)
	  .click("input[value='Add Immunization - Adult']") 
	     
	  // Cancel Adult Immunization
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']")
    
     //Save Adult Immunization
     .click("input[value='Add Immunization - Adult']") 
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']", defaultOperationTimeout)
     
	  .getSelectOptions('Vaccine Type')
      .then(function(VacType) {
        assert.deepEqual([
          "", "Chicken Pox (Varicella)", "Diphtheria/Tetanus/Pertussis", "Hepatitis A", "Hepatitis B", "Influenza",
           "Measles/Mumps/Rubella", "Meningitis", "Pneumonia", "Shingles (Herpes Zoster)", "Other"
        ], VacType);
      })
      .getSelectOptions('Vaccination Status')
      .then(function(VacStatus) {
        assert.deepEqual([
          "", "Administered", "Administration Unknown", "Not Recommended", "PBS Refused"
        ], VacStatus);
      })
     .chooseSelectOption("Vaccine Type", "Chicken Pox (Varicella)")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultSave & New']")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultSave']", defaultOperationTimeout)

	 // Create one more Adult Immunization (Save and New)
	 
     .chooseSelectOption("Vaccine Type", "Chicken Pox (Varicella)")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultSave']")
     
     //Edit Adult Immunization
     .pause(3000)
     .click("[data-regression='Immunization - AdultPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(3)")
     
     //Cancel edited one
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']")
     
     .click("[data-regression='Immunization - AdultPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(3)")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultCancel']", defaultOperationTimeout)
     .chooseSelectOption("Vaccination Status", "Administered")
     .fillInputText("Dosage (mL)", "1") 
     .fillInputText("Dosage Number", "123") 
     .fillInputText("Body Location", "Test") 
     .fillInputText("Lot #", "2") 
     .fillInputText("Administered By", "Tester") 
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultSave']") 
          
     // E-sign Test Case
     .pause(3000)
     .click("[data-regression='Immunization - AdultPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(5)")
     .waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
     .fillInputText("Username",user.username)
	 .fillInputText("Password",user.password)
     .click("input[value='E-Sign']") 
     .pause(4000)
	 .alertDismiss()     
	 
	 // Disregard Adult Immunization
	 
	 .pause(3000)
     .click("[data-regression='Immunization - AdultPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - AdultDisregard']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - AdultDisregard']", defaultOperationTimeout) 
     
     //Adding Guardian on PBS to overcome below 18 age validation
         
     .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
     .scroll("input[value='Edit Person Being Served']", 0, -300)
     .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
     .waitForVisible("input[value='Save']", defaultOperationTimeout)
     .fillInputText("Date of Birth", "1/1/2002")
     .scroll("input[value='Save']", 0, -300)
	 .click("input[value='Save']")
	 .waitForVisible("input[value='Save']", defaultOperationTimeout)
	 .fillInputText("Party Name", "Test")
	 .scroll("input[value='Save']", 0, -300)
	 .click("input[value='Save']")   
	 
	 // Child Immunization for Person Being Served

	 .waitForVisible("input[value='Add Immunization - Child']", defaultOperationTimeout)
	  .scroll("input[value='Add Immunization - Child']", 0 , -300)
	  .click("input[value='Add Immunization - Child']") 
	     
	  // Cancel Child Immunization
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']")
    
     .click("input[value='Add Immunization - Child']") 
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     
	  .getSelectOptions('Vaccine Type')
      .then(function(VacType) {
        assert.deepEqual([
          "", "Chicken Pox (Varicella)", "Diphtheria/Tetanus/Pertussis", "Hepatitis A", "Hepatitis B", "Inactivated Poliovirus", "Influenza",
           "Measles/Mumps/Rubella", "Pneumonia", "Rotavirus", "Other"
        ], VacType);
      })
      .getSelectOptions('Vaccination Status')
      .then(function(VacStatus) {
        assert.deepEqual([
          "", "Administered", "Administration Unknown", "Not Recommended", "PBS Refused"
        ], VacStatus);
      })
     .chooseSelectOption("Vaccine Type", "Hepatitis A")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave & New']")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']", defaultOperationTimeout)

	 //Create one more Child Immunization (Save and New)
	 
     .chooseSelectOption("Vaccine Type", "Chicken Pox (Varicella)")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']")
     
     //Edit Child Immunization
     .pause(3000)
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(3)")
     
     //Cancel edited one
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']")
     
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(3)")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .chooseSelectOption("Vaccination Status", "Administered")
     .fillInputText("Dosage (mL)", "1") 
     .fillInputText("Dosage Number", "123") 
     .fillInputText("Body Location", "Test") 
     .fillInputText("Lot #", "2") 
     .fillInputText("Administered By", "Tester") 
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']") 
          
     // E-sign Test Case
     .pause(3000)
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a:nth-child(5)")
     .waitForVisible("input[value='E-Sign']", defaultOperationTimeout)
     .fillInputText("Username",user.username)
	 .fillInputText("Password",user.password)
     .click("input[value='E-Sign']") 
     .pause(3000)
	 .alertDismiss()   
	 
	 // Disregard Child Immunizations
	 .pause(3000)
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildDisregard']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildDisregard']", defaultOperationTimeout)
     .pause(3000)
	 
     
     //Child Immunizations for Annual Health and Wellness Checklist
	 .scroll("[id$=adminsId]", 0 , -300)
	 .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
	 
	 .waitForVisible("input[value='New Checklist']", defaultOperationTimeout)
     .scroll("input[value='New Checklist']", 0, -300)
     .click("input[value='New Checklist']", defaultOperationTimeout)
     .waitForVisible("input[value='Save']", defaultOperationTimeout)
     
     .getSelectOptions('Status of Physical')
      .then(function(StaPhysical) {
        assert.deepEqual([
           "Preparation for Annual Physical", "Post Annual Physical"
        ], StaPhysical);
      })
      .getSelectOptions('Is the person taking any psychotropic medications?')
      .then(function(medic) {
        assert.deepEqual([
          "", "Yes", "No"
        ], medic);
      })
      .getSelectOptions('Dental visit within last year?')
      .then(function(dentalYear) {
        assert.deepEqual([
          "", "Yes", "No"
        ], dentalYear);
      })
     //.chooseSelectOption("Status of Physical", "Preparation for Annual Physical")
     .fillInputText("Date of Physical", "4/1/2016") 
     .waitForVisible("input[value='Save']", defaultOperationTimeout)
     .chooseSelectOption("Is this person taking any prescription medications?", "No")
     .chooseSelectOption("Dental visit within last year?", "No")
     .scroll("input[value='Save']", 0, -300)
     .click("input[value='Save']", defaultOperationTimeout)
     
     .waitForVisible("input[value='Edit']", defaultOperationTimeout)
     .click("input[value='Edit']", defaultOperationTimeout)
     .waitForVisible("input[value='Save']", defaultOperationTimeout)
     .chooseSelectOption("Dental visit within last year?", "Yes") 
     .fillInputText("Date of Last Dental Visit", "3/30/2016") 
     .scroll("input[value='Save']", 0, -300)
     .click("input[value='Save']", defaultOperationTimeout)
     //.waitForVisible("input[value='Edit']", defaultOperationTimeout) 
     
     /* Child Immunization for Health and Wellness Checklist  */
     
	 .waitForVisible("input[value='Add Immunization - Child']", defaultOperationTimeout)
	  .scroll("input[value='Add Immunization - Child']", 0 , -300)
	  .click("input[value='Add Immunization - Child']") 
	     
	  // Cancel Child Immunization
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']")
    
     .click("input[value='Add Immunization - Child']") 
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     
	  .getSelectOptions('Vaccine Type')
      .then(function(VacType) {
        assert.deepEqual([
          "", "Chicken Pox (Varicella)", "Diphtheria/Tetanus/Pertussis", "Hepatitis A", "Hepatitis B", "Inactivated Poliovirus", "Influenza",
           "Measles/Mumps/Rubella", "Pneumonia", "Rotavirus", "Other"
        ], VacType);
      })
      .getSelectOptions('Vaccination Status')
      .then(function(VacStatus) {
        assert.deepEqual([
          "", "Administered", "Administration Unknown", "Not Recommended", "PBS Refused"
        ], VacStatus);
      })
     .chooseSelectOption("Vaccine Type", "Hepatitis B")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave & New']")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']", defaultOperationTimeout)

	 //Create one more Child Immunization (Save and New)
	 
     .chooseSelectOption("Vaccine Type", "Pneumonia")
     .fillInputText("Date", "3/30/2016") 
     .chooseSelectOption("Vaccination Status", "Administered")
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']")
     
     //Edit Child Immunization
     .pause(3000)
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
     
     //Cancel edited one
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']")
     
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildCancel']", defaultOperationTimeout)
     .chooseSelectOption("Vaccination Status", "Administered")
     .fillInputText("Dosage (mL)", "1") 
     .fillInputText("Dosage Number", "123") 
     .fillInputText("Body Location", "Test") 
     .fillInputText("Lot #", "2") 
     .fillInputText("Administered By", "Tester") 
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildSave']")   
	 
	 // Disregard Child Immunizations
	 .pause(3000)
     .click("[data-regression='Immunization - ChildPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
     .waitForVisible("span[id$=responseDialog] input[data-regression='Immunization - ChildDisregard']", defaultOperationTimeout)
     .click("span[id$=responseDialog] input[data-regression='Immunization - ChildDisregard']", defaultOperationTimeout)
     .pause(3000)
       
     // Make sure you cannot add an Immunization for PBS with Non-Residential Service Assignments	
     
     .execUtil("convert_referral", {
	        operatingGroup: "NeuroRestorative",
	        flavor: "MA",
	        hooks: {
				"create_referral_before_save_referral": function (client) {
					return client
					.click("a[id$=originlookup]")
					.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
					.setValue("input[id$=nameFilter2]","160926")
				    .setValue("input[id$=originstate]","MA")
					.click("span[id$=searchDialog2] input[value='Search!']")
					.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
					.element("span[id$=searchDialog2] a")
					.then(function (el) {
					  return this.elementIdClick(el.value.ELEMENT);
					})
				}
			}
	      }) 
	      
	 //Add Immunization - Adult button should NOT exist on the Page
      .isExisting("input[value='Add Immunization - Adult']")
      .then(function(isExist){
    	  assert(!isExist);
      })	  
	      
	 .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
     .scroll("input[value='Edit Person Being Served']", 0, -300)
     .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
     .waitForVisible("input[value='Save']", defaultOperationTimeout)
     .fillInputText("Date of Birth", "1/1/2002")
     .scroll("input[value='Save']", 0, -300)
	 .click("input[value='Save']")
	 .waitForVisible("input[value='Save']", defaultOperationTimeout)
	 .fillInputText("Party Name", "Test")
	 .scroll("input[value='Save']", 0, -300)
	 .click("input[value='Save']")     
	 .pause(3000)
	 
	 //Add Immunization - Child button should NOT exist on the Page
	 	 
	 .isExisting("input[value='Add Immunization - Child']")
	      .then(function(isExist){
	    	  assert(!isExist);
	 })
	       
      
}
});
       