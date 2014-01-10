trigger NPA_Trigger_Delete on NPA_Audit__c (before delete) {
    
    list<Npa_Audit__c > audits = new list<Npa_Audit__c >();
    
    audits = trigger.old;
   
    for(Npa_Audit__c  local : audits){
        if (local.Status__c == 'Final')
            {
            local.addError('cant delete a final record');
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, ' The Record was not saved '+ Datetime.now()));
             }
    
    }
}