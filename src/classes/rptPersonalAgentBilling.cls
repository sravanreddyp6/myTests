public with sharing class rptPersonalAgentBilling {
	
    public date startDate {get; set;}
    public date endDate {get; set;}
    public String dateField {get; set;}
    
    public list<Progress_Note__c> rptData {get; set;}
    
	public rptPersonalAgentBilling() {
		
	}
	
	public List<SelectOption> getFields() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Created Date', 'Created Date'));
		options.add(new SelectOption('Event Date', 'Event Date'));
		return options;
	}
	
    public list<SelectOption> programslist;
	public List<Id> selectedPrograms {get; set;}
	
    public list<SelectOption> select2list = new list<SelectOption>();
    public list<SelectOption> getSelect2list(){ return select2list; }	
    public List<id> select2PrmIds {get; set;}
    
	public List<SelectOption> getProgramslist() {
		if (programslist != null) {
			return programslist;
		}
		programslist = new List<SelectOption>();
		select2PrmIds = new List<ID>();
		Service_Location__c[] locations = [
                     SELECT Id, Name, ProgramId__c, Location_Nickname__c
                       FROM Service_Location__c
                     WHERE State__c = 'OR'
                        AND Service_Type__c = 'CM - Case Management'
                     ORDER BY ProgramId__c
              ];
		
		// System.debug(locations);
		// default all to selected
		for (Service_Location__c location: locations) {
			select2list.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
		}
		UpdateProgramSelections();
		return programslist;
	}
	
	public pagereference AddPrograms(){
		for (Id p : selectedPrograms ){
			for(Integer i=0; i < programslist.size(); i++){
				if (programslist.get(i).getValue() == p) {
	    			select2list.add(new SelectOption(programslist.get(i).getValue(), programslist.get(i).getLabel()));
	    			programslist.remove(i);
					break;
	    		}
			}
		}
		UpdateProgramSelections();
//		select2list.sort();
        return null;
    }

	public pagereference RemovePrograms(){
		for (Id p :select2PrmIds){
			for(Integer i=0; i < select2list.size(); i++){
				if (select2list.get(i).getValue() == p) {
	    			programslist.add(new SelectOption(select2list.get(i).getValue(), select2list.get(i).getLabel()));
	    			select2list.remove(i);
					break;
	    		}
			}
		}
		UpdateProgramSelections();
//		programslist.sort();
        return null;
    }

	public void UpdateProgramSelections(){
		select2PrmIds = new List<ID>();
		for (selectOption so : select2list){
			select2PrmIds.add(so.getValue());
		}
	}
		
    
    public pageReference runRpt(){
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    
    	//system.debug( 'sd=' + startDate + ', ed=' + endDate);
    
    	if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid from and to dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	} else if ( startDate > endDate ) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid from and to dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}    	
		
		if (dateField == null) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose a date criteria field');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	} else if (dateField != 'Created Date' && dateField != 'Event Date') {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose a date criteria field');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
    	
    	if ( select2list.size() == 0 ) {
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one brokerage');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
       
		if ( inputErr ) {
			return null;
		}
		
		TimeZone zone = UserInfo.getTimeZone();
		datetime startDateTime = StartDate;
		if(startDateTime !=null){
			startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);
		}
		
		
		datetime endDateTime = endDate;
		if(endDateTime !=null){
			endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
			endDateTime = endDateTime.addDays(1);
			endDateTime = endDateTime.addseconds(-1);
		}
		
		if (dateField == 'Event Date') {
			rptData = [SELECT Id, Start_Time__c, Service_Assignment__r.Person_being_served__r.name, Service_Assignment__r.Person_Being_served__r.PRIME_Number__c, 
						Type_of_Contact__c, CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Service_Assignment__r.Service_Location__r.ProgramId__c, 
						Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDateTime AND 
						End_Time__c <= :endDateTime AND
						recordtype.developername = 'RW_Case_Management' AND
						Purpose_Service_is_Billable__c = true AND
						service_assignment__r.service_location__c in :select2PrmIds AND
						Status__c = 'Final' AND
						Disregard_Note__c = false
					order by
						start_time__c desc
					LIMIT 50000
					];
		}
		else if (dateField == 'Created Date') {
			rptData = [SELECT Id, Service_Assignment__r.Person_being_served__r.name, Service_Assignment__r.Person_Being_served__r.PRIME_Number__c,
						Start_Time__c, Type_of_Contact__c, CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Service_Assignment__r.Service_Location__r.ProgramId__c, 
						Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						CreatedDate >= :startDateTime AND 
						CreatedDate <= :endDateTime AND
						recordtype.developername = 'RW_Case_Management' AND
						service_assignment__r.service_location__c in :select2PrmIds AND
						Purpose_Service_is_Billable__c = true AND
						Status__c = 'Final' AND
						Disregard_Note__c = false
					order by
						createddate desc
					LIMIT 50000
					];
		}
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/rptPersonalAgentBilling');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}