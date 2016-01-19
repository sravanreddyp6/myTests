/*
 * Suite: pbseditnewRW
 * Operating Group: Redwood
 * Functionality Tested: PBS Edit and View Mode
 * CreatedDate: 01/19/2016
 * CreatedBy: Sravan Pinninti 
 * 
 * Comments: All RW States will use same flavor of PBS page and hence this suite
 * will cater the regression testing needs of NR PBS. This Suite DOES NOT have any
 * dependency on other suites.
 * 
 * Expected Functionality:
 *	a.Creation of Referral
 *	b.Conversion
 *	c.Landing on PBS page
 *	d.Navigating to PBS from Home page By searching first and Last Name
 *	e.Navigating to PBS from Home page by choosing the Alias
 *	f.Validation Rules in PBS edit mode
 *	g.Field value assertion b/w edit and View
 *	h.Checking the existence of Required buttons and Related lists
 *	i.Negative case to check the non-existence of certain buttons and Fields
 *
 *LastModifiedBy:
 *LastModifiedReason:
 * 
 * 
 * 
 * 
 * 
 * 
 */

var assert = require('chai').assert;
var expect = require('chai').expect;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("pbseditnewNR", suiteTimeout, {
	"Should validate the field entries on PBS page and validate the existense required buttons/related lists for Redwood": function(client, done) {
		var today = new Date().getMilliseconds() + new Date().getDate();
		var firstName = 'Regression '+today;
		var lastName = 'RW AZ PBS '+today;
		var middleName = 'test '+today;
		var birthDate = "1/1/1970";
		var birthdateString = "1970-01-01";
		var age = function(birthdateString){
			 var birthday = new Date(birthdateString);
			 return~~ ((Date.now() - birthday) / (31557600000)) + ' Years';
		}
		var alias; 

	client = client
		
	.execUtil("convert_referral",{
		operatingGroup: "Redwood",
		flavor: "AZ",
		hooks:{
			"create_referral_before_save_referral": function (client) {
				return client
				.fillInputText("First Name",firstName)
			    .fillInputText("Last Name",lastName)
			    .fillInputText("Middle Name",middleName)
				.getOutputTextFromInput("Alias")
			    .then(function(text){
			    	 alias = text;
			     })
					    
			}
		}
	})
	
	     .click("a=ESD Home")
	    //Search for the PBS using first name and Last name
	      .addValue("[id$=PbsSearchFirstName]",firstName) //Seeing weird behavior if FillinputText is used
	      .addValue("[id$=PbsSearchLastName]",lastName)
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
	      
	      //Filter the Search result in the table by exactly inputting the name
	      .then(function(){
	    	  return this.setValue("#searchResultDialog input[type='search']", lastName+', '+firstName+ " Served");
	      })
	      
	      .pause(1000) //Waiting for a second so that j-query data table can search the record. No side effect of waiting as user will wait till the search returned the result
	      //.waitForValue("a=Vader835, Darth835", defaultOperationTimeout)
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(1) a")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      //Navigate to PBS view Page
	      .waitForValue("a="+firstName+' '+lastName, defaultOperationTimeout)
	      .click("a="+firstName+' '+lastName)
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          
          //Go back to home page and find the same PBS by choosing Program
          .windowHandleMaximize()
          .click("a=ESD Home")
          //.waitForVisible("[id$='selectprograms']", defaultOperationTimeout)
          .then(function(){
        	  return this.selectByValue("[id$='selectprograms']", alias);
          })
          
	      
	   //Below function makes sure to find the PBS even if the table is paginated
	    var choosePbs = function (client) {
	    	client.pause(2000)
	    	return client.isExisting("a="+firstName+' '+lastName)
            .then(function(exist){
        	  if(exist){
        		  return client.click("a="+firstName+' '+lastName)
        	  }else{
        		  client.scroll("[id$='serviceAssignmentTable_next']", 0 -700)
        		  .then(function(){
        			  return client.click("[id$='serviceAssignmentTable_next']")
        			  .then(function(){
	        			  return choosePbs(client);
        			 })
        		  }) 
        	  }
          })
	    };
	    
	    client = choosePbs(client)
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          //Click on Home page tab and find the PBS from recently viewed person being served list view
          .click("a=ESD Home")
          .click("a=My Recently Viewed Persons Being Served")
          .waitForVisible("input[value='Refresh']", defaultOperationTimeout);
	    
	    var choosePBSFromListView = function (client) {
	    	client.pause(2000)
	    	return client.isExisting("a="+lastName+', '+firstName)
	    	.then(function(exist){
	    		if(exist){
	    			console.log('in existing');
	    			return client.click("a="+lastName+', '+firstName)
	    		}else{
	    			console.log('in non existing');
	    			return client.click("[id$=persons_table_paginate] .paginate_enabled_next")
	    			.then(function(){
	    				return choosePBSFromListView(client);
	    			})
	    		}
	    	})
	    };
	   
        
	    client = choosePBSFromListView(client)
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      //Validate All the blank fields by inputting blank values and hitting Save
	      .windowHandleMaximize()
	      .chooseSelectOption("Race", "Caucasian")
	      .chooseSelectOption("Ethnicity", "North American")
	      .chooseSelectOption("Marital Status", "Divorced")
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
	      .fillInputText("Date of Birth", birthDate)
	     
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
	      .fillInputText("Medicaid ID","test")
	      .fillInputText("Billing ID","Some random BillingId")
	      .chooseSelectOption("Billing System","AVATAR")
	      .fillInputText("Other ID","Some random otherId")
	      .fillInputText("Other ID Description","Some random description")
	      
	      .fillInputText("Mailing Street 1", "123 Something Street")
	      .fillInputText("Mailing Street 2", "apt. 456")
	      .fillInputText("Mailing City", "Some City")
	     // .chooseSelectOption("Mailing Country", "United States")
	      //.chooseSelectOption("Mailing State/Province", "Illinois")
	      .fillInputText("Mailing Zip/Postal Code","23456")
	      .fillInputText("Mailing County", "Georgia County")
	      .fillInputText("Home Phone", "6090210")
	      .fillInputText("Email", "someone@something.com")
	    		  
	      .fillInputText("Other Street 1", "Test Street")
	      .fillInputText("Other Street 2", "Test steet 2")
	      .fillInputText("Other City", "Test City")
	      .fillInputText("Other Zip/Postal Code","12345")
	      .fillInputText("Other County", "Test County")
	      .fillInputText("Other Phone", "123-234-5555")
	      .fillInputText("Other Contact Information", "Nothing much to fill here")
	      
	      .fillInputText("SSI","20")
	      .fillInputText("Financial MCD","20")
	      .fillInputText("Financial SS","20")
	      .fillInputText("Funding Mechanism","Test Funding Mechanism")
	      .fillInputText("Life Insurance Information","Test Life Insurance Information")
	      .fillInputText("RSDI","20")
	      .fillInputText("Checking Account Location","Test Checking Account Location")
	      .fillInputText("Savings Account location","Test Savings Account location")
	      .fillInputText("Prepaid Burial Information","Test Prepaid Burial Information")
	      
	      
	      
	      
	      .fillInputText("Family Members / Other / Notes", "Test Notes")
	      .scroll(0,-200) //move down
	      .chooseSelectOption("Guardianship Type","Partial Guardianship/Conservatorship") 
	      .waitForVisible("select[id$='partialGuardianShip_unselected']",defaultOperationTimeout)
	      .chooseMultiSelectOption("Partial Guardianship/Conservatorship", ["Financial"])
	      .selectCheckbox("VIP Indicator")
	     
//	      .chooseSelectOption("Family Annual Income","15,000 or under")
//	      .selectCheckbox("Family Native American Ancestry")
//	      .waitForActionStatusDisappearance("statusnativeancestry", defaultOperationTimeout)
//	      .chooseSelectOption("Family Military Involvement","Active")
//	      .pause(1000)
//	      .chooseSelectOption("Family Military Involvement Branch","Navy")
//	      .fillInputText("Family Prior Military Involvement Date", "1/6/2000")
//	      .scroll("[id$='SavePBSId']",0,-300) //move up to save button
//	      .click("input[value='Save']")
//	      .getText("#msgs*=Family Native American Tribe: You must enter a value")
//	      .scroll(0,-300) //move down
//	      .fillInputText("Family Native American Tribe", "Test")
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
	    	  assert.equal(birthDate, text.trim());
	      })
	      .getOutputText("Age")
	      .then(function(text){
	    	  assert.equal(age(birthDate), text.trim()); //dynamic Calculation
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
	    	  assert.equal("Some random BillingId", text.trim());
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
	      .getOutputText("SSI")
	      .then(function(text){
	    	  assert.equal("$20.00", text.trim());
	      })
	      .getOutputText("Financial MCD")
	      .then(function(text){
	    	  assert.equal("$20.00", text.trim());
	      })
	      .getOutputText("Financial SS")
	      .then(function(text){
	    	  assert.equal("$20.00", text.trim());
	      })
	      .getOutputText("Funding Mechanism")
	      .then(function(text){
	    	  assert.equal("Test Funding Mechanism", text.trim());
	      })
	      .getOutputText("Life Insurance Information")
	      .then(function(text){
	    	  assert.equal("Test Life Insurance Information", text.trim());
	      })
	      .getOutputText("RSDI")
	      .then(function(text){
	    	  assert.equal("$20.00", text.trim());
	      })
	      .getOutputText("Checking Account Location")
	      .then(function(text){
	    	  assert.equal("Test Checking Account Location", text.trim());
	      })
	      .getOutputText("Savings Account location")
	      .then(function(text){
	    	  assert.equal("Test Savings Account location", text.trim());
	      })
	      .getOutputText("Prepaid Burial Information")
	      .then(function(text){
	    	  assert.equal("Test Prepaid Burial Information", text.trim());
	      })
	      .getOutputText("Guardianship Type")
	      .then(function(text){
	    	 // assert.equal("Partial Guardianship/Conservatorship", text.trim());
	    	  expect(text).to.contain('Partial Guardianship/Conservatorship');
	      })
	      .getOutputText("Partial Guardianship/Conservatorship")
	      .then(function(text){
	    	  //assert.equal("Financial", text.trim());
	    	  expect(text).to.contain('Financial');
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
	      .isExisting("input[value='Add Agency Involved With Individual']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Diagnosis']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("[id$='admit__Alt1_Header']")
	      .then(function(isExist){
	    	  assert(isExist);
	      }) // Admission Related list
	      .isExisting("input[value='PRE 10/1/2015']")
	      .then(function(isExist){
	    	  assert(isExist);
	      })
	      .isExisting("input[value='Add Allergy']")
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
	      //These Buttons should NOT be present on the Page
	      .isExisting("input[value='Add Immunization - Adult']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("input[value='Add PPD Skin Test']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("input[value='Add Assistive Device']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      
	      //These Fields should NOT be present on the Page for Hastings
	      .isExisting("label[name='UCI ID']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Code Status']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Advance Directives']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Advance Directives Attached']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	
		return client
		
	}
});
