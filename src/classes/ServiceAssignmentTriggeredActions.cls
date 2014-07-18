public with sharing class ServiceAssignmentTriggeredActions {

	public void OnBeforeInsert(Service_Assignment__c[] newObjects){
        boolean found;
		List<AggregateResult> currCounts = [SELECT Service_Location__c, Person_Being_Served__c, count (id) total FROM Service_Assignment__c where Service_Location__c != null group by Person_Being_Served__c, Service_Location__c];
		
		// loop through all the inserted service assignments
		for(Service_Assignment__c sa :newObjects ){
			// update the ServiceLocationCount only if the sevice location is present
			if (sa.Service_Location__c != null){
                system.debug('Service location present');				
				found = false;
				// loop through the aggregate count resluts, if 
				for (AggregateResult res : currCounts){
					if (sa.Person_Being_Served__c == res.get('Person_Being_Served__c')  &&  sa.Service_Location__c == res.get('Service_Location__c') ){
						sa.PBS_ServiceLocation_Count__c = Integer.valueOf(res.get('total')) + 1;
						found = true;          
                        // if the inserted batch has the same serviceAssignments, then we need to update the res total = +1 to reflect to count the new addition   --------   TODO
                         
						break;
					}
				}
			}
            // if not found in the existing list, then mark it as the first entry into this service location; 
            // Also, need to add this service assignment to the aggregate results                ----------------------------   TODO
            if (!found){
                sa.PBS_ServiceLocation_Count__c = 1;                    
            }
		}
		
	}


    public void OnBeforeUpdate(Service_Assignment__c[] oldObjects, Service_Assignment__c[] updatedObjects, Map<Id,Service_Assignment__c> oldObjMap){
/*        boolean found;
        List<AggregateResult> currCounts = [SELECT Service_Location__c, Person_Being_Served__c, count (id) total FROM Service_Assignment__c where Service_Location__c != null group by Person_Being_Served__c, Service_Location__c];
    	
        // loop through all the updated service assignments
        for(Service_Assignment__c sa :updatedObjects){
            // update the ServiceLocationCount if the service location was added to the service assignment
            if (sa.Service_Location__c != null && oldObjMap.get(sa.id).Service_Location__c == null ){
                found = false;
                // loop through the aggregate count resluts, if 
                for (AggregateResult res : currCounts){
                    if (sa.Person_Being_Served__r.id == res.get('Person_Being_Served__c')  &&  sa.Service_Location__c == res.get('Service_Location__c')){
                        sa.PBS_ServiceLocation_Count__c = Integer.valueOf(res.get('total')) + 1;
                        found = true;                        
                        // if the inserted batch has the same serviceAssignments, then we need to update the res total = +1 to reflect to count the new addition   --------   TODO
                         
                        break;
                    }
                }
            }
            // if not found in the existing list, then mark it as the first entry into this service location; 
            // Also, need to add this service assignment to the aggregate results                ----------------------------   TODO
            if (!found){                    
                sa.PBS_ServiceLocation_Count__c = 1;                    
            }
        } */
    }
    
    
    
}