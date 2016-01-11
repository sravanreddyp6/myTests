var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
var agen = [{"Action": "Edit", "Agency Name":"test","Address":"404 test street","Phone":"8008378", "Reason for Involvement": "test"}, 
            {"Action": "Edit", "Agency Name":"testName","Address":"404 test street","Phone":"8008378", "Reason for Involvement": "test"},
            {"Action": "Edit", "Agency Name":"testPBS","Address":"313 Wilcox Street","Phone":"8008378", "Reason for Involvement": "timeout"},
            {"Action": "Edit", "Agency Name":"testPBSedit","Address":"313 marshmallow Street","Phone":"8008378", "Reason for Involvement": "random"}];
var relatedp = [{"Action": "Edit", "Type":"Caregiver","Party Name":"Party","Address":"Somewhere", "Email": "someone@something.com", "Phone 1":"8888888", "Phone 1 Type":"Home", "Phone 2":"7777777","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"This is a test"},
                {"Action": "Edit", "Type":"Case Manager", "Party Name": "Qui Gon Jinn", "Address":"", "Email": "", "Phone 1":"8675309", "Phone 1 Type":"", "Phone 2":"","Phone 2 Type":"" , "Status":"Active", "Comments":""},
                {"Action": "Edit", "Type":"Adjuster","Party Name":"PBSParty","Address":"Above the Sky", "Email": "someone@something.com", "Phone 1":"1111111", "Phone 1 Type":"Home", "Phone 2":"2222222","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"This is a test"},
                {"Action": "Edit", "Type":"Spouse","Party Name":"Hector","Address":"Beneath the fire", "Email": "someone@something.com", "Phone 1":"1111111", "Phone 1 Type":"Home", "Phone 2":"2222222","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"Win win"}];
var allerg = [{"Action": "Edit", "Allergy Type":"Food","Allergy Details":"Peanuts","Life Threatening": ""},
              {"Action": "Edit", "Allergy Type":"Other","Allergy Details":"Cats","Life Threatening": ""}];

testSuite("HSGARelatedLists", suiteTimeout, {
  "Should add, edit, cancel related parties, agencies, allergy successfully": function(client, done) {
  var user = users["HS_GA_Referral_Intaker"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["HS_GA_Referral_Intaker"])
      .click("a=Create New Referral")
      .waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
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
      .fillInputText("Mailing City", "Georgia")
      .chooseSelectOption("Mailing State/Province", "Georgia")
      .fillInputText("Mailing Zip/Postal Code", "23456")
      .fillInputText("Mailing County", "Georgia County")
      .setValue("input[id$=Perm_Phone]", "6090210")
      .setValue("input[id$=Perm_Email]", "someone@something.com")
      .click("input[value='Create Person Being Referred']")
      .waitForVisible("input[value='Save Referral']", defaultOperationTimeout)
      //Adding Related Party on referral creation
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Party Name", "Party")
      .click("span[id$=relatedPartyModal] input[value='Cancel']")
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      
      .getSelectOptions("Type")
      .then(function(typeParty) {
        assert.deepEqual(["", "Adjuster","Attorney", "Caregiver", "Case Manager", "Conservator", "Employment", 
                          "Family/Friends", "Financial Worker","Funder Resources",
                           "Guardian", "Insurance", "Medical", "Mentor",
                           "Mentor Co-Applicant", "Other", "Parent", "Physician - Alternate", 
                           "Physician - Primary", "Power of Attorney", "Probation Officer", "Referring Provider",
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
      .chooseSelectOption("Program Category", "ARY")
      .doubleClick("select[title='Service Line - Available'] option[value='0']")
      .doubleClick("select[title='Services Requested - Available'] option[value='0']")
      .fillInputText("Reason for Referral", "Test")
      .fillInputText("Update Notes", "Test")
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .click("a[id$=originlookup]")
      .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=originstate]","GA")
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
      .setValue("input[id$=addlocationstate]","GA")
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
      //Adding Agency on referral creation
      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
      .click("input[value='Add Agency Involved With Individual']")
      .fillInputText("Agency Name:", "test")
      .click("span[id$=agencyModal] input[value='Cancel']")
      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
      .click("input[value='Add Agency Involved With Individual']")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .timeoutsImplicitWait(3000)
      .fillInputText("Agency Name:", "test")
      .waitUntil(function() {
  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)
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
      .click("input[value='Save Referral']")
      
      
      .waitForVisible("input[value='Edit']", defaultOperationTimeout)
      .url()
      .then(function (url) {
        assert.include(url.value, "referral2");
      })
      //Asserting Agency from referral creation
      .tableToJSON("[id$=agencyTable]")
      .then(function (agencyn) {
    	  agencyn = agencyn.map(function (agencyTable) {
    		  delete agencyTable["Created Date"];
    		  return agencyTable;
    	  });
    	  var obj2 = [agen[0]];
        assert.deepEqual(obj2, agencyn);
      })
      //Asserting Relatedparty from referral creation
      .tableToJSON("[id$=rpartyTable]")
      .then(function (rpartyn) {
    	  rpartyn = rpartyn.map(function (rpartyTable) {
    		  delete rpartyTable["Created Date"];
    		  return rpartyTable;
    	  });
    	  var relpcg = [relatedp[0]];
        assert.deepEqual(relpcg, rpartyn);
      })
      //Adding another agency on save referral
      .click("input[value='Add Agency Involved With Individual']")
      .fillInputText("Agency Name:", "test")
      .click("span[id$=agencyModal] input[value='Cancel']")
      .waitForVisible("input[value='Add Agency Involved With Individual']", defaultOperationTimeout)
      .click("input[value='Add Agency Involved With Individual']")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .timeoutsImplicitWait(3000)
      .fillInputText("Agency Name:", "test")
      .waitUntil(function() {
  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)
      .fillInputText("Agency Name:", "testName")
      .fillInputText("Address:", "404 test street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "test")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      //Asserting agency
      .tableToJSON("[id$=agencyTable]")
      .then(function (agencyf) {
    	  agencyf = agencyf.map(function (agencyTable) {
    		  delete agencyTable["Created Date"];
    		  return agencyTable;
    	  });
    	  var obj3 = [agen[1]];
    	  var obj4 = [agencyf[1]];
        assert.deepEqual(obj3, obj4);
      })

      .waitForVisible("input[value='Convert']", defaultOperationTimeout)
      .click("input[value='Convert']")
      
      .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      .click("input[value='Confirm Conversion']")
      //After Conversion
      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
      //Asserting Agency after convert
      .tableToJSON("[id$=agencyTable]")
      .then(function (agencyg) {
    	  agencyg = agencyg.map(function (agencyTable) {
    		  delete agencyTable["Created Date"];
    		  return agencyTable;
    	  });
    	  var obj7 = [agen[1]];
    	  var obj8 = [agencyg[1]];
        assert.deepEqual(obj7, obj8);
      })
      //Asserting relatedparty after convert including Case Manager use case
      .tableToJSON("[id$=rpartyTable]")
      .then(function (rpartyn) {
    	  rpartyn = rpartyn.map(function (rpartyTable) {
    		  delete rpartyTable["Created Date"];
    		  return rpartyTable;
    	  })
    	  var careG = [rpartyn[0]];
    	  var caseM = [rpartyn[1]];
    	  var rpcg = [relatedp[0]];
    	  var rpcm = [relatedp[1]];
    	  
        assert.deepEqual(rpcg, careG);
        assert.deepEqual(rpcm, caseM);
      })
      //Adding Related Party on PBS
      .scroll("input[value='Add Related Party']", 0 , -300)
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Party Name", "Party")
      .click("span[id$=relatedPartyModal] input[value='Cancel']")
      .click("input[value='Add Related Party']")
      .fillInputText("Party Name", "Party")
      .chooseSelectOption("Type", "Adjuster")
      .waitUntil(function() {
  		return this.getText("[id$=relatedPartyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)
	  .fillInputText("Party Name", "PBSParty")
      .chooseSelectOption("Type", "Adjuster")
      .fillInputText("Address", "Above the Sky")
      .setValue("input[id$=relatedPartyEntry_Email]", "Someone@something.com")
      .fillInputText("Phone 1", "1111111")
      .fillInputText("Phone 2", "2222222")
      .chooseSelectOption("Phone 1 Type", "Home")
      .chooseSelectOption("Phone 2 Type", "Cell")
      .setValue("span[id$=relatedPartyModal] textarea[id$=relatedPartyEntry_Comments]","This is a test")
      .selectByValue("span[id$=relatedPartyModal] select[id$=relatedPartyEntry_Status]", "Active")
      .click("span[id$=relatedPartyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      //Asserting related party on PBS
      .tableToJSON("[id$=rpartyTable]")
      .then(function (rpartyn) {
    	  rpartyn = rpartyn.map(function (rpartyTable) {
    		  delete rpartyTable["Created Date"];
    		  return rpartyTable;
    	  })
    	  var careA = [rpartyn[0]];
    	  var caseM = [rpartyn[2]];
    	  var careG = [rpartyn[1]];
    	  var rpcg = [relatedp[0]];
    	  var rpcm = [relatedp[1]];
    	  var rpa = [relatedp[2]];
    	  
        assert.deepEqual(rpcg, careG);
        assert.deepEqual(rpcm, caseM);
        assert.deepEqual(rpa, careA);
      })
      //Adding agency on PBS
      .scroll("[id$=addAgency]", 0 , -300)
	  .click("[id$=addAgency]")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Agency Name:", "test")
      .waitUntil(function() {
  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)
      .fillInputText("Agency Name:", "testPBS")
      .fillInputText("Address:", "313 Wilcox Street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "timeout")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      //Asserting agency on PBS.
      .tableToJSON("[id$=agencyTable]")
      .then(function (agencyh) {
    	  agencyh = agencyh.map(function (agencyTable) {
    		  delete agencyTable["Created Date"];
    		  return agencyTable;
    	  });
    	  var obj5 = [agen[2]];
    	  var obj6 = [agencyh[2]];
        assert.deepEqual(obj5, obj6);
      })
      //Adding Allergy on PBS
      .scroll("input[value='Add Allergy']", 0 , -300)
      .click("input[value='Add Allergy']")
      .waitForVisible("span[id$=responseDialog] input[value='Save']", defaultOperationTimeout)
      .chooseSelectOption("Allergy Type", "Food")
      .click("span[id$=responseDialog] input[value='Cancel']")
      .click("input[value='Add Allergy']")
      .waitForVisible("span[id$=responseDialog] input[value='Save']", defaultOperationTimeout)
      .chooseSelectOption("Allergy Type", "Food")
      .fillInputText("Allergy Details", "Peanuts")
      //.selectCheckbox("Life Threatening")
      .click("span[id$=responseDialog] input[value='Save']")
      .waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
      //Asserting allergy on PBS
      .tableToJSON("[id$=responseTable]")
      .then(function (allergyp) {
    	  var all1 = [allerg[0]];
     	 assert.deepEqual(all1, allergyp);
      })
      //Editing existing related party
      .scroll("input[value='Add Related Party']", 0 , -300)
      .click("table[id$=rpartyTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Party Name", "Hector")
      .chooseSelectOption("Type", "Adjuster")
      .waitUntil(function() {
          return this.getText("[id$=relatedPartyEntry_Name]").then(function(text) {
           	return text === ''
           })
       }, defaultOperationTimeout)
      .fillInputText("Party Name", "Hector")
      .chooseSelectOption("Type", "Spouse")
      .fillInputText("Address", "Beneath the fire")
      .setValue("input[id$=relatedPartyEntry_Email]", "Someone@something.com")
      .fillInputText("Phone 1", "1111111")
      .fillInputText("Phone 2", "2222222")
      .chooseSelectOption("Phone 1 Type", "Home")
      .chooseSelectOption("Phone 2 Type", "Cell")
      .setValue("span[id$=relatedPartyModal] textarea[id$=relatedPartyEntry_Comments]","Win win")
      .selectByValue("span[id$=relatedPartyModal] select[id$=relatedPartyEntry_Status]", "Active")
      .click("span[id$=relatedPartyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      //Asserting edited related party
      .tableToJSON("[id$=rpartyTable]")
      .then(function (rpartyp) {
    	  rpartyp = rpartyp.map(function (rpartyTable) {
    		  delete rpartyTable["Created Date"];
    		  return rpartyTable;
    	  });
    	  var relpedit = [relatedp[3]];
    	  var rpartypedit = [rpartyp[2]]
        assert.deepEqual(relpedit, rpartypedit);
      })
      //Editing existing agency
      .scroll("[id$=addAgency]", 0 , -300)
      .click("table[id$=agencyTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Agency Name:", "test")
      .waitUntil(function() {
  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)
      .fillInputText("Agency Name:", "testPBSedit")
      .fillInputText("Address:", "313 marshmallow Street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "random")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      //Asserting edited agency
      .tableToJSON("[id$=agencyTable]")
      .then(function (agencya) {
    	  agencya = agencya.map(function (agencyTable) {
    		  delete agencyTable["Created Date"];
    		  return agencyTable;
    	  });
    	  var agenedit = [agen[3]];
    	  var agencyedit = [agencya[0]];
        assert.deepEqual(agenedit, agencyedit);
      })
      //Editing existing allergy
      .click("table[id$=responseTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=responseDialog] input[value='Save']", defaultOperationTimeout)
      .chooseSelectOption("Allergy Type", "Other")
      .fillInputText("Allergy Details", "Cats")
      .click("span[id$=responseDialog] input[value='Save']")
      .waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
      //Asserting Edited allergy
      .tableToJSON("[id$=responseTable]")
      .then(function (allergye) {
    	  var all2 = [allerg[1]];
    	  assert.deepEqual(all2, allergye);
      }) 
  }
});
