public with sharing class ServiceLocationTriggerHandler {

	private boolean m_isExecuting = false;

    public ServiceLocationTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterInsert(Service_Location__c [] newObjects){
        updateServiceCodeInfo( newObjects );
        
    }
    public void OnAfterUpdate(Service_Location__c [] newObjects){
        updateServiceCodeInfo( newObjects );
        
    }
    
    private void updateServiceCodeInfo (Service_Location__c[] newObjects ) {
		
		Map<String, Service_Location__c> slMap = new Map<String, Service_Location__c>();
		for ( Service_Location__c sl : newObjects ) {
			
			slMap.put( sl.ProgramID__c, sl);
		}
		
		
		// get all the service codes with this program code
		List<Service_Code__c> servcodes = [ select id, program_code__c, program_rollup__c from service_code__c where program_code__c in :slMap.keySet() ];
		
		for ( Service_code__c sc : servcodes ) {
			
			sc.Program_Rollup__c = slMap.get( sc.Program_code__c ).Program_Rollup__c;
			
		}
		
		update servcodes;
		    	
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}