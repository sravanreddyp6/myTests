var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 3 * 60 * 1000;
var relatedp = [{"Action": "Edit", "Type":"Caregiver","Party Name":"Party","Address":"Somewhere", "Email": "someone@something.com", "Phone 1":"8888888", "Phone 1 Type":"Home", "Phone 2":"7777777","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"This is a test"},
                {"Action": "Edit", "Type":"Case Manager", "Party Name": "Qui Gon Jinn", "Address":"", "Email": "", "Phone 1":"8675309", "Phone 1 Type":"", "Phone 2":"","Phone 2 Type":"" , "Status":"Active", "Comments":""},
                {"Action": "Edit", "Type":"Adjuster","Party Name":"PBSParty","Address":"Above the Sky", "Email": "someone@something.com", "Phone 1":"1111111", "Phone 1 Type":"Home", "Phone 2":"2222222","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"This is a test"},
                {"Action": "Edit", "Type":"Spouse","Party Name":"Hector","Address":"Beneath the fire", "Email": "someone@something.com", "Phone 1":"1111111", "Phone 1 Type":"Home", "Phone 2":"2222222","Phone 2 Type":"Cell" , "Status":"Active", "Comments":"Win win"}];
var allerg = [{"Action": "Edit", "Allergy Type":"Food","Allergy Details":"Peanuts","Life Threatening": ""},
              {"Action": "Edit", "Allergy Type":"Other","Allergy Details":"Cats","Life Threatening": ""}];

testSuite("CMAZRelatedLists", suiteTimeout, {
	"Should add, edit, cancel related parties, allergy successfully": function(client, done) {
		var firstName;
		var lastName;
		var user = users["CM_Marketer"];

		return client
		.execUtil("convert_referral", {
			operatingGroup: "Care Meridian",
			flavor: "AZ",
			hooks: {
				"create_referral_before_save_referral": function (client) {
					//Adding Related Party on referral creation

					return client
					.click("input[value='Add Related Party']")
					.waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
					.fillInputText("Party Name", "Party")
					.click("span[id$=relatedPartyModal] input[value='Cancel']")
					.click("input[value='Add Related Party']")
					.waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)

					.getSelectOptions("Type")
					.then(function(typeParty) {
						assert.deepEqual(["", "Adjuster","Attorney", "Caregiver", "Case Manager", "Common Law Employer", "Conservator", "Designated Representative", "Employment", 
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
				},
				"create_referral_after_save_referral": function (client) {
					return client
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
				}
			}
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
		//.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
		.pause(3000)
		//Asserting related party on PBS
		.tableToJSON("[id$=rpartyTable]")
		.then(function (rpartyn) {
			rpartyn = rpartyn.map(function (rpartyTable) {
				delete rpartyTable["Created Date"];
				return rpartyTable;
			})
			var careA = [rpartyn[0]];
			var careG = [rpartyn[1]];
			var rpcg = [relatedp[0]];
			var rpa = [relatedp[2]];

			assert.deepEqual(rpcg, careG);
			assert.deepEqual(rpa, careA);
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
		//.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
		.pause(3000)
		//Asserting edited related party
		.tableToJSON("[id$=rpartyTable]")
		.then(function (rpartyp) {
			rpartyp = rpartyp.map(function (rpartyTable) {
				delete rpartyTable["Created Date"];
				return rpartyTable;
			});
			var relpedit = [relatedp[3]];
			var rpartypedit = [rpartyp[1]];
			assert.deepEqual(relpedit, rpartypedit);
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
		.getOutputText("First Name")
		.then(function (fName){

			firstName = fName;
			console.log("first Name"+firstName);

		})
		.getOutputText("Last Name")
		.then(function (lName){

			lastName = lName;
			console.log("Last Name"+lastName);
		})
		
		/* Make sure you cannot Add a Personal Agent for Care Meridian on the Service Assignment*/
		
		//Navigating to Admission Page
        .scroll("[id$=adminsId]", 0 , -300)
        .click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")  
        .windowHandleMaximize() 
       
        //Navigating to Service Assignment Page
        .waitForVisible("input[value='New Standard Service']", defaultOperationTimeout)
        .scroll("[id$=servAssignId]", 0 , -300)
        .click("table[id$=servAssignId] tbody tr:nth-child(1) td:nth-child(2) a") 
        
  		//Add Personal Agent button should NOT exist on the Page
        .isExisting("input[value='Add Personal Agent']")
        .then(function(isExist){
    	  assert(!isExist);
         })      
         
		.logInAs(user)
		
		//.scroll("a=Home", 0 , -300)
		//.click("a=Home")
		.scroll("a=Search Referrals", 0 , -300)
		.click("a=Search Referrals")
		.waitForVisible("input[value='Back']", defaultOperationTimeout)
		.then(function () {
			return this.fillInputText("First Name",firstName);
			return this.fillInputText("Last Name",lastName);
		})
		.click("input[type='submit'][value='Search']", defaultOperationTimeout)
		.pause(3000)
		.click("table[id$=referralSearchTable] tbody tr:nth-child(1) td:nth-child(7) a")
		.pause(3000)
		.execUtil("convert_referral", {
			operatingGroup: "Care Meridian",
			flavor: "AZ",
			bypassPbrCreation: true,
			hooks: {
				"create_referral_initial_referral": function (client) {
					return client
					.selectByValue("[id$=sfps]", "Arizona")
					.pause(3000)
					.chooseSelectOption("Referral Status", "New")
					.fillInputText("Referral Date", "01/14/2016")
				},
				"create_referral_before_save_referral": function (client) {
					return client
					//Adding related party on new referral for converted referral
					.click("input[value='Add Related Party']")
					.waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)
					.fillInputText("Party Name", "Party")
					.click("span[id$=relatedPartyModal] input[value='Cancel']")
					.click("input[value='Add Related Party']")
					.waitForVisible("span[id$=relatedPartyModal] input[value='Save']", defaultOperationTimeout)

					.getSelectOptions("Type")
					.then(function(typeParty) {
						assert.deepEqual(["", "Adjuster","Attorney", "Caregiver", "Case Manager", "Common Law Employer", "Conservator", "Designated Representative", "Employment", 
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
					.fillInputText("Party Name", "Tony McGregor")
					.chooseSelectOption("Type", "Caregiver")
					.fillInputText("Address", "300 boulevard")
					.setValue("input[id$=relatedPartyEntry_Email]", "test@test.com")
					.fillInputText("Phone 1", "1111111")
					.fillInputText("Phone 2", "6666666")
					.chooseSelectOption("Phone 1 Type", "Home")
					.chooseSelectOption("Phone 2 Type", "Cell")
					.setValue("span[id$=relatedPartyModal] textarea[id$=relatedPartyEntry_Comments]","This is a test")
					.selectByValue("span[id$=relatedPartyModal] select[id$=relatedPartyEntry_Status]", "Active")
					.click("span[id$=relatedPartyModal] input[value='Save']")
					.waitForActionStatusDisappearance("myStatus", defaultOperationTimeout)
				},
				"create_referral_after_save_referral": function (client) {
					return client
					//Asserting Relatedparty from referral creation
					.tableToJSON("[id$=rpartyTable]")
					.then(function (rpartyn) {
						assert(rpartyn.length==3);
						console.log(rpartyn.length);
					})
				}
			}
		})
		.tableToJSON("[id$=rpartyTable]")
		.then(function (rpartyn) {
			assert(rpartyn.length==3);
		})
	}
});

