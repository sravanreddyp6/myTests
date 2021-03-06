var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var GaRefPa = JSON.parse(stripJsonComments(fs.readFileSync("./configs/GaReferralPage.json", "utf8")));
var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
var diagn = [{"Action": "Edit", "ICD-10 Code":"A01.02","Code Type":"","ICD/DSM-VDescription/Axis-IV Description":"Typhoid fever with heart involvement", "Date and Time of Diagnosis": "12/31/2015 15:00", "Status": "Active", "Type": ""}];
//Should cover Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7 for NR
//Should cover Test Case: View Diagnosis 1-6 for NR
//Should cover Test Case: Add Diagnosis(Referral, New Referral, Referral to PBS Conversion) 1-9 for NR
//Should cover Test Case: Change Diagnosis Info/Status/Ranking 1-5 for NR
testSuite("NR_Assoc_Diag", suiteTimeout, {
  "Test Case: Associate/Disassociate Diagnosis to Service Assignment 1-7, Test Case: View Diagnosis 1-6, Test Case: Add Diagnosis(Referral, New Referral, Referral to PBS Conversion) 1-9, and Test Case: Change Diagnosis Info/Status/Ranking 1-5 all for NR. Also, should associate a diagnosis with a PBS successfully": function(client, done) {
    return client
      .execUtil("convert_referral", {
      operatingGroup: "NeuroRestorative",
      flavor: "MA",
      hooks: {
      		"convert_referral_initial_referral": function (client) {
      		return client.isExisting("input[value='PRE 10/1/2015']")
      .then(function (isExisting) {
      		if(isExisting==false)
      	return true;
      		else
      	return this.click("input[value='PRE 10/1/2015']");
      })
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
	  .click("table[id$=diagTable] tbody tr:nth-child(1) td:nth-child(1) a")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      
      .click("a[id$=diagnosisEntry_icd_lkwgt]")
      //.selectLookup("ICD-10 Code")
      .switchToNextWindow()
      .element("#searchFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .setValue("input#lksrch", "02")
      .click("input[value*='Go']")
      .frameParent()
      .waitForExist("#resultsFrame", defaultOperationTimeout)
      .element("#resultsFrame")
      .then(function (frame) { return frame.value; })
      .then(client.frame)
      .click("tr.dataRow th a:first-child")
      .switchToNextWindow()
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .fillInputText("Date and Time of Diagnosis", "12/31/2015 15:00")
      .selectByValue("select[id$=diagnosisEntry_status]", "Active")
      .click("span[id$=diagnosisModal] input[value='Save']")
      //.waitForVisible("input[value='Add Funding Source']", defaultOperationTimeout)
      .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
      //.waitForExist("span[id$=AdddiagStatus] img[class=dialogLoadingSpinner]", 2000, true)
      .refresh()
        	}
        }
      })
      
      //.waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
      //.click("input[value='Confirm Conversion']")
      //.click("a[title='iServe Home Tab']")
      //.click("a=My Recently Viewed Persons Being Served")
      //.waitForVisible("input[value='Refresh']", defaultOperationTimeout)
      //.click("table#persons_table tbody tr:nth-child(1) td:nth-child(3) a")
      //.element("#resultsFrame")
      //.then(function (frame) { return frame.value; })
      //.then(client.frame)
      //.click("tr.dataRow th a:first-child")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .tableToJSON("[id$=diagTable]")
      .then(function (icd10code) {
        assert.deepEqual(diagn, icd10code);
      })
      .isExisting("input[value='PRE 10/1/2015']")
      .then(function (isExisting) {
      		if(isExisting==false)
      	return true;
      		else
      	return this.click("input[value='PRE 10/1/2015']");
      })
      .click("input[value='Add Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      .getSelectOptionsBySelector("[id$=diagnosisEntry_type]")
	  .then(function(digtype) {
        assert.deepEqual([
          "", "Admission", "Discharge", "Onset", "Update"  ], digtype);
      })
      
      .click("a[id$=diagnosisEntry_icd_lkwgt]")
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
      .fillInputText("Date and Time of Diagnosis", "12/30/2015 12:00")
      .selectByValue("select[id$=diagnosisEntry_status]", "Active")
      .selectByValue("select[id$=diagnosisEntry_type]", "Admission")
      .click("span[id$=diagnosisModal] input[value='Save']")
	  .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	  .waitForActionStatusDisappearance("saveResponseStatus", defaultOperationTimeout)
	  .waitForActionStatusDisappearance("AdddiagStatus", defaultOperationTimeout)
	  .refresh()
      //.waitForExist("input[value='PRE 10/1/2015']",defaultOperationTimeout,true)
      //.then(function (el) {
      //		if(el==true)
      //	return true;
      //		else
      //	return this.click("input[value='PRE 10/1/2015']");
      //})
      .click("a*=Admission 1 -")
      .waitForVisible("input[value='Edit Admission']", defaultOperationTimeout)
      .refresh()
      .scroll("input[value='New Assessment Only']", 0, -500)
      .click("a*=N. MA - SA1 - 130201")
      .waitForVisible("input[value='Associate Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Associate Diagnosis']", 0, -500)
	  .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.01 - Typhoid meningitis", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .getSelectOptions("Injury Type")
      .then(function(injurytype) {
        var dash = String.fromCharCode("8211");
          assert.deepEqual(["", "Acquired Brain Injury - Anoxia/hypoxia", "Acquired Brain Injury " + dash + " CVA " + dash + " R hemiplegia",
          "Acquired Brain Injury " + dash + " CVA " + dash + " L hemiplegia", "Acquired Brain Injury " + dash + " TBI", "Acquired Brain Injury " + dash + " Other",
          "Cognitive Disorder", "CONGENTIAL", "Medical - Cardiac", "Medical - GI", "Medical - GU",
          "Medical - Cancer", "Neuro - Degenerative", "Neuro - Non-degenerative", "PTSD", 
          "Pulmonary - End-stage", "Pulmonary - Other", "Orthopedic - Disease", "Orthopedic - Injury",
          "Spinal Cord Injury - C 1-3", "Spinal Cord Injury - C4-5", "Spinal Cord Injury - C6-8",
          "Spinal Cord Injury - Paraplegia", "Other"], injurytype);
      })
      .getSelectOptions("Glasgow Coma Score at Injury")
      .then(function(glasgowcomainjury) {
          assert.deepEqual(["", "3-8", "9-12", "13-15" ], glasgowcomainjury);
      })
      .getSelectOptions("Glasgow Coma Scale Severity")
      .then(function(glasgowcomasev) {
          assert.deepEqual(["", "Mild", "Moderate", "Severe"], glasgowcomasev);
      })
      
      .chooseSelectOption("Injury Type", "PTSD")
      .selectCheckbox("ABI Diagnosis")
      .fillInputText("Injury Date", "12/25/2015")
      .selectCheckbox("Billable")
      .chooseSelectOption("Glasgow Coma Score at Injury", "3-8")
      .chooseSelectOption("Glasgow Coma Scale Severity", "Severe")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      .click("a=Edit")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.01 - Typhoid meningitis", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Secondary")
      .selectCheckbox("Billable")
      .click("span[id$=saDiagModal] input[value='Save']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .refresh()
      .click("input[value='Associate Diagnosis']")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
	  .waitForVisible("span[id$=saDiagModal] input[value='Save']", defaultOperationTimeout)
	  .getSelectOptionsBySelector("[id$=pbsdiagSelectList]", "true")
      .then(function(pbsdiaglist) {
          assert.deepEqual(["--None--", "A01.02 - Typhoid fever with heart involvement", "A01.01 - Typhoid meningitis"], pbsdiaglist);
      })
	  .getSelectOptionsBySelector("[id$=sadiagJoEntry_sadiagJoRanking]")
      .then(function(sadiagJoEntry) {
          assert.deepEqual(["", "Primary", "Secondary", "Tertiary" ], sadiagJoEntry);
      })
      
      .chooseSelectOption("Diagnosis", "A01.02 - Typhoid fever with heart involvement", "true")
      .selectByValue("select[id$=sadiagJoEntry_sadiagJoRanking]", "Primary")
      .getSelectOptions("Injury Type")
      .then(function(injurytype) {
        var dash = String.fromCharCode("8211");
          assert.deepEqual(["", "Acquired Brain Injury - Anoxia/hypoxia", "Acquired Brain Injury " + dash + " CVA " + dash + " R hemiplegia",
          "Acquired Brain Injury " + dash + " CVA " + dash + " L hemiplegia", "Acquired Brain Injury " + dash + " TBI", "Acquired Brain Injury " + dash + " Other",
          "Cognitive Disorder", "CONGENTIAL", "Medical - Cardiac", "Medical - GI", "Medical - GU",
          "Medical - Cancer", "Neuro - Degenerative", "Neuro - Non-degenerative", "PTSD", 
          "Pulmonary - End-stage", "Pulmonary - Other", "Orthopedic - Disease", "Orthopedic - Injury",
          "Spinal Cord Injury - C 1-3", "Spinal Cord Injury - C4-5", "Spinal Cord Injury - C6-8",
          "Spinal Cord Injury - Paraplegia", "Other"], injurytype);
      })
      .getSelectOptions("Glasgow Coma Score at Injury")
      .then(function(glasgowcomainjury) {
          assert.deepEqual(["", "3-8", "9-12", "13-15" ], glasgowcomainjury);
      })
      .getSelectOptions("Glasgow Coma Scale Severity")
      .then(function(glasgowcomasev) {
          assert.deepEqual(["", "Mild", "Moderate", "Severe" ], glasgowcomasev);
      })
      
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
      .click("a*=View Admission")
      .waitForVisible("input[value='Add Diagnosis']", defaultOperationTimeout)
      .scroll("input[value='Add Diagnosis']", 0, -500)
      .click("a=Edit")
      .waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
      .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
      .getSelectOptionsBySelector("[id$=diagnosisEntry_status]")
	  .then(function(digstat) {
        assert.deepEqual([
          "", "Active", "Inactive", "Void" ], digstat);
      })
      .selectByValue("select[id$=diagnosisEntry_status]", "Void")
      .selectByValue("select[id$=diagnosisEntry_type]", "Admission")
	  .waitForVisible("span[id$=diagnosisModal] input[value='Save']", defaultOperationTimeout)
	  .click("span[id$=diagnosisModal] input[value='Save']")
	  isExisting("li*=You cannot inactivate this Diagnosis as it is associated with an Active Service Assignment.")

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