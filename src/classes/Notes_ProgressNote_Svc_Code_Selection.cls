public with sharing class Notes_ProgressNote_Svc_Code_Selection {
    public Progress_Note__c CurrentRecord {get; set;}
    
    public Notes_ProgressNote_Svc_Code_Selection(ApexPages.StandardController controller) {
        
        loadData((Progress_Note__c)Controller.getRecord());
    }
    public void loadData(Progress_Note__c localRecord){
        CurrentRecord = [Select Service_Assignment__c, Service_Code__c, Admission__c, start_time__c From Progress_Note__c Where ID = :localRecord.id Limit 1];
    }
    public List<SelectOption> Codes = new List<SelectOption>();
    public List<SelectOption> getCodes(){
    loadData(CurrentRecord);
        Codes.clear();
        SelectOption SOtmp = new SelectOption('', '--None--');
        Codes.Add(SOtmp);
        
        	// CTEAE-88 look at note start date for effective service codes
            for(Service_code__c local : 
            		[SELECT Id, Service_Code__c, Service_Value__c From Service_Code__c
            		where id in (select service_code__c from ServiceAssignment_ServiceCode_Jo__c where service_assignment__c = :currentRecord.Service_Assignment__c)
            		and start_date__c <= :Date.valueOf(CurrentRecord.Start_Time__c) and (end_date__c = null or end_date__c >= :Date.valueOf(CurrentRecord.Start_Time__c))  
            		])
            {                                   
                SelectOption SO = new SelectOption(local.ID, local.Service_Value__c);
                Codes.Add(SO);
            }        
        return Codes;
    }
    
    public List<SelectOption> Auths = new List<SelectOption>();
    public List<SelectOption> getAuths(){
        loadData(CurrentRecord);
        Auths.clear();
        SelectOption SOtmp = new SelectOption('', '--None--');
        Auths.Add(SOtmp);
        
        	System.Debug( 'START_TIME=' + CurrentRecord.Start_Time__c);
        	
        	// CTEAE-50 03/11/14 - make sure auth dates are valid for date of service.  User Start Time field as DOS is not calculated until save
            for(Authorization_ServiceCode_Jo__c local : 
                    [Select Service_Code__r.ID, Service_Code__r.Service_Value__c, Authorization__c, Authorization__r.Display_Name__c
                        From Authorization_ServiceCode_Jo__c 
                            Where Service_Code__c = :currentRecord.Service_Code__c 
                            AND Authorization__r.Admission__c = :currentRecord.Admission__c
                            and Authorization__r.Payer_Effective_Date__c <=:currentRecord.Start_Time__c.date()  
                            and Authorization__r.Payer_End_Date__c >= :currentRecord.Start_Time__c.date() 
                            ])
            {                                   
                SelectOption SO = new SelectOption(local.Authorization__c, local.Authorization__r.Display_Name__c);
                Auths.Add(SO);
            }        
        return Auths ;
    }    
}