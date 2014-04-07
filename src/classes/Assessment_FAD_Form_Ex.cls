public with sharing class Assessment_FAD_Form_Ex {
    public Assessment__c assess { get; set; }
    public string mode {get; set;}
    
    public map<string, boolean> mapAvalPhases = new map<string, boolean>();
    public map<string, boolean> getmapAvalPhases(){ return mapAvalPhases;}
    
    public map<string, assessment_Question__c> mapQs = new map<string, assessment_Question__c>();
    public map<string, assessment_Question__c> getMapQs(){ return mapQs;}
     
    public map<string, Assessment_Response__c> mapRes = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapRes(){ return mapRes;}
    
    public User curU = [select id, UserRoleId from user where id =:UserInfo.getUserId()];
        
    public Assessment_FAD_Form_Ex(ApexPages.StandardController controller) {
        assess = new assessment__c ();
        assess = (Assessment__c) controller.getRecord();
        mode ='view';
        if(ApexPages.currentPage().getParameters().get('edit') == '1'){
            mode = 'edit';
        }
        
        if(ApexPages.currentPage().getParameters().get('isnew') == '1'){
            mode = 'edit';
        }
        
        for(Assessment_Question__c aq: [select id, Dev_Name__c, Question_Title__c from Assessment_Question__c Where Question_Domain__r.Assessment_Type2__c = 'FAD Summary']){        
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
        // check the PBS questions
        if(mapRes.get('PBS_Problem_Solving').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Problem_Solving').Score__c.addError('Person Being Served - Problem Solving must have a score');
            hasError = true;
        }
        if(mapRes.get('PBS_Communication').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Communication').Score__c.addError('Person Being Served - Communication must have a score');
            hasError = true;
        }                             
        if(mapRes.get('PBS_Roles').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Roles').Score__c.addError('Person Being Served - Roles must have a score');
            hasError = true;
        }        
        if(mapRes.get('PBS_Affective_Responses').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Affective_Responses').Score__c.addError('Person Being Served - Affective Responses must have a score');
            hasError = true;
        } 
        if(mapRes.get('PBS_Affective_Involvement').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Affective_Involvement').Score__c.addError('Person Being Served - Affective Involvement must have a score');
            hasError = true;
        }        
        if(mapRes.get('PBS_Behavior_Control').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_Behavior_Control').Score__c.addError('Person Being Served - Behavior Control must have a score');
            hasError = true;
        } 
        if(mapRes.get('PBS_General_Functioning').Score__c == null && !mapRes.get('PBS_Could_Not_complete').Yes_No__c){
            mapRes.get('PBS_General_Functioning').Score__c.addError('Person Being Served - General Functioning must have a score');
            hasError = true;
        } 
        // Caregiver check
        if(mapRes.get('CG_Problem_Solving').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Problem_Solving').Score__c.addError('Caregiver - Problem Solving must have a score');
            hasError = true;
        }
        if(mapRes.get('CG_Communication').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Communication').Score__c.addError('Caregiver - Communication must have a score');
            hasError = true;
        }                             
        if(mapRes.get('CG_Roles').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Roles').Score__c.addError('Caregiver - Roles must have a score');
            hasError = true;
        }        
        if(mapRes.get('CG_Affective_Responses').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Affective_Responses').Score__c.addError('Caregiver - Affective Responses must have a score');
            hasError = true;
        } 
        if(mapRes.get('CG_Affective_Involvement').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Affective_Involvement').Score__c.addError('Caregiver - Affective Involvement must have a score');
            hasError = true;
        }        
        if(mapRes.get('CG_Behavior_Control').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_Behavior_Control').Score__c.addError('Caregiver - Behavior Control must have a score');
            hasError = true;
        } 
        if(mapRes.get('CG_General_Functioning').Score__c == null && !mapRes.get('CG_Could_Not_complete').Yes_No__c){
            mapRes.get('CG_General_Functioning').Score__c.addError('Caregiver - General Functioning must have a score');
            hasError = true;
        }                        
        if(mapRes.get('CG_is_same_as_other_assessment').Rating__c == null && assess.Phase__c !='Initial' ){
            mapRes.get('CG_is_same_as_other_assessment').Rating__c.addError('Caregiver - Did they caregiver who completed the initial FAD assessment also complete this 3-month or final assessment');
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
    Map<String, UserRole> roleMap  = new Map<String, UserRole>();
    public boolean IsLogedHigherRole{ set;}
    public boolean getIsLogedHigherRole(){
        rolemap.clear();
        roleMap = new Map<String, UserRole>([SELECT Id, Name, parentRoleId FROM UserRole]); 
        User curU = [select id, UserRoleId from user where id =:UserInfo.getUserId()];
        User theOwner = [select id, UserRoleID from user where id=:assess.ownerID];
        Boolean resVal = false;
    
    if(curU.UserRoleId == roleMap.get(theOwner.UserRoleID).parentRoleId){ return true;}
    
    resVal = traverseRoleHierarchy(curU.UserRoleId, theOwner.UserRoleID , roleMap.get(theOwner.UserRoleId).parentRoleId);
    
    
        return resVal ;
    }
    
            public Boolean traverseRoleHierarchy(String uManagerRoleId, String uRoleId, String uParentRoleId)
            {
                if(roleMap!=null && roleMap.containsKey(uParentRoleId))
                {
                    UserRole uRole = roleMap.get(uParentRoleId);
                    if( uManagerRoleId == uParentRoleId || uManagerRoleId == uRole.ParentRoleId)
                        return true;
                    else
                    {
                        return traverseRoleHierarchy( uManagerRoleId, uParentRoleId, uRole.ParentRoleId);                   
                    }
                }
                
                return false;
            }    
    public boolean canSubmit{set;}        
    public boolean getCanSubmit(){
    //currently used to define who can disgregard as well
    List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
                for ( PermissionSetAssignment p : userperms ) {
                        
                        // user can only update if in one of these three permission sets
                        
                        
                        if (
                                p.PermissionSet.Name.Contains('ESD_Notes_Organizer')) {
                                System.Debug('User is allowed.');
                                return true;    
                                }
                }
                return false;        

    
    }
    
    public boolean canUnlock{set;}        
    public boolean getcanUnlock(){
    //currently used to define who can disgregard as well
    List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
                for ( PermissionSetAssignment p : userperms ) {
                        
                        // user can only update if in one of these three permission sets
                        
                        
                        if (
                                p.PermissionSet.Name.Contains('ESD_Notes_Supervisor')) {
                                System.Debug('User is allowed.');
                                return true;    
                                }
                }
                return false;        

    
    }    
          
}