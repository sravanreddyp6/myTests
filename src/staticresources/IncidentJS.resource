window.Incident = {};

(function($) {
	"use strict";

	$.extend({
		alert: function(message, title) {
			$("<div></div>").dialog({
				buttons: {
					"Ok": function() {
						$(this).dialog("close");
					}
				},
				close: function(event, ui) {
					$(this).remove();
				},
				resizable: false,
				title: title,
				modal: true
			}).text(message);
		}
	});

	Incident.formatStaff = function(staff) {
		if (staff.loading) {
			return staff.text;
		}
		var markup = "<div class='select2-result-item clearfix'>" +
			"<div class='select2-result-item__avatar'></div>" +
			"<div class='select2-result-item__title'>" + staff.text + "</div>";
		if (staff.jobTitle) {
			markup += "<div class='select2-result-item__description'>" + staff.jobTitle + "</div>";
		}
		if (staff.email) {
			markup += "<div class='select2-result-item__statistics'>" +
				"<div class='select2-result-item__forks'><i class='fa fa-flash'></i> " + staff.email + "</div>" +
				"</div>";
		}
		markup += "</div></div>";
		return markup;
	}

	Incident.formatStaffSelection = function(staff) {
		return staff.text;
	}

	Incident.formatPBS = function(pbs) {
		if (!pbs.obj) {
			return pbs.text;
		}
		var obj = pbs.obj;
		var markup = "<div class='select2-result-item clearfix'>";
		if (obj.Flavor__c) {
			markup += "<div class='select2-result-item__avatar'><img src='" + obj.Flavor__c + "'/></div>";
		}
		markup += "<div class='select2-result-item__meta'>" +
			"<div class='select2-result-item__title'>" + obj.pbsFirstName__c + ' ' + obj.pbsLastName__c + "</div>";
		if (obj.Person_Being_Served__r.Gender__c || obj.Person_Being_Served__r.Age_Text__c) {
			markup += "<div class='select2-result-item__statistics'>" +
				"<div class='select2-result-item__forks'><i class='fa fa-flash'></i> " + obj.Person_Being_Served__r.Gender__c + ', Age - ' + obj.Person_Being_Served__r.Age_Text__c + "</div>" +
				"</div>";
		}
		markup += "</div></div>";
		return markup;
	}

	Incident.formatPBSSelection = function(pbs) {
		return (pbs.obj ? pbs.obj.pbsFirstName__c + ' ' + pbs.obj.pbsLastName__c : pbs.text);
	}

	Incident.handleFormErrors = function(errorBlockSelector, whenHappenedSelector, whenNotifiedSelector, moment) {
		// This is used to handle error for the whole form (in ReportEvent), *not* the individual
		// involved party errors
		var eventErrors = [];
		var $errorBlock = $(errorBlockSelector);
		var $whenHappened = $(whenHappenedSelector);
		var $whenNotified = $(whenNotifiedSelector);
		var $requiredInput = $(".requiredInput");
		$errorBlock.html('');
		// select all the required input fields and set the hidden boolean and the error message fields.
		$requiredInput.find(":input:visible:enabled").each(function(_, target) {
			var $target = $(target);
			if ($target.val() == '') {
				eventErrors.push($('label[for="' + $target.attr('id').substring($target.attr('id').lastIndexOf(':') + 1) + '"]')[0].innerHTML + ' field is mandatory.');
			}
		});
		// This logic below looks for any multi checkboxes marked as required.
		$requiredInput.prev().filter(":visible").each(function(_, target) {
			var $target = $(target);
			var multiCheckValid = false;
			$('[id^=' + $target.prop("for") + '] :input').each(function(_, multiCheckBox) {
				if (multiCheckBox.checked) {
					multiCheckValid = true;
					return false;
				}
			});
			if (!multiCheckValid && $('[id^=' + $target.prop("for") + '] :input').length > 0) {
				eventErrors.push('At least one checkbox is required from the multiple checkboxes for - ' + $target.prop('innerHTML') + '.');
			}
		});
		if (moment($whenHappened.val()).isAfter()) {
			eventErrors.push('The value for "When did it happen?" cannot be in the future. Please adjust the "When did it happen?" for the event.');
		}
		if (!moment($whenNotified.val()).isAfter(moment($whenHappened.val()))) {
			eventErrors.push('The value "When was the Supervisor notified?" cannot occur prior to the date/time of "When did it happen?".');
		}
		if (eventErrors.length > 0) {
			$(window).scrollTop(0);
			$.each(eventErrors, function(index, error) {
				$errorBlock.append('<li class="error">' + error + '</li>');
			});
			return false;
		}
		return true;
	};

	Incident.buildInvolvedPartyEventErrors = function (involvedPartyId) {
		$(involvedPartyId).accordion().accordion("destroy");
		$(involvedPartyId + ' > table').each(function(_, $$target){
			var errorMsg = '';
			var $requiredInputs = $($$target).find(".requiredInput");
			$requiredInputs.find(":input:visible:enabled").each(function(_, target) {
				var $target = $(target);
				if ($target.val() == '') {
					errorMsg += '<li class="ui-state-error-text">' + $('label[for="' + $target.attr('id') + '"]')[0].innerHTML + ' field is mandatory.</li>';
				}
			});
			// This logic below looks for any multi checkboxes marked as required.
			$requiredInputs.prev().filter(":visible:enabled").each(function(_, target) {
				var $target = $(target);
				var multiCheckValid = false;
				$('[id^=' + $target.prop("for") + '] :input').each(function(_, multiCheckBox) {
					if (multiCheckBox.checked) {
						multiCheckValid = true;
						return false;
					}
				});
				if (!multiCheckValid && $('[id^=' + $target.prop("for") + '] :input').length > 0) {
					errorMsg += '<li class="ui-state-error-text">At least one checkbox is required from the multiple checkboxes for - ' + $target.prop('innerHTML') + '.</li>';
				}
			});
			if (errorMsg.length > 0) {
				$($$target).find('[id$=IsValid]').val("false").trigger('change');
				$($$target).find('[id$=ErrorMsg]').val(errorMsg).trigger('change');
			} else {
				$($$target).find('[id$=IsValid]').val("true").trigger('change');
				$($$target).find('[id$=ErrorMsg]').val("").trigger('change');
			}
		});
	};
})(jQuery.noConflict());