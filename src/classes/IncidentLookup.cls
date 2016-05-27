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

	public Service_Location__c serviceLocation { get; set; }
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

	public Id pbsId { get; set; }
	public Id staffId { get; set; }
	public Boolean searchInitiated { get; set; }

	public List<Im_Incident__c> incidents { get; set; }

	public IncidentLookup() {
		searchInitiated = false;
	}

	public PageReference search() {
		String query = '' +
			'SELECT Id, Name, Status__c, Final_Level__c, Date_Documented__c, Service_Location__r.Alias__c, Service_Location__r.Program__c ' +
			'  FROM Im_Incident__c ' +
			' WHERE Status__c LIKE \'Incident%\'' +
			'   AND Status__c <> \'Incident-Disregarded\'';

		incidents = Database.query(query);
		searchInitiated = true;
		return null;
	}
}