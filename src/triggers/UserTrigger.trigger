trigger UserTrigger on User (before update) {
    UserTriggeredActions handler = new UserTriggeredActions(true);

    /* Before Update */
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    } 
 

}