trigger Notes_ProgressNote_BeforeInsertUpdate on Progress_Note__c (before insert, before update) {
	if(!system.ISFUTURE()){
		
	    list<Progress_Note__c > PNs= new list<Progress_Note__c >();    
	    PNs = trigger.new;
	    Set<Id> planIDs = new Set<Id>();    
	
	    for (Progress_Note__c  local : PNs) {
	        if (local.Plan__c != null) {
	            planids.add(local.Plan__c);
	        }
	    }
	    Map<Id, Plan__c> AllPlans = new Map<Id, Plan__c>([select ID from Plan__c where id in :PlanIds]);
	    
	    List<Plan__c> PlansToUpdate = new List<Plan__c>();
	    
	    for(Progress_Note__c  local : PNs){         
	        if(local.plan__c !=null){
	            if(local.Start_time__c < local.Date_Service_Started_on_Plan__c || local.Date_Service_Started_on_Plan__c == null ){
	                system.debug('entered truth' + local.Plan__c);
	                Plan__c ChangePlan = AllPlans.get(local.Plan__c);
	                ChangePlan.Date_Service_Started__c = local.Start_Time__c.Date();
	                PlansToUpdate.add(ChangePlan);
	                
	            }        
	        }
	    }
	    
	   update PlansToUpdate ;

	}
}