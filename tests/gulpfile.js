var argv = require('yargs')
  .boolean('d')
  .boolean('sd')
  .boolean('users')
  .alias('s', 'suite')
  .alias('d', 'debug')
  .alias('e', 'selenium-debug')
  .alias('f', 'force')
  .alias('j', 'file')
  .alias('u', 'with-managed-users')
  .argv;

var findRemoveSync = require('find-remove');
var execSync = require('child_process').execSync;
var gulp = require('gulp');
var selenium = require('selenium-standalone');
var mocha = require('gulp-spawn-mocha');
var path = require('path');
var fs = require('fs');
var spawn = require('child_process').spawn;
var manageUsers = require('./users.js').manageUsers;

gulp.task('selenium', function (done) {
  var opts = {
    version: '2.48.2',
    baseURL: 'http://selenium-release.storage.googleapis.com',
    drivers: {
      chrome: {
        version: '2.20',
        arch: process.arch,
        baseURL: 'http://chromedriver.storage.googleapis.com'
      },
      ie: {
        version: '2.48.0',
        arch: process.arch,
        baseURL: 'http://selenium-release.storage.googleapis.com'
     }
    },
    logger: function (message) {
      if (argv["selenium-debug"]) {
        console.log(message);
      }
    }
  };
  selenium.install(opts, function (err) {
    if (err) return done(err);

    selenium.start(opts, function (err, child) {
      if (err) return done(err);
      selenium.child = child;
      done();
    });
  });
});

var inspector;
gulp.task("inspector", function (done) {
  inspector = spawn('node-inspector.cmd', [], {
    detached: true,
    stdio: [ 'ignore', 'ignore', 'ignore' ]
  });
  done();
});

gulp.task("manage-users", function (done) {
  manageUsers(done, argv.force);
});

gulp.task("clean-up", function () {
  findRemoveSync(path.resolve(__dirname, './screenshots'), { extensions: [ '.png' ] });
});

var cleanUpProcesses = function (err) {
  console.log("Cleaning up processes");
  var exitCode;
  if (err) {
    exitCode = 1;
  }
  selenium.child.kill();
  if (argv.debug) {
    var taskkill = spawn("taskkill", ["/pid", inspector.pid, '/f', '/t']);
    taskkill.on("exit", function () {
      process.exit(exitCode);
    });
  } else {
    process.exit(exitCode);
  }
}

var deps = ["clean-up", "manage-users", "selenium"];
if (argv.debug) {
  deps.push("inspector");
}
gulp.task("tests", deps, function () {
  return gulp
    .src(argv.suite ? argv.suite: 'suites/*.js', {read: false})
    .pipe(mocha({
      debugBrk: argv.debug
    }))
    .once('error', cleanUpProcesses)
    .once('end', cleanUpProcesses);
});

var jobDeps = ["clean-up", "selenium"];
if (argv.debug) {
  jobDeps.push("inspector");
}
if (argv["with-managed-users"]) {
  jobDeps.push("manage-users");
}
gulp.task("job", jobDeps, function () {
  const execFile = function (fileLoc) {
    const normalizedPath = path.normalize(fileLoc);
    const errorStr = fileLoc + " is not a valid file";
    if (!fs.existsSync(normalizedPath) || !fs.lstatSync(normalizedPath).isFile()) {
      console.error(errorStr);
      throw errorStr;
    }
    const nodeRuntime = argv.debug ? "node-debug" : "node";
    execSync(nodeRuntime + " " + normalizedPath, {
      stdio: [0, 1, 2]
    });
  };
  try {
    if (Array.isArray(argv.file)) {
      argv.file.forEach(execFile);
    } else if (!argv.file) {
      throw "You have to specify at least one job file";
    } else {
      execFile(argv.file);
    }
  } catch (e) {
    cleanUpProcesses(e);
  } finally {
    cleanUpProcesses();
  }
});
