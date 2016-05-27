public with sharing class IncidentInvolvedPartyModel {
	public static void updateNames(Im_InvolvedParty__c[] involvedParties) {
		Set<Id> saIds = new Set<Id>();
		Set<Id> tmnUserIds = new Set<Id>();
		for (Im_InvolvedParty__c party: involvedParties) {
			if (party.Person_Being_Served_Involved__c != null) {
				saIds.add(party.Person_Being_Served_Involved__c);
			}
			if (party.Staff_Involved__c != null) {
				tmnUserIds.add(party.Staff_Involved__c);
			}
		}
		Map<Id, Service_Assignment__c> saMap = new Map<Id, Service_Assignment__c>([
			SELECT Id, pbsFirstName__c, pbsLastName__c
			  FROM Service_Assignment__c
			 WHERE Id IN :saIds
		]);
		Map<Id, Tmn_User__c> tmnUserMap = new Map<Id, Tmn_User__c>([
			SELECT Id, Name
			  FROM Tmn_User__c
			 WHERE Id IN :tmnUserIds
		]);

		for (Im_InvolvedParty__c involvedParty: involvedParties) {
			if (involvedParty.Type__c != 'Person Being Served' && involvedParty.Type__c != 'Staff') {
				continue;
			}
			String name;
			if (involvedParty.Type__c == 'Person Being Served') {
				name = String.format('{0} {1}', new String[] {
					saMap.get(involvedParty.Person_Being_Served_Involved__c).pbsFirstName__c,
					saMap.get(involvedParty.Person_Being_Served_Involved__c).pbsLastName__c
				});
			} else {
				name = tmnUserMap.get(involvedParty.Staff_Involved__c).Name;
			}
			involvedParty.Name = name;
		}
	}

	public static TMN_TreePktDocTable getInvolvedPartyTypes(String[] evalTypes, String involvePartyType, String involvePartyId) {
		System.debug('getInvolvedPartyTypes called');
		if (involvePartyType.equalsIgnoreCase('Person Being Served')) {
			involvePartyType = 'PBS';
		} else if (involvePartyType.equalsIgnoreCase('Host Home Parent')) {
			involvePartyType = 'Mentor';
		} else if (involvePartyType.equalsIgnoreCase('Other Family Member')) {
			involvePartyType = 'Other';
		}
		involvePartyType = '%' + involvePartyType + '%';

		TMN_TreePktDocTable formTree = new TMN_TreePktDocTable();
		Map<String, String> eventTypes = new Map<String, String>();
		for(Eval__c e : [
				select Composite__c, category__c, sub_category__c
				  from eval__c
				 where eval_type__r.Name IN :evalTypes
				   and Visible__c = true
				   and Involved_Party_Type__c like :involvePartyType
				order by cat_seq_text__c, subcat_seq_text__c
			]){
			if (!eventTypes.containsKey(e.Composite__c)) {
				eventTypes.put(e.Composite__c, e.sub_category__c); // they want only the subCat
			}
		}
		//remove the ones that are already on this involved party
		list<Eval_Value__c> existinEvntTyps = [
			SELECT eval__r.Composite__c FROM eval_value__c
			 WHERE what_id__c = : involvePartyId
			   AND eval__r.Visible__c = true
			   AND eval__r.HtmlId__c = 'IsValid'
		];

		//can not add anything else if one has Injury OR law enforcement
		for (Eval_value__c ev : existinEvntTyps){
			if (ev.eval__r.Composite__c.equalsIgnoreCase('Involved Party~Behavioral~Law Enforcement Involvement') || ev.eval__r.Composite__c.equalsIgnoreCase('Involved Party~All Others~Injury')){
				eventTypes = new map<String, String>();
				break;
			}
		 	eventTypes.remove(ev.eval__r.Composite__c); // remove the ones already added
		}
		//if there is one that means i can not add Injury OR law enforcement
		if (existinEvntTyps.size() > 0 && eventTypes.keySet().size() > 0) {
			if (eventTypes.containsKey('Involved Party~Behavioral~Law Enforcement Involvement')) {
				eventTypes.remove('Involved Party~Behavioral~Law Enforcement Involvement');
			}
			if (eventTypes.containsKey('Involved Party~All Others~Injury')) {
				eventTypes.remove('Involved Party~All Others~Injury');
			}
		}

		for(String s : eventTypes.keySet()){
			TMN_TreePktDocTable.node eNode = new TMN_TreePktDocTable.node(s, eventTypes.get(s));
			formTree.root.children.add(eNode);
		}
		return formTree;
	}

	public static void insertInvolvedPartyTypes(Set<String> evalSections, Id involvedPartyId) {
		//can not add anything else with Injury and/OR law enforcement
		if (evalSections.size() > 1 && (evalSections.contains('Involved Party~Behavioral~Law Enforcement Involvement') || evalSections.contains('Involved Party~All Others~Injury') )){
			 throw new CustomException('Cannot add anything if adding Injury OR Law Enforcement');
		}

		list<Eval_Value__c> evalVals = new list<Eval_Value__c>();
		integer i = 0;
		for (Eval__c e : [
				Select id
				  from eval__c
				 where Composite__c IN :evalSections
				   and field_name__c = 'isValid'
				   and visible__c = true
				ORDER BY category_sequence__c, sub_category_sequence__c
		]){
			Eval_Value__c ev = new Eval_Value__c(Eval__c = e.id);
			String evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime()+i);
			ev.eval_Section_Id__c = evalSectionId;
			ev.Eval_Section_Type__c = 'Im_Incident';
			ev.what_id__c = involvedPartyId;
			ev.what_id_object__c = 'Im_InvolvedParty__c';
			ev.Boolean__c = false;
			evalVals.add(ev);
			i++;
		}
		insert evalVals;
	}

	public static final boolean isMilitaryTime = UserDefaults__c.getInstance(userinfo.getuserId()).MilitaryTime__c;

	private class FormKeyVal{
		public String name;
		public String value;
	}

 	public static list<String> saveFields(IncidentModel.Stage stage, Id involvedPrty, String jsonForm) {
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
			 WHERE eval_type__r.name IN ('Involved Party', 'Involved Party Qualifying')
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
		autoInsertSections(newValues);
		return getInvolvedPartyDetails(stage, String.ValueOf(involvedPrty), false);
 	}

	public static void autoInsertSections(Eval_Value__c[] newValues) {
		// We also need to add sections if certains questions are answered
		newValues = [
			SELECT Id, Eval_Section_Id__c, Text_Under_250__c, Number_No_Decimal__c, Date_Time__c,
			       Eval__r.Category__c, Eval__r.Sub_Category__c, Eval__r.htmlid__c, Boolean__c,
			       Eval__r.Eval_Type__r.Name, What_Id__c
			  FROM Eval_Value__c
			 WHERE Id IN :newValues
		];
		Map<String, Eval_Value__c[]> sectionMap = new Map<String, Eval_Value__c[]>();
		for (Eval_Value__c value: newValues) {
			if (value.Eval__r.Eval_Type__r.Name != 'Involved Party' && value.Eval__r.Eval_Type__r.Name != 'Involved Party Qualifying') {
				continue;
			}
			if (!sectionMap.containsKey(value.Eval_Section_Id__c)) {
				sectionMap.put(value.Eval_Section_Id__c, new List<Eval_Value__c>());
			}
			sectionMap.get(value.Eval_Section_Id__c).add(value);
		}

		Eval_Value__c[] potentialValuesToInsert = new Eval_Value__c[]{};
		for (String evalSectionId: sectionMap.keySet()) {
			Eval_Value__c[] sectionValues = sectionMap.get(evalSectionId);
			// First let's create a map from the htmlid to the values for easy access
			Map<String, Eval_Value__c> valueMap = new Map<String, Eval_Value__c>();
			for (Eval_Value__c value: sectionValues) {
				valueMap.put(value.Eval__r.HtmlId__c, value);
			}

			String sectionName = sectionValues[0].Eval__r.Category__c + '~' + sectionValues[0].Eval__r.Sub_Category__c;

			System.debug('sectionName: ' + sectionName);
			System.debug('valueMap: ' + valueMap);
			System.debug('valueMap keySet: ' + valueMap.keySet());
			if (sectionName != 'All Others~Injury' || !valueMap.containsKey('injuryCause')) {
				continue;
			}
			Eval_Value__c valueToInsert = new Eval_Value__c(
				Eval_Section_Id__c = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime()),
				Eval_Section_Type__c = 'Im_Incident',
				What_id_object__c = 'Im_InvolvedParty__c',
				What_Id__c = valueMap.get('injuryCause').What_Id__c,
				Boolean__c = false
			);

			Set<String> injuryCauses = new Set<String>(valueMap.get('injuryCause').Text_Under_250__c.split(';'));
			if (injuryCauses.contains('Self-Harm')) {
				valueToInsert.Eval__c = getIsValidId('Mental Health', 'Self Harm');
			}
			if (injuryCauses.contains('Fall')) {
				valueToInsert.Eval__c = getIsValidId('All Others', 'Fall');
			}
			if (injuryCauses.contains('Equipment')) {
				// TODO there's an Equipment Failure category in the data, is that the one?
			}
			if (injuryCauses.contains('Vehicle Accident')) {
				// TODO right now the value is Motor Vehicle
				valueToInsert.Eval__c = getIsValidId('All Others', 'Vehicle Accident');
			}
			if (injuryCauses.contains('Ingestion of Foreign Object')) {
				// TODO right now the value is Ingestion
				valueToInsert.Eval__c = getIsValidId('Mental Health', 'Ingestion of Foreign Object');
			}
			if (injuryCauses.contains('Sexual Aggression')) {
				// TODO right now the value is Sexual Assault, and there's no Sexual Aggression category in our data yet
				valueToInsert.Eval__c = getIsValidId('Behavioral', 'Sexual Aggression/Assault');
			}
			if (valueMap.containsKey('injuryResultOf')) {  // TODO right now injuryResultOf does not exist in data
				String injuryResultOf = valueMap.get('injuryResultOf').Text_Under_250__c;
				Id evalId;
				if (injuryResultOf == 'Allegations of Neglect') {
					evalId = getIsValidId('Allegations of Abuse/Neglect', 'Allegation of Neglect');
				} else if (injuryResultOf == 'Allegations of Abuse - Physical') {
					evalId = getIsValidId('Allegations of Abuse/Neglect', 'Allegations of Abuse - Physical');
				} else if (injuryResultOf == 'Allegations of Abuse - Sexual') {
					evalId = getIsValidId('Allegations of Abuse/Neglect', 'Allegations of Abuse - Sexual');
				}
				if (injuryCauses.contains('Another person - staff') ||
						injuryCauses.contains('Another person - PBS') ||  // TODO right now the value is Another person - another PBS
						injuryCauses.contains('Another person - other') ||
						injuryCauses.contains('Another person - Mentor/Provider') ||  // TODO right now there's no Mentor/Provider value
						injuryCauses.contains('Another person - Mentor/Provider Family')  // TODO right now there's no Mentor/Provider Family value
					) {
					valueToInsert.Eval__c = evalId;
				}
			}
			if (valueMap.containsKey('restraintUsed')) {  // TODO right now restraintUsed does not exist in data
				String restraintUsed = valueMap.get('restraintUsed').Text_Under_250__c;
				Id evalId;
				if (restraintUsed == 'Physical') {
					evalId = getIsValidId('Intervention', 'Physical Restraint');
				} else if (restraintUsed == 'Mechanical') {
					evalId = getIsValidId('Intervention', 'Mechanical Restraint');
				} else if (restraintUsed == 'Chemical') {
					evalId = getIsValidId('Intervention', 'Chemical Restraint');
				} else if (restraintUsed == 'Seclusion') {
					evalId = getIsValidId('Intervention', 'Seclusion');
				}
				if (injuryCauses.contains('Restraint')) {
					valueToInsert.Eval__c = evalId;
				}
			}

			if (valueToInsert.Eval__c != null) {
				potentialValuesToInsert.add(valueToInsert);
			}
		}

		if (potentialValuesToInsert.size() > 0) {
			// Only insert the new section if there's no existing one
			Map<Id, Boolean> existingSectionMap = new Map<Id, Boolean>();
			for (Eval_Value__c value: potentialValuesToInsert) {
				existingSectionMap.put(value.Eval__c, false);
			}
			Eval_Value__c[] existingValues = [
				SELECT Id, Eval__c
				  FROM Eval_Value__c
				 WHERE Eval__c IN :existingSectionMap.keySet()
				   AND What_Id__c = :potentialValuesToInsert[0].What_Id__c  // assumption: all the Eval_Value__c are for the same involved party
			];
			for (Eval_Value__c existingValue: existingValues) {
				existingSectionMap.put(existingValue.Eval__c, true);
			}
			Eval_Value__c[] valuesToInsert = new Eval_Value__c[]{};
			for (Eval_Value__c value: potentialValuesToInsert) {
				if (!existingSectionMap.get(value.Eval__c)) {
					valuesToInsert.add(value);
				}
			}
			if (valuesToInsert.size() > 0) {
				insert valuesToInsert;
			}
		}
	}

	private static Id getIsValidId(String category, String subCategory) {
		return [
			Select Id
			  from eval__c
			 where Category__c = :category
			   and Sub_Category__c = :subCategory
			   and field_name__c = 'isValid'
			   and visible__c = true
		].Id;
	}

	public static list<String> getInvolvedPartyDetails(IncidentModel.Stage stage, Id involvedPartyId, Boolean isLocked) {
		Map<String, String> sectionIdMap = new Map<String, String>();
		Map<String, List<Eval__c>> sectionMap = new Map<String, List<Eval__c>>();

		Map<Id, Eval_Value__c> evalIdToValueMap = new Map<Id, Eval_Value__c>();
		Map<String, Eval_Value__c> sectionErrorMsgs = new Map<String, Eval_Value__c>();
		Set<String> validSubCats = new Set<String>();
		for (Eval_Value__c value: [
				SELECT id, boolean__c, currency__c, date_time__c, number_no_decimal__c,
				       text_over_250__c, text_under_250__c,
				       eval__c, eval__r.composite__c, eval_section_type__c,
				       eval_section_id__c, eval__r.length__c, eval__r.htmlId__c
				  FROM eval_value__c
				 WHERE eval__r.Visible__c = true
				   AND what_id__c = :involvedPartyId
				ORDER BY eval__r.category_sequence__c, eval__r.sub_category_sequence__c, eval__r.field_sequence__c
			]) {
			evalIdToValueMap.put(value.Eval__c, value);
			if (!sectionMap.containsKey(value.eval__r.composite__c)) {
				sectionMap.put(value.eval__r.composite__c, new list<Eval__c>());
				sectionIdMap.put(value.eval__r.composite__c, value.eval_section_id__c);
			}
			if (value.eval__r.htmlId__c.equalsIgnoreCase('ErrorMsg')) {
				sectionErrorMsgs.put(value.eval__r.composite__c, value);
			}
			if (value.eval__r.htmlId__c.equalsIgnoreCase('isValid') && value.Boolean__c) {
				validSubCats.add(value.eval__r.composite__c);
			}
		}
		Set<String> allSections = sectionMap.keySet().clone();  // Since a keySet() is read only...
		if (stage == IncidentModel.Stage.QUALIFYING || stage == IncidentModel.Stage.INCIDENT) {
			// Here we need to merge the qualifying questions with the event questions by adding them to
			// the list of categories queried (aka allSections)
			for (String composite: allSections) {
				if (!composite.startsWith('Involved Party~')) {
					continue;
				}
				String qualifyingComposite = composite.replace('Involved Party', 'Involved Party Qualifying');
				allSections.add(qualifyingComposite);
			}
		}

		set<Id> evalIds = new set<Id>();
		for (Eval__c eval : [
				SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c,
				       sub_category__c, sub_category_sequence__c, eval_type__r.name, Field_Type__c,
				       Field_Sub_Type__c, field_sequence__c, required__c, Length__c, Visible__c,
				       visibility_rules__c, visibility_row_rules__c, Dependent_Fields__c, Composite__c
				  FROM eval__c
				 WHERE Composite__c IN :allSections
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
			String cleanComposite = 'mySecId-' + sectionIdMap.get(composite);
			if ( sectionErrorMsgs.containsKey(composite) && String.isNotBlank(sectionErrorMsgs.get(composite).Text_Over_250__c) ){
				myScripts.add('<h3 id="'+ cleanComposite +'" class="ui-state-error">'+ composite.substringAfterLast('~') + '</h3>');
				myScripts.add('<table style="width: 100%;" class="subCatTable ' + cleanComposite + '"><tr><td style="width=100%;">' + (isLocked ? '' : '<input type="button" value="Remove" class="btn removeInvPrtyEvntTyp"/>') + '<ul class="ui-state-error" style="margin-right: 5em;">' +
						sectionErrorMsgs.get(composite).Text_Over_250__c + '</ul></td></tr><tr><td style="width=100%;">' +
						generateSubsection(sectionMap.get(composite), dd, evalIdToValueMap, sectionIdMap.get(composite), involvedPartyId) + '</td></tr></table>');
			} else {
				myScripts.add('<h3 id="'+ cleanComposite +'" class="'+ (validSubCats.contains(composite) ? 'ui-state-success' : '' ) +'">'+ composite.substringAfterLast('~') + '</h3>');
				myScripts.add('<table style="width: 100%;" class="subCatTable ' + cleanComposite + '"><tr><td style="width=100%;">' + (isLocked ? '':  '<input type="button" value="Remove" class="btn removeInvPrtyEvntTyp"/>') + '</td></tr><tr><td style="width=100%;">' +
						generateSubsection(sectionMap.get(composite), dd, evalIdToValueMap, sectionIdMap.get(composite), involvedPartyId) + '</td></tr></table>');
			}
		}
		if (myScripts.size() > 0) {
			myScripts.add(String.format(
				'<script id="{0}myScript">var id = jQuery("#{0}myScript").parent().attr("id"); setUpFields(jQuery("#" + id + " input, #" + id + " img, #" + id + " select, #" + id + " textarea"));</script>',
				new String[] { involvedPartyId}
			));
		}
		return myScripts;
	}

	private static String generateSubsection(List<Eval__c> listEvalItems, List<Eval_Drop_Down__c> dd, map<id,Eval_Value__c> mapEvalValues, String evalSectionId, String involvedPrtyId) {
		System.debug('involvedPrtyId: ' + involvedPrtyId);
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
				if (String.IsNotBlank(e.Dependent_Fields__c))  e.Dependent_Fields__c = updateRulesJSON(e.Dependent_Fields__c,evalSectionId);
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
					if (e.length__c >= 255) {
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
							newHtmlLbl = '<td class="text_right"><input type="hidden" name="' + e.Id + '_esi" value="' + evalSectionId + '" /><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;width: 100%;" data-composite="' + involvedPrtyId + '">' + e.field_name__c + '</label>';
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
				System.debug(ex);
				System.Debug(ex.getStackTraceString());
			}
		}

		String htmlTable = '<table data-composite="' + involvedPrtyId + '" style="width:100%;" class="subCatTable"><tr><th style="width:20%;"></th><th style="width:30%;"></th><th style="width:15%;"></th><th style="width:25%;"></th></tr><tr>';

		Integer i = 0;
		for (String s : htmlControls){
			if (Math.mod(i, 4) == 0) {
				htmlTable += '</tr><tr>';
			}
			htmlTable += s;
			i++;
		}

		return htmlTable;
	}

	private static String updateRulesJSON(String ruleStr, String sectionId){
		if (String.IsBlank(ruleStr)) {
			return '';
		}
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
		} catch (Exception e) {
			return '';
		}
	}

	private static map<String, list<Evaluation_Response__c>> invPrtyAnnotations = new map<String, list<Evaluation_Response__c>>();
	@TestVisible
	private static String getAnnotations(String invPrtyId, String subCatIdentifier) {
		if (invPrtyAnnotations.isEmpty()) {
			invPrtyAnnotations.put('dummyKey', new list<Evaluation_Response__c>());
			for (Evaluation_Response__c e : [
					SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
					       Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
					       Annotation_Text__c, EvalValueSectionIdentifier__c, ImInvolvedPartyAnnotations__c
					  FROM Evaluation_Response__c WHERE ImInvolvedPartyAnnotations__c = :invPrtyId AND RecordType.Name = 'Annotation'
				]){
				if (!invPrtyAnnotations.containsKey(e.EvalValueSectionIdentifier__c)) {
					invPrtyAnnotations.put(e.EvalValueSectionIdentifier__c, new list<Evaluation_Response__c>{e});
				} else {
					invPrtyAnnotations.get(e.EvalValueSectionIdentifier__c).add(e);
				}
			}
		}
		if (invPrtyAnnotations.containsKey(subCatIdentifier)) {
			return json.serialize(invPrtyAnnotations.get(subCatIdentifier));
		}
		return '';
	}

	private static String bodyMapUrl;
	private static String GetResourceURL(String resourceName) {
		if (String.IsNotBlank(bodyMapUrl)) {
			return bodyMapUrl;
		}
		List<StaticResource> resourceList = [
			SELECT Name, NamespacePrefix, SystemModStamp
			  FROM StaticResource
			 WHERE Name = :resourceName
		];
		if (resourceList.size() == 1) {
			String namespace = resourceList[0].NamespacePrefix;
			bodyMapUrl = '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;
			return bodyMapUrl;
		} else {
			return '';
		}
	}

	class CustomException extends Exception {}
}
