public with sharing class IncidentInvestigation {
	public ApexPages.standardController stdController;
	public Im_Investigation__c investigation { get; set; }
	public Im_Incident__c incident { get; set; }
	public IncidentAssociation[] incidentAssociations { get; set; }
	public Decimal approvalLevel { get; set; }

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

	public Boolean isFinalized {
		get {
			return this.investigation.Status__c == 'Finalized';
		}
	}

	public Boolean isLocked {
		get {
			return isFinalized || this.investigation.Status__c == 'Disregarded';
		}
	}
	public Id currentManualAssociationId { get; set; }
	public Id currentAutoAssociationId { get; set; }
	public Id lookedUpIncidentId { get; set; }
	public Evaluation_Response__c currentManualAssociation { get; set; }
	public Evaluation_Response__c currentAutoAssociation { get; set; }

	private transient Map<String, String> internalInvestigatingParties;

	public Map<String, String> getInternalInvestigatingParties() {
		if (internalInvestigatingParties != null) {
			return internalInvestigatingParties;
		}
		internalInvestigatingParties = new Map<String,String>();
		if (!String.Isempty(this.investigation.Internal_Investigating_Parties__c)) {
			for (TMN_User__c u : [SELECT Id, Name FROM TMN_User__c WHERE Id IN :this.investigation.Internal_Investigating_Parties__c.split(',')]) {
				internalInvestigatingParties.put(u.Id, u.Name);
			}
		}
		return internalInvestigatingParties;
	}

	public String internalInvestigatingPartyNames {
		get {
			return String.join(getInternalInvestigatingParties().values(), ', ');
		}
	}

	public IncidentInvestigation(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		if(!test.isRunningTest()){
			this.stdController.addFields(new List<String>{
				'Status__c',
				'Im_Incident__c',
				'Im_Incident__r.Id',
				'Im_Incident__r.Name',
				'Im_Incident__r.CreatedDate'
			});
		}
		this.investigation = (IM_Investigation__c) stdController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (params.containsKey('mode')) {
			this.mode = params.get('mode');
		} else {
			this.mode = 'view';
		}
		this.incidentAssociations = getAssociations(this.investigation.Id);

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
	}

	public PageReference createNewManualAssociation() {
		this.currentManualAssociation = getNewResponse(true, this.investigation.Id);
		return null;
	}

	public PageReference createNewAutoAssociation() {
		this.currentAutoAssociation = getNewResponse(false, this.investigation.Id);
		System.debug(lookedUpIncidentId);
		Im_Incident__c lookedUpIncident = [
			SELECT Id, Name, Date_Documented__c, Final_Level__c, Service_Location__r.Name
			  FROM Im_Incident__c
			 WHERE Id=:lookedUpIncidentId
			];
		currentAutoAssociation.ImIncident__r = lookedUpIncident;
		return null;
	}

	private static Evaluation_Response__c getNewResponse(Boolean manual, Id investigationId) {
		return new Evaluation_Response__c(
				IncidentInvestigation__c = investigationId,
				RecordTypeId = Utility.getEvaluationResponseRecordType(manual ? 'Manual Incident Investigation JO' : 'Auto Incident Investigation JO'),
				Date_of_Association__c = DateTime.now(),
				Association_Made_By__c = UserInfo.getName()
		);
	}

	private static List<IncidentAssociation> getAssociations(Id investigationId) {
		Evaluation_Response__c[] responses = [
			SELECT Id, ImIncident__r.Name, ImIncident__r.Date_Documented__c, ImIncident__r.Final_Level__c,
			       ImIncident__r.Service_Location__r.Name, Source__c, Comment__c, Incident_Number__c,
			       Program_Association__c, Date_of_Incident__c, Association_Made_By__c,
			       Date_of_Association__c, Final_Level__c
			  FROM Evaluation_Response__c
			 WHERE RecordType.Name IN ('Manual Incident Investigation JO', 'Auto Incident Investigation JO')
			   AND IncidentInvestigation__c = :investigationId
		];
		IncidentAssociation[] associations = new IncidentAssociation[] {};
		for (Evaluation_Response__c response: responses) {
			associations.add(new IncidentAssociation(response));
		}
		return associations;
	}

	public PageReference saveManualAssociation() {
		if (IncidentInvestigationModel.validateManualAssociation(this.currentManualAssociation)) {
			upsert this.currentManualAssociation;
			this.incidentAssociations = getAssociations(this.investigation.Id);
		}
		return null;
	}

	public PageReference saveAutoAssociation() {
		this.currentAutoAssociation.ImIncident__c = lookedUpIncidentId;
		if (IncidentInvestigationModel.validateAutoAssociation(this.currentAutoAssociation)) {
			upsert this.currentAutoAssociation;
			this.incidentAssociations = getAssociations(this.investigation.Id);
		}
		return null;
	}

	public PageReference save() {
		if (!IncidentInvestigationModel.saveValidation(this.investigation)) {
			return null;
		}
		upsert investigation;
		return new PageReference('/' + investigation.Id);
	}

	public PageReference disregard() {
		update new Im_Investigation__c(
				Id = investigation.Id,
				Status__c = 'Disregarded'
				);
		return null;
	}

	public PageReference finalize() {
		if (!IncidentInvestigationModel.finalizeValidation(this.investigation)) {
			return null;
		}
		update new Im_Investigation__c(
				Id = investigation.Id,
				Status__c = 'Finalized'
				);
		this.investigation.Status__c = 'Finalized';
		return null;
	}

	@RemoteAction
	public static List<MyRemoteMethods.SelOption> findInternalInvestigatingParties(String params){
		map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
		String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;

		list<MyRemoteMethods.SelOption> retVal = new list<MyRemoteMethods.SelOption>();
		// TODO need to figure out Legal and QI Staff here
		for (TMN_User__c t: IncidentInvestigationModel.findInternalInvestigatingParties(searchTerm)){
			retVal.add(new MyRemoteMethods.SelOption(t));
		}
		return retVal;
	}

	class IncidentAssociation {
		private Boolean manualEntry;
		private Evaluation_Response__c response;

		public String incidentNumber { get; set; }
		public DateTime dateOfIncident { get; set; }
		public Decimal finalLevel { get; set; }
		public String programAssociation { get; set; }
		public String source { get; set; }
		public String comment { get; set; }
		public DateTime dateOfAssociation { get; set; }
		public String associationMadeBy { get; set; }

		public IncidentAssociation(Evaluation_Response__c response) {
			this.response = response;
			manualEntry = false;

			if (this.response.RecordTypeId == Utility.getEvaluationResponseRecordType('Manual Incident Investigation JO')) {
				manualEntry = true;
			}

			if (manualEntry) {
				incidentNumber = this.response.Incident_Number__c;
				dateOfIncident = this.response.Date_of_Incident__c;
				finalLevel = this.response.Final_Level__c;
				programAssociation = this.response.Program_Association__c;
			} else {
				incidentNumber = this.response.ImIncident__r.Name;
				dateOfIncident = this.response.ImIncident__r.Date_Documented__c;
				if (this.response.ImIncident__r.Final_Level__c == null) {
					finalLevel = 0;
				} else {
					finalLevel = Decimal.valueOf(this.response.ImIncident__r.Final_Level__c);
				}
				programAssociation = this.response.ImIncident__r.Service_Location__r.Name;
			}
			source = this.response.Source__c;
			comment = this.response.Comment__c;
			associationMadeBy = this.response.Association_Made_By__c;
			dateOfAssociation = this.response.Date_of_Association__c;
		}
	}

	/****  Addendum log entries */

	private transient List<EvaluationResponseWrapper> addendumEntries;
	public List<EvaluationResponseWrapper> getAddendumEntries() {
		if ( addendumEntries != null) {
			return addendumEntries;
		}
		addendumEntries = new List<EvaluationResponseWrapper>();
		List<Evaluation_Response__c> entries = [
			select id, type__c, narrative_note__c, createdby.name, createdbyid, lastmodifiedby.name, lastmodifiedbyid, createddate, lastmodifieddate, disregard__c
			  from evaluation_response__c
			 where incidentinvestigation__c = :investigation.Id
			   and recordtype.name = 'Im_InvestigationLogEntry'
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

	public EvaluationResponseWrapper currEntry { get; set; }
	public ID currEntryId { get; set ; }

	public pageReference showEditLogEntry() {
		List<Evaluation_Response__c> evr = [
			select id, type__c, narrative_note__c, createdby.name, createdbyid, lastmodifiedby.name, lastmodifiedbyid, createddate, lastmodifieddate, disregard__c
			  from evaluation_response__c
			 where IncidentInvestigation__c = :investigation.id
			   and id= :currEntryId
			   and recordtype.name = 'Im_InvestigationLogEntry'
		];

		if (evr.size() > 0 )
			currEntry = new EvaluationResponseWrapper(evr[0]);
		else
			currEntry = new EvaluationResponseWrapper( new Evaluation_Response__c( IncidentInvestigation__c = investigation.id, recordtypeid = utility.getEvaluationResponseRecordType('Im_InvestigationLogEntry')) );

		return null;
	}

	public pageReference showAddLogEntry() {
		currEntry = new EvaluationResponseWrapper( new Evaluation_Response__c( IncidentInvestigation__c = investigation.id, recordtypeid = utility.getEvaluationResponseRecordType('Im_InvestigationLogEntry')) );
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
				 where incidentinvestigation__c= :investigation.Id
				   and id= :currEntryId
				   and recordtype.name = 'Im_InvestigationLogEntry'
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