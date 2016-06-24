public with sharing class rptActive_Referrals_with_Diagnosis {

    private date StartDate;
    public void setStartDate(Date StartDate){
    	this.StartDate = StartDate;
    }
    public date getStartDate() {
    	return this.StartDate;
    }
    
    private date EndDate;
    public void setEndDate(Date EndDate){
    	this.EndDate = EndDate;
    }
    public date getEndDate(){
    	return this.EndDate;
    } 

    public transient list<rptRow> rptData { get; private set;}

    public rptActive_Referrals_with_Diagnosis(){
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
        rptData = new list<rptRow>();
        set<id> PBRids = new set<id>();
        for ( AggregateResult ar : [ select 
        						person_being_referred__c, count(id) 
        					from 
        						referral__c where Referral_Date__c >= :StartDate 
        					AND Referral_Date__c <= :EndDate 
        					AND Referral_Status__c != 'Closed'
        					group by person_being_referred__c]) {
        	PBRids.add((ID)ar.get('Person_Being_Referred__c'));        
        }
        system.debug('pbr count=' + PBRids.size());
        
        map<id, list<Diagnosis__c>> diagsById = new map<id, list<Diagnosis__c>>();
        
        list<Diagnosis__c> currDiags = new list<Diagnosis__c>();
        long cnt = 1;
        for (Diagnosis__c diag : [select id, name, Status__c, Effective_Date__c, ICD__r.Name, ICD__r.Icd_Description__c, PBR__c from Diagnosis__c where PBR__c in : PBRids ORDER BY PBR__c])
        {
        	
        	currDiags = diagsByID.get( diag.PBR__c );
        	if ( currDiags == null ) {
        		diagsById.put( diag.PBR__c, new List<Diagnosis__c>{ diag});
        	} else {
        		currDiags.add( diag );
        		diagsById.put( diag.PBR__c, currDiags );
        	}
        	
        }
        
	    for (Referral__c ref: [ select 
        							id, Name, Mobility__c, Assigned_Users__c, 
                                    Update_Notes__c, Comments__c, Referral_Date__c, Referral_Name__c, 
                                    Referral_Phone_Number__c, Referral_Status__c,
                                    Person_Being_Referred__r.Full_Name__c, Person_Being_Referred__r.Age__c, Person_Being_Referred__r.Gender__c,
                                    Person_Being_Referred__c
                               FROM 
                               		Referral__c
                               WHERE 
		                       		Referral_Date__c > :StartDate AND 
		                            Referral_Date__c <= :EndDate AND
                                    Referral_Status__c != 'Closed'
                               ORDER BY Person_Being_Referred__r.Full_Name__c]){
        
            	currDiags = diagsById.get(ref.Person_Being_Referred__c);
            	system.debug( currDiags);
	        	if (currDiags != null) {
		            for(Diagnosis__c diag: currDiags) {
		                rptRow row = new rptRow();
		                row.ref = ref;
		                row.Diag = diag;
		                rptData.add(row);
		            }
	        	}
	        }
                        
        return null;
    }
    
    public class rptRow{
        public Referral__c ref {get; set;}
        public Person_Being_Referred__c PBR {get; set;}
        public Diagnosis__c Diag {get; set;}
        public rptRow(){
            Diag = new Diagnosis__c ();
            PBR = new Person_Being_Referred__c ();
            ref = new Referral__c ();
        }
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/rptActive_Referrals_with_Diagnosis');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}