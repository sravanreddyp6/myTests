public without sharing class T_RouteTriggerHandler {
    private boolean m_isExecuting = false;

    public T_RouteTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
 
    public void OnBeforeInsert(T_Route__c[] oldObjects, T_Route__c[] updatedObjects, Map<Id, T_Route__c> oldObjMap, Map<Id,T_Route__c> newObjMap) {
        checkDuplicateRoute(filterListForRecType('ADH', updatedObjects), newObjMap);
    }

    public void OnAfterInsert(T_Route__c[] oldObjects, T_Route__c[] updatedObjects, Map<Id, T_Route__c> oldObjMap, Map<Id,T_Route__c> newObjMap){
    }

    public void OnBeforeUpdate(T_Route__c[] oldObjects, T_Route__c[] updatedObjects, Map<Id, T_Route__c> oldObjMap, Map<Id,T_Route__c> newObjMap) {
        checkDuplicateRoute(filterListForRecType('ADH', updatedObjects), newObjMap);
    }

    public void OnAfterUpdate(T_Route__c[] oldObjects, T_Route__c[] updatedObjects, Map<Id, T_Route__c> oldObjMap, Map<Id,T_Route__c> newObjMap) {
    }   

    private void checkDuplicateRoute(T_Route__c[] updatedObjects, Map<Id,T_Route__c> newObjMap){
        Id routeRecTyp = Utility.getRouteRecordType('ADH');
        if (updatedObjects.size()==0 || updatedObjects[0].recordTypeId != routeRecTyp) return;
        set<String> newNames = new set<String>();
        for(T_Route__c route : updatedObjects){
                if (!newNames.add(route.Name)) {
                    route.Name.addError('Duplicate Route Name.');
                }
        }
        list<T_Route__c> existingRoutes;
        if (newObjMap != null ) existingRoutes = [select Id, Name from T_Route__c where Name IN : newNames and Id Not IN : newObjMap.keyset() and RecordTypeId =: routeRecTyp];
        else existingRoutes = [select Id, Name from T_Route__c where Name IN : newNames and RecordTypeId =: routeRecTyp];
        for(T_Route__c  r : existingRoutes){
           for(T_Route__c  r1 : updatedObjects){
                if (r.Name.EqualsIgnoreCase(r1.Name)){
                       r1.Name.addError('Duplicate Route Name.');
                       break;
                }
            }
        }
    }

    private list<T_Route__c> filterListForRecType(String recType, T_Route__c[] updatedObjects){
        Id filterRecTyp = Utility.getRouteRecordType(recType);
        list<T_Route__c> updatedRoutes = new list<T_Route__c>();
        for (T_Route__c event : updatedObjects) {
            if (event.recordTypeId == filterRecTyp) updatedRoutes.add(event);  
        }
        return updatedRoutes;
    }
}