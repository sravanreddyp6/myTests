(function ($) {
    validateEmail = function (email) {
        return /\S+@\S+\.\S+/.test(email);  // Very simple regex to check email here
    }
    validateFundingSource = function (referralRecordType) {
        var errors = [];
        if (referralRecordType != 'CareMeridian' && referralRecordType != 'NeuroRestorative' && $('select[id$=fundingEntry_Source]').val() == '') {
            errors.push('Funding Source is required.');
        }
        if (referralRecordType == 'CareMeridian' || referralRecordType == 'NeuroRestorative') {
            // Validate dependent fields
            var inputFields = $('[id*=FundingSourceModal] select').filter(function () {
                return (this.id.indexOf('field_validation') != -1);
            });
            $.each(inputFields, function (index, inputField) {
                var fieldId = $(inputField).attr('id');
                //var fieldNum = fieldId.substr(fieldId.length - 1);
                var fieldNum = fieldId.substr(fieldId.indexOf('field_validation') + 16, fieldId.length);
                var $fieldToCheck = $('[id*=FundingSourceModal] input[id*=field_check' + fieldNum + ']');
                var $checkBoxLabel = $('label[for="' + $(inputField).attr('name') + '"]');
                var $fieldLabel = $('label[for="' + $fieldToCheck.attr('name') + '"]');
                if ($(inputField).val() == 'Yes' && $fieldToCheck.val() == '') {
                    errors.push($fieldLabel.text() + ' cannot be empty when ' + $checkBoxLabel.text() + ' is Yes');
                }
            });
        }
        if (referralRecordType == 'CareMeridian') {
            // Additional Coverage
            if ($('[id*=additionalCoverage]').val() == 'Yes' && $('[id*=additionalCoverageDetail]').val() == '') {
                errors.push('Please provide more detail for Additional Coverage');
            }
            // Validate claims submission email
            var $claimsSubmissionEmail = $('[id*=claimsSubmissionEmail]');
            if ($claimsSubmissionEmail.size()>0 && $claimsSubmissionEmail.val()!='' && !validateEmail($claimsSubmissionEmail.val())) {
                errors.push('Claims Submission Email does not seem to a valid email address');
            }
            var $payerCmEmail = $('[id*=payerCmEmail]');
            if ($payerCmEmail.size()>0 && $payerCmEmail.val()!='' && !validateEmail($payerCmEmail.val())) {
                errors.push('Payer CM Email does not seem to a valid email address');
            }

            // claims submission zip
            if ( !checkZipCode(j$('input[id$=Claims_Submission_Zip]').val())) {
                errors.push('Please enter zip code in the format: XXXXX or XXXXX-XXXX');
            }

            if (j$('select[id$=authtype]').length > 0 && j$('select[id$=authtype]').val() == 'Other') {
                if ( j$('input[id$=otherauthtype]').val().trim() == false  ) {
                    errors.push ('Please describe "Other" authorization type');
                }
            }

            if ( j$('input[id$=contractused_lkid]').length > 0 &&  j$('input[id$=contractused]').val().trim() && !(j$('input[id$=contractused_lkid]').val().trim())) {
                errors.push('Please choose a valid contract using the search icon');
            }


        }

        if (referralRecordType == 'NeuroRestorative') {
            // Validate email fields
            var $claimsSubmissionEmail = $('[id*=claimsSubmissionEmail]');
            if ($claimsSubmissionEmail.size()>0 && $claimsSubmissionEmail.val()!='' && !validateEmail($claimsSubmissionEmail.val())) {
                errors.push('Claims Submission Email does not seem to a valid email address');
            }
            var $payerCmEmail = $('[id*=payerCmEmail]');
            if ($payerCmEmail.size()>0 && $payerCmEmail.val()!='' && !validateEmail($payerCmEmail.val())) {
                errors.push('Payer CM Email does not seem to a valid email address');
            }
            var $nrCmEmail = $('[id*=nrCmEmail]');
            if ($nrCmEmail.size()>0 && $nrCmEmail.val()!='' && !validateEmail($nrCmEmail.val())) {
                errors.push('NR CM Email does not seem to a valid email address');
            }
            var $adjusterEmail = $('[id*=adjusterEmail]');
            if ($adjusterEmail.size()>0 && $adjusterEmail.val()!='' && !validateEmail($adjusterEmail.val())) {
                errors.push('Adjustor Email does not seem to a valid email address');
            }
            
            //For EB-438 Sravan
            
            if($('[id$=funding_casemanagerName]').val() == ''){
            	errors.push('Case Manager is Mandatory');
            }
            
            if($('[id$=funding_costTherapyEffeciveDate]').val() == ''){
            	errors.push('Effective Date of Cost/Therapy is Mandatory');
            }
             
            if($('[id$=funding_costTherapyTermDate]').val() == ''){
            	errors.push('Term Date of Cost/Therapy');
            }
            
            if($('[id$=funding_oneoneRatio]').val() == ''){
            	errors.push('Staffing Ratio 1:1 field is Mandatory');
            }
            
            
            
            
            
            
            
            
            
            
            //End EB-438

            // Other validation
            var $referralStatus = $('[id$=referralStatus]');
            var $payerType = $('[id$=neuroPayerType]');
            // $referralStatus could either be in a <span> or in an <input>,
            // depending on which page we're looking at (view or edit page),
            // so we have to use diffferent methods to find its value.
            if (($referralStatus.val() == 'Closed' || $referralStatus.text() == 'Closed') && $payerType.val() == '') {
                errors.push('You must choose a Payer Type for a closed referral!');
            }

            var $vaPilotClinicalNumber = $('[id$=vaPilotClinicalNumber]');
            if ($payerType.val() == 'VA - Pilot' && $vaPilotClinicalNumber.val() == '') {
                errors.push('You must enter the VA Pilot Clinical Number because the Payer Type is VA - Pilot!');
            }
        }
        return errors;
    }

     // ERC-96: Adding this for front end validation.
  // Claims_Submission_Zip is now a text field instead of number field.
  function checkZipCode(value) {
      var errors = '';
      var validformat = /^\d{5}$|^\d{5}-\d{4}$/

      // if it contains a value and doesn't match regex then error
      return ( !(!validformat.test(value) && value.trim()) );

      }



    fundingSourceSaveHelper = function (referralRecordType) {
        fundingSourceClearMessages();
        var errors = validateFundingSource(referralRecordType);
        if (errors.length > 0) {
            $('#fundingMessages').html('');
            $.each(errors, function (index, error) {
                $('#fundingMessages').append('<li class="error">' + error + '</li>');
            });
            fundingSourceScrollToTop();
        } else {
            saveFundingSource();
        }
    }
    fundingSourceScrollToTop = function (isSuccess) {
        if (isSuccess) {
            $('#fundingMessages').append('<li class="success">Save successful!</li>');
        }
        $('[id*=FundingSourceModal].ui-dialog-content').parent().animate({
            scrollTop: 0
        }, 200);
    }
    fundingSourceClearMessages = function () {
        $('#fundingMessages').html('');
    }
    assignValue = function (elSelector, value) {
        var $el = $(document.getElementById(elSelector));
        $el.val(value);
    }
    
    costperDay = function(ValueId, typeId, elSelector){
    	console.log('type id is '+typeId);
    	var idt = "+typeId+";
    	var dayCost = $(document.getElementById(ValueId)).val();
    	//var types = jQuery('input[id*=typeId]');
    	var types = document.getElementsByName(idt);
    	var t = '';
    	
    	
    	for(var x= 0; x < types.length; x++){
    		if(types[x].checked){
    			t = types[x].value;
    		}
    	}
    	
    	/*$('input[id*=dmeType]').each(function (index, element) {
					if ( $(element).checked )
						t = $(element).val();
				});*/
    	
    	console.log('type is'+t);
    	
    	if(t == 'Yearly'){
    		dayCost = dayCost/365;
    	}
    	else if(t == 'Monthly'){
    		dayCost = dayCost/30;
    	}
    	else if (t == 'Weekly'){
    		dayCost = dayCost/7;
    	}
    	
    	assignValue(elSelector,dayCost);
    
    }
    
}) (jQuery.noConflict());
