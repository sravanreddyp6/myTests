var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("DiagnosisRef", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["HS_AL_Auburn_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["HS_GA_Referral_Intaker"])
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
          "", "Male", "Female" ], genders);
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
      .fillInputText("First Name", "Darth" + today)
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freaking" + today)
      .chooseSelectOption("Ethnicity", "North American")
      .fillInputText("Last Name", "Vader" + today)
      .chooseSelectOption("Marital Status", "Divorced")
      .fillInputText("Date of Birth", "7/7/1970")  // not working yet because there are 2 DOB fields on the page
      .chooseSelectOption("Primary Language", "English")
      .click("input[id$=nonverb]")
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
	  
	  .click("input[value='Add Diagnosis']")
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  getSelectOptions("input[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      
      .click("a[id$=diagnosisEntry_icd10_lkwgt]")
      .setValue("input#lksrch", "01")
      .click("input[value*='Go']")
      .frameParent()
      .waitForExist("#resultsFrame", defaultOperationTimeout)
      .element("#resultsFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .click("tr.dataRow th a:first-child")
      .fillInputText("Date and Time of Diagnosis", "12/30/2015 13:21")
      .click("span[id$=diagnosisModal] input[value='Save']")
      .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
      .click("input[value='Save Referral']")