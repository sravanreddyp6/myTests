var argv = require('yargs')
  .boolean('d')
  .boolean('sd')
  .alias('s', 'suite')
  .alias('d', 'debug')
  .alias('sd', 'seleniumdebug')
  .alias('f', 'force')
  .argv;

var exec = require('child_process').exec;
var gulp = require('gulp');
var selenium = require('selenium-standalone');
var mocha = require('gulp-spawn-mocha');
var spawn = require('child_process').spawn;
var manageUsers = require('./users.js').manageUsers;

gulp.task('selenium', ["install-dependencies"], function (done) {
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
      if (argv.seleniumdebug) {
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

gulp.task("manage-user", ["install-dependencies"], function (done) {
  manageUsers(done, argv.force);
});

gulp.task("install-dependencies", function (done) {
  exec("npm install", function (err, stdout, stderr) {
    if (stderr) {
      throw new Error(stderr);
    }
    done();
  })
});

var deps = ["install-dependencies", "manage-user", "selenium"];
if (argv.debug) {
  deps.push("inspector");
}
gulp.task("tests", deps, function () {
  return gulp
    .src(argv.suite ? argv.suite: 'suites/*.js', {read: false})
    .pipe(mocha({
      debugBrk: argv.debug
    }))
    .once('error', function () {
      selenium.child.kill();
      if (argv.debug) {
        var taskkill = spawn("taskkill", ["/pid", inspector.pid, '/f', '/t']);
        taskkill.on("exit", function () {
          process.exit(1);
        });
      } else {
        process.exit(1);
      }
    })
    .once('end', function () {
      selenium.child.kill();
      if (argv.debug) {
        var taskkill = spawn("taskkill", ["/pid", inspector.pid, '/f', '/t']);
        taskkill.on("exit", function () {
          process.exit();
        });
      } else {
        process.exit();
      }
    });
});
