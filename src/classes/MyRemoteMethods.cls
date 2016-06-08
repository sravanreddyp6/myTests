public with sharing class MyRemoteMethods {
	public static final boolean isMilitaryTime = UserDefaults__c.getInstance(userinfo.getuserId()).MilitaryTime__c;
	@TestVisible private transient TxnQueueResponseController parentCntrller;
    public class Im_partyData{
        @TestVisible Id id;
        String DT_RowId;
        public String name {get;set;}
        public String type {get;set;}
        Im_partyData(Im_InvolvedParty__c party){
            this.involvedParty = party;
            this.DT_RowId = String.valueOf(party.id);
            this.id = party.id;
            this.type = party.Type__c;
            //if (party.Type__c == 'Person Being Served') this.name = party.Person_Being_Served_Involved__r.pbsFirstName__c + ' ' + party.Person_Being_Served_Involved__r.pbsLastName__c;
            //else if (party.Type__c == 'Staff') this.name = party.Staff_Involved__r.name;
            //else
            this.name = party.name;
            if (!String.isBlank(party.Nickname__c)) {
                this.name += String.format(' ({0})', new String[]{ party.Nickname__c });
            }
        }
        public Im_InvolvedParty__c involvedParty {get;set;}
    }
	@RemoteAction
	public static Im_partyData getInvolvedParty(String InvPrtyId) {
		Im_InvolvedParty__c imPrty = [
			select id, Type__c, name, PBS_Age__c, Nickname__c,
			       Person_Being_Served_Involved__r.pbsFirstName__c,
			       Person_Being_Served_Involved__r.pbsLastName__c,
			       Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.PBS_Identifier__c,
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
			  from Im_InvolvedParty__c
			 where id =: InvPrtyId
			 limit 1
		];

		Im_partyData Prty = new Im_partyData(imPrty);
		return Prty;
	}

	@ReadOnly
	@RemoteAction
	public static list<Im_partyData> getInvolvedParties(String EventId) {
		Id event = (EventId instanceof Id) ? (Id) EventId : null;
		list<Im_partyData> dataObj = new list<Im_partyData>();
		for (Im_InvolvedParty__c imPrty : [
				select id, Type__c, name, PBS_Age__c, Nickname__c,
				       Person_Being_Served_Involved__r.pbsFirstName__c,
				       Person_Being_Served_Involved__r.pbsLastName__c,
				       Person_Being_Served_Involved__r.Admission__r.Person_being_served__r.PBS_Identifier__c,
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
				  from Im_InvolvedParty__c
				 where Im_Incident__c = :event
				order by Type__c
		]){
			Im_partyData Prty = new Im_partyData(imPrty);
			dataObj.add(Prty);
		}
		return dataObj;
	}


	@ReadOnly
	@RemoteAction
	public static list<String> getInvPrtyEvntDetails(String involvedPartyId, Boolean isLocked) {
		return IncidentInvolvedPartyModel.getInvolvedPartyDetails(IncidentModel.Stage.EVENT, Id.valueOf(involvedPartyId), isLocked);
	}

	private static String updateRulesJSON(String ruleStr, String sectionId){
		if (String.IsBlank(ruleStr)){
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
    private static String GetResourceURL(String resourceName) {
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

 	@RemoteAction
 	public static list<String> saveFields(Id involvedPrty, String jsonForm) {
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

		IncidentInvolvedPartyModel.autoInsertSections(newValues);
		return getInvPrtyEvntDetails(String.ValueOf(involvedPrty), false);
	}

    @ReadOnly
    @RemoteAction
    public static String GetInvolvedPartyEventTypes(String invPrtyData){
        map<String, object> inputs = (Map<string, object>) json.deserializeUntyped(invPrtyData);
        Id invPrty = (Id) inputs.get('involvedParty');
        String invPrtyTyp = (String) inputs.get('involvedPartyType');
        TMN_TreePktDocTable formTree = IncidentInvolvedPartyModel.getInvolvedPartyTypes(
            new String[] { 'Involved Party' },
            invPrtyTyp,
            invPrty
        );
        return JSON.serialize(formTree.root.children);
    }

    @ReadOnly
    @RemoteAction
    public static map<string, object> validateEvent(String eventId) {
        return IncidentModel.validateEvent(eventId);
    }

    public list<SelectOption> getMyService_Locations() {
        list<SelectOption> programslist = new list<SelectOption>();
        Service_Location__c sl;
        if (parentCntrller != null) {
            if (String.isEmpty(parentCntrller.incident.event.Service_Location)) {
                programslist.add(new SelectOption('','') );
            } else {
                sl = [SELECT Id, Alias__c, Program__c FROM Service_Location__c WHERE Id=:parentCntrller.incident.event.Service_Location];
                programslist.add(new SelectOption(sl.Id, sl.Alias__c + '-' + sl.Program__c));
            }
        }
        list<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                         FROM service_assignment__c
                                         GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c
                                         HAVING COUNT(service_location__r.id) > 0
                                         ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            if (sl != null && slPrgm.get('slId') == sl.Id) {
                continue;
            }
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        return programslist;
    }
    public MyRemoteMethods(TxnQueueResponseController controller){
    	this.parentCntrller = controller;
    }
    public MyRemoteMethods(){}

	public class SelOption {
		String id;
		String text;
		String email;
		String jobTitle;
		sobject obj;

		public SelOption(sobject obj){
			this.id = String.valueOf(obj.get('Id'));
			if (obj instanceof TMN_User__c){
				TMN_User__c tmnUser = (TMN_User__c) obj;
				this.text = tmnUser.name;
				this.email = tmnUser.email__c;
				this.jobTitle = tmnUser.job_title__c;
			}
			else if (obj instanceof Service_Assignment__c){}
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

    @RemoteAction public static list<SelOption> getResponsePlanManagers(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }
        Id sl = ( (Id) values.get('programLocation') );
        Id aliasForPrgram = [select Alias_lookup__c from Service_Location__c where id =: sl limit 1].Alias_lookup__c;

        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        Boolean searchAllLoc = Boolean.valueOf(values.get('searchAllLocations'));
        String jobStatusActive = 'Active';

        String strSQL = 'select Id, Name, email__c, job_title__c from TMN_User__c where Salesforce_User_Account__c != null ' +
                        ' and Job_Status__c =: jobStatusActive and Approval_Level__c > 2 and Name like : searchTerm';

        if (!searchAllLoc)
            strSQL  += ' and Alias_Lookup__c =: aliasForPrgram ';

        strSQL  += ' order by Name';
        system.debug(strSQL);
        list<SelOption> retVal = new list<SelOption>();
        for (TMN_User__c t : Database.query(strSQL)){
                retVal.add(new SelOption(t));
        }
        return retVal;
    }

}