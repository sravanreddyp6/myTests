var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsMaNewBedfordReferralReferral", suiteTimeout, {
  "should create a Hastings MA Referral successfully": function(client, done) {
   var user = users["HS_AL_Auburn_Referral_Intaker"];
    return client
      .logInAs(users["HS_MA_NewBedford_Referral_Intaker"])
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .getSelectOptions("Race")
      .then(function(races) {
        assert.deepEqual([
          "", "Caucasian", "African American", "American Indian/Alaskan", "Asian/Pacific Islands",
          "Hispanic", "Middle Eastern", "Multi-Racial", "Other"
        ], races);
      })
      .getSelectOptions("Ethnicity")
      .then(function(ethnicities) {
        assert.deepEqual([
          "", "Aboriginal", "African", "Arab", "Balkan", "Baltic", "British Isles", "Caribbean",
          "Czech and Slovak", "East and Southeast Asian", "Eastern European", "European", "French",
          "Indo-Chinese", "Latin, Central, South American", "Maghrebi", "North American",
          "Northern European", "Oceania", "Other European", "Pacific Islands", "Scandinavian",
          "South Asian", "Southern European", "West Asian", "Western European", "Unknown"
        ], ethnicities);
      })
      .getSelectOptions("Marital Status")
      .then(function(status) {
        assert.deepEqual([
          "", "Single", "Married", "Divorced", "N/A"
        ], status);
      })
      .getSelectOptions("Primary Language")
      .then(function(languages) {
        assert.deepEqual([
          "", "English", "English creoles- Belize, Guyanese", "Jamaican Creole", "Italian",
          "French", "Patois", "French Creole", "Haitian Creole", "Cajun", "Spanish", "Portuguese",
          "Greek", "Albanian", "Russian", "Bielorussian", "German", "Austrian", "Swiss", "Swedish",
          "Danish", "Norwegian", "Icelandic", "Romanian", "Ukrainian", "Czech", "Polish", "Bosnian",
          "Croatian", "Serbian", "Armenian", "India, n.e.c.", "Hindi", "Bengali", "Afghani",
          "Pakistan, n.e.c.", "Turkish", "Chinese", "Cantonese", "Mandarin", "Taiwanese",
          "Shanghainese", "Miao, Hmong", "Hmong", "Japanese", "Korean", "Laotian",
          "Mon-Khmer, Cambodian", "Cambodian", "Khmer", "Vietnamese", "Muong", "Indonesian",
          "Arabic", "Hebrew"
        ], languages);
      })
      .getSelectOptions("Highest Level of Education")
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
      .getSelectOptions("Gender")
      .then(function(genders) {
        assert.deepEqual([
          "", "Male", "Female", "Transgender", "Other"
        ], genders);
      })
      .getSelectOptions("Mailing State/Province")
      .then(function(states) {
        assert.deepEqual([
          "", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
          "Delaware", "District of Columbia", "Florida", "Georgia", "Guam", "Hawaii", "Idaho",
          "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
          "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
          "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
          "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
          "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
          "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
        ], states);
      })
      .fillInputText("First Name", "Darth")
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freaking")
      .chooseSelectOption("Ethnicity", "North American")
      .fillInputText("Last Name", "Vader")
      .chooseSelectOption("Marital Status", "Divorced")
      .fillInputText("Date of Birth", "7/7/1970")  // not working yet because there are 2 DOB fields on the page
      .chooseSelectOption("Primary Language", "English")
      .fillInputText("Age", "25")
      .chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")
      .fillInputText("SSN", "111111111")
      .fillInputText("Additional Information / Comments", "Really hateful")
      .fillInputText("Mailing Street 1", "123 Something Street")
      .fillInputText("Mailing Street 2", "apt. 456")
      .fillInputText("Mailing City", "Massachusetts")
      .chooseSelectOption("Mailing State/Province", "Massachusetts")
      .fillInputText("Mailing Zip/Postal Code", "23456")
      .fillInputText("Mailing County", "Georgia County")
      .setValue("input[id$=Perm_Phone]", "6090210")
      .setValue("input[id$=Perm_Email]", "someone@something.com")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      
      .getSelectOptions("Type")
      .then(function(typeParty) {
        assert.deepEqual(["", "Caregiver", "Case Worker", "Employment", 
                          "Family/Friends", "Financial Worker", "Funder Resources",
                           "Guardian", "Insurance", "Medical", "Mentor",
                           "Mentor Co-Applicant", "Other", "Parent", "Physician - Alternate", 
                           "Physician - Primary", "Power of Attorney", "Referring Provider",
                            "Representative Payee", "Spouse"], typeParty);
      })
      .getSelectOptions("Phone 1 Type")
      .then(function(phon1Type) {
        assert.deepEqual(["", "Home", "Work", "Cell", "Fax"], phon1Type);
      })
      .getSelectOptions("Phone 2 Type")
      .then(function(phon2Type) {
        assert.deepEqual(["", "Home", "Work", "Cell", "Fax"], phon2Type);
      })
      .getSelectOptionsBySelector("[id$=relatedPartyEntry_Status]")
      .then(function(relPartyStatus) {
        assert.deepEqual(["", "Active", "Inactive"], relPartyStatus);
      })
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
      
      .getSelectOptions("Referral Status")
      .then(function(refStatus) {
        assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
      })
      .getSelectOptions("Referral Source Type")
      .then(function(refSrcType) {
          assert.deepEqual(["", "Attorney", "Counselor", "Family", "Hospital Case Manager", 
                            "Independent Case Manager", "Internal", "Juvenile Justice", 
                            "Other therapist", "Payor Case Manager","Physician", 
                            "Rehab/Hospital", "School", "Self", "Social Worker", 
                            "Unknown", "Other" ], refSrcType);
      })
      .getSelectOptionsBySelector("[id$=legalGuardian_status]")
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", 
                            "Guardian", "Health Care Representative", "Kinship", "Limited Guardianship", 
                            "Parent", "Self", "Shelter Care", "State Assumes Guardianship", 
                            "Voluntary Placement Agreement"], guardianStatus);
      })
      .getMultiSelectOptions("Reason Category: Mental Health/Emotional")
      .then(function(rescatMen) {
          assert.deepEqual(["Exposure to Violence", "Domestic Violence", "Grief", "Physical Abuse", "Sexual Abuse",
                            "Neglect", "Depression", "Suicidal Ideation/Attempts", "Transitional/Adjustment Problems",
                            "Eating Disorders",  "Vistim of Bullying", "Victim of Discrimination" ], rescatMen);
      })
      .getMultiSelectOptions("Reason Category: School Problems")
      .then(function(rescatProb) {
          assert.deepEqual(["Truancy", "Learning Disability", "Behavior", "Bullying" ], rescatProb);
      })
      .getSelectOptions("Discrimination Reason")
      .then(function(disReason) {
          assert.deepEqual(["", "Gender", "Race", "Sexual Orientation" ], disReason);
      })
      .getMultiSelectOptions("Reason Category: Medical Problems")
      .then(function(rescatMedProb) {
          assert.deepEqual(["Caregiver Health", "Client Health", "Physical Disability" ], rescatMedProb);
      })
      .getMultiSelectOptions("Reason Category: Physical Environment")
      .then(function(rescatPhE) {
          assert.deepEqual(["Homeless / Shelter Needs", "Food Needs", "Employment Needs", 
                            "Financial Needs", "Sanitation", "Safety Needs" ], rescatPhE);
      })
      .getMultiSelectOptions("Reason Category: Behavioral Problems")
      .then(function(rescatBeProb) {
          assert.deepEqual(["Juvenile Delinquency", "AWOL/Runaway", "Sex Offender",
                            "Parental Neglect", "Parenting Skills", "Assault",
                            "Property Damage", "Substance Abuse", "Personal Hygiene" ], rescatBeProb);
      })
      .getSelectOptions("If the referral is from the ICC has the care plan been submitted to the insurance company in order for us to obtain an authorization for services?")
      .then(function(Icc) {
          assert.deepEqual(["", "Yes", "No" ], Icc);
      })
      .chooseSelectOption("Referral Status", "Active")
      .chooseSelectOption("Referral Source Type", "Family")
      .waitForActionStatusDisappearance("statusRefSourceType", defaultOperationTimeout)
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Phone Number", "586356")
      .fillInputText("Referrer Street", "Somewhere")
      .fillInputText("Case Manager Name", "Qui Gon Jinn")
      .selectByValue("select[id$=legalGuardian_status]", "Kinship")
      .fillInputText("Referrer Name", "Some else")
      .fillInputText("Referrer Email", "Someone@something.com")
      .fillInputText("Billing ID", "something")
      .fillInputText("Case Manager Phone", "8675309")
      .fillInputText("Current Representative Payee", "Master Yoda")
      .selectByIndex("select[title='Reason Category: Mental Health/Emotional - Available']", 11)
      .click("a img[id$=mentalHealthEmot_right_arrow]")
      .waitForActionStatusDisappearance("statusMental_Health", defaultOperationTimeout)
      .selectByIndex("select[title='Reason Category: School Problems - Available']", 0)
      .click("a img[id$=schoolProb_right_arrow]")
      .chooseSelectOption("Discrimination Reason", "Gender")
      .selectByIndex("select[title='Reason Category: Medical Problems - Available']", 0)
      .click("a img[id$=medicProb_right_arrow]")
      .selectByIndex("select[title='Reason Category: Physical Environment - Available']", 0)
      .click("a img[id$=physEnv_right_arrow]")
      .selectByIndex("select[title='Reason Category: Behavioral Problems - Available']", 0)
      .click("a img[id$=behavProb_right_arrow]")
      .chooseSelectOption("If the referral is from the ICC has the care plan been submitted to the insurance company in order for us to obtain an authorization for services?", "Yes")
      .fillInputText("Describe Any Household Pets", "Test")
      .fillInputText("Goals from the Referral Source", "Test")
      .fillInputText("Reason for Referral", "Test")
      .fillInputText("Update Notes", "Test")
      
      .getSelectOptions("Is the person at risk of an out of home placement?")
      .then(function(perRisk) {
          assert.deepEqual(["", "Yes", "No", "Unknown" ], perRisk);
      })
      .getSelectOptions("How great is the risk?")
      .then(function(howRisk) {
          assert.deepEqual(["", "Low", "Moderate", "High", "Placement Pending" ], howRisk);
      })
      .getSelectOptions("Select the type of placement that would be most likely to occur, should an out of home placement be required:")
      .then(function(selectReq) {
          assert.deepEqual(["", "Foster Care", "Relative", "Youth Academy/Training Center", 
                            "Psychiatric Hospitalization", "Secure Detention", "Group Home", 
                            "Residential Treatment Facility", "Respite/Emergeny Shelter", 
                            "Inpatient Substance Abuse Treatment", "Group Home (juvenile Serviles)",
                             "Other (specify)" ], selectReq);
      })
      .getSelectOptions("Does the person have a history of placement (past or current)?")
      .then(function(pastPlace) {
          assert.deepEqual(["", "Yes", "No", "Unknown" ], pastPlace);
      })
      .getSelectOptions("Is this a reunification process due to recent placement back in the home/community?")
      .then(function(reProc) {
          assert.deepEqual(["", "Yes", "No" ], reProc);
      })
      .getSelectOptions("Is the person currently in an out of home placement?")
      .then(function(curplace) {
          assert.deepEqual(["", "Yes", "No", "Unknown" ], curplace);
      })
      .getSelectOptions("Is the plan to return the person to home/community?")
      .then(function(planHome) {
          assert.deepEqual(["", "Yes", "No" ], planHome);
      })
      .getSelectOptions("Select the type of the current out of home placement:")
      .then(function(selectReqhome) {
          assert.deepEqual(["", "Foster Care", "Relative", "Youth Academy/Training Center", 
                            "Psychiatric Hospitalization", "Secure Detention", "Host Home", 
                            "Residential Treatment Facility", "Respite/Emergeny Shelter", 
                            "Inpatient Substance Abuse Treatment", "Group Home (juvenile Serviles)",
                             "Other (specify)" ], selectReqhome);
      })
      .getSelectOptions("The person is not currently in an out of home placement but has a history of placements")
      .then(function(histPlace) {
          assert.deepEqual(["", "Yes", "No" ], histPlace);
      })
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
      .chooseSelectOption("Is the person at risk of an out of home placement?", "Yes")
      .waitForActionStatusDisappearance("statusPlaceRisk", defaultOperationTimeout)
      .chooseSelectOption("How great is the risk?", "Low")
      .chooseSelectOption("Select the type of placement that would be most likely to occur, should an out of home placement be required:", "Other (specify)")
      .waitForActionStatusDisappearance("statusPlaceTypeRisk", defaultOperationTimeout)
      .fillInputText("Other (specify)", "Test")
      .chooseSelectOption("Does the person have a history of placement (past or current)?", "Yes")
      .waitForActionStatusDisappearance("statusPlaceHx", defaultOperationTimeout)
      .chooseSelectOption("Is this a reunification process due to recent placement back in the home/community?", "No")
      .chooseSelectOption("Is the person currently in an out of home placement?", "Yes")
      .waitForActionStatusDisappearance("statusPlaceCur", defaultOperationTimeout)
      .chooseSelectOption("Is the plan to return the person to home/community?", "No")
      .chooseSelectOption("Select the type of the current out of home placement:", "Other (specify)")
      .waitForActionStatusDisappearance("statusPlaceTypeCur", defaultOperationTimeout)
      .fillInputText("Other (specify)", "Test")
      .chooseSelectOption("The person is not currently in an out of home placement but has a history of placements", "No")
      .fillInputText("Foster Care (how many times?)", "2")
      .fillInputText("Relative (how many times?)", "2")
      .fillInputText("Psychiatric Hospitalization (how many times?)", "2")
      .fillInputText("Group Home (Juvenile Services) (how many times?)", "2")
      .fillInputText("Secure Detention (how many times?)", "2")
      .fillInputText("Other (how many times?)", "2")
      .waitForActionStatusDisappearance("statusPlaceOtherCount", defaultOperationTimeout)
      .fillInputText("Group Home (how many times?)", "2")
      .fillInputText("Residential Treatment Facility (how many times?)", "2")
      .fillInputText("Respite/Emergency Shelter (how many times?)", "2")
      .fillInputText("Long Term Secure Confinement (how many times?)", "2")
      .fillInputText("Inpatient Substance Abuse Treatment (how many times?)", "2")
      .fillInputText("Other (specify)", "Test")
      .chooseSelectOption("Previous Juvenile Services Involvement?", "Yes")
      .waitForActionStatusDisappearance("statusPrevJuv", defaultOperationTimeout)
      .chooseSelectOption("Current Juvenile Services Involvement?", "Yes")
      .waitForActionStatusDisappearance("statusCurrJuv", defaultOperationTimeout)
      .fillInputText("Current Charges", "Something")
      .chooseSelectOption("Is this charge considered a misdemeanor?", "Yes")
      .waitForActionStatusDisappearance("statusMis", defaultOperationTimeout)
      .chooseSelectOption("Is this client considered pre-court with charges pending?", "No")
      .chooseSelectOption("Is this client currently on probation?", "No")
      .chooseSelectOption("Is this client a repeat offender?", "No")
      .chooseSelectOption("Is this charge considered a felony?", "Yes")
      .waitForActionStatusDisappearance("statusFel", defaultOperationTimeout)
      .chooseSelectOption("Is this client adjudicated delinquent?", "No")
      .chooseSelectOption("Is this client receiving after care supervision?", "No")
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .click("a[id$=originlookup]")
      .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=originstate]","MN")
      .click("span[id$=searchDialog2] input[value='Search!']")
      .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
      //.click("span[id$=searchDialog] a:first")
      .element("span[id$=searchDialog2] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
      .click("input[value='Add Location']")
      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
      
      .getSelectOptionsBySelector("[id$=locationEntry_Status]")
      .then(function(locStatus) {
          assert.deepEqual(["", "New", "Active", "On Hold", "Closed"], locStatus);
      })
      .click("a[id$=aliaslookup]")
      .waitForVisible("input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=addlocationstate]","MN")
      .click("span[id$=searchDialog] input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.click("span[id$=searchDialog] a:first")
      .element("span[id$=searchDialog] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
      .selectLookup("User Assigned")
      .switchToNextWindow()
      .waitForVisible("#searchFrame", defaultOperationTimeout)
      //.element("#resultsFrame a")
      //.then(function (el) {
      //	return this.elementIdClick(el.value.ELEMENT);
      //})
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
      
      .getSelectOptions("Program Category")
      .then(function(progCat) {
          assert.deepEqual(["", "IDD", "ARY"], progCat);
      })
      .getMultiSelectOptions("Service Line")
      .then(function(serLine) {
          assert.deepEqual(["Group Home", "Host Home", "Periodic (Other)", "Day Program", 
                            "Early Intervention", "Home Health", "ICF/Group Home", 
                            "Supported Living", "Outpatient Services", "Schools" ], serLine);
      })
      .getMultiSelectOptions("Services Requested")
      .then(function(serReq) {
          assert.deepEqual(["Host Home", "Periodic Services", "ICF", "Med Waiver Group Home", "ADT",
                            "FCT - Family Centered Treatment", "Crisis Stabilization", 
                            "Therapeutic Support" ], serReq);
      })
      .fillInputText("Axis I", "some 1")
      .fillInputText("Axis II", "some 2")
      .fillInputText("Axis III", "some 3")
      .fillInputText("Axis IV", "some 4")
      .fillInputText("Axis V", "some 5")
      .fillInputText("Communication Summary", "test")
      .fillInputText("ADL Summary", "test")
      .chooseSelectOption("Program Category", "IDD")
      .selectByIndex("select[title='Service Line - Available']", 0)
      .click("a img[id$=servicesLine_right_arrow]")
      .selectByIndex("select[title='Services Requested - Available']", 0)
      .click("a img[id$=servicesRequested_right_arrow]")
      .fillInputText("Family History", "test")
      .fillInputText("Medical History", "test")
      .fillInputText("Behavior Summary", "test")
      .fillInputText("Current Medications", "test")
      .fillInputText("Prior Program Information", "test")
      .fillInputText("Comments", "test")
      .click("input[value='Add Agency Involved With Individual']")
      .fillInputText("Agency Name:", "test")
      .fillInputText("Address:", "404 test street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "test")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .click("input[value='Add Funding Source']")
      .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
      
      .getSelectOptions("Funding Source")
      .then(function(funSource) {
          assert.deepEqual(["", "Beacon Health Strategies", "Massachusetts Behavioral Health Partnership", 
                            "Network Health"], funSource);
      })
      .getSelectOptions("Service Being Funded")
      .then(function(serbfun) {
          assert.deepEqual(["", "Host Home", "Periodic Services", "ICF", "Med Waiver Group Home", 
                             "ADT", "FCT-Family Centered Treatment", "Crisis Stabilization", 
                             "Therapeutic Support"], serbfun);
      })
      .getSelectOptionsBySelector("[id$=fundingEntry_Status]")
      .then(function(funStatus) {
          assert.deepEqual(["", "Pending Approval", "Authorized"], funStatus);
      })
      .chooseSelectOption("Funding Source", "Beacon Health Strategies")
      .fillInputText("Funding Source ID", "test")
      .chooseSelectOption("Service being Funded", "Host Home")
      .chooseSelectOption("[id$=fundingEntry_Status]", "Pending Approval")
      .selectByValue("span[id$=FundingSourceModal] select[id$=fundingEntry_Status]", "Pending Approval")
      .setValue("span[id$=FundingSourceModal] textarea[id$=fundingEntry_comment]", "test")
      .click("span[id$=FundingSourceModal] input[value='Save']")
      .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
      .click("input[value='Add Referral Tracking Task']")
      .waitForVisible("span[id$=ActivityModal] input[value='Save']", defaultOperationTimeout)
      .setValue("input[id$=activityEntry_Subject]","CN")
      .fillInputText("Due Date", "10/25/2015")
      .setValue("span[id$=ActivityModal] textarea[id$=activityEntry_Comments__c]", "This is a Test")
      .click("span[id$=ActivityModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
            
      .getSelectOptions("Staffing Needs")
      .then(function(vals) {
          assert.deepEqual(["", "Night Sleep", "Night Awake"], vals);
      })
      .getSelectOptions("Staffing Ratio")
      .then(function(vals) {
          assert.deepEqual(["","1:1","1:2","1:3","1:4","Other"], vals);
      })
      .getSelectOptions("Desired Living Environment")
      .then(function(vals) {
          assert.deepEqual(["", "ICF", "Supported Living", "Group Home", "With Family", 
                            "With Foster Family", "With Housemates", "Alone"], vals);
      })
      .getSelectOptions("Preferred Setting")
      .then(function(vals) {
          assert.deepEqual(["", "Urban", "Suburban", "Rural" , "No Preference"], vals);
      })
      .getSelectOptions("Mobility")
      .then(function(vals) {
          assert.deepEqual(["", "Ambulatory", "Wheelchair", "Uses Walker" , "Uses Cane"], vals);
      })
      .getSelectOptions("If Yes, How Many?")
      .then(function(yesMany) {
          assert.deepEqual(["", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                            "11", "12" ], yesMany);
      })
      .getSelectOptions("If Yes, Age Requirements?")
      .then(function(yesAge) {
          assert.deepEqual(["", "Older", "Younger", 
                            "Age Is Not a Factor" ], yesAge);
      })
      .getSelectOptions("If Yes, Level?")
      .then(function(yesLevel) {
          assert.deepEqual(["", "Frequent Visitation", "Limited Visitation", "Supervised Visitation",
           "Unsupervised Visitation", "No Contact" ], yesLevel);
      })
      .chooseSelectOption("Staffing Needs", "Night Sleep")
      .chooseSelectOption("Staffing Ratio", "1:2")
      .chooseSelectOption("Desired Living Environment", "ICF")
      .chooseSelectOption("Preferred Setting", "Urban") 
      .chooseSelectOption("Mobility", "Uses Walker")
      .selectCheckbox("Accessible Housing Needed")
      .selectCheckbox("Accessible Vehicle Needed")
      .selectCheckbox("Geographic Restrictions")
      .fillInputText("Area of State Interested In", "test")
      .selectCheckbox("Access to Public Transportation") 
      .selectCheckbox("Physically Aggressive to Staff") 
      .selectCheckbox("Physically Aggressive to Self") 
      .selectCheckbox("Physically Aggressive to Peers")
      .selectCheckbox("Verbally Aggressive")
      .selectCheckbox("Suicide Threats") 
      .selectCheckbox("Suicide Attempts")
      .selectCheckbox("Self Harm or Self-Injurious Behaviors")
      .selectCheckbox("Fire Setting")
      .selectCheckbox("Property Destruction")
      .selectCheckbox("Gang Involvement") 
      .selectCheckbox("Theft")
      .selectCheckbox("Legal History")
      .selectCheckbox("Law Enforcement Involvement")
      .selectCheckbox("Adjudicated offense status")
      .selectCheckbox("Tobacco Use (Current)")
      .selectCheckbox("Chemical Use (Recovery)") 
      .selectCheckbox("Chemical Use (Current)")
      .selectCheckbox("Chemical Dependency Treatment")
      .selectCheckbox("Drug Possession/Distribution") 
      .selectCheckbox("Elopement")
      .selectCheckbox("Unwanted Sexual Behavior")
      .selectCheckbox("Registered Sex Offender") 
      .selectCheckbox("Nursing Oversight Required")
      .fillInputText("If Yes, Level of Support Required", "test1")
      .selectCheckbox("Unsupervised Time")
      .fillInputText("If Yes, Length of time", "1")
      .selectCheckbox("Maintain Sibling Group")
      .chooseSelectOption("If Yes, How Many?", "5")
      .selectCheckbox("No Same Sex Peers")
      .selectCheckbox("Can Live with Opposite Sex")
      .selectCheckbox("No Cross Cultural Placement") 
      .selectCheckbox("Can Be Placed With Other Children")
      .chooseSelectOption("If Yes, Age Requirements?", "Older")
      .selectCheckbox("Family Involvement Restrictions")
      .chooseSelectOption("If Yes, Level?", "Limited Visitation")
      .selectCheckbox("Animal Cruelty")
      .selectCheckbox("Choking Risk")
      .selectCheckbox("Eating Disorders") 
      .selectCheckbox("History of Bowel Obstructions")
      .selectCheckbox("Ingesting Non-Consumables") 
      .selectCheckbox("Takes Injectible Medications")
      .selectCheckbox("Psychiatric/Mental Hospitalization")
      .selectCheckbox("Ventilator Dependent") 
      .selectCheckbox("Hospitalization Within the Past Year")
      .setValue("textarea[id$=ProgConsComment]", "test")
      
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
      })
      .isExisting("input[value='Convert']")
      .then(function(isExisting) {
    	 assert.Ok(isExisting, "Convert Button exists.");
      })      
      .getOutputText("First Name")
      .then(function (firstName) {
        assert.equal("Darth", firstName);
      })
      .getOutputText("Race")
      .then(function (race) {
        assert.equal("Caucasian", race);
      })
      .getOutputText("Referral Source")
      .then(function (source) {
        assert.equal("Mentor", source);
      })
      .getOutputText("Referrer Name")
      .then(function (name) {
        assert.equal("Obi-wan Kennobi", name);
      });
  }
});