"use strict";

const chai = require('chai');
const assert = chai.assert;
const testSuite = require("../main.js").testSuite;
const users = require("../users.js").accounts;

const helper = require("../helpers/referral_conversion.js");

const suiteTimeout = 5 * 60 * 1000;
const defaultOperationTimeout = 30 * 1000;

testSuite("Referral Conversion for Care Meridian", suiteTimeout, {
  "should have correct Convert button visibility on different Referral statuses": function(client, done) {
    return helper.testConvertButtonVisibility(client, "Redwood", "AZ");
  },
});