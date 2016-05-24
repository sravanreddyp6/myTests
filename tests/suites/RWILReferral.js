var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("RWILReferral", suiteTimeout, {
  "should create a Redwood IL Referral successfully": function(client, done) {
	var user = users["RW_IL_Referral_Cans"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
        .execUtil("create_referral", {operatingGroup: "Redwood",flavor: "IL"})
        .waitForVisible("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']")
		.getSelectOptions('Referral Status')
        .then(function(refStatus) {
            assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
        })
        .chooseSelectOption("Referral Status", "Active")
        .getSelectOptions('Referral Source Type')
        .then(function(refSrcType) {
            assert.deepEqual(["", "Attorney", "Family", "Hospital Case Manager",
			"Independent Case Manager", "Internal", "Payor Case Manager",
			"Physician", "Rehab/Hospital", "School", "Self", "Social Worker", "Unknown", "Other"], refSrcType);
		})
        .chooseSelectOption("Referral Source Type", "Other")
		.fillInputText("Other (Describe)", "Other Testing")
		.fillInputText("Referral Source", "Referral Source Testing")
        .fillInputText("Referrer Name", "Referrer Name Testing")
		.fillInputText("Referrer Phone Number", "617-555-7890")
		.fillInputText("Case Manager Name", "Case Test")
		.fillInputText("Case Manager Phone", "555-555-5555")
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
		.getSelectOptions('Highest Level of Education')
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
        .chooseSelectOption("Highest Level of Education", "Unknown")
//		.fillInputText("Vision", "Vision Test")
//		.fillInputText("Hearing", "Hearing Test")
//		.fillInputText("Seizures", "Seizures Test")
//		.fillInputText("Other", "Other Test")
		.fillInputText("Communication Summary","Communication Summary Test")
		.fillInputText("ADL Summary", "ADL Summary Test")
		.fillInputText("Behavior Summary", "Behavior Summary Test")
		.fillInputText("Current Medications", "Current Medications Test")
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
			  "", "Admitted", "Chose Another Service", "Could Not Meet Needs",
			  "Error", "Funding Inadequate", "Inquiry Only", "No Vacancies", 
			  "Not Eligible", "Referral Withdrawn", "Other"
			], closeReason);
		})
		.fillInputText("Close Comment", "Close Comment Test")
		.click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "IL")
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
		.getSelectOptionsBySelector("select[id$='servicesRequested_unselected']")
		.then(function(ServicesRequested) {
			assert.deepEqual(["0", "1"], ServicesRequested);
		})		
	    .chooseMultiSelectOption("Services Requested", ["Periodic Services"])
		.fillInputText("Prior Program Information", "Prior Program Information Test")
		.fillInputText("Comments", "Comments Test")
		.getSelectOptions('Staffing Needs')
		.then(function(vals) {
			assert.deepEqual(["","Night Sleep", "Night Awake"], vals);
		})
		.chooseSelectOption("Staffing Needs","Night Sleep")
		.getSelectOptions('Staffing Ratio')
		.then(function(vals) {
			assert.deepEqual(["","1:1","1:2","1:3","1:4","Other"], vals);
		})
		.chooseSelectOption("Staffing Ratio","1:1")
		.getSelectOptions('Desired Living Environment')
		.then(function(vals) {
			assert.deepEqual(["", "ICF", "Supported Living", "Group Home", "With Family", "With Foster Family", "With Housemates", "Alone"], vals);
		})
		.chooseSelectOption("Desired Living Environment","Group Home")	
		.getSelectOptions('Mobility')
		.then(function(vals) {
			assert.deepEqual(["", "Ambulatory", "Wheelchair", "Uses Walker", "Uses Cane"], vals);
		})
		.chooseSelectOption("Mobility","Wheelchair")
		.selectCheckbox("Accessible Housing Needed")
		.selectCheckbox("Accessible Vehicle Needed")
		.fillInputText("Area of State Interested In","Area of State Interested In Test")
		.fillInputText("Current Medical Conditions","Current Medical Conditions Test")
		.selectCheckbox("Physically Aggressive to Staff")
		.selectCheckbox("Physically Aggressive to Self")
		.selectCheckbox("Physically Aggressive to Peers")
		.selectCheckbox("Verbally Aggressive")
		.selectCheckbox("Suicide Threats")
		.selectCheckbox("Suicide Attempts")
		.selectCheckbox("Self Harm or Self-Injurious Behaviors")
		.selectCheckbox("Law Enforcement Involvement")
		.selectCheckbox("Property Destruction")
		.selectCheckbox("Chemical Use (Recovery)")
		.selectCheckbox("Chemical Use (Current)")
		.selectCheckbox("Chemical Dependency Treatment")
		.selectCheckbox("Elopement")
		.selectCheckbox("Unwanted Sexual Behavior")
		.selectCheckbox("Nursing Oversight Required")
		.fillInputText("If Yes, Level of Support Required","If Yes, Level of Support Required Test")
		.selectCheckbox("Unsupervised Time")
		.fillInputText("If Yes, Length of time","If Yes, Length of time Test")
		.selectCheckbox("Can Live with Opposite Sex")
  }
});
