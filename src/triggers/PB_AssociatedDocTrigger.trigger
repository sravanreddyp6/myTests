trigger PB_AssociatedDocTrigger on PB_AssociatedDoc__c (after update) {
    PB_AssociatedDocTriggeredActions handler = new PB_AssociatedDocTriggeredActions();
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}