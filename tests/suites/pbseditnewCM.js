/*
 * Suite: pbseditnewCM
 * Operating Group: Care Meridian
 * Functionality Tested: PBS Edit and View Mode
 * CreatedDate: 01/15/2016
 * CreatedBy: Sravan Pinninti 
 * 
 * Comments: All CareMeridian States will use same flavor of PBS page and hence this suite
 * will cater the regression testing needs of CM PBS. This Suite DOES NOT have any
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
 *	i.Negative case to check the non-existence of certian buttons and Fields
 *
 *LastModifiedBy: Adam Vernatter 06/14/2016
 *LastModifiedReason: Updated for PBS view edit page split June 2016
 * 
 * 
 * 
 * 
 * 
 * 
 */

var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("pbseditnewCM", suiteTimeout, {
	  "Should validate the field entries on PBS page and validate the existense required buttons/related lists for CM": function(client, done) {
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
		  var pbsUrl;
		  
	    client = client
	    
	    .execUtil("convert_referral",{
			operatingGroup: "Care Meridian",
			flavor: "CA",
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
	      
		  .url()
		  .then(function (url){
			  pbsUrl = url.value;
		  })
		  
	      .click("a=iServe Home")
		  
	      //Search for the PBS using first name and last name
		  .then(function () { console.log('Starting PBS Search by Name'); })
	      .addValue("[id$=PbsSearchFirstName]",firstName) //Seeing weird behavior if FillinputText is used
	      .addValue("[id$=PbsSearchLastName]",lastName)
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
	      //Filter the Search result in the table by exactly inputting the name
		  .then(function () { console.log('Filtering PBS search by name'); })
	      .setValue("#searchResultDialog input[type='search']", lastName+', '+firstName+ " Served")
	      .pause(1000) //Waiting for a second so that j-query data table can search the record. No side effect of waiting as user will wait till the search returned the result
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(1) a")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
		  .then(function () { console.log('Select PBS after searching by name'); })
	      .waitForValue("a="+lastName+', '+firstName, defaultOperationTimeout)
	      .click("a="+lastName+', '+firstName)
		  .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
          .waitForVisible("input[value='Find']", defaultOperationTimeout)

          //Go back to home page and find the same PBS by choosing Program
		  .then(function () { console.log('Reload iServe home for PBS search by program'); })
          .windowHandleMaximize()
          .click("a=iServe Home")
		  .addValue("[id$=PbsSearchProgram]",'114160')
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
		  .then(function () { console.log('Filtering PBS search by program'); })
	      .setValue("#searchResultDialog input[type='search']", lastName+', '+firstName+ " Served")
	      .pause(1000) //Waiting for a second so that j-query data table can search the record. No side effect of waiting as user will wait till the search returned the result
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(1) a")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
		  .then(function () { console.log('Select PBS after searching by program'); })
	      .waitForValue("a="+lastName+', '+firstName, defaultOperationTimeout)
	      .click("a="+lastName+', '+firstName)
          .waitForVisible("input[value='Find']", defaultOperationTimeout)
		  
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
		  //Navigate to PBS page to edit record
		  .then(function(){
			this.url(pbsUrl)	  
		  })
		  .then(function () { console.log('Start PBS edit page testing'); })
		  .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      //Validate All the blank fields by inputting blank values and hitting Save
	      .windowHandleMaximize()
	      .chooseSelectOption("Race", "Caucasian")
	      .chooseSelectOption("Ethnicity", "North American")
	      .chooseSelectOption("Marital Status", "Divorced")
	      .fillInputText("Date of Birth", "")
	      .fillInputText("First Name", "")
	      .fillInputText("Middle Name", "")
	      .fillInputText("Last Name", "")
		  .then(function () { console.log('Check validation rule for first name'); })
	      
	      //.fillInputText("Does the person Identify with a gender other than legal gender selected?", "")
	      .scroll("input[value='Save']", 0, -300)
	      .click("input[value='Save']")
	      .waitForVisible("[id$='msgs'] .messageText", defaultOperationTimeout)
	      //.waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .getText("#msgs*=First Name: You must enter a value") // This is equivalent to assert
	      
	      .fillInputText("First Name", firstName)
	      .fillInputText("Middle Name", middleName)
		  .then(function () { console.log('Check validation rule for last name'); })
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Last Name: You must enter a value")
	      .fillInputText("Last Name", lastName)
		  .then(function () { console.log('Check validation rule for date of birth'); })
	      .click("input[value='Save']")
	      .getText("#msgs*=Date of Birth: You must enter a value")
	      .fillInputText("Date of Birth", "01/12/1988")
	     
	      .chooseSelectOption("Does the person Identify with a gender other than legal gender selected?","No")
	      .chooseSelectOption("Does the person Identify with a gender other than legal gender selected?","Yes")
	      .waitForVisible("input[id$='genderIdentity']", defaultOperationTimeout)
	      .addValue("input[id$='genderIdentity']", "")
		  .then(function () { console.log('Check validation rule for gender identity'); })
	      .scroll("input[value='Save']", 0, -300)
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Gender Identity is required when the person identifies with a gender other than the legal gender")
	      .fillInputText("Gender Identity", "Test")
		  .scroll("input[value='Save']", 0, -300)
	      .click("input[value='Save']")
	      
		  .then(function () { console.log('Fill in remaining fields'); })
	      .waitForVisible("input[type='submit'][value='Edit Person Being Served']", defaultOperationTimeout)
	      .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      .fillInputText("Mailing Street 1", "123 Something Street")
	      .fillInputText("Mailing Street 2", "apt. 456")
	      .fillInputText("Mailing City", "Some City")
	      .fillInputText("Mailing Zip/Postal Code","23456")
	      .fillInputText("Mailing County", "Orange County")
	      .fillInputText("Home Phone", "6090210")
	      .fillInputText("Email", "someone@something.com")

	      
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
		  .then(function () { console.log('Validate fields on view screen'); })
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
		  .then(function () { console.log('Validate buttons are visible'); })
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
		  .then(function () { console.log('Validate the buttons that should not be present on the page'); })
	      .isExisting("input[value='Add Agency Involved With Individual']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      
	      //These fields should NOT exist on the Page
		  .then(function () { console.log('Validate the fields that should not be present on the page'); })
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
	      
	      .isExisting("label[name='SSI']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Financial MCD']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Financial SS']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Funding Mechanism']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Life Insurance Information']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='RSDI']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Checking Account Location']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Savings Account location']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      .isExisting("label[name='Prepaid Burial Information']")
	      .then(function(isExist){
	    	  assert(!isExist);
	      })
	      
	      return client
	  }
	      
	});