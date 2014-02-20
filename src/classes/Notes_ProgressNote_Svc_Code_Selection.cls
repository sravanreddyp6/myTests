public with sharing class Notes_ProgressNote_Svc_Code_Selection {
    public Progress_Note__c CurrentRecord {get; set;}
    
    public Notes_ProgressNote_Svc_Code_Selection(ApexPages.StandardController controller) {
        
        loadData((Progress_Note__c)Controller.getRecord());
    }
    public void loadData(Progress_Note__c localRecord){
        CurrentRecord = [Select Service_Assignment__c, Service_Code__c, Admission__c From Progress_Note__c Where ID = :localRecord.id Limit 1];
    }
    public List<SelectOption> Codes = new List<SelectOption>();
    public List<SelectOption> getCodes(){
    loadData(CurrentRecord);
        Codes.clear();
        SelectOption SOtmp = new SelectOption('', '--None--');
        Codes.Add(SOtmp);
        
            for(ServiceAssignment_ServiceCode_Jo__c local : 
                    [Select Service_Code__r.ID, Service_Code__r.Service_Value__c 
                        From ServiceAssignment_ServiceCode_Jo__c 
                            Where
                            Service_Code__r.isActive__c = 1
                            	AND 
                        	Service_Assignment__c = :currentRecord.Service_Assignment__c])
            {                                   
                SelectOption SO = new SelectOption(local.Service_Code__r.ID, local.Service_Code__r.Service_Value__c);
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
        
            for(Authorization_ServiceCode_Jo__c local : 
                    [Select Service_Code__r.ID, Service_Code__r.Service_Value__c, Authorization__c, Authorization__r.Display_Name__c
                        From Authorization_ServiceCode_Jo__c 
                            Where Service_Code__c = :currentRecord.Service_Code__c AND Authorization__r.Admission__c = :currentRecord.Admission__c])
            {                                   
                SelectOption SO = new SelectOption(local.Authorization__c, local.Authorization__r.Display_Name__c);
                Auths.Add(SO);
            }        
        return Auths ;
    }    
}