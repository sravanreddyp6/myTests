public with sharing class IncidentManagement {
	public ApexPages.StandardController stdController;
	public IM_Incident__c incident { get; set; }
	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit';
		}
	}

	public IncidentManagement(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		this.incident = (IM_Incident__c) stdController.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();

		this.mode = 'view';
		if (params.containsKey('mode')) {
			this.mode = params.get('mode');
		}
	}

	public Map<String, String> notifiedStaffs {
		set;
		get {
			notifiedStaffs = new Map<String,String>();
			if (!String.Isempty(this.incident.Notified_Staff__c)) {
				for (TMN_User__c u : [SELECT Id, Name FROM TMN_User__c WHERE Id IN :this.incident.Notified_Staff__c.split(',')]){
					notifiedStaffs.put(u.Id, u.Name);
				}
			}
			return notifiedStaffs;
		}
	}

	public List<SelectOption> serviceLocations {
		private set;
		get {
			serviceLocations = new list<SelectOption>();
			for (AggregateResult slPrgm : [
					SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
					  FROM service_assignment__c
					GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c
					HAVING COUNT(service_location__r.id) > 0
					ORDER BY service_location__r.program__c
			]) {
				serviceLocations.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
			}
			return serviceLocations;
		}
	}

	@RemoteAction
	public static List<MyRemoteMethods.IM_PartyData> getInvolvedParties(Id incidentId) {
		return MyRemoteMethods.getInvolvedParties(incidentId);
	}

	@RemoteAction
	public static list<MyRemoteMethods.SelOption> getStaffForProgram(String params) {
		return MyRemoteMethods.getStaffForTheProgram(params);
	}

	@RemoteAction
	public static list<MyRemoteMethods.SelOption> getPBSForProgram(String params) {
		return MyRemoteMethods.getPbsForTheProgram(params);
	}

	@ReadOnly
	@RemoteAction
	public static list<String> getEventDetails(String involvedPartyStr) {
		return IncidentInvolvedPartyModel.getInvolvedPartyDetails(IncidentModel.Stage.QUALIFYING, Id.valueOf(involvedPartyStr));
	}

	@ReadOnly
	@RemoteAction
	public static String getInvolvedPartyEventTypes(String invPrtyData){
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

	@RemoteAction
	public static list<String> saveFields(Id involvedPartyId, String jsonForm) {
		return IncidentInvolvedPartyModel.saveFields(IncidentModel.Stage.QUALIFYING, involvedPartyId, jsonForm);
	}

	public static Map<String, Integer> calculateLevel(Eval_Value__c[] values) {
		Map<String, Integer> resultMap = new Map<String, Integer>();
		// Put all of the values into different "buckets" based on their eval section id
		Map<String, Eval_Value__c[]> sectionMap = new Map<String, Eval_Value__c[]>();
		for (Eval_Value__c value: values) {
			if (value.Eval__r.Eval_Type__r.Name != 'Involved Party') {
				// right now Incident Management/Involved Party is the only Eval Type that uses this/
				// computation
				continue;
			}
			String composite = value.Eval__r.Composite__c + '~' + value.Eval_Section_Id__c;
			if (!sectionMap.containsKey(value.Eval_Section_Id__c)) {
				sectionMap.put(composite, new List<Eval_Value__c>());
			}
			sectionMap.get(composite).add(value);
		}
		return resultMap;
	}

}