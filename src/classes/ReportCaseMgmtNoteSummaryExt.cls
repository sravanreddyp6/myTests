public with sharing class ReportCaseMgmtNoteSummaryExt {
    public date startDate {get; set;}
    public date endDate {get; set;}
    public List<SelectOption> listofPrograms {get;set;}
    public List<SelectOption> listofPersonBingSrvd {get;set;}
    public list<Progress_Note__c> rptData {get; set;}
    public list<Service_Assignment_Personal_Agent__c > pagentData {get; set;}
    Public String ProgramSelected{get;set;}
    Public Boolean ActiveServAssign{get;set;}
    Public string PersonBeingServedSelected{get;set;}
    public boolean hasRunOnce {get; set;} 
    public string PersonBeingServedSelectedName{get; set;}
    public string ProgramSelectedName{get; set;}
    Public Map<Id,string> pbsIdtoName = New Map<id,string>();
    Public Map<Id,string> programIdtoName = New Map<id,string>();
    Public String LoggedinuserName{get;set;}
    public string datetimenow{get;set;}
    public ReportCaseMgmtNoteSummaryExt() {
        LoggedinuserName = Userinfo.getName();
        ActiveServAssign = false;PersonBeingServedSelectedName='';ProgramSelectedName='';
        listofPrograms = new List<SelectOption>();
        listofPersonBingSrvd = new List<SelectOption>();
        listofPrograms.add(new SelectOption('', '--None--'));
        List<Service_Location__c> srvcLocations = [SELECT ProgramID__c,Id,State__c, Service_Type__c,Location_Nickname__c FROM Service_Location__c where State__c =: 'OR' and Service_type__c =: 'CM - Case Management' ORDER BY ProgramID__c ASC];
        for(Service_Location__c srvc:srvcLocations){
            listofPrograms.add(new SelectOption(srvc.Id, srvc.ProgramID__c + ' - ' + srvc.Location_Nickname__c));
            programIdtoName.put(srvc.Id, srvc.ProgramID__c + ' - ' + srvc.Location_Nickname__c);
        }
        hasRunOnce =false;
    }
    
    Public void updatepicklistPBS(){
        listofPersonBingSrvd = new List<SelectOption>();
        
        List<Service_Assignment__c> srvcAssgnList = [SELECT person_being_served__c,person_being_served__r.firstName,person_being_served__r.LastName,Service_Location__c,Id,Status__c FROM Service_Assignment__c where Service_Location__c =: ProgramSelected and Status__c =: 'Active' ORDER BY person_being_served__r.LastName ASC];
        for(Service_Assignment__c srvcAssgn:srvcAssgnList){
            if(ActiveServAssign == False){
                if(srvcAssgn.Status__c == 'Active' || srvcAssgn.Status__c == 'Inactive'){
                    listofPersonBingSrvd.add(new SelectOption(srvcAssgn.Id, srvcAssgn.person_being_served__r.LastName + ',' + srvcAssgn.person_being_served__r.FirstName));
                    pbsIdtoName.put(srvcAssgn.Id, srvcAssgn.person_being_served__r.LastName + ',' + srvcAssgn.person_being_served__r.FirstName);
                    
                }
            }else if(ActiveServAssign == True){
                if(srvcAssgn.Status__c == 'Active'){
                    listofPersonBingSrvd.add(new SelectOption(srvcAssgn.Id, srvcAssgn.person_being_served__r.LastName + ',' + srvcAssgn.person_being_served__r.FirstName));
                    pbsIdtoName.put(srvcAssgn.Id, srvcAssgn.person_being_served__r.LastName + ',' + srvcAssgn.person_being_served__r.FirstName);
                }
            }
        }
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
		System.debug('PersonBeingServedSelected --> ' + PersonBeingServedSelected + ' === ProgramSelected' + ProgramSelected);
		System.debug('startDate --> ' + startDate + 'endDate' + endDate + '----'+ enddateTime + 'startDateTime --> ' + startDateTime );
		rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c, Billable_Category__c,	Narrative__c,
						CreatedBy.Name, CreatedDate, Name, Program_Code__c, Service_Assignment__r.Service_Location__r.Location_Nickname__c
					FROM Progress_Note__c
					WHERE 
						Start_Time__c >= :startDateTime AND 
						End_Time__c <= :endDateTime AND
						Purpose_Service_is_Billable__c =: true AND
						Status__c =: 'Final' AND
						Service_Assignment__c =: PersonBeingServedSelected AND
						Service_Assignment__r.Service_Location__c =: ProgramSelected AND
						Disregard_Note__c =: false AND
						RecordType.DeveloperName =: 'RW_Case_Management'
					];
		pagentData = [SELECT Id,Personal_Agent__r.First_name__c,Personal_Agent__r.Last_name__c,Status__c 
						FROM Service_Assignment_Personal_Agent__c 
						WHERE Service_Assignment__c =: PersonBeingServedSelected AND
						Status__c = 'Active' ];
		hasRunOnce =true;
		PersonBeingServedSelectedName = pbsIdtoName.get(PersonBeingServedSelected);
		ProgramSelectedName = programIdtoName.get(ProgramSelected);
		
		return null; 
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/ReportCaseManagementNoteSummary');
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