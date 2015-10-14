trigger TMN_User on TMN_User__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    TMN_UserTriggerHandler handler = new TMN_UserTriggerHandler(true);

    /* Before Insert 
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }*/
    /* After Insert update*/
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        handler.OnAfterInsertUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    
    /* Before Update 
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    /* After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    /* Before Delete
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    /* After Delete 
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Undelete 
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }*/
    
}