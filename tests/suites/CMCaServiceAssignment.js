var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CMCaServiceAssignment", suiteTimeout, {
  "should Create/Edit/View/Close/promptFullDischarge a Care Meridian CA Service Assignment successfully": function(client, done) {
    var user = users["CM_DON"];
    var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(user)
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .fillInputText("First Name", "Darth" + today)
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freakin" + today)
      .chooseSelectOption("Ethnicity", "Unknown")
      .fillInputText("Last Name", "Vader" + today)
      .chooseSelectOption("Marital Status", "Divorced")
      .fillInputText("Date of Birth", "7/7/1970")
      .chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")
      .fillInputText("Additional Information / Comments", "Really hateful")
      .chooseSelectOption("Mailing State/Province", "California")
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
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForVisible("span[id$=ReferralAdmissionLocationModal] input[value='Save and Continue']", defaultOperationTimeout)
      .click("span[id$=ReferralAdmissionLocationModal] input[value='Save and Continue']")
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      
      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")     
      
       //Service Assignment Regression Starts From here 
       // Test case 15: Cancel Service Assignment
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
      .fillInputText("Start Date", "01/04/2016 15:00") 
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","114020")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      .element("span[id$=searchDialog] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .getSelectOptions('Service Assignment Status')
      .then(function(saStatus) {
        assert.deepEqual([
          "", "Active", "Inactive", "Created in Error"
        ], saStatus);
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
      .chooseSelectOption("Service Assignment Status", "Created in Error")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .fillInputText("Specify Error", "Testing") 
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("[id$=admlink] a")
      
      //Creating SA with Active Status and Editing to Inactive(Close SA)
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("input[value='New Standard Service']", 0 , -300)
      .click("input[value='New Standard Service']")      
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .fillInputText("Start Date", "12/30/2015 16:00") 
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","114020")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      .element("span[id$=searchDialog] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .getSelectOptions('Was dissatisfaction the reason for service ending?')
      .then(function(sEnd) {
        assert.deepEqual([
          "", "Yes", "No"
        ], sEnd);
      })
      .fillInputText("End Date", "1/5/2016") 
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
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
      .getSelectOptions('Was dissatisfaction the reason for service ending?')
      .then(function(sEnd) {
        assert.deepEqual([
          "", "Yes", "No"
        ], sEnd);
      })
      .fillInputText("End Date", "1/5/2016") 
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
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
        assert.equal("1/5/2016", enddate.trim());
      })
      .getOutputText("Was dissatisfaction the reason for service ending?")
      .then(function (rservEnd) {
        assert.equal("No", rservEnd.trim());
      })
      
     /* //Discharging Admission
     
      .waitForVisible("input[value='Yes']", defaultOperationTimeout)
      .click("input[value='Yes']")
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .getSelectOptions('Planned Discharge')
      .then(function(planDis) {
        assert.deepEqual([
          "", "Yes", "No"
        ], planDis);
      })
      .getSelectOptions('Discharged To')
      .then(function(planDis) {
        assert.deepEqual([
          "", "Death", "Home", "Hospitalization", "Another Facility", "Other"
        ], planDis);
      })
      .getSelectOptions('Discharged Reason')
      .then(function(planDis) {
        assert.deepEqual([
          "", "Acute Episode", "Deceased", "Funding", "Legal", "Goals Achieved", "Wrong Program Selected", "Other"
        ], planDis);
      })
      .fillInputText("Discharged Date/Time", "01/05/2016 16:00") 
      .chooseSelectOption("Planned Discharge", "Yes")
      .chooseSelectOption("Discharged To", "Home")
      .chooseSelectOption("Discharged Reason", "Goals Achieved")
      .click("input[value='Save']")      
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      
      //Negative Testing, Creating a SA with Discharged Admission.
       .scroll("input[value='New Standard Service']", 0 , -300)
       .click("input[value='New Standard Service']")
       .click("span[id$=buttons] input[value='Save']") 
       .waitForVisible("Service Assignments cannot be saved as Active when their Admission is set to Discharged.", defaultOperationTimeout)
       */
      
      
  
  }
});

