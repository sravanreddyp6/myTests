var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 100 * 1000;

testSuite("Service Location Search", suiteTimeout, {
  "should create a new service location": function(client, done) {
  var user = users["RW_MN_L3"];
  var today = new Date().getMilliseconds() + new Date().getDate();
    return client
      .logInAs(users["RW_MN_L3"])
      .click("a=Create New Referral")
      .click("input[value='Create Person Being Referred']")      
      .waitForExist("#viewServiceLocation123", defaultOperationTimeout)  

  }
})
