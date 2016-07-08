var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("HsGaReferral", suiteTimeout, {
  "should create a Cambridge GA Referral successfully": function(client, done) {
	var user = users["HS_GA_Referral_Intaker"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
    	.execUtil("create_referral", {operatingGroup: "Cambridge",flavor: "GA"})
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
			"Physician", "Rehab/Hospital", "School", "Self",
			"Social Worker", "Other"], refSrcType);
		})
        .chooseSelectOption("Referral Source Type", "Other")
		.fillInputText("Other (Describe)", "Other Testing")
		.fillInputText("Referral Source", "Referral Source Testing")
        .fillInputText("Referrer Name", "Referrer Name Testing")
		.fillInputText("Referrer Phone Number", "617-555-7890")
		.fillInputText("Billing ID", "5555")
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
        .fillInputText("Current Representative Payee", "Payee Test")	
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
			  "", "Admitted", "Another Provider Chosen", "Chose Another Service", "Could Not Meet Needs",
			  "Error", "Funding Inadequate", "Inquiry Only", "Mentor Refused Placement",
			  "No Match 2nd Client Issues", "No match geography", "No Match required no children in the home",
			  "No Open Bed", "No Response", "No Vacancies", "Not Eligible", "Referral Withdrawn", "Other"
			], closeReason);
		})		
		.fillInputText("Close Comment", "Close Comment Test")
		.click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "GA")
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
	    .getSelectOptions('Program Category')
		.then(function(ProCat) {
			assert.deepEqual(["IDD","ARY"], ProCat);
		})
        .chooseSelectOption("Program Category", "IDD")	
		.getSelectOptionsBySelector("select[title='Service Line - Chosen']")
		.then(function(ServiceLine) {
			assert.deepEqual(["0"], ServiceLine);
		})		
		.getSelectOptionsBySelector("select[title='Service Line - Available']")
		.then(function(ServiceLine) {
			assert.deepEqual(["1", "2", "3", "4", "5", "6", "7", "8", "9"], ServiceLine);
		})		
	    .chooseMultiSelectOption("Service Line", ["Host Home"])
		.getSelectOptionsBySelector("select[id$='servicesRequested_selected']")
		.then(function(ServicesRequested) {
			assert.deepEqual(["7"], ServicesRequested);
		})		
		.getSelectOptionsBySelector("select[id$='servicesRequested_unselected']")
		.then(function(ServicesRequested) {
			assert.deepEqual(["0", "1", "2","3", "4", "5","6", "8","9", "10", "11","12", "13", "14","15", "16", "17","18"], ServicesRequested);
		})		
	    .chooseMultiSelectOption("Services Requested", ["Base"])
		.fillInputText("Family History", "Family History Test")
		.fillInputText("Medical History", "Medical History Test")
		.fillInputText("Behavior Summary", "Behavior Summary Test")
		.fillInputText("Current Medications", "Current Medications Test")
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
		.getSelectOptions('Preferred Setting')
		.then(function(vals) {
			assert.deepEqual(["", "Urban", "Suburban", "Rural", "No Preference"], vals);
		})
		.chooseSelectOption("Preferred Setting","Urban")
		.getSelectOptions('Mobility')
		.then(function(vals) {
			assert.deepEqual(["", "Ambulatory", "Wheelchair", "Uses Walker", "Uses Cane"], vals);
		})
		.chooseSelectOption("Mobility","Wheelchair")
		.selectCheckbox("Accessible Housing Needed")
		.selectCheckbox("Accessible Vehicle Needed")
		.selectCheckbox("Geographic Restrictions")
		.fillInputText("Area of State Interested In","Area of State Interested In Test")
		.selectCheckbox("Access to Public Transportation")
		.selectCheckbox("Physically Aggressive to Staff")
		.selectCheckbox("Physically Aggressive to Self")
		.selectCheckbox("Physically Aggressive to Peers")
		.selectCheckbox("Verbally Aggressive")
		.selectCheckbox("Suicide Threats")
		.selectCheckbox("Suicide Attempts")
		.selectCheckbox("Self Harm or Self-Injurious Behaviors")
		.selectCheckbox("Fire Setting")
		.selectCheckbox("Legal History")
		.selectCheckbox("Law Enforcement Involvement")
		.selectCheckbox("Property Destruction")
		.selectCheckbox("Tobacco Use (Current)")
		.selectCheckbox("Chemical Use (Recovery)")
		.selectCheckbox("Chemical Use (Current)")
		.selectCheckbox("Chemical Dependency Treatment")
		.selectCheckbox("Elopement")
		.selectCheckbox("Unwanted Sexual Behavior")
		.getSelectOptions('if Yes, Type')
		.then(function(vals) {
			assert.deepEqual(["", "Issue", "Aggression", "Acting Out"], vals);
		})
		.chooseSelectOption("if Yes, Type","Issue")
		.selectCheckbox("Nursing Oversight Required")
		.fillInputText("If Yes, Level of Support Required","If Yes, Level of Support Required Test")
		.selectCheckbox("Unsupervised Time")
		.fillInputText("If Yes, Length of time","If Yes, Length of time Test")
		.selectCheckbox("Maintain Sibling Group")
		.getSelectOptions('If Yes, How Many?')
		.then(function(vals) {
			assert.deepEqual(["", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], vals);
		})
		.chooseSelectOption("If Yes, How Many?", "1")
		.selectCheckbox("No Same Sex Peers")
		.selectCheckbox("Can Live with Opposite Sex")
		.selectCheckbox("No Cross Cultural Placement")
		.selectCheckbox("Can Be Placed With Other Children")
		.getSelectOptions('If Yes, Age Requirements?')
		.then(function(vals) {
			assert.deepEqual(["", "Older", "Younger", "Age Is Not a Factor"], vals);
		})
		.chooseSelectOption("If Yes, Age Requirements?", "Older")
		.selectCheckbox("Family Involvement Restrictions")
		.getSelectOptions('If Yes, Level?')
		.then(function(vals) {
			assert.deepEqual(["", "Frequent Visitation", "Limited Visitation", "Supervised Visitation", "Unsupervised Visitation", "No Contact"], vals);
		})
		.chooseSelectOption("If Yes, Level?", "Frequent Visitation")
		.selectCheckbox("Has Pets")
		.fillInputText("If Yes, Type","Cat")
		.selectCheckbox("Animal Cruelty")
		.selectCheckbox("Choking Risk")
		.selectCheckbox("History of Bowel Obstructions")
		.selectCheckbox("Takes Injectible Medications")
		.selectCheckbox("Ventilator Dependent")
		.selectCheckbox("Eating Disorders")
		.selectCheckbox("Ingesting Non-Consumables")
		.selectCheckbox("Psychiatric/Mental Hospitalization")
		.selectCheckbox("Hospitalization Within the Past Year")
		.getSelectOptionsBySelector("select[id$='resrictHealthCond_unselected']")
		.then(function(ServiceLine) {
			assert.deepEqual(["0", "1", "2", "3", "4", "5", "6", "7", "8"], ServiceLine);
		})		
	    .chooseMultiSelectOption("Restricted Health Conditions", ["Feeding Tube"])
		.fillInputText("Programming Considerations Comments","Programming Considerations Comments Test")
		.click("input[value='Add Funding Source']")
        .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
        .getSelectOptions("Funding Source")
        .then(function(funSource) {
         assert.deepEqual(["", "AFDC", "Blue Cross Blue Shield", "Childnet", "CSB", "DFCS", 
                             "DJJ Region 1", "DJJ Region 2", "DJJ Region 3", "DJJ Region 4", 
                              "DJJ Region 5", "Etna", "MAAC", "Medicaid", "Medicare", "MIERS", "Military VA Benefits",
                              "Office of Adoption", "Oxford", "Physician Health Services",                                  
                               "Self Pay", "SSDI", "SSI", "State Adoption Unit", "Value Behavorial Health", "Other"], funSource);
         })
	    .chooseSelectOption("Funding Source", "Medicaid")
	    .click("span[id$=FundingSourceModal] input[value='Cancel']")
        .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
		
  }
});
