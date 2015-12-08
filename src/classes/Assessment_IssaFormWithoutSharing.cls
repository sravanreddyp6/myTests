public with sharing class Assessment_IssaFormWithoutSharing extends Assessment_AbstractForm implements DSP_AssessmentResponseType{
    
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}
    
    public map<id, boolean> mapDomainHasRisk = new map<id, boolean>();
    public map<id, boolean> getmapDomainHasRisk  (){ return mapDomainHasRisk ;}    
    
    public Assessment_IssaFormWithoutSharing(Id assessmentId) {
        super(assessmentId);
        String strSQLResp =  'SELECT ' + String.join(selectFieldsAssessResp, ',') + ' FROM Assessment_Response__c WHERE assessment__c = \'' + assessment.id + '\'';
        List<Assessment_Response__c> CurrentResps = (List<Assessment_Response__c>) Database.query(strSQLResp);
        for(Assessment_Response__c local: CurrentResps){
            DomainsInScopeIDs.Add(local.Question__r.Question_Domain__c);
            QuestionsInScopeIDs.Add(local.Question__c);
            // calculate whether this domain as a whole has risk
            if (mapDomainHasRisk.containsKey(local.Question__r.Question_Domain__c) && mapDomainHasRisk.get(local.Question__r.Question_Domain__c)) {
                continue;
            } else {
                if(local.rating__c != null  &&  local.rating__c.equalsIgnoreCase('yes') ) {
                    mapDomainHasRisk.put(local.Question__r.Question_Domain__c,true);
                } else {
                    mapDomainHasRisk.put(local.Question__r.Question_Domain__c,false);
                } 
            }
        }
        
        List<Assessment_Question__c > tmpQ = [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, Question_Domain__c,
                        (Select Name, Score__c, Rating__c, Color__c, Rating_Description__c, Show_These_Fields__c, id
                                From Assessment_Question_Option__r 
                                Order By Sort_Order__c)  
                From Assessment_Question__c 
                Where ID in  :QuestionsInScopeIDs];
        
            for(Assessment_Question__c local : tmpQ){
                // always show the extra questions - we'll do the show/hide toggle on the front end
                List<String> showFields= new List<String>{'Description_of_risk__c'};
                List<String> emptyList= new List<String>();
                    for(Assessment_Question_Option__c QO : local.Assessment_Question_Option__r ){
                        // if the question contains the words 'supports' then add the extra field to show                        
                        if ( local.Question_title__c.contains('supports') ) {
                            mapQuestions.put(local.id+QO.Rating__c, showfields);      
                        } else
                            mapQuestions.put(local.id+QO.Rating__c, emptyList);
                    }
                    // add the question options for when the radio button is not selected
                    if ( local.Question_title__c.contains('supports'))
                        mapQuestions.put(local.id, showFields);
                    else
                        mapQuestions.put(local.id, emptyList);
            }
            
    }
    public override Map<id, Map<string,Object>> getMapCurrentResps(){
        if (this.mapCurrentResps == null) {
            this.mapCurrentResps = new Map<id, Map<String,Object>>();
            String strSQLResp =  'SELECT ' + String.join(selectFieldsAssessResp, ',') + ' FROM Assessment_Response__c WHERE assessment__c = \'' + assessment.id + '\'';
            List<Assessment_Response__c> CurrentResps = (List<Assessment_Response__c>) Database.query(strSQLResp);
            for (Assessment_Response__c response : CurrentResps){
                Map<String, Object> m = new Map<String, Object>();
                for(String s : selectFieldsAssessResp){
                    m.put(s,'');
                }
                updateMapWithRelationshipKeys(m, JSON.serialize(response), '');
                mapCurrentResps.put(response.Question__c, m);
            }
        } 
        return this.mapCurrentResps;
    }
}