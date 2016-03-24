public without sharing class Im_Report_Incident {
	private static String OPTION_TEMPLATE_STR = '<option value="{0}"{2}>{1}</option>';
	private map<String, String> requestParams;
	public boolean editMode {get; set;}
	public IncidentWrapper event {get;set;}
	public Id eventId {get; set;} 
	public String actionType {get; set;}
	
	private transient Boolean isLocked;
	public Boolean getIsLocked(){
		if (this.isLocked == null){
			// if the event is disregarded or submitted
			// OR this is the event that is a result of of an event submit
			// OR if there is a lock on the event because of its submit
			this.isLocked = this.event.status == 'Event-Submitted'
							|| this.event.status == 'Event-Disregarded'
							|| String.IsNotBlank(this.event.reportedEvent) 
							|| Approval.isLocked(this.event.Id);
		}
		return this.isLocked;
	}
	
	public String getEventTitle(){
		return (String.IsBlank(this.event.Identifier) ? 'Report Event' : this.event.Name + ' - ' +  this.event.status.substringAfter('-'));
	}
	
	public list<SelectOption> getWheredidItHappenOptions(){
		list<SelectOption> lst = new list<SelectOption>();
		lst.add(new SelectOption('',''));
		lst.addAll(Utility.getPicklistValues(new Im_Incident__c(), 'Where_did_it_happen__c'));
		return lst;
	}
	
	public String getOptsForAgenciesNotified(){
		String str;
		set<String> selectedOptns = new set<String>();
		set<String> options = new set<String>{'Funding Source','Local Protective Services','Family','Guardian','Law Enforcement'};
		if (!String.IsEmpty(this.event.Agencies_notified)){
			 options.addAll(this.event.Agencies_notified.split(','));
			 selectedOptns.addAll(this.event.Agencies_notified.split(','));
		}
		for(String s : options){
		 	str += String.format(OPTION_TEMPLATE_STR, new String[]{s,s,(selectedOptns.contains(s) ? 'selected="selected"' : '')} );
		}
		return str;
	}
	
    public Im_Report_Incident(){
    	this((Id) ApexPages.CurrentPage().getParameters().get('Id'));
    }
	
	public Im_Report_Incident(String inputs){
		if (inputs instanceof Id) this((Id) inputs);
		else {
	        this.editMode = true;
			Im_Incident__c incident = new Im_Incident__c(Reported_By__c = UserInfo.getUserId(), Status__c='Event-Draft', Date_Documented__c= system.now());
	        this.event = new IncidentWrapper(incident);
	        this.event.Reported_By_Name = UserInfo.getName();
	        
	        list<TMN_User__c> tmnUser = [SELECT id, name, Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c, Alias_lookup__c from TMN_User__c where Salesforce_User_Account__c =: UserInfo.getUserId()];
	        list<TMN_User__c> accountableMgr = [SELECT id, name from TMN_User__c where email__c =: tmnUser[0].Accountable_Manager_Mentor_Email__c];
	        	        
	        if (tmnUser.size() != 1 || accountableMgr.size() != 1)
				throw new CustomException('ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.');
			else {
				//get the list of service locations for my alias, if more than one, then user would have to pick one else default that to this one
				list<service_location__c> sls = [select id from service_location__c where Alias_lookup__c =: tmnUser[0].Alias_lookup__c and status__c = 'Active'];
				if (sls.size() == 1) this.event.Service_Location = String.valueOf(sls[0].id);
				this.event.Supervisor = accountableMgr[0].Id;
		        this.event.Supervisor_Name = tmnUser[0].Accountable_Approval_Manager__c;
		        this.event.Supervisor_for_Location = accountableMgr[0].Id;
				this.event.Supervisor_for_Location_Name = accountableMgr[0].Name;
			}	
		}
	}
	class CustomException extends Exception {}
			
	public Im_Report_Incident(Id eventId) {
        String strSQL =  'SELECT Id, OwnerId, Name, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, Reported_By__c, Reported_By__r.name, ';
        	   strSQL += 'Date_Documented__c, Where_did_it_happen__c, When_did_it_happen__c, When_was_the_Supervisor_notified__c, Supervisor__c, Supervisor_Name__c, Service_Location__c, ';
        	   strSQL += 'What_Happened__c, ReportedEvent__c, Status__c, Notified_Staff__c, Identifier__c, Supervisor_for_Location__c,Supervisor_for_Location__r.Name, Agencies_notified__c, Agencies_notified_narrative__c	 FROM Im_Incident__c WHERE Id = \'' + eventId + '\'';
        Im_Incident__c incident = (Im_Incident__c) Database.query(strSQL)[0];
        this.event = new IncidentWrapper(incident);
        this.eventId = eventId;
        editMode = false;
    }

	public class IncidentWrapper {
	    public Id id {get;set;}
	    public String Identifier {get;set;}
	    public String name {get;set;}
	    public String reportedEvent {get;set;}
	    public datetime Date_Documented {get;set;}
	    public datetime When_did_it_happen {get;set;}
	    public datetime When_was_the_Supervisor_notified {get;set;}
	    public String Reported_By {get;set;}
	    public String Reported_By_Name {get;set;}
	    public String Status {get;set;}
		public String Supervisor {get;set;}
	    public String Supervisor_Name {get;set;}
		public String Supervisor_for_Location {get;set;}
		public String Supervisor_for_Location_Name {get;set;}
	    public String What_Happened {get;set;}
	    public String Where_did_it_happen {get;set;}
	    public String Notified_Staff {get;set;}
	    public map<String,String>  getNotifiedStaffJSON(){
	    	map<String,String> staffnotified = new map<String,String>();
	    	if (!String.Isempty(this.notified_Staff)) {
	    		for (TMN_User__c u : [select Id, Name, email__c, job_title__c  from TMN_User__c where id IN : this.notified_Staff.split(',')]){
	    			staffnotified.put(u.id, u.name);
	    		}
	    	} 
	    	return staffnotified;
	    }
	    public String getNotified_Staff_Names(){
	    	list<String> staffnotified = new list<String>();
	    	if (!String.Isempty(this.notified_Staff)) {
	    		for (TMN_User__c u : [select id, name from TMN_User__c where id IN : this.notified_Staff.split(',')]){
	    			staffnotified.add(u.name);
	    		}
	    	} 
	    	return String.join(staffnotified, ', ');
	    }
	    public String Agencies_notified {get;set;}
	    public String Agencies_notified_narrative {get;set;}
	    public String createdbyName {get;set;}
	    public String lastmodifiedbyName{get;set;}
	    public datetime CreatedDate {get;set;}
	    public datetime LastModifiedDate {get;set;}
	    public String Service_Location {get;set;}
	    public String getService_Location_Name(){
	    	if (Service_Location instanceof Id) {
	    		Service_Location__c sl = [select Alias__c, program__c from service_location__c where id =: Service_Location limit 1 ]; 
	    		return sl.Alias__c + '-' + sl.program__c;
	    	} 
	    	return '';
	    }


	    public IncidentWrapper(){}
	    public IncidentWrapper(Im_Incident__c incident){
			this.id = incident.id;
			this.Identifier = String.valueOf(incident.Identifier__c);
			this.name = incident.Name;
			this.reportedEvent = incident.ReportedEvent__c;
			this.Date_Documented = incident.Date_Documented__c;
			this.When_did_it_happen = incident.When_did_it_happen__c;
			this.When_was_the_Supervisor_notified = incident.When_was_the_Supervisor_notified__c;
			this.Reported_By = incident.Reported_By__c;
			this.Reported_By_Name = incident.Reported_By__r.Name;
			this.Status = incident.Status__c;
			this.Supervisor = incident.Supervisor__c;
			this.Supervisor_Name = incident.Supervisor_Name__c;
			this.What_Happened = incident.What_Happened__c;
			this.Where_did_it_happen = incident.Where_did_it_happen__c;
			this.Notified_Staff = incident.Notified_Staff__c;
			this.Agencies_notified = incident.Agencies_notified__c;
			this.Agencies_notified_narrative = incident.Agencies_notified_narrative__c;
			this.createdbyName = incident.createdby.Name;
			this.lastmodifiedbyName = incident.lastmodifiedby.Name;
			this.CreatedDate = incident.CreatedDate;
			this.LastModifiedDate = incident.LastModifiedDate;
			this.Supervisor_for_Location = incident.Supervisor_for_Location__c;
			this.Supervisor_for_Location_Name = incident.Supervisor_for_Location__r.Name;
			this.Service_Location = incident.Service_Location__c;
	    }
	    public Im_Incident__c incidentSObject(){
	        return new Im_Incident__c(
					        id = this.id,
							Supervisor__c = this.Supervisor,
							Date_Documented__c = this.Date_Documented,
							When_did_it_happen__c = this.When_did_it_happen,
							When_was_the_Supervisor_notified__c = this.When_was_the_Supervisor_notified,
							Reported_By__c = this.Reported_By,
							Status__c = this.Status,
							What_Happened__c = this.What_Happened,
							Where_did_it_happen__c = this.Where_did_it_happen,
							Notified_Staff__c = this.Notified_Staff,
							Agencies_notified__c = this.Agencies_notified,
			 				Agencies_notified_narrative__c = this.Agencies_notified_narrative,
							Supervisor_for_Location__c = ( (this.Supervisor_for_Location instanceof Id) ? (Id) this.Supervisor_for_Location : null),
							Service_Location__c = ( (this.Service_Location instanceof Id) ? (Id) this.Service_Location : null)
							);
	    }
	    
	}
    
    public pagereference mySave(){
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Update Incident';
        txn.requested_date_time__c = DateTime.Now();
        if (!String.IsEmpty(actionType)) this.event.status = actionType;
        Map<String, String> inputs = new Map<String, String>{'payload.event' => json.serialize(this.event.incidentSObject())};
        txn.input_params__c = json.serialize(inputs);
        system.debug('form values: ' + inputs);
        try { 
            insert txn;
            PageReference pr =  Page.ReportEvent;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public pagereference myEdit(){
        this.editMode = true;
        return null;
    }
    public pagereference myCancel(){
    	if (!String.isEmpty(this.eventId)){
	        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
	        txn.request_type__c = 'Incident';
	        txn.requested_date_time__c = DateTime.Now();
	        txn.input_params__c = this.eventId;
	        try { 
	            insert txn;
	            PageReference pr =  Page.ReportEvent;
	            pr.getParameters().put('txnID', txn.ID);
	            pr.setRedirect(true);
	            return pr;
	        } catch (Exception e) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	            return null;
	        }
    	} else {
    		return new PageReference('/');
    	}
    	
    }
    
    public PageReference eventSubmit(){
        try{
            return mySave();
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    

    public PageReference updateLocked () {
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Disregard Incident';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = this.eventId;
        try { 
            insert txn;
            PageReference pr =  Page.ReportEvent;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }       
    }   
 
	@InvocableMethod(label='LockImIncident' description='Locks the incident, involved parties and associated event data after submit or disregard.')
	public static void lockIncident(list<Id> incidents) {
		//Approval.lock(incidents);
		Map<Id, Im_involvedParty__c> involvedParties = new map<Id,Im_involvedParty__c>([select id from Im_involvedParty__c where Im_Incident__c IN : incidents]);
		incidents.addAll(involvedParties.keySet());
		Approval.LockResult[] lrList = Approval.lock(incidents, false);

		// Iterate through each returned result
		for(Approval.LockResult lr : lrList) {
		    if (lr.isSuccess()) {
		        // Operation was successful, so get the ID of the record that was processed
		        System.debug('Successfully locked incidents with ID: ' + lr.getId());
		    }
		    else {
		        // Operation failed, so get all errors                
		        for(Database.Error err : lr.getErrors()) {
		            System.debug('The following error has occurred.');                    
		            System.debug(err.getStatusCode() + ': ' + err.getMessage());
		            System.debug('incidents fields that affected this error: ' + err.getFields());
		        }
		    }
		}	
		
	}
    
}