trigger Assessment_AfterInsert_AfterUpdate on Assessment__c (after update, after insert) {
    
    List<Assessment__c> assess = new List<Assessment__c>();
    assess = trigger.new;
    system.debug('enter delete trigger');
    assess = [select id, Delete_Assessment__c from Assessment__c where id in :trigger.new];
    for(Assessment__c item: assess){
        system.debug('enter delete trigger 2');   
        if(item.Delete_Assessment__c)
            {system.debug('item delete trigger ' + item.id); delete item;}
    
    }
}