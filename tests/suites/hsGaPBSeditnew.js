var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));

testSuite("hsGaPBSeditnew", suiteTimeout, {
	  "should be able to update and Save the PBS and related lists successfully": function(client, done) {
	    return client
	    //login
	      .logInAs(users["HS_GA_Referral_Intaker"])
	      
	    //Search for the PBS using first name and Last name
	      .addValue("[id$=PbsSearchFirstName]","Darth835") //Seeing weird behavior if FillinputText is used
	      .addValue("[id$=PbsSearchLastName]","Vader835")
	      .click("input[type='submit'][value='Find']", defaultOperationTimeout)
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .waitForVisible("span[id$=searchResultDialog]", defaultOperationTimeout)
	      
	      //Filter the Search result in the table by exactly inputting the name
	      .setValue("#searchResultDialog input[type='search']", "Vader835, Darth835 Served")
	      .timeoutsImplicitWait(1000) //Waiting for a second so that j-query data table can search the record. No side effect of waiting as user will wait till the search returned the result
	      //.waitForValue("a=Vader835, Darth835", defaultOperationTimeout)
	      .click("table[id$=searchTable] tbody tr:nth-child(1) td:nth-child(1) a")
	      //.click("a=Vader835, Darth835")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      //.waitForVisible("table#serviceAssignmentTable", defaultOperationTimeout)
	      //.click("table#serviceAssignmentTable tbody tr:nth-child(1) td:nth-child(1) a")
	      //Navigate to PBS view Page
	      .waitForValue("a=Darth835 Vader835", defaultOperationTimeout)
	      .click("a=Darth835 Vader835")
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          
          //Click on Home page tab so we can come to the same page from Recently viewed Person Being Served
          .click("a=ESD Home")
          .click("a=My Recently Viewed Persons Being Served")
          .waitForVisible("input[value='Refresh']", defaultOperationTimeout)
          .click("table#persons_table tbody tr:nth-child(1) td:nth-child(1) a")
          .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
          
          .click("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      
	      //Validate All the blank fields by inputting blank values and hitting Save
	      .fillInputText("First Name", "")
	      .fillInputText("Last Name", "")
	      .fillInputText("Date of Birth", "")
	      //.fillInputText("Does the person Identify with a gender other than legal gender selected?", "")
	      .click("input[value='Save']")
	      .waitForVisible("[id$='msgs'] .messageText", defaultOperationTimeout)
	      //.waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .getText("#msgs*=First Name: You must enter a value") // This is equivalent to assert
	      
	      .fillInputText("First Name", "Darth835")
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getText("#msgs*=Last Name: You must enter a value")
	      .fillInputText("Last Name", "Vader835")
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
	      .timeoutsImplicitWait(1000)
	      .chooseSelectOption("Family Military Involvement Branch","Navy")
	      .fillInputText("Family Prior Military Involvement Date", "1/6/2000")
	      .scroll("[id$='SavePBSId']",0,-300) //move upto save buttton
	      .click("input[value='Save']")
	      .getText("#msgs*=Family Native American Tribe: You must enter a value")
	      .scroll(0,-300) //move down
	      .fillInputText("Family Native American Tribe", "Test")
	      .scroll("[id$='SavePBSId']",0,-300) //move upto save buttton
	      .click("input[value='Save']")
	      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      
	  }
	  
	});