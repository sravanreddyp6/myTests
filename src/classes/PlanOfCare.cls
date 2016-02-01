public with sharing class PlanOfCare {
    string glbListSeperator {get{return ';';} set;}
    transient public Id pbsId {get; set;}

    transient public Contact pbsObj {get; set;}
    transient public Assessment__c assessment {get; set;}
    transient public Action_Plan__c actionPlan {get; set;}
    transient public String[] Staffing_Supervision_Needs {get; set;}
    transient public map<String, Assessment_Response__c> responseMap {get; set;}
    
    public map<string, clsGoal> planStuff = new map<string, clsGoal> ();    
    public map<string, clsGoal> GETplanStuff(){return planStuff;}


    transient public boolean errorPresent {get; set;}
    
    public without sharing class NoSharingRecord {
        public NoSharingRecord(){}
	    public TMN_User__c getTmnAccess(){
	        return [SELECT Id, Name, Professional_Title__c FROM TMN_User__c WHERE Salesforce_User_Account__c =: UserInfo.getUserId() limit 1];
	    }
    }
    public String title {get {return (new NoSharingRecord()).getTmnAccess().Professional_Title__c ;} }
    
    public String getSfInstance(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    public planOfCare(){
    	this.errorPresent= false;
        this.pbsId = ApexPages.CurrentPage().getParameters().get('Id');
        
        try {
	        pbsObj = [Select Name, (select name from Service_Assignment__r where Status__c = 'Active' limit 1), FirstName, Middle_Name__c, LastName, Birthdate, Medicaid_ID__c from Contact where id =: this.pbsId];
	        
	        //get the latest risk assessment and the action plan in the Active Final status.... if not found then cannot procceed.
	        list<Assessment__c> assessments = [select   Id, Dsc_Prevocational_Services__c, Dsc_Day_Habilitation_Services__c, Dsc_Organizational_Employment_Services__c, Dsc_School_Transition_Services__c, 
	                                                    Individual_Rights_Review__c, Individual_Rights_Review_Explain__c, Dsc_Private_Pay_Services__c, Staffing_Supervision_Needs__c,
	                                                    Strengths__c, Needs__c
	                                            from Assessment__c where Admission__r.Person_Being_Served__c =: this.pbsId and Status__c = 'Active Final' order by CreatedDate desc limit 1];
	        list<Action_Plan__c> actionPlans = [select Id, Name, Service_Assignment__r.Name from Action_Plan__c where Service_Assignment__r.Status__c = 'Active' And Status__c = 'Active Final'
		                                        And Service_Assignment__r.Person_Being_Served__c =: this.pbsId order by CreatedDate desc limit 1];
	                                        
	        if (assessments.size() != 1) throw new CustomException('Cannot find Risk Assessment in the Active Final state. Please make sure the Risk Assessment is complete.');
	        else assessment = assessments[0];
	        if (actionPlans.size() != 1 ) throw new CustomException('Cannot find Action Plan in the Active Final state. Please make sure the Action Plan is complete.');
	        else actionPlan = actionPlans[0];
	        
	        
	        if(assessment.Staffing_Supervision_Needs__c != null ){
	            Staffing_Supervision_Needs = assessment.Staffing_Supervision_Needs__c.split(glbListSeperator);
	        }
	        
	        refreshPlan();
	        
	        responseMap = new map<String, Assessment_Response__c>(); 
	        for (Assessment_Response__c response : [Select id, Rating__c, Description_of_Risk__c, Plan_to_reduce_Risk__c, Comment__c, Assessment_Domain_Result__c, 
	                                                        Question__c, Question__r.External_Id__c, Question__r.Question_Domain__r.Name, Question__r.Question_Title__c 
	                                                  From Assessment_Response__c Where assessment__c =: assessment.id]){                
	                responseMap.put(response.Question__r.Question_Domain__r.Name + '~' + response.Question__r.Question_Title__c, response);
	        }
	        
	        // Naming the PDF in case this controller is used for the PDF page
	        String file = pbsObj.FirstName + ' ' + pbsObj.LastName + ' - Plan Of Care'  + '.pdf';
	        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
	        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
        } catch (Exception e) {
        	this.errorPresent= true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
    }
    
    
    public void refreshPlan(){
       list<Action_Plan_Goal__c> goals = [select id, name, description__c, CreatedDate,Sort_Order__c ,ReferenceID__c, Former_ID__c,
                    (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Action_plan_Goal__c, sort_order__c, ReferenceID__c, Former_ID__c, CreatedDate
                     from Action_Plan_Objectives__r Order By CreatedDate) 
                        from Action_Plan_Goal__c where action_plan__c = :ActionPlan.id Order By CreatedDate]; 
        list<Action_Plan_Objective__c> objectives = [select id, Action_plan_goal__c, name, ReferenceID__c, Description__c, CreatedDate, sort_order__c, Action_Plan_Goal__r.Sort_Order__c,
                    (select id, description__c, ReferenceID__c, name, CreatedDate, sort_order__c, status__c, Start_Date__c, End_date__c
                        from Action_Plan_Actions__r Order By sort_order__c) 
                            from Action_Plan_Objective__c where Action_Plan_Goal__r.Action_Plan__c = :ActionPlan.id];        
    
        for(Action_Plan_Goal__c g : goals){
            clsGoal clsG = new clsGoal(g);
            planStuff.put(g.sort_order__c + g.id, clsG);
            
                for(Action_Plan_Objective__c o: g.Action_Plan_Objectives__r){
                    clsObj clsO = new clsObj(o, false, g.id);
                    planStuff.get(g.sort_order__c + g.id).GoalObjs.put(o.sort_order__c + o.id, clsO );                
                }
        }
        
            for(Action_Plan_Objective__c o: objectives){
                for(Action_Plan_Action__c a: o.Action_plan_actions__r){
                    clsAction clsA = new clsAction(a,false,o.id);
                    planStuff.get(o.Action_Plan_Goal__r.Sort_Order__c + o.Action_Plan_Goal__c).GoalObjs.get(o.sort_order__c + o.id).ObjActs.put(a.Sort_Order__c+a.id, clsA);
                
                }
            }        
    } //end of refresh plan 
    
    
    public class clsGoal{
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public string GoalID {get; set;}
        public string tmpIdOfGoal {get; set;}
        public Action_Plan_Goal__c theGoal {get; set;}
        public Map<string, clsObj> GoalObjs = new Map<string, clsObj>();
         public Map<string, clsObj> getGoalObjs(){ return GoalObjs;}
        Blob b = Crypto.GenerateAESKey(128);
        public clsGoal(Action_Plan_Goal__c tmpGoal){
            commonlyConstructed(tmpGoal, '');
        }
       public void commonlyConstructed(Action_Plan_Goal__c tmpGoal, string key){
                isNew = false;
                deleteMe = false;
             Integer len = 5;
            Blob blobKey = crypto.generateAesKey(128);
            String Randomkey = EncodingUtil.convertToHex(blobKey);
            String RandomCharKey = Randomkey.substring(0,len);
                theGoal = tmpGoal;  
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');
                tmpIdOfGoal = 'zg' + shortnow + key + RandomCharKey ;
                //EncodingUtil.ConvertTohex(b);           
                if(theGoal.id == null){
                    isNew = true;
                    theGoal.Sort_Order__c = shortnow;
                    theGoal.Former_ID__c = tmpIdOfGoal;               
                }        
        }     
    }  
    
    
    public class clsObj{
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public boolean isParentNew{get; set;}
        public string GoalID {get; set;}                    
        public Action_Plan_Objective__c theObj {get; set;}
        public string QuestionID {get; set;}  
        public string tmpIdOfObj {get; set;}
        public map<string, clsAction> ObjActs = new Map<string, clsAction>();
        public map<string, clsAction> getObjActs(){return ObjActs ;}
        Blob b = Crypto.GenerateAESKey(128);
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID){
            commonlyConstructed(tmpObj, isGoalNew, parentID, '');
        }  
        public void commonlyConstructed(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID, string key){
                isNew = false;
                isParentNew = false;
                deleteMe = false;
                  Integer len = 5;
            Blob blobKey = crypto.generateAesKey(128);
            String Randomkey = EncodingUtil.convertToHex(blobKey);
            String RandomCharKey = Randomkey.substring(0,len);
                theObj = tmpObj;
                GoalID = parentID;
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');  
                tmpIdOfObj  =  'zo' + shortnow + key + RandomCharKey;
                //EncodingUtil.ConvertTohex(b); 
                if(isGoalNew){
                    isParentNew = true;
                    Action_Plan_Goal__c apg = new Action_Plan_Goal__c();
                    apg.Former_ID__c = GoalID;    
                    theObj.Action_Plan_Goal__r = apg;                    
                }
                if(theObj.id == null){
                    isNew = true; 
                    theObj.Sort_Order__c = shortnow;
                    theObj.Former_ID__c = tmpIdOfObj ;
                }
                if(theObj.id == null && !isGoalNew)
                    {theObj.Action_Plan_Goal__c = GoalID.right(18) ;}        
        }             
    }     
    
                  
     public class clsAction{
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public boolean isQuestionNew {get; set;}
        public string QuestionID {get; set;}
        public string ActionID {get; set;}
        public Action_Plan_Action__c theAction {get; set;}
        public string tmpIdOfAct {get; set;}
        public string objID {get; set;}  
        Blob b = Crypto.GenerateAESKey(128);   
        
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID){        
            commonlyConstructed(tmpAction, isObjNew, parentID, '');
        }
        public void commonlyConstructed(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID, string key){
                isNew = false;
                isQuestionNew = false;
                deleteMe = false;
                theAction = tmpAction;  
                objId = parentID; 
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');               
                tmpIdOfAct  =  'za' +  shortnow  + key;
                //EncodingUtil.ConvertTohex(b); 
                
                if(isObjNew){
                    Action_Plan_Objective__c apo = new Action_Plan_Objective__c();
                    apo.Former_Id__c = objId;
                    theAction.Action_Plan_Objective__r= apo;  
                }
                if(theAction.id == null){isNew = true; theAction.Sort_Order__c =  shortnow;  }
                if(theAction.id == null && !isObjNew){theAction.Action_Plan_Objective__c = objId.right(18);}        
        }      
    }
    
     class CustomException extends Exception {}  
}