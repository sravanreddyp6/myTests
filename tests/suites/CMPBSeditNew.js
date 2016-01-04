var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;
var jsforce = require('jsforce');

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("CMPBSeditNew", suiteTimeout, {
	  "should be able to update and Save the PBS and related lists successfully": function(client, done) {
	    return client
	      .logInAs(users["CM_DON"])
	      .url('https://c.cs20.visual.force.com/apex/PersonBeingServedEditNew?id=003m000000N61oWAAR&sfdc.override=1')
	      .waitForVisible("input[value='Edit Person Being Served']", defaultOperationTimeout)
	      .click("input[value='Edit Person Being Served']")
	      .waitForVisible("input[value='Save']", defaultOperationTimeout)
	      .getOutputTextFromInput("First Name")
	     // .getOutputText("First Name")
	       .then(function (firstName) {
		    assert.equal("Regression" , firstName, 'This is the actual value '+firstName);
		  })
	      
	  }
	});
