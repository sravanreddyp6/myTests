trigger ReferralLocationTrigger on Referral_Location__c (before insert, before update) {
    ReferralLocationTriggeredActions handler = new ReferralLocationTriggeredActions(true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    } 
 
    /* After Undelete 
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }
*/
}