public with sharing class OR_Personal_Agent_Billing_Report {
	
    public date startDate {get; set;}
    public date endDate {get; set;}
    
    public list<Progress_Note__c> rptData {get; set;}
    
	public OR_Personal_Agent_Billing_Report() {
		
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
						CreatedBy.Contact.Name, CreatedDate, Name, Program_Code__c, Location__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDate AND 
						Start_Time__c <= :endDate AND
						// TBD: billable flag true??
						Status__c = 'Final' AND
						Disregard_Note__c = false
					];
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/OR_Personal_Agent_Billing_Report');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}