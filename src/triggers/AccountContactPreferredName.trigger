trigger AccountContactPreferredName on Account (before insert, before update) {
    
    ContactTriggerAction action = new ContactTriggerAction();
    
    action.onBeforeInsertUpdate(Trigger.new);
    
}