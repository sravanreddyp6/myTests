/*
Fields type - sub types that are not yet handelled:
    Boolean - Radio
*/
public with sharing class GenerateEvalComponent {
	public Component.Apex.OutputPanel getSectionContent() {
		return CreateFieldControls();
	}

	public string cat { get; set; }
	public string subcat{ get; set; }
	public string subsubcat{ get; set; }
	public string evalname{ get; set; }
	public ID evaluationID {
		get;
		set {
			evaluationId = value;
			if (evaluationId != null) {
				serviceAssignmentId = [
					SELECT ServiceAssignment__c FROM Evaluation__c WHERE Id=:evaluationId
				].ServiceAssignment__c;
			}
		}
	}
	public Id serviceAssignmentId { get; set; }
	public string evalSectionId { get; set; }
	public string evalSecType { get; set; }
	public static List<Set<String>> previousEntryAssociation = new List<Set<String>>{
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsDate',
			'CNA Workbook%Diagnostics%Vitals Signs%signsDateTime'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsBloodPressure',
			'CNA Workbook%Diagnostics%Vitals Signs%signsBP'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsHeartRate',
			'CNA Workbook%Diagnostics%Vitals Signs%signsHeartRate'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsO2Saturation',
			'CNA Workbook%Diagnostics%Vitals Signs%signsO2Sat'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%HRinterventionNeeded'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%O2interventionNeeded'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsR',
			'CNA Workbook%Diagnostics%Vitals Signs%vitalR'
		},
		new Set<String>{
			'Head to Toe%Diagnostics%Vitals Signs%vitalsTemperature',
			'CNA Workbook%Diagnostics%Vitals Signs%signsTemp'
		},
		new Set<String>{
			'CNA Workbook%Diagnostics%Vitals Signs%weightAtAdmission'
		},
		new Set<String>{
			'Head to Toe%Neurological%Cognitive%ranchoLevel'
		}
	};

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
	public Evaluation_Response__c[] annotations {
		get {
			String annotationRecType= cat != null && cat.contains('Neuro') ? 'NeuroAnnotation': 'Annotation';
			return [
				SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
				       Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
				       Annotation_Text__c
				  FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId
				   AND RecordType.Name = :annotationRecType
			];
		}
		set;
	}

	public GenerateEvalComponent() {
		mapEvalItems = new Map<ID, Eval__c>();
		mapEvalValues = new Map<ID, Eval_Value__c>();
	}

	public Component.Apex.OutputPanel CreateFieldControls () {
		List<Eval__c> listEvalItems;
		String additionalCondition = '';
		//EC-169 the questions 1 through 10 do NOT apply to the section if entering an activity log
		if (evalSecType == 'Activity Log' && evalname == 'Head to Toe' && cat == 'Diagnostics' && subcat == 'IV'){
			additionalCondition = 'AND (NOT htmlid__c LIKE \'HeadtoToeDiagnosticsIVQuestion%\') ';
		}
		if (subcat != null && subcat != '') {  // We're looking at the general category here
			additionalCondition += 'AND Sub_Category__c = :subcat ';
		}
		listEvalItems = Database.query(
			'SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c, ' +
			'       sub_category__c, sub_category_sequence__c, eval_type__r.name, Field_Type__c, ' +
			'       Field_Sub_Type__c, field_sequence__c, required__c, Length__c, ' +
			'       visibility_rules__c, visibility_row_rules__c, Dependent_Fields__c ' +
			'  FROM eval__c ' +
			' WHERE eval_type__r.name = :evalname ' +
			'   AND category__c =:cat ' +
			'   AND visible__c = true ' +
			additionalCondition +
			'ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c'
		);
		List<String> evalIds = new List<String>();
		Map<String, List<Eval__c>> subCategoryMap = new Map<String, List<Eval__c>>();
		for (Eval__c eval: listEvalItems) {
			evalIds.add(eval.Id);
			if (!subCategoryMap.containsKey(eval.Sub_Category__c)) {
				subCategoryMap.put(eval.Sub_Category__c, new List<Eval__c>());
			}
			subCategoryMap.get(eval.Sub_Category__c).add(eval);
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
		List<Eval_Value__c> listEvalValues = [
			SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c,
			       text_over_250__c, text_under_250__c, eval__c, eval__r.length__c
			  FROM eval_value__c
			 WHERE eval__c in :listEvalItems
			   AND what_id__c = :evaluationID
			   AND eval_Section_Id__c = :evalSectionId
		];
		Component.Apex.OutputPanel fullPanel = new Component.Apex.OutputPanel(layout='none');
		for (String subCategory: subCategoryMap.keySet()) {
			fullPanel.childComponents.add(generateSubsectionHtml(subCategoryMap.get(subCategory), dd, listEvalValues));
		}
		return fullPanel;
	}

	private Component.Apex.PageBlock generateSubsectionHtml(List<Eval__c> listEvalItems, List<Eval_Drop_Down__c> dd, List<Eval_Value__c> listEvalValues) {
		// get the list of controls for this type, category, and subcategory
		List<String> htmlcontrols = new List<String>();

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
		String newHTMLfld = '';
		String strval = '';
		String reqfldHTML = '';
		String subcategory = '';  // Assumption: this is all part of the same subcategory
		Set<String> fieldsWithPreviousEntries = new Set<String>();
		for (Set<String> association: previousEntryAssociation) {
			fieldsWithPreviousEntries.addAll(association);
		}
		for(Eval__c e : listEvalItems){
			try {
				subcategory = e.Sub_Category__c;
				newHtmlLbl = '<td class="text_right"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label></td>';
				newHTMLfld = '';
				strval = '';
				system.debug(' field type is ' + e.field_type__c);
				String composite = String.format('{0}%{1}%{2}%{3}', new List<String>{
					e.eval_type__r.name,
					e.category__c,
					e.sub_category__c,
					e.htmlid__c
				});
				String prevEntryStr = '';
				if (fieldsWithPreviousEntries.contains(composite)) {
					prevEntryStr += ' data-previous-entry="' + composite + '"';
				}
				if (e.Required__c) {
					reqfldHTML = '<div class="requiredInput" style="display: table-cell;"' + prevEntryStr + '><div class="requiredBlock"></div>';
				} else {
					reqfldHTML = '<div style="display: table-cell;"'+ prevEntryStr +'>';
				}


				if (e.Field_Type__c == 'Hidden')  {
					newHtmlLbl = '<td></td> ';  // an emtpy col for the hidden fields so that their labes wont show up on the form
					newHTMLfld = '<td class="dataCol"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="hidden" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHTMLfld += 'value="' ;
						if (e.Field_Sub_Type__c == 'Boolean') {
							newHTMLfld += mapEvalValues.get(e.id).boolean__c;
						}
						else if (e.Field_Sub_Type__c == 'String') {
							newHTMLfld += mapEvalValues.get(e.id).Text_Over_250__c;
						}
					}
					newHTMLfld += '"/></td>';

				} else if (e.Field_Type__c == 'Boolean')  { // Boolean can be Checkbox, Radio, or Dropdown
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHTMLfld = '<td class="dataCol"><div style="display: table-row;"><input id="' + e.htmlid__c + '" name="' + e.id + '" type="checkbox" value="' + 1 + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '"';

						// insert value
						if (mapEvalValues.ContainsKey(e.id))
							if (mapEvalValues.get(e.id).boolean__c)
								newHTMLFld += ' checked ';

						newHTMLfld += '/></div></td>';
					} else if (e.Field_Sub_Type__c == 'Dropdown') {
						// Boolean dropdown values = --None--, Yes, No
						newHTMLfld = '<td class="dataCol"><div style="display: table-row;">';
						newHTMLfld += reqfldHTML;
						newHTMLfld += '<select  id="' + e.htmlid__c + '" name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '">';
						newHTMLfld += '<option value="">-- None --</option>';
						if (mapEvalValues.ContainsKey(e.id)) {
							strval = mapEvalValues.get(e.id).Text_Under_250__c;
						}
						newHTMLfld += '<option value="1"';
						if (strval == '1')
							newHTMLfld += ' selected';
						newHtmlfld += '>Yes</option>';
						newHTMLfld += '<option value="0"';
						if (strval == '0')
							newHTMLfld += ' selected';
						newHTMLfld += '>No</option>';
						newHTMLfld += '</select></div></div></td>';
					} //TODO: output radio buttons for Radio type
				} else if (e.Field_Type__c=='String') {
					if (e.length__c >= 3000) {
						newHTMLfld = '<td class="dataCol" style="vertical-align: top" ><div style="display: table-row;">';
						newHTMLfld += reqfldHTML;
						newHTMLfld += '<textarea  id="' + e.htmlid__c + '"  name="' + e.id + '" >';
						if (mapEvalValues.ContainsKey(e.id)) {
							strVal = mapEvalValues.get(e.id).text_over_250__c;
							if (strVal != null && strVal != '')
								newHTMLfld += strVal;
						}
						newHTMLfld +=  '</textarea></div></div></td>';

					} else {
						newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
						newHTMLfld += reqfldHTML;
						newHTMLfld += '<input  id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
						if (mapEvalValues.ContainsKey(e.id)) {
							newHTMLfld += 'value="' ;
							if (e.length__c > 250)
								strVal = mapEvalValues.get(e.id).text_over_250__c;
							else
								strVal = mapEvalValues.get(e.id).text_under_250__c;

							if (strVal != null && strVal != '')
								newHTMLfld += strVal;

							newHTMLfld += '"';
						}
						newHTMLfld +=  '/></div></div></td>';
					}
				} else if (e.Field_Type__c == 'Double'){
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += reqfldHTML;
					newHTMLfld += '<input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHTMLfld += 'value="' ;
						if (mapEvalValues.get(e.id).eval__r.length__c == null || mapEvalValues.get(e.id).eval__r.length__c < 250) {
							strVal = mapEvalValues.get(e.id).text_under_250__c;
						} else {
							strVal = mapEvalValues.get(e.id).text_over_250__c;
						}

						if (strVal != null && strVal != '')
							newHTMLfld += strVal;

						newHTMLfld += '"';
					}
					if (e.htmlid__c == 'weightAtAdmission') {
						newHTMLfld += ' size="6" onkeyUp="return calculate(this, \'kg\');" /> <label for="weightAtAdmission">(kg) OR</label>';
						newHTMLfld += ' <br/><span style="white-space: nowrap;"><input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="weightAtAdmissionlb"  size="6" name="" type="text" onkeyUp="return calculate(this, \'lb\');" /> <label for="weightAtAdmissionlb">(lb)</label>';
						newHTMLfld += ' <input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="weightAtAdmissionoz"  size="6" name="" type="text" onkeyUp="return calculate(this, \'oz\');" /> <label for="weightAtAdmissionoz">(oz)</label></span>';
					}  else if (e.htmlid__c == 'kg') {
						newHTMLfld += ' size="6" onkeyUp="return calculate(this, \'kg\');" /> <label for="kg" id="kgLabel2">(kg) OR</label>';
						newHTMLfld += ' <br/><span style="white-space: nowrap;"><input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="weightlb"  size="6" name="" type="text" onkeyUp="return calculate(this, \'lb\');" /> <label for="weightlb" id="weightlbLabel">(lb)</label>';
						newHTMLfld += ' <input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="weightoz"  size="6" name="" type="text" onkeyUp="return calculate(this, \'oz\');" /> <label for="weightoz" id="weightozLabel">(oz)</label></span>';
					} else if (e.htmlid__c == 'heightAtAdmission') {
						newHTMLfld += ' size="6" onkeyUp="return calculate(this, \'cm\');" /> <label for="heightAtAdmission">(cm) OR</label>';
						newHTMLfld += ' <br/><span style="white-space: nowrap;"><input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="heightAtAdmissionft"  size="6" name="" type="text" onkeyUp="return calculate(this, \'ft\');" /> <label for="heightAtAdmissionft">(ft)</label>';
						newHTMLfld += ' <input  pattern="^[0-9]*(?:\\.\\d{1,2})?$" title="Please enter a valid two decimal digit number." id="heightAtAdmissionin"  size="6" name="" type="text" onkeyUp="return calculate(this, \'inc\');" /> <label for="heightAtAdmissionin">(in)</label></span>';
					} else {
						newHTMLfld +=  '/>';
					}
					newHTMLfld += '</div></div></td>';

				} else if (e.Field_Type__c == 'Int'){
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += reqfldHTML;
					newHTMLfld += '<input  pattern="[0-9]+" title="Please enter a valid number." id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHTMLfld += 'value="' ;
						strVal = String.valueOf(mapEvalValues.get(e.id).Number_No_Decimal__c);

						if (strVal != null && strVal != '')
							newHTMLfld += strVal;

						newHTMLfld += '"';
					}
					newHTMLfld +=  '/></div></div></td>';

				} else if (e.Field_Type__c == 'DropDown') {

					// get the value
					if (mapEvalValues.ContainsKey(e.id)) {
						if (mapEvalValues.get(e.id).eval__r.length__c == null || mapEvalValues.get(e.id).eval__r.length__c < 250) {
							strVal = mapEvalValues.get(e.id).text_under_250__c;
						} else {
							strVal = mapEvalValues.get(e.id).text_over_250__c;
						}
					}

					// get the options
					List<Eval_drop_Down__c> dropdownopts = ddOptions.get(e.id);
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += reqfldHTML;
					newHTMLfld += '<select id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '">';
					newHTMLfld += '<option value="">-- None --</option>';
					for (Eval_Drop_Down__c thisdd : dropdownopts) {
						newHTMLFld += '<option value="' + thisdd.option_value__c + '"';
						if (strval ==  thisdd.option_value__c)
							newHTMLFld += ' selected ';

						newHTMLFld += '>' + thisdd.option_name__c + '</option>';
					}
					newHTMLfld += '</select></div></div></td>';
				}  else if (e.Field_Type__c == 'Date') {
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += reqfldHTML;
					newHTMLfld += '<input class="datepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHTMLfld += 'value="' + mapEvalValues.get(e.id).date_time__c.date().format();
						newHTMLfld  += '"';
					}
					newHTMLfld +=  '/></div></div></td>';
				} else if (e.Field_Type__c == 'Datetime') {
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += reqfldHTML;
					newHTMLfld += '<input class="datetimepicker" id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
					if (mapEvalValues.ContainsKey(e.id)) {
						system.debug(mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy HH:mm'));
						newHTMLfld += 'value="' + mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy HH:mm');
						newHTMLfld  += '"';
					} else if (e.Required__c) {
						newHTMLfld += 'value="' + Datetime.now().format('MM/dd/yyyy HH:mm');
						newHTMLfld  += '"';
					}
					newHTMLfld +=  '/></div></div></td>';
				} else if (e.Field_Type__c == 'Multiselect') {
					String selectedVals;
					if (mapEvalValues.ContainsKey(e.id)){
						if (e.length__c > 250)
							selectedVals = mapEvalValues.get(e.id).Text_Over_250__c;
						else
							selectedVals = mapEvalValues.get(e.id).Text_Under_250__c;
					}

					// get the options
					List<Eval_drop_Down__c> dropdownopts = ddOptions.get(e.id);
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;" id=' + e.htmlid__c + '>';
						if (e.Required__c) {
							newHtmlLbl = '<td class="text_right"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
							newHtmlLbl += reqfldHTML;
							newHtmlLbl +=  '</div></td>';
						}
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHTMLfld += '<input id="' + e.htmlid__c+thisdd.Option_Value__c.replaceAll('\\s','') + '" name="' + e.id + '" type="checkbox" value="' + thisdd.Option_Value__c + '" data-visibility-row-rules="' + thisdd.visibility_row_rules__c + '" data-visibility-rules="' + thisdd.visibility_rules__c + '" data-rules="' + thisdd.Dependent_Fields__c + '"';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHTMLFld += ' checked ';

							newHTMLfld += '/>&nbsp<span>' + thisdd.Option_Name__c + '</span><br/>';
						}
						newHTMLfld +=  '</div></td>';
					} else {
						newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
						newHTMLfld += reqfldHTML;
						newHTMLfld += '<select style="vertical-align: text-top" multiple="multiple" id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '">';
						for (Eval_Drop_Down__c thisdd : dropdownopts) {
							newHTMLFld += '<option value="' + thisdd.option_value__c + '"';
							if (selectedVals != null && selectedVals.contains(thisdd.Option_Value__c))
								newHTMLFld += ' selected ';

							newHTMLFld += '>' + thisdd.option_name__c + '</option>';
						}
						newHTMLfld += '</select></div></div></td>';
					}
				} else if (e.field_type__c == 'BodyMap') {
					newHTMLfld = '<td><div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
					newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' +  GetResourceURL(e.field_sub_type__c) + '?' + evalSectionId + '" id="bodyMap' + evalSectionID + '" />';
					newHTMLfld += '</div>';
					newHTMLfld += '<div style="margin-left: 420px; height: 298px; overflow: auto;">';
					newHTMLfld += '<table id="annotations">';
					newHTMLfld += '<tbody></tbody></table></div></td>';
				} else if (e.field_type__c == 'Image') {
					newHTMLfld = '<td class="dataCol" style="vertical-align: top"><div style="display: table-row;">';
					newHTMLfld += '<img id="' + e.htmlid__c + '"  name="' + e.id + '"';
					newHTMLfld += ' src="' + GetResourceURL(e.field_sub_type__c) + '" />';
					newHTMLfld +=  '</td>';
				} else if (e.field_type__c == 'Slider') {
					newHTMLfld = '<td class="dataCol" style="vertical-align: top">';
					newHTMLfld += '<div id="' + e.htmlid__c + '" style="margin-left: 30px; margin-right: 40px;" name="' + e.id + '" />';
					newHTMLfld += '</td>';
				}

				htmlControls.Add(newHtmlLbl);
				htmlControls.Add(newHTMLfld);
			} catch (Exception ex) {
				System.Debug(ex);
			}
		}

		Component.Apex.PageBlock pageBlock = new Component.Apex.PageBlock(title=subcategory, rendered=(cat != ''));
		Component.Apex.OutputText outputText = new Component.Apex.OutputText(escape=false);

		String htmlTable2 = '<label class="labelCol">Created By:</label>' + getEvalSectionOwner() + '<br />' +
			'<label class="labelCol">Last Modified By:</label>' + getEvalSectionLastMod() +
			'<span id="evalSecValMsgs" style="color: red;"></span>';

		if (evalSecType == 'Head To Toe' && evalname == 'Head to Toe' && cat == 'Diagnostics' && subcategory == 'IV') {
			htmlTable2 += '<table style="width:100%;"><tr><th></th><th></th><th style="width:15%;"></th><th style="width:25%;"></th></tr><tr>';
		} else {
			htmlTable2 += '<table style="width:100%;"><tr><th style="width:15%;"></th><th style="width:25%;"></th><th style="width:15%;"></th><th style="width:25%;"></th></tr><tr>';
		}
		integer i=0;
		for (String s : htmlControls){
			if (Math.mod(i, 4) == 0) {
				htmlTable2 += '</tr><tr class="border_bottom">';
			}
			htmlTable2 += s;
			i++;
		}
		htmlTable2 += '</tr></table>';

		outputText.value = htmlTable2;
		pageBlock.childComponents.add(outputText);

		return pageBlock;
		//return htmlTable2;
	}

	public class FormKeyVal{
		public Id name;
		public String value;
	}

	@RemoteAction
	public static void saveFields(ID evalId, String evalSectionId, String evalSectionType, String EvalType, String jsonForm) {
		if (evalSectionId == '' || evalSectionId == null) {
			evalSectionId = UserInfo.getUserId() + '-' + DateTime.now().formatLong();
		}
		// Deserialize the form
		list<FormKeyVal> objs = (list<FormKeyVal>) JSON.deserialize(jsonForm, list<FormKeyVal>.class);
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
			       field_sequence__c, required__c, length__c
			  FROM eval__c
			 WHERE eval_type__r.name = :EvalType
			   AND Composite__c IN :composites
			   AND visible__c = true
			ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c
		]);

		// get any populated values for this eval and section
		List<Eval_Value__c> listEvalValues = [
			SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c,
			       text_over_250__c, text_under_250__c, eval__c from eval_value__c
			 WHERE eval_Section_Id__c = :evalSectionId
			   AND what_id__c = :evalId
			   AND what_id_object__c = 'Evaluation__c'
			   AND Eval__r.Composite__c IN :composites
		];

		// create a map by eval id
		mapEvalValues = new Map<ID, Eval_Value__c>();
		for (Eval_Value__c ev: listEvalValues) {
			mapEvalValues.put(ev.eval__c, ev);
		}

		List<Eval_Value__c> newValues = new List<Eval_Value__c>();
		List<Eval_Value__c> delValues = new List<Eval_Value__c>();
		Datetime evalShiftStartTime = [select Shift_Start_Time__c from Evaluation__c where ID = :evalId limit 1].Shift_Start_Time__c;
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
			}   else {
				ev = new Eval_Value__c();
				ev.eval__c = (ID)f;
				ev.eval_Section_Id__c = evalSectionId;
				ev.Eval_Section_Type__c = evalSectionType;
				ev.what_id__c = evalID;
				ev.what_id_object__c = 'Evaluation__c';
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
					if (EvalType == 'Head to Toe' || EvalType == 'CNA Workbook'){
						system.debug('ShiftStartTime: ' + evalShiftStartTime.format() + '  Entered time: ' + ev.Date_Time__c.format());
						if (evalShiftStartTime > ev.Date_Time__c || ev.Date_Time__c > Datetime.now()) {
							throw new InvalidDateTimeValException('<li>Save failed!!! The date and time value for ' + ei.field_name__c + ' must be within the current shift start time and the current time.</li>');
						}
					}
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

		delete delValues;
		upsert newValues;
	}

	public class InvalidDateTimeValException extends Exception{
	}

	@RemoteAction
	public static Evaluation_Response__c addOrModifyAnnotation(ID annotationId, String source, Decimal x, Decimal y, Decimal Width, Decimal Height, String Shape, String Text, String evaluationId) {
		Evaluation_Response__c annotation;
		if (annotationId!=null) {
			annotation = [SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId];
		} else {
			annotation = new Evaluation_Response__c();
			annotation.Evaluation__c = evaluationId;
			annotation.RecordTypeId = source.contains('Neurotab') ? Utility.getEvaluationResponseRecordType('NeuroAnnotation'): Utility.getEvaluationResponseRecordType('Annotation');
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

	public static String GetResourceURL(String resourceName) {
		List<StaticResource> resourceList = [
			SELECT Name, NamespacePrefix, SystemModStamp
			  FROM StaticResource
			 WHERE Name = :resourceName
		];
		if (resourceList.size() == 1) {
			String namespace = resourceList[0].NamespacePrefix;
			return '/resource/'
					+ resourceList[0].SystemModStamp.getTime() + '/'
					+ (namespace != null && namespace != '' ? namespace + '__' : '')
					+ resourceName;
		} else {
			return '';
		}
	}

	@RemoteAction
	public static EvalValue[] getPreviousEntries(String composite, Id serviceAssignmentId) {
		List<Evaluation__c> evaluations = [SELECT Id FROM Evaluation__c WHERE ServiceAssignment__c = :serviceAssignmentId];
		String evaluationStr = '(';
		for (Evaluation__c evaluation: evaluations) {
			evaluationStr += '\'' + evaluation.Id + '\', ';
		}
		evaluationStr = evaluationStr.removeEnd(', ');
		evaluationStr += ')';
		List<String> split = composite.split('%', 0);
		String query =
			'SELECT Id, Boolean__c, Currency__c, Date_Time__c, Number_No_Decimal__c, ' +
			'       Text_Over_250__c, Text_Under_250__c, What_Id__c, Eval__r.Field_Type__c, ' +
			'       Eval__r.Field_Sub_Type__c, Eval__r.Length__c, LastModifiedDate, ' +
			'       Eval__r.Eval_Type__r.Name, Eval__r.Category__c, Eval__r.Sub_Category__c, ' +
			'       Eval__r.Field_Name__c ' +
			'  FROM Eval_Value__c ' +
			' WHERE What_Id__c IN ' + evaluationStr + ' ' +
			'   AND (';
		Integer index = 0;
		for (Set<String> association: previousEntryAssociation) {
			if (association.contains(composite)) {
				for (String fields: association) {
					if (index != 0) {
						query += 'OR ';
					}
					query += String.format(
							'(Eval__r.Eval_Type__r.Name=\'\'{0}\'\' AND Eval__r.Category__c=\'\'{1}\'\' ' +
							'AND Eval__r.Sub_Category__c=\'\'{2}\'\' AND Eval__r.htmlid__c=\'\'{3}\'\') ',
							fields.split('%', 0));
					index ++;
				}
			}
		}
		query += ') ' +
			'ORDER BY LastModifiedDate DESC ' +
			'LIMIT 7';
		EvalValue[] evalValues = new EvalValue[] {};
		System.debug(query);
		for (Eval_Value__c evalValue: Database.query(query)) {
			evalValues.add(new EvalValue(evalValue));
		}
		return evalValues;
	}

	public class EvalValue {
		public String value { get; set; }
		public Id evaluationId { get; set; }
		public String lastModifiedDate { get; set; }
		public Eval_Value__c evalValueSObject { get; set; }

		public EvalValue(Eval_Value__c evalValue) {
			evaluationId = evalValue.What_Id__c;
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