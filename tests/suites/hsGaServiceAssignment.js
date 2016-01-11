var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("hsGaServiceAssignment", suiteTimeout, {
  "should Create/Edit/View/Close/promptFullDischarge a Hastings GA Service Assignment successfully": function(client, done) {
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["HS_GA_Referral_Intaker"])
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .fillInputText("First Name", "Darth" + today)
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freaking" + today)
      .chooseSelectOption("Ethnicity", "North American")
      .fillInputText("Last Name", "Vader" + today)
      .chooseSelectOption("Marital Status", "Divorced")
      .fillInputText("Date of Birth", "7/7/1970")  
      .chooseSelectOption("Primary Language", "English")
      .click("input[id$=nonverb]")
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
      .fillInputText("Anticipated Admission DateTime", "12/30/2015 16:00")
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
      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
      .click("input[value='Add Agency Involved With Individual']")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .timeoutsImplicitWait(3000)
      .fillInputText("Agency Name:", "test")
      .waitUntil(function() {
              return this.getText("[id$=agencyEntry_Name]").then(function(text) {
              return text === ''
              })
          }, defaultOperationTimeout)
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
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")     
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
      
      //Navigating to Admission page
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a") 
      
      //Service Assignment Regression Starts From here 
	  //Assessment-Only Service Assignment: wrote it without a corresponding test case
  
      //Cancel SA Assmnt-Only
  	  .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")      
	  .waitForVisible("span[id$=buttons] input[value='Cancel']", defaultOperationTimeout)
	  .click("span[id$=buttons] input[value='Cancel']")
	  
      //Creating SA Assmnt-Only with Active Status and Editing to Created in Error
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")    
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
      
  	  //Creating SA Assmnt-Only with Active Status and Editing to Inactive(Close SA)
  	  .click("[id$=admlink] a")
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")     
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
      .fillInputText("End Date", "1/7/2016") 
      .chooseSelectOption("Was Child Service or Permanency Goal met at End of Service?", "Yes")
      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Model", "MENTOR")
      .waitForActionStatusDisappearance("SaveStatus1", defaultOperationTimeout)
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
  
      // Standard Service: Test case 15: Cancel SA
      .click("[id$=admlink] a")
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
           

  }
});

