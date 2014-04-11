public with sharing class Assessment_FADResearchSummaryRpt_cnt {
    public map<string, Assessment_Response__c> mapResults = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapResults(){ return mapResults;}

    public list<string> repeatList= new list<string>();
    public list<string> getrepeatList (){ return repeatList;}    

    public Date fStartDate{get{return fStartDate;} set;}
    
    public PageReference runReport(){
        set<id> saScope = new set<id>();
        mapResults.clear();
        repeatList.clear();
    
        List<Assessment_Response__c> tmpAR = new list<Assessment_Response__c>();
        tmpar = [select id, Question__r.Dev_Name__c, assessment__r.Service_Assignment__r.person_being_served__c, Assessment__c, 
                        assessment__r.Service_Assignment__r.admission__r.Effective_Date__c,
                        assessment__r.Assessment_Date__c,
                        assessment__r.Service_Assignment__r.person_being_served__r.LastName,
                        assessment__r.Service_Assignment__r.person_being_served__r.FirstName,
                        Rating__c, Score__c, Yes_No__c, assessment_response__c.assessment__r.Phase__c, 
                        assessment_response__c.assessment__r.AccountID__c, assessment_response__c.assessment__r.Service_Assignment__c 
                                from Assessment_response__c 
                                    Where assessment_response__c.assessment__r.Disregard__c = False AND assessment_response__c.assessment__r.type__c = 'FAD Summary'];
            set<string> QuestionNames = new set<string>();
            for(Assessment_Response__c AR: tmpAR){
                questionnames.add(ar.Question__r.Dev_Name__c);
                boolean hasItem = false;
                for(string item: repeatList){                    
                    if(item == ar.assessment__r.Service_Assignment__c){
                        hasItem = true;
                    }                
                }
                if(!hasItem){
                    repeatList.add(ar.assessment__r.Service_Assignment__c);                
                }            
            
            }
            
            for(string item: repeatList){
                for(string QN: questionNames){
                    Assessment_Response__c blankAR = new Assessment_Response__c();
                    assessment__c blankAssess = new Assessment__c();
                    blankAssess.Assessment_Date__c= system.today()-100;
                    blankAR.Assessment__c = blankAssess.id;
                    mapResults.put('Initial' + QN + item,blankAR);
                    mapResults.put('3 Month' + QN + item,blankAR);
                    mapResults.put('Final' + QN + item,blankAR);
                }
            
            
            }
            
            for(Assessment_Response__c AR: tmpAR){
                saScope.add(ar.assessment__r.Service_Assignment__c);
                mapResults.put(ar.assessment__r.Phase__c + ar.Question__r.Dev_Name__c + ar.assessment__r.Service_Assignment__c,AR);
                

            }
        
        
        return null;
    }
    
    public Assessment_FADResearchSummaryRpt_cnt(){
        runReport();
    }
}