var execJobs = require("../main.js").execJobs;
var url = require("url");

const defaultOperationTimeout = 3 * 60 * 1000;

execJobs({
  "Loop doing same actions on different pages": function (client) {
    var pagesToVisit = [
      "https://google.com",
      "https://salesforce.com",
      "https://apple.com"
    ];
    pagesToVisit = [];
    pagesToVisit.forEach(function (page) {
      client = client
        .url(page)
        .pause(5000);  // You can extend this by doing actions, e.g. clicking buttons, fill forms, etc.
    });
    // The above loop works because any call on the variable `client` returns a Promise,
    // and promises can be chained together. We just happen to assign that Promise to a variable
    // called `client`. The above code is equivalent to:
    //
    // client = client
    //   .url("https://google.com")
    //   .pause(5000);
    // client = client
    //   .url("https://salesforce.com")
    //   .pause(5000);
    // client = client
    //   .url("https://apple.com")
    //   .pause(5000);
    //
    // which is equivalent to:
    //
    // client = client
    //   .url("https://google.com")
    //   .pause(5000)
    //   .url("https://salesforce.com")
    //   .pause(5000)
    //   .url("https://apple.com")
    //   .pause(5000)
    //
    // In order to understand the final equivalence, think of the following synchronous code:
    // a = 0;
    // a = a + 1 + 2;
    // a = a + 1 + 2;
    //
    // It is equivalent to:
    //
    // a = a
    //   + 1
    //   + 2
    //   + 1
    //   + 2
    //
    // The exact same thing applies to the async code above.

    // Here we need to return a Promise, otherwise the outer script will not wait for the actions
    // to complete.
    return client
      .then(function () {
        console.log("Done visiting all the pages");
      });
  },
  "Login as multiple people on Salesforce and do same action": function (client) {
    var username = process.env.SF_USERNAME;
    var password = process.env.SF_PASSWORD;
    if (!username) {
      throw "Username environment variable is required";
    }
    if (!password) {
      throw "Password environment variable is required";
    }

    var userIds = [
      "005U0000001BxuG",
      "005U00000029d8C"
    ];
    return client
      .logInAs({
        username: username,
        password: password
      })
      .url()
      .then(function (currentUrl) {
        // Basically here we append the user Id to the instance URL to get a list of urls that
        // point to the user profiles (the one with the login button)
        return userIds.map(function (userId) {
          return url.resolve(currentUrl.value, '/' + userId + '?noredirect=1');
        });
      })
      .then(function (urls) {
        // This just turns into the previous examples, in which have multiple pages that we need
        // to visit, and apply some actions on.
        urls.forEach(function (pageToVisit) {
          client = client
            .url(pageToVisit)
            .waitForVisible("input[title=Login]", defaultOperationTimeout)
            .click("input[title=Login]")
            .waitForVisible("a=Home", defaultOperationTimeout)
            .click("#userNavLabel")
            .click("a=Logout")
            .waitForVisible("input[title=Login]", defaultOperationTimeout);
        });
        // Since we need to wait for all the actions to looping actions to complete, we'll return
        // the Promise here, so that the outer script knows it has to hang around and wait.
        // Otherwise it'll just move on and lead to unexpected behavior.
        return client;
      });
  }
});