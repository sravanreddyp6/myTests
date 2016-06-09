var execJobs = require("../main.js").execJobs;

// In this example, we use environment variables to customize the logging in process, since we
// want the same script to log in to different systems (sandbox/production).
// In Windows CMD, these variables can be set before each run of the script like so:
// set SF_USERNAME=username@thementornetwork.com.sandboxdm&&set SF_PASSWORD=password&&set SF_PROD=false&&npm run job -- --file .\jobs\sample_login.js
// or it can be set in the Windows environmental variable dialog
// In Bash, it'll be a bit easier:
// SF_USERNAME=username@thementornetwork.com.sandboxdm SF_PASSWORD=password SF_PROD=false npm run job -- --file .\jobs\sample_login.js

var username = process.env.SF_USERNAME;
var password = process.env.SF_PASSWORD;
var runInProduction = process.env.SF_PROD;

if (!username) {
  throw "Username environment variable is required";
}
if (!password) {
  throw "Password environment variable is required";
}
if (runInProduction == undefined) {
  throw "runInProduction environment variable is required";
} else if (runInProduction === "true") {
  runInProduction = true;
} else {
  runInProduction = false;
}

execJobs({
  "Log In": function (client) {
    return client
      .logInAs({ username: username, password: password }, runInProduction);
  },
});
