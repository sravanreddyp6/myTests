var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("rwAzGaAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for Redwood": function(client, done) {
  var admViewUrl;
  var refUrl;
  var alias;
  var user = users["RW_AZ_handler"];
  var today = new Date().getMilliseconds() + new Date().getDate();
  var firstName = 'Redwood '+today;
  var lastName = 'Admission '+today;
  var middleName = 'rwtest '+today;
  var birthDate = "1/12/1970";
  
  return client
	.execUtil("convert_referral", { 
		operatingGroup: "Redwood", 
		flavor: "AZ", 
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
	.selectByValue("[id$=sfps]", "Arizona")
	.waitForVisible("div[class=thinking]", defaultOperationTimeout,true)
	.chooseSelectOption("Referral Status", "Active")
	.fillInputText("Referral Date", '9/15/2015')
	.click("a[id$=originlookup]")
	.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=originstate]","AZ")
	.click("span[id$=searchDialog2] input[value='Search!']")
	.waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
	.element("span[id$=searchDialog2] a")
	.then(function (el) {
	return this.elementIdClick(el.value.ELEMENT);
	})
	.waitForVisible("input[value='Add Location']", defaultOperationTimeout)
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