var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;

testSuite("hsGaReferral", suiteTimeout, {
  "should create a Hastings GA Referral successfully": function(client, done) {
  var user = users["HS_AL_Auburn_Referral_Intaker"];
  var refpag1 = GaRefPa["First"];
  var refpag2 = GaRefPa["Contact"];
  var refpag3 = GaRefPa["Related"];
  var refpag4 = GaRefPa["Referral State"];
  var refpag5 = GaRefPa["Service"];
  var refpag6 = GaRefPa["Diagnosis"];
  var refpag7 = GaRefPa["AgencyFund"];
  var refpag8 = GaRefPa["Tracking"];
  var refpag9 = GaRefPa["Else"];
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
      .timeoutsImplicitWait(4000)
      .fillInputText("Agency Name:", "test")
      .fillInputText("Address:", "404 test street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "test")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
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
      .fillInputText("Due Date", "12/25/2015")
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
      .click("input[value='Save Referral']")
      
      
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
      })
      //.isExisting("input[value='Convert']")
      //.then(function(isExisting) {
      //  assert.Ok(isExisting, "Convert Button exists.");
      //})      
      //.getOutputText("First Name")
      //.then(function (firstName) {
      //  assert.equal(firstName , refpag1["First Name"]); 
      //})
      .getOutputText("Race")
      .then(function (race) {
        assert.equal(race , refpag1["Race"] );
      })
      //.getOutputText("Middle Name")
      //.then(function (middleName) {
      //  assert.equal(middleName , refpag1["Middle Name"]);
      //})
      .getOutputText("Ethnicity")
      .then(function (ethnicity) {
        assert.equal(ethnicity , refpag1["Ethnicity"]);
      })
      //.getOutputText("Last Name")
      //.then(function (lastName) {
      //  assert.equal(lastName , refpag1["Last Name"]);
      //})
      .getOutputText("Marital Status")
      .then(function (maritalstatus) {
        assert.equal(maritalstatus , refpag1["Marital Status"]);
      })
	  .getOutputText("Date of Birth")
      .then(function (dob) {
        assert.equal(dob , refpag1["Date of Birth"]);
      })
	  //.getOutputText("Primary Language")
      //.then(function (primarylanguage) {
      //  assert.equal(primarylanguage , refpag1["Primary Language"]);
      //})
	  .getOutputText("Age")
      .then(function (age) {
        assert.equal(age , refpag1["Age"]);
      })
	  .getOutputText("Highest Level of Education")
      .then(function (highlevel) {
        assert.equal(highlevel , refpag1["Highest Level of Education"]);
      })
	  .getOutputText("Gender")
      .then(function (gender) {
        assert.equal(gender , refpag1["Gender"]);
      })
	  .getOutputText("SSN")
      .then(function (ssn) {
        assert.equal(ssn , refpag1["SSN"]);
      })
	  .getOutputText("Additional Information / Comments")
      .then(function (addcomments) {
        assert.equal(addcomments , refpag1["Additional Information / Comments"]);
      })
	  .getOutputText("Mailing Street 1")
      .then(function (mailingstr1) {
        assert.equal(mailingstr1 , refpag1["Mailing Street 1"]);
      })
	  .getOutputText("Mailing Street 2")
      .then(function (mailingstr2) {
        assert.equal(mailingstr2 , refpag1["Mailing Street 2"]);
      })
	  .getOutputText("Mailing City")
      .then(function (mailingcity) {
        assert.equal(mailingcity , refpag1["Mailing City"]);
      })
	  .getOutputText("Mailing State/Province")
      .then(function (mailingstate) {
        assert.equal(mailingstate , refpag1["Mailing State/Province"]);
      })
	  .getOutputText("Mailing Zip/Postal Code")
      .then(function (mailingzip) {
        assert.equal(mailingzip , refpag1["Mailing Zip/Postal Code"]);
      })
	  .getOutputText("Mailing County")
      .then(function (mailingcounty) {
        assert.equal(mailingcounty , refpag1["Mailing County"]);
      })
      .getOutputText("Phone")
      .then(function (phone) {
        assert.equal(phone ,refpag2["Phone"]);
      })
	  .getOutputText("Email")
      .then(function (email) {
        assert.equal(email , refpag2["Email"]);
      })
      .getOutputText("Email")
      .then(function (email2) {
        assert.equal(email2 , refpag3["Email"]);
      })
	  .getOutputText("Party Name")
      .then(function (partname) {
        assert.equal(partname , refpag3["Party Name"]);
      })
	  .getOutputText("Type")
      .then(function (type) {
        assert.equal(type , refpag3["Type"]);
      })
	  .getOutputText("Phone 1")
      .then(function (phone11) {
        assert.equal(phone11 , refpag3["Phone 1"]);
      })
	  .getOutputText("Phone 1 Type")
      .then(function (phone1type) {
        assert.equal(phone1type , refpag3["Phone 1 Type"]);
      })
	  .getOutputText("Phone 2")
      .then(function (phone21) {
        assert.equal(phone21 , refpag3["Phone 2"]);
      })
	  .getOutputText("Phone 2 Type")
      .then(function (phone2type) {
        assert.equal(phone2type , refpag3["Phone 2 Type"]);
      })
	  .getOutputText("Address")
      .then(function (address1) {
        assert.equal(address1 , refpag3["Address"]);
      })
	  .getOutputText("Comments")
      .then(function (comments1) {
        assert.equal(comments1 , refpag3["Comments"]);
      })
	  .getOutputText("Status")
      .then(function (status1) {
        assert.equal(status1 , refpag3["Status"]);
      })
      .getOutputText("Referral Status")
      .then(function (referralstatus) {
        assert.equal(referralstatus , refpag4["Referral Status"]);
      })
      .getOutputText("Referral Source Type")
      .then(function (referralsourcetype) {
        assert.equal(referralsourcetype , refpag4["Referral Source Type"]);
      })    
      .getOutputText("Referral Source")
      .then(function (referralsource) {
        assert.equal(referralsource , refpag4["Referral Source"]);
      })    
      .getOutputText("Referrer Name")
      .then(function (referrername) {
        assert.equal(referrername , refpag4["Referrer Name"]);
      })    
      .getOutputText("Referrer Phone Number")
      .then(function (referrerphonenumber) {
        assert.equal(referrerphonenumber , refpag4["Referrer Phone Number"]);
      })    
      .getOutputText("Case Manager Name")
      .then(function (casemanagername) {
        assert.equal(casemanagername , refpag4["Case Manager Name"]);
      })    
      .getOutputText("Billing ID")
      .then(function (billingid) {
        assert.equal(billingid , refpag4["Billing ID"]);
      })   
      .getOutputText("Case Manager Phone")
      .then(function (casemanagerphone) {
        assert.equal(casemanagerphone , refpag4["Case Manager Phone"]);
      })    
      .getOutputText("Current Representative Payee")
      .then(function (currentreppay) {
        assert.equal(currentreppay , refpag4["Current Representative Payee"]);
      })    
      .getOutputText("legal/Guardian status")
      .then(function (legalstatus) {
        assert.equal(legalstatus , refpag4["legal/Guardian status"]);
      })
      .getOutputText("Reason for Referral")
      .then(function (reasonreferral1) {
        assert.equal(reasonreferral1 , refpag4["Reason for Referral"]);
      })  
      .getOutputText("Update Notes")
      .then(function (updatenotes) {
        assert.equal(updatenotes , refpag4["Update Notes"]);
      })   
      .getOutputText("Anticipated Admission DateTime")
      .then(function (antadmdateline) {
        assert.equal(antadmdateline , refpag4["Anticipated Admission DateTime"]);
      })   
      .getOutputText("Service Location")
      .then(function (servicelocation) {
        assert.equal(servicelocation , refpag4["Service Location"]);
      })   
      .getOutputText("Service Value")
      .then(function (servicevalue) {
        assert.equal(servicevalue , refpag4["Service Value"]);
      })    
      .getOutputText("Setting")
      .then(function (setting1) {
        assert.equal(setting1 , refpag4["Setting"]);
      })   
      .getOutputText("Street")
      .then(function (street) {
        assert.equal(street , refpag4["Street"]);
      })   
      .getOutputText("City")
      .then(function (city) {
        assert.equal(city , refpag4["City"]);
      }) 
      .getOutputText("Alias")
      .then(function (alias) {
        assert.equal(alias , refpag5["Alias"]);
      })
      .getOutputText("Service Value")
      .then(function (servicevalue) {
        assert.equal(servicevalue , refpag5["Service Value"]);
      })   
      .getOutputText("Setting")
      .then(function (setting2) {
        assert.equal(setting2 , refpag5["Setting"]);
      }) 
      .getOutputText("Program")
      .then(function (program) {
        assert.equal(program , refpag5["Program"]);
      })  
      .getOutputText("Address")
      .then(function (address2) {
        assert.equal(address2 , refpag5["Address"]);
      })   
      .getOutputText("User Assigned")
      .then(function (userassigned) {
        assert.equal(userassigned , refpag5["User Assigned"]);
      })   
      .getOutputText("Status")
      .then(function (status2) {
        assert.equal(status2 , refpag5["Status"]);
      })   
      .getOutputText("Axis I")
      .then(function (axis1) {
        assert.equal(axis1 , refpag6["Axis I"]);
      }) 
      .getOutputText("Axis II")
      .then(function (axis2) {
        assert.equal(axis2 , refpag6["Axis II"]);
      })     
      .getOutputText("Axis III")
      .then(function (axis3) {
        assert.equal(axis3 , refpag6["Axis III"]);
      })   
      .getOutputText("Axis IV")
      .then(function (axis4) {
        assert.equal(axis4 , refpag6["Axis IV"]);
      })    
      .getOutputText("Axis V")
      .then(function (axis5) {
        assert.equal(axis5 , refpag6["Axis V"]);
      })  
      .getOutputText("Program Category")
      .then(function (programcategory) {
        assert.equal(programcategory , refpag6["Program Category"]);
      })   
      .getOutputText("Service Line")
      .then(function (serviceline) {
        assert.equal(serviceline , refpag6["Service Line"]);
      }) 
      .getOutputText("Services Requested")
      .then(function (servicesrequested) {
        assert.equal(servicesrequested , refpag6["Services Requested"]);
      })    
      .getOutputText("Family History")
      .then(function (familyhistory) {
        assert.equal(familyhistory , refpag6["Family History"]);
      })    
      .getOutputText("Medical History")
      .then(function (medicalhistory) {
        assert.equal(medicalhistory , refpag6["Medical History"]);
      }) 
      .getOutputText("Behavior Summary")
      .then(function (behaviorsummary) {
        assert.equal(behaviorsummary , refpag6["Behavior Summary"]);
      })    
      .getOutputText("Current Medications")
      .then(function (currentmedications) {
        assert.equal(currentmedications , refpag6["Current Medications"]);
      })    
      .getOutputText("Prior Program Information")
      .then(function (priorproginfo) {
        assert.equal(priorproginfo , refpag6["Prior Program Information"]);
      })   
      .getOutputText("Comments")
      .then(function (comments2) {
        assert.equal(comments2 , refpag6["Comments"]);
      })   
      //.getOutputText("Referral Source")
      //.then(function (source) {
      //  assert.equal("Mentor", source);
      //})
      //.getOutputText("Referrer Name")
      //.then(function (name) {
      //  assert.equal("Obi-wan Kennobi", name);
      //});
      .getOutputText("Agency Name")
      .then(function (agencyname) {
        assert.equal(agencyname , refpag7["Agency Name"]);
      })
      .getOutputText("Address")
      .then(function (address3) {
        assert.equal(address3 , refpag7["Address"]);
      })  
      .getOutputText("Phone Number")
      .then(function (phonenumber) {
        assert.equal(phonenumber , refpag7["Phone Number"]);
      })  
      .getOutputText("Reason for Involvement")
      .then(function (reasoninvolvement2) {
        assert.equal(reasoninvolvement2 , refpag7["Reason for Involvement"]);
      })   
      .getOutputText("Funding Source")
      .then(function (fundingsource) {
        assert.equal(fundingsource , refpag7["Funding Source"]);
      })   
      .getOutputText("Funding Source ID")
      .then(function (fundingsourceid) {
        assert.equal(fundingsourceid , refpag7["Funding Source ID"]);
      })   
      .getOutputText("Service Being Funded")
      .then(function (servicebeingfunded) {
        assert.equal(servicebeingfunded , refpag7["Service Being Funded"]);
      })  
      .getOutputText("Status")
      .then(function (status3) {
        assert.equal(status3 , refpag7["Status"]);
      })   
      .getOutputText("Comment")
      .then(function (comment2) {
        assert.equal(comment2 , refpag7["Comment"]);
      })  
      .getOutputText("Subject")
      .then(function (subject2) {
        assert.equal(subject2 , refpag8["Subject"]);
      })  
      .getOutputText("Due Date")
      .then(function (duedate) {
        assert.equal(duedate , refpag8["Due Date"]);
      })  
      .getOutputText("Assigned To")
      .then(function (assignedto) {
        assert.equal(assignedto , refpag8["Assigned To"]);
      })    
      .getOutputText("Priority")
      .then(function (priority) {
        assert.equal(priority , refpag8["Priority"]);
      })   
      .getOutputText("Status")
      .then(function (status4) {
        assert.equal(status4 , refpag8["Status"]);
      })   
      .getOutputText("Comments")
      .then(function (comments3) {
        assert.equal(comments3 , refpag8["Comments"]);
      })   
      .getOutputText("Staffing Needs")
      .then(function (staffingneeds) {
        assert.equal(staffingneeds , refpag8["Staffing Needs"]);
      })    
      .getOutputText("Staffing Ratio")
      .then(function (staffingratio) {
        assert.equal(staffingratio , refpag8["Staffing Ratio"]);
      })   
      .getOutputText("Desired Living Environment")
      .then(function (desiredlivingenv) {
        assert.equal(desiredlivingenv , refpag8["Desired Living Environment"]);
      })  
      .getOutputText("Preferred Setting")
      .then(function (preferredsetting2) {
        assert.equal(preferredsetting2 , refpag8["Preferred Setting"]);
      })    
      .getOutputText("Mobility")
      .then(function (mobility) {
        assert.equal(mobility , refpag8["Mobility"]);
      })   
      .getOutputText("Area of State Interested In")
      .then(function (areainterest) {
        assert.equal(areainterest , refpag9["Area of State Interested In"]);
      })
      .getOutputText("if Yes: Type")
      .then(function (yestype) {
        assert.equal(yestype , refpag9["if Yes: Type"]);
      })
      .getOutputText("If Yes: Level of Support Required")
      .then(function (yeslevel) {
        assert.equal(yeslevel , refpag9["If Yes: Level of Support Required"]);
      })
      .getOutputText("If Yes: Length of time")
      .then(function (yeslength) {
        assert.equal(yeslength , refpag9["If Yes: Length of time"]);
      })
      .getOutputText("If Yes: How Many?")
      .then(function (yeshow) {
        assert.equal(yeshow , refpag9["If Yes: How Many?"]);
      })
      .getOutputText("If Yes: Age Requirements?")
      .then(function (yesage) {
        assert.equal(yesage , refpag9["If Yes: Age Requirements?"]);
      })
      .getOutputText("If Yes: Level?")
      .then(function (ifyeslevel) {
        assert.equal(ifyeslevel , refpag9["If Yes: Level?"]);
      })
      .getOutputText("If Yes: Type")
      .then(function (ifyestype) {
        assert.equal(ifyestype , refpag9["If Yes: Type"]);
      })
      .getOutputText("Restricted Health Conditions")
      .then(function (restrictedhealthconditions) {
        assert.equal(restrictedhealthconditions , refpag9["Restricted Health Conditions"]);
      })
      .getOutputText("Programming Considerations Comments")
      .then(function (progconscomments) {
        assert.equal(progconscomments , refpag9["Programming Considerations Comments"]);
      })
  }
});
