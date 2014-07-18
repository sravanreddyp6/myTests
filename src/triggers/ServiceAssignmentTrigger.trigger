trigger ServiceAssignmentTrigger on Service_Assignment__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

     ServiceAssignmentTriggeredActions handler = new ServiceAssignmentTriggeredActions();
    
    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }

}