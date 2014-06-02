trigger Assessment_BeforeInsert_BeforeUpdate on Assessment__c (before update, before insert) {
    
    List<Assessment__c> assess = new List<Assessment__c>();
    assess = trigger.new;
    if(trigger.isupdate){
        Assessment_BeforeInsert_BeforeUpdate.setAccountPerson(assess);
    }
}