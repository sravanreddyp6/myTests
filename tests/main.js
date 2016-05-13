const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');

chai.Should();
chai.use(chaiAsPromised);

const webdriverio = require("webdriverio");
const path = require("path");
const options = {
    host: "127.0.0.1",
    desiredCapabilities: {
        browserName: "chrome"
    }
};

const errorHandler = function (name, client, done) {
  return function (err) {
    var ssFileName = path.normalize("./screenshots/Error - " + name + " - " + new Date().getTime() + ".png");
    client
      .saveScreenshot(ssFileName)
      .then(function () {
        if (err instanceof Error) {
          if (err.message.substr(-1) === " " || err.message.substr(-1) === ".") {
            err.message = err.message.slice(0, -1);
          }
          err.message += ". Screenshot saved to \"" + ssFileName + "\"";
        }
        if (done) {
          done(err);
        }
      });
  };
}
module.exports = {
  execJobs: function (jobs) {
    var client = webdriverio.remote(options).init();
    var errorFound = false;

    chaiAsPromised.transferPromiseness = client.transferPromiseness;
    require("./commands.js")(client);

    Object.keys(jobs).forEach(function (jobName) {
      client = client
        .then(function () { console.log("Running job: " + jobName); });
      client = jobs[jobName](client)
        .deleteCookie()
        .then(undefined, errorHandler(jobName, client, function () {
          errorFound = true;
        }));
    });
    client
      .end()
      .then(function () {
        if (errorFound) {
          process.exit(2);
        }
      });
  },
  testSuite: function (name, timeout, tests) {
    describe(name, function () {
      this.timeout(timeout);

      var client = webdriverio.remote(options);
      before(function (done) {
        chaiAsPromised.transferPromiseness = client.transferPromiseness;
        client
          .init()
          .then(function () { done(); });
      });
      var testsRun = 0;
      Object.keys(tests).forEach(function (testName) {
        it(testName, function (done) {
          testsRun += 1;
          if (testsRun === 1) {
            // Otherwise WebDriverIO would complain that we define the same custom commands
            // multiple times
            require("./commands.js")(client, done);
          }
          tests[testName](client, done)
            .deleteCookie()
            .then(function () {
              done();
            }, errorHandler(testName, client, done));
          });
      });

      after(function (done) {
        client.end().then(function () { done(); });
      });
    });
  }
};
