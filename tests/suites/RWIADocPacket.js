var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

var dpacka = [{"":"", "Packet Name": "As Needed Documents", "Document Name":"Inventory of Personal Effects","Version":"1","Type": "Non-Standard","Recurrence":"","Due Date":"1/15/2016","Status":"Received","Received Date":"4/1/2016","Comments":"Editing packet for regression"},
				{"":"", "Packet Name": "As Needed Documents", "Document Name":"Inventory of Personal Effects","Version":"1","Type": "Non-Standard","Recurrence":"","Due Date":"1/15/2016","Status":"Pending","Received Date":"","Comments":"Adding packet for regression"}];
testSuite(
		"RWMNDocPacket",
		suiteTimeout,
		{
			"Document packet test" : function(client, done) {
				return client
				// Referral Conversion
				.execUtil("convert_referral", {
					operatingGroup : "Redwood",
					flavor : "IA"
				})
				// Navigating to Admission
				.scroll("[id$=adminsId]", 0, -300)
				.click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")
				.windowHandleMaximize()
				.scroll("[id$=addDocPacket]", 0, -300)
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']")
				//Adding Documents
				.scroll("[id$=addDocPacket]", 0, -300)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("table[id$=pb_packetDoc] tbody tr:nth-child(2) td:nth-child(1) span")
				//.elements("span[class='fancytree-checkbox'])")
				//.then(function (elements) {
				//	return elements[1];
				//})
				//.then(client.click)
				.waitForVisible("span[id$=addAdmissionDocumentModal] select[id$=currrentAssocDoc_Status]",defaultOperationTimeout)
				//.setValue("input[id$=currrentAssocDoc_Due_Date_edit]", "04/30/2016")
				//.setValue("select[id$=currrentAssocDoc_Status]", "Received")
				.selectByValue('select[id$=currrentAssocDoc_Status]', 'Pending')
				.setValue("textarea[id$=currrentAssocDoc_Comments]", "Adding packet for regression")
				.click("span[id$=addAdmissionDocumentModal] input[value='Save']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.pause(3000)
				//Asserting added document
				.tableToJSON("[id$=docPacketTable]")
				.then(function (dpack) {
					dpack = dpack.map(function (docpacktable) {
					return docpacktable;
					})
					var d1 = [dpack[0]];
					var d2 = [dpacka[1]];
					assert.deepEqual(d1, d2);
					console.log(JSON.stringify(d1));
				})
				//Editing existing document
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.scroll("[id$=addDocPacket]", 0, -300)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']")
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("table[id$=pb_packetDoc] tbody tr:nth-child(2) td:nth-child(1) span")
				.click("table[id$=pb_packetDoc] tbody tr:nth-child(2) td:nth-child(1) span")
				//.elements("span[class='fancytree-checkbox'])")
				//.then(function (elements) {
				//	return elements[1];
				//})
				//.then(client.click)
				.pause(3000)
				.selectByValue('select[id$=currrentAssocDoc_Status]', 'Received')
				.setValue("textarea[id$=currrentAssocDoc_Comments]", "Editing packet for regression")
				.setValue("input[id$=currrentAssocDoc_Status_Date]", "04/01/2016")
				.click("span[id$=addAdmissionDocumentModal] input[value='Save']")
				.scroll("[id$=addDocPacket]", 0, -300)
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.pause(3000)
				//Asserting added document
				.tableToJSON("[id$=docPacketTable]")
				.then(function (dpack1) {
					dpack1 = dpack1.map(function (docpacktable) {
					return docpacktable;
					})
					var d1 = [dpack1[0]];
					var d2 = [dpacka[0]];
					assert.deepEqual(d1, d2);
					console.log(JSON.stringify(d1));
				})
				//Removing existing document
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.scroll("[id$=addDocPacket]", 0, -300)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']")
				//Removing Documents
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("table[id$=pb_packetDoc] tbody tr:nth-child(2) td:nth-child(1) span")
				//.elements("span[class='fancytree-checkbox'])")
				//.then(function (elements) {
				//	return elements[1];
				//})
				//.then(client.click)
				//.waitForVisible("span[id$=addAdmissionDocumentModal] input[id$=currrentAssocDoc_Due_Date_edit]",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Save']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.pause(3000)
				//Checking removed document
				.tableToJSON("[id$=docPacketTable]")
				.then(function (dpack2) {
					dpack2 = dpack2.map(function (docpacktable2) {
					return docpacktable2;
					})
					var d3 = [dpack2[0]];
					var d4 = [dpacka[0]];
					assert.notEqual(d3, d4);
					console.log(JSON.stringify(d3));
				})
				/*Negative Cases
				.waitForVisible("[id$='msgs'] .messageText", defaultOperationTimeout)
				.getText("#msgs*=First Name: You must enter a value") // This is equivalent to assert
				*/
			}
		})