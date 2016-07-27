trigger T_Event_Trigger on T_Event__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    T_EventTriggerHandler handler = new T_EventTriggerHandler(true);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } /* else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    } */
}