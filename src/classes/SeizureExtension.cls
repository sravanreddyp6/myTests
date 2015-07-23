public with sharing class SeizureExtension {
    public string pbsId {get; private set;}
    public Seizure__c seizure {get;set;}
    public string retUrl {get;set;}
    public string seizureStart_DateTime {get;set;}
    public string seizureEnd_DateTime {get;set;}
    
      
    public SeizureExtension() {
        this.pbsId = ApexPages.CurrentPage().getParameters().get('pbsId');  // pbsId needed so that the blue card can initialize. 
    	this.retUrl = ApexPages.currentPage().getParameters().get('retURL');
    	if(ApexPages.CurrentPage().getParameters().get('seizureId') == null ){
            this.seizure = new Seizure__c();
            this.seizure.Service_Assignment__c = ApexPages.CurrentPage().getParameters().get('service_assignment');
            if (this.seizure.Service_Assignment__c == null){
                list<Service_Assignment__c> sa = [select id from Service_Assignment__c where Person_Being_Served__c = : pbsId And Status__c = 'Active'];
                if (sa.size() == 1) 
                    this.seizure.Service_Assignment__c = sa.get(0).id;
            }
            this.seizure.Observed_By__c = UserInfo.getUserId();
    	}else{
	        this.seizure = [select id, Service_Assignment__c, Service_Assignment__r.Person_Being_Served__c, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c from Seizure__c where id = : ApexPages.CurrentPage().getParameters().get('seizureId')];
    	}

        if (this.pbsId == null || this.pbsId=='') {     //if the PBS id is not present then its a call to edit an existing seizure.
        	this.pbsId = this.seizure.Service_Assignment__r.Person_Being_Served__c;
        }
        
    }
    
    public pageReference saveSeizure(){
        if (String.valueOf(this.seizure.Id) == '') {
            this.seizure.Id = null;
        }
        try{
            this.seizure.Start_DateTime__c = getDateTimeFromString(seizureStart_DateTime);
            this.seizure.End_DateTime__c = getDateTimeFromString(seizureEnd_DateTime);
            upsert this.seizure;
        } catch (Exception e){
        	System.debug('Seizure Save Exception:'+e);
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Seizure Save Exception. Please try again after correcting the errors.'));
        }
        
        return redirectBack(this.retUrl);
    }
    
    public pagereference backMethod()
	{
        return redirectBack(this.retUrl);
	}
	
    public pagereference redirectBack(String retUrl)
    {
        Pagereference pg =  new Pagereference(retUrl);
        pg.setRedirect(true);
        return pg;
    }
    	
    public static Datetime getDateTimeFromString(String dateTimeStr) {
            //yyyy-MM-dd HH:mm:ss - this is the correct datetime format to return
            string stringDate='';
        try {
             stringDate = dateTimeStr.substring(6,10) + '-' +dateTimeStr.substring(0,2) + '-' + dateTimeStr.substring(3,5) + ' ' + dateTimeStr.substring(11);
             return Datetime.valueOf(stringDate);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid date'));
        }
            
        return null;
        //return Datetime.valueOfGMT(stringDate);
    }
    
    @RemoteAction
    public static boolean findDuplicateSeizure(string seizureStart, string seizureEnd, string saId, string seizureId) {
        DateTime st = getDateTimeFromString(seizureStart);
        DateTime en = getDateTimeFromString(seizureEnd);
        boolean dupefound = false;
        List<Seizure__c> duplicateSeizure = [SELECT Id FROM Seizure__c WHERE Service_Assignment__c = :saId 
                                              AND ( ( Start_DateTime__c <= : st And End_DateTime__c > : st )   // one start at the same time OR after but the before the end of an existing one
                                              Or ( Start_DateTime__c >= : st And End_DateTime__c <= : en ) )   // the one being entered is not marking an existing one as the duplicate
                                              AND Duplicate_Entry__c = false
                                              AND Id != : seizureId                               // exclude the one itself from consideration when editing a record.
                                              limit 1];
                        
        if(duplicateSeizure.size() > 0) {
            dupeFound = true;
        }
        return dupeFound;
    }
    
}