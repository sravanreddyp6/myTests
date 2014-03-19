public with sharing class Assessment_FAD_Form_Ex {
    public Assessment__c assess { get; set; }
    public string mode {get; set;}
    public map<string, assessment_Question__c> mapQs = new map<string, assessment_Question__c>();
    public map<string, assessment_Question__c> getMapQs(){ return mapQs;}
     
    public map<string, Assessment_Response__c> mapRes = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapRes(){ return mapRes;}
        
    public Assessment_FAD_Form_Ex(ApexPages.StandardController controller) {
        assess = new assessment__c ();
        assess = (Assessment__c) controller.getRecord();
        assess.Type__c = 'FAD';
        mode = 'edit';
        if(ApexPages.currentPage().getParameters().get('isnew') == '1'){
            assess.accountperson__c = ApexPages.currentPage().getParameters().get('pbs');
            assess.service_assignment__c = ApexPages.currentPage().getParameters().get('sa'); 
            assess.admission__c = ApexPages.currentPage().getParameters().get('admin');
        }
        
        for(Assessment_Question__c aq: [select id, Dev_Name__c, Question_Title__c from Assessment_Question__c Where Question_Domain__r.Assessment_Type2__c = 'FAD']){        
            mapQs.put(aq.Dev_Name__c, aq);
            Assessment_Response__c tmpAR = new Assessment_Response__c();
            mapRes.put(aq.Dev_Name__c, tmpAR );
        }
        
        for(Assessment_Response__c ar: [select rating__c, Yes_No__c, Response__c, score__c, id, question__c, question__r.dev_name__c from assessment_response__c where assessment__c =:assess.id]){
            mapRes.put(ar.question__r.Dev_Name__c, ar);
        
        }
    }
    
    
    public PageReference mySave(){
        try{
            upsert mapRes.values();
            upsert Assess;
        
        
    
        } catch (Exception ex) {
                ApexPages.addMessages(ex);
                mode = 'edit';
                return null;
        }  
        mode = 'view';
        return null;   
    } 
    
    
    public PageReference myEdit(){
        mode = 'edit';
        return null;   
    }       

}