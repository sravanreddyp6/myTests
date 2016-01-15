var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.Should();
chai.use(chaiAsPromised);

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
      chaiAsPromised.transferPromiseness = client.transferPromiseness;
      before(function (done) {
        client
          .init()
          .then(function () { done(); });
      });
      var testsRun = 0;
      Object.keys(tests).forEach(function (testName) {
        it(testName, function (done) {
          testsRun += 1;
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
          if (testsRun === 1) {
            // Otherwise WebDriverIO would complain that we define the same custom commands
            // multiple times
            require("./commands.js")(client, done);
          }
          tests[testName](client, done)
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
