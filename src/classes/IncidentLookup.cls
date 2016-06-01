public with sharing class IncidentLookup {
	@RemoteAction
	public static list<MyRemoteMethods.SelOption> findPBS(String params) {
		map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
		String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;

		list<MyRemoteMethods.SelOption> retVal = new list<MyRemoteMethods.SelOption>();
		map<Id, Service_Assignment__c> pbsSaMap = new map<Id, Service_Assignment__c>();

		list<Service_Assignment__c> serviceAssignments = [
			select Id, person_being_served__c, pbsLastName__c, pbsFirstName__c,
			       person_being_served__r.Age_Text__c, person_being_served__r.Gender__c
			  from Service_Assignment__c
			 where Status__c = 'Active'
			   and (pbsFirstName__c like :searchTerm OR pbsLastName__c like :searchTerm)
			 order by Name
		];
		for(Service_Assignment__c sa : serviceAssignments){
			pbsSaMap.put(sa.person_being_served__c, sa);
			retVal.add(new MyRemoteMethods.SelOption(sa));
		}
		for(Attachment headShot : [SELECT Id, Name,  ParentId from Attachment where Name LIKE 'HeadShot-Current%' and ParentId IN :pbsSaMap.keySet()]){
			Service_Assignment__c sa = (Service_Assignment__c) pbsSaMap.get(headShot.ParentId);
			//chose a dummy field on the SA object to carrry the pbs headShot attachment id
			sa.Flavor__c = '/servlet/servlet.FileDownload?file=' + headShot.id;
		}
		return retVal;
	}

	@RemoteAction
	public static list<MyRemoteMethods.SelOption> findStaff(String params){
		map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
		String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;

		list<MyRemoteMethods.SelOption> retVal = new list<MyRemoteMethods.SelOption>();
		for (TMN_User__c t : [select Id, Name, email__c, job_title__c from TMN_User__c where Job_Status__c = 'Active' and Name like :searchTerm order by Name]){
			retVal.add(new MyRemoteMethods.SelOption(t));
		}
		return retVal;
	}

	public Id serviceLocation { get; set; }
	public List<SelectOption> serviceLocations {
		private set;
		get {
			if (serviceLocations != null) {
				return serviceLocations;
			}
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
			Id currentServiceLocationId;
			if (sls.size() == 1) {
				currentServiceLocationId = String.valueOf(sls[0].id);
			}
			serviceLocations = Utility.getServiceLocations(currentServiceLocationId);
			return serviceLocations;
		}
	}

	public String eventType { get; set; }
	public List<SelectOption> eventTypes {
		private set;
		get {
			if (eventTypes != null) {
				return eventTypes;
			}
			eventTypes = new List<SelectOption>();
			Map<String, String> eventTypeMap = new Map<String, String>();
			for(Eval__c e : [
				select Composite__c, category__c, sub_category__c
				  from eval__c
				 where eval_type__r.Name IN ('Involved Party')
				   and Visible__c = true
				order by cat_seq_text__c, subcat_seq_text__c
			]){
				if (!eventTypeMap.containsKey(e.Composite__c)) {
					eventTypeMap.put(e.Composite__c, e.sub_category__c); // they want only the subCat
				}
			}
			eventTypes.add(new SelectOption('', ''));
			for (String composite: eventTypeMap.keySet()) {
				eventTypes.add(new SelectOption(composite, eventTypeMap.get(composite)));
			}
			return eventTypes;
		}
	}

	public Boolean finalizedIncidentsOnly { get; set; }

	public Id pbsId { get; set; }
	public Id staffId { get; set; }

	public Service_Assignment__c pbs {
		set;
		get {
			if (!String.isBlank(pbsId)) {
				pbs = [SELECT pbsLastName__c, pbsFirstName__c FROM Service_Assignment__c WHERE Id=:pbsId];
				return pbs;
			}
			return null;
		}
	}

	public TMN_User__c staff {
		set;
		get {
			if (!String.isBlank(staffId)) {
				staff = [SELECT Id, Name FROM Tmn_User__c WHERE Id = :staffId];
				return staff;
			}
			return null;
		}
	}
	public Boolean searchInitiated { get; set; }

	public List<Im_Incident__c> incidents { get; set; }

	public IncidentLookup() {
		searchInitiated = false;
	}

	public PageReference search() {
		// Here's how we narrow down the search: First by Program, then by
		// involved party (PBS & Staff), and lastly by event types
		Im_Incident__c[] incidentsInScope;
		if (!String.isBlank(serviceLocation)) {
			incidentsInScope = [
				SELECT Id
				  FROM Im_Incident__c
				 WHERE Service_Location__c = :serviceLocation
			];
		}
		String query =
			'SELECT Id, Im_Incident__c, Person_Being_Served_Involved__c, Staff_Involved__c' +
			'  FROM Im_InvolvedParty__c';

		if (!String.isBlank(pbsId) || !String.isBlank(staffId) || !String.isBlank(serviceLocation)) {
			query += ' WHERE ';
		}
		String[] conditions = new String[] {};
		if (!String.isBlank(serviceLocation)) {
			conditions.add(' Im_Incident__r.Service_Location__c = :serviceLocation');
		}
		if (!String.isBlank(pbsId) || !String.isBlank(staffId)) {
			String invQuery = '(';
			if (!String.isBlank(pbsId)) {
				invQuery += 'Person_Being_Served_Involved__c = :pbsId';
			}
			if (!String.isBlank(pbsId) && !String.isBlank(staffId)) {
				invQuery += ' OR ';
			}
			if (!String.isBlank(staffId)) {
				invQuery += 'Staff_Involved__c = :staffId';
			}
			invQuery += ')';
			conditions.add(invQuery);
		}
		query += String.join(conditions, ' AND ');
		System.debug('Involved Party Query: ' + query);

		Im_InvolvedParty__c[] involvedParties = Database.query(query);

		// At this point, the involved parties might still have records in them
		// that should not be in the search result, e.g. if the user specifies
		// both the Staff and the Person Being Served, right now involvedParties
		// have them ORed together, so we need to do some work to get rid of
		// unnecessary records.
		if (!String.isBlank(pbsId) && !String.isBlank(staffId)) {
			Im_InvolvedParty__c[] correctedInvolvedParties = new Im_InvolvedParty__c[]{};
			Map<Id, List<Im_InvolvedParty__c>> incidentInvolvedPartyMap = new Map<Id, List<Im_InvolvedParty__c>>();
			for (Im_InvolvedParty__c involvedParty: involvedParties) {
				if (!incidentInvolvedPartyMap.containsKey(involvedParty.Im_Incident__c)) {
					incidentInvolvedPartyMap.put(involvedParty.Im_Incident__c, new List<Im_InvolvedParty__c>());
				}
				incidentInvolvedPartyMap.get(involvedParty.Im_Incident__c).add(involvedParty);
			}
			for (Id incidentId: incidentInvolvedPartyMap.keySet()) {
				Boolean pbsFound = false;
				Boolean staffFound = false;
				for (Im_InvolvedParty__c involvedParty: incidentInvolvedPartyMap.get(incidentId)) {
					if (!String.isBlank(pbsId) && involvedParty.Person_Being_Served_Involved__c == pbsId) {
						pbsFound = true;
					}
					if (!String.isBlank(staffId) && involvedParty.Staff_Involved__c == staffId) {
						staffFound = true;
					}
				}
				if (pbsFound && staffFound) {
					correctedInvolvedParties.addAll(incidentInvolvedPartyMap.get(incidentId));
				}
			}
			involvedParties = correctedInvolvedParties;
		}
		Set<Id> involvedPartyIds = new Set<Id>();
		for (Im_InvolvedParty__c involvedParty: involvedParties) {
			involvedPartyIds.add(involvedParty.Id);
		}

		if (!String.isBlank(eventType)) {
			Eval_Value__c[] values = [
				SELECT Id, What_Id__c
				  FROM Eval_Value__c
				 WHERE Eval__r.Composite__c = :eventType
				   AND What_Id__c IN :involvedPartyIds
			];
			Set<String> involvedPartiesFromValues = new Set<String>();
			for (Eval_Value__c value: values) {
				involvedPartiesFromValues.add(value.What_Id__c);
			}
			Im_InvolvedParty__c[] correctedInvolvedParties = new Im_InvolvedParty__c[]{};
			for (Im_InvolvedParty__c involvedParty: involvedParties) {
				if (involvedPartiesFromValues.contains(involvedParty.Id)) {
					correctedInvolvedParties.add(involvedParty);
				}
			}
			involvedParties = correctedInvolvedParties;
		}

		Set<Id> incidentIds = new Set<Id>();
		for (Im_InvolvedParty__c involvedParty: involvedParties) {
			incidentIds.add(involvedParty.Im_Incident__c);
		}

		String incidentQuery =
			'SELECT Id, Name, Status__c, Final_Level__c, Date_Documented__c,' +
			'       Service_Location__r.Alias__c, Service_Location__r.Program__c' +
			'  FROM Im_Incident__c' +
			' WHERE Id IN :incidentIds';
		if (finalizedIncidentsOnly) {
			incidentQuery += ' AND Status__c = \'Incident-Finalized\'';
		}
		System.debug('Incident query: ' + incidentQuery);

		incidents = Database.query(incidentQuery);

		searchInitiated = true;
		return null;
	}
}
