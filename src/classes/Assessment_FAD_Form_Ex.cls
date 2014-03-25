public with sharing class Assessment_FAD_Form_Ex {
    public Assessment__c assess { get; set; }
    public string mode {get; set;}
    
    public map<string, boolean> mapAvalPhases = new map<string, boolean>();
    public map<string, boolean> getmapAvalPhases(){ return mapAvalPhases;}
    
    public map<string, assessment_Question__c> mapQs = new map<string, assessment_Question__c>();
    public map<string, assessment_Question__c> getMapQs(){ return mapQs;}
     
    public map<string, Assessment_Response__c> mapRes = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapRes(){ return mapRes;}
        
    public Assessment_FAD_Form_Ex(ApexPages.StandardController controller) {
        assess = new assessment__c ();
        assess = (Assessment__c) controller.getRecord();
        assess.Type__c = 'FAD';
        mode ='view';
        if(ApexPages.currentPage().getParameters().get('edit') == '1'){
            mode = 'edit';
        }
        
        if(ApexPages.currentPage().getParameters().get('isnew') == '1'){
            mode = 'edit';
        }
        
        for(Assessment_Question__c aq: [select id, Dev_Name__c, Question_Title__c from Assessment_Question__c Where Question_Domain__r.Assessment_Type2__c = 'FAD']){        
            mapQs.put(aq.Dev_Name__c, aq);
            Assessment_Response__c tmpAR = new Assessment_Response__c();
            mapRes.put(aq.Dev_Name__c, tmpAR );
        }
        
        for(Assessment_Response__c ar: [select rating__c, Yes_No__c, Response__c, score__c, id, question__c, question__r.dev_name__c from assessment_response__c where assessment__c =:assess.id]){
            mapRes.put(ar.question__r.Dev_Name__c, ar);
        
        }
        mapAvalPhases.put('Initial', true);
        mapAvalPhases.put('3 Month',true);
        mapAvalPhases.put('Final',true);
        
    }
    public PageReference myCG_is_same_as_other_assessment(){
        if(assess.Phase__c =='Initial'){
        
        mapRes.get('CG_is_same_as_other_assessment').Rating__c = null;
        }
        return null;
    }
    public PageReference myDisregard(){
        try{
            Assess.Disregard__c = True;
            upsert Assess;
        
        
    
        } catch (Exception ex) {
                ApexPages.addMessages(ex);
                return null;
        }  
        mode = 'view';
        return null;   
    } 
        
    public PageReference mySave(){
        try{
            list<assessment__c> oldAssess = new list<assessment__c>();
            
            oldassess = [select id from assessment__c where Service_Assignment__c = :assess.service_assignment__c AND Disregard__c = false AND Phase__c = :assess.phase__c AND id != :assess.id];
            
            if (oldassess.size() > 0){
                assess.phase__c.adderror('An assessment with this service assignment and phase has already been created');
                return null;
            
            }
            upsert mapRes.values();
            upsert Assess;
        
        
    
        } catch (DMLException e) {
                ApexPages.addMessages(e);
                mode = 'edit';
                return null;
        }  
        PageReference ref =  new PageReference('/'+this.assess.id); 
        return  ref;
    } 
    
    
    public PageReference myEdit(){
        mode = 'edit';
        return null;   
    }       

    public PageReference myLock(){
        boolean hasError = false;
        if(mapRes.get('CG_Could_Not_complete').Yes_No__c && mapRes.get('CG_Could_Not_complete_reason').Rating__c == null){
            mapRes.get('CG_Could_Not_complete_reason').Rating__c.addError('Please provide a reason the Caregiver could not complete all questions');
            hasError = true;   
        }
        if(mapRes.get('PBS_Could_Not_complete').Yes_No__c && mapRes.get('PBS_Could_Not_complete_reason').Rating__c == null){
            mapRes.get('PBS_Could_Not_complete_reason').Rating__c.addError('Please provide a reason the Person being served could not complete all questions');
            hasError = true;   
        }        
        if(hasError){
            mode='edit';
            return null;
        }
        assess.Status__c = 'Locked';
        update assess;
        return null;   
    }  
    public PageReference myUnlock(){
        assess.Status__c = 'Open';
        update assess;
        return null;   
    }    

    public PageReference myCancel(){ 
        //used only on new form
        try{
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assess);
            assess.Delete_Assessment__c =true;            
            PageReference ref =  new PageReference('/'+this.assess.service_assignment__c);
            ctr.save();
            
            
            return ref; 
              
        }
            catch(System.DmlException e){
           // ApexPages.addMessages(e);
            return null;
        }
        return null;
        
             
    }       
}