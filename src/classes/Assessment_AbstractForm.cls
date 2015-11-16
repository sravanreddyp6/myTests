public abstract class Assessment_AbstractForm {
    protected list<string> selectFields = new list<string>();
    protected list<string> selectFieldsAssessResp = new list<string>();	
    protected Assessment__c assessment { get; set; }
	
	protected Assessment_AbstractForm(Id assessmentId){
	    // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Assessment__c').getDescribe().Fields.getMap();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
        selectFields.addAll(new List<String>{ 'Admission__r.Name', 'Admission__r.State__c', 'LastModifiedBy.Name', 'CreatedBy.Name', 'Approved_By__r.Name', 'Admission__r.Person_Being_Served__r.Name'});
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Assessment__c WHERE Id = \'' + assessmentId + '\'';
        this.assessment = (Assessment__c) Database.query(strSQL)[0];


        fMap = Schema.getGlobalDescribe().get('Assessment_Response__c').getDescribe().Fields.getMap();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFieldsAssessResp.add(fd.getName());
            }
        }
        selectFieldsAssessResp.addAll(new List<String>{'Question__r.External_Id__c', 'Question__r.Question_Domain__c', 'Question__r.Question_Title__c'});
    }

    protected void updateMapWithRelationshipKeys(Map<String, Object> m, String jsonString, String relationshipKey){
            Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> newMap = new Map<String, Object>(); 
            for(String k : temp.keySet()){
                if(k.endsWithIgnoreCase('__r') || k == 'LastModifiedBy' || k == 'CreatedBy') updateMapWithRelationshipKeys(m, JSON.serialize(temp.get(k)), k);
                else {
                    if (String.IsBlank(relationshipKey) ) newMap.put(k, temp.get(k));
                    else newMap.put(relationshipKey + '.' + k,  temp.get(k));
                }
            }
            m.putAll(newMap);
            m.remove(String.IsBlank(relationshipKey) ? 'attributes' : relationshipKey + '.attributes'); // this is to remove this key, SF adds this when serializing the sObject.
    }
    
    
}