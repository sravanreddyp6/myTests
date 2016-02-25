var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 2 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("Home Page", suiteTimeout, {
  "should go to the correct page": function(client, done) {
    return client
      .logInAs(users["CM_CNA"])
      .url()
      .then(function (url) {
        assert.include(url.value, 'Home');
      });
  }
});
