global class SAUpdateSALocationCountBatch implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT id, Service_Location__c, Person_Being_Served__c, PBS_ServiceLocation_Count__c FROM Service_Assignment__c where Service_Location__c != null and (PBS_ServiceLocation_Count__c = null OR PBS_ServiceLocation_Count__c = 0) order by id desc';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Service_Assignment__c> updatedObjects ){
	    boolean found;
        Map<String,SAaggregates> currCounts = getSAaggregateMap();
        // loop through all the updated service assignments
        for(Service_Assignment__c sa :updatedObjects){
			if (currCounts.containsKey(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c))){
					sa.PBS_ServiceLocation_Count__c = currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).total;
	                --currCounts.get(String.valueOf(sa.Service_Location__c) + String.valueOf(sa.Person_Being_Served__c)).total;
				}
		}
		update updatedObjects;
    }

    private Map<String,SAaggregates> getSAaggregateMap(){
    	Map<String,SAaggregates> aggregates = new Map<String,SAaggregates>();
        List<AggregateResult> currCounts = [SELECT Service_Location__r.id slID, Person_Being_Served__c, count (id) total FROM Service_Assignment__c where Service_Location__c != null group by Person_Being_Served__c, Service_Location__r.id];
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
    
	
	global void finish(Database.BatchableContext BC){
		List<String> toAddresses = new List<String>();
		toAddresses.add('contractor.neeraj.gupta@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('SalesforceBatchUpdates');
		mail.setSubject('SA location count Update Batch Run');
		mail.setUseSignature(false);
		string body = 'Salesforce Batch to update SA location count on the service assignment completed';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
}