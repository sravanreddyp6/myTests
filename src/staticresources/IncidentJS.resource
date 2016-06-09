window.Incident = {};

(function($) {
	"use strict";

	$.extend({
		alert: function(message, title, fn) {
			$("<div></div>").dialog({
				buttons: {
					"Ok": function() {
						$(this).dialog("close");
					}
				},
				close: function(event, ui) {
					$(this).remove();
					if (fn) {
						fn();
					}
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
			$requiredInputs.prev().filter(":visible").each(function(_, target) {
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

	// Take in a list of selectors, then clear all the inputs associated with those selectors
	Incident.clearFields = function (selectors) {
		selectors.forEach(function (selector) {
			$(selector).val("").trigger("change");
		});
	};

	// Polyfill for Object.assign
	if (typeof Object.assign != 'function') {
		Object.assign = function(target) {
			'use strict';
			if (target == null) {
				throw new TypeError('Cannot convert undefined or null to object');
			}

			target = Object(target);
			for (var index = 1; index < arguments.length; index++) {
				var source = arguments[index];
				if (source != null) {
					for (var key in source) {
						if (Object.prototype.hasOwnProperty.call(source, key)) {
							target[key] = source[key];
						}
					}
				}
			}
			return target;
		};
	}

	Incident.setUpSelect2Fields = function (selector, hiddenFieldSelector, templateResult, templateSelection, transportFn, opts) {
		// Merge the default opts with the user provided ones
		var opts = Object.assign({
			allowClear: true,
			placeholder: "",
			minimumInputLength: 3,
		}, opts);
		var $select = $(selector).select2({
			minimumInputLength: opts.minimumInputLength,
			escapeMarkup: function(markup) {
				return markup;
			},
			allowClear: opts.allowClear,
			placeholder: opts.placeholder,
			templateResult: templateResult,
			templateSelection: templateSelection,
			ajax: {
				processResults: function(data) {
					return { results: data };
				},
				cache: true,
				delay: 1000,
				data: function(params) {
					return {
						q: params.term, // search term
						page: params.page,
					};
				},
				transport: function(params, success, failure) {
					transportFn(JSON.stringify(params.data), function(result, event) {
						if (!event.status) {
							$('.select2-results__options').empty().append('<li class="error">' + event.message + '</li>');
							console.error(event.message);
							return false;
						} else {
							success(result);
						}
					});
				}
			}
		});
		$select.on("change", function (e) {
			var value = $(e.target).find('option:selected').map(function () { return $(this).val(); }).get().join(",");
			$(hiddenFieldSelector).val(value);
		});
	};

	// The following 2 methods open and close modal dialogs in conjunction with jQuery and jQuery UI 2
	Incident.openModalDialogById = function (dialogId, formId, opts) {
		opts = Object.assign({
			dClass: "fixed-dialog",
			width: 800,
			hideCloseButton: true,
			titleString: "",
		}, opts);
		var $element = $(document.getElementById(dialogId));
		$element.dialog({
			dialogClass: opts.dClass,
			title: opts.titleString,
			modal: true,
			width: opts.width,
			resizable: false,
			minHeight: 0,
			dialogClass: 'modalDialog',
			closeOnEscape: false,
			zIndex: 9, // so that datepickers appear on top of the dialogs
			position: {
				my: "center top",
				at: "center top"
			},
			open: function () {
				// Don't allow "background" to be scrollable when dialogs
				// are open.
				$("body").css("overflow", "hidden");
			},
		}).parent().appendTo($(document.getElementById(formId)));
		if (opts.hideCloseButton) {
			$element.parent().find('button.ui-dialog-titlebar-close').remove();
		}
		return $element;
	};

	Incident.closeModalDialogById = function (dialogId) {
		var $element = $(document.getElementById(dialogId));
		$element.dialog('destroy');
		// Allow "background" to be scrollable when dialogs are closed.
		$("body").css("overflow", "auto");
	};

	// This function takes in an DOM element Id and a function. If there's no error in that element,
	// aka no "message" class, the function will be executed.
	Incident.onNoError = function (elId, fn) {
		var $el = $(document.getElementById(elId));
		if ($el.find('.message').length == 0) {
			fn();
		}
	};

	Incident.setUpConfirmDialog = function ($confirmDialog) {
		$confirmDialog.dialog({
			resizable: false,
			draggable: false,
			width: 500,
			modal: true,
			autoOpen: false,
			buttons: {
				Close: function() {
					$(this).dialog("close");
				}
			}
		});
	};

	Incident.alertPendingChanges = function ($involvedPartiesTable, $confirmDialog, $changeList) {
		return function(rowId) {
			$changeList.empty();
			var api = $involvedPartiesTable.dataTable().api();

			if (!rowId){
				api.rows().every(function(rowIdx, tableLoop, rowLoop) {
					var data = this.data();
					if (data.isModified) {
						$changeList.append('<li>' + data.type + ' - ' + data.name + '</li>');
						$confirmDialog.dialog("open");
					}
				});
			} else {
				var data = api.row('#' + rowId).data();
				if (data.isModified) {
					$changeList.append('<li>' + data.type + ' - ' + data.name + '</li>');
					$confirmDialog.dialog("open");
				}
			}
			return $changeList.children().length > 0 ;
		};
	};

	Incident.setUpAddInvolvedPartyDialog = function (
			$addInvolvedParty,
			$addInvolvedPartyError,
			$involvedPartyType,
			$involvedPartiesTable,
			actionStatusId
	) {
		return $addInvolvedParty.dialog({
			width: 500,
			autoOpen: false,
			modal: true,
			resizable: false,
			open: function() {
				// var ui_dialog_interaction;
				if ($.ui && $.ui.dialog && !$.ui.dialog.prototype._allowInteractionRemapped && $(this).closest(".ui-dialog").length) {
					var ui_dialog_interaction = $.ui.dialog.prototype._allowInteraction;
					$.ui.dialog.prototype._allowInteraction = function(e) {
						return true;
						if ($(e.target).closest('.select2-drop').length) {
							return true;
						}
						return ui_dialog_interaction.apply(this, arguments);
					};
				}
			},
			_allowInteraction: function(event) {
				return !!$(event.target).is(".select2-input") || this._super(event);
			},
			create: function() {
				$(this).closest(".ui-dialog")
						.find(".ui-button")
						.addClass("");
			},
			close: function(event, ui) {
				$addInvolvedPartyError.html('');
				$involvedPartyType.val('').trigger('change');
			},
			buttons: {
				"Save": function() {
					var dataObj = $.grep($addInvolvedParty.find(':input').serializeArray(), function(k, i) {
						return k.value ? true : false;
					});
					if ($involvedPartyType.val() == '') {
						$addInvolvedPartyError.html('You must select "Who was involved?" to proceed.');
						return false;
					} else if (dataObj.length < 3) {
						$addInvolvedPartyError.html('Missing required input.');
						return false;
					}
					var formdata = {};
					$(dataObj).each(function(index, obj) {
						formdata[obj.name] = obj.value;
					});
					window.ImInvolvedParty = new SObjectModel.txnQ({
						Request_Type__c: 'Insert-Im_InvolvedParty',
						Input_Params__c: JSON.stringify(formdata),
						Requested_Date_Time__c: new Date(new Date().valueOf() + new Date().getTimezoneOffset() * 60000)
					});
					$('[Id="' + actionStatusId + '.start"]').toggle();
					ImInvolvedParty.upsert(function(err, ids) {
						if (err) {
							console.log(err);
							$addInvolvedPartyError.html(err.message.slice(err.message.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + ('FIELD_CUSTOM_VALIDATION_EXCEPTION,').length, err.message.lastIndexOf(': []')));
							$('[Id="' + actionStatusId + '.start"]').toggle();
						} else {
							$addInvolvedPartyError.html('');
							var ImInvolvedParty = new SObjectModel.txnQ();
							ImInvolvedParty.retrieve({
								where: {
									Id: {
										eq: ids[0]
									}
								}
							}, function(err, records) {
								if (err) {
									console.log(err);
									$addInvolvedPartyError.html(err.message);
									$('[Id="' + actionStatusId + '.start"]').toggle();
								} else {
									var mytreeData = JSON.parse($('<div/>').html(records[0].get("Return_Value__c")).text());
									var myTableApi = $involvedPartiesTable.dataTable().api();
									var rowNode = myTableApi.row.add(mytreeData).draw(false);
									myTableApi.row(rowNode).select();
									$involvedPartyType.val('').trigger('change');
									$addInvolvedPartyError.html('');
									$addInvolvedParty.dialog("close");
									$('[Id="' + actionStatusId + '.start"]').toggle();
								}
							});
						}
					});
				},
				Cancel: function() {
					$addInvolvedPartyError.html('');
					$involvedPartyType.val('').trigger('change');
					$(this).dialog("close");
				},
			},
		});
	};

	Incident.setUpDeleteInvolvedPartyDialog = function (
			$deleteInvolvedPartyDialog,
			$deleteInvolvedPartyError,
			$involvedPartiesTable,
			actionStatusId,
			onSuccess
	) {
		return $deleteInvolvedPartyDialog.dialog({
			customOption: {},
			width: 500,
			autoOpen: false,
			modal: true,
			resizable: false,
			open: function(event, ui) {
				var data = $deleteInvolvedPartyDialog.dialog('option', 'customOption.rowData');
				var msg = 'You are removing the ' + data.type + ' - ' + data.name + ' from this event. This will delete all the information for this party associated to the event. Please confirm.';
				$(event.target).find('center').html(msg);
			},
			buttons: {
				"Confirm Delete": function() {
					var ImInvolvedParty = new SObjectModel.txnQ({
						Request_Type__c: 'Delete-Im_InvolvedParty',
						Input_Params__c: $deleteInvolvedPartyDialog.dialog('option', 'customOption.rowData').id,
						Requested_Date_Time__c: new Date(new Date().valueOf() + new Date().getTimezoneOffset() * 60000)
					});
					$('[Id="' + actionStatusId + '.start"]').toggle();
					ImInvolvedParty.upsert(function(err, ids) {
						if (err) {
							console.log(err);
							$deleteInvolvedPartyError.html(err.message);
							$('[Id="' + actionStatusId + '.start"]').toggle();
						} else {
							$involvedPartiesTable.dataTable().api().row('#' + $deleteInvolvedPartyDialog.dialog('option', 'customOption.rowData').id).remove().draw(false);
							$deleteInvolvedPartyError.html('');
							$deleteInvolvedPartyDialog.dialog("close");
							$('[Id="' + actionStatusId + '.start"]').toggle();
							if (onSuccess) {
								onSuccess();
							}
						}
					});
				},
				Cancel: function() {
					$deleteInvolvedPartyError.html('');
					$(this).dialog("close");
				},
			},
		});
	};

	Incident.reloadEventsForIP = function (
		$reportEventErrors,
		$involvedPartiesTable,
		actionStatusId,
		isIncidentLocked,
		remoteFn
	) {
		return function(involvedParty) {
			$('[Id="' + actionStatusId + '.start"]').toggle();
			remoteFn(involvedParty, isIncidentLocked, function(result, event) {
				if (!event.status) {
					$reportEventErrors.append('<li class="error">' + event.message + '</li>');
					$('[Id="' + actionStatusId + '.start"]').toggle();
				} else {
					$('#' + involvedParty + 'placeHolderDiv').empty().append(result).accordion({
						collapsible: true,
						heightStyle: "content",
						header: "h3",
						active: false,
						animate: false
					});
					$('#' + involvedParty + 'placeHolderDiv').accordion("refresh");
					var api = $involvedPartiesTable.dataTable().api();
					var row = api.row('#' + involvedParty);
					row.data().eventsTypesLoaded = true;
					row.select();
					$(row.node()).find("a.saveInvprty").show()
					$('[Id="' + actionStatusId + '.start"]').toggle();
				}
			}, {
				escape: false
			});
		};
	};

	Incident.setUpDialogForEventsTree = function (
		$eventsTreeDialog,
		$eventsTreeDialogError,
		$eventsTypeFancyTree,
		actionStatusId,
		remoteFn
	) {
		return $eventsTreeDialog.dialog({
			customOption: {},
			width: 500,
			autoOpen: false,
			modal: true,
			title: "",
			resizable: false,
			position: {
				my: "center",
				at: "center",
				of: window
			},
			height: 600,
			open: function(event, ui) {
				$('[Id="' + actionStatusId + '.start"]').toggle();
				var data = $eventsTreeDialog.dialog('option', 'customOption.rowData');
				$eventsTreeDialog.dialog("option", "title", "Add event types for " + data.type + " - " + data.name);
				remoteFn(JSON.stringify({
						involvedParty: data.id,
						involvedPartyType: data.type
				}), function(result, event) {
					if (!event.status) {
						$eventsTreeDialogError.html(event.message);
						$eventsTreeDialog.scrollTop("0");
						$eventsTypeFancyTree.fancytree("getTree").reload('');
						$('[Id="' + actionStatusId + '.start"]').toggle();
					} else {
						$eventsTreeDialogError.html('');
						var mytreeData = JSON.parse($('<div/>').html(result).text());
						$("button#btnResetSearch").trigger('click');
						$eventsTypeFancyTree.fancytree("getTree").reload(mytreeData);
						$('[Id="' + actionStatusId + '.start"]').toggle();
					}
				});
			},
			buttons: {
				"Add Events": function() {
					var selCategories = $.map($eventsTypeFancyTree.fancytree("getTree").getSelectedNodes(), function(node) {
						return node.key;
					});
					if (selCategories.length < 1) {
						$eventsTreeDialogError.html('No event types selected.');
						$eventsTreeDialog.scrollTop("0");
						return false;
					}
					var data = $eventsTreeDialog.dialog('option', 'customOption.rowData');
					var txn = new SObjectModel.txnQ({
						Request_Type__c: 'Insert-InvolvedPartyEvtTyps',
						Input_Params__c: JSON.stringify({
							involvedParty: data.id,
							eventsAdded: selCategories
						}),
						Requested_Date_Time__c: new Date(new Date().valueOf() + new Date().getTimezoneOffset() * 60000)
					});
					$('[Id="' + actionStatusId + '.start"]').toggle();
					txn.upsert(function(err, ids) {
						if (err) {
							console.log(err);
							$eventsTreeDialogError.html(err.message.slice(err.message.lastIndexOf('CustomException:') + ('CustomException:').length, err.message.lastIndexOf('Class.')));
							$eventsTreeDialog.scrollTop("0");
							$('[Id="' + actionStatusId + '.start"]').toggle();
						} else {
							$eventsTreeDialogError.html('');
							$('[Id="' + actionStatusId + '.start"]').toggle();
							$('#' + data.id + 'eventLoader').trigger('change'); // tell the data table to reload the events.
							$eventsTreeDialog.dialog("close");
						}
					});
				},
				Cancel: function() {
					$eventsTreeDialogError.html('');
					$(this).dialog("close");
				}
			}
		});
	};

	Incident.saveInvolvedParty = function (
			$changeList,
			$reportEventErrors,
			$involvedPartiesTable,
			actionStatusId,
			remoteFn,
			onSuccess
	) {
		return function(involvedParty) {
			$changeList.empty();
			Incident.buildInvolvedPartyEventErrors('#' + involvedParty.id + 'placeHolderDiv');
			var myData = JSON.stringify($involvedPartiesTable.dataTable().api().row('#' + involvedParty.id).child().find(":input").serializeArray());
			$('[Id="' + actionStatusId + '.start"]').toggle();
			remoteFn(involvedParty.id, myData, function(result, event) {
				if (!event.status) {
					$reportEventErrors.append('<li class="error">' + event.message + '</li>');
					$('[Id="' + actionStatusId + '.start"]').toggle();
				} else {
					$('#' + involvedParty.id + 'placeHolderDiv').empty().append(result).accordion({
						collapsible: true,
						heightStyle: "content",
						header: "h3",
						active: false,
						animate: false
					});
					$('#' + involvedParty.id + 'placeHolderDiv').accordion("refresh");
					var api = $involvedPartiesTable.dataTable().api();
					api.row('#' + involvedParty.id).data().eventsTypesLoaded = true;
					api.row('#' + involvedParty.id).data().isModified = false;
					api.row('#' + involvedParty.id).select();
					$('[Id="' + actionStatusId + '.start"]').toggle();
					$.alert('Your data for ' + involvedParty.type + ' - ' + involvedParty.name + ' has been saved successfully.', 'Successfully Saved!!!', function () {
						if (onSuccess) {
							onSuccess();
						}
					});
				}
			}, {
				escape: false
			});
		};
	};

	Incident.initializeEventTypesTree = function (
			$eventsTypeFancyTree
	) {
		return function() {
			$eventsTypeFancyTree.fancytree({
				extensions: ["filter"],
				filter: {
					fuzzy: false,
					autoApply: false,
					counter: true,
					hideExpandedCounter: true,
					mode: "hide"
				},
				checkbox: true,
				selectMode: 3,
				source: function() {
					return [];
				},
				icons: false
			});
			var tree = $eventsTypeFancyTree.fancytree("getTree");
			$("input[name=search]").keyup(function(e) {
				var n;
				var opts = {
					autoExpand: true,
					leavesOnly: true
				},
				match = $(this).val();
				if (e && e.which === $.ui.keyCode.ESCAPE || $.trim(match) === "") {
					$("button#btnResetSearch").click();
					return;
				}
				n = tree.applyFilter(match, opts);
				$("button#btnResetSearch").attr("disabled", false);
				$("span#matches").text("(" + n + " matches)");
			}).focus();

			$("button#btnResetSearch").click(function(e) {
				$("input[name=search]").val("");
				$("span#matches").text("");
				tree.clearFilter();
			}).attr("disabled", true);
		};
	};

	Incident.initializeInvolvedParties = function (
			$involvedPartiesTable,
			$reportEventErrors,
			$deleteInvolvedPartyDialog,
			$eventsTreeDialog,
			isReadOnlyMode,
			incidentId,
			reloadEventsForIP,
			alertPendingChanges,
			saveInvolvedParty,
			remoteFn
	) {
		return function () {
			var table = $involvedPartiesTable.DataTable({
				select: {
					style: 'api'
				},
				"paging": false,
				"ordering": false,
				"info": false,
				"searching": false,
				"orderFixed": [2, 'desc'],
				"processing": true,
				"ajax": function(data, callback, settings) {
					// vf remote to retrieve table data
					remoteFn(incidentId, function(result, event) {
						if (!event.status) {
							$reportEventErrors.append('<li class="error">' + event.message + '</li>');
							$reportEventErrors.show();
						} else {
							callback({ data: result });
						}
					}, {
						escape: false
					});
				},
				"columns": [{
					"class": "details-control",
					"orderable": false,
					"data": null,
					"defaultContent": ""
				}, {
					"data": "id"
				}, {
					"data": "type"
				}, {
					"data": "name"
				}, {
					"orderable": false,
					"data": null
				}],
				"columnDefs": [{
					"visible": false,
					"targets": 1
				}, {
					"targets": 4,
					"render": function(data, type, full, meta) {
						var actionStr = '<span style="float: right;"><a class="btn tableActionBtn pdfSummary" href="javascript:void(0);">PDF</a>&nbsp;&nbsp;';
						if (!isReadOnlyMode) {
							actionStr += '<a class="btn tableActionBtn deleteRow" href="javascript:void(0);">Remove</a>&nbsp;&nbsp;<a class="btn tableActionBtn addEvent" href="javascript:void(0);">Add Events</a>&nbsp;&nbsp;<a class="btn tableActionBtn saveInvprty" href="javascript:void(0);" style="display:none;">Save</a>';
						}
						actionStr += '</span>';
						return actionStr;
					}
				}],
				"drawCallback": function(settings) {
					var api = this.api();
					api.rows().every(function(rowIdx, tableLoop, rowLoop) {
						var data = this.data();
						data.eventsTypesLoaded = false;
						data.elementsModified = [];
						if (this.child.isShown()) {
							this.child.hide();
							$(this.node()).removeClass('shown');
							$involvedPartiesTable.dataTable().api().row(this).deselect();
						}
					});
				},
				"rowCallback": function(row, data, index) {
					var rowAPI = $involvedPartiesTable.dataTable().api().row(index);
					var detailData = '<tr>';
					if (data.type == "Person Being Served") {
						detailData += '<td class="involvedPartyInfo"><table>' +
							'<tr><td class="text_right" style="font-weight: bold;">Person Number' + '</td><td> #' + data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_Being_Served__r.PBS_Identifier__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Gender</td><td>' + data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_Being_Served__r.Gender__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Date of Birth</td><td>' + (new Date(data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_Being_Served__r.Birthdate)).toLocaleDateString() + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Age</td><td>' + data.involvedParty.PBS_Age__c + ' yr  </td></tr>';
						if (data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_being_served__r && data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Guardian1_Name__c) {
							detailData += '<tr><td class="text_right" style="font-weight: bold;">Guardian Name</td><td>' + data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Guardian1_Name__c + '</td></tr>';
						} else {
							detailData += '<tr><td class="text_right" style="font-weight: bold;">Guardian Name</td><td> Not Available </td></tr>';
						}
						detailData += '<tr><td class="text_right" style="font-weight: bold;">Population</td><td>' + data.involvedParty.PBS_Population_Type__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Admission Date</td><td>' + (new Date(data.involvedParty.Person_Being_Served_Involved__r.Admission__r.Effective_Date__c)).toLocaleDateString() + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Service Assignment Start Date</td><td>' + (new Date(data.involvedParty.Person_Being_Served_Involved__r.Start_Date__c)).toLocaleDateString() + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Length of Service</td><td>' + data.involvedParty.Length_Of_Service__c + '</td></tr></table>' +
							'</td>';
					} else if (data.type == "Staff") {
						detailData += '<td class="involvedPartyInfo"><table>' +
							'<tr><td class="text_right" style="font-weight: bold;">Employee' + '</td><td> #' + data.involvedParty.Staff_Involved__r.Employee_Number__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Job Title</td><td>' + data.involvedParty.Staff_Involved__r.Job_Title__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Job Status</td><td>' + data.involvedParty.Staff_Involved__r.Job_Status__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Type</td><td>' + data.involvedParty.Staff_Involved__r.Current_Person_Type__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Manager Name</td><td>' + data.involvedParty.Staff_Involved__r.Manager_Name__c + '</td></tr>' +
							'<tr><td class="text_right" style="font-weight: bold;">Primary Work Location </td><td>' + data.involvedParty.Staff_Involved__r.Location_Name__c + '</td></tr></table>' +
							'</td>';
					} else if (data.type == "Host Home Parent") {
						detailData += '<td class="involvedPartyInfo"></td>';
					} else if (data.type == "Other Family Member") {
						detailData += '<td class="involvedPartyInfo"></td>';
					} else if (data.type == "Other") {
						detailData += '<td class="involvedPartyInfo"></td>';
					}
					detailData += '<td><input type="hidden" id="' + data.id + 'eventLoader" value="0" onchange="reloadEventsForIP(\'' + data.id + '\');return false;"/><div id="' + data.id + 'placeHolderDiv" class="placeHolderDiv"/></td>';
					detailData += '</tr>';
					rowAPI.child($('<table style="width: 100%;"/>').append(detailData));
				}
			});
			$involvedPartiesTable.find('tbody').on('click', 'td.details-control', function() {
				var tr = $(this).closest('tr');
				var row = table.row(tr);
				var rowData = row.data();

				if (row.child.isShown()) {
					row.child.hide();
					tr.removeClass('shown');
					table.row(tr).deselect();
				} else {
					row.child.show();
					tr.addClass('shown');
					table.row(tr).select();
					if (!rowData.eventsTypesLoaded) {
						reloadEventsForIP(rowData.id);
					}
				}
			});
			$involvedPartiesTable.find('tbody').on('click', 'a.tableActionBtn', function() {
				var tr = $(this).closest('tr');
				var row = table.row(tr);
				var rowData = row.data();
				switch ($(this).prop('class').split(' ').slice(-1)[0]) {
					case 'deleteRow':
						if (alertPendingChanges()) {
							break;
						}
						$deleteInvolvedPartyDialog.dialog('option', 'customOption.rowData', rowData);
						$deleteInvolvedPartyDialog.dialog('open');
						break;
					case 'addEvent':
						if (!row.child.isShown()) {
							row.child.show();
							tr.addClass('shown');
							table.row(tr).select();
							if (!rowData.eventsTypesLoaded) reloadEventsForIP(rowData.id);
						}
						if (alertPendingChanges(rowData.id)) {
							break;
						}
						$eventsTreeDialog.dialog('option', 'customOption.rowData', rowData);
						$eventsTreeDialog.dialog('open');
						break;
					case 'saveInvprty':
						if (!row.child.isShown()) {
							$(row.node()).css('color', 'black').animate({
								color: 'red'
							}, 'slow');
							$.alert('You must expand the details before save.', '*** Cannot Save ***');
							break;
						}
						saveInvolvedParty(rowData);
						break;
					case 'pdfSummary':
						window.open('/apex/Im_EventSummary?Id=' + incidentId + '&invParty=' + rowData.id, 'EventSummary');
						break;
					default:
						alert('Not implemented yet!!');
				}
			});
		};
	};

	Incident.removeInvolvedPartyEventType = function (
			$reportEventErrors,
			onSuccess
	) {
		return function($target) {
			if (!$target) {
				return false;
			}
			var sectionIdentifier = $target.closest('.subCatTable').prop('class').split(' ').slice(1)[0];
			var invParty =  $target.closest('.placeHolderDiv').prop('id').split('placeHolderDiv')[0];
			var ImInvolvedParty = new SObjectModel.txnQ({
				Request_Type__c: 'Delete-InvPrtyEvntTyp',
				Input_Params__c: JSON.stringify({
					'sectionIdentifier' : sectionIdentifier.substring(8),
					'invParty' : invParty
				}),
				Requested_Date_Time__c: new Date(new Date().valueOf() + new Date().getTimezoneOffset() * 60000)
			});
			ImInvolvedParty.upsert(function(err, ids) {
				if (err) {
					console.log(err);
					$reportEventErrors.html(err.message);
					$(window).scrollTop(0);
				}
				if (onSuccess) {
					onSuccess();
				}
			});
			$('#' + sectionIdentifier + ', .' + sectionIdentifier).fadeOut('slow', function() { $(this).remove(); });
		};
	};

	Incident.initializeSelect2 = function (
			$tmnAccessEnhancedSelect,
			$programAssociatedToEvent,
			$reviewerEnhancedSelect,
			$pbsEnhancedSelect,
			$agenciesEnhancedSelect,
			$simpleSelect2,
			$hiddenFields,
			getStaffForProgram,
			getReviewers,
			getPBSForProgram
	) {
		return function () {
			$tmnAccessEnhancedSelect.select2({
				minimumInputLength: 3,
				escapeMarkup: function(markup) {
					return markup;
				},
				templateResult: Incident.formatStaff,
				templateSelection: Incident.formatStaffSelection,
				ajax: {
					processResults: function(data) {
						return { results: data };
					},
					minimumInputLength: 3,
					cache: true,
					delay: 100,
					data: function(params) {
						return {
							q: params.term, // search term
							page: params.page,
							programLocation: $programAssociatedToEvent.val()
						};
					},
					transport: function(params, success, failure) {
						getStaffForProgram(JSON.stringify(params.data), function(result, event) {
							if (!event.status) {
								$('.select2-results__options').empty().append('<li class="error">' + event.message + '</li>');
								return false;
								failure(event.message);
							} else {
								success(result);
							}
						});
					}
				}
			});

			$reviewerEnhancedSelect.select2({
				minimumInputLength: 3,
				escapeMarkup: function(markup) {
					return markup;
				},
				templateResult: Incident.formatStaff,
				templateSelection: Incident.formatStaffSelection,
				ajax: {
					processResults: function(data) {
						return { results: data };
					},
					minimumInputLength: 3,
					cache: true,
					delay: 100,
					data: function(params) {
						return {
							q: params.term, // search term
							page: params.page,
							programLocation: $programAssociatedToEvent.val()
						};
					},
					transport: function(params, success, failure) {
						getReviewers(JSON.stringify(params.data), function(result, event) {
							if (!event.status) {
								$('.select2-results__options').empty().append('<li class="error">' + event.message + '</li>');
								return false;
							} else {
								success(result);
							}
						});
					}
				}
			});

			$pbsEnhancedSelect.select2({
				minimumInputLength: 3,
				escapeMarkup: function(markup) {
					return markup;
				},
				templateResult: Incident.formatPBS,
				templateSelection: Incident.formatPBSSelection,
				ajax: {
					processResults: function(data) {
						return { results: data };
					},
					minimumInputLength: 3,
					cache: true,
					delay: 100,
					data: function(params) {
						return {
							q: params.term, // search term
							page: params.page,
							programLocation: $programAssociatedToEvent.val()
						};
					},
					transport: function(params, success, failure) {
						getPBSForProgram(JSON.stringify(params.data), function(result, event) {
							if (!event.status) {
								$('.select2-results__options').empty().append('<li class="error">' + event.message + '</li>');
								return false;
							} else {
								success(result);
							}
						});
					}
				}
			});

			$agenciesEnhancedSelect.select2({
				tags: true,
				tokenSeparators: [',']
			});
			$simpleSelect2.select2({
				minimumResultsForSearch: Infinity,
				allowClear: true
			});
			$hiddenFields.each(function(i) {
				var $target = $(this);
				if (!$target.data('hidden-field')) {
					return true;
				}
				$target.on("change", function(e) {
					$('[id$=' + $target.data('hidden-field') + ']').val($target.val());
				});
			});
		};
	};
})(jQuery.noConflict());
