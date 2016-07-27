public without sharing class T_EventTriggerHandler {
    private boolean m_isExecuting = false;

    public T_EventTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
 
    public void OnBeforeInsert(T_Event__c[] oldObjects, T_Event__c[] updatedObjects, Map<Id, T_Event__c> oldObjMap, Map<Id,T_Event__c> newObjMap) {
        checkDuplicateRoute(filterListForRecType('Route', updatedObjects), newObjMap);
        checkDuplicateVehicle(filterListForRecType('Vehicle', updatedObjects), newObjMap);
    }

    public void OnAfterInsert(T_Event__c[] oldObjects, T_Event__c[] updatedObjects, Map<Id, T_Event__c> oldObjMap, Map<Id,T_Event__c> newObjMap){
    }

    public void OnBeforeUpdate(T_Event__c[] oldObjects, T_Event__c[] updatedObjects, Map<Id, T_Event__c> oldObjMap, Map<Id,T_Event__c> newObjMap) {
        checkDuplicateRoute(filterListForRecType('Route', updatedObjects), newObjMap);
        checkDuplicateVehicle(filterListForRecType('Vehicle', updatedObjects), newObjMap);
    }

    public void OnAfterUpdate(T_Event__c[] oldObjects, T_Event__c[] updatedObjects, Map<Id, T_Event__c> oldObjMap, Map<Id,T_Event__c> newObjMap) {
    }   

    private void checkDuplicateRoute(T_Event__c[] updatedObjects, Map<Id,T_Event__c> newObjMap){
        Id routeRecTyp = Utility.getEventRecordType('Route');
        if (updatedObjects.size()==0 || updatedObjects[0].recordTypeId != routeRecTyp) return;
        set<String> newNames = new set<String>();
        for(T_Event__c route : updatedObjects){
    			if (!newNames.add(route.Name)) {
    				route.Name.addError('Duplicate Route Name.');
    			}
    	}
        list<T_Event__c> existingRoutes;
        if (newObjMap != null ) existingRoutes = [select Id, Name from T_Event__c where Name IN : newNames and Id Not IN : newObjMap.keyset() and RecordTypeId =: routeRecTyp];
        else existingRoutes = [select Id, Name from T_Event__c where Name IN : newNames and RecordTypeId =: routeRecTyp];
        for(T_Event__c  r : existingRoutes){
	       for(T_Event__c  r1 : updatedObjects){
                if (r.Name.EqualsIgnoreCase(r1.Name)){
	                   r1.Name.addError('Duplicate Route Name.');
	                   break;
                }
            }
    	}
    }

    private void checkDuplicateVehicle(T_Event__c[] updatedObjects, Map<Id,T_Event__c> newObjMap){
        Id vehicleRecTyp = Utility.getEventRecordType('Vehicle');
        if (updatedObjects.size()==0 || updatedObjects[0].recordTypeId != vehicleRecTyp) return;
        set<String> newNames = new set<String>();
        for(T_Event__c vehicle : updatedObjects){
            if (!newNames.add(vehicle.Name)) {
                    vehicle.Name.addError('Duplicate Vehicle Registration Number.');
            }
        }
        
        list<T_Event__c> existingVehicles;
        if (newObjMap != null ) existingVehicles = [select Id, Name from T_Event__c where Name IN : newNames and Id Not IN : newObjMap.keyset() and RecordTypeId =: vehicleRecTyp];
        else existingVehicles = [select Id, Name from T_Event__c where Name IN : newNames and RecordTypeId =: vehicleRecTyp];
        for(T_Event__c  v : existingVehicles){
           for(T_Event__c  v1 : updatedObjects){
                if (v.Name.EqualsIgnoreCase(v1.Name)){
                       v1.Name.addError('Duplicate Vehicle Registration Number.');
                       break;
                }
            }
        }
    }
        
    private list<T_Event__c> filterListForRecType(String recType, T_Event__c[] updatedObjects){
    	Id filterRecTyp = Utility.getEventRecordType(recType);
    	list<T_Event__c> updatedRoutes = new list<T_Event__c>();
        for (T_Event__c event : updatedObjects) {
            if (event.recordTypeId == filterRecTyp) updatedRoutes.add(event);  
        }
        return updatedRoutes;
    }


}