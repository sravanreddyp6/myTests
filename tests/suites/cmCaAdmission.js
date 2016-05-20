var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CmCaAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for CareMeridian": function(client, done) {
  var admViewUrl;
  
  return client
	.execUtil("convert_referral", { operatingGroup: "Care Meridian", flavor: "CA" })
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
          assert.deepEqual(["ABI", "ARY", "IDD","MH"], ntWrkOfrng);
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
    	 assert.ok(isExisting, "Add New Admission Button exists.");
    })
	.click("input[value='Add New Admission']")
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
	.fillInputText("Admission Date", "01/19/2016 11:00")
	.click("input[value='Save']")
	.pause(2000)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })
	  
  }

});