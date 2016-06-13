public with sharing class rptActive_Referrals_with_Diagnosis {

    public date StartDate {get; set;}
    public date EndDate {get; set;}

    public list<rptRow> rptData {get; set;}

    public rptActive_Referrals_with_Diagnosis(){
        rptData = new list<rptRow>();
        runRpt();
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
        
        list<referral__c> refs = [select id, Name, Mobility__c, Assigned_Users__c, 
                                    Update_Notes__c, Comments__c, Referral_Date__c, Referral_Name__c, 
                                    Referral_Phone_Number__c, Referral_Status__c,
                                        Person_Being_Referred__r.Full_Name__c, Person_Being_Referred__r.Age__c, Person_Being_Referred__r.Gender__c,
                                        Person_Being_Referred__r.id
                                            FROM Referral__c
                                            WHERE 
		                                        Referral_Date__c > :startDateTime.date() AND 
		                                        Referral_Date__c < :endDateTime.date() AND
                                            	Referral_Status__c != 'Closed'
                                            ORDER BY Person_Being_Referred__r.Full_Name__c];
        
        set<id> PBRids = new set<id>();
        
        for (Referral__c ref: refs){        
            PBRids.add(ref.Person_Being_Referred__r.id);        
        }
        
        list<Diagnosis__c> diags = [select id, name, Status__c, Effective_Date__c, ICD__r.Name, ICD__r.Icd_Description__c, PBR__c from Diagnosis__c where PBR__c in : PBRids ORDER BY ICD__r.Name];
        
        
        for (Referral__c ref: refs){        
            for(Diagnosis__c diag: diags){
                if(ref.Person_Being_Referred__r.id == diag.PBR__c){
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