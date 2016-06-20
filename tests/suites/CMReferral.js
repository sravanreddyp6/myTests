var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CMReferral", suiteTimeout, {
  "should create a Care Meridian CA Referral successfully": function(client, done) {
	var user = users["CM_Marketer"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
        .execUtil("create_referral", {operatingGroup: "Care Meridian",flavor: "CA"})
        .waitForVisible("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']")
		.getSelectOptions('How did referral come in')
        .then(function(comein) {
            assert.deepEqual(["", "AllScripts", "Conference", "Curaspan", "Inservice", "Phone", "Website", "Other"], comein);
        })
        .chooseSelectOption("How did referral come in", "Other")		
		.getSelectOptions('Referral Status')
        .then(function(refStatus) {
            assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
        })
        .chooseSelectOption("Referral Status", "Active")
        .getSelectOptions('Referral Source Type')
        .then(function(refSrcType) {
            assert.deepEqual(["", "Attorney", "Family", "Hospital Case Manager",
			"Hospital Discharge Planner", "Independent Case Manager", "Internal", "Payor Case Manager",
			"Physician", "Rehab/Hospital", "School", "Self",
			"Social Worker", "Unknown", "Other"], refSrcType);
      })
        .chooseSelectOption("Referral Source Type", "Other")
		.fillInputText("Other (Describe)", "Other Testing")
      	.fillInputText("Referral Source", "Referral Source Testing")
        .fillInputText("Referrer Name", "Referrer Name Testing")
		.fillInputText("Referrer Phone Number", "617-555-7890")
		.getSelectOptions('Financial Status')
        .then(function(financial) {
            assert.deepEqual(["", "Pending", "Accepted", "Rejected"], financial);
        })
        .chooseSelectOption("Financial Status", "Pending")	
		.getSelectOptions('Clinical Evaluation Status')
        .then(function(evalstatus) {
            assert.deepEqual(["", "Pending", "Accepted", "Rejected"], evalstatus);
        })
        .chooseSelectOption("Clinical Evaluation Status", "Pending")			
		.fillInputText("Case Manager Name", "Case Test")
		.fillInputText("Case Manager Phone", "555-555-5555")
		.fillInputText("Current Location", "Current Location Test")
		.getSelectOptions('Current Location Type')
        .then(function(loctype) {
            assert.deepEqual(["", "Acute Rehab", "Board & Care", "Home", "Hospital", "LTAC", "Other",
			"Other LTC", "State Hospital", "Unknown"], loctype);
        })
        .chooseSelectOption("Current Location Type", "Home")
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
		.fillInputText("Comments", "Comments Test")
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
			  "Error", "Funding Inadequate", "Inquiry Only", "No Vacancies", "Not Eligible", "Referral Withdrawn", "Other"
			], closeReason);
		})		
		.chooseSelectOption("Close Reason", "Error")	
		.fillInputText("Close Comment", "Close Comment Test")
		
  }
});
