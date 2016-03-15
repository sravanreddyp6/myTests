public with sharing class MyRemoteMethods {
	public static final boolean isMilitaryTime = UserDefaults__c.getInstance(userinfo.getuserId()).MilitaryTime__c;
	private transient TxnQueueResponseController parentCntrller;
    public class Im_partyData{
        Id id;
        String DT_RowId;
        String name;
        String type;
        Im_partyData(Im_InvolvedParty__c party){
            this.involvedParty = party;
            this.DT_RowId = String.valueOf(party.id);
            this.id = party.id;
            this.type = party.Type__c;
            //if (party.Type__c == 'Person Being Served') this.name = party.Person_Being_Served_Involved__r.pbsFirstName__c + ' ' + party.Person_Being_Served_Involved__r.pbsLastName__c;
            //else if (party.Type__c == 'Staff') this.name = party.Staff_Involved__r.name;
            //else 
            this.name = party.name;
        }
        Im_InvolvedParty__c involvedParty;
    }
	@RemoteAction public static Im_partyData getInvolvedParty(String InvPrtyId) {
        Im_InvolvedParty__c imPrty = [select id, Type__c, name, 
        									Person_Being_Served_Involved__r.pbsFirstName__c, 
        									Person_Being_Served_Involved__r.pbsLastName__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.PBS_Identifier__c,
        									PBS_Age__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Gender__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Birthdate,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Guardian1_Name__c,
        									Person_Being_Served_Involved__r.Admission__r.Effective_Date__c,
        									Person_Being_Served_Involved__r.Start_Date__c,
        									Length_Of_Service__c,
        									PBS_Population_Type__c,
        									Staff_Involved__r.name,
        									Staff_Involved__r.Employee_Number__c,
        									Staff_Involved__r.Job_Title__c,
        									Staff_Involved__r.Job_Status__c,
        									Staff_Involved__r.Current_Person_Type__c,
        									Staff_Involved__r.Location_Name__c,
        									Staff_Involved__r.Manager_Name__c
        									from Im_InvolvedParty__c where  id =: InvPrtyId limit 1];
        									
		Im_partyData Prty = new Im_partyData(imPrty);
        return Prty;		 
    }
    
	@ReadOnly @RemoteAction public static list<Im_partyData> getInvolvedParties(String EventId) {
        Id event = (EventId instanceof Id) ? (Id) EventId : null;
        list<Im_partyData> dataObj = new list<Im_partyData>();
        for (Im_InvolvedParty__c imPrty : [select id, Type__c, name, 
        									Person_Being_Served_Involved__r.pbsFirstName__c, 
        									Person_Being_Served_Involved__r.pbsLastName__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.PBS_Identifier__c,
        									PBS_Age__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Gender__c,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Birthdate,
        									Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.Guardian1_Name__c,
        									Person_Being_Served_Involved__r.Admission__r.Effective_Date__c,
        									Person_Being_Served_Involved__r.Start_Date__c,
        									Length_Of_Service__c,
        									PBS_Population_Type__c,
        									Staff_Involved__r.name,
        									Staff_Involved__r.Employee_Number__c,
        									Staff_Involved__r.job_title__c,
        									Staff_Involved__r.Job_Status__c,
        									Staff_Involved__r.Current_Person_Type__c,
        									Staff_Involved__r.Location_Name__c,
        									Staff_Involved__r.Manager_Name__c	
        									 from Im_InvolvedParty__c where Im_Incident__c =: event order by Type__c]){
			Im_partyData Prty = new Im_partyData(imPrty);
            dataObj.add(Prty);
        }
        return dataObj;		 
    }
    
    
    @ReadOnly @RemoteAction public static list<String> getInvPrtyEvntDetails(String involvedPrtyId) {
        Id invPrty = Id.valueOf(involvedPrtyId);
		map<String, String> sectionIdMap = new map<String, String>();
		map<String, list<Eval__c>> sectionMap = new map<String, list<Eval__c>>();
		
		map<Id, Eval_Value__c> evalIdToValueMap = new map<Id, Eval_Value__c>();
		map<String, Eval_Value__c> sectionErrorMsgs = new map<String, Eval_Value__c>();
		set<String> validSubCats = new set<String>();
		for (Eval_Value__c value: [SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c, 
											text_over_250__c, text_under_250__c, 
											eval__c, eval__r.composite__c, eval_section_type__c, 
											eval_section_id__c, eval__r.length__c, eval__r.htmlId__c 
										FROM eval_value__c 
									 WHERE eval__r.Visible__c = true
									   AND what_id__c = :invPrty order by eval__r.category_sequence__c, eval__r.sub_category_sequence__c, eval__r.field_sequence__c]) {
			evalIdToValueMap.put(value.Eval__c, value);
			if (!sectionMap.containsKey(value.eval__r.composite__c)) {
				sectionMap.put(value.eval__r.composite__c, new list<Eval__c>());
				sectionIdMap.put(value.eval__r.composite__c, value.eval_section_id__c);
			}
			if (value.eval__r.htmlId__c.equalsIgnoreCase('ErrorMsg')) sectionErrorMsgs.put(value.eval__r.composite__c, value);			
			if (value.eval__r.htmlId__c.equalsIgnoreCase('isValid') && value.Boolean__c) validSubCats.add(value.eval__r.composite__c);
		}

		set<Id> evalIds = new set<Id>();
		for (Eval__c eval : [SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c, 
									sub_category__c, sub_category_sequence__c, eval_type__r.name, Field_Type__c,
									Field_Sub_Type__c, field_sequence__c, required__c, Length__c, Visible__c,
									visibility_rules__c, visibility_row_rules__c, Dependent_Fields__c, Composite__c
							  FROM eval__c WHERE Composite__c IN : sectionMap.keySet() and Visible__c = true
							 ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c]) {
		 	sectionMap.get(eval.Composite__c).add(eval);
		 	evalIds.add(eval.id);
		}

		List<Eval_Drop_Down__c> dd = [SELECT whatid__c, option_name__c, option_value__c, Dependent_Fields__c,
									       visibility_row_rules__c, visibility_rules__c
									  FROM eval_drop_down__c
									 WHERE whatid__c in : evalIds
									ORDER BY whatid__c, Sequence__c ];

		list<string> myScripts = new list<String>();
		for (String composite: sectionMap.keySet()) {
			//String cleanComposite = composite.replaceAll('[^A-Za-z0-9 ]', '').deleteWhitespace();
			String cleanComposite = 'mySecId-' + sectionIdMap.get(composite);
			if ( sectionErrorMsgs.containsKey(composite) && String.isNotBlank(sectionErrorMsgs.get(composite).Text_Over_250__c) ){
				myScripts.add('<h3 id="'+ cleanComposite +'" class="ui-state-error">'+ composite.substringAfterLast('~') + '</h3>');
				myScripts.add('<table style="width: 100%;" class="subCatTable ' + cleanComposite + '"><tr><td style="width=100%;"><input type="button" value="Remove" class="btn removeInvPrtyEvntTyp"/><ul class="ui-state-error" style="margin-right: 5em;">' + 
								sectionErrorMsgs.get(composite).Text_Over_250__c + '</ul></td></tr><tr><td style="width=100%;">' + 
								generateSubsection(composite, sectionMap.get(composite), dd, evalIdToValueMap, sectionIdMap.get(composite), involvedPrtyId) + '</td></tr></table>');
			}
			else {
				myScripts.add('<h3 id="'+ cleanComposite +'" class="'+ (validSubCats.contains(composite) ? 'ui-state-success' : '' ) +'">'+ composite.substringAfterLast('~') + '</h3>');
				myScripts.add('<table style="width: 100%;" class="subCatTable ' + cleanComposite + '"><tr><td style="width=100%;"><input type="button" value="Remove" class="btn removeInvPrtyEvntTyp"/></td></tr><tr><td style="width=100%;">' + 
								generateSubsection(composite, sectionMap.get(composite), dd, evalIdToValueMap, sectionIdMap.get(composite), involvedPrtyId) + '</td></tr></table>');
			}
		}
		if (myScripts.size() > 0 ) myScripts.add('<script id="'+ involvedPrtyId + 'myScript" >setUpFields(jQuery(\'#\' + jQuery(\'#' + involvedPrtyId + 'myScript\').parent().attr("id") + \' input, #\' +  '  +   'jQuery(\'#' + involvedPrtyId + 'myScript\').parent().attr("id") + \' img, #\' +  ' + 'jQuery(\'#' + involvedPrtyId + 'myScript\').parent().attr("id") + \' select\'));</script>');
		return myScripts;		
	}
     

	private static String generateSubsection(String composite, List<Eval__c> listEvalItems, List<Eval_Drop_Down__c> dd, map<id,Eval_Value__c> mapEvalValues, String evalSectionId, String involvedPrtyId) {
		List<String> htmlControls = new List<String>();

		Map<ID, List<Eval_Drop_Down__c>> ddOptions = new Map<ID, List<Eval_Drop_Down__c>>();
		// create a map for easy access
		Map<ID, Eval__c> mapEvalItems = new Map<ID, Eval__c>(listEvalItems);
		List<Eval_Drop_Down__c> newdd;
		for (Eval_Drop_Down__c edd : dd) {
			if (ddOptions.ContainsKey(edd.whatid__c)) {
				if ((newdd = ddOptions.get(edd.whatid__c)) == null)
					newdd = new List<Eval_Drop_Down__c>();
			} else {
				newdd = new List<Eval_Drop_Down__c>();
			}
			newdd.Add(edd);
			ddOptions.put(edd.whatid__c, newdd);
		}


		String newHtmlLbl = '';
		String newHtmlFld = '';
		String strval = '';
		String reqFldHtml = '';
		for(Eval__c e : listEvalItems){
			try {
				e.htmlid__c = evalSectionId + e.htmlid__c;
				if (String.IsNotBlank(e.visibility_rules__c)) e.visibility_rules__c = updateRulesJSON(e.visibility_rules__c,evalSectionId);
				if (String.IsNotBlank(e.Dependent_Fields__c))  e.Dependent_Fields__c = updateRulesJSON(e.visibility_rules__c,evalSectionId);
				newHtmlLbl = '<td class="text_right">';
				newHtmlLbl += '<input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" />';
				newHtmlLbl += '<label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label></td>';
				newHtmlFld = '';
				strval = '';

				if (e.Required__c) {
					reqFldHtml = '<div class="requiredInput" style="display: table-cell;"><div class="requiredBlock"></div>';
				} else {
					reqFldHtml = '<div style="display: table-cell;">';
				}

				if (e.Field_Type__c == 'Hidden')  {
						newHtmlLbl = '<td><input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" /></td> ';  // an emtpy col for the hidden fields so that their labes wont show up on the form
						newHtmlFld += '<td class="dataCol"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="hidden" ';
						if (mapEvalValues.ContainsKey(e.id)) {
							newHtmlFld += 'value="' ;
							if (e.Field_Sub_Type__c == 'Boolean') {
								newHtmlFld += mapEvalValues.get(e.id).boolean__c;
							} else if (e.Field_Sub_Type__c == 'String') {
								newHtmlFld += mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
							}
						}
						newHtmlFld += '"/></td>';
				} else if (e.Field_Type__c == 'Boolean')  { // Boolean can be Checkbox, Radio, or Dropdown
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="checkbox" value="' + 1 + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + involvedPrtyId + '" ';

						// insert value
						if (mapEvalValues.ContainsKey(e.id)) {
							if (mapEvalValues.get(e.id).boolean__c) {
								newHtmlFld += ' checked ';
							}
						}

						newHtmlFld += '/></div></td>';
					} else if (e.Field_Sub_Type__c == 'Dropdown') {
						// Boolean dropdown values = --None--, Yes, No
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<select  id="' + e.htmlid__c + '" name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + involvedPrtyId + '">';
						newHtmlFld += '<option value="">-- None --</option>';
						if (mapEvalValues.ContainsKey(e.id)) {
							strval = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();
						}
						newHtmlFld += '<option value="1"';
						if (strval == '1')
							newHtmlFld += ' selected';
						newHtmlFld += '>Yes</option>';
						newHtmlFld += '<option value="0"';
						if (strval == '0')
							newHtmlFld += ' selected';
						newHtmlFld += '>No</option>';
						newHtmlFld += '</select></div></div></td>';
					} //TODO: output radio buttons for Radio type
				} else if (e.Field_Type__c=='String') {
					if (e.length__c >= 3000) {
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<textarea  id="' + e.htmlid__c + '"  name="' + e.id + '" data-composite="' + involvedPrtyId + '">';
						if (mapEvalValues.ContainsKey(e.id)) {
							strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
							if (strVal != null && strVal != '')
								newHtmlFld += strVal;
						}
						newHtmlFld +=  '</textarea></div></div></td>';

					} else {
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<input  id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + involvedPrtyId + '" ';
						if (mapEvalValues.ContainsKey(e.id)) {
							newHtmlFld += 'value="' ;
							if (e.length__c > 250)
								strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
							else
								strVal = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();

							if (strVal != null && strVal != '')
								newHtmlFld += strVal;

							newHtmlFld += '"';
						}
						newHtmlFld +=  '/></div></div></td>';
					}
				} else if (e.Field_Type__c == 'Double'){
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + involvedPrtyId + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' ;
						if (mapEvalValues.get(e.id).eval__r.length__c == null || mapEvalValues.get(e.id).eval__r.length__c < 250) {
							strVal = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();
						} else {
							strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
						}

						if (strVal != null && strVal != '')
							newHtmlFld += strVal;

						newHtmlFld += '"/>';
					}
					newHtmlFld += '</div></div></td>';

				} else if (e.Field_Type__c == 'Int'){
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input  pattern="[0-9]+" title="Please enter a valid number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + involvedPrtyId + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' ;
						strVal = String.valueOf(mapEvalValues.get(e.id).Number_No_Decimal__c);

						if (strVal != null && strVal != '')
							newHtmlFld += strVal;

						newHtmlFld += '"';
					}
					newHtmlFld +=  '/></div></div></td>';

				} else if (e.Field_Type__c == 'DropDown') {

					// get the value
					if (mapEvalValues.ContainsKey(e.id)) {
						if (mapEvalValues.get(e.id).eval__r.length__c == null || mapEvalValues.get(e.id).eval__r.length__c < 250) {
							strVal = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();
						} else {
							strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
						}
					}

					// get the options
					List<Eval_drop_Down__c> dropdownopts = ddOptions.get(e.id);
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<select id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + involvedPrtyId + '">';
					newHtmlFld += '<option value="">-- None --</option>';
					for (Eval_Drop_Down__c thisdd : dropdownopts) {
						newHtmlFld += '<option value="' + thisdd.option_value__c + '"';
						if (strval ==  thisdd.option_value__c)
							newHtmlFld += ' selected ';

						newHtmlFld += '>' + thisdd.option_name__c + '</option>';
					}
					newHtmlFld += '</select></div></div></td>';
				}  else if (e.Field_Type__c == 'Date') {
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input class="datepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + involvedPrtyId + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' + mapEvalValues.get(e.id).date_time__c.date().format();
						newHtmlFld  += '"';
					}
					newHtmlFld +=  '/></div></div></td>';
				} else if (e.Field_Type__c == 'Datetime') {
					newHtmlFld += '<td class="dataCol"  ><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input class="datetimepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + involvedPrtyId + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' + (isMilitaryTime ? mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy HH:mm')
													: mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().toString()));
						newHtmlFld  += '"';
					} else if (e.Required__c) {
						newHtmlFld += 'value="' + (isMilitaryTime ? Datetime.now().format('MM/dd/yyyy HH:mm')
													: Datetime.now().format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().toString()));
						newHtmlFld  += '"';
					}
					newHtmlFld +=  '/></div></div></td>';
				} else if (e.Field_Type__c == 'Multiselect') {
					String selectedVals;
					if (mapEvalValues.ContainsKey(e.id)){
						if (e.length__c > 250)
							selectedVals = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
						else
							selectedVals = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();
					}

					// get the options
					List<Eval_drop_Down__c> dropdownopts = ddOptions.get(e.id);
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;" id=' + e.htmlid__c + '>';
						if (e.Required__c) {
							newHtmlLbl = '<td class="text_right"><input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" /><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;width: 100%;" data-composite="' + e.Composite__c + '">' + e.field_name__c + '</label>';
							newHtmlLbl += reqFldHtml;
							newHtmlLbl +=  '</div></td>';
						}
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHtmlFld += '<input id="' + e.htmlid__c + thisdd.Option_Value__c.replaceAll('\\s','') + '" name="' + e.id + '" type="checkbox" value="' + thisdd.Option_Value__c + '" data-visibility-row-rules="' + thisdd.visibility_row_rules__c + '" data-visibility-rules="' + (String.IsNotBlank(thisdd.visibility_rules__c) ? updateRulesJSON(thisdd.visibility_rules__c, evalSectionId) : '') + '" data-rules="' + (String.IsNotBlank(thisdd.Dependent_Fields__c) ? updateRulesJSON(thisdd.Dependent_Fields__c, evalSectionId) : '') + '" data-composite="' + involvedPrtyId + '" ';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHtmlFld += ' checked ';

							newHtmlFld += '/>&nbsp<span>' + thisdd.Option_Name__c + '</span><br/>';
						}
						newHtmlFld +=  '</div></td>';
					} else {
						newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<select style="vertical-align: text-top" multiple="multiple" id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + involvedPrtyId + '">';
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHtmlFld += '<option value="' + thisdd.option_value__c + '"';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHtmlFld += ' selected ';

							newHtmlFld += '>' + thisdd.option_name__c + '</option>';
						}
						newHtmlFld += '</select></div></div></td>';
					}
				} else if (e.field_type__c == 'BodyMap') {
					newHtmlFld += '<td><div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
					newHtmlFld += '<img class="annotableImage" data-myannotations="'+ getAnnotations(involvedPrtyId, evalSectionId).escapeHtml4() +'" width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' +  GetResourceURL('WholeBodyNoGrid') + '?' + evalSectionId + '&' + involvedPrtyId + '" id="bodyMap' + evalSectionId + '" />';
					newHtmlFld += '</div>';
					newHtmlFld += '<div style="margin-left: 420px; height: 298px; overflow: auto;">';
					newHtmlFld += '<table id="annotations'+ evalSectionId + '">';
					newHtmlFld += '<tbody></tbody></table></div></td>';
				} 

				htmlControls.Add(newHtmlLbl);
				htmlControls.Add(newHtmlFld);
			} catch (Exception ex) {
				//throw new CustomException(ex);
				System.Debug(ex);
			}
		}

		String htmlTable = '<table data-composite="' + composite  + '" style="width:100%;" class="subCatTable"><tr><th style="width:20%;"></th><th style="width:30%;"></th><th style="width:15%;"></th><th style="width:25%;"></th></tr><tr>';

		Integer i = 0;
		for (String s : htmlControls){
			if (Math.mod(i, 4) == 0) {
				htmlTable += '</tr><tr class="border_bottom">';
			}
			htmlTable += s;
			i++;
		}

		return htmlTable;
	}
	
	private static String updateRulesJSON(String ruleStr, String sectionId){
		if (String.IsBlank(ruleStr)) return '';
        try {
	        String myUnscapedRuleStr = ruleStr.unescapeHtml4();
			map<String, list<String>> myVisibilityRules = new map<String, list<String>>();
			map<String, object> myDeserialized = (map<String, object> ) JSON.deserializeUntyped(myUnscapedRuleStr);
			for (String s : myDeserialized.keySet() ) {
				myVisibilityRules.put(s, new list<String>());
				list<Object>myTemp = (list<Object>) myDeserialized.get(s);
				for (Object o : myTemp){
						String absS = (String) o;
				   		myVisibilityRules.get(s).add(sectionId + absS);
				}
			}
			return JSON.serialize(myVisibilityRules).escapehtml4();
		}catch (Exception e) {
			return '';
		}
	} 
	
	private static map<String, list<Evaluation_Response__c>> invPrtyAnnotations = new map<String, list<Evaluation_Response__c>>();
	private static String getAnnotations (String invPrtyId, String subCatIdentifier){
		if (invPrtyAnnotations.isEmpty()) {
			invPrtyAnnotations.put('dummyKey', new list<Evaluation_Response__c>());
			
            for (Evaluation_Response__c e : [SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
		                                           Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
		                                           Annotation_Text__c, EvalValueSectionIdentifier__c, ImInvolvedPartyAnnotations__c
		                                      FROM Evaluation_Response__c WHERE ImInvolvedPartyAnnotations__c = :invPrtyId AND RecordType.Name = 'Annotation']){
                if (!invPrtyAnnotations.containsKey(e.EvalValueSectionIdentifier__c)) invPrtyAnnotations.put(e.EvalValueSectionIdentifier__c, new list<Evaluation_Response__c>{e});
                else invPrtyAnnotations.get(e.EvalValueSectionIdentifier__c).add(e);                                      	
            }
		}
		if (invPrtyAnnotations.containsKey(subCatIdentifier)) return json.serialize(invPrtyAnnotations.get(subCatIdentifier));            			
		else return '';
	}
	
	@RemoteAction
	public static Evaluation_Response__c addOrModifyAnnotation(ID annotationId, String source, Decimal x, Decimal y, Decimal Width, Decimal Height, String Shape, String Text, String parentId, String invPrtyId) {
		Evaluation_Response__c annotation;
		if (annotationId!=null) {
			annotation = [SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId];
		} else {
			annotation = new Evaluation_Response__c();
			annotation.ImInvolvedPartyAnnotations__c = invPrtyId;
            annotation.EvalValueSectionIdentifier__c = parentId;
			annotation.RecordTypeId = Utility.getEvaluationResponseRecordType('Annotation');
		}
		annotation.Annotation_Height__c = Height;
		annotation.Annotation_Width__c = Width;
		annotation.Annotation_X__c = x;
		annotation.Annotation_Y__c = y;
		annotation.Annotation_Source__c = Source;
		annotation.Annotation_Shape__c = Shape;
		annotation.Annotation_Text__c = Text;
		System.debug('Annotation to upsert: ' + annotation);
		upsert annotation;
		return annotation;
	}

	@RemoteAction
	public static void deleteAnnotation(ID annotationId) {
		delete [SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId];
	}
	
	
    private static String bodyMapUrl;
    public static String GetResourceURL(String resourceName) {
    	if (String.IsNotBlank(bodyMapUrl)) return bodyMapUrl; 
		List<StaticResource> resourceList = [
			SELECT Name, NamespacePrefix, SystemModStamp
			  FROM StaticResource
			 WHERE Name = :resourceName
		];
		if (resourceList.size() == 1) {
			String namespace = resourceList[0].NamespacePrefix;
			bodyMapUrl = '/resource/'
                    + resourceList[0].SystemModStamp.getTime() + '/'
                    + (namespace != null && namespace != '' ? namespace + '__' : '')
                    + resourceName;
			return bodyMapUrl;
		} else {
			return '';
		}
	}
 
 	public class FormKeyVal{
		public String name;
		public String value;
	}
	
 	@RemoteAction public static list<String> saveFields(Id involvedPrty, String jsonForm) {
 		Id involvedPrtyID = Id.ValueOf(involvedPrty);
		List<FormKeyVal> objs = (List<FormKeyVal>) JSON.deserialize(jsonForm, list<FormKeyVal>.class);
		
		Map<Id, String> evalIdToSectionId = new Map<Id, String>();
		for(Integer i = objs.size() - 1; i >= 0; i--) {
			String eval = objs[i].name;
			if (objs[i].name.indexOf('_esi') != -1) {
				eval = objs[i].name.substringBefore('_esi');
				try {
					evalIdToSectionId.put((Id) eval, objs[i].value);
				} catch (StringException ex) {
					System.debug(ex);
				}
				objs.remove(i);
				continue;
			}
			try {
				Id dummyId = (Id) objs[i].name;
			} catch (Exception ex) {
				objs.remove(i);
			}
		}
		
		Map<String,String> formData = new map<String, String>();
		// This is used to handle multi-select picklist
		String oldMapVal;
		for(FormKeyVal d : objs){
			oldMapVal = formData.put(d.name, d.value);
			if (oldMapVal != null && oldMapVal != '') {
				formData.put(d.name, oldMapVal +';'+ formData.get(d.name));
			}
		}

		Set<String> composites = new Set<String>();
		for (Eval__c eval: [ SELECT Id, Composite__c FROM Eval__c WHERE Id IN :formData.keySet() ]) {
			composites.add(eval.Composite__c);
		}

		Map<ID, Eval__c> mapEvalItems = new Map<ID, Eval__c>([
			SELECT Id, htmlid__c, field_name__c, category__c, category_sequence__c, sub_category__c,
			       sub_category_sequence__c, eval_type__r.name, Field_Type__c, Field_Sub_Type__c,
			       field_sequence__c, required__c, length__c, composite__c
			  FROM eval__c
			 WHERE eval_type__r.name = 'Involved Party'
			   AND Composite__c IN :composites
			   AND visible__c = true
			ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c
		]);
		// get any populated values for this eval and section
		List<Eval_Value__c> listEvalValues = Database.query('' +
			'SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c, ' +
			'       text_over_250__c, text_under_250__c, eval__c, eval_section_type__c, ' +
			'       eval__r.eval_type__r.name, eval__r.composite__c ' +
			'  FROM eval_value__c ' +
			' WHERE what_id__c = :involvedPrtyID ' +
			'   AND Eval__r.Composite__c IN :composites '
		);

		// create a map by eval id
		Map<ID, Eval_Value__c> mapEvalValues = new Map<ID, Eval_Value__c>();
		for (Eval_Value__c ev: listEvalValues) {
			mapEvalValues.put(ev.eval__c, ev);
		}

		List<Eval_Value__c> newValues = new List<Eval_Value__c>();
		List<Eval_Value__c> delValues = new List<Eval_Value__c>();

		// use the values already on the eval
		// check if data has changed
		Eval_Value__c ev;
		for (String f : formData.Keyset()) {
			// get the eval item from the map so we know what type, etc.
			Eval__c ei = mapEvalItems.get((ID)f);

			// construct new eval_value object
			if (mapEvalValues.containsKey((ID)f))  {
				// value exists - need to update value
				ev = (Eval_Value__c) mapEvalValues.remove((ID)f);
			} else {
				ev = new Eval_Value__c();
				ev.eval__c = (ID)f;
				ev.eval_Section_Id__c = evalIdToSectionId.get((Id)f);
				ev.Eval_Section_Type__c = 'Im_Incident';
				ev.what_id__c = involvedPrtyID;
				ev.what_id_object__c = 'Im_InvolvedParty__c';
			}

			system.debug(f);
			system.debug(ei);
			
			if (formData.get(f) != null && formData.get(f) != '') {
				// put the value in the right place
				if (ei.Field_Type__c == 'Boolean'){
					if (ei.Field_Sub_Type__c == 'Checkbox' || ei.Field_Sub_Type__c == 'Radio') {
						if (formData.get(f) == '1') {
							ev.Boolean__c = true;
						} else {
							ev.Boolean__c = false;
						}
					} else if (ei.Field_Sub_Type__c == 'Dropdown') {
						ev.Text_Under_250__c = formData.get(f);
					}
				} else if (ei.Field_Type__c == 'Int') {
					ev.Number_No_Decimal__c = Integer.valueOf(formData.get(f));
				} else if (ei.Field_Type__c == 'Date') {
					ev.Date_Time__c = Datetime.newInstance(Date.parse(formData.get(f)), Time.newInstance(0,0,0,0));
				} else if (ei.Field_Type__c == 'Datetime') {
					ev.Date_Time__c = (isMilitaryTime ? Utility.getDateTimeFromString(formData.get(f) +':00') : DateTime.parse(formData.get(f))); 
				} else if (ei.Field_Type__c == 'String' || ei.Field_Type__c == 'ID' ||
						ei.Field_Type__c == 'Multiselect' || ei.Field_Type__c == 'Dropdown' || ei.Field_Type__c == 'Double' ||
						ei.Field_Type__c == 'Currency') {
					if (ei.length__c > 250) {
						ev.Text_Over_250__c = formData.get(f);
					} else {
						ev.Text_Under_250__c = formData.get(f);
					}
				} else if (ei.Field_Type__c == 'Hidden') {
					if (ei.Field_Sub_Type__c == 'Boolean') ev.Boolean__c = Boolean.valueOf(formData.get(f));
					else if (ei.Field_Sub_Type__c == 'String') ev.Text_Over_250__c = formData.get(f);
				}
				newValues.add(ev);
			} else if (ev.id != null) {
				delValues.add(ev);
			}
		}

		for (ID evID : mapEvalValues.Keyset()){
			delValues.add((Eval_Value__c) mapEvalValues.get(evID));
		}
		
		delete delValues;
		upsert newValues;
		
		return getInvPrtyEvntDetails(String.ValueOf(involvedPrty)); 
	}

    @ReadOnly 
    @RemoteAction 
    public static String GetInvolvedPartyEventTypes(String invPrtyData){
        map<String, object> inputs = (Map<string, object>) json.deserializeUntyped(invPrtyData);
        Id invPrty = (Id) inputs.get('involvedParty');
        String invPrtyTyp = (String) inputs.get('involvedPartyType');
        if (invPrtyTyp.equalsIgnoreCase('Person Being Served')) invPrtyTyp = 'PBS';
        else if (invPrtyTyp.equalsIgnoreCase('Host Home Parent')) invPrtyTyp = 'Mentor';
        else if (invPrtyTyp.equalsIgnoreCase('Other Family Member')) invPrtyTyp = 'Other';
                        
        invPrtyTyp = '%' + invPrtyTyp + '%'; 
                        
        TMN_TreePktDocTable formTree = new TMN_TreePktDocTable();
        map<String, String> eventTypes = new map<String, String>();
        for(Eval__c e : [select Composite__c, category__c, sub_category__c 
                           from eval__c  
                          where eval_type__r.Name = 'Involved Party' 
                            and Visible__c = true 
                            //and HtmlId__c = 'IsValid' -cant use this since the invPrtyTyps isnt defined for this field
                            and Involved_Party_Type__c like : invPrtyTyp
                           order by cat_seq_text__c, subcat_seq_text__c]){
                            //if (!eventTypes.containsKey(e.Composite__c)) eventTypes.put(e.Composite__c, e.category__c + ' - ' + e.sub_category__c);
                            if (!eventTypes.containsKey(e.Composite__c)) eventTypes.put(e.Composite__c, e.sub_category__c); // they want only the subCat
        }
        //remove the ones that are already on this involved party
        list<Eval_Value__c> existinEvntTyps = [SELECT eval__r.Composite__c FROM eval_value__c 
                                                WHERE what_id__c = : invPrty 
                                                and eval__r.Visible__c = true and eval__r.HtmlId__c = 'IsValid'];
                                                
        //can not add anything else if one has Injury OR law enforcement                        
        for (Eval_value__c ev : existinEvntTyps){
            if (ev.eval__r.Composite__c.equalsIgnoreCase('Involved Party~Behavioral~Law Enforcement Involvement') ||
                    ev.eval__r.Composite__c.equalsIgnoreCase('Involved Party~All Others~Injury')){
                    eventTypes = new map<String, String>();
                    break;
            }
            eventTypes.remove(ev.eval__r.Composite__c); // remove the ones already added
        }
        //if there is one that means i can not add Injury OR law enforcement
        if (existinEvntTyps.size() > 0 && eventTypes.keySet().size() > 0){
            if (eventTypes.containsKey('Involved Party~Behavioral~Law Enforcement Involvement')) eventTypes.remove('Involved Party~Behavioral~Law Enforcement Involvement');
            if (eventTypes.containsKey('Involved Party~All Others~Injury')) eventTypes.remove('Involved Party~All Others~Injury');  
        }
                        
        for(String s : eventTypes.keySet()){
            TMN_TreePktDocTable.node eNode = new TMN_TreePktDocTable.node(s, eventTypes.get(s));
            formTree.root.children.add(eNode);
        }
        return JSON.serialize(formTree.root.children);
    }
	
    @ReadOnly 
    @RemoteAction 
    public static map<string, object> validateEvent(String eventId){
        map<string, object> validationResults = new map<string, object>{'goodToSubmit' => false, 'validationErrors' => ''};
        list<String> myValidationErrors = new list<String>();
        
        map<id, Im_InvolvedParty__c> invPrties = new map<id, Im_InvolvedParty__c>([select Id, type__c, name, Person_Being_Served_Involved__r.pbsFirstName__c, 
				                                         Person_Being_Served_Involved__r.pbsLastName__c, Staff_Involved__r.name
                                                    from Im_InvolvedParty__c where Im_incident__c =: eventId]);
        if (invPrties.keySet().size() == 0) {
        	myValidationErrors.add('There are no involved parties added. At least one involved party with all the event types associated is required. Please update and try again.');
        	validationResults.put('validationErrors', myValidationErrors);
        	return validationResults;
        } 
        map<String, list<Eval_Value__c>> sectionsMap = new map<String, list<Eval_Value__c>>();
        list<Eval_Value__c> evalVals = [SELECT id, boolean__c, text_over_250__c,
                                          eval__c, eval__r.sub_category__c, 
                                          eval_section_id__c, eval__r.htmlId__c, what_id__c 
                                     FROM Eval_Value__c
                                    WHERE eval__r.Visible__c = true
                                      AND what_id__c IN : invPrties.keySet()
                                      AND (eval__r.htmlId__c = 'ErrorMsg' OR eval__r.htmlId__c = 'IsValid')
                                    order by what_id__c, eval__r.category_sequence__c, eval__r.sub_category_sequence__c, eval__r.Field_sequence__c];
        if (evalVals.size() == 0) {
            myValidationErrors.add('At least one event type is required for each involved party. Please update and try again.');
            validationResults.put('validationErrors', myValidationErrors);
            return validationResults;
        } 

        set<Id> invPartiesWithEvalVal = new set<Id>();
        for (Eval_Value__c value: evalVals) {
            if (!sectionsMap.containsKey(value.eval_section_id__c)) sectionsMap.put(value.eval_section_id__c, new list<Eval_Value__c>{value});
            else sectionsMap.get(value.eval_section_id__c).add(value);
            
            invPartiesWithEvalVal.add((Id)value.what_id__c);
        }
        
        set<Id> invPrtiesIdClone = invPrties.keySet().clone();
        invPrtiesIdClone.removeAll(invPartiesWithEvalVal);
        if (invPrtiesIdClone.size() > 0){
            myValidationErrors.add('At least one event type is required for each involved party. No events found for following involved parties:');
            for (Id i : invPrtiesIdClone){
                myValidationErrors.add(invPrties.get(i).type__c + ' - ' + invPrties.get(i).name);
            }
            validationResults.put('validationErrors', myValidationErrors);
            return validationResults;
        	
        }
                
        for(String section : sectionsMap.keySet()){
        	list<Eval_Value__c> values = sectionsMap.get(section);
            if (values.size() == 1 && values[0].boolean__c == false){ // user never saved the event details
                Eval_Value__c ev = values[0];
            	myValidationErrors.add(invPrties.get(ev.what_id__c).Type__c + ' - ' +  invPrties.get(ev.what_id__c).Name + '. Event details not filled for : ' + ev.eval__r.sub_category__c);
            }
        	if (values.size() > 1 && values[0].boolean__c == false && String.IsNotBlank(values[1].text_over_250__c) ){ // user saved the event but there were errors
                Eval_Value__c ev = values[1];
                myValidationErrors.add(invPrties.get(ev.what_id__c).Type__c + ' - ' +  invPrties.get(ev.what_id__c).Name + '. Missing required fields for event : ' + ev.eval__r.sub_category__c);
        	}
        }
        if (myValidationErrors.size() > 0){
	        validationResults.put('validationErrors', myValidationErrors);
	        return validationResults;
        }
        
        validationResults.put('goodToSubmit', true);
        return validationResults;
    }
	
    public list<SelectOption> getMyService_Locations(){
        list<SelectOption> programslist = new list<SelectOption>();
        if (parentCntrller != null &&  String.isEmpty(parentCntrller.incident.event.Service_Location)) programslist.add(new SelectOption('','') );
        list<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                         FROM service_assignment__c
                                         GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                         HAVING COUNT(service_location__r.id) > 0
                                         ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        return programslist;
    }
    public MyRemoteMethods(TxnQueueResponseController controller){
    	this.parentCntrller = controller;
    }
    public MyRemoteMethods(){}
    
    class SelOption {
        String id;
        String text;
        String email;
        String jobTitle;
        sobject obj;
        SelOption(sobject obj){
            this.id = String.valueOf(obj.get('Id'));
			if (obj instanceof TMN_User__c){
            	TMN_User__c tmnUser = (TMN_User__c) obj;
	            this.text = tmnUser.name;
	            this.email = tmnUser.email__c;
	            this.jobTitle = tmnUser.job_title__c;
            }
            else if (obj instanceof Service_Assignment__c){
            }
            this.obj = obj;
        }
    }
    
    @RemoteAction public static list<SelOption> getPBSFortheProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }
        Id sl = ( (Id) values.get('programLocation') );
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        map<Id, Service_Assignment__c> pbsSASet = new map<Id, Service_Assignment__c>();

        list<Service_Assignment__c> sAs = [select Id, person_being_served__c, pbsLastName__c, pbsFirstName__c, person_being_served__r.Age_Text__c, person_being_served__r.Gender__c 
        									 from Service_Assignment__c 
        									where service_location__c =: sl and Status__c = 'Active' 
        									 and (pbsFirstName__c like : searchTerm OR pbsLastName__c like : searchTerm) order by Name];
		for(Service_Assignment__c sa : sAs){
			pbsSASet.put(sa.person_being_served__c, sa);
			retVal.add(new SelOption(sa));
		}        
        for(Attachment headShot : [SELECT Id, Name,  ParentId from Attachment where Name LIKE 'HeadShot-Current%' and ParentId IN : pbsSASet.keySet()]){
			Service_Assignment__c sa = (Service_Assignment__c) pbsSASet.get(headShot.ParentId);
			//chose a dummy field on the SA object to carrry the pbs headShot attachment id 
			sa.Flavor__c = '/servlet/servlet.FileDownload?file=' + headShot.id;
        }        
        return retVal;
    }
    
        
    class CustomException extends Exception {}
    
    @RemoteAction public static list<SelOption> getStaffFortheProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }   
        Id sl = ( (Id) values.get('programLocation') );
        Id aliasForPrgram = [select Alias_lookup__c from Service_Location__c where id =: sl limit 1].Alias_lookup__c;
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        // get the list of tmn users for the alias based on the service location user must have proviced to call this method else throw exception.  
        for (TMN_User__c t : [select Id, Name, email__c, job_title__c from TMN_User__c where Alias_Lookup__c =: aliasForPrgram and Job_Status__c = 'Active' and Name like : searchTerm order by Name]){
            retVal.add(new SelOption(t));
        } 
        //return JSON.serialize(retVal);
        return retVal;
    }
    
    @RemoteAction public static list<SelOption> getEventReviewerForProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }   
        Id sl = ( (Id) values.get('programLocation') );
        Id aliasForPrgram = [select Alias_lookup__c from Service_Location__c where id =: sl limit 1].Alias_lookup__c;
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        // get the list of tmn users for the alias based on the service location user must have proviced to call this method else throw exception.  
        for (TMN_User__c t : [select Id, Name, email__c, job_title__c from TMN_User__c 
                              where Salesforce_User_Account__c != null 
                              and Salesforce_User_Account__c !=: UserInfo.getUserId()
                              and Job_Status__c = 'Active' 
                              and Alias_Lookup__c =: aliasForPrgram
                              and Approval_Level__c > 2 
                              and Name like : searchTerm 
                              order by Name] ){
                                  retVal.add(new SelOption(t));
                              } 
        //return JSON.serialize(retVal);
        return retVal;
    }
    
}