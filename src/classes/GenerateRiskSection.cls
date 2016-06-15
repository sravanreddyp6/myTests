public with sharing class GenerateRiskSection {
	
	
	public string cat { get; set; }
	public string subcat{ get; set; }
	public string subsubcat{ get; set; }
	public string evalname{ get; set; }
	public Boolean showActionButtons { get; set; }
	public Boolean editable { get; set; }
	//public string evalSectionUuidForBodyMap { get; set; }

	/*public ID evaluationID {
		get;
		set {
			evaluationId = value;
			if (evaluationId != null) {
				serviceAssignmentId = [
					SELECT ServiceAssignment__c FROM Evaluation__c WHERE Id=:evaluationId
				].ServiceAssignment__c;
			}
		}
	}*/
	
	public ID casemanagementID {
		get;
		set {
			casemanagementID = value;
			if (casemanagementID != null) {
				serviceAssignmentId = [
					SELECT Service_Assignment__c FROM Case_management_Plan__c WHERE Id=:casemanagementID
				].Service_Assignment__c;
			}
		}
	}
	
	public Id serviceAssignmentId { get; set; }
	public string evalSectionId { get; set; }
	public string evalSecType { get; set; }
	
	
	@TestVisible private string getEvalSectionOwner(){
		String str = '';
		if (evalSectionId == null || evalSectionId == ''){
			str = UserInfo.getName();
		}else {
			try{
				str = [SELECT name FROM user WHERE id = :evalSectionId.split('-').get(0)].get(0).Name;
				str += ' @ ';
				str += DateTime.newInstance(Long.valueOf(evalSectionId.split('-').get(1))).format('MM/dd/yyyy HH:mm');
			} catch (Exception e){
				System.debug(e);
			}
		}
		return str;
	}

	private string getEvalSectionLastMod() {
		String str = '';
		if (String.IsBlank(evalSectionId))
			return str;
		else {
			try {
				List<Eval_Value__c> evs = [
					SELECT lastmodifieddate, lastmodifiedby.name
					  FROM eval_value__c
					 WHERE eval_section_id__c = :evalSectionId
					ORDER BY lastmodifieddate DESC
					 LIMIT 1];
				if (evs.size() == 1) {
					return evs[0].lastmodifiedby.name + ' @ ' +  evs[0].lastmodifieddate.format('MM/dd/yyyy HH:mm');
				} else {
					return str;
				}
			} catch (Exception e) {
				system.debug(e);
				return '';
			}
		}
	}


	public static Map<ID, Eval__c> mapEvalItems;
	public static Map<ID, Eval_Value__c> mapEvalValues;
	

	public GenerateRiskSection() {
		mapEvalItems = new Map<ID, Eval__c>();
		mapEvalValues = new Map<ID, Eval_Value__c>();
	}

	public List<String> getComposites() {
		return generateForm();
	}
	public transient Map<String, String> compositeToHtmlMap { get; set; }
	public transient Map<String, String> compositeToHeaderMap {get; set; }
	public transient Map<String, String> compositeToSectionTypeMap { get; set; }
	public transient Integer numSection { get; set; }
	public Boolean batchInsert { get; set; }
	public Boolean batchUpsert { get; set; }

	
	public List<String> generateForm() {
		List<String> composites = new List<String>();
		compositeToHtmlMap = new Map<String, String>();
		compositeToHeaderMap = new Map<String, String>();
		compositeToSectionTypeMap = new Map<String, String>();

		List<Eval__c> listEvalItems;
		String additionalCondition = '';
		if (!batchInsert && !batchUpsert) {
			additionalCondition += 'AND Sub_Category__c = :subcat ';
		}

		listEvalItems = Database.query(
			'SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c, ' +
			'       sub_category__c, sub_category_sequence__c, eval_type__r.name, Field_Type__c, ' +
			'       Field_Sub_Type__c, field_sequence__c, required__c, Length__c, Visible__c, ' +
			'       visibility_rules__c, visibility_row_rules__c, Dependent_Fields__c, Composite__c ' +
			'  FROM eval__c ' +
			' WHERE eval_type__r.name = :evalname ' +
			'   AND category__c =:cat ' +
			additionalCondition +
			'ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c'
		);
		List<String> evalIds = new List<String>();
		Map<String, List<Eval__c>> sectionMap = new Map<String, List<Eval__c>>();
		Set<String> repeatables = new Set<String>();
		for (Eval__c eval: listEvalItems) {
			if (eval.Visible__c) {
				evalIds.add(eval.Id);
				if (!sectionMap.containsKey(eval.Composite__c)) {
					sectionMap.put(eval.Composite__c, new List<Eval__c>());
					composites.add(eval.Composite__c);
					compositeToHtmlMap.put(eval.Composite__c, 'N/A');
					compositeToHeaderMap.put(eval.Composite__c, eval.Sub_Category__c);
				}
				sectionMap.get(eval.Composite__c).add(eval);
			} else if (eval.Field_Name__c == 'isRepeatable') {
				repeatables.add(eval.Composite__c);
			}
		}
		List<Eval_Drop_Down__c> dd = [
			SELECT whatid__c, option_name__c, option_value__c, Dependent_Fields__c,
			       visibility_row_rules__c, visibility_rules__c
			  FROM eval_drop_down__c
			 WHERE What_Id_Object__c = 'Eval__c'
			   AND whatid__c in :evalIds
			ORDER BY whatid__c, Sequence__c
		];
		// get any populated values for this eval and section
		// The query to get these populated values can potentially run VERY slow, so we'll
		// optimize by not running it when we KNOW it's not necessary (e.g. when we're doing insert)
		List<Eval_Value__c> listEvalValues = new List<Eval_Value__c>();
		if (batchInsert || batchUpsert || evalSectionId != '') {
			listEvalValues = Database.query(
				'SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c, ' +
				'       text_over_250__c, text_under_250__c, eval__c, eval__r.length__c, ' +
				'       eval__r.composite__c, eval_section_type__c, eval__r.eval_type__r.name, ' +
				'       eval_section_id__c ' +
				'  FROM eval_value__c '+
				' WHERE eval__c in :listEvalItems ' +
				'   AND eval__r.Visible__c = true ' +
				'   AND what_id__c = :casemanagementID ' +
				((batchInsert || batchUpsert) ? '' :'   AND eval_Section_Id__c = :evalSectionId ') + // We don't need to fill in the values for batch insert, but we do need to figure out whether a section should be bypassed or not
				(batchUpsert ? '   AND eval_section_type__c = :evalName' : '')
			);
		}
		Set<String> sectionsToBypass = new Set<String>();
		Map<Id, Eval_Value__c> evalIdToValueMap = new Map<Id, Eval_Value__c>();
		for (Eval_Value__c value: listEvalValues) {
			evalIdToValueMap.put(value.Eval__c, value);
			/* remove this rule 
			if (!repeatables.contains(value.Eval__r.Composite__c)) {
				if (batchInsert) {
					sectionsToBypass.add(value.Eval__r.Composite__c);
				}
			}
			*/
			/* remove this rule ... people can co-edit the risk plan */
			/*
			if (batchUpsert) {
				if (value.Eval_Section_Id__c.split('-')[0] != UserInfo.getUserId()) {
					sectionsToBypass.add(value.Eval__r.Composite__c);
				}
			}
			*/
		}
		Component.Apex.OutputPanel fullPanel = new Component.Apex.OutputPanel(layout='none');

		numSection = 0;
		if ((evalSectionId == '' || evalSectionId == null) && !batchUpsert) {
			evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
		}
		for (String composite: sectionMap.keySet()) {
			if (batchInsert) {
				if (!sectionsToBypass.contains(composite)) {
					numSection ++;
					evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
					compositeToHtmlMap.put(composite, generateSubsection(sectionMap.get(composite), dd, new List<Eval_Value__c>(), evalSectionId));
				}
			} else if (batchUpsert) {
				if (!sectionsToBypass.contains(composite)) {
					numSection ++;
					String sectionId = 	UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
					for (Eval__c eval: sectionMap.get(composite)) {
						if (evalIdToValueMap.containsKey(eval.Id)) {
							sectionId = evalIdToValueMap.get(eval.Id).Eval_Section_Id__c;
							break;
						}
					}
					compositeToHtmlMap.put(composite, generateSubsection(sectionMap.get(composite), dd, listEvalValues, sectionId));
				}
			} else {
				numSection ++;
				compositeToHtmlMap.put(composite, generateSubsection(sectionMap.get(composite), dd, listEvalValues, evalSectionId));
			}
		}
		compositeToSectionTypeMap = determineSectionTypes(listEvalItems, listEvalValues, evalSecType, batchInsert, batchUpsert);

		
		for (Eval__c eval: listEvalItems) {
			if (sectionsToBypass.contains(eval.Composite__c)) {
				continue;
			}
		}
		return composites;
	}

	private static Map<String, String> determineSectionTypes(List<Eval__c> listEvalItems, List<Eval_Value__c> listEvalValues, String evalSecType, Boolean batchInsert, Boolean batchUpsert) {
		Map<String, String> compositeToSectionTypeMap = new Map<String, String>();
		if (evalSecType != null && evalSecType != '') {
			for (Eval__c eval: listEvalItems) {
				compositeToSectionTypeMap.put(eval.Composite__c, evalSecType);
			}
			return compositeToSectionTypeMap;
		}

		for (Eval__c eval: listEvalItems) {
			compositeToSectionTypeMap.put(eval.Composite__c, eval.Eval_Type__r.Name);
		}
		if (batchUpsert) {
			return compositeToSectionTypeMap;
		}
		Set<String> compositesWithMainEntry = new Set<String>();
		for (Eval_Value__c value: listEvalValues) {
			if (compositesWithMainEntry.contains(value.Eval__r.Composite__c)) {
				continue;
			}
			if (value.Eval_Section_Type__c == value.Eval__r.Eval_Type__r.Name) {
				compositesWithMainEntry.add(value.Eval__r.Composite__c);
				compositeToSectionTypeMap.put(value.Eval__r.Composite__c, 'Activity Log');
			}
		}
		return compositeToSectionTypeMap;
	}

	private String generateSubsection(List<Eval__c> listEvalItems, List<Eval_Drop_Down__c> dd, List<Eval_Value__c> listEvalValues, String evalSectionId) {
		// get the list of controls for this type, category, and subcategory
		List<String> htmlControls = new List<String>();

		Map<ID, List<Eval_Drop_Down__c>> ddOptions = new Map<ID, List<Eval_Drop_Down__c>>();

		// create a map for easy access
		mapEvalItems = new Map<ID, Eval__c>(listEvalItems);

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

		// create a map by eval id
		mapEvalValues = new Map<ID, Eval_Value__c>();
		for (Eval_Value__c ev: listEvalValues) {
			mapEvalValues.put(ev.eval__c, ev);
		}

		String newHtmlLbl = '';
		String newHtmlFld = '';
		String strval = '';
		String reqFldHtml = '';
		String subcategory = '';  // Assumption: this is all part of the same subcategory
		String sectionComposite = '';
		Id notApplicableFieldId;
		Id isValidFieldId;
		/*Set<String> fieldsWithPreviousEntries = new Set<String>();
		for (Set<String> association: previousEntryAssociation) {
			fieldsWithPreviousEntries.addAll(association);
		}*/
		for(Eval__c e : listEvalItems){
			try {
				subcategory = e.Sub_Category__c;
				sectionComposite = e.Composite__c;
				newHtmlLbl = '<td class="text_right">';
				newHtmlLbl += '<input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" />';
				newHtmlLbl += '<label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label></td>';
				newHtmlFld = '';
				strval = '';
				String composite = String.format('{0}%{1}%{2}%{3}', new List<String>{
					e.eval_type__r.name,
					e.category__c,
					e.sub_category__c,
					e.htmlid__c
				});
				String prevEntryStr = '';
				/*if (fieldsWithPreviousEntries.contains(composite)) {
					prevEntryStr += ' data-previous-entry="' + composite + '"';
				}*/
				if (e.Required__c) {
					reqFldHtml = '<div class="requiredInput" style="display: table-cell;"' + prevEntryStr + '><div class="requiredBlock"></div>';
				} else {
					reqFldHtml = '<div style="display: table-cell;"'+ prevEntryStr +'>';
				}


				if (e.Field_Type__c == 'Hidden')  {
					if (e.HtmlId__c == 'NotApplicable') {
						// This is a special field that is shown in the header, so we'll suppress
						// showing it here
						notApplicableFieldId = e.Id;
						continue;
					} else {
						if (e.HtmlId__c == 'IsValid') {
							isValidFieldId = e.Id;
						}
						newHtmlLbl = '<td><input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" /></td> ';  // an emtpy col for the hidden fields so that their labes wont show up on the form
						newHtmlFld += '<td class="dataCol"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="hidden" data-composite="' + e.Composite__c + '" ';
						if (mapEvalValues.ContainsKey(e.id)) {
							newHtmlFld += 'value="' ;
							if (e.Field_Sub_Type__c == 'Boolean') {
								newHtmlFld += mapEvalValues.get(e.id).boolean__c;
							} else if (e.Field_Sub_Type__c == 'String') {
								newHtmlFld += mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
							}
						}
						newHtmlFld += '"/></td>';
					}

				} else if (e.Field_Type__c == 'Boolean')  { // Boolean can be Checkbox, Radio, or Dropdown
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="checkbox" value="' + 1 + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + e.Composite__c + '" ';

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
						newHtmlFld += '<select  id="' + e.htmlid__c + '" name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + e.Composite__c + '">';
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
						newHtmlFld += '<td class="dataCol" style="vertical-align: top" ><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<textarea  id="' + e.htmlid__c + '"  name="' + e.id + '" data-composite="' + e.Composite__c + '">';
						if (mapEvalValues.ContainsKey(e.id)) {
							strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
							if (strVal != null && strVal != '')
								newHtmlFld += strVal;
						}
						newHtmlFld +=  '</textarea></div></div></td>';

					} else {
						newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<input  id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + e.Composite__c + '" ';
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
					newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + e.Composite__c + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' ;
						if (mapEvalValues.get(e.id).eval__r.length__c == null || mapEvalValues.get(e.id).eval__r.length__c < 250) {
							strVal = mapEvalValues.get(e.id).Text_Under_250__c.escapeHtml4();
						} else {
							strVal = mapEvalValues.get(e.id).Text_Over_250__c.escapeHtml4();
						}

						if (strVal != null && strVal != '')
							newHtmlFld += strVal;

						newHtmlFld += '"';
					}
						newHtmlFld +=  '/>';
					//}
					newHtmlFld += '</div></div></td>';

				} else if (e.Field_Type__c == 'Int'){
					newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input  pattern="[0-9]+" title="Please enter a valid number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + e.Composite__c + '" ';
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
					newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<select id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + e.Composite__c + '">';
					newHtmlFld += '<option value="">-- None --</option>';
					for (Eval_Drop_Down__c thisdd : dropdownopts) {
						newHtmlFld += '<option value="' + thisdd.option_value__c + '"';
						if (strval ==  thisdd.option_value__c)
							newHtmlFld += ' selected ';

						newHtmlFld += '>' + thisdd.option_name__c + '</option>';
					}
					newHtmlFld += '</select></div></div></td>';
				}  else if (e.Field_Type__c == 'Date') {
					newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input class="datepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + e.Composite__c + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' + mapEvalValues.get(e.id).date_time__c.date().format();
						newHtmlFld  += '"';
					}
					newHtmlFld +=  '/></div></div></td>';
				} else if (e.Field_Type__c == 'Datetime') {
					newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHtmlFld += reqFldHtml;
					newHtmlFld += '<input class="datetimepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" data-composite="' + e.Composite__c + '" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += 'value="' + mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy HH:mm');
						newHtmlFld  += '"';
					} else if (e.Required__c) {
						newHtmlFld += 'value="' + Datetime.now().format('MM/dd/yyyy HH:mm');
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
							newHtmlLbl = '<td class="text_right"><input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" /><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;" data-composite="' + e.Composite__c + '">' + e.field_name__c + '</label>';
							newHtmlLbl += reqFldHtml;
							newHtmlLbl +=  '</div></td>';
						}
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHtmlFld += '<input id="' + e.htmlid__c+thisdd.Option_Value__c.replaceAll('\\s','') + '" name="' + e.id + '" type="checkbox" value="' + thisdd.Option_Value__c + '" data-visibility-row-rules="' + thisdd.visibility_row_rules__c + '" data-visibility-rules="' + thisdd.visibility_rules__c + '" data-rules="' + thisdd.Dependent_Fields__c + '" data-composite="' + e.Composite__c + '" ';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHtmlFld += ' checked ';

							newHtmlFld += '/>&nbsp<span>' + thisdd.Option_Name__c + '</span><br/>';
						}
						newHtmlFld +=  '</div></td>';
					} else {
						newHtmlFld += '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
						newHtmlFld += reqFldHtml;
						newHtmlFld += '<select style="vertical-align: text-top" multiple="multiple" id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '" data-composite="' + e.Composite__c + '">';
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHtmlFld += '<option value="' + thisdd.option_value__c + '"';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHtmlFld += ' selected ';

							newHtmlFld += '>' + thisdd.option_name__c + '</option>';
						}
						newHtmlFld += '</select></div></div></td>';
					}
				}
				htmlControls.Add(newHtmlLbl);
				htmlControls.Add(newHtmlFld);
			} catch (Exception ex) {
				System.Debug(ex);
			}
		}

		String selector = String.format(
			'input{0}, select{0}, textarea{0}',
			new String[] {
				'[data-composite=\'' + sectionComposite + '\']:not(#NotApplicable)'
			}
		);
		String notApplicableField = '';
		String isValidField = '';

		if (notApplicableFieldId != null) {
			String checked = '';
			if (mapEvalValues.containsKey(notApplicableFieldId) && mapEvalValues.get(notApplicableFieldId).Boolean__c) {
				checked = 'checked';
			}
			notApplicableField = '<input type="hidden" name="' + notApplicableFieldId + '_esi" value="' + evalSectionId + '"><input id="NotApplicable" name="' + notApplicableFieldId + '" type="checkbox" value="true" ' + checked + ' data-composite="' + sectionComposite + '" style="margin-right: 3px; " data-rules="{&quot;0&quot;: &quot;' + selector + '&quot;}" /><span>Not Applicable</span>';
		}
		String header = String.format(
			'<table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="pbTitle"><h2 class="mainTitle">{0}</h2></td><td style="text-align: right;">{1}{2}</td></tr></tbody></table>',
			new String[]{
				subcategory,
				notApplicableField,
				isValidField
			});
		compositeToHeaderMap.put(sectionComposite, header);

		Component.Apex.OutputText outputText = new Component.Apex.OutputText(escape=false);

	/*	String htmlTable2 = '<label class="labelCol">Created By:</label>' + getEvalSectionOwner() + '<br />' +
			'<label class="labelCol">Last Modified By:</label>' + getEvalSectionLastMod();*/
			
		String htmlTable2 ='';
		String composite = cat + '~' + subCategory;
		 
		htmlTable2 += '<table data-composite="' + composite  + '" style="width:100%;"><tr><th style="width:15%;"></th><th style="width:25%;"></th><th style="width:15%;"></th><th style="width:25%;"></th></tr><tr>';
		
		Integer i = 0;
		for (String s : htmlControls){
			if (Math.mod(i, 2) == 0) {
				htmlTable2 += '</tr><tr class="border_bottom">';
			}
			htmlTable2 += s;
			i++;
		}
		htmlTable2 += '</tr></table>';

		return htmlTable2;
	}

	public class FormKeyVal{
		public String name;
		public String value;
	}

	@RemoteAction
	public static void saveFields(ID evalId, String evalSectionId, String evalSectionType, String EvalType, String jsonForm, Boolean batchInsert, Boolean batchUpsert) {
		// Deserialize the form
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

		mapEvalItems = new Map<ID, Eval__c>([
			SELECT Id, htmlid__c, field_name__c, category__c, category_sequence__c, sub_category__c,
			       sub_category_sequence__c, eval_type__r.name, Field_Type__c, Field_Sub_Type__c,
			       field_sequence__c, required__c, length__c, composite__c
			  FROM eval__c
			 WHERE eval_type__r.name = :EvalType
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
			' WHERE what_id__c = :evalId ' +
			'   AND what_id_object__c = \'Case_management_Plan__c\' ' +
			'   AND Eval__r.Composite__c IN :composites ' +
			(batchInsert ? '' : '   AND eval_Section_Id__c IN ' + String.format( '(\'\'{0}\'\')', new List<String> { String.join( evalIdToSectionId.values() , '\',\'') }))
		);

		// create a map by eval id
		mapEvalValues = new Map<ID, Eval_Value__c>();
		for (Eval_Value__c ev: listEvalValues) {
			mapEvalValues.put(ev.eval__c, ev);
		}

		Map<String, String> sectionTypeMap = determineSectionTypes(mapEvalItems.values(), listEvalValues, evalSectionType, batchInsert, batchUpsert);

		List<Eval_Value__c> newValues = new List<Eval_Value__c>();
		List<Eval_Value__c> delValues = new List<Eval_Value__c>();
		//Datetime evalShiftStartTime = [select Shift_Start_Time__c from Evaluation__c where ID = :evalId limit 1].Shift_Start_Time__c;

		// For normal panels, the isValid field is determined on the client side; which means that
		// if a N/A field is selected it can change isValid to true using JS. However, for certain
		// panels with use custom component (e.g. restraint reduction), we need to update the
		// isValid field in the backend, since that field is now based on multiple checks that are
		// harder to do on the client side. We use the following map to achieve this.
		Map<String, Eval_Value__c> isValidToEvalValueMap = new Map<String, Eval_Value__c>();

		// use the values already on the eval
		// check if data has changed
		Eval_Value__c ev;
		for (String f : formData.Keyset()) {
			// get the eval item from the map so we know what type, etc.
			Eval__c ei = mapEvalItems.get((ID)f);

			// construct new eval_value object
			if (mapEvalValues.containsKey((ID)f) && (!batchInsert || batchUpsert))  {
				// value exists - need to update value
				ev = (Eval_Value__c) mapEvalValues.remove((ID)f);
			} else {
				ev = new Eval_Value__c();
				ev.eval__c = (ID)f;
				ev.eval_Section_Id__c = evalIdToSectionId.get((Id)f);
				ev.Eval_Section_Type__c = (batchInsert || batchUpsert) ? sectionTypeMap.get(ei.Composite__c) : evalSectionType;
				ev.what_id__c = evalID;
				ev.what_id_object__c = 'Case_Management_Plan__c';
			}

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
					ev.Date_Time__c = Utility.getDateTimeFromString(formData.get(f) +':00');
				} else if (ei.Field_Type__c == 'String' || ei.Field_Type__c == 'ID' ||
						ei.Field_Type__c == 'Multiselect' || ei.Field_Type__c == 'Dropdown' || ei.Field_Type__c == 'Double' ||
						ei.Field_Type__c == 'Currency') {
					if (ei.length__c > 250) {
						ev.Text_Over_250__c = formData.get(f);
					} else {
						ev.Text_Under_250__c = formData.get(f);
					}
				} else if (ei.Field_Type__c == 'Hidden') {
					if (ei.Field_Sub_Type__c == 'Boolean') {
						
						Boolean isValid = (ei.HtmlId__c == 'IsValid');
						Boolean notApplicable = (ei.HtmlId__c == 'NotApplicable');
						ev.Boolean__c = Boolean.valueOf(formData.get(f));
					} else if (ei.Field_Sub_Type__c == 'String') {
						ev.Text_Over_250__c = formData.get(f);
					}
				}
				newValues.add(ev);
			} else if (ev.id != null) {
				delValues.add(ev);
			}
		}

		for (ID evID : mapEvalValues.Keyset()){
			delValues.add((Eval_Value__c) mapEvalValues.get(evID));
		}

		if (!batchInsert) {
			// We never delete values when doing a batch insert
			delete delValues;
		}
		upsert newValues;
	}

	public class InvalidDateTimeValException extends Exception{
	}



	public class EvalValue {
		public String value { get; set; }
		public Id casemanagementID {get; set;}
		public Id evaluationId { get; set; }
		public String lastModifiedDate { get; set; }
		public Eval_Value__c evalValueSObject { get; set; }

		public EvalValue(Eval_Value__c evalValue) {
			// This class is used as a wrapper for an Eval_Value__c, mainly for easier transport
			// as JSON serialization. BEWARE: the class does NOT escape the output by the user,
			// so you *HAVE TO* escape the output before displaying the value, otherwise you'll be
			// vulnerable to XSS attacks. Right now the JSON is used in conjunction with qtip2,
			// which automatically escapes outputs.
			casemanagementID = evalValue.What_Id__c;
			value = evalValue.Text_Under_250__c;
			lastModifiedDate = evalValue.LastModifiedDate.format('MM/dd/yyyy HH:mm');
			evalValueSObject = evalValue;
			if (evalValue.Eval__r.Field_Type__c == 'Boolean')  {
				if (evalValue.Eval__r.Field_Sub_Type__c == 'Checkbox') {
					if (evalValue.Boolean__c) {
						value = 'Yes';
					} else {
						value = 'No';
					}
				} else if (evalValue.Eval__r.Field_Sub_Type__c == 'Dropdown') {
					if (evalValue.Text_Under_250__c == '1') {
						value = 'Yes';
					} else {
						value = 'No';
					}
				}
			} else if (evalValue.Eval__r.Field_Type__c=='String') {
				if (evalValue.Eval__r.length__c > 250) {
					value = evalValue.Text_Over_250__c;
				} else {
					value = evalValue.Text_Under_250__c;
				}
			} else if (evalValue.Eval__r.Field_Type__c == 'Double'){
				value = evalValue.Text_Under_250__c;
			} else if (evalValue.Eval__r.Field_Type__c == 'Int'){
				value = String.valueOf(evalValue.Number_No_Decimal__c);
			} else if (evalValue.Eval__r.Field_Type__c == 'DropDown') {
				value = evalValue.Text_Under_250__c;
			}  else if (evalValue.Eval__r.Field_Type__c == 'Date') {
				value = evalValue.Date_Time__c.date().format();
			} else if (evalValue.Eval__r.Field_Type__c == 'Datetime') {
				value = evalValue.Date_Time__c.format('MM/dd/yyyy HH:mm');
			} else if (evalValue.Eval__r.Field_Type__c == 'Multiselect') {
				if (evalValue.Eval__r.length__c > 250) {
					value = evalValue.Text_Over_250__c;
				} else {
					value = evalValue.Text_Under_250__c;
				}
			}
		}
	}
    
}