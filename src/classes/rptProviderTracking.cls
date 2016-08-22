public with sharing class rptProviderTracking {
	
	public transient list<TMN_Provider__c> rptData {get; set;}
	
	public rptProviderTracking() {
	}
	
	public list<SelectOption> statuslist;
	public List<String> selectedstatus {get; set;}
	public List<String> selected2status {get; set;}
    public list<SelectOption> selectStatusList = new list<SelectOption>();
    public list<SelectOption> getSelectStatusList(){ return selectStatusList; }	
    
	public List<SelectOption> getstatuslist() {
		if (statuslist != null) {
			return statuslist;
		}
		statuslist = new List<SelectOption>();
		selectstatuslist = new List<SelectOption>();
		
		// set all to selected at first
		selectstatuslist.add(new SelectOption('Pending Approval', 'Pending Approval'));
		selectstatuslist.add(new SelectOption('Approved', 'Approved'));
		selectstatuslist.add(new SelectOption('Expired', 'Expired'));
		selectstatuslist.add(new SelectOption('Disqualified', 'Disqualified'));
		return statuslist;
	}
	
	public pagereference AddStatus(){
		for (String p : selectedstatus ){
			for(Integer i=0; i < statuslist.size(); i++){
				if (statuslist.get(i).getValue() == p) {
	    			selectstatuslist.add(new SelectOption(statuslist.get(i).getValue(), statuslist.get(i).getLabel()));
	    			statuslist.remove(i);
					break;
	    		}
			}
		}
        return null;
    }

	public pagereference RemoveStatus(){
		for (String p :selected2status ){
			for(Integer i=0; i < selectstatusList.size(); i++){
				if (selectstatusList.get(i).getValue() == p) {
	    			statuslist.add(new SelectOption(selectstatusList.get(i).getValue(), selectstatusList.get(i).getLabel()));
	    			selectstatusList.remove(i);
					break;
	    		}
			}
		}
        return null;
    }
	
	public void UpdateStatusSelections(){
		selected2status = new List<String>();
		for (selectOption so : selectstatusList){
			selected2status.add(so.getValue());
		}
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
		selectedprograms = new List<ID>();
		select2PrmIds = new List<ID>();
		Service_Location__c[] locations = [
                     SELECT Id, Name, ProgramId__c, Location_Nickname__c
                       FROM Service_Location__c
                     WHERE State__c = 'OR'
                        AND Service_Type__c = 'CM - Case Management'
                     ORDER BY ProgramId__c
              ];
		
		// default all to selected
		for (Service_Location__c location: locations) {
			select2list.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
		}
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
        return null;
    }

	public void UpdateProgramSelections(){
		select2PrmIds = new List<ID>();
		for (selectOption so : select2list){
			select2PrmIds.add(so.getValue());
		}
		
	}
	
	
	public list<SelectOption> provtypelist;
	public List<String> selectedTypes {get; set;}
	public List<String> selected2Types {get; set;}
    public list<SelectOption> selectTypeList = new list<SelectOption>();
    public list<SelectOption> getSelectTypeList(){ return selectTypeList; }	
    
	public List<SelectOption> getTypeList() {
		if (provtypelist != null) {
			return provtypelist;
		}
		provtypelist = new List<SelectOption>();
		selectTypeList = new List<SelectOption>();
		
		// set all to selected at first
		selectTypeList.add(new SelectOption('PSW','PSW'));
		selectTypeList.add(new SelectOption('General Business', 'General Business'));
		selectTypeList.add(new SelectOption('Provider Organization', 'Provider Organization'));
		selectTypeList.add(new SelectOption('Independent Contractor', 'Independent Contractor'));
		
		return provtypelist;
	}
	
	public pagereference AddTypes(){
		for (String p : selectedTypes ){
			for(Integer i=0; i < provTypeList.size(); i++){
				if (provtypelist.get(i).getValue() == p) {
	    			selectTypeList.add(new SelectOption(provtypelist.get(i).getValue(), provtypelist.get(i).getLabel()));
	    			provtypelist.remove(i);
					break;
	    		}
			}
		}
        return null;
    }

	public pagereference RemoveTypes(){
		for (String p :selected2Types ){
			for(Integer i=0; i < selectTypeList.size(); i++){
				if (selectTypeList.get(i).getValue() == p) {
	    			provtypelist.add(new SelectOption(selectTypeList.get(i).getValue(), selectTypeList.get(i).getLabel()));
	    			selectTypeList.remove(i);
					break;
	    		}
			}
		}
        return null;
    }
	
	public void UpdateTypeSelections(){
		selected2Types = new List<String>();
		for (selectOption so : selectTypeList){
			selected2Types.add(so.getValue());
		}
	}
	
	
    
    public PageReference runRpt() {
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    	
    //	system.debug('providerStatus=' + providerStatus);
    	UpdateProgramSelections();
    	UpdateTypeSelections();
    	UpdateStatusSelections();
    
    	if(selected2status.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Provider Status');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
    	if (select2PrmIds.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Brokerage');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	} 
    	if ( selected2Types.isEmpty() ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Provider Type');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
		if ( inputErr ) {
			return null;
		}
		
		rptData = [SELECT Id, First_Name__c, Last_Name__c, Gender__c, SPD_Number__c, eXPRS_Number__c, Address_Street_1__c,
						Address_Street_2__c, City__c, State__c, Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c,
						Provider_Type__c, Company_Agency_Name__c, Brokerage__r.Alias__c, Brokerage__r.ProgramID__c, Brokerage__r.Location_Nickname__c,   
						Counties_Served__c, Services_Provided__c, Status__c, (SELECT Disqualification_Date__c, Effective_Date__c, Expiration_Date__c 
							FROM TMN_Provider_Applications__r ORDER BY Effective_Date__c DESC LIMIT 1)
					FROM TMN_Provider__c
					WHERE Status__c in :selected2status and 
							Brokerage__c in :select2PrmIds and
							Provider_Type__c in :selected2Types
                   ORDER BY First_Name__c, Last_Name__c, Application_Expiration_Date__c ASC
					];
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/rptProvider_Tracking');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}