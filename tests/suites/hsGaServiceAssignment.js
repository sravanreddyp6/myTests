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
          
          //Going to Admission page
          .scroll("[id$=adminsId]", 0 , -300)
          .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a") 
          
          //Service Assignment Regression Starts From here 
      
		   // Standard Service: Test case 15: Cancel SA
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
	      .getSelectOptions('Model')
	      .then(function(modl) {
	        assert.deepEqual([
	          "--None--", "MENTOR", "FCT", "Family Vistas Intensive In Home"
	        ], modl);
	      })
	      .getSelectOptions('Child Service Goal at Start of Service')
	      .then(function(sgSOS) {
	        assert.deepEqual([
	          "", "Assessment", "Community Integration", "Complete Secondary Education", "Crisis Intervention", "Family Preservation", "GED", 
	          "Independent Living/Emancipation", "Job Readiness", "Medical Respite", "Prevent Placement Disruption", "Reduction of Presenting Behaviors",
	          "Remain in the Community", "Stay in School", "Transition to Adult Services" 
	          
	        ], sgSOS);
	      })
	      .getSelectOptions('Educational Involvement at Start of Service')
	      .then(function(eiSOS) {
	        assert.deepEqual([
	          "", "Enrolled, Attending Regularly", "Enrolled, Truant Regularly", "Not Enrolled", "Unknown"
	        ], eiSOS);
	      })
	      .getSelectOptions('Highest Level of Education at Start of Service')
	      .then(function(educationLevels) {
	        assert.deepEqual([
	          "", "1 Year Preschool", "2+ Years Preschool", "Kindergarten", "Grade 1", "Grade 2",
	          "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10",
	          "Grade 11", "Grade 12", "1 Year College", "2 Years College", "3 Years College",
	          "4+ Years College", "Graduate School", "1 Year Vocational/Technical",
	          "2 Years Vocational/Technical", "Elementary School Special Education",
	          "Middle School Special Education", "High School Special Education",
	          "1 Year Special Education", "2+ Years Special Education",
	          "Post Secondary Transition Services", "None", "Unknown"
	        ], educationLevels);
	      })
	      .fillInputText("Start Date", "01/07/2016 13:00") 
	      .click(".lookupIcon")
	      //.click("span[id$=sl] a")
	      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
	      .setValue("input[id$=nameFilter]","011030")
	      .click("input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
	      //.element("span[id$=searchDialog] a")
	      .element("span[id$=searchDialog] tr:first-child a")
	      .then(function (el) {
	      	return this.elementIdClick(el.value.ELEMENT);
	      })
	      .chooseSelectOption("Child Service Goal at Start of Service", "Assessment")
	      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
	      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
	      .chooseSelectOption("Model", "FCT")
	      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
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
	      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
	      .click("span[id$=buttons] input[value='Save']")
	      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
	      
	       //Creating SA with Active Status and Editing to Inactive(Close SA)
	      .click("[id$=admlink] a")
	      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
	      .scroll("input[value='New Standard Service']", 0 , -300)
	      .click("input[value='New Standard Service']")      
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .fillInputText("Start Date", "01/07/2016 13:00") 
	      .click(".lookupIcon")
	      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
	      .setValue("input[id$=nameFilter]","011030")
	      .click("input[value='Search!']")
	      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
	      .element("span[id$=searchDialog] a")
	      .then(function (el) {
	      	return this.elementIdClick(el.value.ELEMENT);
	      })
	      .getSelectOptions('Episode')
	      .then(function(epsd) {
	        assert.deepEqual([
	          "", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
	           "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
	           "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"
	        ], epsd);
	      })      
	      .chooseSelectOption("Model", "FCT")
	      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
	      .chooseSelectOption("Child Service Goal at Start of Service", "Assessment")
	      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
	      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
	      .chooseSelectOption("Episode", "1")
	      .click("span[id$=buttons] input[value='Save']")
	      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
	      .click("input[value='Edit']")
	      .chooseSelectOption("Service Assignment Status", "Inactive")
	      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
	      .getSelectOptions('Was Child Service or Permanency Goal met at End of Service?')
	      .then(function(sEnd) {
	        assert.deepEqual([
	          "", "Yes", "No"
	        ], sEnd);
	      })
	      .getSelectOptions('Educational Involvement at End of Service')
	      .then(function(eoSOS) {
	        assert.deepEqual([
	          "", "Enrolled, Attending Regularly", "Enrolled, Truant Regularly", "Not Enrolled", "Unknown"
	        ], eoSOS);
	      })
	      .getSelectOptions('Was dissatisfaction the reason for service ending?')
	      .then(function(sEnd) {
	        assert.deepEqual([
	          "", "Yes", "No"
	        ], sEnd);
	      })
	      .fillInputText("End Date", "1/7/2016") 
	      .chooseSelectOption("Was Child Service or Permanency Goal met at End of Service?", "Yes")
	      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
	      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
	      /* .click("span[id$=buttons] input[value='Save']")
	      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
	      //Negative Testing
	      getText("#msgs*=An FCT Service Assignment cannot be made inactive until a Service Assignment Closure has been completed and approved for the Service Assignment")
	      */
	      .chooseSelectOption("Model", "MENTOR")
	      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
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
	      .getSelectOptions('Highest Level of Education at End of Service')
	      .then(function(hlEOS) {
	        assert.deepEqual([
	          "", "1 Year Preschool", "2+ Years Preschool", "Kindergarten", "Grade 1", "Grade 2",
	          "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10",
	          "Grade 11", "Grade 12", "1 Year College", "2 Years College", "3 Years College",
	          "4+ Years College", "Graduate School", "1 Year Vocational/Technical",
	          "2 Years Vocational/Technical", "Elementary School Special Education",
	          "Middle School Special Education", "High School Special Education",
	          "1 Year Special Education", "2+ Years Special Education",
	          "Post Secondary Transition Services", "None", "Unknown"
	        ], hlEOS);
	      })
	      .fillInputText("End Date", "1/7/2016") 
	      .chooseSelectOption("Child Service Goal at Start of Service", "Assessment")
	      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
	      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
	      .chooseSelectOption("Was Child Service or Permanency Goal met at End of Service?", "Yes")
	      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
	      .chooseSelectOption("Highest Level of Education at End of Service", "Graduate School")
	      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
	      .chooseSelectOption("Model", "MENTOR")
	      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
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
	        assert.equal("1/7/2016", enddate.trim());
	      })
	      .getOutputText("Was dissatisfaction the reason for service ending?")
	      .then(function (rservEnd) {
	        assert.equal("No", rservEnd.trim());
	      })
	      .getOutputText("Child Service Goal at Start of Service")
	      .then(function (csSOS) {
	        assert.equal("Assessment", csSOS.trim());
	      })
	      .getOutputText("Educational Involvement at Start of Service")
	      .then(function (eSOS) {
	        assert.equal("Enrolled, Attending Regularly", eSOS.trim());
	      })
	      .getOutputText("Highest Level of Education at End of Service")
	      .then(function (hlEOS) {
	        assert.equal("Graduate School", hlEOS.trim());
	      })
	      .getOutputText("Highest Level of Education at End of Service")
	      .then(function (higheEOS) {
	        assert.equal("Graduate School", higheEOS.trim());
	      })
	      .getOutputText("Educational Involvement at End of Service")
	      .then(function (eduEOS) {
	        assert.equal("Enrolled, Attending Regularly", eduEOS.trim());
	      })
	      .getOutputText("Model")
	      .then(function (mdl) {
	        assert.equal("MENTOR", mdl.trim());
	      })
     
	     /* 
	     Note: This file is dependent on Hasting GA Referral Convertion
	     For PBS Search: Need to change the firstname(l:19), lastname(l:20), lines: 26, 35, 36  
	     For SA: a) Start Date(Based on admission start time which is given in the refconvertion, l:91, l:130 
	             b) End Date lines: 177, 218, 242(in assert statement also).
	     */
           
  }
});