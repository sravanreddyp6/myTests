var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("Referral", suiteTimeout, {
  "should create a Referral successfully": function(client, done) {
    var user = users["CM_Marketer"];
    return client
      .logInAs(user)
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
      .getSelectOptions('Race')
      .then(function(races) {
        assert.deepEqual([
          "", "African American", "American Indian/Alaskan", "Asian/Pacific Islands", "Caucasian",
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
      .getSelectOptions('Gender')
      .then(function(genders) {
        assert.deepEqual([
          "", "Male", "Female"
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
      .fillInputText("Middle Name", "Freakin'")
      .chooseSelectOption("Ethnicity", "Unknown")
      .fillInputText("Last Name", "Vader")
      .chooseSelectOption("Marital Status", "Divorced")
      .fillInputText("Date of Birth", "7/7/1970")

      .chooseSelectOption("Gender", "Male")


      .fillInputText("Additional Information / Comments", "Really hateful")
      .chooseSelectOption("Mailing State/Province", "Arizona")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .chooseSelectOption("Highest Level of Education", "Graduate School")      
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
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal]", defaultOperationTimeout)
      .fillInputText("Party Name", "Anakin Skywalker")
      .chooseSelectOption("Type", "Family/Friends")
      .click("span[id$=relatedPartyModal] input[value=Save]")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
      .selectLookup("Evaluated By")
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
      .click("#TMN_User__c_body tr.dataRow th a")
      .switchToNextWindow()
      .click("input[value='Add Funding Source']")
      .waitForVisible("span[id$=FundingSourceModal]", defaultOperationTimeout)
      .selectCheckbox("More than 1.5 Yrs of Disability")
      .selectCheckbox("ALS/ESRD/Black Lung Disease")
      .selectCheckbox("Patient Over 64 Years of Age")
      .click("span[id$=FundingSourceModal] input[value='Save']")
      .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
      .click("input[value='Save Referral']")
      .waitForVisible("input[value=Edit]", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
      })
      .getOutputText("First Name")
      .then(function (firstName) {
        assert.equal("Darth", firstName);
      })
      .getOutputText("Date of Birth")
      .then(function (dateOfBirth) {
        assert.equal("7/7/1970", dateOfBirth);
      })
      .getOutputText("Race")
      .then(function (race) {
        assert.equal("Caucasian", race);
      }).
      getOutputText("Evaluated By")
      .then(function (evaluatedBy) {
        assert.equal(user["first_name"] + " " + user["last_name"], evaluatedBy);
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
