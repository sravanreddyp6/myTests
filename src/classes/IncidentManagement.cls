public with sharing class IncidentManagement implements AuthenticatedAction {
	public ApexPages.StandardController stdController;
	public IM_Incident__c incident { get; set; }
	public String mode { get; set; }
	public Decimal approvalLevel { get; set; }

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

	public String name {
		get {
			if (this.incident.Name == '' || this.incident.Name == null) {
				return 'Create Qualifier';
			}
			return this.incident.Name + ' - ' + this.incident.Status__c.substringAfter('-');
		}
	}

	public IncidentManagement() {
		// This is only used for esigning purpose. Don't use it otherwise!
	}

	public IncidentManagement(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		if(!test.isRunningTest()){
			this.stdController.addFields(new List<String>{
				'Status__c',
				'Name',
				'CreatedDate'
			});
		}
		this.incident = (IM_Incident__c) stdController.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();


		// need the TMN User regardless of incident status
		list<TMN_User__c> tmnUser = [
			SELECT id, name, Accountable_Approval_Manager__c,
			       Accountable_Manager_Mentor_Email__c, Alias_lookup__c, Approval_Level__c
			  FROM TMN_User__c
			 WHERE Salesforce_User_Account__c =:UserInfo.getUserId()
			];
		if (tmnUser.size() != 1) {
			throw new Utility.CustomException(Utility.IMPLEMENTATION_EXCEPTION_MESSAGE);
		}
		approvalLevel = tmnUser[0].approval_level__c;


		if (this.incident.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else {
			// This is a new Qualifier
			this.mode = 'edit';
			this.incident.Status__c = 'Event-Qualifying';
			this.incident.Date_Documented__c = DateTime.now();
			this.incident.Reported_By__c = UserInfo.getUserId();

			Service_Location__c[] sls = Utility.getServiceLocationsForTmnUser(tmnUser[0]);
			if (sls.size() == 1) {
				//get the list of service locations for my alias, if more than one, then user would have to pick one else default that to this one
				this.incident.Service_Location__c = String.valueOf(sls[0].id);
			}
			TMN_User__c manager = Utility.getManagerForTmnUser(tmnUser[0]);
			if (manager != null) {
				this.incident.Supervisor__c = manager.Id;
			}

		}
	}

	public void reloadCalculatedLevel() {
		Im_Incident__c inc = [
			SELECT Id, Calculated_Level__c, Calculated_Level_Explanation__c
			  FROM Im_Incident__c
			 WHERE Id=:this.incident.Id
			];
		this.incident.Calculated_Level__c = inc.Calculated_Level__c;
		this.incident.Calculated_Level_Explanation__c = inc.Calculated_Level_Explanation__c;
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
			serviceLocations = IncidentModel.getServiceLocations(this.incident.Service_Location__c);
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

	private transient List<EvaluationResponseWrapper> addendumEntries;
	public transient List<String> columnsToFetch { get; private set ;}
	public List<EvaluationResponseWrapper> getAddendumEntries() {
		if ( addendumEntries != null) {
			return addendumEntries;
		}
		addendumEntries = new List<EvaluationResponseWrapper>();
		List<Evaluation_Response__c> entries = [
			select id, narrative_note__c, createdby.name, createdbyid, lastmodifiedby.name, lastmodifiedbyid, createddate, lastmodifieddate, disregard__c from evaluation_response__c
			 where imincident__c = :incident.Id
			   and recordtype.name = 'Im_AddendumLogEntry'
			 order by lastmodifieddate desc LIMIT 100
			];
		for ( Evaluation_Response__c e: entries) {
			addendumEntries.Add( new EvaluationResponseWrapper(e));
		}
		return addendumEntries;
	}
	public class EvaluationResponseWrapper {
		public Evaluation_Response__c evalresp { get; set; }
		public String briefDesc { get;  set; }

		public EvaluationResponseWrapper( Evaluation_Response__c e) {
			evalresp = e;
			if ( e.narrative_note__c != null && e.Narrative_Note__c.length() > 101 )
				briefDesc = e.Narrative_Note__c.substring(0, 99) + '...';
			else
				briefDesc = e.Narrative_Note__c;
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
		List<String> involvedPartyDetails = IncidentInvolvedPartyModel.saveFields(IncidentModel.Stage.QUALIFYING, involvedPartyId, jsonForm);
		IncidentModel.updateCalculatedLevel(involvedPartyId);
		return involvedPartyDetails;
	}

	public PageReference save() {
		return this.save(true);
	}

	public PageReference save(Boolean validateNeeded) {
		if (!validateFields(this.incident, IncidentModel.Stage.QUALIFYING, '0')) {
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
		IncidentModel.updateCalculatedLevel(this.incident);
		return this.save(false);
	}

	public PageReference readyForReview() {
		if (!validateFields(this.incident, IncidentModel.Stage.REVIEW, this.incident.Calculated_Level__c)) {
			return null;
		}
		this.incident.Status__c = 'Incident-Ready for Review';
		update this.incident;
		// TODO delete tasks doesn't work right now due to permissions
		//IncidentModel.deleteExistingReadyForReviewTasks(new Im_Incident__c[] { this.incident });
		IncidentModel.createReadyForReviewTasks(new Im_Incident__c[] { this.incident });
		return null;
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
	private static Boolean validateFields(IM_Incident__c incident, IncidentModel.Stage stage, String calculatedLevel) {
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
		if (stage == IncidentModel.Stage.REVIEW) {
			if (incident.Final_Level__c == null || incident.Final_Level__c == '') {
				incident.Final_Level__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			} else if (incident.Final_Level__c != calculatedLevel && (incident.Final_Level_Reason__c == null || incident.Final_Level_Reason__c == '')) {
				incident.Final_Level_Reason__c.addError(errorGenerator.generate('Reason for Final Level is required, since it is different from the calculated level'));
				noError = false;
			}
			if (incident.Incident_Reviewer__c == null) {
				incident.Incident_Reviewer__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
		}
		return noError;
	}

	@ReadOnly
	@RemoteAction
	public static map<string, object> validateEvent(String eventId) {
		return IncidentModel.validateEvent(eventId);
	}


	public PageReference handle(Id recordId, Id userId) {
		IncidentModel.finalizeIncident(new Im_Incident__c(Id = recordId), userId);
		return new PageReference('/' + recordId);
	}

	/**** IM-3 - Addendum log entries on finalized incidents */
	public EvaluationResponseWrapper currEntry { get; set; }
	public ID currEntryId { get; set ; }

	public pageReference showEditLogEntry() {
		List<Evaluation_Response__c> evr = [
			select id, narrative_note__c, createdby.name, createdbyid, lastmodifiedby.name, lastmodifiedbyid, createddate, lastmodifieddate, disregard__c
			  from evaluation_response__c
			 where imincident__c = :incident.Id
			   and id= :currEntryId
			   and recordtype.name = 'Im_AddendumLogEntry'
			];

		if (evr.size() > 0 )
			currEntry = new EvaluationResponseWrapper(evr[0]);
		else
			currEntry = new EvaluationResponseWrapper( new Evaluation_Response__c( imincident__c = incident.id, recordtypeid = utility.getEvaluationResponseRecordType('Im_AddendumLogEntry')) );

		return null;
	}

	public pageReference showAddLogEntry() {
		currEntry = new EvaluationResponseWrapper( new Evaluation_Response__c( imincident__c = incident.id, recordtypeid = utility.getEvaluationResponseRecordType('Im_AddendumLogEntry')) );
		return null;
	}

	public void saveLogEntry() {

		try {
			upsert( currEntry.evalresp);
			addendumEntries = null; // causes a refresh

		} catch (DMLException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
					'An error occurred saving the Log Entry. ' + ex.getMessage()));
			system.debug(ex);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
					'An error occurred saving the Log Entry. ' + e.getMessage()));
			system.debug(e);
		}
	}

	public void disregardLogEntry() {
		try {
			List<Evaluation_Response__c> evr = [
				select id, disregard__c from evaluation_response__c
				 where imincident__c = :incident.Id
				   and id= :currEntryId
				   and recordtype.name = 'Im_AddendumLogEntry'
			];
			if ( evr.size() > 0 ) {
				evr[0].disregard__c = true;
				update(evr);
			}
			addendumEntries = null;
		} catch (DMLException ex) {
			system.debug(ex);
		} catch (Exception e) {
			system.debug(e);
		}
	}

}