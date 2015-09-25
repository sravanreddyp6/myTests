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
	
	fundingSourceFinalizeHelper = function (recordType, totalauthUnits, elSelector){
		fundingSourceClearMessages();
		var errors = validateFundingSource(recordType);
		var authErrors = validateAuthCalculations();
		
		/*var otherCost = $('[id$=otherCost]').val();
		if(parseFloat(otherCost) > 0 && $('[id$=otherCostDescription]').val() == ''){
			authErrors.push('Please enter the other cost description');
		}
		 
		var Excess = validateauthUnitsTotal();
		if(Excess == '1' && $('[id$=authExcessJustification]').val() == ''){
			authErrors.push('Please enter the Authorization Excess justification');
		}*/
		
		var allErrors = authErrors.concat(errors);
		var totalAuthstring = 'input[id*=' + elSelector + ']';
		if (allErrors.length > 0) {
			$('#fundingMessages').html('');
			$.each(allErrors, function (index, error) {
				$('#fundingMessages').append('<li class="error">' + error + '</li>');
			});
			fundingSourceScrollToTop();
        } else {
			$(totalAuthstring).val(parseFloat(totalauthUnits));
			var finalErrors = [];
			var Excess = validateauthUnitsTotal();
			var otherCost = $('[id$=otherCost]').val();
			if(Excess == '1'){
				$('[id$=authGrandTotalUnits]').addClass("grandtotalwarning");
			}else{
				$('[id$=authGrandTotalUnits]').removeClass("grandtotalwarning");
			}
			if(parseFloat(otherCost) > 0 && $('[id$=otherCostDescription]').val() == ''){
				finalErrors.push('Please enter the other cost description');
			}
			if(Excess == '1' && $('[id$=authExcessJustification]').val() == ''){
				finalErrors.push('Please enter the Authorization Excess justification');
			}
			if (finalErrors.length > 0) {
			$('#fundingMessages').html('');
			$.each(finalErrors, function (index, error) {
				$('#fundingMessages').append('<li class="error">' + error + '</li>');
			});
			fundingSourceScrollToTop();
			}
			else{
				if(window.confirm('You will not be able to edit the funding source once you Finalize it. Do you want to proceed?')){
					finalizeFundingSource();
				}else{
					return null;
				}
			}
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
        j$('#fundingMessages').html('');
    }
    assignValue = function (elSelector, value) {
        var $el = $(document.getElementById(elSelector));
        $el.val(value);
    }
    
    costperDay = function(ValueId, typeId, elSelector){
    	var dayCost  = $(document.getElementById(ValueId)).val();
    	var t = '';
    	var typeString = 'input[id*=' + typeId + ']';
    	var types = j$(typeString);
		
    	for(var x= 0; x < types.length; x++){
    		if(types[x].checked){
    			t = types[x].value;
    		}
    	}

    	console.log('type is'+t);
    	
    	if(t == 'Yearly' &&  parseFloat(dayCost) >= 0 ){
    		dayCost = parseFloat(dayCost)/365;
			dayCost = Math.round(dayCost * 100)/100;
			assignValue(elSelector,dayCost);
    	}
    	else if(t == 'Monthly' &&  parseFloat(dayCost) >= 0 ){
    		dayCost = parseFloat(dayCost)/30.5;
			dayCost = Math.round(dayCost * 100)/100
			assignValue(elSelector,dayCost);
    	}
    	else if (t == 'Weekly' &&  parseFloat(dayCost) >= 0){
    		dayCost = parseFloat(dayCost)/7;
			dayCost = Math.round(dayCost * 100)/100
			assignValue(elSelector,dayCost);
    	}
		else{
			assignValue(elSelector,0);
		}
    
    }
	
/*	totalauthTherapyUnits = function(FSRate,ServiceLocationSum, FSHrs, FSDME, FSOther, FSMedication, FSNutritional, perproductiveUnit){
		//var FSRate = $(document.getElementById(FSRate)).val();
		//var SLsum = ServiceLocationSum;
		//var FSHrs =  $(document.getElementById(FSHrs)).val();
		//var FSDME = $(document.getElementById(FSDME)).val();
		//var FSOther = $(document.getElementById(FSOther)).val();
		//var FSMedication = $(document.getElementById(FSMedication)).val();
		//var FSNutritional = $(document.getElementById(FSNutritional)).val();
		//var perUnit =  perproductiveUnit;
		
		var totalUnits = 0;
		var sum = 0;
		
		if(ServiceLocationSum > 0){
				sum = sum + parseFloat(ServiceLocationSum);
			}
			if(FSHrs > 0){
				sum = sum + parseFloat(FSHrs);
			}
			if(FSDME > 0){
				sum = sum + parseFloat(FSDME);
			}
			if(FSOther > 0){
				sum = sum + parseFloat(FSOther);
			}
			if(FSMedication > 0){
				sum = sum + parseFloat(FSMedication);
			}
			if(FSNutritional > 0){
				sum = sum + parseFloat(FSNutritional);
			}
			
			totalUnits = parseFloat(FSRate) - sum;
			if(parseFloat(perproductiveUnit) > 0){
				totalUnits = totalUnits/parseFloat(perproductiveUnit);
			}else{
				totalUnits = totalUnits/1;
			}
			totalUnits = Math.round(totalUnits);
			return totalUnits;
	}*/
	
	totalauthTherapyUnits = function(FSRate,SLRoomBoard,SLPRNDS, FSHrs, FSDME, FSOther, FSMedication, FSNutritional, SLperproductiveUnit){
		//var FSRate = $(document.getElementById(FSRate)).val();
		//var SLsum = ServiceLocationSum;
		//var FSHrs =  $(document.getElementById(FSHrs)).val();
		//var FSDME = $(document.getElementById(FSDME)).val();
		//var FSOther = $(document.getElementById(FSOther)).val();
		//var FSMedication = $(document.getElementById(FSMedication)).val();
		//var FSNutritional = $(document.getElementById(FSNutritional)).val();
		//var perUnit =  perproductiveUnit;
		
		var totalUnits = 0;
		var sum = 0;
		var FSPRNDS = 0;
		var FSmarginMultiplier = 0;
		
		if(FSHrs > 0 && SLPRNDS >0){
			FSPRNDS = FSHrs*SLPRNDS;
		}
		if(FSRate > 0){	
			FSmarginMultiplier = FSRate*0.67;
		}
		
		if(FSPRNDS > 0){
				sum = sum + parseFloat(FSPRNDS);
			}
			if(SLRoomBoard > 0){
				sum = sum + parseFloat(SLRoomBoard);
			}
			if(FSDME > 0){
				sum = sum + parseFloat(FSDME);
			}
			if(FSOther > 0){
				sum = sum + parseFloat(FSOther);
			}
			if(FSMedication > 0){
				sum = sum + parseFloat(FSMedication);
			}
			if(FSNutritional > 0){
				sum = sum + parseFloat(FSNutritional);
			}
			
			console.log('Hours' + FSHrs);
			console.log('SLPRNDS' +SLPRNDS);
			console.log('FSPRNDS'+FSPRNDS);
			console.log('RATE'+FSRate);
			console.log('Rate*0.67'+FSmarginMultiplier);
			console.log('SLRoomBoard'+SLRoomBoard);
			console.log('DME'+FSDME);
			console.log('FSOther'+FSOther);
			console.log('FSMedication'+FSMedication);
			console.log('FSNutritional'+FSNutritional);
			
			totalUnits = (parseFloat(FSmarginMultiplier) - sum)*7;
			console.log('total units*7'+totalUnits);
			if(parseFloat(SLperproductiveUnit) > 0){
				totalUnits = totalUnits/parseFloat(SLperproductiveUnit);
			}else{
				totalUnits = totalUnits/1;
			}
			totalUnits = Math.round(totalUnits);
			return totalUnits;
	}
	
	authUnitsTotal = function(OT, PT, SLP,BIT, Counselling, elSelector){
		var OTUnits = $(document.getElementById(OT)).val();
		var PTUnits = $(document.getElementById(PT)).val();
		var SLPUnits = $(document.getElementById(SLP)).val();
		var BITUnits = $(document.getElementById(BIT)).val();
		var couUnits = $(document.getElementById(Counselling)).val();
		
		var sumTotal = 0;
		$(elSelector).removeClass("grandTotal");
		if(OTUnits > 0){
			sumTotal = sumTotal + parseFloat(OTUnits);
		}
		if(PTUnits > 0){
			sumTotal = sumTotal + parseFloat(PTUnits);
		}
		if(SLPUnits > 0){
			sumTotal = sumTotal + parseFloat(SLPUnits);
		}
		if(BITUnits > 0){
			sumTotal = sumTotal + parseFloat(BITUnits);
		}
		if(couUnits > 0){
			sumTotal = sumTotal + parseFloat(couUnits);
		}
		
		sumTotal = Math.round(sumTotal);		
		assignValue(elSelector,sumTotal);
		
		var exceeded = validateauthUnitsTotal();
		if(exceeded == '1'){
			j$('[id$=authGrandTotalUnits]').addClass("grandtotalwarning");
		}else{
			j$('[id$=authGrandTotalUnits]').removeClass("grandtotalwarning");
		}
	
	}
	validateauthUnitsTotal = function(){
		var actualUnits = j$('[id$=authGrandTotalUnits]').val();
		var allowedUnits = j$('[id$=totalAuthUnits]').val();
		
		if(parseFloat(actualUnits) > parseFloat(allowedUnits)){
			return '1';
		}else{
			return '0';
		}

	}
	
	validateAuthCalculations = function(){
		var authUnitErrors = [];
		var term = $('[id$=funding_costTherapyTermDate]').val();
		var effective = $('[id$=funding_costTherapyEffeciveDate]').val();
		var today = new Date();
		var termDate = new Date(term);
		var effectiveDate = new Date(effective);
		
		if($('[id$=funding_casemanagerName]').val() == ''){
            	authUnitErrors.push('Case Manager is Mandatory');
		}
		if(effective == ''){
			authUnitErrors.push('Effective Date of Cost/Therapy is Mandatory');
		}
		if(term == ''){
			authUnitErrors.push('Term Date of Cost/Therapy is Mandatory');
		}
		
		if($('[id$=funding_oneoneRatio]').val() == ''){
			authUnitErrors.push('Staffing Ratio 1:1 field is Mandatory');
		}
		
		if($('[id$=hoursExpected]').val() == ''){
			authUnitErrors.push('Number of Hours field is mandatory');
		}
		
		if($('[id$=receivedRate]').val() == ''){
			authUnitErrors.push('Rate is Mandatory for Calculating total Units');
		}
		if($('[id$=DMECost]').val() != '' && !$("input[name*='dmeType']:checked").val()){
			authUnitErrors.push('Please choose the calculation type for DME');
		}
		if($('[id$=medicationCost]').val() != '' && !$("input[name*='medicationType']:checked").val()){
			authUnitErrors.push('Please choose the calculation type for Medication Costs');
		}
		if($('[id$=nutritionalCost]').val() != '' && !$("input[name*='nutritionalType']:checked").val()){
			authUnitErrors.push('Please choose the calculation type for Nutritonal Cost');
		}
		if($('[id$=otherCost]').val() != '' && !$("input[name*='otherType']:checked").val()){
			authUnitErrors.push('Please choose the calculation type for Other Cost');
		}
		
		return authUnitErrors;
	
	}
	
	prnDS = function(slPRNDS, elselector){
		var hours = $('[id$=hoursExpected]').val();
		var slDs = slPRNDS;
		console.log('I am in here');
		console.log(hours);
		console.log(elselector);
		console.log(slDs);
		
		if(hours > 0 && slDs  > 0){
			console.log('i am in if loop');
			assignValue(elselector,hours*slDs);
		}else{
			console.log('I am ion else loop');
			assignValue(elselector, 0);
		}
	
	}
	
	onlyNos = function(e, t) {
            try {
                if (window.event) {
                    var charCode = window.event.keyCode;
                }
                else if (e) {
                    var charCode = e.which;
                }
                else { return true; }
                if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                    return false;
                }
                return true;
            }
            catch (err) {
                alert(err.Description);
            }
        }
 
     isNumberwithDec = function (evt, obj) {
            var charCode = (evt.which) ? evt.which : event.keyCode
            var value = obj.value;
            var dotcontains = value.indexOf(".") != -1;
            if (dotcontains)
                if (charCode == 46) return false;
            if (charCode == 46) return true;
            if (charCode > 31 && (charCode < 48 || charCode > 57))
                return false;
            return true;
        }
	
    
}) (jQuery.noConflict());