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
})(jQuery.noConflict());