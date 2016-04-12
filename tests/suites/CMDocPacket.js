/*
This suite tests Adding/editing/removing admission packets/documents on the admission. To create Admission packets please run CMDocCompliance.js
*/
var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

var dpacka = [{"":"", "Packet Name": "As Needed Documents", "Document Name":"Inventory of Personal Effects","Version":"1","Type": "Non-Standard","Recurrence":"","Due Date":"4/30/2016","Status":"Received","Received Date":"4/1/2016","Comments":"Editing packet for regression"},
				{"":"", "Packet Name": "As Needed Documents", "Document Name":"Inventory of Personal Effects","Version":"1","Type": "Non-Standard","Recurrence":"","Due Date":"4/30/2016","Status":"Pending","Received Date":"","Comments":"Adding packet for regression"}];
testSuite(
		"CMDocPacket",
		suiteTimeout,
		{
			"Should add, edit, remove documents for a PBS successfully" : function(client, done) {
				return client
				// Referral Conversion
				.execUtil("convert_referral", {
					operatingGroup : "Care Meridian",
					flavor : "CA"
				})
				// Navigating to Admission
				.scroll("[id$=adminsId]", 0, -300)
				.click("table[id$=adminsId] tbody tr:nth-child(1) td:nth-child(2) a")
				.windowHandleMaximize()
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				//Adding Documents
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				//making it click a particular element
				 .elements("table#pb_packetDoc span.fancytree-title")
				 .then(function (elements) {
					 var elementTexts = [];
					 elements.value.forEach(function (el) {
						 elementTexts.push(client.elementIdText(el.ELEMENT));
					 });
					 return this.unify(elementTexts)
					 .then(function (elementTexts) {
						 var elFound = false;
						 var i;
						 for (i=0; i<elementTexts.length; i++) {
							 if (elementTexts[i].value.indexOf("Inventory of Personal Effects") != -1) {
								 elFound = true;
								 break;
							 }
						 }
						 if (!elFound) {
							 throw new Error('Element Inventory of Personal Effects not found');
						 }
//			  			return elements.value[i].ELEMENT;
						 return i;
					 });
				 })
				 .then(function (index) {
					 return client.elements("table#pb_packetDoc span.fancytree-checkbox")
					 .then(function (els) {
						 return els.value[index].ELEMENT;
					 });
				 })
				 .then(client.elementIdClick)
				
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[id$=currrentAssocDoc_Due_Date_edit]",defaultOperationTimeout)
				.setValue("input[id$=currrentAssocDoc_Due_Date_edit]", "04/30/2016")
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
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.elements("table#pb_packetDoc span.fancytree-title")
				.then(function (elements) {
					var elementTexts = [];
					elements.value.forEach(function (el) {
						elementTexts.push(client.elementIdText(el.ELEMENT));
					});
					return this.unify(elementTexts)
					.then(function (elementTexts) {
						var elFound = false;
						var i;
						for (i=0; i<elementTexts.length; i++) {
							if (elementTexts[i].value.indexOf("Inventory of Personal Effects") != -1) {
								elFound = true;
								break;
							}
						}
						if (!elFound) {
							throw new Error('Element Inventory of Personal Effects not found');
						}
						return elements.value[i].ELEMENT;
//			  			return i;
					});
				})
				.then(function (el) {
					return this.elementIdText(el).then(function (elText) {
						console.log(elText.value);
						return el;
					});
				})
				.then(client.elementIdClick)
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[id$=currrentAssocDoc_Due_Date_edit]",defaultOperationTimeout)
				.setValue("input[id$=currrentAssocDoc_Due_Date_edit]", "04/30/2016")
				.selectByValue('select[id$=currrentAssocDoc_Status]', 'Received')
				.setValue("textarea[id$=currrentAssocDoc_Comments]", "Editing packet for regression")
				.setValue("input[id$=currrentAssocDoc_Status_Date]", "04/01/2016")
				.click("span[id$=addAdmissionDocumentModal] input[value='Save']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.pause(3000)
				//Asserting edited document
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
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.click("span[id$=addAdmissionDocumentModal] input[value='Cancel']")
				.waitForVisible("input[value='Add/Edit Documents']",defaultOperationTimeout)
				//Removing Documents
				.click("input[value='Add/Edit Documents']")
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[value='Save']",defaultOperationTimeout)
				.elements("table#pb_packetDoc span.fancytree-title")
				 .then(function (elements) {
					 var elementTexts = [];
					 elements.value.forEach(function (el) {
						 elementTexts.push(client.elementIdText(el.ELEMENT));
					 });
					 return this.unify(elementTexts)
					 .then(function (elementTexts) {
						 var elFound = false;
						 var i;
						 for (i=0; i<elementTexts.length; i++) {
							 if (elementTexts[i].value.indexOf("Inventory of Personal Effects") != -1) {
								 elFound = true;
								 break;
							 }
						 }
						 if (!elFound) {
							 throw new Error('Element Inventory of Personal Effects not found');
						 }
//			  			return elements.value[i].ELEMENT;
						 return i;
					 });
				 })
				 .then(function (index) {
					 return client.elements("table#pb_packetDoc span.fancytree-checkbox")
					 .then(function (els) {
						 return els.value[index].ELEMENT;
					 });
				 })
				 .then(client.elementIdClick)
				//.elements("span[class='fancytree-checkbox'])")
				//.then(function (elements) {
				//	return elements[1];
				//})
				//.then(client.click)
				.waitForVisible("span[id$=addAdmissionDocumentModal] input[id$=currrentAssocDoc_Due_Date_edit]",defaultOperationTimeout)
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
			}
		})