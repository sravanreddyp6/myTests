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

	public Boolean isQualifyingStage {
		get {
			if (this.incident == null) {
				return false;
			}
			return this.incident.Status__c == 'Event-Qualifying';
		}
	}

	public Boolean isIncidentStage {
		get {
			if (this.incident == null) {
				return false;
			}
			return this.incident.Status__c.indexOf('Incident') != -1;
		}
	}


	public Integer calculatedLevel {
		get {
			return 0;
		}
	}

	public String calculatedLevelExplanation {
		get {
			return 'Dummy Explanation';
		}
	}


	public IncidentManagement(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		if(!test.isRunningTest()){
			this.stdController.addFields(new List<String>{
				'Status__c'
			});
		}
		this.incident = (IM_Incident__c) stdController.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();

		if (this.incident.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else {
			// This is a new Qualifier
			this.mode = 'edit';
			this.incident.Status__c = 'Event-Qualifying';
			this.incident.Reported_By__c = UserInfo.getUserId();

			list<TMN_User__c> tmnUser = [
				SELECT id, name, Accountable_Approval_Manager__c,
				       Accountable_Manager_Mentor_Email__c, Alias_lookup__c
				  FROM TMN_User__c
				 WHERE Salesforce_User_Account__c =:UserInfo.getUserId()
			];
			if (tmnUser.size() != 1) {
				throw new Utility.CustomException(Utility.IMPLEMENTATION_EXCEPTION_MESSAGE);
			}
			Service_Location__c[] sls = Utility.getServiceLocationsForTmnUser(tmnUser[0]);
			if (sls.size() == 1) {
				//get the list of service locations for my alias, if more than one, then user would have to pick one else default that to this one
				this.incident.Service_Location__c = String.valueOf(sls[0].id);
			}
			TMN_User__c manager = Utility.getManagerForTmnUser(tmnUser[0]);
			this.incident.Supervisor__c = manager.Id;
		}
	}

	private transient Map<String, String> notifiedStaffs;

	public Map<String, String> getNotifiedStaffs() {
			if (notifiedStaffs != null) {
				return notifiedStaffs;
			}
			notifiedStaffs = new Map<String,String>();
			if (!String.Isempty(this.incident.Notified_Staff__c)) {
				for (TMN_User__c u : [SELECT Id, Name FROM TMN_User__c WHERE Id IN :this.incident.Notified_Staff__c.split(',')]){
					notifiedStaffs.put(u.Id, u.Name);
				}
			}
			return notifiedStaffs;
	}

	public String notifiedStaffNames {
		get {
			return String.join(getNotifiedStaffs().values(), ', ');
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

	public String agenciesNotifiedOptions {
		get {
			String str;
			set<String> selectedOptns = new set<String>();
			set<String> options = new set<String>{'Funding Source','Local Protective Services','Family','Guardian','Law Enforcement'};
			if (!String.IsEmpty(this.incident.Agencies_Notified__c)){
				 options.addAll(this.incident.Agencies_Notified__c.split(','));
				 selectedOptns.addAll(this.incident.Agencies_Notified__c.split(','));
			}
			for(String s : options){
			 	str += String.format('<option value="{0}"{2}>{1}</option>', new String[]{s,s,(selectedOptns.contains(s) ? 'selected="selected"' : '')} );
			}
			return str;
		}
	}

	@RemoteAction
	public static List<MyRemoteMethods.SelOption> getIncidentReviewers(String params) {
		map<String, String> values = (Map<String, String>)JSON.deserialize(params, map<String, String>.class);
		if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) {
			throw new Utility.CustomException('Missing program location.');
		}
		Id sl = ((Id) values.get('programLocation'));
		String state = [
			select Id, State__c from Service_Location__c where id =:sl limit 1
		].State__c;
		String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;

		list<MyRemoteMethods.SelOption> retVal = new list<MyRemoteMethods.SelOption>();
		for (TMN_User__c t : IncidentModel.findReviewers(searchTerm, state)){
			retVal.add(new MyRemoteMethods.SelOption(t));
		}
		return retVal;
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
	public static list<String> getEventDetails(String involvedPartyStr, Boolean isLocked) {
		return IncidentInvolvedPartyModel.getInvolvedPartyDetails(IncidentModel.Stage.QUALIFYING, Id.valueOf(involvedPartyStr), isLocked);
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

	public PageReference save() {
		return this.save(true);
	}

	public PageReference save(Boolean validateNeeded) {
		if (!validateFields(this.incident)) {
			return null;
		}
		upsert this.incident;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.incident.Id);
		page.setRedirect(true);
		return page;
	}

	public PageReference close() {
		this.incident.Status__c = 'Event-Closed';
		return this.save(false);
	}

	public PageReference qualifyEvent() {
		this.incident.Status__c = 'Incident-Draft';
		return this.save(false);
	}

	private transient Boolean isLocked;

	public Boolean getIsLocked() {
			if (this.isLocked == null) {
				this.isLocked = IncidentModel.checkLocked(
					this.incident.Status__c.indexOf('Qualifying') != -1 ? IncidentModel.Stage.QUALIFYING : IncidentModel.Stage.INCIDENT,
					this.incident
				);
			}
			return this.isLocked;
	}

	/**
	 * Return false if error found, true if otherwise
	 */
	private static Boolean validateFields(IM_Incident__c incident) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (incident.What_Happened__c == '' || incident.What_Happened__c == null) {
			incident.What_Happened__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (incident.Service_Location__c == null) {
			incident.Service_Location__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (incident.When_Did_It_Happen__c == null) {
			incident.When_Did_It_Happen__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		} else if (incident.When_Did_It_Happen__c > DateTime.now()) {
			incident.When_Did_It_Happen__c.addError('The value for "When did it happen?" cannot be in the future. Please adjust the "When did it happen?" for the event.');
			noError = false;
		}
		if (incident.When_was_the_Supervisor_Notified__c == null) {
			incident.When_was_the_Supervisor_Notified__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (incident.When_Did_It_Happen__c != null && incident.When_was_the_Supervisor_Notified__c != null && incident.When_Did_It_Happen__c > incident.When_was_the_Supervisor_Notified__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The value "When was the Supervisor notified?" cannot occur prior to the date/time of "When did it happen?".'));
			noError = false;
		}
		return noError;
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
