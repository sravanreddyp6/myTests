public with sharing class Report_AuthChanges {

    public date StartDate {get; set;}
    public date EndDate {get; set;}
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

	public transient Map<id, List<authorization__c>> logMap;
	public Map<id, List<authorization__c>> getlogMap () {
		return logMap;
	}

	public transient Map<id, String> people;
	public Map<id, String> getpeople() {
		return people;
	}
	
	private Map<Id, string> pbsLookup;
	public transient Map<Id, Integer> authCount;
	public Map<id, Integer> getauthCount() {
		return authCount;
	}

	public Report_AuthChanges() {

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

		List<AggregateResult> aggrePbs = [SELECT Person_Being_Served__c pbsID, Person_Being_Served__r.Lastname pbsLastName, Person_Being_Served__r.Firstname pbsFirstName
				  FROM service_assignment__c
				 WHERE service_location__r.id In :selectedPrmIds
				 GROUP BY person_being_served__c, Person_Being_Served__r.Lastname, Person_Being_Served__r.Firstname
				 ORDER BY Person_Being_Served__r.Lastname, Person_Being_Served__r.Firstname];
		PBSList.clear();
		
		PBSlookup = new Map<Id, string>();
		for (AggregateResult pbs : aggrePbs) {
			PBSList.add(new SelectOption((Id) pbs.get('pbsID'), String.valueOf(pbs.get('pbsLastName')) + ', ' + String.valueOf(pbs.get('pbsFirstName'))));
			PBSLookup.put( (ID) pbs.get('pbsID'), String.valueOf(pbs.get('pbsFirstName')) + ' ' + String.valueOf(pbs.get('pbsLastName')));
			
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


		people = new Map<Id, String>();
		authcount = new Map<Id, Integer>();
		for ( string p : selectedPBS ) {
			
			people.put( (ID)p, pbsLookup.get((ID)p));
			authcount.put( (ID)p, 0);
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

	   logMap = new Map<Id, List<authorization__c>>();
	   
//Authorization Change (new, revised, clone, disregarded, finalized)

	   
       List<Authorization__c> auths= [Select id, name, person_being_Served__c, person_being_served__r.name, received_date_time__c, payer_authorization_id__c, type__c, authorization_status__c,
       									reason_for_new_authorization__c, rate__c, rate_unit__c, rate_unit_other__c, payer_effective_date__c, payer_end_date__c,
       									contract_used__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate, 
       									parent_auth__r.payer_authorization_id__c, parent_auth__r.payer_effective_date__c, 
       									original_auth__r.payer_authorization_id__c, original_auth__r.payer_effective_date__c,
       									parent_auth__c 
       									from authorization__c where
                                        ((lastmodifieddate >= :startDateTime AND lastmodifieddate <= :endDateTime) OR
                                        (createddate >= :startDateTime AND createddate <= :endDateTime))
                                        AND Person_Being_Served__c In :selectedPBS
                                        ORDER BY payer_effective_date__c, payer_end_Date__c ];

     	ID pbsID;
       	for ( authorization__c auth : auths ) {
       		pbsID = auth.person_being_served__c;
       		system.debug('LOGMAP: ' + logmap + ', ' + logmap.size());
       		
			integer howmany = authcount.get(pbsID);
			howmany += 1;
			authcount.put( pbsID, howmany);
			
       		if ( logmap.size() > 0 && logMap.KeySet().contains( pbsID ) )
       			logMap.get( pbsID).add( auth );
       		else {
       			List<authorization__c> pbsLogs = new List<authorization__c>{ auth};
       			logMap.put( pbsID, pbsLogs);
       		}
       	}
        return null;
    }

    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/Report_DraftAuths');
    	pageRef.setRedirect(true);
    	return pageRef;
    }

}
