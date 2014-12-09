(function ($) {
    "use strict";

    window.scrollToTop = function () {
        window.scrollTo(0, 0);
    };
    String.prototype.endsWith = function (suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };
    $.fn.realVal = function () {
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
    window.applyRulesToField = function (element) {
        var $element = $(element);
        // For multi-picklist, apparently the data- passthrough also
        // exist in the selected and unselected checkboxes, which confuse
        // the script, so we check for their existence here.
        if ($element.attr('multiple') == 'multiple' && ($element.attr('id').endsWith('_selected') || $element.attr('id').endsWith('_unselected'))) {
            return;
        }
        var enabledFields = [];
        var rules = $element.data("rules");
        rules && $.each(rules, function (key, value) {
            var $targets = [];
            if (value instanceof Array) {
                $.each(value, function (_, selector) {
                    $targets.push($(document.getElementById(selector)));
                });
            } else {
                $targets.push($(document.getElementById(value)));
            }
            var val = $element.realVal();
            if (val == key || (val instanceof Array && $.inArray(key, val) != -1)) {
                // Enable fields
                $.each($targets, function (_, $target) {
                    if ($target.attr("multiple")) {
                        $target.parent().find("select").prop("disabled", false);
                    } else {
                        $target.prop("disabled", false);
                    }
                    enabledFields.push($target.get(0));
                });
            } else {
                // Disable fields
                $.each($targets, function (_, $target) {
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
    }
})(jQuery.noConflict());