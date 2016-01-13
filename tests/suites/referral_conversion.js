var chai = require('chai');
var assert = chai.assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("Referral Conversion", suiteTimeout, {
  "should convert a referral successfully for Redwood": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "Redwood", flavor: "AZ" })
  },
  "should convert a referral successfully for Care Meridian": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "Care Meridian", flavor: "GA" })
  },
  "should convert a referral successfully for NeuroRestorative": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "NeuroRestorative", flavor: "MA" })
  },
  "should convert a referral successfully for Hastings": function(client, done) {
    return client
      .execUtil("convert_referral", { operatingGroup: "Cambridge", flavor: "GA" })
  },
});
