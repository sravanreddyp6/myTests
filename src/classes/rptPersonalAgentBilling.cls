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
    
    public pageReference runRpt(){
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    
    	system.debug( 'sd=' + startDate + ', ed=' + endDate);
    
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
    	} else if (dateField == null) {
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
			rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c, CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Service_Assignment__r.Service_Location__r.ProgramId__c, 
						Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDateTime AND 
						End_Time__c <= :endDateTime AND
						Purpose_Service_is_Billable__c = true AND
						Status__c = 'Final' AND
						Disregard_Note__c = false
					];
		}
		else if (dateField == 'Created Date') {
			rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c, CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Service_Assignment__r.Service_Location__r.ProgramId__c, 
						Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						CreatedDate >= :startDateTime AND 
						CreatedDate <= :endDateTime AND
						Purpose_Service_is_Billable__c = true AND
						Status__c = 'Final' AND
						Disregard_Note__c = false
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