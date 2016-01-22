public with sharing class Report_TimeLogEntry {

    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public string HCMCfilter {get; set;}
    public List<id> selectedPBS {get; set;}
    public list<SelectOption> PBSList = new list<SelectOption>();
    public list<SelectOption> getPBSList(){ return PBSList ;}
    public boolean hasRunOnce {get; set;}

    public DateTime pdfRunDateTime { get; set; }

    public list<SelectOption> programslist = new list<SelectOption>();
    public list<SelectOption> getProgramslist(){ return programslist; }
	public List<Id> selectedPrograms {get; set;}

    public list<SelectOption> select2list = new list<SelectOption>();
    public list<SelectOption> getSelect2list(){ return select2list; }
    public List<id> select2PrmIds {get; set;}

    public string opGroup { get; private set; }

	public transient Map<id, List<evaluation_response__c>> logMap;
	public Map<id, List<evaluation_response__c>> getlogMap () {
		return logMap;
	}

	public transient Map<id, String> people;
	public Map<id, String> getpeople() {
		return people;
	}

	public Report_TimeLogEntry() {

		opGroup = [ select operating_group__c from user where id = :UserInfo.getUserId()].operating_group__c;

		List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
										   FROM service_assignment__c
										  GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c
										 HAVING COUNT(service_location__r.id) > 0
										  ORDER BY service_location__r.program__c];
		for (AggregateResult slPrgm : slPrgms) {
			programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
		}
		selectedPBS = new List<id>();
		hasRunOnce =false;
}


	public pagereference AddPrograms(){
		for (Id p :selectedPrograms){
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
		List<id> selectedPrmIds = new List<id>();
		for (selectOption so : select2list){
			selectedPrmIds.add(so.getValue());
		}

		List<AggregateResult> aggrePbs = [SELECT service_assignment__r.Person_Being_Served__c pbsID, service_assignment__r.Person_Being_Served__r.Lastname pbsLastName, service_assignment__r.Person_Being_Served__r.Firstname pbsFirstName
				  FROM evaluation_response__c
				 WHERE recordType.DeveloperName = 'Time_Log'
				   AND Service_Assignment__r.service_location__r.id In :selectedPrmIds
				 GROUP BY service_assignment__r.person_being_served__c, service_assignment__r.Person_Being_Served__r.Lastname, service_assignment__r.Person_Being_Served__r.Firstname
				 ORDER BY service_assignment__r.Person_Being_Served__r.Lastname, service_assignment__r.Person_Being_Served__r.Firstname];
		PBSList.clear();
		for (AggregateResult pbs : aggrePbs) {
			PBSList.add(new SelectOption((Id) pbs.get('pbsID'), String.valueOf(pbs.get('pbsLastName')) + ', ' + String.valueOf(pbs.get('pbsFirstName'))));
        }
    }

    public pagereference runReport(){

     boolean inputErr = false;
       ApexPages.getMessages().clear();

       system.debug( 'sd=' + startDate + ', ed=' + endDate + ', prog=' + select2PrmIds.size() + ', pbs=' + selectedPBS.size());

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
       if(selectedPBS.Size()==0    ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select at least one Person Being Served');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }

       if ( inputErr ) {
			return null;
       }


       hasRunOnce = true;
       TimeZone zone = UserInfo.getTimeZone();
       datetime startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}


       datetime endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }

		people = new Map<id, string>();
		logMap = new Map<Id, List<Evaluation_response__c>>();
       List<Evaluation_response__c> logs = [Select service_assignment__r.person_being_served__c, service_assignment__r.person_being_served__r.name, Name, ID,
       												Start_Date_Time__c, End_Date_Time__c, CreatedByid, tmn_user__c, location__c, is_late_entry__c, service_type__c, Narrative_Note__c
            						From Evaluation_response__c where
                                        (
                                            (Start_Date_time__c > :startDateTime OR End_Date_time__c > :startDateTime )
                                                AND
                                            (Start_Date_time__c < :endDateTime OR End_date_time__c < :endDateTime)
                                        )
                                            AND Service_Assignment__r.Person_Being_Served__c In :selectedPBS
                                            AND RecordType.DeveloperName = 'Time_Log'
                                            AND Disregard__c = false
                                        ORDER BY start_Date_time__c, end_date_time__c ];

     	ID pbsID;
       	for ( Evaluation_response__c logEntry : logs ) {
       		pbsID = logEntry.service_assignment__r.person_being_served__c;
       		system.debug('LOGMAP: ' + logmap + ', ' + logmap.size());

       		if ( logmap.size() > 0 && logMap.KeySet().contains( pbsID ) )
       			logMap.get( pbsID).add( logEntry);
       		else {
       			List<Evaluation_response__c> pbsLogs = new List<Evaluation_Response__c>{ logEntry };
       			logMap.put( pbsID, pbsLogs);
       			people.put( pbsID, logEntry.service_assignment__r.person_being_served__r.name);
       		}
       	}
        return null;
    }

    public PageReference runExcel() {
        pdfRunDateTime = System.now();

        PageReference toPdfPage = new PageReference('/apex/Report_TimeLogEntry_Excel');
        toPdfPage.setRedirect(false);
        return toPdfPage;
    }

    public PageReference runPdf() {
    	pdfRunDateTime = System.now();

    	PageReference toPdfPage = new PageReference('/apex/Report_TimeLogEntry_PDF');
    	toPdfPage.setRedirect(false);
    	return toPdfPage;


    }

    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/Report_TimeLogEntry');
    	pageRef.setRedirect(true);
    	return pageRef;
    }



}