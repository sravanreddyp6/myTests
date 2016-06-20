var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("ADHMAReferral", suiteTimeout, {
  "should create a ADH MA Referral successfully": function(client, done) {
	var user = users["ADH_MA_Referral"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
         .execUtil("create_referral", {operatingGroup: "Adult Day Health",flavor: "MA"})
        .waitForVisible("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']")
        .getSelectOptions('Referral Status')
        .then(function(refStatus) {
            assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
        })
        .chooseSelectOption("Referral Status", "Active")
        .getSelectOptions('Referral Source Type')
        .then(function(refSrcType) {
            assert.deepEqual(["Administrator", "Attorney", "Case Manager – Hospital", "Case Manager – Military",
                "Case Manager – Non Public (includes all WC, Accident and Health, Private funds Case Managers)",
                "Case Manager – Public (includes all Medicaids)", "Case Manager – Treatment Facility",
                "Case Manager – Veterans Administration", "Family", "Internal", "Life Care Planner",
                "Nurse", "Physician", "Professional", "Service Coordinator", "Social Worker","Therapist",
                "Other"], refSrcType);
      })
        .chooseSelectOption("Referral Source Type", "Other")
        .fillInputText("Other (Describe)", "Other Testing")
        .fillInputText("Referral Source", "Referral Source Testing")
        .fillInputText("Referrer Name", "Referrer Name Testing")
        .getSelectOptions('How did referrer learn about us?')
        .then(function(refLearn) {
            assert.deepEqual(["Internet Search", "Speaker/ CEU Event", "Conference",  "Referred Before",
            "Email/Mailing", "Past Participant's Family", "Web Site", "Advertisement",
            "NeuroRestorative Clinical Evaluator / Marketer", "Colleague"], refLearn);
      })
        .chooseSelectOption("How did referrer learn about us?", "Colleague")
        .setValue("input[id$=Ref_Perm_Street]", "123 Test St")
        .setValue("input[id$=Ref_Perm_Street2]", "456 Test Rd")
        .setValue("input[id$=Ref_Perm_City]", "Boston")
		.getSelectOptionsBySelector('select[id$=Ref_Perm_State]')
		.then(function(states) {
			assert.deepEqual([
			"", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
			"Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois",
			"Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
			"Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
			"Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
			"North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
			"Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
			"Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
			], states);
		})
        .selectByValue('select[id$=Ref_Perm_State]', "Massachusetts")
        .setValue("input[id$=Ref_Perm_Zip]", "02115")
		.fillInputText("Referrer Email", "Testing@TMN.com")
		.fillInputText("Referrer Fax", "617-555-1234")
		.fillInputText("Referrer Phone Number", "617-555-7890")
		.fillInputText("Billing ID", "5555")
//		.getSelectOptions('Legal/Guardianship Status')
//		.then(function(guardianStatus) {
//			assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", "Guardian", "Health Care Representative",
//			"Kinship", "Limited Guardianship", "Parent", "Self", "Shelter Care", "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
//		})
		.getSelectOptionsBySelector('select[id$=guardianShipType]')
		.then(function(gaurdType) {
			assert.deepEqual([
			"", "Full Guardianship/Conservatorship", "Partial Guardianship/Conservatorship", "Self"
			], gaurdType);
		})
        .chooseSelectOption("Guardianship Type", "Self")	
		.waitForVisible("select[id$='partialGuardianShip_unselected']", defaultOperationTimeout,true)
		.chooseSelectOption("Guardianship Type", "Partial Guardianship/Conservatorship")
		.getSelectOptionsBySelector("select[id$='partialGuardianShip_unselected']")
		.then(function(partGaurdType) {
			assert.deepEqual(["0", "1", "2"], partGaurdType);
			//assert.deepEqual(["Financial", "Medical", "Placement Decisions"], partGaurdType);
		})		
	    .chooseMultiSelectOption("Partial Guardianship/Conservatorship Type", ["Financial"])	
		.fillInputText("Reason for Referral", "This is my reason for referral.......")
		.fillInputText("Update Notes", "This is my updated notes.........")
		//Created By
		//Last Modified By
        .chooseSelectOption("Referral Status", "On Hold")
		.waitForVisible("input[id$='holdDate']", defaultOperationTimeout)
		.fillInputText("Hold Date", "1/1/2000")
		.getSelectOptions('Hold Reason')
		.then(function(review) {
			assert.deepEqual([
			  "", "Pending Funding Availability", "Pending Waiver Approval", "Pending Authorization",
			  "Wait List", "Medical/Health Concerns", "Client/Family Choice", "Other"
			], review);
		})		
        .chooseSelectOption("Hold Reason", "Other")	
		.fillInputText("Review On", date)
		.chooseSelectOption("Referral Status", "Closed")
		.waitForVisible("input[id$='closeDate']", defaultOperationTimeout)
		.fillInputText("Close Date", "1/1/2000")
		.getSelectOptions('Close Reason')
		.then(function(closeReason) {
			assert.deepEqual([
			  "", "Admitted", "Chose Another Service", "Could Not Meet Needs", "Error", "Funding Inadequate",
			  "Inquiry Only", "Legal Reason", "No Response", "No Vacancies", "Not Eligible", "Referral Withdrawn Family Decision", "Other"
			], closeReason);
		})		
		.fillInputText("Close Comment", "Close Comment Test")
        .chooseSelectOption("Close Reason", "Error")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "Inquiry Only")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "Legal Reason")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "No Response")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "No Vacancies")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "Not Eligible")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "Referral Withdrawn Family Decision")
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)	
        .chooseSelectOption("Close Reason", "Other")	
		.waitForVisible("select[id$='closeDetail']", defaultOperationTimeout,true)
        .chooseSelectOption("Close Reason", "Chose Another Service")	
		.fillInputText("Close Comment", "Close Comment Test")		
		.click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "MA")
        .click("span[id$=searchDialog] input[value='Search!']")
        .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
        .element("span[id$=searchDialog] a")
        .then(function (el) {
          return this.elementIdClick(el.value.ELEMENT);
        })
		.selectLookup("User Assigned")
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
        .click(".list tbody tr.dataRow th a")
        .switchToNextWindow()
        .chooseSelectOption("Status", "New")
        .click("span[id$=ReferralLocationModal] input[value='Save']")
        .fillInputText("Referring Physician","Referring Physician Testing")		
		.fillInputText("Prior Program Information", "Prior Program Information Test")
		.fillInputText("Comments", "Comments Test")		
		.fillInputText("Reason for Referral", "This is my reason for referral change.......")
		.fillInputText("Update Notes", "This is my updated notes change.........")
		.fillInputText("Area of State Interested In","Area of State Interested In Test")
		.selectCheckbox("Verbally Aggressive")
		.selectCheckbox("Property Destruction")
		.selectCheckbox("Law Enforcement Involvement")
		.fillInputText("Current Medical Conditions","Current Medical Conditions Test")
		.selectCheckbox("Extreme Unwanted Behaviors")
		.selectCheckbox("Physically Aggressive to Staff")
	    .selectCheckbox("Suicide Threats")
		.selectCheckbox("Tobacco Use (Current)")
		.selectCheckbox("Chemical Dependency Treatment")
	    .selectCheckbox("Fire Setting")
		.selectCheckbox("No Mixed Diagnosis")
	    .selectCheckbox("Physically Aggressive to Self")
		.selectCheckbox("Registered Sex Offender")
		.getSelectOptions('Mobility')
		.then(function(vals) {
			assert.deepEqual(["", "Ambulatory", "Wheelchair", "Uses Walker", "Uses Cane"], vals);
		})
		.chooseSelectOption("Mobility","Wheelchair")
		.selectCheckbox("Suicide Attempts")
		.waitForVisible("span[id$='suicideAttemptsStatus.start']", defaultOperationTimeout,true)
		.setValue("input[id$='suicideAttempts']","Suicide Attempts Test")
		.selectCheckbox("Unwanted Sexual Behavior")
		.selectCheckbox("Legal History")
		.selectCheckbox("Physically Aggressive to Peers")
		.selectCheckbox("Chemical Use (Recovery)")
		.selectCheckbox("Chemical Use (Current)")
		.selectCheckbox("Elopement")
		.selectCheckbox("Self Harm or Self-Injurious Behaviors")
		.selectCheckbox("Current Pending Litigation")					   
		.selectCheckbox("Nursing Oversight Required")
		.fillInputText("If Yes, Level of Support Required","If Yes, Level of Support Required Test")
		.fillInputText("Programming Considerations Comments","Programming Considerations Comments Test")

  }
});
