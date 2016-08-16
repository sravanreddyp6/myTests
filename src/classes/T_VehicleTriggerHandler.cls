public with sharing class T_VehicleTriggerHandler {
    private boolean m_isExecuting = false;


public T_VehicleTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
 
    public void OnBeforeInsert(T_Vehicle__c[] oldObjects, T_Vehicle__c[] updatedObjects, Map<Id, T_Vehicle__c> oldObjMap, Map<Id,T_Vehicle__c> newObjMap) {
        checkDuplicateVehicle(filterListForRecType('ADH', updatedObjects), newObjMap);
    }

    public void OnAfterInsert(T_Vehicle__c[] oldObjects, T_Vehicle__c[] updatedObjects, Map<Id, T_Vehicle__c> oldObjMap, Map<Id,T_Vehicle__c> newObjMap){
    }

    public void OnBeforeUpdate(T_Vehicle__c[] oldObjects, T_Vehicle__c[] updatedObjects, Map<Id, T_Vehicle__c> oldObjMap, Map<Id,T_Vehicle__c> newObjMap) {
        checkDuplicateVehicle(filterListForRecType('ADH', updatedObjects), newObjMap);
    }

    public void OnAfterUpdate(T_Vehicle__c[] oldObjects, T_Vehicle__c[] updatedObjects, Map<Id, T_Vehicle__c> oldObjMap, Map<Id,T_Vehicle__c> newObjMap) {
    }   

    private void checkDuplicateVehicle(T_Vehicle__c[] updatedObjects, Map<Id,T_Vehicle__c> newObjMap){
        Id adhVehicleRecTyp = Utility.getVehicleRecordType('ADH');
        if (updatedObjects.size()==0 || updatedObjects[0].recordTypeId != adhVehicleRecTyp ) return;
        set<String> newNames = new set<String>();
        for(T_Vehicle__c vehicle : updatedObjects){
            if (!newNames.add(vehicle.Name)) {
                    vehicle.Name.addError('Duplicate Vehicle Registration Number.');
            }
        }
        
        list<T_Vehicle__c> existingVehicles;
        if (newObjMap != null ) existingVehicles = [select Id, Name from T_Vehicle__c where Name IN : newNames and Id Not IN : newObjMap.keyset() and RecordTypeId =: adhVehicleRecTyp ];
        else existingVehicles = [select Id, Name from T_Vehicle__c where Name IN : newNames and RecordTypeId =: adhVehicleRecTyp ];
        for(T_Vehicle__c  v : existingVehicles){
           for(T_Vehicle__c  v1 : updatedObjects){
                if (v.Name.EqualsIgnoreCase(v1.Name)){
                       v1.Name.addError('Duplicate Vehicle Registration Number.');
                       break;
                }
            }
        }
    }
        
    private list<T_Vehicle__c> filterListForRecType(String recType, T_Vehicle__c[] updatedObjects){
        Id filterRecTyp = Utility.getVehicleRecordType(recType);
        list<T_Vehicle__c> updatedRoutes = new list<T_Vehicle__c>();
        for (T_Vehicle__c event : updatedObjects) {
            if (event.recordTypeId == filterRecTyp) updatedRoutes.add(event);  
        }
        return updatedRoutes;
    }
    
}