var argv = require('yargs')
  .boolean('d')
  .boolean('sd')
  .alias('s', 'suite')
  .alias('d', 'debug')
  .alias('sd', 'seleniumdebug')
  .argv;

var gulp = require('gulp');
var selenium = require('selenium-standalone');
var mocha = require('gulp-spawn-mocha');
var spawn = require('child_process').spawn;

gulp.task('selenium', function (done) {
  selenium.install({
    // version: '2.45.0',
    // drivers: {
    //   version: '2.15'
    // },
    logger: function (message) {
      if (argv.seleniumdebug) {
        console.log(message);
      }
    }
  }, function (err) {
    if (err) return done(err);

    selenium.start(function (err, child) {
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

var deps = ["selenium"];
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
