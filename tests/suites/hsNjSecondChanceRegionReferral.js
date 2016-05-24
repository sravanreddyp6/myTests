var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsNjSecondChanceRegionReferral", suiteTimeout, {
  "should create a Hastings NJ Referral successfully": function(client, done) {
    var user = users["HS_NJ_SecondChanceRegion_Referral_Intaker"];
    return client
      .logInAs(users["HS_NJ_SecondChanceRegion_Referral_Intaker"])
      .click("a=Create New Referral")
      .getSelectOptions("Race")
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
      .getSelectOptions("Gender")
      .then(function(genders) {
        assert.deepEqual([
          "", "Male", "Female"
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
      //.chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")
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
.waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptions('Type')
      .then(function(typeVal) {
          assert.deepEqual(["", "Adjuster",
                                "Attorney",
                                "Caregiver",
                                "Case Manager",
                                "Common Law Employer",
                                "Conservator",
                                "Designated Representative",
                                "Employment",
                                "Family/Friends",
                                "Financial Worker",
                                "Funder Resources",
                                "Guardian",
                                "Insurance",
                                "Medical",
                                "Mentor",
                                "Mentor Co-Applicant",
                                "Other",
                                "Parent",
                                "Physician - Alternate",
                                "Physician - Primary",
                                "Power of Attorney",
                                "Probation Officer",
                                "Referring Provider",
                                "Representative Payee",
                                "Spouse"], typeVal);
      }) 
      .getSelectOptions("Phone 1 Type")
      .then(function(phon1Type) {
        assert.deepEqual(["", "Home", "Work", "Cell", "Fax"], phon1Type);
      })
      .getSelectOptions("Phone 2 Type")
      .then(function(phon2Type) {
        assert.deepEqual(["", "Home", "Work", "Cell", "Fax"], phon2Type);
      })
      /*
      .getSelectOptions("[id$=relatedPartyEntry_Status]")
      .then(function(partStatus) {
        assert.deepEqual(["", "Active", "Inactive"], partStatus);
      })
      */
      .fillInputText("Party Name", "Party")
      .chooseSelectOption("Type", "Caregiver")
      .fillInputText("Address", "Somewhere")
      .fillInputText("Phone 1", "8888888")
      .fillInputText("Phone 2", "7777777")
      .chooseSelectOption("Phone 1 Type", "Home")
      .chooseSelectOption("Phone 2 Type", "Cell")
      .selectByValue("span[id$=relatedPartyModal] select[id$=relatedPartyEntry_Status]", "Active")
      .click("span[id$=relatedPartyModal] input[value='Save']")
      
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
      /*
      .getSelectOptions("Legal/Guardianship Status")
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", 
                            "Guardian", "Health Care Representative", "Kinship", 
                            "Limited Guardianship", "Parent", "Self", "Shelter Care", 
                            "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
      })
      */
      .chooseSelectOption("Referral Status", "Active")
      .chooseSelectOption("Referral Source Type", "Family")
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
      .fillInputText("Referrer Phone Number", "586356")
      .fillInputText("Case Manager Name", "Qui Gon Jinn")
      //.chooseSelectOption("Legal/Guardianship Status", "Kinship")
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
      .waitForVisible("span[id$=ReferralLocationModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptionsBySelector("[id$=locationEntry_Status]")
      .then(function(locStatus) {
          assert.deepEqual(["", "New", "Active", "On Hold", "Closed"], locStatus);
      })      
     .click("a[id$=aliaslookup]")
      .waitForVisible("input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=addlocationstate]","NJ")
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
      //    return this.elementIdClick(el.value.ELEMENT);
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
          assert.deepEqual(["Behavioral Support Services",
                            "County Specific Court Bed",
                            "Detention Alternative",
                            "Group Home",
                            "Host Home",
                            "In-Home",
                            "Second Chance",
                            "Specialty Bed Group Home",
                            "Treatment Home" ], serReq);
      })
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
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .pause(5000)       
      .fillInputText("Agency Name:", "test")
      .fillInputText("Address:", "404 test street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "test")
      .pause(5000)       
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .click("input[value='Add Funding Source']")
      .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptions("Funding Source")
      .then(function(funSource) {
          assert.deepEqual(["", "County Contract",
                                "CSOC",
                                "DCPP/SAR",
                                "DDD",
                                "Medicaid",
                                "Private Insurance"], funSource);
      })
      .chooseSelectOption("Funding Source", "Medicaid")
      .fillInputText("Funding Source ID", "test")
      .click("span[id$=FundingSourceModal] input[value='Save']")
            
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
      .chooseSelectOption("Staffing Ratio", "1:7")
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
      .selectCheckbox("Legal History")
      .selectCheckbox("Law Enforcement Involvement")
      .selectCheckbox("Tobacco Use (Current)")
      .selectCheckbox("Chemical Use (Recovery)") 
      .selectCheckbox("Chemical Use (Current)")
      .selectCheckbox("Chemical Dependency Treatment")
      .selectCheckbox("Elopement")
      .selectCheckbox("Unwanted Sexual Behavior")
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
      .selectCheckbox("Choking Risk")
      .selectCheckbox("Eating Disorders") 
      .selectCheckbox("History of Bowel Obstructions")
      .selectCheckbox("Ingesting Non-Consumables") 
      .selectCheckbox("Takes Injectible Medications")
      .selectCheckbox("Psychiatric/Mental Hospitalization")
      .selectCheckbox("Ventilator Dependent") 
      .selectCheckbox("Hospitalization Within the Past Year")
      .setValue("textarea[id$=ProgConsComment]", "test2")      

      .click("input[value='Save Referral']")
      .pause(5000)
      .alertAccept()       
      .waitForVisible("input[value=Edit]", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
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
