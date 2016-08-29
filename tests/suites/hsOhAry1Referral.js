var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 60 * 1000;

testSuite("HsOhAry1Referral", suiteTimeout, {
  "should create a Cambridge OH Referral successfully": function(client, done) {
	var user = users["HS_OH_Ary1_Referral_Intaker"];
	var d=new Date();
	var date = ("0" + (d.getMonth()+1)).slice(-2) + "/" + ("0" + d.getDate()).slice(-2) + "/" + d.getFullYear();
    return client
        .execUtil("create_referral", {operatingGroup: "Cambridge",flavor: "OH"})
        .waitForVisible("input[value='Edit']", defaultOperationTimeout)
        .click("input[value='Edit']")
		.getSelectOptions('Referral Status')
        .then(function(refStatus) {
            assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
        })
        .chooseSelectOption("Referral Status", "Active")
        .getSelectOptions('Referral Source Type')
        .then(function(refSrcType) {
            assert.deepEqual(["", "Attorney", "Counselor", "Family", "Hospital Case Manager",
			"Independent Case Manager", "Internal", "Juvenile Justice", "Other therapist", "Payor Case Manager",
			"Physician", "Rehab/Hospital", "School", "Self",
			"Social Worker", "Other"], refSrcType);
		})
        .chooseSelectOption("Referral Source Type", "Other")
		.fillInputText("Other (Describe)", "Other Testing")
		.fillInputText("Referral Source", "Referral Source Testing")
        .fillInputText("Referrer Name", "Referrer Name Testing")
        .fillInputText("Referrer Street", "123 Test St")
        .fillInputText("Referrer Email", "Test123@TMN.com")
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
        .fillInputText("Current Representative Payee", "Payee Test")
		.getSelectOptionsBySelector("select[id$='mentalHealthEmot_unselected']")
		.then(function(partGaurdType) {
			assert.deepEqual(["0", "1", "2","3", "4", "5", "6", "7", "8", "9", "10", "11"], partGaurdType);	
		})		
	    .chooseMultiSelectOption("Reason Category: Mental Health/Emotional", ["Victim of Discrimination"])
		.waitForVisible("span[id$='statusMental_Health.start']",defaultOperationTimeout,true)
		.getSelectOptionsBySelector ("select[id$='clearReason_MentalHealth_input2']")
		.then(function(discrimination) {
			assert.deepEqual(["", "Gender", "Race", "Sexual Orientation"], discrimination);
		})		
		.selectByValue("select[id$='clearReason_MentalHealth_input2']","Race")
		.getSelectOptionsBySelector("select[id$='schoolProb_unselected']")
		.then(function(schoolProb) {
			assert.deepEqual(["0", "1", "2","3"], schoolProb);	
		})		
	    .chooseMultiSelectOption("Reason Category: School Problems", ["Truancy"])
		.getSelectOptionsBySelector("select[id$='medicProb_unselected']")
		.then(function(schoolProb) {
			assert.deepEqual(["0", "1", "2"], schoolProb);	
		})		
	    .chooseMultiSelectOption("Reason Category: Medical Problems", ["Client Health"])
		.getSelectOptionsBySelector("select[id$='physEnv_unselected']")
		.then(function(schoolProb) {
			assert.deepEqual(["0", "1", "2", "3", "4", "5"], schoolProb);	
		})		
	    .chooseMultiSelectOption("Reason Category: Physical Environment", ["Food Needs"])
		.getSelectOptionsBySelector("select[id$='behavProb_unselected']")
		.then(function(schoolProb) {
			assert.deepEqual(["0", "1", "2", "3", "4", "5", "6", "7", "8"], schoolProb);	
		})		
	    .chooseMultiSelectOption("Reason Category: Behavioral Problems", ["Assault"])
		.fillInputText("Communication Summary","Communication Summary Test")
		.fillInputText("ADL Summary","ADL Summary Test")
		.fillInputText("Reason for Referral", "This is my reason for referral.......")
		.fillInputText("Update Notes", "This is my updated notes.........")
		//Created By
		//Last Modified By
		.getSelectOptions("Is the person at risk of an out of home placement?")
		.then(function(perRisk) {
			assert.deepEqual(["", "Yes", "No", "Unknown" ], perRisk);
		})
		.chooseSelectOption("Is the person at risk of an out of home placement?","Yes")
		.waitForVisible("span[id$='statusPlaceRisk.start']",defaultOperationTimeout,true)
		.getSelectOptions("How great is the risk?")
		.then(function(howRisk) {
			assert.deepEqual(["", "Low", "Moderate", "High", "Placement Pending" ], howRisk);
		})
		.chooseSelectOption("How great is the risk?","Low")
		.getSelectOptions("Select the type of placement that would be most likely to occur, should an out of home placement be required:")
		.then(function(selectReq) {
			assert.deepEqual(["", "Foster Care", "Relative", "Youth Academy/Training Center", 
			"Psychiatric Hospitalization", "Secure Detention", "Group Home", 
			"Residential Treatment Facility", "Respite/Emergency Shelter", 
			"Inpatient Substance Abuse Treatment", "Group Home (Juvenile Services)",
			"Other (specify)" ], selectReq);
		})
		.chooseSelectOption("Select the type of placement that would be most likely to occur, should an out of home placement be required:","Other (specify)")
		.waitForVisible("span[id$='statusPlaceTypeRisk.start']",defaultOperationTimeout,true)
		.setValue("div[id$=placementRiskBlock] input","Other (specify) Test")
		.getSelectOptions("Does the person have a history of placement (past or current)?")
		.then(function(pastPlace) {
			assert.deepEqual(["", "Yes", "No", "Unknown" ], pastPlace);
		})
		.chooseSelectOption("Does the person have a history of placement (past or current)?","Yes")
		.waitForVisible("span[id$='statusPlaceHx.start']",defaultOperationTimeout,true)
		.getSelectOptions("Is this a reunification process due to recent placement back in the home/community?")
		.then(function(reProc) {
			assert.deepEqual(["", "Yes", "No" ], reProc);
		})	
		.chooseSelectOption("Is this a reunification process due to recent placement back in the home/community?","Yes")		
		.getSelectOptions("Is the person currently in an out of home placement?")
		.then(function(curplace) {
			assert.deepEqual(["", "Yes", "No", "Unknown" ], curplace);
		})
		.chooseSelectOption("Is the person currently in an out of home placement?","Yes")
		.waitForVisible("span[id$='statusPlaceCur.start']",defaultOperationTimeout,true)
		.getSelectOptions("Is the plan to return the person to home/community?")
		.then(function(planHome) {
			assert.deepEqual(["", "Yes", "No" ], planHome);
		})
		.chooseSelectOption("Is the plan to return the person to home/community?","Yes")
		.getSelectOptions("Select the type of the current out of home placement:")
		.then(function(selectReqhome) {
			assert.deepEqual(["", "Foster Care", "Relative", "Youth Academy/Training Center", 
							"Psychiatric Hospitalization", "Secure Detention", "Group Home", 
							"Residential Treatment Facility", "Respite/Emergency Shelter", 
							"Inpatient Substance Abuse Treatment", "Group Home (Juvenile Services)",
							"Other (specify)" ], selectReqhome);
		})	
		.chooseSelectOption("Select the type of the current out of home placement:","Other (specify)")
		.waitForVisible("span[id$='statusPlaceTypeCur.start']",defaultOperationTimeout,true)
		//.setValue("div[id$='PlacementHxBlockSection'] input","Other (specify) Test")
		.getSelectOptions("The person is not currently in an out of home placement but has a history of placements")
		.then(function(histPlace) {
			assert.deepEqual(["", "Yes", "No" ], histPlace);
		})	
		.chooseSelectOption("The person is not currently in an out of home placement but has a history of placements","Yes")
		.fillInputText("Foster Care (how many times?)","1")
		.fillInputText("Relative (how many times?)","1")
		.fillInputText("Psychiatric Hospitalization (how many times?)","1")
		.fillInputText("Group Home (Juvenile Services) (how many times?)","1")
		.fillInputText("Secure Detention (how many times?)","1")
		.fillInputText("Group Home (how many times?)","1")
		.fillInputText("Residential Treatment Facility (how many times?)","1")
		.fillInputText("Respite/Emergency Shelter (how many times?)","1")
		.fillInputText("Long Term Secure Confinement (how many times?)","1")
		.fillInputText("Inpatient Substance Abuse Treatment (how many times?)","1")
		.fillInputText("Other (how many times?)","1")
		.waitForVisible("span[id$='statusPlaceOtherCount.start']",defaultOperationTimeout,true)
		.waitForVisible("div[class='errorMsg']",defaultOperationTimeout,true)
		//.setValue("div[id$='placementRiskBlock'] input","1")
		.getSelectOptions("Previous Juvenile Services Involvement?")
		.then(function(prevSer) {
			assert.deepEqual(["", "Yes", "No" ], prevSer);
		})
		.getSelectOptions("Current Juvenile Services Involvement?")
		.then(function(curServ) {
			assert.deepEqual(["", "Yes", "No" ], curServ);
		})
		.getSelectOptions("Is this charge considered a misdemeanor?")
		.then(function(misdem) {
			assert.deepEqual(["", "Yes", "No" ], misdem);
		})
		.getSelectOptions("Is this client considered pre-court with charges pending?")
		.then(function(precour) {
			assert.deepEqual(["", "Yes", "No" ], precour);
		})
		.getSelectOptions("Is this client currently on probation?")
		.then(function(curproba) {
			assert.deepEqual(["", "Yes", "No" ], curproba);
		})
		.getSelectOptions("Is this client a repeat offender?")
		.then(function(repeoff) {
			assert.deepEqual(["", "Yes", "No" ], repeoff);
		})
		.getSelectOptions("Is this charge considered a felony?")
		.then(function(confel) {
			assert.deepEqual(["", "Yes", "No" ], confel);
		})
		.getSelectOptions("Is this client adjudicated delinquent?")
		.then(function(adjDel) {
			assert.deepEqual(["", "Yes", "No" ], adjDel);
		})
		.getSelectOptions("Is this client receiving after care supervision?")
		.then(function(careSuper) {
			assert.deepEqual(["", "Yes", "No" ], careSuper);
		})
		.chooseSelectOption("Previous Juvenile Services Involvement?", "Yes")
		.waitForActionStatusDisappearance("statusPrevJuv", defaultOperationTimeout)
		.chooseSelectOption("Current Juvenile Services Involvement?", "Yes")
		.waitForActionStatusDisappearance("statusCurrJuv", defaultOperationTimeout)
		.fillInputText("Current Charges", "Current Charges Test")
		.chooseSelectOption("Is this charge considered a misdemeanor?", "Yes")
		.waitForActionStatusDisappearance("statusMis", defaultOperationTimeout)
		.chooseSelectOption("Is this charge considered a felony?", "Yes")
		.waitForActionStatusDisappearance("statusFel", defaultOperationTimeout)      
		.chooseSelectOption("Is this client considered pre-court with charges pending?", "No")
		.chooseSelectOption("Is this client currently on probation?", "No")
		.chooseSelectOption("Is this client a repeat offender?", "No")
		.chooseSelectOption("Is this client adjudicated delinquent?", "No")
		.chooseSelectOption("Is this client receiving after care supervision?", "No")
		
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
		.chooseSelectOption("Close Reason", "Error")
		.fillInputText("Close Comment", "Close Comment Test")
		.click("input[value='Add Location']")
        .waitForVisible("span[id$=ReferralLocationModal]", defaultOperationTimeout)
        .click("span[id$=ReferralLocationModal] a#aliaslookup")
        .waitForVisible("span[id$=searchDialog] input[value='First']", defaultOperationTimeout)
        .setValue("input[id$=addlocationstate]", "OH")
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
		.getSelectOptionsBySelector("select[id$='servicesRequested_unselected']")
		.then(function(ServicesRequested) {
			assert.deepEqual(["0", "2", "3", "4", "5"], ServicesRequested);
		})		
	    .chooseMultiSelectOption("Services Requested", ["ADT"])
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
		.selectCheckbox("Gang Involvement")
		.selectCheckbox("Theft")
		.selectCheckbox("Legal History")
		.selectCheckbox("Law Enforcement Involvement")
		.selectCheckbox("Adjudicated offense status")
		.waitForActionStatusDisappearance("statusAdjudicated_offense_status",defaultOperationTimeout)
		.selectCheckbox("Misdemeanor/s")
		.selectCheckbox("Felony/ies")
		.selectCheckbox("Property Destruction")
		.selectCheckbox("Tobacco Use (Current)")
		.selectCheckbox("Chemical Use (Recovery)")
		.selectCheckbox("Chemical Use (Current)")
		.selectCheckbox("Chemical Dependency Treatment")
		.selectCheckbox("Drug Possession/Distribution")
		.selectCheckbox("Elopement")
		.selectCheckbox("Unwanted Sexual Behavior")
		.selectCheckbox("Registered Sex Offender")
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
		.selectCheckbox("Animal Cruelty")
		.selectCheckbox("Victim of Domestic Violence")
		.selectCheckbox("Parental Disability")
		.selectCheckbox("Choking Risk")
		.selectCheckbox("History of Bowel Obstructions")
		.selectCheckbox("Takes Injectible Medications")
		.selectCheckbox("Ventilator Dependent")
		.selectCheckbox("Eating Disorders")
		.selectCheckbox("Ingesting Non-Consumables")
		.selectCheckbox("Psychiatric/Mental Hospitalization")
		.selectCheckbox("Hospitalization Within the Past Year")
		.fillInputText("Programming Considerations Comments","Programming Considerations Comments Test")
		.click("input[value='Add Funding Source']")
        .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
        .getSelectOptions("Funding Source")
        .then(function(funSource) {
         assert.deepEqual(["", "Juvenile Court", "Medicaid"], funSource);
         })
	    .chooseSelectOption("Funding Source", "Medicaid")
	    .click("span[id$=FundingSourceModal] input[value='Cancel']")
        .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
               
  }
});
