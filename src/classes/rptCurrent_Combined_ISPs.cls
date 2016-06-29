public with sharing class rptCurrent_Combined_ISPs {
	
    public date startDate {get; set;}
    public date endDate {get; set;}
    
    public list<Case_Management_Plan__c> rptData {get; set;}
    
	public rptCurrent_Combined_ISPs() {
		
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
		
		rptData = [SELECT Id, Service_Assignment__r.Person_Being_Served__r.Name,
					Service_Assignment__r.Name, Name, PD_Start__c, PD_End__c, Status__c,
					CreatedBy.Name
					FROM Case_Management_Plan__c
					WHERE RecordType.DeveloperName = 'OR_Combined_ISP'
					];
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/rptPersonalAgentBilling');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}