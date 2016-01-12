var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

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

testSuite("NRILRelatedLists", suiteTimeout, {
  "Should add, edit, cancel related parties, agencies, allergy successfully": function(client, done) {
  var user = users["NR_funding"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["NR_funding"])
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
      .fillInputText("Mailing City", "Illinois")
      .chooseSelectOption("Mailing State/Province", "Illinois")
      .fillInputText("Mailing Zip/Postal Code", "23456")
      .fillInputText("Mailing County", "Illinois County")
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
      .chooseSelectOption("Referral Status", "Active")
      .chooseSelectOption("Referral Source Type", "Family")
      .chooseSelectOption("How did referrer learn about us?", "Internet Search")
      .waitForActionStatusDisappearance("statusRefSourceType", defaultOperationTimeout)
      .fillInputText("Referral Source", "Mentor")
      .fillInputText("Referrer Name", "Obi-wan Kennobi")
      .fillInputText("Referrer Phone Number", "586356")
       .selectLookup("Evaluated By (Internal)")
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
      .fillInputText("Date of Injury", "01/12/2016")
      .chooseSelectOption("Cause of Injury", "ATV")
      .chooseSelectOption("Current Location Type", "Home")
      .doubleClick("select[title='Services Requested - Available'] option[value='0']")
      .fillInputText("Reason for Referral", "Test")
      .fillInputText("Update Notes", "Test")
      .fillInputText("Anticipated Admission DateTime", "09/18/2015 12:00")
      .click("a[id$=originlookup]")
      .waitForVisible("span[id$=searchDialog2] input[value='First']", defaultOperationTimeout)
      .setValue("input[id$=originstate]","IL")
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
      .setValue("input[id$=addlocationstate]","IL")
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
	  .pause(6000)
      .fillInputText("Agency Name:", "test")
      .fillInputText("Address:", "404 test street")
      .fillInputText("Phone Number:", "8008378")
      .fillInputText("Reason for Involvement:", "test")
      .click("span[id$=agencyModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
      .click("input[value='Add Funding Source']")
      .waitForVisible("span[id$=FundingSourceModal] input[value='Save']", defaultOperationTimeout)
      .chooseSelectOption("Coverage Level", "Primary")
      .chooseSelectOption("Payer Type", "Auto")
      .click("span[id$=FundingSourceModal] input[value='Save']")
      .waitForActionStatusDisappearance("saveFundingSourceStatus", defaultOperationTimeout)
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
      /*.fillInputText("Agency Name:", "test")
      .waitUntil(function() {
  		return this.getText("[id$=agencyEntry_Name]").then(function(text) {
    		return text === ''
  		})
	   }, defaultOperationTimeout)*/
	  .pause(3000)
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
    	  var rpcg = [relatedp[0]];
    	  
        assert.deepEqual(rpcg, careG);
      })
      //Adding Related Party on PBS
      .scroll("input[value='Add Related Party']", 0 , -300)
      .click("input[value='Add Related Party']")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Party Name", "Party")
      .click("span[id$=relatedPartyModal] input[value='Cancel']")
      .click("input[value='Add Related Party']")
	   .pause(3000)
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
    	  var rpa = [relatedp[2]];
    	  
        assert.deepEqual(rpcg, careG);
        assert.deepEqual(rpa, careA);
      })
      //Adding agency on PBS
      .scroll("[id$=addAgency]", 0 , -300)
	  .click("[id$=addAgency]")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
	  .pause(3000)
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
      .click("span[id$=responseDialog] input[data-regression='AllergyCancel']")
      .click("input[value='Add Allergy']")
      .waitForVisible("span[id$=responseDialog] input[data-regression='AllergySave']", defaultOperationTimeout)
      .chooseSelectOption("Allergy Type", "Food")
      .fillInputText("Allergy Details", "Peanuts")
      //.selectCheckbox("Life Threatening")
      .click("span[id$=responseDialog] input[data-regression='AllergySave']")
      //.waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
      .waitForVisible("[data-regression='AllergyPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1)", defaultOperationTimeout)
      //Asserting allergy on PBS
      //.pause(3000)
      .tableToJSON("[data-regression='AllergyPanel'] table[id$='responseTable']")
      .then(function (allergyp) {
    	  var all1 = [allerg[0]];
     	 assert.deepEqual(all1, allergyp);
      })
      //Editing existing related party
      .scroll("input[value='Add Related Party']", 0 , -300)
      .click("table[id$=rpartyTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
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
    	  var rpartypedit = [rpartyp[1]]
        assert.deepEqual(relpedit, rpartypedit);
      })
      //Editing existing agency
      .scroll("[id$=addAgency]", 0 , -300)
      .click("table[id$=agencyTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=agencyModal] input[value='Save']", defaultOperationTimeout)
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
      .click("[data-regression='AllergyPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForVisible("span[id$=responseDialog] input[value='Save']", defaultOperationTimeout)
      .chooseSelectOption("Allergy Type", "Other")
      .fillInputText("Allergy Details", "Cats")
      .click("span[id$=responseDialog] input[data-regression='AllergySave']")
      .pause(3000)
      //.waitForVisible("[data-regression='AllergyPanel'] table[id$='responseTable'] tbody tr:nth-child(1) td:nth-child(1)", defaultOperationTimeout)
      //.waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
      //Asserting Edited allergy
      .tableToJSON("[data-regression='AllergyPanel'] table[id$='responseTable']")
      .then(function (allergye) {
    	  var all2 = [allerg[1]];
    	  assert.deepEqual(all2, allergye);
      })
  }
});
