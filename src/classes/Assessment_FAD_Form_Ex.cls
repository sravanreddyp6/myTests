public with sharing class Assessment_FAD_Form_Ex {
    public Assessment__c assess { get; set; }
    public string mode {get; set;} 
    
    public string otherChildDisplayStyle {get; set;}
    
    public map<string, boolean> mapAvalPhases = new map<string, boolean>();
    public map<string, boolean> getmapAvalPhases(){ return mapAvalPhases;}
        
    public map<string, assessment_Question__c> mapQs = new map<string, assessment_Question__c>();
    public map<string, assessment_Question__c> getMapQs(){ return mapQs;}
     
    public map<string, Assessment_Response__c> mapRes = new map<string, Assessment_Response__c>();
    public map<string, Assessment_Response__c> getmapRes(){ return mapRes;}
    
    public User curU = [select id, UserRoleId from user where id =:UserInfo.getUserId()];
    
    public list<Related_Party__c> curOtherChilren {get; set;}
    
    public Related_Party__c curRel_Party {get; set;}
    public ID Rel_Party_ID {get; set;}
             
    public Assessment_FAD_Form_Ex(ApexPages.StandardController controller) {
        assess = new assessment__c ();
        assess = (Assessment__c) controller.getRecord();
        mode ='view';
        otherChildDisplayStyle = 'none';
        if(ApexPages.currentPage().getParameters().get('edit') == '1'){
            myEdit();
        }
        
        if(ApexPages.currentPage().getParameters().get('isnew') == '1'){
            myEdit();
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
        
        curOtherChilren = new list<Related_Party__c>();
        
        updateCurChildren();        
        curRel_Party  = new Related_Party__c ();
        
    }
    public void updateCurChildren(){
                curOtherChilren = [select Name, Age__c, Assessment__c, Gender__c, Received_FCT_services_before__c, Relationship_to_Person_Being_Served__c, Relationship_to_Person_Being_Served_Othe__c from Related_Party__c Where Assessment__c = :assess.id];   
    }     
    
    public PageReference myCG_is_same_as_other_assessment(){
        if(assess.Phase__c =='Initial'){
            mapRes.get('CG_is_same_as_other_assessment').Rating__c = null;
        }
        return null;
    }
    public PageReference editRel_Party(){
        for(Related_Party__c item :curOtherChilren ){
            if(item.id == Rel_Party_ID){
                system.debug('i tried-' + item.id);
                curRel_Party = item; 
            }
        }
        return null;
    } 
    public PageReference SaveNew_Rel_Party(){
        insertRelatedParty();
        updateCurChildren(); 
        resetRelParty();
   
        return null;
    }   
    public PageReference resetRelParty(){
        curRel_Party  = new Related_Party__c ();
        otherChildDisplayStyle = 'block';
        return null; 
    }
    public PageReference AddOtherChild(){
        //Related_Party__c tmp = new Related_Party__c ();
        if(!insertRelatedParty()){
            updateCurChildren(); 
            otherChildDisplayStyle = 'none';
        }
        else{
            otherChildDisplayStyle = 'block';
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
    public boolean insertRelatedParty(){
        curRel_Party.Assessment__c = assess.id;
        boolean hasError = false;
        if(curRel_Party.Relationship_to_Person_Being_Served__c =='Other' && curRel_Party.Relationship_to_Person_Being_Served_Othe__c ==null){
            curRel_Party.Relationship_to_Person_Being_Served_Othe__c.addError('Please specify the Other relationship to the Person Being Served.');
            hasError = true;
        }        
        if(!hasError){
            upsert curRel_Party;
        }
        return hasError;
    }    
    public PageReference mySave(){
        try{
            list<assessment__c> oldAssess = new list<assessment__c>();
            
            oldassess = [select id from assessment__c where Service_Assignment__c = :assess.service_assignment__c AND Disregard__c = false AND Phase__c = :assess.phase__c AND id != :assess.id];
            
            if (oldassess.size() > 0){
                assess.phase__c.adderror('An assessment with this service assignment and phase has already been created');
                return null;
            
            }
            if(!mapRes.get('CG_Could_Not_complete').Yes_No__c){
                mapRes.get('CG_Could_Not_complete_reason').rating__c = null;
            }
            if(!mapRes.get('PBS_Could_Not_complete').Yes_No__c){
                mapRes.get('PBS_Could_Not_complete_reason').rating__c = null;
            }            
            upsert mapRes.values();
            upsert Assess;
            upsert curOtherChilren;
        
    
        } catch (DMLException e) {
                ApexPages.addMessages(e);
                myEdit();
                return null;
        }  
        PageReference ref =  new PageReference('/'+this.assess.id); 
        return  ref;
    } 
    
    
    public PageReference myEdit(){
        if(assess.status__c != 'locked'){
            mode = 'edit';
        
        }
        return null;   
    }       

    public PageReference myLock(){
        boolean hasError = false;
        list<assessment__c> oldAssess = new list<assessment__c>();
        
        oldassess = [select id from assessment__c where Service_Assignment__c = :assess.service_assignment__c AND Disregard__c = false AND Phase__c = :assess.phase__c AND id != :assess.id];
//new rules
        if(mapRes.get('Caregiver_Who_Completed_Assessment').Rating__c == null){
            mapRes.get('Caregiver_Who_Completed_Assessment').Rating__c.addError('Please identify which caregiver completed this assessment.');
            hasError = true;   
        }
        if(mapRes.get('PC_Name').Rating__c == null){
            mapRes.get('PC_Name').Rating__c.addError('Please enter the name of the Primary Caregiver at the time of this FAD Assessment.');
            hasError = true;   
        }    
        if(mapRes.get('PC_Relationship_to_PBS').Rating__c == null){
            mapRes.get('PC_Relationship_to_PBS').Rating__c.addError('Please select the Primary Caregiver\'s relationship to the Person Being Served at the time of this FAD Assessment.');
            hasError = true;   
        }
            set<string> ForceOther = new set<string>();
            ForceOther.add('Other Female Relative');
            ForceOther.add('Other Male Relative');
            ForceOther.add('Other');        
        if(mapRes.get('PC_Relationship_to_PBS_Other').Rating__c == null && ForceOther.contains(mapRes.get('PC_Relationship_to_PBS').Rating__c) ){
            mapRes.get('PC_Relationship_to_PBS_Other').Rating__c.addError('Please specify the Primary Caregiver\'s relationship to the Person Being Served at the time of this FAD Assessment.');
            hasError = true;   
        } 
        else{mapRes.get('PC_Relationship_to_PBS_Other').Rating__c = null;}       
        if(!mapRes.get('SC_No_SC').Yes_No__c && mapRes.get('SC_Relationship_to_PBS_Other').Rating__c == null && ForceOther.contains(mapRes.get('SC_Relationship_to_PBS').Rating__c) ){
            mapRes.get('SC_Relationship_to_PBS_Other').Rating__c.addError('Please specify the Secondary Caregiver\'s relationship to the Person Being Served at the time of this FAD Assessment.');
            hasError = true;   
        } 
        else{mapRes.get('SC_Relationship_to_PBS_Other').Rating__c = null;}
        if(!mapRes.get('SC_No_SC').Yes_No__c && mapRes.get('SC_Name').Rating__c == null){
            mapRes.get('SC_Name').Rating__c.addError('Please select the name of the Secondary Caregiver at the time of this FAD Assessment or select "No secondary caregiver"');
            hasError = true;   
        }        
        if(!mapRes.get('SC_No_SC').Yes_No__c && mapRes.get('SC_Relationship_to_PBS').Rating__c == null){
            mapRes.get('SC_Relationship_to_PBS').Rating__c.addError('Please select the Secondary Caregiver\'s relationship to the Person Being Served at the time of this FAD Assessment.');
            hasError = true;   
        }         
        
        
        if(assess.phase__c == 'Initial' || assess.phase__c == 'Final'){
            if(mapRes.get('PC_Highest_Edu').Rating__c == null){
                mapRes.get('PC_Highest_Edu').Rating__c.addError('Please select a value for Primary Caregiver\'s Highest Education Completed at the time of this FAD Assessment.');
                hasError = true;   
            }    
            
            if(mapRes.get('PC_Employment').Rating__c == null){
                mapRes.get('PC_Employment').Rating__c.addError('Please select a value for Primary Caregiver\'s Employment at the time of this FAD Assessment.');
                hasError = true;   
            }  
            if(mapRes.get('PC_Employment').Rating__c == 'Employed' && mapRes.get('PC_Occupation').Rating__c == null){
                mapRes.get('PC_Occupation').Rating__c.addError('Please provide the Primary Caregiver\'s occupation at the time of this FAD Assessment.');
                hasError = true;   
            }                             
            if(mapRes.get('PC_Received_FCT_before').Rating__c ==  null){
                mapRes.get('PC_Received_FCT_before').Rating__c.addError('Please select a value for Primary Caregiver Received FCT services before?');
                hasError = true;   
            } 
            if(mapRes.get('SC_Highest_Edu').Rating__c == null){
                mapRes.get('SC_Highest_Edu').Rating__c.addError('Please select a value for Secondary Caregiver\'s Highest Education Completed at the time of this FAD Assessment.');
                hasError = true;   
            }    
            
            if(mapRes.get('SC_Employment').Rating__c == null){
                mapRes.get('SC_Employment').Rating__c.addError('Please select a value for Secondary Caregiver\'s Employment at the time of this FAD Assessment.');
                hasError = true;   
            }  
            if(mapRes.get('SC_Employment').Rating__c == 'Employed' && mapRes.get('SC_Occupation').Rating__c == null){
                mapRes.get('SC_Occupation').Rating__c.addError('Please provide the Secondary Caregiver\'s occupation at the time of this FAD Assessment.');
                hasError = true;   
            }                             
            if(mapRes.get('SC_Received_FCT_before').Rating__c ==  null){
                mapRes.get('SC_Received_FCT_before').Rating__c.addError('Please select a value for Secondary Caregiver Received FCT services before?');
                hasError = true;   
            }             
            
            if(assess.Family_Annual_Income__c ==null){
                assess.Family_Annual_Income__c.addError('Please select a value for Family Annual Income.');
            }         
        }
        /*
        for(Related_Party__c item :curOtherChilren ){
            if(item.Relationship_to_Person_Being_Served__c =='Other' && item.Relationship_to_Person_Being_Served_Othe__c ==null){
                item.Relationship_to_Person_Being_Served_Othe__c.addError('Please specify the Other relationship to the Person Being Served.');
            }
        
        }
        */
        if(mapRes.get('SC_No_SC').Yes_No__c && mapRes.get('Caregiver_Who_Completed_Assessment').Rating__c == 'Secondary'){
            mapRes.get('SC_No_SC').Yes_No__c.addError('If the secondary caregiver has completed this assessment, provide the secondary caregiver details.');
        
        }             
//end new rules

        
        if (oldassess.size() > 0){
            assess.phase__c.adderror('An assessment with this service assignment and phase has already been created');
            hasError = true;
        
        }        
        if(assess.phase__c == 'Initial' && assess.referral_date__c ==null){
            assess.referral_date__c.addError('Referral Date is required before you can submit this assessment');
            hasError = true;
        }
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
            mapRes.get('CG_is_same_as_other_assessment').Rating__c.addError('Caregiver - Did the caregiver who completed the initial FAD assessment also complete this 3-month or final assessment? is required.');
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
     public List<SelectOption> getPC_Rel_To_PBS() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));         
        options.add(new SelectOption('Self/Cares for Self - is an adult client','Self/Cares for Self - is an adult client'));
        options.add(new SelectOption('Biological Mother','Biological Mother'));
        options.add(new SelectOption('Biological Father','Biological Father'));
        options.add(new SelectOption('Foster Mother','Foster Mother'));
        options.add(new SelectOption('Foster Father','Foster Father'));
        options.add(new SelectOption('Adoptive Mother','Adoptive Mother'));
        options.add(new SelectOption('Adoptive Father','Adoptive Father'));
        options.add(new SelectOption('Grandmother','Grandmother'));
        options.add(new SelectOption('Grandfather','Grandfather'));                
        options.add(new SelectOption('Step-Mother','Step-Mother'));
        options.add(new SelectOption('Step-Father','Step-Father'));
        options.add(new SelectOption('Other Female Relative','Other Female Relative'));
        options.add(new SelectOption('Other Male Relative','Other Male Relative')); 
        options.add(new SelectOption('Family Friend','Family Friend'));
        options.add(new SelectOption('Client\'s Friend','Client\'s Friend'));  
        options.add(new SelectOption('Child of client','Child of client'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Unknown','Unknown'));                                         
        return options;
    }
    public List<SelectOption> getPhoneTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));         
        options.add(new SelectOption('Home','Home'));
        options.add(new SelectOption('Work','Work'));
        options.add(new SelectOption('Cell','Cell'));
        options.add(new SelectOption('Fax','Fax'));                                        
        return options;
    }   
    public List<SelectOption> getEduTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));         
        options.add(new SelectOption('No School','No School'));
        options.add(new SelectOption('Grammar/Middle School','Grammar/Middle School'));
        options.add(new SelectOption('Some High School','Some High School'));
        options.add(new SelectOption('High School Diploma/GED','High School Diploma/GED'));  
        options.add(new SelectOption('Some College','Some College'));
        options.add(new SelectOption('Vocational/Technical/Associates Degree','Vocational/Technical/Associates Degree'));  
        options.add(new SelectOption('Bachelors Degree','Bachelors Degree'));
        options.add(new SelectOption('Masters Degree','Masters Degree'));  
        options.add(new SelectOption('PhD/MD','PhD/MD'));
        options.add(new SelectOption('Unknown','Unknown'));                                                                
        return options;
    }    
    
    public List<SelectOption> getEmploTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));         
        options.add(new SelectOption('Unemployed','Unemployed'));
        options.add(new SelectOption('Employed','Employed'));
        options.add(new SelectOption('Retired','Retired'));
        options.add(new SelectOption('Disabled','Disabled'));  
        options.add(new SelectOption('Unknown','Unknown'));                                                           
        return options;
    }         
}