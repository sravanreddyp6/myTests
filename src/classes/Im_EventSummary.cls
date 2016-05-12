public without sharing class Im_EventSummary {
	private Im_Report_Incident cntlr;
	public list<map<String, Object>> invPrties { get; set; }
	public map<String, list<String>> invPrtyEvntTyp { get; set; }

	public Im_EventSummary(Im_Report_Incident cntlr){
		this.cntlr = cntlr;
		String file = cntlr.getEventTitle() + '.pdf';
		file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
		Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');

		list<MyRemoteMethods.Im_partyData> invPrtyLst = new list<MyRemoteMethods.Im_partyData>();

		if (ApexPages.CurrentPage().getParameters().containsKey('invParty')) {
			invPrtyLst.add(MyRemoteMethods.getInvolvedParty(String.ValueOf(ApexPages.CurrentPage().getParameters().get('invParty'))));
		}
		else {
			invPrtyLst = MyRemoteMethods.getInvolvedParties(String.ValueOf(cntlr.eventId));
		}

		this.invPrties = new list<map<String, Object>>();
		this.invPrtyEvntTyp = new map<String, list<String>>();
		Im_EventSummary.getAnnotations(String.ValueOf(cntlr.eventId), '');

		for (MyRemoteMethods.Im_partyData invP : invPrtyLst){
			Map<String, Object> m = new Map<String, Object>{'Person_Being_Served__r.Guardian1_Name__c'=>''};
			updateMapWithRelationshipKeys(m, JSON.serialize(invP.involvedParty), '');
			this.invPrties.add(m);

			invPrtyEvntTyp.put(invP.involvedParty.id, getInvPrtyEvntDetails(String.valueOf(invP.involvedParty.id)));
		}
	}

	private void updateMapWithRelationshipKeys(Map<String, Object> m, String jsonString, String relationshipKey){
		Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		Map<String, Object> newMap = new Map<String, Object>();
		for(String k : temp.keySet()){
			if(k.endsWithIgnoreCase('__r')) {
				updateMapWithRelationshipKeys(m, JSON.serialize(temp.get(k)), k);
			} else {
				if (String.IsBlank(relationshipKey)) {
					newMap.put(k, temp.get(k));
				} else {
					newMap.put(relationshipKey + '.' + k,  temp.get(k));
				}
			}
		}
		m.putAll(newMap);
		m.remove(String.IsBlank(relationshipKey) ? 'attributes' : relationshipKey + '.attributes'); // this is to remove this key, SF adds this when serializing the sObject.
	}

	private static list<String> getInvPrtyEvntDetails(String involvedPrtyId) {
		Id invPrty = Id.valueOf(involvedPrtyId);
		map<String, String> sectionIdMap = new map<String, String>();
		map<String, list<Eval__c>> sectionMap = new map<String, list<Eval__c>>();

		map<Id, Eval_Value__c> evalIdToValueMap = new map<Id, Eval_Value__c>();
		for (Eval_Value__c value: [
				SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c, text_over_250__c, text_under_250__c,
				       eval__c, eval__r.composite__c, eval_section_type__c, eval_section_id__c, eval__r.length__c, eval__r.htmlId__c
				  FROM eval_value__c
				 WHERE eval__r.Visible__c = true AND what_id__c = :invPrty
				ORDER BY eval__r.category_sequence__c, eval__r.sub_category_sequence__c, eval__r.field_sequence__c
			]) {
			evalIdToValueMap.put(value.Eval__c, value);
			if (!sectionMap.containsKey(value.eval__r.composite__c)) {
				sectionMap.put(value.eval__r.composite__c, new list<Eval__c>());
				sectionIdMap.put(value.eval__r.composite__c, value.eval_section_id__c);
			}
		}

		set<Id> evalIds = new set<Id>();
		for (Eval__c eval : [
				SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c,
				       sub_category__c, sub_category_sequence__c, eval_type__r.name, Field_Type__c,
				       Field_Sub_Type__c, field_sequence__c, required__c, Length__c, Visible__c,
				       visibility_rules__c, visibility_row_rules__c, Dependent_Fields__c, Composite__c
				  FROM eval__c
				 WHERE Composite__c IN :sectionMap.keySet()
				   AND Visible__c = true
				ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c
		]) {
			if (eval.Composite__c.startsWith('Involved Party Qualifying')) {
				// Here we just pretend that it's an event question instead of a qualifying question
				String eventComposite = eval.Composite__c.replace('Involved Party Qualifying', 'Involved Party');
				sectionMap.get(eventComposite).add(eval);
				if (sectionMap.containsKey(eval.Composite__c) && sectionMap.get(eval.Composite__c).size() == 0) {
					// This is used in case there are eval values associated with the qualifier questions.
					// Without this, we'll have empty sections later on because we're iterating over sectionMap
					// keys, which include the Qualifier composites.
					sectionMap.remove(eval.Composite__c);
				}
			} else {
				sectionMap.get(eval.Composite__c).add(eval);
			}
			evalIds.add(eval.id);
		}

		List<Eval_Drop_Down__c> dd = [
			SELECT whatid__c, option_name__c, option_value__c, Dependent_Fields__c,
			       visibility_row_rules__c, visibility_rules__c
			  FROM eval_drop_down__c
			 WHERE whatid__c in : evalIds
			ORDER BY whatid__c, Sequence__c
		];

		list<string> myScripts = new list<String>();
		for (String composite: sectionMap.keySet()) {
			myScripts.add('<h3 style="text-align: center;">' + composite.substringAfterLast('~') + '</h3>' +
				generateSubsection(composite, sectionMap.get(composite), dd, evalIdToValueMap, sectionIdMap.get(composite), involvedPrtyId));
		}
		return myScripts;
	}

	private static String generateSubsection(String composite, List<Eval__c> listEvalItems, List<Eval_Drop_Down__c> dd, map<id,Eval_Value__c> mapEvalValues, String evalSectionId, String involvedPrtyId) {
		List<String> htmlControls = new List<String>();

		Map<ID, List<Eval_Drop_Down__c>> ddOptions = new Map<ID, List<Eval_Drop_Down__c>>();
		Map<ID, Eval__c> mapEvalItems = new Map<ID, Eval__c>(listEvalItems);
		List<Eval_Drop_Down__c> newdd;
		for (Eval_Drop_Down__c edd : dd) {
			if (ddOptions.ContainsKey(edd.whatid__c)) {
				if ((newdd = ddOptions.get(edd.whatid__c)) == null) {
					newdd = new List<Eval_Drop_Down__c>();
				}
			} else {
				newdd = new List<Eval_Drop_Down__c>();
			}
			newdd.Add(edd);
			ddOptions.put(edd.whatid__c, newdd);
		}

		String newHtmlLbl = '';
		String newHtmlFld = '';
		String strval = '';
		for(Eval__c e : listEvalItems){
			try {
				newHtmlLbl = '<td class="text_right">';
				newHtmlLbl += '<label  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label></td>';

				newHtmlFld = '';
				strval = '';
				if (e.Field_Type__c == 'Hidden' || (e.Field_Type__c != 'BodyMap' && !mapEvalValues.ContainsKey(e.id))) {
					continue;
					newHTMLfld = '<div >';
					if (e.Field_Sub_Type__c == 'String') newHTMLfld += mapEvalValues.get(e.id).text_over_250__c;
					newHTMLfld +=  '</div>';
				} else if (e.Field_Type__c == 'Boolean')  { // Boolean can be Checkbox, Radio, or Dropdown
					if (e.Field_Sub_Type__c == 'Checkbox') {
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
						if (mapEvalValues.ContainsKey(e.id)) {
							if (mapEvalValues.get(e.id).boolean__c) {
								newHtmlFld += ' Yes';
							} else {
								newHTMLFld += 'No';
							}
						}
						newHtmlFld += '/></div></td>';
					} else if (e.Field_Sub_Type__c == 'Dropdown') {
						// Boolean dropdown values = --None--, Yes, No
						newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
						if (mapEvalValues.ContainsKey(e.id)) {
							strval = mapEvalValues.get(e.id).Text_Under_250__c;
						}
						if (strval == '1') {
							newHTMLfld += 'Yes';
						} else if (strval == '0') {
							newHTMLfld += 'No';
						}
						newHTMLfld += '</div></td>';
					}
				} else if (e.Field_Type__c=='String' || e.Field_Type__c == 'DropDown' || e.Field_Type__c == 'Double' || e.Field_Type__c == 'Multiselect') {
					newHtmlFld += '<td class="dataCol"><div style="display: table-row;">';
					if (mapEvalValues.ContainsKey(e.id)) {
						if (e.length__c > 250) {
							strVal = mapEvalValues.get(e.id).text_over_250__c.escapeHtml4();
						} else {
							strVal = mapEvalValues.get(e.id).text_under_250__c.escapeHtml4();
						}
						if (strVal != null && strVal != '') {
							newHtmlFld += strVal;
						}
					}
					newHtmlFld +=  '</div></td>';
				} else if (e.Field_Type__c == 'Int') {
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					if (mapEvalValues.ContainsKey(e.id)) {
						strVal = String.valueOf(mapEvalValues.get(e.id).Number_No_Decimal__c);
						if (strVal != null && strVal != '') {
							newHtmlFld += strVal;
						}
					}
					newHtmlFld +=  '</div></td>';
				} else if (e.Field_Type__c == 'Date') {
					newHtmlFld += '<td class="dataCol" ><div style="display: table-row;">';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += mapEvalValues.get(e.id).date_time__c.date().format();
					}
					newHtmlFld +=  '</div></td>';
				} else if (e.Field_Type__c == 'Datetime') {
					newHtmlFld += '<td class="dataCol"  ><div style="display: table-row;">';
					if (mapEvalValues.ContainsKey(e.id)) {
						newHtmlFld += (MyRemoteMethods.isMilitaryTime ? mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy HH:mm') : mapEvalValues.get(e.id).date_time__c.format('MM/dd/yyyy hh:mm a', UserInfo.getTimeZone().toString()));
					}
					newHtmlFld +=  '</div></td>';
				} else if (e.field_type__c == 'BodyMap') {
					if (!getAnnotations('', evalSectionId).containsKey(evalSectionId)) {
						continue;
					}

					list<Evaluation_Response__c> annotations = getAnnotations('', evalSectionId).get(evalSectionId);

					newHtmlLbl = '<td>';
					newHtmlLbl += '<div style="page-break-before: always;"></div><label  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label></td>';

					newHTMLfld += '<td colspan="3"><div style="page-break-before: always;"></div><div style="position: relative; float: left; margin-bottom: 10px;">';
					newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' + annotations.get(0).Annotation_Source__c.escapeHtml4() + '" id="bodyMap' + evalSectionId + '" />';

					Integer i=1;
					for (Evaluation_Response__c annotation : annotations){
						newHTMLfld += '<div class="annotation-number" style="pointer-events: none; position: absolute; text-align: center; ';
						newHTMLfld += 'left: ' + annotation.Annotation_X__c * 100 + '%;';
						newHTMLfld += 'width: ' + annotation.Annotation_Width__c * 100 + '%;';
						newHTMLfld += 'top: ' + annotation.Annotation_Y__c * 100 + '%;';
						newHTMLfld += 'height: ' + annotation.Annotation_Height__c * 100 + '%;';
						newHTMLfld += 'border: 1px black solid;"><span style="color: red; font-size: 1.5em;">';
						newHTMLfld += i;
						newHTMLfld += '</span></div>';
						++i;
					}
					newHTMLfld += '</div>';
					newHTMLfld += '<div style="margin-left: 380px; height: 298px; overflow: auto;">';
					newHTMLfld += '<table>';
					newHTMLfld += '<tbody>';
					Integer j=1;
					for (Evaluation_Response__c annotation : annotations){
						newHTMLfld += '<tr><td>' + j + '</td><td>' + annotation.Annotation_Text__c + '</td></tr>';
						++j;
					}
					newHTMLfld +='</tbody></table></div>';
					newHTMLfld +=  '</div></td>';

					htmlControls.Add(newHtmlLbl);
					htmlControls.Add(newHtmlFld);
					htmlControls.Add('<td></td>');
					htmlControls.Add('<td></td>');
					continue;
				}
				htmlControls.Add(newHtmlLbl);
				htmlControls.Add(newHtmlFld);
			} catch (Exception ex) {
					System.Debug(ex);
			}
		}

		String htmlTable = '<table style="width:100%;" class="subCatTable"><tr><th style="width:30%;"></th><th style="width:20%;"></th><th style="width:25%;"></th><th style="width:20%;"></th></tr><tr>';
		Integer i = 0;
		for (String s : htmlControls){
			if (Math.mod(i, 4) == 0) {
					htmlTable += '</tr><tr class="border_bottom">';
			}
			htmlTable += s;
			i++;
		}
		htmlTable += '</tr></table>';
		return htmlTable;
	}

	private static map<String, list<Evaluation_Response__c>> invPrtyAnnotations = new map<String, list<Evaluation_Response__c>>();
	private static map<String, list<Evaluation_Response__c>> getAnnotations (String incident, String subCatIdentifier){
		if (invPrtyAnnotations.isEmpty()) {
			invPrtyAnnotations.put('dummyKey', new list<Evaluation_Response__c>());
			for (Evaluation_Response__c e : [
					SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
					       Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
					       Annotation_Text__c, EvalValueSectionIdentifier__c, ImInvolvedPartyAnnotations__c
					  FROM Evaluation_Response__c
					 WHERE ImInvolvedPartyAnnotations__r.Im_Incident__c = :incident
					   AND RecordType.Name = 'Annotation'
			]){
				if (!invPrtyAnnotations.containsKey(e.EvalValueSectionIdentifier__c)) invPrtyAnnotations.put(e.EvalValueSectionIdentifier__c, new list<Evaluation_Response__c>{e});
				else invPrtyAnnotations.get(e.EvalValueSectionIdentifier__c).add(e);
			}
		}
		if (invPrtyAnnotations.containsKey(subCatIdentifier)) {
			return invPrtyAnnotations;
		} else {
			return null;
		}
	}
}