public with sharing class AcknowledgmentTriggerHandler {
    private boolean m_isExecuting = false;
    public AcknowledgmentTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterInsert(Acknowledgment__c[] newObjects){
        list<Id> updatedIds = new list<Id>();
        list<Id> updatedIds2 = new list<Id>();
        system.debug( newObjects );
        for(Acknowledgment__c ack :newObjects){
            if (ack.Attachment__c != null) {
            	updatedIds2.add(ack.Action_Plan__c);
            	continue;
            }
            if (ack.Action_Plan__c != null) updatedIds.add(ack.Action_Plan__c);
            if (ack.Assessment__c != null) updatedIds.add(ack.Assessment__c);
        }
        
        system.debug('UpdatedIDs1 (action plan or assessment)' + updatedids);
        system.debug('UpdatedIDs2 (attachments)' + updatedids2);

        List<Task> updateTasks = [Select id, subject, WhatId, Description
                                    from Task
                                   where What.Type in ('Action_Plan__c','Assessment__c')
                                     And WhatId =: updatedIds  // the associated action plan or assessment(risk/issa)
                                     and subject != 'ISP Acknowledgment'
                                     And status != 'Completed'
                                     And OwnerId = : UserInfo.getUserId()];

		// OH-11 - for the ISP attachment tasks, the what id is the action plan, but we only want to close out the attachment task, not the plan task 
        List<Task> updateTasks2 = [Select id, subject, WhatId, Description
                                    from Task
                                   where What.Type in ('Action_Plan__c')
                                     And WhatId =: updatedIds2  // the associated action plan 
                                     and subject = 'ISP Acknowledgment'
                                     And status != 'Completed'
                                     And OwnerId = : UserInfo.getUserId()];
		
        for(Task t : updateTasks){
            t.status = 'Completed';
            t.Description = t.Description + '\r\n\r\n Acknowledged by ' + UserInfo.getName();
        }
        for(Task t : updateTasks2){
            t.status = 'Completed';
            t.Description = t.Description + '\r\n\r\n Acknowledged by ' + UserInfo.getName();
        }
        
        update updateTasks;
        update updateTasks2; 
    }

}