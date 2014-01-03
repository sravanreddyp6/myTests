public with sharing class ActionPlan_form {
    public string inti {get;set;}
    public Acknowledgment__c theAck = new Acknowledgment__c ();
    public Acknowledgment__c GETtheAck(){ return theAck;}
    public boolean showAck {get; set;}
    public string WorksheetId{get;set;}
    public string worksheetWeek{get;set;}
    public boolean isRedwood {get; set;}
    public string tmp {get; set;} 
    public string parentID {get; set;}   
    public string goalID {get; set;}  
    public string objID {get; set;}  
    public string goalRef {get; set;}  
    public string objRef {get; set;}      
    public boolean isparentNew {get; set;}    
    public string deleteGid {get; set;}
    public string deleteOid {get; set;}
    public string deleteAid {get; set;}    
    public List<Action_Plan_Goal__c > goalsToDelete = new List<  Action_Plan_Goal__c >() ;
    public List<Action_Plan_Goal__c > GETgoalsToDelete(){return goalsToDelete ;}        
    public List<Action_Plan_Objective__c> objsToDelete = new List<Action_Plan_Objective__c>();
    public List<Action_Plan_Objective__c> GETobjsToDelete(){return objsToDelete ;}       
    public List<Action_Plan_Action__c> actsToDelete = new List<Action_Plan_Action__c>();   
    public List<Action_Plan_Action__c> GETactsToDelete(){return actsToDelete ;}          
    public Action_Plan__c ActionPlan = new Action_Plan__c();
    public boolean editMode {get; set;}
    public ID myid{get; set;}
    public List<Action_Plan_Goal__c > goals = new List<Action_Plan_Goal__c >();
    public List<Action_Plan_Goal__c > GETgoals(){ return goals;}    
    public List<Action_Plan_Objective__c> objectives = new List<Action_Plan_Objective__c>();
    public List<Action_Plan_Objective__c> GETobjectives(){return objectives;}    
    public map<string, clsGoal> planStuff = new map<string, clsGoal> ();
    public map<string, clsGoal> GETplanStuff(){return planStuff;}      
    public list<Progress_Note__c> getNotes(){
        return [select id, name, Start_Time__c, End_Time__c from Progress_Note__c where Action_plan__c = :actionplan.id];

    }      


    public boolean canEditPlan { get {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :ActionPlan.id];

        if (acls.size() > 0) {
            return acls[0].HasEditAccess;
        } else { return false;} 
        
    } set; }
    
       
public boolean getHasDraft(){
    boolean doesIt = false;
    
    for(Action_Plan__c a: [select id from action_plan__c where status__c = 'Inactive Draft' AND service_assignment__c = :actionplan.service_assignment__c]){
        doesit= true;
    
    }
    
    return doesit;

}    
 public Boolean canFinalize { get {
        // do not allow level 1 or 2 to finalize
        return (!isUserLevel1or2());
        }
        set;
    }
    
    // calculation of whether user is allowed to make this change
    private Boolean isUserLevel1or2() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];
         
        for ( PermissionSetAssignment p : userperms ) {

            //System.Debug( p.permissionset.name );
                        
            // user can only update if in one of these three permission sets
            if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
                System.Debug('User is level1 or level2.');
                return true;    
            }
        }
        return false;
    }
    

    public list<Acknowledgment__c > getAllAcks(){
    
        return [Select id, Name, Action_Plan__c, User__c, Initials__c, Date_Acknowledged__c from Acknowledgment__c where Action_plan__c = :ActionPlan.id];
    
    }
    
    public boolean getHasAcknowledged(){
            boolean tmp = false;
            //loop is only entered if the query returns a row
            for ( Acknowledgment__c a : [select name from Acknowledgment__c where user__c =:UserInfo.getUserId() AND Action_Plan__c =:ActionPlan.id limit 1]){
               tmp = true;
          
            }    
            return tmp;
    }
public pagereference createrShiftNote(){
    PageReference ref = new PageReference('/apex/shiftnote_basic_form?planId='+actionplan.id + '&admID=' + actionplan.Service_Assignment__r.Admission__c);
    return ref ;
}
public pagereference myCancel(){
    list<Action_plan__c> APs = [select id from action_plan__c where Service_assignment__c = :actionplan.service_assignment__c];
        
    if(APs.size() == 1){
    
        actionplan.Purge_Record__c = true;
      //  update actionplan;
        PageReference ref = new PageReference('/apex/ServiceAssignmentEditNew?Id='+ actionplan.Service_Assignment__c);
        return ref ;     
    
    }
    
    PageReference ref =  new ApexPages.StandardController(ActionPlan).view();
    return ref;
    
    
}
    public pagereference myFinal(){
        try{
        
            actionplan.Status__c = 'Active Final';
            actionplan.finalized_by__c = UserInfo.getUserId();
            actionplan.Finalized_Date__c = system.today();
            update actionplan;  
            Action_Plan__c oldPlan = new Action_Plan__c();
           // oldPlan = [select status__c, id from Action_plan__c where id =:actionplan.Previous_Action_plan__c limit 1];
           //the above line of code would throw and error if it didnt return any rows, so this for loop handles the 0 rows and would be if statment
            for ( Action_Plan__c a : [select status__c, id from Action_plan__c where id =:actionplan.Previous_Action_plan__c limit 1]){
               a.Status__c = 'Inactive Final';
               update a;            
            }
            
                
            list<task> newtasks= new list<task>();
            for(Acknowledgment__c  a : [Select user__c from Acknowledgment__c where Action_Plan__c = :actionplan.Previous_Action_plan__c  AND Action_Plan__c != :null]){
                task tmpTask = new task();
                
                tmpTask.whatid=actionplan.id;
                tmptask.OwnerId = a.user__c;
                tmpTask.Subject = 'Action Plan Acknowledgment';
                tmpTask.Description = 'Please acknowledge that you have read the new version of the Action Plan';
                tmpTask.whoID = ActionPlan.Service_Assignment__r.Admission__r.Person_Being_Served__c ;
                newtasks.add(tmpTask);
            }
            insert newtasks;
            
            PageReference ref =  new ApexPages.StandardController(ActionPlan).view();
            return ref;        
        
        }
        catch(DMLException e){actionplan.Status__c = 'Inactive Draft'; editMode= true;}
    return null;
    
    }
    
    public pagereference myacknowledge(){
   // editMode = true;
   try{
       theAck.Action_Plan__c = ActionPlan.id;
       theAck.User__c = UserInfo.getUserId();
       
       insert theAck;
            PageReference ref =  new ApexPages.StandardController(ActionPlan).view();
            return ref;    
   }
   
   catch(Exception e){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
   }
        
    
        return null;
    } 

    public pagereference editMode(){
        editMode = true;

        
    
        return null;
    } 

    public pagereference addAct(){
     
        Action_Plan_Action__c tmpAct = new Action_Plan_Action__c ();
        clsAction tmpClsAct = new clsAction(tmpAct, isparentNew, objID);
        planStuff.get(goalID).GoalObjs.get(objID).ObjActs.put(tmpClsAct.tmpIdOfAct, tmpClsAct); 
             
        return null;
    }

    public pagereference addObj(){
     
        Action_Plan_Objective__c tmpObj = new Action_Plan_Objective__c();
        clsObj tmpClsObj = new clsObj(tmpObj, isparentNew, goalID );
        planStuff.get(goalID ).GoalObjs.put(tmpClsObj.tmpIdOfObj, tmpClsObj); 

        Action_Plan_Action__c tmpAct = new Action_Plan_Action__c();
        clsAction tmpclsAct = new clsAction(tmpAct, True,tmpClsObj.tmpIdOfObj);
        planStuff.get(goalID).GoalObjs.get(tmpClsObj.tmpIdOfObj).ObjActs.put(tmpclsAct.tmpIdOfAct, tmpclsAct ); 
             
        return null;
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
        
public pagereference deleteGoal(){
    if(planStuff.get(deleteGid).theGoal.id !=null)
        {goalsToDelete.add(planStuff.get(deleteGid).theGoal);}
    planStuff.remove(deleteGid);
    return null;
}

public pagereference deleteObj(){
    if(planStuff.get(deleteGid).GoalObjs.get(deleteOid).theObj.id != null)
        {objsToDelete.add(planStuff.get(deleteGid).GoalObjs.get(deleteOid).theObj);}
    planStuff.get(deleteGid).GoalObjs.remove(deleteOid);
    return null;
}

public pagereference deleteAct(){
    if(planStuff.get(deleteGid).GoalObjs.get(deleteOid).ObjActs.get(deleteAid).theAction.id != null)
        {actsToDelete.add(planStuff.get(deleteGid).GoalObjs.get(deleteOid).ObjActs.get(deleteAid).theAction);}
    planStuff.get(deleteGid).GoalObjs.get(deleteOid).ObjActs.remove(deleteAid);
    return null;
}

public pagereference mySave(){
     //   map<string, clsGoal> beforeSavePlanStuff = new map<string, clsGoal> ();
     //   beforeSavePlanStuff= planstuff.Clone();
     //   for(clsGoal g: beforeSavePlanStuff.values()){
     //       system.debug('goal id b4 = '+g.theGoal.id);
      //  }
        
        
        Savepoint sp = Database.setSavepoint();
        List<Action_Plan_Goal__c > goalsToUpdate = new List<  Action_Plan_Goal__c >() ;
        List<Action_Plan_Objective__c> objToUpdate = new List<Action_Plan_Objective__c>();
        List<Action_Plan_Action__c> actToUpdate = new List<Action_Plan_Action__c>();
        
        List<Action_Plan_Goal__c > goalsToInsert = new List<  Action_Plan_Goal__c >() ;
        List<Action_Plan_Objective__c> objToInsert = new List<Action_Plan_Objective__c>();
        List<Action_Plan_Action__c> actToInsert = new List<Action_Plan_Action__c>();

                
    try{
        for(clsGoal g: planStuff.values()){    
            if(g.isNew && g.theGoal.id==null)
                {goalsToInsert.add(g.theGoal);}
            else
                {goalsToUpdate.add(g.theGoal);}
            
            for(clsObj o: g.GoalObjs.values()){
                if(o.isNew && o.theObj.id==null)
                    {objToInsert.add(o.theObj);}
                else
                    {objToUpdate.add(o.theObj);}           
            
                for(clsAction a: o.objActs.values()){
                    if(a.isNew && a.theAction.id==null)
                        {actToInsert.add(a.theAction);}
                    else
                        {actToUpdate.add(a.theAction);}
                }
            
            }
        
        
        }
        //this next section looks for objectives with blank status that have actions that have a description
        boolean addStatusError = false;
        boolean hadStatusErr = false;
        for(clsGoal g: planStuff.values()){              
            for(clsObj o: g.GoalObjs.values()){
                addStatusError =false;
                if(o.theObj.status__c == null){
                 
                    for(clsAction a: o.objActs.values()){
                        if(a.theAction.Description__c!=null)
                            {addStatusError =true;hadStatusErr = true;}
                    }
                    if(addStatusError ){
                        o.theObj.Status__c.addError('Status is required when an Action is provided');
                    }
                }
            
            }
        }
        if(hadStatusErr ){
            return null;
        }
                
        update actionPlan;
        
        //update([goalsToUpdate, objToUpdate, actToUpdate]);
        update goalsToUpdate;
        update objToUpdate;
        update actToUpdate; 
        
       //   insert ([goalsToInsert, objToInsert, actToInsert]);          
        insert goalsToInsert;
        insert objToInsert; 
        insert actToInsert;
        
        
        
        delete actsToDelete;
        delete objsToDelete;
        delete goalsToDelete;
        system.debug('tried to delete ' + goalsToDelete);
    
            PageReference ref =  new ApexPages.StandardController(ActionPlan).view();
            return ref;  
           }
           catch(DMLException e){
               ApexPages.addMessages(e); 
               Database.rollback(sp);//
               map<id,action_plan_goal__c> tmpgoals = new map<id, action_plan_goal__c>();
               for(action_plan_goal__c g: [select id from action_plan_goal__c where action_plan__c = :Actionplan.id]){
                   tmpgoals.put (g.id,g);
               }
               for(clsGoal g: planStuff.values()){    
                    if(g.theGoal.id!=null && !tmpgoals.containskey(g.theGoal.id))
                        {g.theGoal.id = null;}
                } 
              
           }      
       return null;    


}


        
    public ActionPlan_Form(ApexPages.StandardController controller) {
        ActionPlan = (Action_Plan__c)controller.getRecord();
        
        editMode = false;
        

        isRedwood = false;
        tmp = string.valueof(system.now()).remove(' ').remove(':').remove('-');
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
            if (TU.Operating_Group__c == 'Redwood'){isRedwood = true;} 
        }
        refreshPlan(); 
        
        if(goals.size() ==0){
            editMode = true;
            addGoal();
        
        }        
        showAck = true;
        // if this loop has any items it will set the show ack boolean to false. else it stays true
       
       
        for(Acknowledgment__c a: [Select id from Acknowledgment__c Where User__c = :UserInfo.getUserId() AND Action_Plan__c = :ActionPlan.id limit 1]){
            showAck = false;        
        }
        if(ActionPlan.Status__c != 'Active Final')
            {showAck = false;}  
             
                                  
    }

      

    
    
    public pagereference myClone(){
        List<string> okstatus = new list<string>();
        okstatus.add ('N/A');
        okstatus.add ('In Progress');
        okstatus.add ('Revised');
        okstatus.add ('New');
        
        
        List<Action_Plan_Goal__c> goals = [select id, name, description__c, Sort_Order__c,  
                    (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Sort_Order__c
                     from Action_Plan_Objectives__r Where Status__c in :okstatus Order By Sort_Order__c) 
                        from Action_Plan_Goal__c where action_plan__c = :ActionPlan.id Order By Sort_Order__c]; 
                        

        List<Action_Plan_Objective__c> objectives = [select id, 
                    (select id, description__c, Sort_Order__c 
                        from Action_Plan_Actions__r Order By CreatedDate) 
                            from Action_Plan_Objective__c where Action_Plan_Goal__r.Action_Plan__c = :ActionPlan.id AND Status__c in :okstatus];

        Action_Plan__c newAP = new Action_Plan__c();                        
        newAP = ActionPlan.clone();
        newAP.Status__c = 'Inactive Draft';
        newAP.Previous_Action_Plan__c = ActionPlan.id;
        newAP.Effective_Date__c = null;
        newAP.Target_Date__c = null;
        insert newAP;
        //ActionPlan.Status__c = 'Inactive Final';
        update ActionPlan;
        list<Action_Plan_Goal__c> copiedGoals = new List<Action_Plan_Goal__c>();
        list<Action_Plan_Objective__c> copiedObjs = new List<Action_Plan_Objective__c>();
        list<Action_Plan_Action__c> copiedActions = new List<Action_Plan_Action__c>();
        
        for (Action_Plan_Goal__c G: goals){
                Action_Plan_Goal__c tmpG = new Action_Plan_Goal__c();
                tmpG = G.clone();
                tmpG.Action_Plan__c = newAP.id;
                tmpG.Former_ID__c = g.id;
                tmpG.sort_order__c = g.sort_order__c;
                copiedGoals.add(tmpG);
                        for(Action_Plan_Objective__c o: G.Action_Plan_Objectives__r){
                                Action_Plan_Objective__c tmpO = new Action_Plan_Objective__c();
                                Action_Plan_Goal__c tmpGref = new Action_Plan_Goal__c();
                                //tmpO = o.clone(false, false);
                                tmpO.Former_ID__c = o.id;
                                tmpGref.Former_ID__c = g.id;
                                //tmpO.Action_Plan_Goal__c = null;
                                tmpO.Action_Plan_Goal__r = tmpGref;
                                tmpO.Description__c = o.Description__c;
                                tmpO.Effective_Date__c =  o.Effective_Date__c;
                                tmpO.target_end_date__c = o.target_end_date__c;
                                tmpO.status__c = o.status__c;
                                tmpO.type__c = o.type__c;
                                tmpO.sort_order__c = o.sort_order__c;
                                copiedObjs.add(tmpO);
                        }

        } 

        for (Action_Plan_Objective__c o : objectives){        
                for(Action_Plan_Action__c a: o.Action_Plan_Actions__r){
                                Action_Plan_Objective__c tmpOref = new Action_Plan_Objective__c();
                                Action_Plan_Action__c tmpA = new Action_Plan_Action__c();

                                tmpOref.Former_Id__c = o.id;
                                tmpA.Description__c = a.Description__c;
                                tmpA.sort_order__c = a.sort_order__c;
                                tmpA.Action_Plan_Objective__r = tmpOref;
                                        copiedActions.add(tmpA);
                }
        }         
        
        
        insert copiedGoals;     
        insert copiedObjs;
        insert copiedActions; 
        //insert ;
        PageReference ref =  new ApexPages.StandardController(newAP).view();
        return ref;   
        
    }     
    
    public PageReference GotoSkillWorksheet(){
        Action_Plan_Worksheet__c worksheet = [select Id from Action_Plan_Worksheet__c where name = :WorksheetId];
        PageReference next = new PageReference('/apex/WeeklySkillTracking?id=' + worksheet.Id);
        return next;
    }  
    
    public PageReference GotoBehaviorWorksheet(){
        Action_Plan_Worksheet__c worksheet = [select Id from Action_Plan_Worksheet__c where name = :WorksheetId];
        PageReference next = new PageReference('/apex/BehaviorTracking?id=' + worksheet.Id);
        return next;
    }  
  
    public boolean showWorkSheets { 
    get { 
        return (ActionPlan.Status__c == 'Active Final' || ActionPlan.Status__c == 'Inactive Final') &&
            isRedwood;
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
       
    public PageReference newWorksheet(){
        // any preconditions??
        Action_Plan_Worksheet__c newWorksheet = new Action_Plan_Worksheet__c();
        newWorksheet.Action_Plan__c = ActionPlan.Id;
        newWorksheet.Start_Date__c = Date.Parse(worksheetWeek);
        newWorksheet.RecordTypeid = [select id from recordtype where name = 'Weekly Skill Result' and SobjectType = 'Action_plan_worksheet__c' limit 1].id;
        insert newWorksheet;
        return new PageReference('/apex/WeeklySkillTracking?id=' + newworksheet.Id);
    } 

    public PageReference newBehaviorWorksheet(){
        // any preconditions??
        Action_Plan_Worksheet__c newWorksheet = new Action_Plan_Worksheet__c();
        newWorksheet.Action_Plan__c = ActionPlan.Id;
        newWorksheet.Start_Date__c = Date.Parse(worksheetWeek);
        newWorksheet.RecordTypeid = [select id from recordtype where name = 'Monthly Behavior Result' and SobjectType = 'Action_plan_worksheet__c' limit 1].id;
        insert newWorksheet;
        return new PageReference('/apex/BehaviorTracking?id=' + newworksheet.Id);
    } 
    public List<Action_Plan_Worksheet__c> getWeekResults(){
        return [select id, name, start_date__c from Action_Plan_Worksheet__c 
                    where Action_Plan__c = :ActionPlan.Id
                      and RecordType.name = 'Weekly Skill Result' 
                    order by start_date__c];     
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
                    order by start_date__c];     
    }
    
    public void refreshPlan(){
       goals = [select id, name, description__c, CreatedDate,Sort_Order__c ,
                    (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Action_plan_Goal__c, sort_order__c, CreatedDate
                     from Action_Plan_Objectives__r Order By CreatedDate) 
                        from Action_Plan_Goal__c where action_plan__c = :ActionPlan.id Order By CreatedDate]; 
        objectives = [select id, Action_plan_goal__c, name, Description__c, CreatedDate, sort_order__c, Action_Plan_Goal__r.Sort_Order__c,
                    (select id, description__c, name, CreatedDate, sort_order__c
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
                
        public clsGoal(Action_Plan_Goal__c tmpGoal){
                isNew = false;
                deleteMe = false;
                theGoal = tmpGoal;  
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');
                tmpIdOfGoal = 'zg' + shortnow;           
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
              
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID){
                isNew = false;
                isParentNew = false;
                deleteMe = false;
                theObj = tmpObj;
                GoalID = parentID;
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');  
                tmpIdOfObj  =  'zo' + shortnow ; 
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
        
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID){
                isNew = false;
                isQuestionNew = false;
                deleteMe = false;
                theAction = tmpAction;  
                objId = parentID; 
                string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');               
                tmpIdOfAct  =  'za' + shortnow; 
                
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