var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("nrInAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for NeuroRestorative": function(client, done) {
  var admViewUrl;
  var refUrl;
  var alias;
  var user = users["NR_funding"];
  var today = new Date().getMilliseconds() + new Date().getDate();
  var firstName = 'Neuro '+today;
  var lastName = 'Admission '+today;
  var middleName = 'nrtest '+today;
  var birthDate = "1/12/1970";
  
  return client
	.execUtil("convert_referral", { 
		operatingGroup: "NeuroRestorative", 
		flavor: "IN", 
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
	.scroll("[id$=adminsId]", 0 , -300)	
	.click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")
	.url()
    .then(function (url) {
    	admViewUrl = url.value;
		assert.include(url.value, "AdmissionView");
    })
	.scroll("[id$=servAssignId]", 0 , -300)	
	.click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(1) a")
	.chooseSelectOption("Service Assignment Status", "Created in Error")
	.waitForVisible("input[id$=Specify]", defaultOperationTimeout)
	.fillInputText("Specify Error", "Regression Test")
	.fillInputText("End Date", "01/13/2016")
	.chooseSelectOption("Rancho Score at Start of Service", "1")
	.pause(3000)
	.scroll("span[id$=buttons] input[value='Save']", 0 , -300)	
	.click("span[id$=buttons] input[value='Save']")
	.then(function(){
        this.url(admViewUrl);
    })
    .refresh()
	.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
	.click("input[value='Edit Admission']")
	.waitForVisible("input[value='Save']", defaultOperationTimeout)
	
	.getSelectOptions('Network Offering')
	.then(function(ntWrkOfrng) {
          assert.deepEqual(["ABI", "ADH", "ARY", "IDD","MH"], ntWrkOfrng);
	})
	.getSelectOptions('Admission Status')
	.then(function(admStatus) {
          assert.deepEqual(["", "Active", "Discharged","Created in Error"], admStatus);
	})
	.chooseSelectOption("Admission Status", "Discharged")
	.waitForVisible("input[id$=dischdate]", defaultOperationTimeout)
	.fillInputText("Discharged Date", "01/13/2016")
	.windowHandleMaximize()
	.pause(2000)
	.chooseSelectOption("Discharged To (ROLES Scale at Discharge)", "Hotel/Motel")
	.chooseSelectOption("Discharged To", "Home")	
	.pause(1000)
	.click("input[value='Save']")
	.pause(2000)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })    
	.isExisting("input[value='Add New Admission']")
    .then(function(isExisting) {
		 assert.equal(isExisting, false, "Add New Admission Button does exists!! It Shouldn't be there!!");
    })

	.logInAs(user)
	.click("a=Create New Referral")
	.waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
	.fillInputText("First Name",firstName)
	.fillInputText("Last Name",lastName)
	.click("input[value='Search for Duplicates']")
	.click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")
	.selectByValue("[id$=sfps]", "Indiana")
	.waitForVisible("div[class=thinking]", defaultOperationTimeout,true)
	.chooseSelectOption("Highest Level of Education", "Grade 12")
	.click("input[value='Add Funding Source']")
	.waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
	.chooseSelectOption("Coverage Level", "Primary")
	.chooseSelectOption("Payer Type", "Auto")
	.click("span[id$=FundingSourceModal] input[value='Save']")
	.waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
	.click("input[value='Add Diagnosis']")
	.waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
	.click("[id$=diagnosisEntry] .lookupInput a")
	.switchToNextWindow()
	.waitForExist("#searchFrame", defaultOperationTimeout)
	.element("#searchFrame")
	.then(function (frame) { return frame.value; })
	.then(client.frame)
	.setValue("input#lksrch", "A00")
	.click("input[value*='Go']")
	.frameParent()
	.waitForExist("#resultsFrame", defaultOperationTimeout)
	.element("#resultsFrame")
	.then(function (frame) { return frame.value; })
	.then(client.frame)
	.click("#ICD__c_body tr.dataRow th a")
	.switchToNextWindow()
	.fillInputText("Date and Time of Diagnosis", "01/12/2016 18:00")
	.click("span[id$=diagnosisModal] input[value='Save']")
	.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	.selectLookup("Evaluated By (Internal)")
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
	.chooseSelectOption("Referral Status", "Active")
	.chooseSelectOption("Referral Source Type", "Family")
	.waitForActionStatusDisappearance("statusRefSourceType", defaultOperationTimeout)
	.fillInputText("Referral Source", "Mentor")
	.fillInputText("Referrer Name", "Somebody")	
	.chooseSelectOption("How did referrer learn about us?", "Internet Search")
	.fillInputText("Referral Date", '9/15/2015')
	.fillInputText("Date of Injury", '9/9/2015')
	.chooseSelectOption("Cause of Injury", "Fall")
	.chooseSelectOption("Current Location Type", "Home")
	.selectByIndex("select[title='Services Requested - Available']", 0)
	.click("a img[id$=servicesRequested_right_arrow]")
	.click("a[id$=originlookup]")
	.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=originstate]","IN")
	.click("span[id$=searchDialog2] input[value='Search!']")
	.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
	.element("span[id$=searchDialog2] a")
	.then(function (el) {
	return this.elementIdClick(el.value.ELEMENT);
	})
	.waitForVisible("input[value='Add Location']", defaultOperationTimeout)
	.click("input[value='Add Location']")
	.waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
	.click("a[id$=aliaslookup]")
	.waitForVisible("input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=addlocationstate]","IN")
	.click("span[id$=searchDialog] input[value='Search!']")
	.waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
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
    .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")	
	.click("input[value='Save Referral']")
	.waitForVisible("input[value='Convert']", defaultOperationTimeout)	
	
	.click("input[value='Convert']")
	.waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout)
	.waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
	.click("input[value='Confirm Conversion']")
	.waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	.scroll("[id$=adminsId]", 0 , -300)
	.click("table[id$=adminsId] tbody tr:nth-child(2) td:nth-child(2) a")
	.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
	.click("input[value='Edit Admission']")
	.waitForVisible("input[value='Save']", defaultOperationTimeout)
	
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionEdit");
    })	

	.click("input[value='Cancel']")
	.pause(2000)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })
	  
  }

});