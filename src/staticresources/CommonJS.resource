(function($) {
	"use strict";

	window.scrollToTop = function() {
		window.scrollTo(0, 0);
	};
	String.prototype.endsWith = function(suffix) {
		return this.indexOf(suffix, this.length - suffix.length) !== -1;
	};
	$.fn.realVal = function() {
		// This function is here to put all the value-getting functionalities
		// in one place. This is because calling val() on a checkbox input
		// will only return the default value.
		var $obj = $(this);
		var val = $obj.val();
		var type = $obj.attr('type');
		if (type && type === 'checkbox') {
			return $obj.prop('checked') ? '1' : '0';
		} else {
			return val;
		}
	};
	// Do the field disabling/enabling functionality here
	// When values are in map -> will be enabled when key is changed
	// This doesn't support the use case when 2 fields try to control 1 field.
	window.applyRulesToField = function(element) {
		var $element = $(element);
		if ($element.attr('multiple') == 'multiple' && !$element.attr('id').endsWith('_selected') & !$element.attr('id').endsWith('_unselected')) {
			// This is the hidden select field for multi-picklist that gets
			// populated automagically by Salesforce when items are moved from
			// the selected and unselected lists. By default, this never gets
			// the change event when its value changed, because their values
			// are changed programmatically by SF (and those don't trigger change
			// event. Therefore, we have to monitor these values.
			// However, this method is called both when the page is initialized
			// and when a value is changed, so we need to make sure to not use
			// more timeout handler than necessary (i.e. in the latter case)
			if (!$element.hasClass("rules-timer-attached")) {
				var originalValue = $element.realVal();
				setInterval(function() {
					var currentValue = $element.realVal();
					if (JSON.stringify(currentValue) != JSON.stringify(originalValue)) { // Normal comparison do NOT work with list, so we use this workaround
						originalValue = currentValue;
						$element.addClass("rules-timer-attached");
						$element.trigger("change");
					}
				}, 100)
			}
		}
		// For multi-picklist, apparently the data- passthrough also
		// exist in the selected and unselected checkboxes, which confuse
		// the script, so we check for their existence here.
		if ($element.attr('multiple') == 'multiple' && ($element.attr('id').endsWith('_selected') || $element.attr('id').endsWith('_unselected'))) {
			return;
		}
		var enabledFields = [];
		var rules = $element.data("rules");
		if (rules && typeof a === 'string') {
			// If we attach a data- attribute to a selectList, VF automatically escapes it, and
			// there's no way to change that behavior, so here we attempt to convert that escaped
			// string back to a JS object
			try {
				rules = JSON.parse($('<div/>').html(rules).text());
			} catch (e) {
				console.error(e);
			}
		}
		rules && $.each(rules, function(key, value) {
			var $targets = [];
			if (value instanceof Array) {
				$.each(value, function(_, selector) {
					$targets.push($(document.getElementById(selector)));
				});
			} else {
				$targets.push($(document.getElementById(value)));
			}
			var val = $element.realVal();
			if (val == key || (val instanceof Array && $.inArray(key, val) != -1)) {
				// Enable fields
				$.each($targets, function(_, $target) {
					if ($target.attr("multiple")) {
						$target.parent().find("select").prop("disabled", false);
					} else {
						$target.prop("disabled", false);
					}
					enabledFields.push($target.get(0));
				});
			} else {
				// Disable fields
				$.each($targets, function(_, $target) {
					// We also need to revert the field(s) to their original state
					// One exception: if the field has been enabled by one of the
					// earlier rules, then don't disable it!
					if ($.inArray($target.get(0), enabledFields) != -1) {
						return;
					}
					if ($target.attr("multiple")) {
						// Simulate removing all the selected options
						$(document.getElementById($target.attr('id') + '_selected')).find('option').attr('selected', 'selected');
						// Fake clicking the Remove button here
						location.href = $target.parent().find("a[title=Remove]").attr("href");
						$target.parent().find("select").prop("disabled", true);
					} else {
						$target.prop("disabled", true);
						var type = $target.attr('type');
						if (type && type === 'checkbox') {
							$target.prop('checked', false);
						} else {
							$target.val('');
						}
					}
					$target.trigger('change');
				});
			}
		});
	};
	// Do the field show/hide functionality here
	// When values are in map -> will be shown when key is changed
	// If the element has a visibility-row-rules and it is true, the whole row
	// containing the target will be shown/hidden, otherwise only the target
	// will be shown/hidden.
	window.applyShowHideRulesToField = function(element) {
		var $element = $(element);
        if ($element.prop('disabled')) {
            return;
        }
		if ($element.attr('multiple') == 'multiple' && !$element.attr('id').endsWith('_selected') & !$element.attr('id').endsWith('_unselected')) {
			// This is the hidden select field for multi-picklist that gets
			// populated automagically by Salesforce when items are moved from
			// the selected and unselected lists. By default, this never gets
			// the change event when its value changed, because their values
			// are changed programmatically by SF (and those don't trigger change
			// event. Therefore, we have to monitor these values.
			// However, this method is called both when the page is initialized
			// and when a value is changed, so we need to make sure to not use
			// more timeout handler than necessary (i.e. in the latter case)
			if (!$element.hasClass("show-hide-rules-timer-attached")) {
				var originalValue = $element.realVal();
				setInterval(function() {
					var currentValue = $element.realVal();
					if (JSON.stringify(currentValue) != JSON.stringify(originalValue)) { // Normal comparison do NOT work with list, so we use this workaround
						originalValue = currentValue;
						$element.addClass("show-hide-rules-timer-attached");
						$element.trigger("change");
					}
				}, 100)
			}
		}
		// For multi-picklist, apparently the data- passthrough also
		// exist in the selected and unselected checkboxes, which confuse
		// the script, so we check for their existence here.
		if ($element.attr('multiple') == 'multiple' && ($element.attr('id').endsWith('_selected') || $element.attr('id').endsWith('_unselected'))) {
			return;
		}

		var shownTargets = [];
		var rules = $element.data("visibility-rules");

		var $allTargets = [];

		if (rules && typeof a === 'string') {
			// If we attach a data- attribute to a selectList, VF automatically escapes it, and
			// there's no way to change that behavior, so here we attempt to convert that escaped
			// string back to a JS object
			try {
				rules = JSON.parse($('<div/>').html(rules).text());
			} catch (e) {
				console.error(e);
			}
		}
		rules && $.each(rules, function(key, value) {
			if (value instanceof Array) {
				$.each(value, function(_, selector) {
					$allTargets.push($(document.getElementById(selector)));
				});
			} else {
				$allTargets.push($(document.getElementById(value)));
			}
		});

		rules && $.each(rules, function(key, value) {
			var $targets = [];
			if (value instanceof Array) {
				$.each(value, function(_, selector) {
					$targets.push($(document.getElementById(selector)));
				});
			} else {
				$targets.push(document.getElementById(value));
			}
			var val = $element.realVal();
			if (val == key || (val instanceof Array && $.inArray(key, val) != -1)) {
				// Show fields
				$.each($targets, function(_, $target) {
					// If the target has a rule about show/hiding the whole row,
					// we have to traverse up its ancestor to show/hide the whole row
					if ($element.data("visibility-row-rules")) {
						$target.parents("tr").eq(0).show();
					} else if ($target.attr('multiple') == 'multiple') {
						$target.parent().find("table.multiSelectPicklistTable").show();
					} else {
						$target.show();
					}
					shownTargets.push($target.get(0));
				});
			}
		});

		// Hide fields
		$.each($allTargets, function(_, $target) {
			// We also need to revert the field(s) to their original state
			// One exception: if the field has been enabled by one of the
			// earlier rules, then don't disable it!
			if ($.inArray($target.get(0), shownTargets) != -1) {
				return;
			}
			// If the target has a rule about show/hiding the whole row,
			// we have to traverse up its ancestor to show/hide the whole row
			if ($element.data("visibility-row-rules")) {
				$target.parents("tr").eq(0).hide();
			} else if ($target.attr('multiple') == 'multiple') {
				$target.parent().find("table.multiSelectPicklistTable").hide();
			} else {
				$target.hide();
			}
			// We also need to make sure the fields are blanked out, so
			// that they could be updated on the backend
			if ($target.attr('multiple') == 'multiple') {
				// Simulate removing all the selected options
				$(document.getElementById($target.attr('id') + '_selected')).find('option').attr('selected', 'selected');
				// Fake clicking the Remove button here
				location.href = $target.parent().find("a[title=Remove]").attr("href");
			} else if ($target.is("input")) {
				if ($target.attr("type") == "checkbox") {
					$target.prop("checked", false).trigger("change");
				} else if ($target.attr("type") != "submit"){
					$target.val("").trigger("change");
				}
			} else if ($target.is("select, textarea")) {
				$target.val("").trigger("change");
			}
			$target.find("input[type!=checkbox], select, textarea").val("").trigger("change");
			$target.find("input[type=checkbox]").prop("checked", false).trigger("change");
			$target.trigger("change");
		});

	}
})(jQuery.noConflict());