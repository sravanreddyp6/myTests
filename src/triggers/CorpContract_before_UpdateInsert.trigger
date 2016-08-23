trigger CorpContract_before_UpdateInsert on TMN_Corp_Contract__c (before update, before insert) {
    
    list<TMN_Corp_Contract__c> contracts = new list<TMN_Corp_Contract__c>();
    
    contracts = trigger.new;
    CorpContract_CountReqFields.DoCount(contracts);
    

}