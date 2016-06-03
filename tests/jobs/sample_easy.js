var execJobs = require("../main.js").execJobs;

execJobs({
  "Simplest job possible": function (client) {
    return client
      .url("https://google.com")
      .pause(10000);
  }
});