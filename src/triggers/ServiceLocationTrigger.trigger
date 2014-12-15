trigger ServiceLocationTrigger on Service_Location__c (after insert, after update) {
 	ServiceLocationTriggerHandler handler = new ServiceLocationTriggerHandler(true);

    /* After Insert or Update */
    if( Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    
    if( Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new);
    }
    
    
}