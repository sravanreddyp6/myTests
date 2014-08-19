trigger NPA_Before_InsertUpdate on NPA_Audit__c (before insert, before update) {

    list<Npa_Audit__c > audits = new list<Npa_Audit__c >();
    
    audits = trigger.new;
    NPA_ClearFields.CheckAndClear(audits);
    
    for(Npa_Audit__c  local : audits){
    
        //local.addError('test');
       // ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Record tested <br/>'+  Datetime.now().format('MM/dd/yyyy @ hh:mm - z')));
    }

   
}