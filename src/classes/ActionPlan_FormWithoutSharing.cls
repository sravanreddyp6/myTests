public without sharing class ActionPlan_FormWithoutSharing {
    public string GoalAlias { get; set;}
    public string ObjAlias { get; set;}
    public string ActAlias { get; set;}
    public boolean isRedwood {get; set;}
    public string tmp {get; set;} 
    public Action_Plan__c ActionPlan = new Action_Plan__c();
    public List<Action_Plan_Goal__c > goals = new List<Action_Plan_Goal__c >();
    public List<Action_Plan_Goal__c > GETgoals(){ return goals;}    
    public List<Action_Plan_Objective__c> objectives = new List<Action_Plan_Objective__c>();
    public List<Action_Plan_Objective__c> GETobjectives(){return objectives;}    
    public map<string, clsGoal> planStuff = new map<string, clsGoal> ();
    public map<string, clsGoal> GETplanStuff(){return planStuff;}      
    public string userOpGrp {get; private set;}

    public string getAP_Child_Record(string refID){
        string myObj = '';
        
        for(clsGoal g: planStuff.values()){    
            if(g.theGoal.ReferenceID__c==refID)
                {myObj = g.getRefID();}            
            for(clsObj o: g.GoalObjs.values()){
                if(o.theObj.ReferenceID__c==refID)
                    {myObj = o.getRefID();}   
                for(clsAction a: o.objActs.values()){
                    if(a.theAction.ReferenceID__c==refID)
                        {myObj = a.getRefID();}
                }            
            }        
        }
        return myObj;
    }

    public ActionPlan_FormWithoutSharing(string GoalAlias, string ObjAlias, string ActAlias, boolean isRedwood, string tmp, Action_Plan__c ActionPlan, List<Action_Plan_Goal__c > goals,
                                         List<Action_Plan_Objective__c> objectives, map<string, clsGoal> planStuff, string userOpGrp) {
		        this.userOpGrp=userOpGrp;
				this.tmp=tmp;
				this.planStuff=planStuff;
				this.objectives=objectives;
				this.ObjAlias=ObjAlias;
				this.isRedwood=isRedwood;
				this.goals=goals;
				this.GoalAlias=GoalAlias;
				this.ActionPlan=ActionPlan;
				this.ActAlias=ActAlias;    	
    }

    public ActionPlan_FormWithoutSharing(Id actionPlanId) {
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Action_Plan__c').getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
        if (!selectFields.isEmpty()) {
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        String strSQL =  'SELECT ' + selects + ' FROM Action_Plan__c WHERE Id = \'' + actionPlanId + '\'';
        strSQL = strSQL.Replace('SELECT ', 'SELECT Service_Assignment__r.Admission__r.Name,Service_Assignment__r.Name, Service_Assignment__r.Service_Location__r.Service_Value__c, Service_Assignment__r.Service_location__r.ProgramID__c, Service_Assignment__r.Flavor__c, ');
        
        ActionPlan = ((List<Action_Plan__c>)Database.query(strSQL))[0];
        isRedwood = false;
        tmp = string.valueof(system.now()).remove(' ').remove(':').remove('-');
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
            if (TU.Operating_Group__c == 'Redwood' && ActionPlan.Service_Assignment__r.Flavor__c != 'CA FSS' ){isRedwood = true;}
            userOpGrp = TU.Operating_Group__c;
        }
        refreshPlan(); 
        aliasChildrenTitles();
        if(goals.size() ==0){
            addGoal();
        }        
        string curSV = ActionPlan.Service_Assignment__r.Service_Location__r.Service_Value__c;
        List<Clinical_Programs__c> allPrgms = Clinical_Programs__c.getall().values();
        map< Decimal, string > mapAllPrgs = new map< Decimal, string >();
        for(Clinical_Programs__c item: allPrgms){
            if(curSV == item.Program_Name__c){
                mapAllPrgs.put(item.ProgramID__c, item.Program_Name__c );
            }
        }        
    }
    public pagereference addGoal(){  
    //create the goal and put it in the master
        Action_Plan_Goal__c tmpGoal = new Action_Plan_Goal__c(); 
        tmpGoal.Action_Plan__c = ActionPlan.id;
        clsGoal tmpClsGoal = new clsGoal( tmpGoal);
        planStuff.put(tmpClsGoal.tmpIdOfGoal , tmpClsGoal);  
    // create the obj and put it in the master
        Action_Plan_Objective__c tmpObj = new Action_Plan_Objective__c();
        clsObj tmpClsObj = new clsObj(tmpObj, True, tmpClsGoal.tmpIdOfGoal);
        planStuff.get(tmpClsGoal.tmpIdOfGoal).GoalObjs.put(tmpClsObj.tmpIdOfObj, tmpClsObj);
    //create the action and put it in the master
        Action_Plan_Action__c tmpAct = new Action_plan_Action__c();
        clsAction tmpClsAct = new clsAction(tmpAct, true,tmpClsObj.tmpIdOfObj);    
        planStuff.get(tmpClsGoal.tmpIdOfGoal).GoalObjs.get(tmpClsObj.tmpIdOfObj).ObjActs.put(tmpClsAct.tmpIdOfAct, tmpClsAct);
        return null;
    }    
    public void aliasChildrenTitles(){
        GoalAlias = 'Goal';
        ObjAlias = 'Objective';
        ActAlias = 'Action';
        SystemSettings__c mc = SystemSettings__c.getInstance(UserInfo.getUserId());
        boolean showThis = (mc.ActnPln_CtlgEnabledFor_CM__c && userOpGrp == 'Care Meridian')
                            || (mc.ActnPln_CtlgEnabledFor_Cambridge__c && userOpGrp == 'Cambridge')
                            || (mc.ActnPln_CtlgEnabledFor_NR__c && userOpGrp == 'NeuroRestorative')
                            || (mc.ActnPln_CtlgEnabledFor_Redwood__c && userOpGrp == 'Redwood')
                            || (mc.ActnPln_CtlgEnabledFor_CAFSS__c && Actionplan.Service_Assignment__r.Flavor__c == 'CA FSS');
        system.debug('catalog enabled - ' + showThis);
        system.debug( 'Program is: ' + ActionPlan.Service_Assignment__r.Service_Location__r.ProgramID__c );
        if(showThis){
            if(ActionPlan.Service_Assignment__r.Service_Location__r.Service_Value__c != null && ActionPlan.Service_Assignment__r.Service_Location__r.Service_Value__c =='ABI' && ActionPlan.Service_Assignment__r.Service_Location__r.ProgramID__c != '114165002'){        
                GoalAlias = 'Problem';
                ObjAlias = 'Goal';
                ActAlias = 'Intervention';
            }    
        }
    }
    public class myDate{
        private Date internaldate;
        
        public myDate(Date initdate){
            internaldate = initdate;
        }
        
        public string UserDate{
            get { return internaldate.format();}
        }
        public string ParsableDate{
            get { return internaldate.month() + '/' + internaldate.day() + '/' + internaldate.year();}
        }
    }
       
    public List<Action_Plan_Worksheet__c> getWeekResults(){
        return [select id, name, start_date__c from Action_Plan_Worksheet__c 
                    where Action_Plan__c = :ActionPlan.Id
                      and RecordType.name = 'Weekly Skill Result' 
                    order by start_date__c DESC];     
    }    
    public List<myDate> getuncheckedWeeks(){
        Date firstMonday = (ActionPlan.Effective_Date__c - 1).toStartOfWeek() +1;
        Date lastMonday = (ActionPlan.Target_Date__c != null ? ActionPlan.Target_Date__c : Date.Today() - 1).toStartOfWeek() +1;
        List<myDate> dates = new List<myDate>();
        Set<Date> existing = new Set<Date>();
        for(Action_Plan_Worksheet__c iter: getWeekResults()){
            existing.Add(iter.Start_Date__c);
        }
        for(Date monday=firstMonday;monday <= lastMonday; monday = monday + 7){
            if (!existing.Contains(monday)){
                dates.Add(new myDate(monday));
            }
        }
        return dates;
    }    

    public List<myDate> getBehaviorMonthsAvailable(){
        Date first1day = ActionPlan.Effective_Date__c.toStartOfMonth();
        Date lastday = ActionPlan.Target_Date__c != null ? ActionPlan.Target_Date__c : Date.Today() ;
        List<myDate> dates = new List<myDate>();
        Set<Date> existing = new Set<Date>();
        for(Action_Plan_Worksheet__c iter: getBehaviorWorkSheets()){
            existing.Add(iter.Start_Date__c);
        }
        for(Date monday=first1day;monday <= lastday; monday = monday.addmonths(1)){
            if (!existing.Contains(monday)){
                dates.Add(new myDate(monday));
            }
        }
        return dates;
    }
    
    public List<Action_Plan_Worksheet__c> getBehaviorWorkSheets(){
        return [select id, name, start_date__c from Action_Plan_Worksheet__c 
                    where Action_Plan__c = :ActionPlan.Id
                      and RecordType.name = 'Monthly Behavior Result' 
                    order by start_date__c DESC];     
    }
    
    public void refreshPlan(){
       goals = [select id, name, description__c, CreatedDate,Sort_Order__c ,ReferenceID__c, Former_ID__c,
                    (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Action_plan_Goal__c, sort_order__c, ReferenceID__c, Former_ID__c, CreatedDate
                     from Action_Plan_Objectives__r Order By CreatedDate) 
                        from Action_Plan_Goal__c where action_plan__c = :ActionPlan.id Order By CreatedDate]; 
        objectives = [select id, Action_plan_goal__c, name, ReferenceID__c, Description__c, CreatedDate, sort_order__c, Action_Plan_Goal__r.Sort_Order__c,
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
        public string getRefID(){
            if(isNew){
                return tmpIdOfGoal;
            }
            /*
            if(theGoal.Former_ID__c != null){
                return theGoal.Former_ID__c;
            }
            */
            return theGoal.Sort_Order__c + theGoal.ID;
        }                   
        public clsGoal(Action_Plan_Goal__c tmpGoal){
            commonlyConstructed(tmpGoal, '');
        }
        public clsGoal(Action_Plan_Goal__c tmpGoal, string key){
            commonlyConstructed(tmpGoal, '_' + key);
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
        public string getRefID(){
            if(isNew){
                return tmpIdOfObj;
            }
        
            return theObj.Sort_Order__c + theObj.ID;
        }                 
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID){
            commonlyConstructed(tmpObj, isGoalNew, parentID, '');
        }  
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID, string key){
            commonlyConstructed(tmpObj, isGoalNew, parentID, '_'+ key);
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
        
        public string getRefID(){
            if(isNew){
                return tmpIdOfAct;
            }
        
            return theAction.Sort_Order__c + theAction.ID;
        }   
        
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID){        
            commonlyConstructed(tmpAction, isObjNew, parentID, '');
        }
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID, string key){
            commonlyConstructed(tmpAction, isObjNew, parentID, '_'+ key);
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
}