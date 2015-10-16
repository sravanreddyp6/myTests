var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("rwAzReferral", suiteTimeout, {
  "should create a Redwood AZ Referral successfully": function(client, done) {
    return client
      .logInAs(users["RW_AZ_Referral_Intaker"])
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .getSelectOptions('Race')
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
      .getSelectOptions('Gender')
      .then(function(genders) {
        assert.deepEqual([
          "", "Male", "Female", "Transgender", "Other"
        ], genders);
      })
      .getSelectOptions('Mailing State/Province')
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
      .chooseSelectOption("Mailing State/Province", "Arizona")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)

      .getSelectOptions('Referral Status')
      .then(function(refStatus) {
        assert.deepEqual(["New", "Active", "On Hold", "Closed"], refStatus);
      })
      .getSelectOptions('Referral Source Type')
      .then(function(refSrcType) {
          assert.deepEqual(["", "Attorney", "Family", "Hospital Case Manager",
                            "Independent Case Manager", "Internal", "Payor Case Manager",
                            "Physician", "Rehab/Hospital", "School", "Self", "Social Worker", "Unknown", "Other"
                            ], refSrcType);
      })
      .getSelectOptions('Legal/Guardianship Status')
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", "Guardian", "Health Care Representative",
                            "Kinship", "Limited Guardianship", "Parent", "Self", "Shelter Care", "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
      })
      .getMultiSelectOptions('Services Requested')
      .then(function(vals) {
          assert.deepEqual(["ATC - Attendant Care", "DTA - Day Program", "DTS - Day Program Summer Children", "DTT - Day Program Afterschool", "H0004 - BH Counseling w/ Group",
                            "H0018 - BH Group Home Daily", "H0034 - BH Medication/Training Support", "H0046 - BH Group Home Daily", "H2011 - Crisis Intervention", "H2014 - Training Skills",
                            "H2017 - Psychosocial Rehab", "HAB - Habilitation Group Homes", "HAH - Habilitation", "HAI - Habilitation", "HBA - Host Home Habilitation", "HBC - Host Home Habilitation Children",
                            "HID - Habilitation", "HSK - Housekeeping", "RBD - Host Home Room and Board", "RRB - Group Home Room and Board", "RSD - Respite Daily", "RSP - Respite", "T1013 - Interpreted Services",
                            "T1016 - Case Management", "T1019 - Prsnal Services Non Residential", "T1020 - Personal Care", "TRA - Transportation", "HPD - Grp Home Habilitation Comm Protect" ], vals);
      })
      .getSelectOptions('Staffing Needs')
      .then(function(vals) {
          assert.deepEqual(["", "Night Sleep", "Night Awake"], vals);
      })
      .getSelectOptions('Staffing Ratio')
      .then(function(vals) {
          assert.deepEqual(["","1:1","1:2","1:3","1:4","Other"], vals);
      })
      .getSelectOptions('Desired Living Environment')
      .then(function(vals) {
          assert.deepEqual(["", "ICF", "Supported Living", "Group Home", "With Family", "With Foster Family", "With Housemates", "Alone"], vals);
      })
      .getSelectOptions('Mobility')
      .then(function(vals) {
          assert.deepEqual(["", "Ambulatory", "Wheelchair", "Uses Walker" , "Uses Cane"], vals);
      })
      .getSelectOptions('Gender Specific Staffing')
      .then(function(vals) {
          assert.deepEqual(["", "Male Preferred", "Female Preferred", "No Preference"], vals);
      })
      .getMultiSelectOptions('Lift Transfer Assistance')
      .then(function(vals) {
          assert.deepEqual(["Able to Transfer", "Use of Hoyer Lift", "One Person Lift", "Two Person Lift" ], vals);
      })
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
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
