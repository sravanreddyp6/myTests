public with sharing class ReportCaseMgmtNoteSummaryExt {
    public date startDate {get; set;}
    public date endDate {get; set;}
    public list<Progress_Note__c> rptData {get; set;}
    public list<Service_Assignment_Personal_Agent__c > pagentData {get; set;}
    public Service_Assignment__c saData {get; set;}
    public boolean hasRunOnce {get; set;} 
    Public String LoggedinuserName{get;set;}
    public string datetimenow{get;set;}
    public id saID = ApexPages.currentPage().getParameters().get('saID');
    public ReportCaseMgmtNoteSummaryExt() {
        LoggedinuserName = Userinfo.getName();
        hasRunOnce =false;
    }
    
    public pageReference runRpt(){
        LoggedinuserName = Userinfo.getName();
        datetimenow = system.now().format();
    	hasRunOnce =false;
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    	system.debug( 'sd=' + startDate + ', ed=' + endDate);
    	if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose valid start and end dates');
            ApexPages.addMessage(myMsg);
            inputErr = true;
    	} 
    	else if ( startDate > endDate ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose valid start and end dates');
            ApexPages.addMessage(myMsg);
            inputErr = true;
    	}
        if ( inputErr ) {
		    return null;
		}
        
		saData = [SELECT Id,Service_Location__r.Programid__c,Service_Location__r.Location_Nickname__c, Person_Being_served__r.Name FROM Service_Assignment__c WHERE Id =: saID LIMIT 1];
		rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c,Narrative__c,CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Program_Code__c, Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDate AND 
						Start_Time__c <= :endDate AND
						Purpose_Service_is_Billable__c =: true AND
						Status__c =: 'Final' AND
						Service_Assignment__c =: saID AND
						Disregard_Note__c =: false
					];
		pagentData = [SELECT Id,Personal_Agent__r.First_name__c,Personal_Agent__r.Last_name__c,Status__c 
						FROM Service_Assignment_Personal_Agent__c 
						WHERE Service_Assignment__c =: saID AND
						Status__c = 'Active' ];
		hasRunOnce =true;
		return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/ReportCaseManagementNoteSummary?saID='+saID);
    	pageRef.setRedirect(true);
    	return pageRef;
    }
     public PageReference runPdf() {	
    	//Datetime pdfRunDateTime = System.now();
    	//pdfRunDateTimeString = pdfRunDateTime.format('MM/dd/yyyy, h:mm:ss a');
    	PageReference toPdfPage = new PageReference('/apex/Report_CaseManagementNoteSummary_PDF');
    	toPdfPage.setRedirect(false);
    	return toPdfPage;
    }
    
}