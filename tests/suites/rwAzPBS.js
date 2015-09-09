var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("rwAzPBS", suiteTimeout, {
    "should create a Redwood AZ Person Being Served successfully": function(client, done) {
      return client
      .logInAs(users["RW_AZ_handler"])
      .click("a=Add New Person Being Served")
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
      .getSelectOptions('Race')
      .then(function(races) {
        assert.deepEqual([
          "", "Caucasian", "African American", "American Indian/Alaskan", "Asian/Pacific Islands",
          "Hispanic", "Multi-Racial", "Middle Eastern", "Other"
        ], races);
      })
      .getSelectOptions("Ethnicity")
      .then(function(ethnicities) {
        assert.deepEqual([
          "", "Aboriginal", "African", "Arab", "Balkan", "Baltic", "British Isles", "Caribbean",
          "Czech and Slovak", "East and Southeast Asian", "Eastern European", "European", "French",
          "Indo-Chinese", "Latin, Central, South American", "Maghrebi", "North American",
          "Northern European", "Oceania", "Other European", "Pacific Islands", "Scandinavian",
          "South Asian", "Southern European", "West Asian", "Western European"
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
          "", "Afghani",
          "Albanian",
          "Arabic",
          "Armenian",
          "Austrian",
          "Bengali",
          "Bielorussian",
          "Bosnian",
          "Cajun",
          "Cambodian",
          "Cantonese",
          "Chinese",
          "Croatian",
          "Czech",
          "Danish",
          "English",
          "English creoles- Belize, Guyanese",
          "French",
          "French Creole",
          "German",
          "Greek",
          "Haitian Creole",
          "Hebrew",
          "Hindi",
          "Hmong",
          "Icelandic",
          "India, n.e.c.",
          "Indonesian",
          "Italian",
          "Jamaican Creole",
          "Japanese",
          "Khmer",
          "Korean",
          "Laotian",
          "Mandarin",
          "Miao, Hmong",
          "Mon-Khmer, Cambodian",
          "Muong",
          "Norwegian",
          "Pakistan, n.e.c.",
          "Patois",
          "Polish",
          "Portuguese",
          "Romanian",
          "Russian",
          "Serbian",
          "Shanghainese",
          "Spanish",
          "Swedish",
          "Swiss",
          "Taiwanese",
          "Turkish",
          "Ukrainian",
          "Vietnamese"
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
          "", "Male", "Female"
        ], genders);
      })
     /*.getSelectOptions('Mailing Country')
      .then(function(Country) {
        assert.deepEqual([
          "",
        ], Country);
      })*/
      //.chooseSelectOption("Mailing Country", "United States")
      .getSelectOptions('Mailing State/Province')
      .then(function(states) {
        assert.deepEqual([
          "", "AL", "AK", "AZ", "AR", "CA", "CO", "CT",
          "DE", "DC", "FL", "GA", "HI", "ID", "IL",
          "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA",
          "MI", "MN", "MS", "MO", "MT", "NE",
          "NV", "NH", "NJ", "NM", "NY", "NC",
          "ND", "OH", "OK", "OR", "PA", "RI",
          "SC", "SD", "TN", "TX", "UT",
          "VT", "VA", "WA", "WV", "WI", "WY"
        ], states);
      })
      .getSelectOptions('Legal/Guardianship Status')
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", "Guardian", "Health Care Representative",
                            "Kinship", "Limited Guardianship", "Parent", "Self", "Shelter Care", "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
      })
      .fillInputText("First Name", "Tom")
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freaking")
      .chooseSelectOption("Ethnicity", "North American")
      .fillInputText("Last Name", "Brady")
      .chooseSelectOption("Marital Status", "Single")
      .fillInputText("Date of Birth", "7/7/1989")
      .chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")

      .fillInputText("Family Members / Other / Notes", "Really hurtful")
      .chooseSelectOption("Mailing State/Province", "AZ")
      .click("input[value='Save']")
      .url()

      .then(function (url) {

        assert.include(url.value, "PersonBeingServedEditNew");
      })

	  }
});