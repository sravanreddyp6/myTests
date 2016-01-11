var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs = require('fs');
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsGaPBSeditnew", suiteTimeout, {
	  "should be able to update and Save the PBS and related lists successfully": function(client, done) { 
		  var user = users["HS_GA_Referral_Intaker"];
		//Variables 
		  var today = new Date().getMilliseconds() + new Date().getDate();
		  var firstName = 'Regression'+today;
		  var lastName = 'Hastings PBS'+today;
		  var middleName = 'test'+today;
	    return client
	    //login
	      .logInAs(users["HS_GA_Referral_Intaker"])
	      .click("a=Create New Referral")
	      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
	      .fillInputText("First Name", firstName)
	      .chooseSelectOption("Race", "Caucasian")
	      .fillInputText("Middle Name", middleName)
	      .chooseSelectOption("Ethnicity", "North American")
	      .fillInputText("Last Name", lastName)
	      .chooseSelectOption("Marital Status", "Divorced")
	      .fillInputText("Date of Birth", "7/7/1970")  // not working yet because there are 2 DOB fields on the page
	      .chooseSelectOption("Primary Language", "English")
	      .click("input[id$=nonverb]")
	      .fillInputText("Age", "25")
	      .chooseSelectOption("Highest Level of Education", "Graduate School")
	      .chooseSelectOption("Gender", "Male")
	      .fillInputText("Additional Information / Comments", "Really hateful")
	      .fillInputText("Mailing Street 1", "123 Something Street")
	      .fillInputText("Mailing Street 2", "apt. 456")
	      .fillInputText("Mailing City", "Georgia")
	      .chooseSelectOption("Mailing State/Province", "Georgia")
	      .fillInputText("Mailing Zip/Postal Code", "23456")
	      .fillInputText("Mailing County", "Georgia County")
	      .setValue("input[id$=Perm_Phone]", "6090210")
	      .setValue("input[id$=Perm_Email]", "someone@something.com")
	      .click("input[value='Create Person Being Referred']")
	      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
	      //Adding Related Party on referral creation
	      .click("input[value='Add Related Party']")
	      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
	      .fillInputText("Party Name", "Party")
	      .click("span[id$=relatedPartyModal] input[value='Cancel']")
	      .click("input[value='Add Related Party']")
	      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
	      .fillInputText("Party Name", "Party")
	      .chooseSelectOption("Type", "Caregiver")
	      .fillInputText("Address", "Somewhere")
	      .setValue("input[id$=relatedPartyEntry_Email]", "Someone@something.com")
	      .fillInputText("Phone 1", "8888888")
	      .fillInputText("Phone 2", "7777777")
	      .chooseSelectOption("Phone 1 Type", "Home")
	      .chooseSelectOption("Phone 2 Type", "Cell")
	      .setValue("span[id$=relatedPartyModal] textarea[id$=relatedPartyEntry_Comments]","This is a test")
	      .selectByValue("span[id$=relatedPartyModal] select[id$=relatedPartyEntry_Status]", "Active")
	      .click("span[id$=relatedPartyModal] input[value='Save']")
	      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
	      .chooseSelectOption("Referral Status", "Active")
	      .chooseSelectOption("Referral Source Type", "Family")
	      .waitForActionStatusDisappearance("statusRefSourceType", defaultOperationTimeout)
	      .fillInputText("Referral Source", "Mentor")
	      .fillInputText("Referrer Name", "Obi-wan Kennobi")
	      .fillInputText("Referrer Phone Number", "586356")
	      .fillInputText("Case Manager Name", "Qui Gon Jinn")
	      .fillInputText("Billing ID", "something")
	      .fillInputText("Case Manager Phone", "8675309")
	      .fillInputText("Current Representative Payee", "Master Yoda")
	      .chooseSelectOption("Program Category", "ARY")
	      .doubleClick("select[title='Service Line - Available'] option[value='0']")
	      .doubleClick("select[title='Services Requested - Available'] option[value='0']")
	      .fillInputText("Reason for Referral", "Test")
	      .fillInputText("Update Notes", "Test")
	      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
	      .click("a[id$=originlookup]")
	      .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
	      .setValue("input[id$=originstate]","GA")
	      .click("span[id$=searchDialog2] input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
	      //.click("span[id$=searchDialog] a:first")
	      .element("span[id$=searchDialog2] a")
	      .then(function (el) {
	      	return this.elementIdClick(el.value.ELEMENT);
	      })
	      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
	      .click("input[value='Add Location']")
	      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	      .click("a[id$=aliaslookup]")
	      .waitForVisible("input[value='First']", defaultOperationTimeout)
	      .setValue("input[id$=addlocationstate]","GA")
	      .click("span[id$=searchDialog] input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
	      //.click("span[id$=searchDialog] a:first")
	      .element("span[id$=searchDialog] a")
	      .then(function (el) {
	      	return this.elementIdClick(el.value.ELEMENT);
	      })
	      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	      .selectLookup("User Assigned")
	      .switchToNextWindow()
	      .waitForVisible("#searchFrame", defaultOperationTimeout)
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
	      .click("tr.dataRow th a:first-child")
	      .switchToNextWindow()
	      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	      .selectByValue("select[id$=locationEntry_Status]", "Active")
	      .click("span[id$=ReferralLocationModal] input[value='Save']")
	      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	      //Adding Agency on referral creation
	      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
	      .click("input[value='Add Agency Involved With Individual']")
	      .fillInputText("Agency Name:", "test")
	      .click("span[id$=agencyModal] input[value='Cancel']")
	      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
	      .click("input[value='Add Agency Involved With Individual']")
	      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
	      .pause(3000)
	      .fillInputText("Agency Name:", "test")
	      .waitUntil(function() {
	  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
	    		return text === ''
	  		})
		   }, defaultOperationTimeout)
		   .pause(3000)
	      .fillInputText("Agency Name:", "test")
	      .fillInputText("Address:", "404 test street")
	      .fillInputText("Phone Number:", "8008378")
	      .fillInputText("Reason for Involvement:", "test")
	      .click("span[id$=agencyModal] input[value='Save']")
	      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	      .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
	      .click("input[value='Add Funding Source']")
	      .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
	      .chooseSelectOption("Funding Source", "Medicaid")
	      .fillInputText("Funding Source ID", "test")
	      .chooseSelectOption("Service Being Funded", "Host Home")
	      .selectByValue("span[id$=FundingSourceModal] select[id$=fundingEntry_Status]", "Pending Approval")
	      .setValue("span[id$=FundingSourceModal] textarea[id$=fundingEntry_comment]", "test")
	      .click("span[id$=FundingSourceModal] input[value='Save']")
	      .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
	      .click("input[value='Save Referral']")
      
      
	      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
	      .url()
	      .then(function (url) {
	        assert.include(url.value, "referral2");
	      })
	      
	      .click("input[value='Convert']")
	      
	      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
	      .click("input[value='Confirm Conversion']")
	      //After Conversion
	      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      
	      .click("a=ESD Home")
	      
	      
	    //Search for the PBS using first name and Last name
	      .addValue("[id$=PbsSearchFirstName]",firstName) //Seeing weird behavior if FillinputText is used
	      .addValue("[id$=PbsSearchLastName]",lastName)
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
	      
	      //Filter the Search result in the table by exactly inputting the name
	      .setValue("#searchResultDialog input[type='search']", lastName+', '+firstName+ " Served")
	      .pause(1000) //Waiting for a second so that j-query data table can search the record. No side effect of waiting as user will wait till the search returned the result
	      //.waitForValue("a=Vader835, Darth835", defaultOperationTimeout)
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(1) a")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      //.waitForVisible("table#serviceAssignmentTable", defaultOperationTimeout)
	      //.click("table#serviceAssignmentTable tbody tr:nth-child(1) td:nth-child(1) a")
	      //Navigate to PBS view Page
	      .waitForValue("a="+firstName+' '+lastName, defaultOperationTimeout)
	      .click("a="+firstName+' '+lastName)
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          
          //Click on Home page tab so we can come to the same page from Recently viewed Person Being Served
          .click("a=ESD Home")
          .click("a=My Recently Viewed Persons Being Served")
          .waitForVisible("input[value='Refresh']", defaultOperationTimeout)
         // .click("table#persons_table tbody tr:nth-child(1) td:nth-child(1) a")
          .click("a="+lastName+', '+firstName)
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          
          .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      //Validate All the blank fields by inputting blank values and hitting Save
	      .windowHandleMaximize()
	      .fillInputText("First Name", "")
	      .fillInputText("Middle Name", "")
	      .fillInputText("Last Name", "")
	      .fillInputText("Date of Birth", "")
	      //.fillInputText("Does the person Identify with a gender other than legal gender selected?", "")
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
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Gender Identity is required when the person identifies with a gender other than the legal gender")
	      .fillInputText("Gender Identity", "Test")
	      .click("input[value='Save']")
	      
	      .waitForVisible("input[type='submit'][value='Edit Person Being Served']", defaultOperationTimeout)
	      .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
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
	      .chooseSelectOption("Family Annual Income","15,000 or under")
	      .selectCheckbox("Family Native American Ancestry")
	      .waitForActionStatusDisappearance("statusnativeancestry", defaultOperationTimeout)
	      .chooseSelectOption("Family Military Involvement","Active")
	      .pause(1000)
	      .chooseSelectOption("Family Military Involvement Branch","Navy")
	      .fillInputText("Family Prior Military Involvement Date", "1/6/2000")
	      .scroll("[id$='SavePBSId']",0,-300) //move up to save button
	      .click("input[value='Save']")
	      .getText("#msgs*=Family Native American Tribe: You must enter a value")
	      .scroll(0,-300) //move down
	      .fillInputText("Family Native American Tribe", "Test")
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
	    	  assert.equal("27 Years", text.trim()); // Need to make it dynamic
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
	    	  assert.equal("North American", text.trim());
	      })
	      .getOutputText("Marital Status")
	      .then(function(text){
	    	  assert.equal("Divorced", text.trim());
	      })
	     /* .getOutputText("Primary Language")
	      .then(function(text){
	    	  assert.equal("English", text.trim());
	      })*/
	      .getOutputText("Medicaid ID")
	      .then(function(text){
	    	  assert.equal("test", text.trim());
	      })
	      .getOutputText("Billing ID")
	      .then(function(text){
	    	  assert.equal("something", text.trim());
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
	    	  assert.equal("Georgia", text.trim());
	      })
	      .getOutputText("Mailing Zip/Postal Code")
	      .then(function(text){
	    	  assert.equal("23456", text.trim());
	      })
	      .getOutputText("Mailing County")
	      .then(function(text){
	    	  assert.equal("Georgia County", text.trim());
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
	      .getOutputText("Guardianship Type")
	      .then(function(text){
	    	  assert.equal("Self", text.trim());
	      })
	      .getOutputText("Family Annual Income")
	      .then(function(text){
	    	  assert.equal("15,000 or under", text.trim());
	      })
	      .getCheckboxOutput("Family Native American Ancestry")
	      .then(function(isChecked){
	    	  assert(isChecked);
	      })
	      .getOutputText("Family Native American Tribe")
	      .then(function(text){
	    	  assert.equal("Test", text.trim());
	      })
	      .getOutputText("Family Military Involvement")
	      .then(function(text){
	    	  assert.equal("Active", text.trim());
	      })
	      .getOutputText("Family Military Involvement Branch")
	      .then(function(text){
	    	  assert.equal("Navy", text.trim());
	      })
	      	
	  }
	  
	});