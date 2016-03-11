public with sharing class ServiceLocationTriggerHandler {

    private boolean m_isExecuting = false;

    public ServiceLocationTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    public void OnAfterInsert( Service_Location__c [] newObjects){
        updateServiceCodeInfo( null, newObjects );
        
    }
    
    public void onBeforeInsert(  Service_Location__c [] newObjects ){
        setProgramString( null, newObjects);
    }
    public void onBeforeUpdate(  Map<ID, Service_Location__c> oldmap, Service_Location__c [] newObjects ){
        setProgramString( oldmap, newObjects);
    }
        
    public void setProgramString( Map<ID, Service_Location__c> oldmap, Service_Location__c[] newObjects ) {
        
        for ( Service_Location__c location : newObjects ) { 
        
            // RPI-513 - get only the service type string up to the hyphen 
            string stAbbrev = location.service_type__c;
            if ( !String.isBlank(location.service_type__c) && location.service_type__c.indexOf( '-') >= 0 ) 
                stAbbrev = location.service_type__c.substring( 0, location.service_type__c.indexOf( '-') - 1);
            
            location.Location_nickname__c = string.isBlank(location.Location_nickname__c) ? location.city__c+' '+location.Physical_Location__c : location.Location_nickname__c;
                        
            if (!string.isblank( location.state__c) && !string.isblank( location.location_nickname__c ) && !string.isblank( location.network_offering__c )) {   
                location.iServe_Program__c = location.State__c+'-'+ stAbbrev +'-'+location.Location_Nickname__c+'-'+ location.Network_Offering__c;
                system.debug( 'SOURCE:' + location.source_system__c + ', program:' + location.iserve_program__c);
                if ( location.source_system__c == 'iServe') 
                    location.program__c = location.iServe_Program__c;
            }
            //Sravan - Added below code to make sure Service Value gets populated for iServe locations uploaded through data loader for iServe locations
            if(string.isblank( location.Service_Value__c) && location.source_system__c == 'iServe'){
                location.Service_Value__c = location.Network_offering__c; 
            }
        }
        
    }
    public void OnAfterUpdate( Service_Location__c[] oldObjects, Service_Location__c [] newObjects){
        updateServiceCodeInfo( oldObjects, newObjects );
        
    }
    
    private void updateServiceCodeInfo (Service_Location__c[] oldObjects, Service_Location__c[] newObjects ) {
        
        Map<ID, Service_Location__c> oldSLMap = new Map<ID, Service_Location__c>();
        
        if ( oldObjects != null )
            oldSLMap.putAll( oldObjects);
            
        Service_Location__c oldSL;
        
        Map<String, Service_Location__c> slMap = new Map<String, Service_Location__c>();
        for ( Service_Location__c sl : newObjects ) {
            
            oldSL = oldSLMap.get(sl.ID);
            
            // if an update, check for change to specific fields
            if ( oldSL != null ) {
                if ( oldSL.Program_Rollup__c != sl.Program_Rollup__c || oldSL.Program__c != sl.Program__c )
                    slMap.put( sl.ProgramID__c, sl);
            } else {
                // always put new locations in for update
                slMap.put( sl.ProgramID__c, sl);
            }
        }
        
        
        // get all the service codes with this program code
        List<Service_Code__c> servcodes = [ select id, program_code__c, program_rollup__c from service_code__c where program_code__c in :slMap.keySet() ];
        
        for ( Service_code__c sc : servcodes ) {
            
            //update from service location
            sc.Program_Rollup__c = slMap.get( sc.Program_code__c ).Program_Rollup__c;
            sc.Program_Value__c = slMap.get(sc.Program_code__c).Program__c;
            
        }
        if (servcodes.size() > 0 )
            update servcodes;
                
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}