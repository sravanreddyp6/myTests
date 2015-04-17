trigger ReferralTrigger on Referral__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
     ReferralTriggerHandler handler = new ReferralTriggerHandler(true);

    // Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    
/*    
    // After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
    }
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    // Before Delete
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    // After Delete
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    // After Undelete
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }
*/

}