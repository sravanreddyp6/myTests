window.serviceDataTracking = window.serviceDataTracking || {};

(function(j$) {
    "use strict";

    serviceDataTracking.setUpFields = function(targets) {
        if (!targets) targets = j$('input, select');
        j$(targets).on("change", function(event) {
            applyShowHideRulesToField(event.target);
        });
        j$(targets).each(function(_, target) {
            applyShowHideRulesToField(target);
        });
        j$('.datepicker').datetimepicker({
            maxDate: 0,
            timepicker: false,
            format: 'm/d/Y',
            closeOnDateSelect: true
        });
    }
    serviceDataTracking.prepDataForSelect = function(data) {
        var myData = [];
        if (!data) return myData;
        for (var i = 0; i < data.length; i++) {
            myData.push({
                id: data[i].Id,
                text: data[i].Description__c,
                dataObj: data[i]
            });
        }
        return myData;
    }
    serviceDataTracking.formatObjective = function(obj) {
        if (obj.loading) {
            return obj.text;
        }
        var markup = "<div class='select2-result-item clearfix'>" +
            "<div class='select2-result-item__avatar'></div>" +
            "<div class='select2-result-item__title'>" + obj.dataObj.Description__c + "</div>";
        if (obj.dataObj) {
            markup += "<div class='select2-result-item__description'>Type: " + obj.dataObj.Type__c + "</div>";
        }
        if (obj.dataObj) {
            markup += "<div class='select2-result-item__statistics'>" +
                "<div class='select2-result-item__forks'><i class='fa fa-flash'></i>Effective Date: " + moment(obj.dataObj.Effective_Date__c).format('MM/DD/YYYY') + "   Target Date: " + moment(obj.dataObj.Target_End_Date__c).format('MM/DD/YYYY') + "</div>" +
                "</div>";
        }
        markup += "</div></div>";
        return markup;
    }
    serviceDataTracking.formatObjectiveSelection = function(obj) {
        return obj.text;
    }
    serviceDataTracking.initializeObjectivesSelect = function() {
        serviceDataTracking.myObjectives = j$.parseJSON(j$('#myServicesList').val());
        j$(".objectivesEnhancedSelect").select2({
            data: serviceDataTracking.prepDataForSelect(serviceDataTracking.myObjectives),
            escapeMarkup: function(markup) {
                return markup;
            },
            templateResult: serviceDataTracking.formatObjective,
            templateSelection: serviceDataTracking.formatObjectiveSelection,
            cache: true,
            disabled: j$('#objResultWrapperId').val() != ''
        }).on("change", function(e) {
            var serviceVal = this.value;
            j$(this).siblings().filter('.select2HiddenField').val(serviceVal);

            var selectedObjective = j$.grep(serviceDataTracking.myObjectives, function(obj) {
                return obj.Id == serviceVal;
            });
            j$('#objectiveType').val(selectedObjective[0].Type__c).trigger('change');

            if (selectedObjective[0].Type__c == 'Yes/No w/time' && j$('[id$=serviceDateTime]').val() == '') {
                j$('[id$=serviceDateTime]').val(moment().format('L LT'));
                j$('#serviceDateTime_pickerId').val(moment().format('L LT'));
                j$('[id$=serviceDate]').val('');
            } else if (selectedObjective[0].Type__c == 'Yes/No' && j$('[id$=serviceDate]').val() == '') {
                j$('[id$=serviceDate]').val(moment().format('L'));
                j$('[id$=serviceDateTime]').val('');
                j$('#serviceDateTime_pickerId').val('');
            }
        });
    }
    serviceDataTracking.validateServiceResult = function() {
        var serviceValue = j$('[id$=selectServiceValue]').val();
        var serviceProvidedValue = j$('[id$=serviceProvided]').val();
        var serviceStatusValue = j$('[id$=serviceStatus]').val();
        var reasonValue = j$('[id$=serviceReason]').val();
        var serviceInitialsValue = j$('[id$=serviceInitials]').val();
        var serviceDateTimeValue = j$('[id$=serviceDateTime]').val();
        var serviceDateValue = j$('[id$=serviceDate]').val();
        var objectiveTypeValue = j$('#objectiveType').val();

        var sericeTrackingErrors = [];
        j$('#sericeTrackingErrors').html('');
        if (serviceValue == '') {
            sericeTrackingErrors.push('Cannot save. Please select a value for "Service".');
        } else if (serviceProvidedValue == '') {
            sericeTrackingErrors.push('Cannot save. Please select a value for "Service Provided".');
        } else if (serviceInitialsValue == '') {
            sericeTrackingErrors.push('Cannot save. Please fill in a value for "Initials".');
        } else if (objectiveTypeValue == 'Yes/No w/time') {
            if (serviceDateTimeValue == '')
                sericeTrackingErrors.push('Cannot save. Please select a value for "Datetime" when the selected service was provided.');
            else {
                var selectedObjective = j$.grep(serviceDataTracking.myObjectives, function(obj) {
                    return obj.Id == serviceValue;
                });

                if (moment(serviceDateTimeValue).isBefore(moment(selectedObjective[0].Effective_Date__c)) ||
                    moment(serviceDateTimeValue).isAfter(moment(selectedObjective[0].Target_End_Date__c).add(1, 'd')))
                    sericeTrackingErrors.push('Cannot save. The Datetime value must be within the selected service Effective Date: ' + moment(selectedObjective[0].Effective_Date__c).format('MM/DD/YYYY') + '   Target Date: ' + moment(selectedObjective[0].Target_End_Date__c).format('MM/DD/YYYY'));
                    
                if (moment(serviceDateTimeValue).isAfter(moment()))
                    sericeTrackingErrors.push('Cannot save. The Datetime value cannot be in future.');
            }
        } else if (objectiveTypeValue == 'Yes/No') {
            if (serviceDateValue == '')
                sericeTrackingErrors.push('Cannot save. Please select a value for "Date" when the selected service was provided.');
            else {
                var selectedObjective = j$.grep(serviceDataTracking.myObjectives, function(obj) {
                    return obj.Id == serviceValue;
                });

                if (moment(serviceDateValue).isBefore(moment(selectedObjective[0].Effective_Date__c)) ||
                    moment(serviceDateValue).isAfter(moment(selectedObjective[0].Target_End_Date__c)))
                    sericeTrackingErrors.push('Cannot save. The Date value must be within the selected service Effective Date: ' + moment(selectedObjective[0].Effective_Date__c).format('MM/DD/YYYY') + '   Target Date: ' + moment(selectedObjective[0].Target_End_Date__c).format('MM/DD/YYYY'));

                if (moment(serviceDateValue).isAfter(moment()))
                    sericeTrackingErrors.push('Cannot save. The Date value cannot be in future.');
            }
        }
        if (sericeTrackingErrors.length > 0) {
            j$(window).scrollTop(0);
            j$.each(sericeTrackingErrors, function(index, error) {
                j$('#sericeTrackingErrors').append('<li class="error">' + error + '</li>');
            });
            return false;
        }
    }
})(jQuery.noConflict());
jQuery(document).ready(function() {
    serviceDataTracking.initializeObjectivesSelect();
    serviceDataTracking.setUpFields();
});