// All the methods in here are injected into the browser context when the test suite is run.
// Don't include comments in here because apparently WebdriverIO do not like it.
var injectJS = function () {
  window.rtSetUp = function ($) {
    $.fn.pureText = function () {
      var str = '';
      this.contents().each(function() {
          if (this.nodeType == 3) {
              str += this.textContent || this.innerText || '';
          }
      });
      return str;
    };
  };
  window.rtInjectJQuery = function(callback) {
    var jqueryUrl = 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js';
    if (typeof jQuery == 'undefined') {
      var script = document.createElement('script');
      var head = document.getElementsByTagName('head')[0];
      var done = false;
      script.onload = script.onreadystatechange = (function() {
        if (!done && (!this.readyState || this.readyState == 'loaded' || this.readyState == 'complete')) {
          done = true;
          script.onload = script.onreadystatechange = null;
          head.removeChild(script);
          jQuery.noConflict();
          rtSetUp(jQuery);
          callback(jQuery);
        }
      });
      script.src = jqueryUrl;
      head.appendChild(script);
    } else {
        rtSetUp(jQuery);
        callback(jQuery);
    }
  };

  window.rtGetLabel = function (label, cb) {
    rtInjectJQuery(function ($) {
      var $el = $("label:contains('" + label +"'), th.labelCol:contains('" + label + "'), th.labelCol span:contains('" + label + "')")
        .filter(function () {
          return $(this).pureText().trim() === label;
        });
      if ($el.length === 0) {
        throw new Error("Label " + label + " not found.");
      } else if ($el.length > 1) {
        throw new Error("More than 1 label " + label + "found.");
      } else {
        cb($el);
      }
    });
  };

  window.rtFollowLabel = function ($labelEl, label, cb) {
    rtInjectJQuery(function ($) {
      if ($labelEl.is("label")) {
        if ($labelEl.attr("for")) {
          $el = $(document.getElementsByName($labelEl.attr("for")));
          if ($el.length === 0) {
            cb($labelEl.closest("th").next());
            return;
          } else if ($el.length > 1) {
            throw new Error("Found more than 1 element associated with " + label);
          }
          cb($el.parent());
          return;
        } else {
          cb($labelEl.closest("th").next());
          return;
        }
      } else if ($labelEl.is("th")) {
        cb($labelEl.next());
        return;
      } else if ($labelEl.is("span")) {
        cb($labelEl.closest("th").next());
        return;
      }
      throw new Error("Tag not supported");
    });
  };
};

var defaultOperationTimeout = 30 * 1000;

module.exports = function (client, done) {
  client.addCommand("logInAs", function(user) {
    var loginSuccessful = false;
    var loginError = false;
    var changePasswordNeeded = false;
    return client
      .url("https://test.salesforce.com")
      .setValue("input#username", user.username)
      .setValue("input#password", user.password)
      .click("button#Login")
      .waitUntil(function () {
        return this.isExisting("a=ESD Home").then(function (loginSuccessResult) {
          if (loginSuccessResult) {
            loginSuccessful = true;
            return true;
          }
          return this.isExisting(".loginError").then(function (loginErrorResult) {
            if (loginErrorResult) {
              loginError = true;
              return true;
            }
            return this.getTitle().then(function (title) {
              if (title.indexOf("Change Password") !== -1) {
                changePasswordNeeded = true;
                return true;
              }
              return false;
            });
          });
        });
      }, defaultOperationTimeout)
      .then(function () {
        if (loginSuccessful) {
          return;
        } else if (loginError) {
          throw new Error("Log in failure with user " + user.name);
        } else if (changePasswordNeeded) {
          return this
            .click("input[value='Cancel']")
            .waitForVisible("a=ESD Home", defaultOperationTimeout);
        }
      });
  });
  client.addCommand("fillInputText", function (label, value) {
    return client
      .execute(injectJS)
      .executeAsync(function (label, value, doneAsync) {
        rtGetLabel(label, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $inputEl = $el.find("input, textarea");
            if ($inputEl.length === 0) {
              throw new Error("No input field associated with label " + label + " can be found");
            }
            $inputEl.val(value);
            $inputEl.trigger('blur');
            doneAsync();
          });
        });
      }, label, value);
  });
  client.addCommand("getOutputText", function (label) {
    return client
      .execute(injectJS)
      .executeAsync(function (label, doneAsync) {
        rtGetLabel(label, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            doneAsync($el.text());
          });
        });
      }, label)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getSelectOptions", function (label) {
    return client
      .execute(injectJS)
      .executeAsync(function (label, doneAsync) {
        rtGetLabel(label, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var options = $el.find("select option");
            if (options.length === 0) {
              throw new Error("Found label " + label + " but cannot find any select options associated with it.");
            }
            doneAsync(options.map(function (index, opt) { return opt.value; }));
          });
        });
      }, label)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getMultiSelectOptions", function (label) {
	    return client
	      .execute(injectJS)
	      .executeAsync(function (label, doneAsync) {
	        rtGetLabel(label, function ($labelEl) {
	          rtFollowLabel($labelEl, label, function ($el) {
	            var options = $el.find("> select option");
	            if (options.length === 0) {
	              throw new Error("Found label " + label + " but cannot find any select options associated with it.");
	            }
	            doneAsync(options.map(function (index, opt) { return opt.value; }));
	          });
	        });
	      }, label)
	      .then(function (result) { return result.value; });
  });
  client.addCommand("chooseSelectOption", function (label, optionValue) {
    return client
      .execute(injectJS)
      .executeAsync(function (label, optionValue, doneAsync) {
        rtGetLabel(label, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $selectEl = $el.find("select");
            if ($selectEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find any select element associated with it");
            }
            var $optionEl = $selectEl.find("option[value='" + optionValue + "']");
            if ($optionEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find a select option with value " + optionValue);
            }
            $optionEl.prop("selected", true);
            $selectEl.trigger('change');
            doneAsync();
          });
        });
      }, label, optionValue);
  });
  client.addCommand("selectLookup", function (label, optionValue) {
    return client
      .execute(injectJS)
      .executeAsync(function (label, optionValue, doneAsync) {
        rtGetLabel(label, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $lookupImg = $el.find("img.lookupIcon");
            if ($lookupImg.length === 0) {
              throw new Error("Found label " + label + " but cannot find a lookup icon associated with it");
            }
            $lookupImg.click();
            doneAsync();
          });
        });
      }, label, optionValue);
  });
  client.addCommand("switchToNextWindow", function () {
    var originalHandle;
    return client
      .windowHandle()
      .then(function (handle) {
        originalHandle = handle.value;
      })
      .windowHandles()
      .then(function (handles) {
        for (var index in handles.value) {
          if (handles.value[index] === originalHandle) {
            continue;
          }
          return handles.value[index];
        }
        throw new Error("There is only one open window!");
      })
      .then(client.window);
  });
};
