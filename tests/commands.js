var fs = require("fs");
var url = require("url");
var _ = require("lodash");

// All the methods in here are injected into the browser context when the test suite is run.
// Don't include comments in here because apparently WebdriverIO do not like it.
var injectJS = function () {
  window.rtSetUp = function ($) {
    eval(window.rtScriptVendorMap["table-to-json"]);
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
    if (typeof jQuery == 'undefined') {
      eval(window.rtScriptVendorMap["jQuery"]);
      jQuery.noConflict();
    }
    rtSetUp(jQuery);
    callback(jQuery);
  };

  window.rtGetLabel = function (label, fromNodeSelector, cb) {
    rtInjectJQuery(function ($) {
      if ($.isFunction(fromNodeSelector)) {
        cb = fromNodeSelector;
        fromNodeSelector = "body";
      } else if (fromNodeSelector == null) {
        fromNodeSelector = "body";
      }
      var $el = $(fromNodeSelector).find("label:contains('" + label +"'):visible, th.labelCol:contains('" + label + "'):visible, th.labelCol span:contains('" + label + "'):visible")
        .filter(function () {
          return $(this).pureText().trim() === label;
        });
      if ($el.length === 0) {
        throw new Error("Label " + label + " not found. fromNodeSelector: " + fromNodeSelector);
      } else if ($el.length > 1) {
        throw new Error("More than 1 label " + label + "found. fromNodeSelector: " + fromNodeSelector);
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

  window.rtCleanText = function ($el) {
    return $el.clone().find("script, style").remove().end().text().trim();
  }
};

var defaultOperationTimeout = 30 * 1000;

module.exports = function (client, done) {
  client.addCommand("checkLogin", function (user) {
    var loginSuccessful = false;
    var loginError = false;
    var changePasswordNeeded = false;
    var scheduledMaintenance = false;

    return client
      .waitUntil(function () {
        return this.isExisting("a=iServe Home").then(function (loginSuccessResult) {
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
              if (title.indexOf("Change Password") !== -1 || title.indexOf("Change Your Password") !== -1) {
                changePasswordNeeded = true;
                return true;
              }
              if (title.indexOf("Scheduled") !== -1) {
                scheduledMaintenance = true;
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
            .url()
            .then(function (currentUrl) {
              return this.url(url.resolve(currentUrl.value, '/apex/Home'));
            })
            .waitForVisible("a=iServe Home", defaultOperationTimeout);
        } else if (scheduledMaintenance) {
          return this
            .click("a.continue")
            .checkLogin();
        }
      });
  });
  client.addCommand("logInAs", function (user) {
    return client
      .deleteCookie()
      .url("https://test.salesforce.com")
      .setValue("input#username", user.username)
      .setValue("input#password", user.password)
      .click("input#Login")
      .checkLogin(user)
      // for some reason sometimes SF confuses sessions (the page would say Invalid Session,
      // press Save again). It's quite hard to reproduce it, so this is my first attempt to resolve
      // it - simply by pausing for a bit and hope for the best...
      .pause(2000);
  });
  client.addCommand("fillInputText", function (label, value, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, value, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $inputEl = $el.find("input, textarea");
            if ($inputEl.length === 0) {
              throw new Error("No input field associated with label " + label + " can be found");
            }
            $inputEl.focus();
            $inputEl.val(value);
            $inputEl.trigger("blur");
            $inputEl.trigger("change");
            doneAsync();
          });
        });
      }, label, value, fromNodeSelector);
  });
  client.addCommand("getOutputText", function (label, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            $el.focus();
            doneAsync(rtCleanText($el));
          });
        });
      }, label, fromNodeSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getOutputTextFromInput", function (label, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
        	var $inputEl = $el.find("input, textarea");
        	if ($inputEl.length === 0) {
	            throw new Error("No input field associated with label " + label + " can be found");
	         }
            $inputEl.focus();
            doneAsync($inputEl.val());
          });
        });
      }, label, fromNodeSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getCheckboxInput", function (label, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $checkboxEl = $el.find("input[type=checkbox]");
            if ($checkboxEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find any checkbox associated with it.");
            }
            $checkboxEl.focus();
            doneAsync($checkboxEl.attr("checked") == "checked");
          });
        });
      }, label, fromNodeSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getCheckboxInputs", function () {
    return client.unify(_.map(arguments, function (label) { return client.getCheckboxInput(label); }))
  });
  client.addCommand("getCheckboxOutput", function (label, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $checkboxEl = $el.find("img.checkImg");
            if ($checkboxEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find any checkbox associated with it.");
            }
            $checkboxEl.focus();
            doneAsync($checkboxEl.attr("title") == "Checked" ? true : false);
          });
        });
      }, label, fromNodeSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getCheckboxOutputBySelector", function (selector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (selector, doneAsync) {
        rtInjectJQuery(function ($) {
          var $el = $(selector);
          if ($el.length === 0) {
            throw new Error("Cannot find checkbox with selector " + selector);
          } else if ($el.lenth > 1) {
            throw new Error("Found more than 1 checkboxes with selector " + selector);
          }
          var $checkboxEl = $el.find("img.checkImg");
          if ($checkboxEl.length === 0) {
            throw new Error("Found element with selector " + selector + " but cannot find any checkbox associated with it.");
          }
          $checkboxEl.focus();
          doneAsync($checkboxEl.attr("title") == "Checked" ? true : false);
        });
      }, selector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getCheckboxOutputs", function () {
    return client.unify(_.map(arguments, function (label) { return client.getCheckboxOutput(label); }))
  });
  client.addCommand("getSelectOptions", function (label, resultInLabel, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, resultInLabel, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var options = $el.find("select option");
            if (options.length === 0) {
              throw new Error("Found label " + label + " but cannot find any select options associated with it.");
            }
            options.focus();
            doneAsync(options.map(function (index, opt) { return resultInLabel ? opt.text : opt.value; }));
          });
        });
      }, label, resultInLabel, fromNodeSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getSelectOptionsBySelector", function (selector, resultInLabel) {
    return client
      .injectVendorScripts()
      .executeAsync(function (selector, resultInLabel, doneAsync) {
        rtInjectJQuery(function ($) {
          if ($(selector).length === 0) {
            throw new Error("Cannot find element with selector " + selector);
          }
          var options = $(selector).find("option");
          if (options.length === 0) {
            throw new Error("Found element with selector " + selector + " but cannot find any select options associated with it.");
          }
          options.focus();
          doneAsync(options.map(function (index, opt) { return resultInLabel ? opt.text : opt.value; }));
        });
      }, selector, resultInLabel)
      .then(function (result) { return result.value; });
  });
  client.addCommand("getMultiSelectOptions", function (label, resultInLabel, fromNodeSelector) {
      return client
        .injectVendorScripts()
        .executeAsync(function (label, resultInLabel, fromNodeSelector, doneAsync) {
          rtGetLabel(label, fromNodeSelector, function ($labelEl) {
            rtFollowLabel($labelEl, label, function ($el) {
              var options = $el.find("> select option");
              if (options.length === 0) {
                throw new Error("Found label " + label + " but cannot find any select options associated with it.");
              }
              options.focus();
              doneAsync(options.map(function (index, opt) { return resultInLabel ? opt.text : opt.value; }));
            });
          });
        }, label, resultInLabel, fromNodeSelector)
        .then(function (result) { return result.value; });
  });
  client.addCommand("getPageMessages", function (pageMessageId) {
    return client
      .injectVendorScripts()
      // pageMessage with single and multiple messages have different structure, so we'll build
      // them separately and push them together at the end
      .executeAsync(function (pageMessageId, doneAsync) {
        rtInjectJQuery(function ($) {
          var selector = "body"
          if (pageMessageId) {
            selector = "[id$=" + pageMessageId + "]";
          }
          var singleMessages = $(selector).find("table.messageTable:visible td.messageCell .messageText")
            .contents()
            .filter(function () { return this.nodeType === 3 })
            .map(function () { return this.textContent });
          singleMessages = $.makeArray(singleMessages);
          var multiMessages = $(selector).find("table.messageTable:visible li")
            .map(function () { return $(this).text() });
          multiMessages = $.makeArray(multiMessages);
          doneAsync($.merge(singleMessages, multiMessages));
        });
      }, pageMessageId)
      .then(function(result) { return result. value; })
  })
  client.addCommand("chooseSelectOption", function (label, text, selectByLabel, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, text, selectByLabel, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $selectEl = $el.find("select");
            if ($selectEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find any select element associated with it");
            }
            var $optionEl;
            if (selectByLabel) {
              $optionEl = $selectEl.find("option").filter(function (idx) {
                return jQuery(this).text() == text;
              }).eq(0);
              if ($optionEl.length === 0) {
                throw new Error("Found label " + label + " but cannot find a select option with label " + text);
              }

            } else {
              $optionEl = $selectEl.find("option[value='" + text + "']");
              if ($optionEl.length === 0) {
                throw new Error("Found label " + label + " but cannot find a select option with value " + text);
              }
            }
            $optionEl.focus();
            $optionEl.prop("selected", true);
            $selectEl.trigger('change');
            doneAsync();
          });
        });
      }, label, text, selectByLabel, fromNodeSelector);
  });
  client.addCommand("chooseMultiSelectOption", function (label, texts, selectByLabel, fromNodeSelector) {
    if (selectByLabel === undefined) {
      selectByLabel = true;  // most of the time it makes more sense to choose this by label, since the value is just a number
    }
    return client
      .injectVendorScripts()
      .executeAsync(function (label, texts, selectByLabel, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $selectEl = $el.find("select[id$='_unselected']");
            if ($selectEl.length === 0) {
              throw new Error("Found label " + label + " but cannot find any select element associated with it");
            }
            // We remove all the chosen ones first, to make sure only the passed in options are
            // chosen afterwards.
            $el.find("select[id$='_selected'] option").prop("selected", true);
            $el.find("a[title='Remove'] img").click();
            var $optionEls;
            if (selectByLabel) {
              var allOptionLabels = jQuery.makeArray($selectEl.find("option").map(function () {
                return jQuery(this).text();
              }));
              texts.forEach(function (text) {
                if (allOptionLabels.indexOf(text) == -1) {
                  throw new Error("Found label " + label + " but cannot find a select option with label " + text);
                }
              });
              $optionEls = $selectEl.find("option").filter(function () {
                return texts.indexOf(jQuery(this).text()) != -1;
              });
              if ($optionEls.length === 0) {
                throw new Error("Found label " + label + " but cannot find a select option with label " + text);
              }
            } else {
              var allOptionLabels = jQuery.makeArray($selectEl.find("option").map(function () {
                return jQuery(this).val();
              }));
              texts.forEach(function (text) {
                if (allOptionLabels.indexOf(text) == -1) {
                  throw new Error("Found label " + label + " but cannot find a select option with value " + text);
                }
              });
              $optionEls = $selectEl.find("option").filter(function () {
                return texts.indexOf(jQuery(this).val()) != -1;
              });
              if ($optionEls.length === 0) {
                throw new Error("Found label " + label + " but cannot find a select option with value " + text);
              }
            }
            $selectEl.focus();
            $optionEls.prop("selected", true);
            $selectEl.trigger('change');
            $el.find("a[title='Add'] img").click();
            doneAsync();
          });
        });
      }, label, texts, selectByLabel, fromNodeSelector);
  });
  client.addCommand("_selectCheckbox", function (label, selected, fromNodeSelector) {
    selected = selected !== false;
    return client
    .injectVendorScripts()
    .executeAsync(function (label, selected, fromNodeSelector, doneAsync) {
      rtGetLabel(label, fromNodeSelector, function ($labelEl) {
        rtFollowLabel($labelEl, label, function ($el) {
          var $checkboxEl = $el.find("input[type='checkbox']");
          if ($checkboxEl.length === 0) {
            throw new Error("Found label " + label + " but cannot find any checkbox associated with it");
          }
          $checkboxEl.focus();
          if ($checkboxEl.is(":checked") !== selected) {
            $checkboxEl.trigger("click");
            $checkboxEl.trigger("change");
            doneAsync();
          }
          doneAsync();
        });
      });
    }, label, selected, fromNodeSelector);
  });
  client.addCommand("_selectCheckboxBySelector", function (selector, selected) {
    selected = selected !== false;
    return client
      .isSelected(selector)
      .then(function (currentlySelected) {
        if (selected != currentlySelected) {
          return this.click(selector);
        }
      })
  });
  client.addCommand("selectCheckbox", function (label, fromNodeSelector) {
    return client._selectCheckbox(label, true, fromNodeSelector);
  });
  client.addCommand("selectCheckboxBySelector", function (selector) {
    return client._selectCheckboxBySelector(selector, true);
  });
  client.addCommand("unselectCheckbox", function (label, fromNodeSelector) {
    return client._selectCheckbox(label, false, fromNodeSelector);
  });
  client.addCommand("unselectCheckboxBySelector", function (selector) {
    return client._selectCheckboxBySelector(selector, false);
  });
  client.addCommand("selectCheckboxes", function () {
    return client.unify(_.map(arguments, function(label) { return client.selectCheckbox(label) }));
  });
  client.addCommand("unselectCheckboxes", function () {
    return client.unify(_.map(arguments, function(label) { return client.unselectCheckbox(label) }));
  });
  client.addCommand("selectLookup", function (label, fromNodeSelector) {
    return client
      .injectVendorScripts()
      .executeAsync(function (label, fromNodeSelector, doneAsync) {
        rtGetLabel(label, fromNodeSelector, function ($labelEl) {
          rtFollowLabel($labelEl, label, function ($el) {
            var $lookupImg = $el.find("img.lookupIcon");
            if ($lookupImg.length === 0) {
              throw new Error("Found label " + label + " but cannot find a lookup icon associated with it");
            }
            $lookupImg.click();
            doneAsync();
          });
        });
      }, label, fromNodeSelector);
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
        return originalHandle;
      })
      .then(client.window);
  });
  client.addCommand("waitForActionStatusDisappearance", function (actionStatusId, timeout) {
    return client.waitForVisible("span[id$=" + actionStatusId + "\\.start]", timeout, true);
  });
  client.addCommand("tableToJSON", function (tableSelector) {
    // By default, table-to-json extracts the text content of the cell, which may include <script>
    // tag. This leads to issues with the military date picker. Therefore we'll make sure to take
    // out the script and style tags
    return client
      .injectVendorScripts()
      .executeAsync(function (selector, doneAsync) {
        rtInjectJQuery(function ($) {
          if ($(selector).length === 0) {
            throw new Error("Cannot find table with selector " + selector);
          }
          doneAsync($(selector).tableToJSON({
            textExtractor: function (cellIndex, $cell) {
              return rtCleanText($cell);
            }
          }));
        });
      }, tableSelector)
      .then(function (result) { return result.value; });
  });
  client.addCommand("unstickPbsCard", function () {
    return client
      .isVisible("img.unstickPbs")
      .then(function (unstickNeeded) {
        if (unstickNeeded) {
          return this.click("img.unstickPbs");
        }
      });
  });
  client.addCommand("injectVendorScripts", function () {
    // This method injects a variable (named rtScriptVendorMap) into the browser context, which
    // maps the name of the script to *content* of the script. This is used to make it more
    // flexible for us to pick and choose which script to load in the browser context.
    var scriptMap = {
        "jQuery": "libs/jquery-1.7.2.js",
        "table-to-json": "node_modules/table-to-json/lib/jquery.tabletojson.js"
    };
    scriptMap = Object.keys(scriptMap).reduce(function (previous, current) {
      previous[current] = fs.readFileSync(scriptMap[current], "utf8");
      return previous;
    }, {});
    return client
      .execute(function (scriptMap) {
        window.rtScriptVendorMap = scriptMap;
      }, scriptMap)
      .execute(injectJS);
  });
  var hookRegistry = {};
  client.addCommand("execUtil", function (name, opts) {
    const util = require("./utils/" + name);
    if (opts.hooks) {
      for (hookName in opts.hooks) {
        hookRegistry[hookName] = opts.hooks[hookName];
      }
    }
    return util(client, opts);
  });
  client.addCommand("callHook", function (hookName) {
    if (hookName in hookRegistry) {
      var fn = hookRegistry[hookName];
      delete hookRegistry[hookName];  // so that the hook is only called once
      return fn(client);
    }
  });
  client.addCommand("fillInputsWithData", function (data) {
    var elementTypeMap = function (client, elementType, isSelector) {
      // If not isSelector, then it's by label
      var fnMap = {
        "text": isSelector ? client.setValue : client.fillInputText,
        "select_option": isSelector ? client.selectByValue : client.chooseSelectOption,
        "checkbox": isSelector ? client._selectCheckboxBySelector : client._selectCheckbox,
        "uncheckbox": isSelector ? client._unselectCheckboxBySelector : client._unselectCheckbox,
        "multi_select_option": client.chooseMultiSelectOption  // no option for isSelector yet
      }
      return fnMap[elementType];
    };
    var promise = this;
    data.forEach(function (action) {
      if (action["enabled"] === false) {
        return;
      }
      promise = elementTypeMap(promise, action["element_type"], action["selector_type"] == "selector").bind(promise)(action["selector"], action["value"]);
    });
    return promise;
  });
};
