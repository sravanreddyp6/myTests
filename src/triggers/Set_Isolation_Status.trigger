trigger Set_Isolation_Status on Evaluation_Response__c (before insert, before update) {
    ID rtId = null;
    List<RecordType> rt = [select id from RecordType where DeveloperName = 'Isolation_Event' and sObjectType = 'Evaluation_Response__c' limit 1];
    if(rt.size() < 1){
        return;
    } else {
        rtId = rt[0].ID;
    }
    for (evaluation_response__c er : Trigger.new){
        if(er.Isolation_Event_End_Date__c == null && er.RecordTypeId == rtId){
            er.Isolation_Status__c = 'Isolated';
        }else if(er.Isolation_Event_End_Date__c != null && er.RecordTypeId == rtId){
            er.Isolation_Status__c = 'Not Isolated';
        }else{
            er.Isolation_Status__c = '';    
        }                      
    }
}