public with sharing class rptPersonalAgentBilling {
	
    public date startDate {get; set;}
    public date endDate {get; set;}
    
    public list<Progress_Note__c> rptData {get; set;}
    
	public rptPersonalAgentBilling() {
		
	}
    
    public pageReference runRpt(){
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    
    	system.debug( 'sd=' + startDate + ', ed=' + endDate);
    
    	if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	} else if ( startDate > endDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
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
		
		rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c, Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Service_Assignment__r.Service_Location__r.ProgramId__c, 
						Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDate AND 
						End_Time__c <= :endDate AND
						Purpose_Service_is_Billable__c = true AND
						Status__c = 'Final' AND
						Disregard_Note__c = false
					];
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/rptPersonalAgentBilling');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}