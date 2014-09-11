/*
 *
 *  EC-16 : Trigger to store the service location count for the person being served. 
 *
 */

public with sharing class ServiceAssignmentTriggeredActions {

	public void OnBeforeInsert(Service_Assignment__c[] newObjects){
        boolean found;
        Map<String,SAaggregates> currCounts = getSAaggregateMap(newObjects);
		// loop through all the inserted service assignments
		for(Service_Assignment__c sa :newObjects ){
			// update the ServiceLocationCount only if the sevice location is present
			if (sa.Service_Location__c != null){
				found = false;
				if (currCounts.containsKey(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c))){
                		sa.PBS_ServiceLocation_Count__c = currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).totalPlusOne();
                        found = true;
				}
	            // if not found in the existing list, then mark it as the first entry into this service location; 
	            // Also, need to add this service assignment to the aggregate results
	            if (!found){
	                sa.PBS_ServiceLocation_Count__c = 1;
	                currCounts.put(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c), new SAaggregates(sa.Service_Location__c, sa.Person_Being_Served__c, 1));
	            } 
            }            
		}
		
	}


    public void OnBeforeUpdate(Service_Assignment__c[] oldObjects, Service_Assignment__c[] updatedObjects, Map<Id,Service_Assignment__c> oldObjMap){
        boolean found;
        Map<String,SAaggregates> currCounts = getSAaggregateMap(updatedObjects);
        // loop through all the updated service assignments
        for(Service_Assignment__c sa :updatedObjects){
            // update the ServiceLocationCount if the service location was added to the service assignment
            if (sa.Service_Location__c != null && oldObjMap.get(sa.id).Service_Location__c == null && sa.PBS_ServiceLocation_Count__c == null ){
                found = false;
				if (currCounts.containsKey(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c))){
                		sa.PBS_ServiceLocation_Count__c = currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).totalPlusOne();
                        found = true;
				}
	            // if not found in the existing list, then mark it as the first entry into this service location; 
	            // Also, need to add this service assignment to the aggregate results
	            if (!found){
	                sa.PBS_ServiceLocation_Count__c = 1;
	                currCounts.put(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c), new SAaggregates(sa.Service_Location__c, sa.Person_Being_Served__c, 1));
	            }                
            }
            // To update the exisiting service assignment records.
            else if (sa.Service_Location__c != null && (sa.PBS_ServiceLocation_Count__c == null || sa.PBS_ServiceLocation_Count__c == 0 )){
				if (currCounts.containsKey(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c))){
						sa.PBS_ServiceLocation_Count__c = currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).total;
	                    --currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).total;
				}
            }
        }
    }

    private Map<String,SAaggregates> getSAaggregateMap(Service_Assignment__c[] modifiedObjs){    	
    	List<Id> pbsIds = new List<Id>();
    	for (Service_Assignment__c sa :modifiedObjs){
    		pbsIds.add(sa.Person_Being_Served__c);
    	}
    	Map<String,SAaggregates> aggregates = new Map<String,SAaggregates>();
        List<AggregateResult> currCounts = [SELECT Service_Location__r.id slID, Person_Being_Served__c, count (id) total FROM Service_Assignment__c where Service_Location__c != null AND Person_Being_Served__c IN :pbsIds group by Person_Being_Served__c, Service_Location__r.id];
        for (AggregateResult res : currCounts) {
        	aggregates.put(String.valueOf(res.get('slID')) + String.valueOf(res.get('Person_Being_Served__c')), new SAaggregates( (Id) res.get('slID'), String.valueOf(res.get('Person_Being_Served__c')), Integer.valueOf(res.get('total'))));
        }
        return aggregates;          	
    }    
    
    class SAaggregates{
    	public Id serviceLocation; 
        public String personBeingServed;
        public Integer total;
    	
        public SAaggregates(Id serviceLocation, String personBeingServed, Integer total){
	        this.serviceLocation = serviceLocation; 
	        this.personBeingServed = personBeingServed;
	        this.total = total;
        }
        public Integer totalPlusOne(){
        	return ++this.total;
        }
    } 
    
    
   /* 
    class ServiceAssignmentWrapper implements Comparable {

	    public Service_Assignment__c servAssig;

	    // Constructor 
	    public ServiceAssignmentWrapper(Service_Assignment__c s) {
	        servAssig = s;
	    }
	    
	    // Compare service Assigment based on the created date 
	    global Integer compareTo(Object compareTo) {

	        ServiceAssignmentWrapper compareToSA = (ServiceAssignmentWrapper)compareTo;
	        // The return value of 0 indicates that both elements are equal. 	    
	        Integer returnValue = 0;
	        if (servAssig.id > compareToSA.servAssig.id) {
                // Set return value to a negative value. 	    
	            returnValue = -1;
	        } else if (servAssig.id < compareToSA.servAssig.id) {
                // Set return value to a positive value. 
	            returnValue = 1;
	        }
	        return returnValue;
	    }
    }
    */
    
}