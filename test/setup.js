// Deps
global.chai = require('chai');
chai.should();

var coffee = require('coffee-script');
var fs = require('fs');
var multisuite = require('./support/multisuite');

var scripts = {
  'jq-1.9':  fs.readFileSync('vendor/jquery-1.9.js'),
  'jq-2.0':  fs.readFileSync('vendor/jquery-2.0.js'),
  'ndialog': coffee.compile(fs.readFileSync('ndialog.coffee', 'utf-8'))
};

function myEnv(jq) {
  var jsdom = require('jsdom');
  return function(done) {
    jsdom.env({
      html: '<!doctype html><html><head></head><body></body></html>',
      src: [ scripts[jq], scripts.ndialog ],
      done: function(errors, window) {
        window.console  = console;
        global.document = window.document;
        global.NDialog  = window.NDialog;
        global.window   = window;
        global.$        = window.$;
        done(errors);
      }
    });
  };
}

if (process.env.fast) {
  before(myEnv('jq-1.9'));
  global.testSuite = describe;
} else {
  global.testSuite = multisuite(['jq-1.9', 'jq-2.0'], myEnv);
}
