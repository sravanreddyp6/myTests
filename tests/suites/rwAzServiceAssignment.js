var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("rwAzServiceAssignment", suiteTimeout, {
  "Should Create/Edit/View/Close/promptFullDischarge a Redwood AZ Service Assignment successfully": function(client, done) {
    return client
      //Referral Convertion
      .execUtil("convert_referral", {
             operatingGroup: "Redwood",
             flavor: "AZ"
       })
      //Navigating to Admission Page
      .scroll("[id$=adminsId]", 0 , -300)
      .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
      .windowHandleMaximize()   
      
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
      .getSelectOptions('Service Assignment Status')
      .then(function(saStatus) {
        assert.deepEqual([
          "", "Active", "Inactive", "Created in Error"
        ], saStatus);
      })
      .getSelectOptions('Episode')
      .then(function(epsd) {
        assert.deepEqual([
          "", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
           "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
           "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"
        ], epsd);
      })  
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
      .getSelectOptions('Child Permanency Goal at Start of Service')
      .then(function(cgSOS) {
        assert.deepEqual([
          "", "Reunification", "Adoption", "Guardianship", "Permanent Placement with Relative (PPWR)", "Another Planned Permanency Living Arrangement (APPLA)"
        ], cgSOS);
      })
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .click(".lookupIcon")
      //.click("span[id$=sl] a")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","122010")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:first-child a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      
      .chooseSelectOption("Child Permanency Goal at Start of Service", "Guardianship")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Created in Error")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .fillInputText("Specify Error", "Testing") 
      .chooseSelectOption("Episode", "1")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Grade 1")
      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
  	  //Creating SA Assmnt-Only with Active Status and Editing to Inactive(Close SA)
  	  .click("[id$=admlink] a")
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")     
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","122010")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:first-child a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })      
      .chooseSelectOption("Child Permanency Goal at Start of Service", "Guardianship")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Episode", "1")
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .getSelectOptions('Educational Involvement at End of Service')
      .then(function(eoSOS) {
        assert.deepEqual([
          "", "Enrolled, Attending Regularly", "Enrolled, Truant Regularly", "Not Enrolled", "Unknown"
        ], eoSOS);
      })
      .fillInputText("End Date", "1/14/2016") 
      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at End of Service", "Graduate School")
      .chooseSelectOption("End of Service Circumstances", "Behavioral needs exceed ability to serve")
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
      
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      //.click("span[id$=sl] a")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","122874")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:nth-child(2) a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      
       //Adding Service codes
      .waitForVisible("[id$=avServCodesId] input[value=Add]", defaultOperationTimeout)
      .scroll("[id$=avServCodesId] input[value=Add]", 0 , -300)
      .click("table[id$=avServCodesId] tbody tr:nth-child(1) input[value=Add]")
      .waitForVisible("[id$=selServCodesId] input[value='Remove']", defaultOperationTimeout) 
      
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Episode", "1")
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
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
      .chooseSelectOption("Episode", "10")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Grade 1")  
       
        //Removing Service codes
	  .scroll("[id$=selServCodesId] input[value=Remove]", 0 , -300)
      .click("table[id$=selServCodesId] input[value=Remove]")
      .waitForActionStatusDisappearance("removeStatus", defaultOperationTimeout)
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300) 
	     
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
       //Creating SA with Active Status and Editing to Inactive(Close SA)
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
      .scroll("input[value='New Standard Service']", 0 , -300)
      .click("input[value='New Standard Service']")      
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","122874")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:nth-child(2) a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      
      //Adding Service codes
      .waitForVisible("[id$=avServCodesId] input[value=Add]", defaultOperationTimeout)
      .scroll("[id$=avServCodesId] input[value=Add]", 0 , -300)
      .click("table[id$=avServCodesId] tbody tr:nth-child(1) input[value=Add]")
      .waitForVisible("[id$=selServCodesId] input[value='Remove']", defaultOperationTimeout) 
      
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Episode", "1")
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .getSelectOptions('Service Ended via Business Divested?')
      .then(function(sEndBu) {
        assert.deepEqual([
          "", "Yes", "No"
        ], sEndBu);
      })
      .getSelectOptions('Educational Involvement at End of Service')
      .then(function(eoSOS) {
        assert.deepEqual([
          "", "Enrolled, Attending Regularly", "Enrolled, Truant Regularly", "Not Enrolled", "Unknown"
        ], eoSOS);
      })
      .getSelectOptions('End of Service Circumstances')
      .then(function(endSC) {
        assert.deepEqual([
          "", "Behavioral needs exceed ability to serve", "Did not comply with services/poor attendance", "Family refused services", 
          "Hospitalization", "Incarceration", "No longer eligible/qualify for services", "PBS/Guardian chose another service provider", 
          "PBS chose to end services", "PBS deceased", "Qualified staff not available", "Relocation", 
          "Termination of funding", "Unable to locate to provide services"
        ], endSC);
      }) 
      .getSelectOptions('Was dissatisfaction the reason for service ending?')
      .then(function(wasSE) {
        assert.deepEqual([
          "", "Yes", "No"
        ], wasSE);
      })
      .fillInputText("End Date", "1/14/2016") 
      .chooseSelectOption("Service Ended via Business Divested?", "No")
      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")      
      .chooseSelectOption("End of Service Circumstances", "Behavioral needs exceed ability to serve")
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
      
      .fillInputText("End Date", "1/14/2016") 
      .chooseSelectOption("Episode", "1")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")      
      .chooseSelectOption("Service Ended via Business Divested?", "No")
      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")      
      .chooseSelectOption("Highest Level of Education at End of Service", "Graduate School")
      .chooseSelectOption("End of Service Circumstances", "Behavioral needs exceed ability to serve")
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
        assert.equal("1/14/2016", enddate.trim());
      })
      .getOutputText("Episode")
      .then(function (epsode) {
        assert.equal("1", epsode.trim());
      })
      .getOutputText("Educational Involvement at Start of Service")
      .then(function (eSOS) {
        assert.equal("Enrolled, Attending Regularly", eSOS.trim());
      })
      .getOutputText("Highest Level of Education at Start of Service")
      .then(function (hlEOS) {
        assert.equal("Graduate School", hlEOS.trim());
      })
      .getOutputText("Was this a transfer from another Service Assignment?")
      .then(function (wtASA) {
        assert.equal("No", wtASA.trim());
      })
      .getOutputText("Service Began via Acquisition Company (as of 2016)?")
      .then(function (servBAC) {
        assert.equal("No", servBAC.trim());
      })
      .getOutputText("Is this a transfer to another Service Assignment?")
      .then(function (transToSA) {
        assert.equal("No", transToSA.trim());
      })
      .getOutputText("Service Ended via Business Divested?")
      .then(function (serveEndBD) {
        assert.equal("No", serveEndBD.trim());
      })
      .getOutputText("Educational Involvement at End of Service")
      .then(function (eduEOS) {
        assert.equal("Enrolled, Attending Regularly", eduEOS.trim());
      })
      .getOutputText("Highest Level of Education at End of Service")
      .then(function (higheEOS) {
        assert.equal("Graduate School", higheEOS.trim());
      })
      .getOutputText("End of Service Circumstances")
      .then(function (eoSerC) {
        assert.equal("Behavioral needs exceed ability to serve", eoSerC.trim());
      })      
      .getOutputText("Was dissatisfaction the reason for service ending?")
      .then(function (dservEnd) {
        assert.equal("No", dservEnd.trim());
      })
      
  }
});