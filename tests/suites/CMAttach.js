var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("CMAttach", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["CM_Marketer"];
  var saveurl;
    return client
		.execUtil("create_referral", {operatingGroup: "Care Meridian",flavor: "AZ"})
		//Referral
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
    .isExisting("span=Choose file")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){  // Ensure there are no files already attached
      assert.equal(files.length, 0);
    })
		//U4
    .chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){  // Ensure there's only 1 file attached
      assert.equal(files.length, 1);
      assert.deepEqual(files[0].Title, "Koala.txt");
      assert.deepEqual(files[0].Description, "");
    })
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
    // What is this looking to not find? Multiple file controls?
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){
      assert.equal(files.length, 2);
      assert.deepEqual(files[0].Title, "Koala.txt");
      assert.deepEqual(files[0].Description, "Testing File Upload");
    })
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id*='0:files:']","./data/Penguins.txt")
		.chooseFile("input[id*='1:files:']","./data/Tulips.txt")
		.chooseFile("input[id*='2:files:']","./data/Desert.txt")
		.chooseFile("input[id*='3:files:']","./data/Jellyfish.txt")
		.chooseFile("input[id*='4:files:']","./data/Koala.txt")
		.click("input[value='Upload']")
    .isExisting("span=Choose file")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){
      assert.equal(files.length, 7);
      // This matches the observed order
/*      assert.deepEqual(files[0].Title, "Penguins.txt");
      assert.deepEqual(files[0].Description, "");
      assert.deepEqual(files[1].Title, "Koala.txt");
      assert.deepEqual(files[1].Description, "");
      assert.deepEqual(files[2].Title, "Jellyfish.txt");
      assert.deepEqual(files[2].Description, "");
      assert.deepEqual(files[3].Title, "Desert.txt");
      assert.deepEqual(files[3].Description, "");
      assert.deepEqual(files[4].Title, "Tulips.txt");
      assert.deepEqual(files[4].Description, "");
*/    })
		//U7
		.click("input[value='Add Multiple']")
    .waitForVisible("input[value='Upload']", defaultOperationTimeout)
    .chooseFile("input[id*='0:files:']","./data/Penguins.txt")
  	.chooseFile("input[id*='1:files:']","./data/Tulips.txt")
  	.chooseFile("input[id*='2:files:']","./data/Desert.txt")
  	.chooseFile("input[id*='3:files:']","./data/Jellyfish.txt")
  	.chooseFile("input[id*='4:files:']","./data/Koala.txt")
		.click("input[value='Upload']")
    .waitForVisible("span=Choose file", defaultOperationTimeout)
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){
      assert.equal(files.length, 10);   // Display is limited to 10 most recent files
      // This matches the observed order
/*      assert.deepEqual(files[0].Title, "Penguins.txt");
      assert.deepEqual(files[0].Description, "");
      assert.deepEqual(files[1].Title, "Koala.txt");
      assert.deepEqual(files[1].Description, "");
      assert.deepEqual(files[2].Title, "Jellyfish.txt");
      assert.deepEqual(files[2].Description, "");
      assert.deepEqual(files[3].Title, "Desert.txt");
      assert.deepEqual(files[3].Description, "");
      assert.deepEqual(files[4].Title, "Tulips.txt");
      assert.deepEqual(files[4].Description, "");
*/    })
		//U8/9
    .waitForVisible("span=Choose file", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
    .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 1")
    .click("input[value='Cancel']")   // Should there be a warning about cancelling changes?
    .waitForExist("td=Referral 1",defaultOperationTimeout,true)
		//A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 2")
    .click("input[value='Save']")
    .isExisting("td=Referral 2")
		//A5
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 3")
		.click("input[value='Save']")
    .isExisting("td=Referral 3")
		//A7/13
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Referral 4")
    .click("input[value='Cancel']")
    .waitForExist("td=Referral 4",defaultOperationTimeout,true)
		//A9/11/12
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 5")
    .click("input[value='Cancel']")
    .waitForExist("td=Referral 5",defaultOperationTimeout,true)
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
		.getUrl().then(function(url) {
        saveurl=url;
		})
	  .logInAs(users["CM_DON"])
		.then(function () {
		    return client.url(saveurl)
		})
		.click("input[value='Convert']")
		.waitForVisible("span[id$='ReferralAdmissionLocationModal'] input[value='Save and Continue']", defaultOperationTimeout)
		.click("span[id$='ReferralAdmissionLocationModal'] input[value='Save and Continue']")
    .waitForVisible("input[value='Confirm Conversion']", defaultOperationTimeout)
		.click("input[value='Confirm Conversion']")
		//Persons Being Served
		//U1
    .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
    .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
    .isExisting("a=Koala.txt")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
    .isExisting("td=Testing File Upload")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
    .waitForVisible("input[value='Upload']", defaultOperationTimeout)
    .chooseFile("input[id*='0:files:']","./data/Penguins.txt")
  	.chooseFile("input[id*='1:files:']","./data/Tulips.txt")
  	.chooseFile("input[id*='2:files:']","./data/Desert.txt")
  	.chooseFile("input[id*='3:files:']","./data/Jellyfish.txt")
  	.chooseFile("input[id*='4:files:']","./data/Koala.txt")
		.click("input[value='Upload']")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){
      assert.equal(files.length, 7);
      // This matches the observed order
/*      assert.deepEqual(files[0].Title, "Penguins.txt");
      assert.deepEqual(files[0].Description, "");
      assert.deepEqual(files[1].Title, "Koala.txt");
      assert.deepEqual(files[1].Description, "");
      assert.deepEqual(files[2].Title, "Jellyfish.txt");
      assert.deepEqual(files[2].Description, "");
      assert.deepEqual(files[3].Title, "Desert.txt");
      assert.deepEqual(files[3].Description, "");
      assert.deepEqual(files[4].Title, "Tulips.txt");
      assert.deepEqual(files[4].Description, "");
*/    })
		//U7
		.click("input[value='Add Multiple']")
    .waitForVisible("input[value='Upload']", defaultOperationTimeout)
    .chooseFile("input[id*='0:files:']","./data/Penguins.txt")
  	.chooseFile("input[id*='1:files:']","./data/Tulips.txt")
  	.chooseFile("input[id*='2:files:']","./data/Desert.txt")
  	.chooseFile("input[id*='3:files:']","./data/Jellyfish.txt")
  	.chooseFile("input[id*='4:files:']","./data/Koala.txt")
		.click("input[value='Upload']")
    .tableToJSON("table[id$='attachmentsTable']")
    .then(function(files){
      assert.equal(files.length, 10);
      // This matches the observed order
/*      assert.deepEqual(files[0].Title, "Penguins.txt");
      assert.deepEqual(files[0].Description, "");
      assert.deepEqual(files[1].Title, "Koala.txt");
      assert.deepEqual(files[1].Description, "");
      assert.deepEqual(files[2].Title, "Jellyfish.txt");
      assert.deepEqual(files[2].Description, "");
      assert.deepEqual(files[3].Title, "Desert.txt");
      assert.deepEqual(files[3].Description, "");
      assert.deepEqual(files[4].Title, "Tulips.txt");
      assert.deepEqual(files[4].Description, "");
*/    })
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
    .waitForExist("td=Testing File Upload",defaultOperationTimeout,true)
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
    .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PBS 1")
    .click("input[value='Cancel']")
    .waitForExist("td=PBS 1",defaultOperationTimeout,true)
		//A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PBS 2")
    .click("input[value='Save']")
    .isExisting("td=PBS 2")
		//A5
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PBS 3")
		.click("input[value='Save']")
    .isExisting("td=PBS 2")
		//A7/13
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "PBS 4")
    .click("input[value='Cancel']")
    .waitForExist("td=PBS 1",defaultOperationTimeout,true)
		//A9/11/12
    .scroll("input[value='View All']")
    .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PBS 5")
    .click("input[value='Cancel']")
    .waitForExist("td=PBS 1",defaultOperationTimeout,true)
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
/*
		//Person Card
		.click("a=Add/Edit Picture")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
      .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PersonCard 1")
      .click("input[value='Cancel']")
		 //A2
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PersonCard 2")
      .click("input[value='Save']")
		//A5
      .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PersonCard 3")
		.click("input[value='Save']")
		//A7/13
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "PersonCard 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "PersonCard 5")
      .click("input[value='Cancel']")
		//R1/7
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
*//*
		//Admission
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - Care Meridian")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("input[value='Attach File']")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
      .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Admission 1")
      .click("input[value='Cancel']")
		 //A2
		.scroll("input[value='Attach File']")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Admission 2")
      .click("input[value='Save']")
		//A5
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Admission 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Admission 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Admission 5")
      .click("input[value='Cancel']")
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
		//Service Assignment
		.scroll("a=C. AZ - SA1 - 114160 - ABI")
		.click("a=C. AZ - SA1 - 114160 - ABI")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
      .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "ServAssign 1")
      .click("input[value='Cancel']")
		 //A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "ServAssign 2")
      .click("input[value='Save']")
		//A5
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.scroll("a=Tulips.txt")
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "ServAssign 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "ServAssign 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "ServAssign 5")
      .click("input[value='Cancel']")
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
		.getUrl().then(function(url) {
        saveurl=url;
		})
/*	  .logInAs(users["CM_DON"])
		.then(function () {
			return client.url(saveurl)
		})
*//*		//Create Action Plan
		.scroll("input[value='Add Seizure']")
		.click("input[value='New Plan']")
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date","1/12/2016")
		.fillInputText("Target Date","1/14/2016")
		.setValue("textarea[id$=txtaoe]", "sdfgsdfgsdfgsdfg")
		.selectByValue("select[id$=stat1]", "New")
		.setValue("input[id$=effe1]","1/12/2016")
		.setValue("input[id$=tar1]","1/13/2016")
		.selectByValue("select[id$=type1]", "Skill")
		.selectByValue("select[id$=stat2]", "New")
		.setValue("input[id$=end1]","1/13/2016")
		.setValue("input[id$=start1]","1/12/2016")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.then(function () {
			return client.url(saveurl)
		})
/*
		.logInAs(users["CM_Marketer"])
		.then(function () {
			return client.url(saveurl)
		})
*//*
		//Action Plan
		.click("img[class='unstickPbs']")
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Restraint Reduction Report']")
		.click("span*=Inactive Draft")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
      .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 1")
      .click("input[value='Cancel']")
		 //A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 2")
      .click("input[value='Save']")
		//A5
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Action 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 5")
      .click("input[value='Cancel']")
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???

		//View Summary
		.click("input[value='View Summary']")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id$='test']","./data/Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:1:files:j_id1186:test']","./data/Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:2:files:j_id1186:test']","./data/Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:3:files:j_id1186:test']","./data/Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1182:j_id1185:4:files:j_id1186:test']","./data/Koala.txt")
		.click("input[value='Upload']")
		//U8/9
		.chooseFile("input[id$='test']","./data/Penguins.txt")
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Cancel']")
		//A1/13
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A3/4
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
      .click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 1")
      .click("input[value='Cancel']")
		 //A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 2")
      .click("input[value='Save']")
		//A5
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.isExisting("div=Action")
		.isExisting("div=Title")
		.isExisting("div=Description")
		.isExisting("div=Created Date/Time")
		.isExisting("div=Created By")
		//A6/8/10
		.click("a=Tulips.txt")
		.isExisting("td=Attachment Owner")
		.isExisting("td=File Name")
		.isExisting("td=Description")
		.isExisting("td=Size")
		.isExisting("a=View file")
		.isExisting("td=Created By")
		.isExisting("td=Modified By")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Summary 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 5")
      .click("input[value='Cancel']")
		//R1/7
		.scroll("a=Koala.txt")
		.click("a=Koala.txt")
		//R2
		.click("input[value='Delete']")
		//R4
		.click("span=No")
		.click("input[value='Delete']")
		//R3
		.click("span=Yes")
		//R5/6???
*/
		}
});
