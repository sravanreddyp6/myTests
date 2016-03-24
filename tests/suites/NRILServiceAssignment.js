var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
testSuite("NRILServiceAssignment", suiteTimeout, {
  "Should Create/Edit/View/Close/promptFullDischarge a NeuroRestorative IL Service Assignment successfully": function(client, done) {
    return client
      //Referral Conversion
      .execUtil("convert_referral", {
             operatingGroup: "NeuroRestorative",
             flavor: "IL"
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
      .getSelectOptions('Was this a transfer from another Service Assignment?')
      .then(function(wtranSA) {
        assert.deepEqual([
          "", "Yes", "No"
        ], wtranSA);
      })
      .getSelectOptions('Service Began via Acquisition Company (as of 2016)?')
      .then(function(servAC) {
        assert.deepEqual([
          "", "Yes", "No"
        ], servAC);
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
      .getSelectOptions('Rancho Score at Start of Service')
      .then(function(cgSOS) {
        assert.deepEqual([
          "", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
        ], cgSOS);
      })
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      //.click("span[id$=sl] a")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","101010")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.element("span[id$=searchDialog] a")
      .element("span[id$=searchDialog] tr:first-child a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      
      //Adding Service codes
      .waitForVisible("[id$=avServCodesId] input[value=Add]", defaultOperationTimeout)
      .scroll("[id$=avServCodesId] input[value=Add]", 0 , -300)
      .click("table[id$=avServCodesId] tbody tr:nth-child(1) input[value=Add]")
      .waitForVisible("[id$=selServCodesId] input[value='Remove']", defaultOperationTimeout)
      
      .chooseSelectOption("Was this a transfer from another Service Assignment?", "No")
      .chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "No")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Rancho Score at Start of Service", "1")  
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
         
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Created in Error")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .fillInputText("Specify Error", "Testing") 
      .chooseSelectOption("Highest Level of Education at Start of Service", "Grade 1")
      .chooseSelectOption("Rancho Score at Start of Service", "2")  
      
       //Removing Service codes
	  .scroll("[id$=selServCodesId] input[value=Remove]", 0 , -300)
      .click("table[id$=selServCodesId] input[value=Remove]")
      .waitForActionStatusDisappearance("removeStatus", defaultOperationTimeout)
	  .scroll("span[id$=buttons] input[value='Save']", 0 , -300) 
	      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
  	  //Creating SA Assmnt-Only with Active Status and Editing to Inactive(Close SA)
  	  .click("[id$=admlink] a")
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
	  .scroll("input[value='New Assessment Only']", 0 , -300)
	  .click("input[value='New Assessment Only']")     
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .fillInputText("Start Date", "01/13/2016 17:00") 
      .pause(4000)
      .click(".lookupIcon")
      .waitForVisible("input[value='Search!']", defaultOperationTimeout)
      .setValue("input[id$=nameFilter]","101010")
      .click("input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      .element("span[id$=searchDialog] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })    
      
      //Adding Service codes
      .waitForVisible("[id$=avServCodesId] input[value=Add]", defaultOperationTimeout)
      .scroll("[id$=avServCodesId] input[value=Add]", 0 , -300)
      .click("table[id$=avServCodesId] tbody tr:nth-child(1) input[value=Add]")
      .waitForVisible("[id$=selServCodesId] input[value='Remove']", defaultOperationTimeout)
      
      .chooseSelectOption("Was this a transfer from another Service Assignment?", "No")
      .chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "No")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Rancho Score at Start of Service", "1") 
      .scroll("span[id$=buttons] input[value='Save']", 0 , -300)      
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("input[value='Edit']")
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      .getSelectOptions('Is this a transfer to another Service Assignment?')
      .then(function(istranSA) {
        assert.deepEqual([
          "", "Yes", "No"
        ], istranSA);
      })
      .getSelectOptions('Service Ended via Business Divested?')
      .then(function(servendBdiv) {
        assert.deepEqual([
          "", "Yes", "No"
        ], servendBdiv);
      })
      .getSelectOptions('Educational Involvement at End of Service')
      .then(function(eoSOS) {
        assert.deepEqual([
          "", "Enrolled, Attending Regularly", "Enrolled, Truant Regularly", "Not Enrolled", "Unknown"
        ], eoSOS);
      })
      .getSelectOptions('Highest Level of Education at End of Service')
      .then(function(educationLevelsEOS) {
        assert.deepEqual([
          "", "1 Year Preschool", "2+ Years Preschool", "Kindergarten", "Grade 1", "Grade 2",
          "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10",
          "Grade 11", "Grade 12", "1 Year College", "2 Years College", "3 Years College",
          "4+ Years College", "Graduate School", "1 Year Vocational/Technical",
          "2 Years Vocational/Technical", "Elementary School Special Education",
          "Middle School Special Education", "High School Special Education",
          "1 Year Special Education", "2+ Years Special Education",
          "Post Secondary Transition Services", "None", "Unknown"
        ], educationLevelsEOS);
      })
      .getSelectOptions('End of Service Circumstances')
      .then(function(endSC) {
        assert.deepEqual([
          "", "Behavioral needs exceed ability to serve", "Incarceration", "Medical needs exceed ability to serve", 
          "Moved to a different level of care", "No longer eligible/qualify for services", "No longer in need of services", 
          "PBS/Guardian chose another service provider", "PBS chose to end services", "PBS deceased", "Termination of funding"
        ], endSC);
      }) 
      .getSelectOptions('Was dissatisfaction the reason for service ending?')
      .then(function(wasSE) {
        assert.deepEqual([
          "", "Yes", "No"
        ], wasSE);
      })
      .fillInputText("End Date", "1/14/2016") 
      .chooseSelectOption("Educational Involvement at End of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at End of Service", "Graduate School")
      .chooseSelectOption("End of Service Circumstances", "Behavioral needs exceed ability to serve")
      .chooseSelectOption("Was dissatisfaction the reason for service ending?", "No")
      .click("span[id$=buttons] input[value='Save']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      
      // Prompt Full Discharge
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a")     
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .click("[id$=admlink] a")
      .waitForVisible("input[value='New Assessment Only']", defaultOperationTimeout)
      .scroll("[id$=servAssignId]", 0 , -300)
      .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(1) a") 
      .waitForVisible("input[value='Save']", defaultOperationTimeout) 
      .chooseSelectOption("Service Assignment Status", "Inactive")
      .waitForActionStatusDisappearance("pageProcessing", defaultOperationTimeout)
      
      .fillInputText("End Date", "1/14/2016") 
       .chooseSelectOption("Was this a transfer from another Service Assignment?", "No")
      .chooseSelectOption("Service Began via Acquisition Company (as of 2016)?", "No")
      .chooseSelectOption("Educational Involvement at Start of Service", "Enrolled, Attending Regularly")
      .chooseSelectOption("Highest Level of Education at Start of Service", "Graduate School")
      .chooseSelectOption("Rancho Score at Start of Service", "1") 
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
      .getOutputText("Was this a transfer from another Service Assignment?")
      .then(function (wtASA) {
        assert.equal("No", wtASA.trim());
      })
      .getOutputText("Service Began via Acquisition Company (as of 2016)?")
      .then(function (servBAC) {
        assert.equal("No", servBAC.trim());
      })
      .getOutputText("Educational Involvement at Start of Service")
      .then(function (eSOS) {
        assert.equal("Enrolled, Attending Regularly", eSOS.trim());
      })
      .getOutputText("Highest Level of Education at Start of Service")
      .then(function (hlEOS) {
        assert.equal("Graduate School", hlEOS.trim());
      })
      .getOutputText("Rancho Score at Start of Service")
      .then(function (ranchoScore) {
        assert.equal("1", ranchoScore.trim());
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