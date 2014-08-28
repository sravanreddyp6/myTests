trigger ServiceAssignmentTrigger on Service_Assignment__c (before insert, before update) {
  if(!system.isBatch()){
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
}