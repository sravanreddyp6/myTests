var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CMPBSeditNew", suiteTimeout, {
	  "should be able to update and Save the PBS and related lists successfully": function(client, done) {
		  var user = users["CM_DON"];
		  var user2 = users["CM_Marketer"];
		  var today = new Date().getMilliseconds() + new Date().getDate();
		  var firstName = 'Regression '+today;
		  var lastName = 'CM PBS '+today;
		  var middleName = 'test '+today;
		  var birthDate = "1/12/1988";
		  var birthdateString = "1988-12-01";
		  var age = function(birthdateString){
			  var birthday = new Date(birthdateString);
			  return~~ ((Date.now() - birthday) / (31557600000)) + ' Years';
		  }
		  var alias; 
		  
	    client = client
	    
	      .logInAs(user2)
	      .click("a=Create New Referral")
	      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
	      .fillInputText("First Name", firstName)
	      .chooseSelectOption("Race", "Caucasian")
	      .fillInputText("Middle Name", middleName)
	      .chooseSelectOption("Ethnicity", "Unknown")
	      .fillInputText("Last Name", lastName)
	      .chooseSelectOption("Marital Status", "Divorced")
	      .fillInputText("Date of Birth", "7/7/1970")
	    //.chooseSelectOption("Highest Level of Education", "Graduate School")
	      .chooseSelectOption("Gender", "Male")
	      .fillInputText("Additional Information / Comments", "Some additional Information")
	      .fillInputText("Mailing Street 1", "123 Something Street")
	      .fillInputText("Mailing Street 2", "apt. 456")
	      .fillInputText("Mailing City", "Some City")
	      .fillInputText("Mailing Zip/Postal Code", "23456")
	      .fillInputText("Mailing County", "Orange County")
	      .chooseSelectOption("Mailing State/Province", "California")
	      .setValue("input[id$=Perm_Phone]", "6090210")
	      .setValue("input[id$=Perm_Email]", "someone@something.com")
	      .click("input[value='Create Person Being Referred']")
	      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
	      .fillInputText("Anticipated Admission DateTime", "12/30/2015 16:00") 
	      .click("input[value='Add Related Party']")
	      .waitForVisible("span[id$=relatedPartyModal]", defaultOperationTimeout)
	      .fillInputText("Party Name", "Anakin Skywalker")
	      .chooseSelectOption("Type", "Family/Friends")
	      .click("span[id$=relatedPartyModal] input[value=Save]")
	      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	      .fillInputText("Referral Source", "Mentor")
	      .fillInputText("Referrer Name", "Obi-wan Kennobi")
	      .fillInputText("Current Location", "Boston")
	      .selectLookup("Evaluated By")
	      .switchToNextWindow()
	      .waitForExist("#searchFrame", defaultOperationTimeout)
	      .element("#searchFrame")
	      .then(function (frame) { return frame.value; })
	      .then(client.frame)
	      .setValue("input#lksrch", user["first_name"] + " " + user["last_name"])
	      .click("input[value*='Go']")
	      .frameParent()
	      .waitForExist("#resultsFrame", defaultOperationTimeout)
	      .element("#resultsFrame")
	      .then(function (frame) { return frame.value; })
	      .then(client.frame)
	      .click("#TMN_User__c_body tr.dataRow th a")
	      .switchToNextWindow()
	      .click("a[id$=originlookup]")
	      .waitForVisible("input[id$=originstate]", defaultOperationTimeout)
	      .setValue("input[id$=originstate]","CA")
	      .click("span[id$=searchDialog2] input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
	      .element("span[id$=searchDialog2] a")
	      .then(function (el) {
	      return this.elementIdClick(el.value.ELEMENT);
	      })
	      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
	      .getOutputTextFromInput("Alias")
	      .then(function(text){
	    	  alias = text;
	      })
	      .click("input[value='Add Location']")
	      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	      .chooseSelectOption("Rank", "Primary")
	      .selectByValue("select[id$=locationEntry_Status]", "Active")
	      .click("a[id$=aliaslookup]")
	      .waitForVisible("input[value='First']", defaultOperationTimeout)
	      .setValue("input[id$=addlocationstate]","CA")
	      .click("span[id$=searchDialog] input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
	      .element("span[id$=searchDialog] a")
	      .then(function (el) {
	      	return this.elementIdClick(el.value.ELEMENT);
	      })
	      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	      .click("span[id$=ReferralLocationModal] input[value='Save']")
	      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
		  .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
	      .click("input[value='Add Funding Source']")
	      .waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
	      .chooseSelectOption("Coverage Level", "Primary")	
	      .selectCheckbox("More than 1.5 Yrs of Disability")
	      .selectCheckbox("ALS/ESRD/Black Lung Disease")
	      .selectCheckbox("Patient Over 64 Years of Age")
	      .click("span[id$=FundingSourceModal] input[value='Save']")
	      .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
		  .click("input[value='Save Referral']")
	      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
	      
	      .logInAs(user)
	      .addValue("[id$=PbsSearchFirstName]",firstName) //Seeing weird behavior if FillinputText is used
	      .addValue("[id$=PbsSearchLastName]",lastName)
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(2) a")   
	      .click("input[type='submit'][value='Search']", defaultOperationTimeout)
	      .waitForVisible("input[value='Search']", defaultOperationTimeout)
	      .click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(1) a")	            
	      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
	      .click("input[value='Convert']")
	      .waitForVisible("span[id$=ReferralAdmissionLocationModal] input[value='Save and Continue']", defaultOperationTimeout)
	      .click("span[id$=ReferralAdmissionLocationModal] input[value='Save and Continue']")
	      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
	      .click("input[value='Confirm Conversion']")      
	      
//stuff here
		   
		  .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      //Validate All the blank fields by inputting blank values and hitting Save
	      .windowHandleMaximize()
	      .fillInputText("Date of Birth", "")
	      .fillInputText("First Name", "")
	      .fillInputText("Middle Name", "")
	      .fillInputText("Last Name", "")
	     
	      
	      //.fillInputText("Does the person Identify with a gender other than legal gender selected?", "")
	      .scroll("input[value='Save']", 0, -300)
	      .click("input[value='Save']")
	      .waitForVisible("[id$='msgs'] .messageText", defaultOperationTimeout)
	      //.waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .getText("#msgs*=First Name: You must enter a value") // This is equivalent to assert
	      
	      .fillInputText("First Name", firstName)
	      .fillInputText("Middle Name", middleName)
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Last Name: You must enter a value")
	      .fillInputText("Last Name", lastName)
	      .click("input[value='Save']")
	      .getText("#msgs*=Date of Birth: You must enter a value")
	      .fillInputText("Date of Birth", "01/12/1988")
	     
	      .chooseSelectOption("Does the person Identify with a gender other than legal gender selected?","No")
	      .chooseSelectOption("Does the person Identify with a gender other than legal gender selected?","Yes")
	      .waitForVisible("input[id$='genderIdentity']", defaultOperationTimeout)
	      .addValue("input[id$='genderIdentity']", "")
	      .scroll("input[value='Save']", 0, -300)
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Gender Identity is required when the person identifies with a gender other than the legal gender")
	      .fillInputText("Gender Identity", "Test")
	      .click("input[value='Save']")
	      
	      .waitForVisible("input[type='submit'][value='Edit Person Being Served']", defaultOperationTimeout)
	      .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .fillInputText("Billing ID","Some random BillingId")
	      .chooseSelectOption("Billing System","AVATAR")
	      .fillInputText("Other ID","Some random otherId")
	      .fillInputText("Other ID Description","Some random description")
	      .fillInputText("UCI ID","Some California Info")
	      .fillInputText("Other Street 1", "Test Street")
	      .fillInputText("Other Street 2", "Test steet 2")
	      .fillInputText("Other City", "Test City")
	      .fillInputText("Other Zip/Postal Code","12345")
	      .fillInputText("Other County", "Test County")
	      .fillInputText("Other Phone", "123-234-5555")
	      .fillInputText("Other Contact Information", "Nothing much to fill here")
	      .fillInputText("Family Members / Other / Notes", "Test Notes")
	      .chooseSelectOption("Guardianship Type","Self") // Change to partial to validate the validation rule
	      .selectCheckbox("VIP Indicator")
	      .scroll(0,-200) //move down
	      .selectCheckbox("Advance Directives")
	      .pause(300)
	      .selectCheckbox("Advance Directives Attached")
	      .chooseSelectOption("Code Status","Other")
	      .pause(300)
	      .fillInputText("Specify Other", "Test Other")
	      .scroll("[id$='SavePBSId']",0,-300) //move up to save button
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      
	      
	      //Validating output field values in view mode
	      .getOutputText("First Name")
	      .then(function(text){
	    	  assert.equal(firstName, text.trim());
	      	})
	      .getOutputText("Middle Name")
	      .then(function(text){
	    	  assert.equal(middleName, text.trim());
	      	})
	      .getOutputText("Last Name")
	      .then(function(text){
	    	  assert.equal(lastName, text.trim());
	      })
	      .getOutputText("Date of Birth")
	      .then(function(text){
	    	  assert.equal("1/12/1988", text.trim());
	      })
	      .getOutputText("Age")
	      .then(function(text){
	    	  assert.equal(age(birthDate), text.trim()); 
	      })
	      .getOutputText("Gender")
	      .then(function(text){
	    	  assert.equal("Male", text.trim());
	      })
	      .getOutputText("Does the person Identify with a gender other than legal gender selected?")
	      .then(function(text){
	    	  assert.equal("Yes", text.trim());
	      })
	      .getOutputText("Describe Gender Identity")
	      .then(function(text){
	    	  assert.equal("Test", text.trim());
	      })
	      .getOutputText("Race")
	      .then(function(text){
	    	  assert.equal("Caucasian", text.trim());
	      })
	      .getOutputText("Ethnicity")
	      .then(function(text){
	    	  assert.equal("Unknown", text.trim());
	      })
	      .getOutputText("Marital Status")
	      .then(function(text){
	    	  assert.equal("Divorced", text.trim());
	      })
	     /* .getOutputText("Primary Language")
	      .then(function(text){
	    	  assert.equal("English", text.trim());
	      })*/
	      
	      .getOutputText("Billing ID")
	      .then(function(text){
	    	  assert.equal("Some random BillingId", text.trim());
	      })
	      .getOutputText("Billing System")
	      .then(function(text){
	    	  assert.equal("AVATAR", text.trim());
	      })
	      .getOutputText("Other ID")
	      .then(function(text){
	    	  assert.equal("Some random otherId", text.trim());
	      })
	      .getOutputText("Other ID Description")
	      .then(function(text){
	    	  assert.equal("Some random description", text.trim());
	      })
	      .getOutputText("UCI ID")
	      .then(function(text){
	    	  assert.equal("Some California Info", text.trim());
	      })
	      .getOutputText("Mailing Street 1")
	      .then(function(text){
	    	  assert.equal("123 Something Street", text.trim());
	      })
	      .getOutputText("Mailing Street 2")
	      .then(function(text){
	    	  assert.equal("apt. 456", text.trim());
	      })
	      .getOutputText("Mailing City")
	      .then(function(text){
	    	  assert.equal("Some City", text.trim());
	      })
	      .getOutputText("Mailing Zip/Postal Code")
	      .then(function(text){
	    	  assert.equal("23456", text.trim());
	      })
	      .getOutputText("Mailing County")
	      .then(function(text){
	    	  assert.equal("Orange County", text.trim());
	      })
	      .getOutputText("Home Phone")
	      .then(function(text){
	    	  assert.equal("6090210", text.trim());
	      })
	      .getOutputText("Email")
	      .then(function(text){
	    	  assert.equal("someone@something.com", text.trim());
	      })
	      .getOutputText("Other Street 1")
	      .then(function(text){
	    	  assert.equal("Test Street", text.trim());
	      })
	      .getOutputText("Other Street 1")
	      .then(function(text){
	    	  assert.equal("Test Street", text.trim());
	      })
	      .getOutputText("Other Street 1")
	      .then(function(text){
	    	  assert.equal("Test Street", text.trim());
	      })
	      .getOutputText("Other Street 2")
	      .then(function(text){
	    	  assert.equal("Test steet 2", text.trim());
	      })
	      .getOutputText("Other City")
	      .then(function(text){
	    	  assert.equal("Test City", text.trim());
	      })
	      .getOutputText("Other State/Province")
	      .then(function(text){
	    	  assert.equal("", text.trim());
	      })
	      .getOutputText("Other Zip/Postal Code")
	      .then(function(text){
	    	  assert.equal("12345", text.trim());
	      })
	      .getOutputText("Other County")
	      .then(function(text){
	    	  assert.equal("Test County", text.trim());
	      })
	      .getOutputText("Other Phone")
	      .then(function(text){
	    	  assert.equal("123-234-5555", text.trim());
	      })
	      .getOutputText("Other Contact Information")
	      .then(function(text){
	    	  assert.equal("Nothing much to fill here", text.trim());
	      })
	      .getOutputText("Family Members / Other / Notes")
	      .then(function(text){
	    	  assert.equal("Test Notes", text.trim());
	      })
	      .getCheckboxOutput("VIP Indicator")
	      .then(function(isChecked){
	    	  assert(isChecked);
	      })
	      .getCheckboxOutput("Advance Directives")
	      .then(function(isChecked){
	    	  assert(isChecked);
	      })
	      .getCheckboxOutput("Advance Directives Attached")
	      .then(function(isChecked){
	    	  assert(isChecked);
	      })
	      .getOutputText("Guardianship Type")
	      .then(function(text){
	    	  assert.equal("Self", text.trim());
	      })
	      .getOutputText("Code Status")
	      .then(function(text){
	    	  assert.equal("Other", text.trim());
	      })
	      .getOutputText("Specify Other")
	      .then(function(text){
	    	  assert.equal("Test Other", text.trim());
	      })
	      
	       //These buttons/sections SHOULD present on the Page
	      .isExisting("input[value='Add Related Party']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Related Parties Report']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Diagnosis']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='PRE 10/1/2015']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("[id$='admit__Alt1_Header']")
	      .then(function(isExist){
	    	  assert(isExist);
	      }) // Admission Related list
	      .isExisting("input[value='Add Allergy']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Immunization - Adult']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Print Report']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add PPD Skin Test']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Assistive Device']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Task']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Attach File']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      //These buttons should NOT exist on the Page
	      .isExisting("input[value='Add Agency Involved With Individual']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      
	      //These fields should NOT exist on the Page
	      .isExisting("label[name='Family Annual Income']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Family Native American Ancestry']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Family Native American Tribe']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Family Military Involvement']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Family Military Involvement Branch']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      
	      return client
	  }
	      
	});
