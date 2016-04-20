var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CmCaAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for CareMeridian": function(client, done) {
	
	var admViewUrl;
	var refUrl;
	var alias;
	var cDate = '4/12/2016';
	var conError = 'This Admission is within the date range of another Admission (Admission 1 - '+firstName+' '+lastName+'). Please correct the dates so Admissions do not overlap'
	var user = users["CM_DON"];
	var user2 = users["CM_Marketer"];
	var today = new Date().getMilliseconds() + new Date().getDate();
	var firstName = 'Regression '+today;
	var lastName = 'CM ADM '+today;
	var middleName = 'test '+today;
	var birthDate = "1/12/1988";
	var birthdateString = "1988-12-01";
	var age = function(birthdateString){
		var birthday = new Date(birthdateString);
		return~~ ((Date.now() - birthday) / (31557600000)) + ' Years';
	}
  
	return client

	.execUtil("convert_referral", { 
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
          assert.deepEqual(["ABI", "ADH", "ARY", "IDD", "MH"], ntWrkOfrng);
	})
	.getSelectOptions('Admission Status')
	.then(function(admStatus) {
          assert.deepEqual(["", "Active", "Discharged","Created in Error"], admStatus);
	})
	.chooseSelectOption("Admission Status", "Discharged")
	.waitForVisible("input[id=dischargedate]", defaultOperationTimeout)
	.fillInputText("Discharged Date/Time", "01/13/2016 18:00")
	.chooseSelectOption("Discharged To", "Home")
	.chooseSelectOption("Discharged Reason", "Funding")
	.chooseSelectOption("Planned Discharge", "Yes")
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
	.logInAs(user2)
	.click("a=Create New Referral")
    .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
	.fillInputText("First Name",firstName)
	.fillInputText("Last Name",lastName)
	.click("input[value='Search for Duplicates']")
	.click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")
	.selectByValue("[id$=sfps]", "California")
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
	.click("input[value='Add Funding Source']")
	.waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
	.chooseSelectOption("Coverage Level", "Primary")
	.click("span[id$=FundingSourceModal] input[value='Save']")
	.waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
	.click("input[value='Add Location']")
	.waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
	.click("span[id$=ReferralLocationModal] a#aliaslookup")
	.waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=addlocationstate]", "AZ")
	.click("span[id$=searchDialog] input[value='Search!']")
	.waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
	.element("span[id$=searchDialog] a")
	.then(function (el) {
	  return this.elementIdClick(el.value.ELEMENT);
	})
	.chooseSelectOption("Rank", "Primary")
	.chooseSelectOption("Status", "New")
	.click("span[id$=ReferralLocationModal] input[value='Save']")
	.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	.waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
	.chooseSelectOption("Referral Status", "New")
	.fillInputText("Referral Date", cDate)
	.click("input[value='Save Referral']")
	.pause(2000)
	.waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)
	.url()
	.then(function (currentUrl) {
		refUrl = currentUrl.value;
    })
	.logInAs(user)
    .then(function () {
		return this.url(refUrl);
    })
	
	.waitForVisible("input[value='Convert']", defaultOperationTimeout)
	.click("input[value='Edit']")
	.waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)
	.chooseSelectOption("Referral Source Type", "School")
	.fillInputText("Referral Source", "Old School" )
	.fillInputText("Current Location", "Home" )
	.click("a[id$=originlookup]")
	.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=originstate]", "AZ")
	.click("span[id$=searchDialog2] input[value='Search!']")
	.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
	.click("table[id$=table2] tbody tr:nth-child(1) td:nth-child(1) a")
	.fillInputText("Anticipated Admission DateTime", "01/12/2017 18:00")
	.click("input[value='Save Referral']")
	.waitForVisible("input[value='Search for Duplicates']", defaultOperationTimeout)
	.pause(2000)
	.click("input[value='Convert']")
	.waitForActionStatusDisappearance("convertStatus", defaultOperationTimeout)
    .click("input[value='Save and Continue']")
    .waitForActionStatusDisappearance("convertStatus2", defaultOperationTimeout)
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
	.chooseSelectOption("Admission Status", "Active")
	.pause(2000)
	.waitForVisible("input[value='Save']", defaultOperationTimeout)
	.chooseSelectOption("Network Offering", "ABI")
	.chooseSelectOption("State", "CA")
	.fillInputText("Admission Date", "4/20/2016" )
	.click("input[value='Save']")
	.waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })
	
  }

});