var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("hsGaAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for Hastings": function(client, done) {
  var admViewUrl;
  
  return client
	.execUtil("convert_referral", { operatingGroup: "Cambridge", flavor: "GA" })
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
	.chooseSelectOption("Model", "FCT")
	.waitForVisible("input[id$=Specify]", defaultOperationTimeout)
	.fillInputText("Specify Error", "Regression Test")
	.chooseSelectOption("Child Service Goal at Start of Service", "Assessment")
	.chooseSelectOption("Educational Involvement at Start of Service", "Unknown")
	.chooseSelectOption("Highest Level of Education at Start of Service", "Unknown")
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
	.getSelectOptions('Admitted From (ROLES Scale at Admission)')
	.then(function(admStatus) {
          assert.deepEqual(["", "Adoptive Home", "Adult Host Home", "Alternative Living Unit", "Armed Forces", "County Detention Center", 
          "Drug/Alcohol Rehab Center", "Foster Care - Regular", "Foster Care - Specialized", "Foster Care - Treatment", 
          "Group Emergency Shelter", "Group Home", "Home Emergency Shelter", "Homeless", "Home of Biological Parents", "Home of Family Friend", 
          "Home of Relative", "Hotel/Motel", "ICF/IDD", "Independent Living by Self", "Independent Living w/Friend", "Independent Living w/Spouse", 
          "Medical Hospital (Inpatient)", "Nursing Home", "Prison", "Residential Job Corps Center", "Residential Treatment Center", "Skilled Nursing Facility", 
          "State/Private Psychiatric Hospital", "State School/Institution", "Sub Acute Care Facility", "Supervised Independent Living", 
          "Youth Correctional Center"], admStatus);
	})
	.chooseSelectOption("Admission Status", "Created in Error")
	.waitForVisible("input[id$=createdInErrorInput]", defaultOperationTimeout)
	.fillInputText("Specify Error", "Regression Test")
	.chooseSelectOption("Admitted From (ROLES Scale at Admission)", "Prison")
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
	.chooseSelectOption("Network Offering", "ARY")
	.chooseSelectOption("State", "GA")
	.chooseSelectOption("Admission Status", "Active")
	.fillInputText("Admission Date", "07/31/2015 14:00")
	.click("input[value='Save']")
	.pause(2000)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })
	  
  }

});