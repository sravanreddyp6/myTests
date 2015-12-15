trigger TherapyHoursTrigger on Therapy_Hour__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
     TherapyHourTriggerHandler handler = new TherapyHourTriggerHandler(true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    /* After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }*/

}