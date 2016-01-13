var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
//Should cover Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7 for CM
//Should cover Test Case: View Diagnosis 3,4, and 6 for CM
testSuite("CM_Assoc_Diag", suiteTimeout, {
  "Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7 and Test Case: View Diagnosis 3,4, and 6 for CM. Also, should associate a diagnosis with a PBS successfully": function(client, done) {
  var user = users["HS_AL_Auburn_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["CM_DON"])
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
      .fillInputText("Additional Information / Comments", "Really hateful")
      .fillInputText("Mailing Street 1", "123 Something Street")
      .fillInputText("Mailing Street 2", "apt. 456")
      .fillInputText("Mailing City", "Minnesota")
      .chooseSelectOption("Mailing State/Province", "Minnesota")
      .fillInputText("Mailing Zip/Postal Code", "23456")
      .fillInputText("Mailing County", "Minnesota County")
      .setValue("input[id$=Perm_Phone]", "6090210")
      .setValue("input[id$=Perm_Email]", "someone@something.com")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .fillInputText("Referral Source", "Someone")
      .fillInputText("Current Location", "Somewhere")
      .click("a[id$=EvalByInter_lkwgt]")
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
      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .click("input[value='Add Location']")
      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)

      .getSelectOptionsBySelector("[id$=locationEntry_Status]")
      .then(function(locStatus) {
          assert.deepEqual(["", "New", "Active", "On Hold", "Closed"], locStatus);
      })
      .getSelectOptions("Rank")
      .then(function(rank) {
          assert.deepEqual(["", "Primary", "Secondary", "Other"], rank);
      })
      .click("a[id$=aliaslookup]")
      .waitForVisible("input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=addlocationstate]","AZ")
      .click("span[id$=searchDialog] input[value='Search!']")
      .waitForVisible("span[id$=searchDialog] a", defaultOperationTimeout)
      //.click("span[id$=searchDialog] a:first")
      .element("span[id$=searchDialog] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
      
      .chooseSelectOption("Rank", "Primary")
      .selectByValue("select[id$=locationEntry_Status]", "Active")
      .click("span[id$=ReferralLocationModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
      .click("a[id$=originlookup]")
      .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=originstate]","AZ")
      .click("span[id$=searchDialog2] input[value='Search!']")
      .waitForVisible("span[id$=searchDialog2] a", defaultOperationTimeout)
      //.click("span[id$=searchDialog] a:first")
      .element("span[id$=searchDialog2] a")
      .then(function (el) {
      	return this.elementIdClick(el.value.ELEMENT);
      })
      .waitForVisible("input[value='Add Location']", defaultOperationTimeout)
	  .click("input[value='Add Diagnosis']")
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })

      .click("a[id$=diagnosisEntry_icd10_lkwgt]")
      //.selectLookup("ICD-10 Code")
      .switchToNextWindow()
      .element("#searchFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .setValue("input#lksrch", "01")
      .click("input[value*='Go']")
      .frameParent()
      .waitForExist("#resultsFrame", defaultOperationTimeout)
      .element("#resultsFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .click("tr.dataRow th a:first-child")
      .switchToNextWindow()
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Date and Time of Diagnosis", "12/30/2015 13:21")
      .click("span[id$=diagnosisModal] input[value='Save']")
      .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .click("input[value='Add Funding Source']")
      .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptions("Coverage Level")
	  .then(function(covLevel) {
        assert.deepEqual([
          "", "Primary", "Secondary", "Tertiary", "Other" ], covLevel);
      })
      
      .chooseSelectOption("Coverage Level", "Primary")
      .fillInputText("Payer Name", "Someone")
      .click("span[id$=FundingSourceModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      .click("input[value='Save Referral']")
      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      .waitForVisible("input[value='Save and Continue']", defaultOperationTimeout)
      .click("input[value='Save and Continue']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      //.waitForExist("input[value='PRE 10/1/2015']",defaultOperationTimeout,true)
      //.then(function (el) {
      //		if(el==true)
      //	return true;
      //		else
      //	return this.click("input[value='PRE 10/1/2015']");
      //})
      .click("a=Admission 1 - Darth" +today +" Vader" +today)
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
      .click("a=D. Vader" +today +" - SA1 - 020010 - Host Home")
      //.element("#resultsFrame")
      //.then(function (frame) { return frame.value; })
      //.then(client.frame)
      //.click("tr.dataRow th a:first-child")
      .waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Associate Diagnosis']", 0, -500)
	  .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      .getSelectOptions("Injury Type")
      .then(function(injurytype) {
          assert.deepEqual(["", "Acquired Brain Injury - Anoxia/hypoxia", "Acquired Brain Injury -- CVA -- R hemiplegia",
          "Acquired Brain Injury -- CVA -- L hemiplegia", "Acquired Brain Injury -- TBI", "Acquired Brain Injury -- Other",
          "Cognitive Disorder", "CONGENTIAL", "Medical - Cardiac", "Medical - GI", "Medical - GU",
          "Medical - Cancer", "Neuro - Degenerative", "Neuro -Non-degenerative", "PTSD", 
          "Pulmonary - End-stage", "Pulmonary - Other", "Orthopedic - Disease", "Orthopedic - Injury",
          "Spinal Cord Injury -C 1-3", "Spinal Cord Injury -C4-5", "Spinal Cord Injury -C6-8",
          "Spinal COrd Injury - Paraplegia", "Other"], injurytype);
      })
      .getSelectOptionsBySelector("Glasgow Coma Score at Injury")
      .then(function(glasgowcomainjury) {
          assert.deepEqual(["", "3-8", "9-12", "13-15" ], glasgowcomainjury);
      })
      .getSelectOptionsBySelector("Glasgow Coma Scale Severity")
      .then(function(glasgowcomasev) {
          assert.deepEqual(["", "Severe", "Moderate", "Mild" ], glasgowcomasev);
      })
      
      .chooseSelectOption("Diagnosis", "A01.01 - Typhoid meningitis", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .chooseSelectOption("Injury Type", "PTSD")
      .selectCheckbox("ABI Diagnosis")
      .fillInputText("Injury Date", "12/25/2015")
      .selectCheckbox("Billable")
      .chooseSelectOption("Glasgow Coma Score at Injury", "3-8")
      .chooseSelectOption("Glasgow Coma Scale Severity", "Severe")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      //.isExisting("input[value='Convert']")
      //.then(function(isExisting) {
      //  assert.Ok(isExisting, "Convert Button exists.");
      //})
       .element("label=Primary Active Diagnosis:")
       client.elementIdElement(el.value, "//..", function (err, res) {
  if (err) {
    throw new Error("Element not found");
  }
  return res;
})
       .then(function (el) { return client.elementIdText(el.value); })
       .then(function (pad) {
        assert.equal("1) A01.01-Typhoid meningitis", pad );
        })
      //.getOutputText("Primary Active Diagnosis:")
      //.then(function (pad) {
      //  assert.equal("1) A01.01-Typhoid meningitis", pad );
      //})
      
      //.getOutputText("ICD-10 Code")
      //.then(function (icd10code) {
      //  assert.equal("A01.01", icd10code);
      //})
      //.getOutputText("Date and Time of Diagnosis")
      //.then(function (dateantime) {
      //  assert.equal("12/30/2015 13:21", dateantime);
      //})
        }
});