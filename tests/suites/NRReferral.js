/**
 * This file is used to test NeuroRestorative operating group Referrals
 * @Sravan Reddy - Aug 31, 2015
 */
var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("NRReferral", suiteTimeout, {
  "should create a Redwood NR Referral successfully": function(client, done) {
	var user = users["NR_Referrals_Ops"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
        .execUtil("create_referral", {operatingGroup: "NeuroRestorative",flavor: "MA"})
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
		.waitForVisible("select[id$='closeDetail'] option[value='Competitor']", defaultOperationTimeout)
		.pause(2000)		
		.getSelectOptions('Close Reason Detail')
		.then(function(CAS) {
			assert.deepEqual([
			  "", "Competitor", "Home with Family (no services)", "Outpatient",
			  "Day Treatment/Day Health", "Home Health", "Skilled Nursing Facility",
			  "Assisted Living", "Psychiatric Hospital"
			], CAS);
		})		
        .chooseSelectOption("Close Reason Detail", "Competitor")				
        .chooseSelectOption("Close Reason", "Could Not Meet Needs")	
		.waitForVisible("select[id$='closeDetail'] option[value='Psychiatric Services Not Available']", defaultOperationTimeout)
		.pause(2000)
		.getSelectOptions('Close Reason Detail')
		.then(function(CNMD) {
			assert.deepEqual([
			  "", "Substance Abuse Programming Not Available", "Psychiatric Services Not Available", "Orthopedic Needs Too Complex",
			  "Nursing Needs Too Complex", "No Identified Brain Injury", "No Bed Availability in Requested/Appropriate Program"
			], CNMD);
		})		
        .chooseSelectOption("Close Reason Detail", "Psychiatric Services Not Available")				
        .chooseSelectOption("Close Reason", "Funding Inadequate")	
		.waitForVisible("select[id$='closeDetail'] option[value='Medicare Funded']", defaultOperationTimeout)
		.pause(2000)		
		.getSelectOptions('Close Reason Detail')
		.then(function(FI) {
			assert.deepEqual([
			  "", "Out-of-Network", "Non-covered Benefit", "Private Pay Not Agreeable",
			  "Does not meet MCD Financial Standards", "MCD/Waiver/MCO Denial",
			  "No Identifiable Funding Option", "Medicare Funded", "Non-compensable Injury",
			  "Letter of Protection (LOP) Denied", "Authorization Withdrawn"
			], FI);
		})		
        .chooseSelectOption("Close Reason Detail", "Medicare Funded")
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
		//Ranchos Los Amigos Scale
		.fillInputText("Prior Program Information", "Prior Program Information Test")
		.fillInputText("Comments", "Comments Test")
		.getSelectOptions('Cause of Injury')
		.then(function(Injury) {
			assert.deepEqual([
			  "", "Abuse", "Accident - Other", "Assault", "At Birth", "ATV", "Bicycle Accident",
			  "Blast Injury", "Brain Tumor", "Cardiac Arrest", "CVA", "Disease", "Drowning",
			  "Drugs", "Fall", "Gunshot", "Military - Combat", "Military - Other",
			  "Motor Vehicle - Driver", "Motor Vehicle - Passenger", "Motorcycle",
			  "Pedestrian Car", "Self-Inflicted", "Shaken Baby", "Stroke", "Sports Injury",
			  "Struck by Object", "Unknown", "Other"
			], Injury);
		})
        .chooseSelectOption("Cause of Injury", "Other")	
		.waitForVisible("input[id$='txtothercause']", defaultOperationTimeout)
		.setValue("input[id$='txtothercause']", "Cause of Injury Other Test")
		.click("input[id$=NR_useContact]")
		.click("input[id$=NR_usePermanent]")
		.getValue("input[id$=Neuro_Street1]")
		.then(function (street1) {
			assert.equal("123 Test St", street1);
		})
		.getValue("input[id$=Neuro_Street2]")
		.then(function (street2) {
			assert.equal("456 Test Rd", street2);
		})
		.getValue("input[id$=MN_City]")
		.then(function (city) {
			assert.equal("Boston", city);
		})
		.getValue("select[id$=MN_State]")
		.then(function (state) {
			assert.equal("Massachusetts", state);
		})
		.getValue("input[id$=MN_Zip]")
		.then(function (zip) {
			assert.equal("02115", zip);
		})
		.setValue("input[id$=Neuro_Street1]", "555 Test St")
        .setValue("input[id$=Neuro_Street2]", "000 Test Rd")
        .setValue("input[id$=MN_City]", "Boston")
		.getSelectOptionsBySelector('select[id$=MN_State]')
		.then(function(states) {
			assert.deepEqual([
			"", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
			"Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Guam", "Hawaii", "Idaho", "Illinois",
			"Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
			"Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
			"Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
			"North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
			"Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
			"Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
			], states);
		})
        .selectByValue('select[id$=MN_State]', "California")
        .setValue("input[id$=MN_Zip]", "02171")
        .getSelectOptions('Current Location Type')
        .then(function(locType) {
            assert.deepEqual(["","Acute Rehab", "Home", "LTAC", "Other", "Acute Hospital",
			"SNF", "Jail", "Post-Hospital Brain Injury Program", "Nursing Home"], locType);
		})
        .chooseSelectOption("Current Location Type", "SNF")		
		.setValue("input[id$=MN_Phone]","987-555-1234")	
		.setValue("input[id$=MN_Email]","emailTest@TMN.com")	
		.setValue("input[id$=MN_Fax]","987-555-9999")	
		.fillInputText("Estimated Discharge Date","1/2/2000")
		.fillInputText("Referring Physician","Referring Physician Testing")
        .getSelectOptions('Previous Brain Injury')
        .then(function(PBI) {
            assert.deepEqual(["","Yes", "No", "Unknown"], PBI);
		})
        .chooseSelectOption("Previous Brain Injury", "No")			
		.pause(2000)		
        .getSelectOptions('Did Alcohol Contribute to Injury')
        .then(function(DACTI) {
            assert.deepEqual(["","Yes", "No", "Unknown"], DACTI);
		})
        .chooseSelectOption("Did Alcohol Contribute to Injury", "No")				
		.pause(2000)		
        .getSelectOptions('Did Drug Use Contribute to Injury')
        .then(function(DDUCTI) {
            assert.deepEqual(["","Yes", "No", "Unknown"], DDUCTI);
		})
        .chooseSelectOption("Did Drug Use Contribute to Injury", "No")				
		.pause(2000)		
        .getSelectOptions('Military Service Related Injury')
        .then(function(MSRI) {
            assert.deepEqual(["","Yes", "No", "Unknown"], MSRI);
		})
        .chooseSelectOption("Military Service Related Injury", "No")			
		.pause(2000)		
		.fillInputText("Duration of Unconsciousness","5")
		.fillInputText("Reported By","Test")	
		
		.getSelectOptions('Staffing Ratio')
		.then(function(vals) {
			assert.deepEqual(["","1:1","1:2","1:3","1:4","Other"], vals);
		})
		.chooseSelectOption("Staffing Ratio","1:1")
		.getSelectOptions('Desired Living Environment at Discharge')
		.then(function(vals) {
			assert.deepEqual(["", "ICF", "Supported Living", "Group Home", "With Family", "With Foster Family", "With Housemates", "Alone"], vals);
		})
		.chooseSelectOption("Desired Living Environment at Discharge","Group Home")	
		.selectCheckbox("Physically Aggressive To Staff")
		.waitForVisible("span[id$='aggressiveToStaffStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Physically Aggressive To Self")
		.waitForVisible("span[id$='aggressiveToSelfStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Physically Aggressive To Peers")
		.waitForVisible("span[id$='aggressiveToPeersStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Verbally Aggressive")
		.waitForVisible("span[id$='verballyAggressiveStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Suicide Threats")
		.waitForVisible("span[id$='suicideThreatsStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Suicide Attempts")
		.waitForVisible("span[id$='suicideAttemptsStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Self-Harm or Self-Injurious Behaviors")
		.waitForVisible("span[id$='selfHarmStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Theft")
		.waitForVisible("span[id$='theftStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Tobacco Use (Current)")
		.waitForVisible("span[id$='usesTobaccoStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Chemical Use (Current)")
		.waitForVisible("span[id$='chemicalUseCurrentStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Chemical Dependency Treatment")
		.waitForVisible("span[id$='chemicalDependencyTreatmentStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Elopement")
		.selectCheckbox("Unwanted Sexual Behavior")
		.waitForVisible("span[id$='unwantedSexualBehaviorStatus.start']", defaultOperationTimeout,true)
		.selectCheckbox("Current Pending Litigation")
		.waitForVisible("span[id$='currentPendingLitigationStatus.start']", defaultOperationTimeout,true)
		.fillInputText("Programming Considerations Comments","Programming Considerations Comments Test")
		.setValue("input[id$='aggressiveToStaffDescription']","Physically Aggressive To Staff Test")
		.setValue("input[id$='verballyAggressive']","Verbally Aggressive Test")
		.setValue("input[id$='theft']","Theft Test")
		.getSelectOptionsBySelector("select[id$='unwantedSexualBehavior']")
		.then(function(unwantedBehav) {
			assert.deepEqual(["", "Issue", "Aggression", "Acting Out"], unwantedBehav);
		})
		.setValue("input[id$='suicideThreats']","Suicide Threats Test")
		.setValue("input[id$='usesTobacco']","Tobacco Use (Current) Test")
		.setValue("input[id$='currentPendingLitigation']","Current Pending Litigation Test")
		.setValue("input[id$='aggressiveToSelf']","Physically Aggressive To Self Test")
		.setValue("input[id$='suicideAttempts']","Suicide Attempts Test")
		.fillInputText("Date Completed","1/1/2000")
		.setValue("input[id$='aggressiveToPeers']","Physically Aggressive To Peers Test")
		.setValue("input[id$='selfHarm']","Self-Harm or Self-Injurious Behaviors Test")
		.fillInputText("Date Last Used","1/1/2000")
  }
});
