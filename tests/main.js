var configs = require("./configs.json");
var webdriverio = require("webdriverio");
var path = require("path");
var options = {
    host: "127.0.0.1",
    desiredCapabilities: {
        browserName: "chrome"
    }
};
var defaultOperationTimeout = 30 * 1000;

module.exports = {
  testSuite: function (name, timeout, tests) {
    describe(name, function () {
      this.timeout(timeout);

      var client = webdriverio.remote(options);
      before(function (done) {
        client
          .init()
          .then(function () { done(); });
      });
      Object.keys(tests).forEach(function (testName) {
        it(testName, function (done) {
          var errorHandler = function (err) {
            var ssFileName = path.normalize("./screenshots/Error - " + testName + " - " + new Date().getTime() + ".png");
            client
              .saveScreenshot(ssFileName)
              .then(function () {
                if (err instanceof Error) {
                  if (err.message.substr(-1) === " " || err.message.substr(-1) === ".") {
                    err.message = err.message.slice(0, -1);
                  }
                  err.message += ". Screenshot saved to \"" + ssFileName + "\"";
                }
                done(err);
              });
          };
          require("./commands.js")(client, done);
          client
            .url("https://test.salesforce.com")
            .setValue("input#username", configs.username)
            .setValue("input#password", configs.password)
            .click("button#Login")
            .waitForVisible("a=ESD Home", defaultOperationTimeout)
            .then(function () {
              return tests[testName](client, done);
            })
            .then(function () {
              done();
            }, errorHandler);
          });
      });

      after(function (done) {
        client.end().then(function () { done(); });
      });
    });
  }
};
