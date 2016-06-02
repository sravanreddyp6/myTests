var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 5 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

var today = new Date().getTime();
var packetName = 'Regression Packet'+today;
var documentName = 'Regression Document'+today;
var editedDoc = 'Edited Document'+today;
var editedPack = 'Edited Packet'+today;
var addedDoc = [{"":documentName,"Due Days":"","Recurring":"As Needed","Expiration":"","Effective":"2016-04-06"},
                {"":editedDoc,"Due Days":"","Recurring":"As Needed","Expiration":"","Effective":"2016-04-06"}];
var addedPack = [{"":packetName,"Due Days":"","Recurring":"","Expiration":"","Effective":""},
                 {"":editedPack,"Due Days":"","Recurring":"","Expiration":"","Effective":""}];

testSuite("CMDocCompliance", suiteTimeout, {
	  "Test to add packets, documents and Inactivate them": function(client, done) {
		  return client
		  .logInAs(users["CM_DON"])
		  .click("a=Manage Admission Packet Content")
		  //.waitForVisible("input[value='Create Person Being Referred']", defaultOperationTimeout)
		  .pause(3000)
		  .selectByValue("select[id$=nwOffering]", "IDD")
		  .click("input[id$='cont']")
		  .waitForVisible("input[value='Add New Document']", defaultOperationTimeout)
		  
		  //Adding Packet
		  .click("input[value='Add New Packet']")
		  .waitForVisible("input[id$=pName]", defaultOperationTimeout)
		  .setValue("input[id$=pName]",packetName)
		  .selectByValue('select[id$=pStatus]', 'Active')
		  .click("input[value='Save Packet']")
		  .waitForVisible("input[value='Add New Document']", defaultOperationTimeout)
		  .pause(3000)
		  //Asserting Packet
		  .tableToJSON("[id$=allPackets]")
		  .then(function (admPack) {
			  admPack = admPack.map(function (admPacktable) {
				  return admPacktable;
			  })
			  var adpack = false;
			  console.log('Asserting packet');
			  for(i=0; i<admPack.length; i++){
				  if(JSON.stringify(admPack[i])==JSON.stringify(addedPack[0])){
					  adpack = true;
				  }
			  }
			  assert.equal(adpack, true)
		  })
		  
		  //Adding Document
		  .click("input[value='Add New Document']")
		  .windowHandleMaximize()
		  .waitForVisible("select[id$=recurring-freq]", defaultOperationTimeout)
		  .getSelectOptions("Due")
		  .then(function(due) {
			//Donot delete the below
			  /*var split = function (strArray) {
				  return strArray.map(function (str) {
					  if (str == '') {
						  return '';
					  }
					  return str.split('').map(function (char) { return char.charCodeAt(0); })
						  .reduce(function (current, previous) {
						    return previous + current;
						  });
				  });
			  };*/
			  var ellipsis = String.fromCharCode("8230");
			  //console.log(split(due));
			  var a = [
			                    "", "72 Hours after Treatment Start","30 days from Treatment Start Date","N/A","Other","Treatment Start Date","2 days from Treatment Start Date",
			                    "5 days from Treatment Start Date","7 days from Treatment Start Date","30 days from last completed (recurring" + ellipsis + ")","90 days from Treatment Start Date",
			                    "7 days PRIOR to Projected End Date","3 days AFTER Service End Date"
			                    ];
			  //console.log(split(a));
			  assert.deepEqual(a, due);
			  
		  })
		  .setValue("input[id$=dName]",documentName)
		  .setValue("input[id$=dVersion]","1")
		  .selectByValue('select[id$=dStatus]', 'Active')
		  .selectByValue('select[id$=dType]', 'Standard')
		  .selectByValue('select[id$=recurring-freq]', 'As Needed')
		  .selectByValue('select[id$=due-picklist]', 'Other')
		  .setValue("input[id$=dEffDate]", "04/06/2016")
		  //Never delete this code
		  //Starts
		  .elements("div#miniFormTree span.fancytree-title")
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
			  			if (elementTexts[i].value.indexOf(packetName) != -1) {
			  				elFound = true;
			  				break;
			  			}
			  		}
			  		if (!elFound) {
			  			throw new Error('Element ' + packetName + ' not found');
			  		}
//			  		return elements.value[i].ELEMENT;
			  		return i;
			  	});
		  })
		  .then(function (index) {
			  return client.elements("div#miniFormTree span.fancytree-checkbox")
			  	.then(function (els) {
			  		return els.value[index].ELEMENT;
			  	});
		  })
//		  .then(function (el) {
//			  return this.elementIdText(el).then(function (elText) {
//				  console.log(elText.value);
//				  return el;
//			  });
//		  })
		  .then(client.elementIdClick)
		  //ends
		  .click("input[value='Save Document']")
		  .waitForVisible("input[value='Add New Document']", defaultOperationTimeout)
		  .pause(3000)
		  //Asserting Document
		  .tableToJSON("[id$=allPackets]")
		  .then(function (admDoc) {
			  admDoc = admDoc.map(function (admDoctable) {
				  return admDoctable;
			  })
			  var addoc = false;
			  console.log('Asserting document');
			  for(i=0; i<admDoc.length; i++){
				  if(JSON.stringify(admDoc[i])==JSON.stringify(addedDoc[0])){
					  addoc = true;
				  }
			  }
			  assert.equal(addoc, true)
		  })
		//Editing Existing Packet and making it Inactive
		  .elements("table#allPackets span.fancytree-title")
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
			  			if (elementTexts[i].value.indexOf(packetName) != -1) {
			  				elFound = true;
			  				break;
			  			}
			  		}
			  		if (!elFound) {
			  			throw new Error('Element ' + packetName + ' not found');
			  		}
			  		return elements.value[i].ELEMENT;
//			  		return i;
			  	});
		  })
//		  .then(function (index) {
//			  return client.elements("div#miniFormTree span.fancytree-checkbox")
//			  	.then(function (els) {
//			  		return els.value[index].ELEMENT;
//			  	});
//		  })
		  .then(function (el) {
			  return this.elementIdText(el).then(function (elText) {
				  console.log(elText.value);
				  return el;
			  });
		  })
		  .then(client.elementIdClick)
		  .waitForVisible("input[id$=pName]", defaultOperationTimeout)
		  .setValue("input[id$=pName]",editedPack)
		  .selectByValue('select[id$=pStatus]', 'Inactive')
		  .click("input[value='Save Packet']")
		  .waitForVisible("input[value='Add New Document']", defaultOperationTimeout)
		  //Asserting Edited Packet
		  .tableToJSON("[id$=allPackets]")
		  .then(function (ePack) {
			  ePack = ePack.map(function (ePacktable) {
				  return ePacktable;
			  })
			  var epac = false;
			  console.log('Asserting edited Packet');
			  for(i=0; i<ePack.length; i++){
				  if(JSON.stringify(ePack[i])==JSON.stringify(addedPack[1])){
					  epac = true;
				  }
			  }
			  assert.equal(epac, true)
		  })
		  //Editing Existing Document and making it Inactive
		  .elements("table#allPackets span.fancytree-title")
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
			  			if (elementTexts[i].value.indexOf(documentName) != -1) {
			  				elFound = true;
			  				break;
			  			}
			  		}
			  		if (!elFound) {
			  			throw new Error('Element ' + documentName + ' not found');
			  		}
			  		return elements.value[i].ELEMENT;
//			  		return i;
			  	});
		  })
//		  .then(function (index) {
//			  return client.elements("div#miniFormTree span.fancytree-checkbox")
//			  	.then(function (els) {
//			  		return els.value[index].ELEMENT;
//			  	});
//		  })
		  .then(function (el) {
			  return this.elementIdText(el).then(function (elText) {
				  console.log(elText.value);
				  return el;
			  });
		  })
		  .then(client.elementIdClick)
		  .waitForVisible("input[id$=dName]", defaultOperationTimeout)
		  .setValue("input[id$=dName]",editedDoc)
		  .selectByValue('select[id$=dStatus]', 'Inactive')
		  .click("input[value='Save Document']")
		  .waitForVisible("input[value='Add New Document']", defaultOperationTimeout)
		  //Asserting Edited Document
		  .tableToJSON("[id$=allPackets]")
		  .then(function (eDocu) {
			  eDocu = eDocu.map(function (eDoctable) {
				  return eDoctable;
			  })
			  var edoc = false;
			  console.log('Asserting edited Document');
			  for(i=0; i<eDocu.length; i++){
				  if(JSON.stringify(eDocu[i])==JSON.stringify(addedDoc[1])){
					  edoc = true;
				  }
			  }
			  assert.equal(edoc, true)
		  })
	  }
})