var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var stripJsonComments = require("strip-json-comments");
var fs   = require('fs');

var suiteTimeout = 10 * 60 * 1000;
var defaultOperationTimeout = 2 * 60 * 1000;

testSuite("RWAttach", suiteTimeout, {
  "should add a diagnosis successfully": function(client, done) {
  var user = users["RW_AZ_User"];
  var today =new Date().getDate() + new Date().getMilliseconds();
    return client
		.execUtil("create_referral", {operatingGroup: "Redwood",flavor: "AZ"})
		//Referral
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
      .click("input[value='Cancel']")
		//A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 2")
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
		.setValue("textarea[id$=Description]", "Referral 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Referral 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 5")
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
		.click("input[value='Convert']")
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
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
      .click("input[value='Cancel']")
		//A2
		.scroll("a=Penguins.txt")
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 2")
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
		.setValue("textarea[id$=Description]", "Referral 3")
		.click("input[value='Save']")
		//A7/13
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Referral 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .scroll("input[value='View All']")
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Referral 5")
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
		
/*		//Person Card
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
*/

	//Admission
		.click("img[class='unstickPbs']")
		.scroll("input[value='Related Parties Report']")
		.click("a*=Admission 1 - Redwood")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
		.scroll("a=R. AZ - SA1 - 122010 - Residential Group Home")
		.click("a=R. AZ - SA1 - 122010 - Residential Group Home")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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

		//Action Plan
		.waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("img[class='unstickPbs']")
		.scroll("input[value='Associate Diagnosis']")
		.click("input[value='New Plan']")
      .waitForVisible("input[value='Save']", defaultOperationTimeout)
		.fillInputText("Effective Date","1/12/2016")
		.fillInputText("Target Date","1/14/2016")
		.setValue("textarea[id$=txtaoe]", "sdfgsdfgsdfgsdfg")
		.click("img[class='unstickPbs']")
		.scroll("input[value='Save']")
		.click("input[value='Save']")
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
		.setValue("textarea[id$=Description]", "Action 1")
      .click("input[value='Cancel']")
		 //A2
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 2")
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
		.setValue("textarea[id$=Description]", "Action 3")
		.click("input[value='Save']")
		//A7/13
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Action 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Action 5")
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
/*		
		//View Summary
		.click("input[value='View Summary']")
		//U1
      .waitForVisible("input[value='Attach File']", defaultOperationTimeout)
		.scroll("input[value='Attach File']")
		.click("input[value='Attach File']")
		//U3
      .isExisting("span=Choose file")
		//U4
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U5/2/10
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Koala.txt")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.fillInputText("Description", "Testing File Upload")
		.click("input[value='Upload']")
		//U2/6/10
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")
		//U7
		.click("input[value='Add Multiple']")
      .waitForVisible("input[value='Upload']", defaultOperationTimeout)
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:1:files:j_id1130:test']","Tulips.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:2:files:j_id1130:test']","Desert.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:3:files:j_id1130:test']","Jellyfish.txt")
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:4:files:j_id1130:test']","Koala.txt")
		.click("input[value='Upload']")		
		//U8/9
		.chooseFile("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1130:test']","Penguins.txt")
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
		.setValue("textarea[id$=Description]", "Summary 1")
      .click("input[value='Cancel']")
		 //A2
		.click("a=Penguins.txt")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 2")
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
		.setValue("textarea[id$=Description]", "Summary 3")
		.click("input[value='Save']")
		//A7/13
      .click("input[value='View All']")
		.waitForExist("input[id='uploader:j_id26:component:attForm:j_id1126:j_id1129:0:files:j_id1139:j_id1141:0']",defaultOperationTimeout,true)
		.waitForExist("a=  | Choose as Head Shot",defaultOperationTimeout,true)
		.click("a=Edit")
		.setValue("textarea[id$=Description]", "Summary 4")
      .click("input[value='Cancel']")
		//A9/11/12
      .click("input[value='View All']")
		.click("a=Tulips.txt")
		.click("a=View file")
		.click("input[value='Edit']")
		.setValue("textarea[id$=Description]", "Summary 5")
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
		*/
		}
});
