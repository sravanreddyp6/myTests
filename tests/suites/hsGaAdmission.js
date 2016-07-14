var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 9 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("hsGaAdmission", suiteTimeout, {
  "should close out the existing admission and create a new one for Hastings": function(client, done) {
  var admViewUrl;
  var refUrl;
  var alias;
  var user = users["HS_GA_Referral_Cans"];
  var user2 = users["HS_GA_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
  var firstName = 'Axle '+today;
  var lastName = 'Rose '+today;
  var middleName = 'artest '+today;
  var birthDate = "1/12/1970";
	
  return client
	.execUtil("convert_referral", { 
		operatingGroup: "Cambridge", 
		flavor: "GA", 
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
          assert.deepEqual(["ABI", "ADH", "ARY", "IDD","MH"], ntWrkOfrng);
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
		 assert.equal(isExisting, false, "Add New Admission Button does exists!! It Shouldn't be there!!");
    })

	.logInAs(user2)
	.click("a=Create New Referral")
    .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
	.fillInputText("First Name",firstName)
	.fillInputText("Last Name",lastName)
	.click("input[value='Search for Duplicates']")
	.click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")
	.selectByValue("[id$=sfps]", "Georgia")
	.waitForVisible("div[class=thinking]", defaultOperationTimeout,true)
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
	.fillInputText("Referrer Name", "Slash")
	.fillInputText("Referrer Phone Number", "586356")
	.fillInputText("Case Manager Name", "Duff")
	.fillInputText("Billing ID", "something")
	.fillInputText("Case Manager Phone", "8675309")
	.fillInputText("Current Representative Payee", "Izzy")
	.fillInputText("Reason for Referral", "Test")
	.fillInputText("Update Notes", "Test")
	.fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
	.click("a[id$=originlookup]")
	.waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
	.setValue("input[id$=originstate]","GA")
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
	.setValue("input[id$=addlocationstate]","GA")
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
	.waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
	.chooseSelectOption("Program Category", "IDD")
      
	.selectByIndex("select[title='Service Line - Available']", 0)
	.click("a img[id$=j_id959_right_arrow]")
	.selectByIndex("select[title='Services Requested - Available']", 0)
	.click("a img[id$=servicesRequested_right_arrow]")

	.fillInputText("Family History", "test")
	.fillInputText("Medical History", "test")
	.fillInputText("Behavior Summary", "test")
	.fillInputText("Prior Program Information", "test")
	.click("input[value='Add Agency Involved With Individual']")
	.waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
	.pause(5000) 
	.fillInputText("Agency Name:", "test")
	.fillInputText("Address:", "404 test street")
	.fillInputText("Phone Number:", "8008378")
	.fillInputText("Reason for Involvement:", "test")
	.pause(5000)
	.click("span[id$=agencyModal] input[value='Save']")
	.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	.waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
	.click("input[value='Add Funding Source']")
	.waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
	.chooseSelectOption("Funding Source", "Medicaid")
	.fillInputText("Funding Source ID", "test")
	.selectByValue("span[id$=FundingSourceModal] select[id$=fundingEntry_Status]", "Pending Approval")
	.setValue("span[id$=FundingSourceModal] textarea[id$=fundingEntry_comment]", "test")
	.click("span[id$=FundingSourceModal] input[value='Save']")
	.waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
	.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	.chooseSelectOption("Staffing Needs", "Night Sleep")
	.chooseSelectOption("Staffing Ratio", "1:2")
	.chooseSelectOption("Desired Living Environment", "ICF")
	.chooseSelectOption("Preferred Setting", "Urban") 
	.chooseSelectOption("Mobility", "Uses Walker")
	.selectCheckbox("Accessible Housing Needed")
	.selectCheckbox("Elopement") 
	.selectCheckbox("Unwanted Sexual Behavior")
	.chooseSelectOption("if Yes, Type", "Issue")
	.selectCheckbox("Nursing Oversight Required")
	.fillInputText("If Yes, Level of Support Required", "test1")
	.selectCheckbox("Unsupervised Time")
	.fillInputText("If Yes, Length of time", "test time")
	.selectCheckbox("Maintain Sibling Group")
	.chooseSelectOption("If Yes, How Many?", "5")
	.selectCheckbox("No Same Sex Peers")
	.selectCheckbox("Can Live with Opposite Sex")
	.selectCheckbox("No Cross Cultural Placement") 
	.selectCheckbox("Can Be Placed With Other Children")
	.chooseSelectOption("If Yes, Age Requirements?", "Older")
	.selectCheckbox("Family Involvement Restrictions")
	.chooseSelectOption("If Yes, Level?", "Limited Visitation")
	.selectCheckbox("Has Pets")
	.fillInputText("If Yes, Type", "test")
	.selectByIndex("select[title='Restricted Health Conditions - Available']", 0)
	.click("a img[id$=resrictHealthCond_right_arrow]")
	.setValue("textarea[id$=ProgConsComment]", "test")
	.fillInputText("Referral Date", '9/15/2015')
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
	.fillInputText("Admission Date", "07/31/2015 14:00")
	.chooseSelectOption("Admitted From (ROLES Scale at Admission)", "Hotel/Motel")
	.chooseSelectOption("Network Offering", "ARY")
	.chooseSelectOption("State", "GA")
	.chooseSelectOption("Admission Status", "Active")
	.click("input[value='Save']")
	.pause(2000)
	.url()
    .then(function (url) {
		assert.include(url.value, "AdmissionView");
    })
	  
  }

});