public with sharing class Assessment_FADResearchSummaryRpt_cnt {
    public map<string, Assessment_Response__c> mapResults = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapResults(){ return mapResults;}

    //this object must be a list (not a set) so item are looped in the correct order on the VF page
    public list<string> repeatList= new list<string>();
    public list<string> getrepeatList (){ return repeatList;}    

    public map<string, Assessment_Response__c> mapCoreData {get; set;}

    public Assessment_FADResearchSummaryRpt_cnt(){
        mapCoreData = new map<string, Assessment_Response__c>();
        runReport();
    }
    set<string> OK_Questions{ set; get{
    
        set<string> mylist = new set<string>();
            mylist.add('PBS_Could_Not_complete');
            mylist.add('PBS_Affective_Involvement');
            mylist.add('PBS_Affective_Responses');
            mylist.add('PBS_Behavior_Control');
            mylist.add('PBS_Communication');
            mylist.add('PBS_General_Functioning');
            mylist.add('PBS_Problem_Solving');
            mylist.add('PBS_Roles');
            mylist.add('CG_Could_Not_complete');
            mylist.add('CG_Affective_Involvement');
            mylist.add('CG_Affective_Responses');
            mylist.add('CG_Behavior_Control');
            mylist.add('CG_Communication');
            mylist.add('CG_General_Functioning');
            mylist.add('CG_Problem_Solving');
            mylist.add('CG_Roles');
            mylist.add('Caregiver_Who_Completed_Assessment');
            mylist.add('PC_Name');
            mylist.add('SC_Name');
            mylist.add('PBS_Could_Not_complete_reason');
            mylist.add('CG_Could_Not_complete_reason');
        return mylist;
    
    }}
    public PageReference runReport(){

        mapResults.clear();
        repeatList.clear();
        mapCoreData.clear();
        List<Assessment_Response__c> tmpAR = new list<Assessment_Response__c>();
        tmpar = [select id, Question__r.Dev_Name__c, assessment__r.Service_Assignment__r.person_being_served__c, Assessment__c, 
                        assessment__r.Service_Assignment__r.admission__r.Effective_Date__c,
                        assessment__r.Service_Assignment__r.Program_Detail__c,
                        assessment__r.Assessment_Date__c,
                        assessment__r.Service_Assignment__r.Phase_1_Start_Date__c,
                        assessment__r.Service_Assignment__r.person_being_served__r.Birthdate,
                        assessment__r.Service_Assignment__r.person_being_served__r.owner.name,
                        assessment__r.Service_Assignment__r.person_being_served__r.LastName,
                        assessment__r.Service_Assignment__r.person_being_served__r.FirstName,
                        Rating__c, Score__c, 
                        Yes_No__c, 
                        assessment_response__c.assessment__r.Phase__c, 
                        assessment_response__c.assessment__r.AccountID__c, 
                        assessment_response__c.assessment__r.Service_Assignment__c 
                        FROM Assessment_response__c 
                        WHERE assessment_response__c.assessment__r.Disregard__c = False 
                            AND 
                                assessment_response__c.assessment__r.type__c = 'FAD Summary'
                            AND
                                Question__r.Dev_Name__c in: OK_Questions
                            AND
                                assessment__r.Assessment_Date__c != null];
            
            for(Assessment_Response__c AR: tmpAR){
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
                for(string QN: OK_Questions){
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
                mapResults.put(ar.assessment__r.Phase__c + ar.Question__r.Dev_Name__c + ar.assessment__r.Service_Assignment__c,AR);
                mapCoreData.put(ar.assessment__r.Service_Assignment__c,AR);               
            }

        return null;
    }
    

    
    
}