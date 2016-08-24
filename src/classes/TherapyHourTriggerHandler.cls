public with sharing class TherapyHourTriggerHandler {
    private boolean m_isExecuting = false;

    public TherapyHourTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert(Therapy_Hour__c[] oldObjects, Therapy_Hour__c[] updatedObjects, Map<Id, Therapy_Hour__c> oldObjMap, Map<Id,Therapy_Hour__c> newObjMap){
        //get my previously submitted hours (all but rejected.) ensure that the new one being entered doesnt overlap. with sharing should only return the one that the individual own.
        Therapy_Hour__c[] existingHrs = [Select Id,Start_Time__c,End_Time__c,Status__c,pbsFirstName__c, pbsLastName__c from Therapy_Hour__c where status__c != 'Rejected'];
        
        //The system will only allow a user to submit up to 3 hours (total sum) on a single patient within a calendar day.
        map<String, double> hourPerDay = new map<String, double>();
        for (AggregateResult ag : [select Service_Assignment__c, sum(Number_of_Hours__c) totalHrs, StartTime_DatePart__c from Therapy_Hour__c where status__c != 'Rejected' group by Service_Assignment__c, StartTime_DatePart__c]){
                hourPerDay.put((String)ag.get('Service_Assignment__c') + ((Date) ag.get('StartTime_DatePart__c')).format(), (double) ag.get('totalHrs'));
        } 
        
        for(Therapy_Hour__c newhr : updatedObjects){
        	long numberOfMins = (newhr.End_Time__c.getTime() - newhr.Start_Time__c.getTime())/60000;
        	if (Math.Mod(numberOfMins, 5) > 0 ){
                newhr.addError('Please enter time in 5 minutes increments.');
                break;        		
        	}
            if (hourPerDay.containsKey(newhr.Service_Assignment__c  + newhr.Start_Time__c.date().format())){
            	Decimal currSum = (Decimal) hourPerDay.get(newhr.Service_Assignment__c  + newhr.Start_Time__c.date().format());
            	Decimal insertedHrs = ((Decimal) numberOfMins/60).setScale(2);
            	if (currSum + insertedHrs > 3.0) {
	                newhr.addError('Only up to 3 hours can be submitted on a single patient within a calendar day');
	                break;
            	}
            	hourPerDay.put(newhr.Service_Assignment__c  + newhr.Start_Time__c.date().format(), currSum + insertedHrs);
            }
        	for(Therapy_Hour__c oldHr : existingHrs){
        		if ((newhr.start_time__c < oldHr.end_time__c && newhr.start_time__c > oldHr.start_time__c) ||
        		    (newhr.end_time__c < oldHr.end_time__c && newhr.end_time__c > oldHr.start_time__c) ||
        		    (oldHr.start_time__c > newhr.start_time__c && oldHr.start_time__c < newhr.end_time__c) ||
        		    (oldHr.end_time__c > newhr.start_time__c && oldHr.end_time__c < newhr.end_time__c) ||
                    (oldHr.start_time__c == newhr.start_time__c && oldHr.end_time__c == newhr.end_time__c)  ) {
			        	newhr.addError('The submitted hours overlap with the pending/approved hours.');
			        	break;
        		}
            }
            existingHrs.add(newHr);
        }
        
        
        
    
    }
}