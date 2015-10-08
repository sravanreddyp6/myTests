var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsGaSavannahReferral", suiteTimeout, {
  "should create a Hastings Ga Referral successfully": function(client, done) {
   var user = users["HS_AL_Auburn_Referral_Intaker"];
    return client
      .logInAs(users["HS_GA_Savannah_Referral_Intaker"])
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
      .fillInputText("Mailing City", "Georgia")
      .chooseSelectOption("Mailing State/Province", "Georgia")
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
          assert.deepEqual(["", "Attorney", "Family", "Hospital Case Manager", 
                            "Independent Case Manager", "Internal", "Payor Case Manager", 
                            "Physician", "Rehab/Hospital", "School", "Self", "Social Worker", 
                            "Other" ], refSrcType);
      })
      .getSelectOptionsBySelector("[id$=legalGuardian_status]")
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", 
                            "Guardian", "Health Care Representative","Kinship", "Limited Guardianship", 
                            "Parent", "Self", "Shelter Care", "State Assumes Guardianship", 
                            "Voluntary Placement Agreement"], guardianStatus);
      })
      .chooseSelectOption("Referral Status", "Active")
      .chooseSelectOption("Referral Source Type", "Family")
      .waitForActionStatusDisappearance("statusRefSourceType", defaultOperationTimeout)
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
      .fillInputText("Referrer Phone Number", "586356")
      .fillInputText("Case Manager Name", "Qui Gon Jinn")
      .fillInputText("Billing ID", "something")
      .fillInputText("Case Manager Phone", "8675309")
      .fillInputText("Current Representative Payee", "Master Yoda")
      .selectByValue("select[id$=legalGuardian_status]", "Kinship")
      .fillInputText("Reason for Referral", "Test")
      .fillInputText("Update Notes", "Test")
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
          assert.deepEqual(["Group Home", "Host Home", "Periodic (Other)", "Day Program", "Early Intervention",
                            "Home Health", "ICF/Group Home", "Supported Living", "Outpatient Services", "Schools" ], serLine);
      })
      .getMultiSelectOptions("Services Requested")
      .then(function(serReq) {
          assert.deepEqual(["Host Home", "Respite", "Nursing - LPN", "Nursing - RN", "CAI",
                            "CAG", "SMS", "Behavior Supports", "Traditional", "Base", "Max",
                            "SBWO", "SMWO", "SMFWO", "MAAC", "MAAC Respite Services", "FIT Wraparound",
                            "FIT", "Adoption Placement" ], serReq);
      })
      .fillInputText("Axis I", "some 1")
      .fillInputText("Axis II", "some 2")
      .fillInputText("Axis III", "some 3")
      .fillInputText("Axis IV", "some 4")
      .fillInputText("Axis V", "some 5")
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
      .setValue("textarea[id$=DiagComments]", "test")
      .click("input[value='Add Agency Involved With Individual']")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
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
          assert.deepEqual(["", "Medicaid", "Medicare", "AFDC", "DFCS", 
                             "DJJ Region 1", "DJJ Region 2", "DJJ Region 3", "DJJ Region 4", 
                              "DJJ Region 5", "Military VA Benefits", "Value Behavorial Health", "Etna",
                              "Blue Cross Blue Shield", "Oxford", "Physician Health Services", "MAAC",
                              "MIERS", "Office of Adoption", "State Adoption Unit", "Childnet", "CSB",
                               "Self Pay", "SSDI", "SSI", "Other"], funSource);
      })
      .getSelectOptions("Service Being Funded")
      .then(function(serbfun) {
          assert.deepEqual(["", "Host Home", "Respite", "Nursing - LPN", "Nursing - RN", 
                             "CAI", "CAG", "SMS", "Behavior Supports", "Traditional", 
                             "Base", "Max", "SBWO", "SMWO", "SMFWO", "MAAC",  
                              "MAAC Respite Services", "FIT Wraparound", "FIT", "Adoption Placement"], serbfun);
      })
      .getSelectOptionsBySelector("[id$=fundingEntry_Status]")
      .then(function(funStatus) {
          assert.deepEqual(["", "Pending Approval", "Authorized"], funStatus);
      })
      .chooseSelectOption("Funding Source", "Medicaid")
      .fillInputText("Funding Source ID", "test")
      .chooseSelectOption("Service Being Funded", "Host Home")
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
      .getSelectOptions("if Yes, Type")
      .then(function(yesType) {
          assert.deepEqual(["", "Issue", "Aggression", "Acting Out"], yesType);
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
      .getMultiSelectOptions("Restricted Health Conditions")
      .then(function(resHeCond) {
          assert.deepEqual(["Feeding Tube", "Breathing Monitor", "Heart/BP Monitor", "Trach", 
                            "Infectious Diseases", "Seizure Disorder", "Speech Therapy", 
                            "Occupational Therapy", "Physical Therapy" ], resHeCond);
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
      .selectCheckbox("Legal History")
      .selectCheckbox("Law Enforcement Involvement")
      .selectCheckbox("Property Destruction") 
      .selectCheckbox("Tobacco Use (Current)")
      .selectCheckbox("Chemical Use (Recovery)") 
      .selectCheckbox("Chemical Use (Current)")
      .selectCheckbox("Chemical Dependency Treatment")
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
      .selectCheckbox("Animal Cruelty")
      .selectCheckbox("Choking Risk")
      .selectCheckbox("Eating Disorders") 
      .selectCheckbox("History of Bowel Obstructions")
      .selectCheckbox("Ingesting Non-Consumables") 
      .selectCheckbox("Takes Injectible Medications")
      .selectCheckbox("Psychiatric/Mental Hospitalization")
      .selectCheckbox("Ventilator Dependent") 
      .selectCheckbox("Hospitalization Within the Past Year")
      .selectByIndex("select[title='Restricted Health Conditions - Available']", 0)
      .click("a img[id$=resrictHealthCond_right_arrow]")
      .setValue("textarea[id$=ProgConsComment]", "test")
      .waitForVisible("input[value=nothing]", defaultOperationTimeout)
      
      .click("input[value='Save Referral']")
      .waitForVisible("input[value=Edit]", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
      })
      .isExisting("input[value='Convert']")
      .then(function(isExisting) {
    	 assert.notOk(isExisting, "Convert Button exists.");
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
