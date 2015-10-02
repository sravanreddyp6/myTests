var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsNjReferral", suiteTimeout, {
  "should create a Hastings NJ Referral successfully": function(client, done) {
    return client
      .logInAs(users["HS_NJ_Referral_Intaker"])
      .click("a=Create New Referral")
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
      // .fillInputText("Date of Birth", "7/7/1970")  // not working yet because there are 2 DOB fields on the page
      .chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")
      .fillInputText("SSN", "111111111")
      .fillInputText("Additional Information / Comments", "Really hateful")
      .fillInputText("Mailing Street 1", "11 Main street")
      .fillInputText("Mailing Street 2", "apt 1")
      .fillInputText("Mailing City", "somewhere")
      .chooseSelectOption("Mailing State/Province", "New Jersey")
      .fillInputText("Mailing Zip/Postal Code", "11111")
      .fillInputText("Mailing County", "somewhere else")
      .fillInputText("Phone", "8001111")
      .fillInputText("Email", "someone@somewhere.com")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .click("input[value='Add Related Party']")
      
      .getSelectOptions("Type")
      .then(function(typeParty) {
        assert.deepEqual(["", "Caregiver", "Case Worker", "Employment", 
                          "Family/Friends", "Financial Worker", "Funder Resources",
                           "Guardian", "Insurance", "Medical", "Mentor",
                           "Mentor Co-Applicant", "Other", "Parent", "Physician - Alternative", 
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
      .getSelectOptions("[id$=relatedPartyEntry_Status]")
      .then(function(partStatus) {
        assert.deepEqual(["", "Active", "Inactive"], partStatus);
      })
      .fillInputText("Party Name", "Party")
      .chooseSelectOption("Type", "Caregiver")
      .fillInputText("Address", "Somewhere")
      .fillInputText("Email", "Someone@something.com")
      .fillInputText("Phone 1", "8888888")
      .fillInputText("Phone 2", "7777777")
      .chooseSelectOption("Phone 1 Type", "Home")
      .chooseSelectOption("Phone 2 Type", "Cell")
      .fillInputText("Comments", "This is a test")
      .chooseSelectOption("[id$=relatedPartyEntry_Status]", "Active")
      .click("input[value='Save']")
      
      .getSelectOptions("Referral Status")
      .then(function(refStatus) {
        assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
      })
      .getSelectOptions("Referral Source Type")
      .then(function(refSrcType) {
          assert.deepEqual(["", "Attorney", "Family", "Hospital Case Manager", 
                            "Independent Case Manager", "Internal", "Payor Case Manager",
                            "Physician", "Rehab/Hospital", "School", "Self", "Social Worker", 
                            "Unknown", "Other" ], refSrcType);
      })
      .getSelectOptions("Legal/Guardianship Status")
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", 
                            "Guardian", "Health Care Representative", "Kinship", 
                            "Limited Guardianship", "Parent", "Self", "Shelter Care", 
                            "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
      })
      .chooseSelectOption("Referral Status", "Active")
      .chooseSelectOption("Referral Source Type", "Family")
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
      .fillInputText("Referrer Phone Number", "586356")
      .fillInputText("Case Manager Name", "Qui Gon Jinn")
      .chooseSelectOption("Legal/Guardianship Status", "Kinship")
      .fillInputText("CYBER ID Number", "8675309")
      .fillInputText("Spirit Case Number", "123")
      .fillInputText("Billing ID", "something")
      .fillInputText("Case Manager Phone", "8675309")
      .fillInputText("Current Representative Payee", "Master Yoda")
      .fillInputText("CYBER Referral Number", "456")
      .fillInputText("Spirit Person Number", "789")
      .fillInputText("Reason for Referral", "Test")
      .fillInputText("Update Notes", "Test")
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .fillInputText("Alias", "Test")
      .click("input[value='Add Location']")
      
      .getSelectOptions("[id$=locationEntry_Status]")
      .then(function(locStatus) {
          assert.deepEqual(["", "New", "Active", "On Hold", "Closed"], locStatus);
      })
      .fillInputText("User Assigned", "Darth Maul")
      .chooseSelectOption("[id$=locationEntry_Status]", "Active")
      .click("input[value='Save']")
      
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
          assert.deepEqual(["Host Home", "Treatment Home", "Specialty Bed Group Home", "Gourp Home", 
                            "Detention Alternative", "Second Chance", "County Specific Court Bed", 
                            "In-Home", "Behavioral Support Services" ], serReq);
      })
      .fillInputText("Axis I", "some 1")
      .fillInputText("Axis II", "some 2")
      .fillInputText("Axis III", "some 3")
      .fillInputText("Axis IV", "some 4")
      .fillInputText("Axis V", "some 5")
      .chooseSelectOption("Program Category", "IDD")
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
      .click("input[value='Save']")
      .click("input[value='Add Funding Source']")
      
      .getSelectOptions("Funding Source")
      .then(function(funSource) {
          assert.deepEqual(["", "Medicaid", "Private Insurance", "DCPP/SAR", "DDD", 
                             "CSOC",  "County Contract"], funSource);
      })
      .getSelectOptions("Service being Funded")
      .then(function(serbfun) {
          assert.deepEqual(["", "Host Home", "Treatment Home", "Specialty Bed Group Home", "Group Home", 
                             "Detention Alternative", "Second Chance", "County Specific Court Bed", 
                             "In-Home", "Behavioral Support Services"], serbfun);
      })
      .getSelectOptions("[id$=fundingEntry_Status]")
      .then(function(funStatus) {
          assert.deepEqual(["", "Pending Approval", "Authorized"], funStatus);
      })
      .chooseSelectOption("Funding Source", "Medicaid")
      .fillInputText("Funding Source ID", "test")
      .chooseSelectOption("Service being Funded", "Host Home")
      .chooseSelectOption("[id$=fundingEntry_Status]", "Pending Approval")
      .fillInputText("Comments", "test")
      .click("input[value='Save']")
            
      .getSelectOptions("Staffing Needs")
      .then(function(vals) {
          assert.deepEqual(["", "Night Sleep", "Night Awake"], vals);
      })
      .getSelectOptions("Staffing Ratio")
      .then(function(vals) {
          assert.deepEqual(["","1:7","1:8","1:9" ], vals);
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
          assert.deepEqual(["", "Issue", "Agression", "Acting Out"], yesType);
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
      .click("[id$=j_id1162]")
      .click("[id$=j_id1185]")
      .click("[id$=j_id1220]")
      .fillInputText("Area of State Interested In", "test")
      .click("[id$=j_id1256]") 
      .click("[id$=j_id1027]")
      .click("[id$=j_id1059]")
      .click("[id$=j_id1084]") 
      .click("[id$=j_id1115]")
      .click("[id$=j_id1140]")
      .click("[id$=j_id1168]")
      .click("[id$=j_id1195]")
      .click("[id$=j_id1227]") 
      .click("[id$=j_id1248]")
      .click("[id$=j_id1258]")
      .click("[id$=j_id1268]") 
      .click("[id$=j_id1035]")
      .click("[id$=j_id1063]") 
      .click("[id$=j_id1092]")
      .click("[id$=j_id1119]")
      .click("[id$=j_id1149]") 
      .click("[id$=j_id1173]")
      .click("[id$=j_id1206]")
      .fillInputText("If Yes, Level of Support Required", "test1")
      .click("[id$=j_id1252]")
      .fillInputText("If Yes, Length of time", "test time")
      .click("[id$=j_id1045]")
      .chooseSelectOption("If Yes, How Many?", "5")
      .click("[id$=j_id1101]")
      .click("[id$=j_id1124]")
      .click("[id$=j_id1158]") 
      .click("[id$=j_id1177]")
      .chooseSelectOption("If Yes, Age Requirements?", "Older")
      .click("[id$=j_id1240]")
      .chooseSelectOption("If Yes, Level?", "Limited Visitation")
      .click("[id$=j_id1310]")
      .click("[id$=j_id1314]") 
      .click("[id$=j_id1311]")
      .click("[id$=j_id1315]") 
      .click("[id$=j_id1312]")
      .click("[id$=j_id1316]")
      .click("[id$=j_id1313]") 
      .click("[id$=j_id1317]")
      .fillInputText("Programming Considerations Comments", "test")
      
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
