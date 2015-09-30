public with sharing class TherapyHourTriggerHandler {
    private boolean m_isExecuting = false;

    public TherapyHourTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert(Therapy_Hour__c[] oldObjects, Therapy_Hour__c[] updatedObjects, Map<Id, Therapy_Hour__c> oldObjMap, Map<Id,Therapy_Hour__c> newObjMap){
        //get my previously submitted hours (all but rejected.) ensure that the new one being entered doesnt overlap. with sharing should only return the one that the individual own.
        Therapy_Hour__c[] existingHrs = [Select Id,Start_Time__c,End_Time__c,Status__c,pbsFirstName__c, pbsLastName__c from Therapy_Hour__c where status__c != 'Rejected'];
        for(Therapy_Hour__c newhr : updatedObjects){
        	for(Therapy_Hour__c oldHr : existingHrs){
        		if ((newhr.start_time__c < oldHr.end_time__c && newhr.start_time__c > oldHr.start_time__c) ||
        		    (newhr.end_time__c < oldHr.end_time__c && newhr.end_time__c > oldHr.start_time__c) ||
        		    (oldHr.start_time__c > newhr.start_time__c && oldHr.start_time__c < newhr.end_time__c) ||
        		    (oldHr.end_time__c > newhr.start_time__c && oldHr.end_time__c < newhr.end_time__c) ) {
			        	newhr.addError('The submitted hours overlap with the pending/approved hours.');
			        	break;
        		}
            }
            existingHrs.add(newHr);
        }
    
    }
}