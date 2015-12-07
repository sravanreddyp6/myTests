public with sharing class AcknowledgmentTriggerHandler {
    private boolean m_isExecuting = false;
    public AcknowledgmentTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterInsert(Acknowledgment__c[] newObjects){
        list<Id> updatedIds = new list<Id>();
        for(Acknowledgment__c ack :newObjects){
            if (ack.Action_Plan__c != null) updatedIds.add(ack.Action_Plan__c);
            if (ack.Assessment__c != null) updatedIds.add(ack.Assessment__c);
        }

        List<Task> updateTasks = [Select id, subject, WhatId, Description
                                    from Task
                                   where What.Type in ('Action_Plan__c','Assessment__c')
                                     And WhatId =: updatedIds  // the associated action plan or assessment(risk/issa)
                                     And status != 'Completed'
                                     And OwnerId = : UserInfo.getUserId()];

        for(Task t : updateTasks){
            t.status = 'Completed';
            t.Description = t.Description + '\r\n\r\n Acknowledged by ' + UserInfo.getName();
        }
        update updateTasks; 
    }

}