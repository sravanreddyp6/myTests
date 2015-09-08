public with sharing class Notes_ProgressNote_AZ_OPT {
    
    public Service_Assignment__c theServAssign { get; set; }
    public Id theServAssignId { get; set; }
    public boolean inlinemode{get; set;} 
    public Id ActivePlanId{get;set;}
    public Id admissionId { get; set; }
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    public Boolean NewBlock{get;set;}
    public boolean displayPopupComp {get; set;}     
    public string ContactName{get;set;}
    public string SignedDoc {get;set;}
    public string SrvcLoc {get;set;}
    public string goalsOrObSelected { get;set; }
    public list<string> GoalSelStrs {get;set;}
    public list<string> AZOPTstring {get;set;}
    public list<string> GoalSelAzOptCombo {get;set;}
    public list<string> GoalSelStrsremvd {get;set;}
    public list<string> GoaldeSelStrs {get;set;}
    public string GoalsSelected{get;set;}
    public string GoalsdeSelected{get;set;}
    public string finalGoalsObjList{get;set;}  
    public list<action_plan_objective__c> allObjectives  = new list<action_plan_objective__c>();
    public list<action_plan_objective__c> getallObjectives (){return allObjectives ;}
    public list<Action_Plan_Goal__c> allgoals1 = new list<Action_plan_Goal__c>();
    Map<id,Action_Plan_Goal__c> GoalMap = New Map<Id,Action_Plan_Goal__c>();
    Map<id,list<Action_plan_objective__c>> GoalObjMap = New Map<id,list<Action_plan_objective__c>>();
    public list<Action_Plan_Goal__c> getallgoals1(){return allGoals1;}
    public map<string, list<action_plan_action__c>> mapActions = new map<string, list<action_plan_action__c>>();
    public map<string, list<action_plan_action__c>> getMapActions(){ return mapActions ;}
    public list<Action_Plan_Goal__c> nodes2 {get;set;}
    public TMN_Tree allGoals {get; set;}
    public string selectedKeys{get; set;}
    public string RTid;
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public Id AZ_OPT_ID, SHIFT_NOTE_ID;
    public string pbsName { get; set; }
    public Boolean AsmntOnly{get;set;}
    private string usrOpGrp;
    public Id insertedProgressNoteId{get;set;}
    public list<SelectOption> rtOptions = new list<SelectOption>();
    public list<SelectOption> getrtOptions(){return rtOptions ;}
    public RecordType defaultRt { get; set; }
    private Final Progress_Note__c pn;
    public boolean displayPopup {get; set;} 
    public boolean displayPopupFinalize{get; set;}        
    public Progress_Note__c thePN = new Progress_Note__c(Start_Time__c=Datetime.now(),End_Time__c=Datetime.now());
    public Progress_Note__c getthePN(){return thePN;}
    public List<Progress_Note__c> pnOverlap {get; set;} 
    public List<Progress_Note__c> overlappingProgressNote {get; set;} 
    public boolean hasOverlap {get { return (pnOverlap.size() > 0 && thePN.recordtype.developername == 'AZ_OPT');} }
    public void update_overlap(){
        LoadData(thePN);    
    }
    
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c,Person_Being_Served__r.Name,Approval_User__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername from Progress_Note__c where id= :tmp.id limit 1];
         
        List<Progress_Note__c> samepbsNotes = [select id, Name, Person_being_served__r.Name, start_time__c, end_time__c,Approval_User__c, status__c, Owner.Name from Progress_Note__c 
              where id != :thePN.id 
              and Person_Being_Served__c = :thePN.Person_Being_Served__c
              and disregard_note__c = false
              and Admission__c = :thePN.Admission__c
              and  Service_Assignment__c = :thePN.Service_Assignment__c
              and Plan__c = :thePN.Plan__c
              and (
                  (start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
                or   (end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
                or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
                )
                ];   
        List<Progress_Note__c> diffpbsNotes = [SELECT Id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c,Approval_User__c, Owner.Name from Progress_Note__c 
              where id != :thePN.id 
              and disregard_note__c = false
              and Person_Being_Served__c != :thePN.Person_Being_Served__c
              and Owner.Name = :thePN.Owner.Name
              and (
                  (start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
                or   (end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
                or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
                ) 
                ]; 
                
        if(samepbsNotes!=null && samepbsNotes.size()>0)
            pnOverlap.addall(samepbsNotes);
        if(diffpbsNotes!=null && diffpbsNotes.size()>0)
            pnOverlap.addall(diffpbsNotes);
        if(pnOverlap!=null && pnOverlap.size()>0){
            displayPopupFinalize = true;
        }
    }
    
    /**Method to check for Progress Notes with same Start And End time for same owner / Person Being Served**/
    public list<Progress_Note__c> lookForOverLappingNotes(Id insertedprogressnoteId){
        overlappingProgressNote = new list<progress_note__c>();
        List<Progress_Note__c> samepbsNotes = [select id, Name, Person_being_served__r.Name,Approval_User__c, Action_Plan__c,start_time__c, end_time__c,ownerId, status__c, Owner.Name from Progress_Note__c 
              where id != :insertedprogressnoteId
              and disregard_note__c = false
              and Person_Being_Served__c = :pn.Person_Being_Served__c
              and Admission__c = :pn.Admission__c
              and  Service_Assignment__c = :pn.Service_Assignment__c
              and Action_Plan__c = :pn.Action_Plan__c
              and OwnerId =: UserInfo.getUserId()
              and (
                  (start_time__c >= :pn.start_Time__c and start_time__c <= :pn.end_time__c)
                or   (end_time__c >= :pn.start_time__c and end_time__c <= :pn.end_time__c)
                or  ( start_time__c <= :pn.start_time__c and end_time__c >= :pn.end_time__c )
                )
                ];   
       
        List<Progress_Note__c> diffpbsNotes = [SELECT Id, Name, Person_being_served__r.Name, start_time__c,Approval_User__c, end_time__c, status__c, Ownerid from Progress_Note__c 
              where Person_Being_Served__c != :pn.Person_Being_Served__c
              and disregard_note__c = false
              and OwnerId =: UserInfo.getUserId()
              and (
                  (start_time__c >= :pn.start_Time__c and start_time__c <= :pn.end_time__c)
                or   (end_time__c >= :pn.start_time__c and end_time__c <= :pn.end_time__c)
                or  ( start_time__c <= :pn.start_time__c and end_time__c >= :pn.end_time__c )
                ) 
                ]; 
                
                
                if(samepbsNotes!=null && samepbsNotes.size()>0)
            overlappingProgressNote.addall(samepbsNotes);
        if(diffpbsNotes!=null && diffpbsNotes.size()>0)
            overlappingProgressNote.addall(diffpbsNotes);
        
                
        return overlappingProgressNote;         
    }
    
    /**Called when Submit for Approval Button Is Clicked, Added In code as the Standard Approval 
    process Was adding an additional page , where user used to select the next Approver**/
    public pagereference SubmitForApp(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(thePn.id);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Progress_Notes_Approval');
        req1.setSkipEntryCriteria(true);
        list<id> listids = new list<id>();
        listids.add(thePN.Approval_User__c);
        req1.setNextApproverIds(listids);
        Approval.ProcessResult result = Approval.process(req1);
        pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_Create_Flavor_PDF?id='+thePn.id+'&IsSubmitted=Yes');
        pageref.setredirect(true);
        return pageref;
    }
    
    /** Disregard Code for added custom button**/
    public PageReference disregardNote(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_AddlActions');
        pageRef.getParameters().put('id', thePN.id);
        return pageRef;
    }
    
    public void closePopupComp() {        
        displayPopupComp = false;    
    } 
    public void showPopupComp() {        
        displayPopupComp = true;    
    }
    public void closePopup() {        
        displayPopup = false;    
    }   
    
    /** Validations which are required to be checked Before Finalizing or Esigning the progress Note**/
    public void validateFinalizeEsign(list<progress_note__c> pnValidations,string GoalsSelected){
        if(GoalsSelected=='NoGoal'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Goal before continuing.'));   
        }
        if(pnValidations[0].status__c == 'Final'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note has already been finalized.'));  
        }
        if(pnValidations[0].Approval_Status__c == 'Pending'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note is pending approval.')); 
        }
        if(pnValidations[0].Action_plan__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an Action Plan before continuing.'));    
        }
        if(pnValidations[0].Service_Location__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Location before continuing.'));   
        }
        if(pnValidations[0].Type_of_Contact__c == Null ||pnValidations[0].Type_of_Contact__c == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select the Type of Contact before continuing.'));  
        }
        if(pnValidations[0].Service_code__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Code before continuing.'));  
        }
        if(pnValidations[0].Interventions__c== Null|| pnValidations[0].Interventions__c== ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Intervention field before continuing.'));    
        }
        if(pnValidations[0].Notes_For_Next_Visit__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Notes For Next Visit field before continuing.'));  
        }
        if(pnValidations[0].progress__c == Null|| pnValidations[0].progress__c == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Progress field before continuing.'));  
        }
            
    }    
    
    /**Esign Validation **/ 
    public pagereference validateesign(){
        list<progress_note__c> pnValidations = [SELECT Id, service_location__C,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c, end_time__c, status__c, recordtype.Name,Service_code__c,People_Present__c,Approval_User__c, 
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Action_plan__c,Number_of_Required_Signatures__c ,GoalIds_AZOPTPage__c,Signature_on_File__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        boolean HasGoal = false;
        //GoalsSelected = pnValidations[0].GoalIds_AZOPTPage__c;
        String GoalsOrObj;
        list<ProgressNote_ActionPlanChildren_mjo__c> lstJncObj = New List<ProgressNote_ActionPlanChildren_mjo__c>();
        lstJncObj = [select goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where progress_note__c =: thePn.Id];
        if(lstjncObj == Null || lstjncObj.size()==0){
            GoalsOrObj ='NoGoal';
        }
        System.debug('Goals Selecetd --> ' + GoalsOrObj); 
        if((GoalsOrObj =='NoGoal') || pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' || pnValidations[0].Action_plan__c == Null ||(pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0)||pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || pnValidations[0].Service_code__c == Null ||pnValidations[0].Interventions__c== Null || pnValidations[0].Notes_For_Next_Visit__c == Null  || pnValidations[0].progress__c == Null || pnValidations[0].Type_of_Contact__c == '' || pnValidations[0].progress__c == '' || pnValidations[0].Interventions__c== '') {
            validateFinalizeEsign(pnValidations,GoalsOrObj);
       }return null;
    }
     
    /** Finalize Validations And then rendering of the finalize popup on the screen Logic**/ 
    public pagereference showPopup() { 
        list<progress_note__c> pnValidations = [SELECT Id, service_location__C,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c, end_time__c, status__c, recordtype.Name,Service_code__c,People_Present__c,Approval_User__c, 
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Action_plan__c,Number_of_Required_Signatures__c ,GoalIds_AZOPTPage__c,Signature_on_File__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        boolean HasGoal = false;
        String GoalsOrObj;
        list<ProgressNote_ActionPlanChildren_mjo__c> lstJncObj = New List<ProgressNote_ActionPlanChildren_mjo__c>();
        lstJncObj = [select goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where progress_note__c =: thePn.Id];
        if(lstjncObj == Null || lstjncObj.size()==0){
            GoalsOrObj ='NoGoal';
        }
        System.debug('Goals Selecetd --> ' + GoalsOrObj); 
        if( GoalsOrObj =='NoGoal' || pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' || pnValidations[0].Action_plan__c == Null ||(pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0)||pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || pnValidations[0].Service_code__c == Null ||pnValidations[0].Interventions__c== Null || pnValidations[0].Notes_For_Next_Visit__c == Null  || pnValidations[0].progress__c == Null || pnValidations[0].Type_of_Contact__c == '' || pnValidations[0].progress__c == '' || pnValidations[0].Interventions__c== '') {
            validateFinalizeEsign(pnValidations,GoalsOrObj);
            if(pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0 ){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Progress Note cannot be finalized without an Electronic Signature attached to the Progress Note. Please esign the document prior to finalization.'));  
            }
            return null;
        }
        else{
            displayPopup = true; 
            LoadData(thePN);
            return null;
        } 
    }
    
    public Notes_ProgressNote_AZ_OPT(ApexPages.StandardController controller){
        GoalsSelected='';overlappingProgressNote = new list<progress_note__c>();GoalsDeSelected='';finalGoalsObjList='';
        GoalSelStrs = New List<string>();
        AZOPTstring = New List<string>();
        goalsOrObSelected ='';
        GoalSelAzOptCombo = New List<string>();
        GoalSelStrsremvd = New List<string>();
        string dispMode = ApexPages.currentPage().getParameters().get('Mode');
        if(dispMode!='Edit'){
            ActivePlanId = ApexPages.currentPage().getParameters().get('plan');
        }else if (dispMode =='Edit'){
            displayPopupFinalize = false;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
            GoalsSelected = Apexpages.currentPage().getParameters().get('selectedKey');
            GoalsDeSelected = Apexpages.currentPage().getParameters().get('DeselectedKey');
            
            
            List<String> OldIds = New List<String>();
            list<ProgressNote_ActionPlanChildren_mjo__c> lstJncObj = New List<ProgressNote_ActionPlanChildren_mjo__c>();
            lstJncObj = [select goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where progress_note__c =: insertedprogressnoteid];
            list<string> existingId = new list <string>();
            if(lstjncobj!= Null && lstjncobj.size()>0){
                for(ProgressNote_ActionPlanChildren_mjo__c jnc:lstjncobj){
                    if(jnc.goal__C != Null ){
                        OldIds.add(jnc.goal__C);
                        existingId.add(jnc.goal__C);
                    }else if(jnc.objective__c != Null ){
                        OldIds.add(jnc.objective__c);
                        existingId.add(jnc.objective__c);
                    }
                }
            }else{
                goalsOrObSelected='NoGoal';
            }  
            list<string> finallisttocreate = new list<string>();
            pn = (Progress_Note__c) controller.getRecord();
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Signature_on_File__c ,Service_Location__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            list<Id> GoalSelIds = New List<Id>();
            if(GoalsSelected == null || GoalsSelected == '' ){
                if(OldIds!=null && OldIds.size()>0)
                    GoalSelStrs.addall(OldIds);
            }
            else{ 
                GoalSelStrs = (GoalsSelected.split(','));
                if(OldIds!=null && OldIds.size()>0)
                    GoalSelStrs.addall(OldIds);
            }   
            SignedDoc = pnedit.Signature_on_File__c;
            SrvcLoc = pnedit.Service_Location__c;
            pnOverlap = new List<Progress_Note__c>();
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
            ActivePlanId = pnedit.Action_Plan__c;
            loaddata(pnedit);
            
            if(GoalsDeSelected!=null && GoalsDeSelected !=''){
                GoalDeSelStrs = (GoalsDeSelected.split(','));
            }System.debug('******************GoalDeSelStrs'+GoalDeSelStrs);
            list<string> RemovedGoalIDs = New List<string>();
            if(GoalsDeSelected!=null && GoalsDeSelected !=''){
                for(string s:GoalDeSelStrs){
                    if(s.contains('a1A')){
                        RemovedGoalIDs.add(s);
                    }
                }System.debug('******************RemovedGoalIDs'+RemovedGoalIDs);
                if(RemovedGoalIDs.size()>0){
                    list<action_plan_objective__c> ObjListToBedel = [select id from action_plan_objective__c where action_plan_goal__r.Id In :RemovedGoalIDs] ; 
                    System.debug('******************ObjListToBedel'+ObjListToBedel);
                    for(action_plan_objective__c obj:ObjListToBedel){
                        GoalDeSelStrs.add(obj.id);
                    }
                }
            }
            if(GoalSelStrs!=null && GoalSelStrs.size()>0){
                if(GoalDeSelStrs!=Null){
                    for(string s:GoalSelStrs){
                        boolean deletethis = false;
                        for(string str:GoalDeSelStrs){
                            if(s==str){
                              deletethis = true; //GoalSelStrs.remove(s);
                            }
                        }
                        if(deletethis == false)
                            GoalSelStrsremvd.add(s);
                    }
                }else{
                    GoalSelStrsremvd.addall(GoalSelStrs);
                }System.debug('********GoalSelStrsremvd**********'+GoalSelStrsremvd);
            }
            reformedittree(GoalSelStrsremvd);
        }//End Edit Mode Block
        if(ActivePlanId != Null && dispMode!='Edit'){
            allgoals1 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Action_Plan__c = :ActivePlanId Order BY Sort_Order__c];  
            allObjectives = [select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId] ;                               
            Map<id,Action_Plan_Goal__c> idGoalMap = New Map<id,Action_Plan_Goal__c>();    
            for(Action_Plan_Goal__c g:allGoals1){
                idGoalMap.put(g.id,g);
                list<Action_plan_objective__c> objectiveList = New List<Action_plan_objective__c>();
                if(g.action_plan_objectives__r!=Null ){
                    System.debug('------------here ====');
                    for(Action_plan_objective__c o: g.action_plan_objectives__r){
                        list<action_plan_action__c> tmpLst = new list<action_plan_action__c>();
                        mapActions.put(o.id, tmpLst);
                        objectiveList.add(o);                
                    }
                    GoalObjMap.put(g.Id,objectiveList);
                }
            }
            for(action_plan_objective__c o:[select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId]){
                if(o.Action_Plan_Actions__r!= null)
                    mapActions.put(o.id, o.Action_Plan_Actions__r);
            }
            retrieveAllGoals();
        }else{}
        inlinemode = false;
        if(dispMode == 'New'){
            NewBlock = true;
            AsmntOnly = false;
            myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c' ORDER BY Name];
            for (RecordType rt: myRTs) {
                if (rt.Name == 'AZ - OPT') {
                    AZ_OPT_ID = rt.Id;
                } 
                if (rt.Name == 'Shift Note') {
                    SHIFT_NOTE_ID = rt.Id;
                }
            }
            System.Debug('shift note id=' + SHIFT_NOTE_ID);
            string pbsId = ApexPages.currentPage().getParameters().get('person');
            if (!string.isBlank(pbsId)) {
                pbsname = [SELECT Name FROM Contact WHERE Id=:pbsId].Name;
            }
            if (!Test.isRunningTest()) {
                controller.addFields(new string[] {'RecordType.Name'});
            }
            pn = (Progress_Note__c) controller.getRecord();
            ID saID = ApexPages.currentPage().getParameters().get('ServAssignId');
            Service_Assignment__c sa = [select id, name, service_location__r.programid__c,recordtype.name from service_assignment__c where id = :saID LIMIT 1];
            User currUser = [ select id, Operating_Group__c from User where id = :UserInfo.getUserId()];
            usrOpGrp = currUser.Operating_Group__c;
            // If Progress Note is AZ-OPT, we have to default some fields here, but only for non-CM AZ
            if (myState == 'AZ') {
                if (sa.service_location__r.programid__c != '114165002') {
                    pn.Number_of_Required_Signatures__c = 1;
                    pn.RecordTypeId = AZ_OPT_ID;
                } else {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                }
            }
            if(sa.recordtype.name == 'Assessment Only' && currUser != null && currUser.Operating_Group__c == 'NeuroRestorative'){
                AsmntOnly = true;
            }   
            if (currUser != null ) {
                if (( myState == 'MN' || myState == 'IN' || myState == 'CA') && currUser.Operating_Group__c == 'Redwood') {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                }
            }else {/*add error to page that shift note cannot be created  */}
            pn.Start_Time__c = datetime.now();
            pn.End_Time__c = datetime.now();
            //loadData();
            if( ApexPages.currentPage() != null){
                theServAssign = [ SELECT Id, Name, Person_Being_Served__c,Person_Being_Served__r.name,Admission__c,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :ApexPages.currentPage().getParameters().get('ServAssignId') ];
                theServAssignId = theServAssign.Id;
                pbsName = theServAssign.Person_Being_Served__c;
                admissionId = theServAssign.Admission__c;
                ContactName = theServAssign.Person_Being_Served__r.name;
                ActivePlanId = ApexPages.currentPage().getParameters().get('plan')==(null)?null:ApexPages.currentPage().getParameters().get('plan');
            }
        }
        else if (dispMode == 'Inlineedit'){
            NewBlock = true;
            inlinemode = true;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
            pn = (Progress_Note__c) controller.getRecord();
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            pnOverlap = new List<Progress_Note__c>();
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
            ActivePlanId = pnedit.Action_Plan__c;
            ContactName = pnedit.Service_Assignment__r.Person_Being_Served__r.Name;
            lookForOverLappingNotes(insertedprogressnoteid);
            myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c' ORDER BY Name];
            for (RecordType rt: myRTs) {
                if (rt.Name == 'AZ - OPT') {
                    AZ_OPT_ID = rt.Id;
                } 
                if (rt.Name == 'Shift Note') {
                    SHIFT_NOTE_ID = rt.Id;
                }
            }
            if (pnedit.Service_Assignment__r.Admission__r.State__c == 'AZ') {
                myState='AZ';
                SelectOption SO;
                pn.RecordTypeId = AZ_OPT_ID;
                for (RecordType thisRT : myRTs){
                    string myName = thisRT.Name;
                    if(myName.contains(myState)){
                        SO = new SelectOption(thisRt.Id, thisRt.Name);
                        rtOptions.Add(SO);
                    }
                }
                if(pnedit.Service_Assignment__r.service_location__r.programid__c != '114165002') {
                    pn.Number_of_Required_Signatures__c = 1;    
                } else {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                }
            }   
        }//End Inline Edit Mode Block
    }//End Constructor Method
     
    /**Method called onclick save button on Edit Page**/
    public pagereference editInline(){
        newBlock = false; 
        pagereference pagref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Inlineedit&id='+ApexPages.currentPage().getParameters().get('id')+'&plan='+ActivePlanId);
        pagref.setredirect(true);
        return pagref;
    } 
    
    /**Method called onclick save button on Edit Page**/
    public pagereference saveModifiedProgressNote(){
    	
    	// EB-539 - moved ordering of time checks
    	if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates and times required.'));     
            return null;
    	}
    	
    	if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times must differ.'));     
            return null;
        } 
        // HOTFIX - EB-539 - start time must be before end time
        else if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date/time must be before end/date time.'));     
            return null;
        }
        else if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy.'));     
            return null;
        }
    	
        overlappingProgressNote = new list<progress_note__c>();
        overlappingProgressNote = lookForOverLappingNotes(insertedProgressNoteId);
        if(overlappingProgressNote.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times overlap with the start and end times of '+ overlappingProgressNote[0].Name+' note that you created. Please consider changing the start and end times.'));     
            return null;
        }
        
        pn.recordtypeid = AZ_OPT_ID ; 
        pn.Person_Being_Served__c = pbsName;
        pn.admission__c = admissionId;
        pn.Service_Assignment__c = theServAssignId;
        pn.Action_Plan__c = ActivePlanId;
        // EB-539 - wrap update in try/catch block to present error more nicely
        try {
       		update pn;
        }
       	catch (Exception e) {
		    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
		    return null;
		}
     	
     	insertedProgressNoteId = pn.Id;
        newBlock = false;
        pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id +'&SelectedKey='+ '' +'&DeselectedKey='+ '' );
        pageref.setredirect(true);
        return pageref;
         
    }
      
    /**Method called onclick Cancel button on Edit Page, Takes back the User 
    to Service Assignment page or Progress note page based on Pn.Id **/
    public pagereference cancelEditNote(){
        newBlock = false; 
        pagereference pageref;
        if(pn.id!=Null)
            pageref = new Pagereference('/'+pn.id);
        else
            pageref = new Pagereference('/'+theServAssignId);
        pageref.setredirect(true);
        return pageref;
    }
    
    //to be fixed
    public pagereference RenderSelectedIds(){
        overlappingProgressNote = new list<progress_note__c>();
        GoalsSelected = Apexpages.currentPage().getParameters().get('selectedKey');
        GoalsDeSelected = Apexpages.currentPage().getParameters().get('DeselectedKey');
        system.debug('*******'+ GoalsSelected);
        system.debug('*******'+ GoalsDeSelected);
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
        
        pn.recordtypeid = AZ_OPT_ID ;
        pn.Person_Being_Served__c = pbsName;
        pn.admission__c = admissionId;
        pn.Service_Assignment__c = theServAssignId;
        pn.Action_Plan__c = ActivePlanId;
        
        // HOTFIX - EB-539 - start time must be before end time, reorder to do time checks before checking overlap
        if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates and times required.'));     
            return null;
    	}
        if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times must differ.'));     
            return null;
        } 
        if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date/time must be before end/date time'));     
            return null;
        }
        if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy'));     
            return null;
        } 
        if(pn.Sleep_Check_Conducted__c == true && pn.Purpose_Service_is_Billable__c == true){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This progress note cannot have the "Purpose/Service is Billable field" checked if the "Sleep Check Conducted" field is also checked'));     
            return null;
        }
                if ([select id from Action_Plan__c where id = :ActivePlanId and Status__c='Active Final'].size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot create note for action plan not in Active Final status.'));  
            return null;
        }
        
        
        list<Progress_Note__c> samepbsNotes = New list<Progress_Note__c>();
        if(insertedProgressnoteid!=Null){
            samepbsNotes = [select id, Name, Person_being_served__r.Name, Action_Plan__c,start_time__c,Approval_User__c, end_time__c, status__c, Owner.Name ,ownerid from Progress_Note__c where id != :insertedprogressnoteId and disregard_note__c = false and Person_Being_Served__c = :pbsName and Admission__c = :admissionId and  Service_Assignment__c = :theServAssignId and Action_Plan__c = :ActivePlanId and OwnerId =: UserInfo.getUserId() and ((start_time__c >= :pn.start_Time__c and start_time__c <= :pn.end_time__c) or (end_time__c >= :pn.start_time__c and end_time__c <= :pn.end_time__c)or ( start_time__c <= :pn.start_time__c and end_time__c >= :pn.end_time__c ) ) ]; 
        }
        else{
            samepbsNotes = [select id, Name, Person_being_served__r.Name, Action_Plan__c,Approval_User__c,start_time__c, end_time__c, status__c, Owner.Name,ownerid from Progress_Note__c 
                where Person_Being_Served__c = :pbsName
                and disregard_note__c = false
                and Admission__c = :admissionId
                and  Service_Assignment__c = :theServAssignId
                and Action_Plan__c = :ActivePlanId
                and OwnerId =: UserInfo.getUserId()
                and (
                    (start_time__c >= :pn.start_Time__c and start_time__c <= :pn.end_time__c)
                    or   (end_time__c >= :pn.start_time__c and end_time__c <= :pn.end_time__c)
                    or  ( start_time__c <= :pn.start_time__c and end_time__c >= :pn.end_time__c )
                )
            ];
        }
        //System.debug('M--> K -->c'+ samepbsNotes );  
        list<Progress_Note__c> diffpbsNotes = [SELECT Id, Name, Person_being_served__r.Name, start_time__c,Approval_User__c, end_time__c, status__c, Owner.Name,ownerid from Progress_Note__c 
            where id != :insertedprogressnoteId 
            and disregard_note__c = false
            and Person_Being_Served__c != :pn.Person_Being_Served__c
            and OwnerId =: UserInfo.getUserId()
            and (
                (start_time__c >= :pn.start_Time__c and start_time__c <= :pn.end_time__c)
                or   (end_time__c >= :pn.start_time__c and end_time__c <= :pn.end_time__c)
                or  ( start_time__c <= :pn.start_time__c and end_time__c >= :pn.end_time__c )
            ) 
        ]; 
        //System.debug('M--> K -->c'+ diffpbsNotes ); 
        overlappingProgressNote.addall(samepbsNotes);
        overlappingProgressNote.addall(diffpbsNotes);
        if(overlappingProgressNote.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times overlap with the start and end times of '+ overlappingProgressNote[0].Name+' note that you created. Please consider changing the start and end times.'));     
            return null;
        }

        //pn.GoalIds_AZOPTPage__c = GoalsSelected;
        // EB-539 - wrap upsert in try/catch to present nicer messsage
        try {
        	upsert pn;

	        insertedProgressNoteId = pn.Id;
	        if(insertedProgressNoteId !=null){
	            list<ProgressNote_ActionPlanChildren_mjo__c> lstJncObj = New List<ProgressNote_ActionPlanChildren_mjo__c>();
	            lstJncObj = [select goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where progress_note__c =: insertedprogressnoteid];
	            list<string> existingId = new list <string>();
	            if(lstjncobj.size()>0){
	                for(ProgressNote_ActionPlanChildren_mjo__c jnc:lstjncobj){
	                    if(jnc.goal__C != Null ){
	                        existingId.add(jnc.goal__C);
	                    }else if(jnc.objective__c != Null ){
	                        existingId.add(jnc.objective__c);
	                    }
	                }
	            }
	            list<string> ObjSelIds = new list<string>();
	            list<string> finallisttocreate = new list<string>();
	            if(GoalsSelected!=null && GoalsSelected !='')
	                GoalSelStrs = (GoalsSelected.split(','));
	            list<string> AlrGoal = New List<String>();
	            if(goalSelStrs!= Null && GoalSelStrs.size()>0){
	                for(string s: goalSelstrs){
	                    if(s.contains('a1B')){
	                        ObjSelIds.add(s);
	                    }
	                }
	            }
	            
	            System.debug('******************GoalSelStrs'+GoalSelStrs);
	            if(existingId!=Null && existingId.size()>0){
	                for(string s:GoalSelStrs){
	                    boolean deletethis = false;
	                    for(string str:existingId){
	                        if(s==str){
	                            deletethis = true; //GoalSelStrs.remove(s)
	                        }
	                    }
	                    if(deletethis == false)
	                        finallisttocreate.add(s);
	                }
	            }else{
	                finallisttocreate.addall(GoalSelStrs);
	            }
	            list<string> relatedGoals = New List<string>();
	            list<action_plan_objective__c> ObjListToBeAdded = [select action_plan_goal__c from action_plan_objective__c where Id In :ObjSelIds] ; 
	            if(objlistToBeAdded!=Null && ObjListToBeAdded.size()>0){
	                for(action_plan_objective__c apo:objlistToBeAdded){
	                    boolean deletethis = false;
	                    for(string str:existingId){
	                        System.debug('******************existingId'+existingId);
	                        System.debug('************apo.action_plan_goal'+apo.action_plan_goal__c);
	                        if(apo.action_plan_goal__c==str){
	                            deletethis = true; //GoalSelStrs.remove(s)
	                        }
	                    }
	                    if(deletethis == false){
	                        boolean toAdd = true;
	                        for(string str:finallisttocreate){
	                            if(str == apo.action_plan_goal__c)
	                                toadd = false;
	                        }
	                        if(toAdd==true)
	                            finallisttocreate.add(apo.action_plan_goal__c);
	                    }
	                }
	            }
	            list<string> RemovedGoalIDs = New List<string>();
	            if(GoalsDeSelected!=null && GoalsDeSelected !=''){
	                GoalDeSelStrs = (GoalsDeSelected.split(','));
	                for(string s:GoalDeSelStrs){
	                    if(s.contains('a1A')){
	                        RemovedGoalIDs.add(s);
	                    }
	                }System.debug('******************RemovedGoalIDs'+RemovedGoalIDs);
	                if(RemovedGoalIDs.size()>0){
	                    list<action_plan_objective__c> ObjListToBedel = [select id from action_plan_objective__c where action_plan_goal__r.Id In :RemovedGoalIDs] ; 
	                    System.debug('******************ObjListToBedel'+ObjListToBedel);
	                    for(action_plan_objective__c obj:ObjListToBedel){
	                        GoalDeSelStrs.add(obj.id);
	                    }
	                }
	            }
	            if(finallisttocreate!=null && finallisttocreate.Size()>0){
	                for(string s:finallisttocreate){
	                    ProgressNote_ActionPlanChildren_mjo__c childJO =  new ProgressNote_ActionPlanChildren_mjo__c();
	                    childJO.progress_note__c = insertedProgressnoteid;
	                    if(S!=Null && S!=''){
	                        if(s.contains('a1A')){
	                           childJO.goal__c = s; 
	                        }
	                        else if(s.contains('a1B')){
	                            childJO.Objective__c=s;
	                        }
	                    }
	                    try{
	                        insert childJO;
	                    }
	                    catch(DMLException e){ApexPages.addMessages(e); }
	                }
	            }
	            if(GoalDeSelStrs!=null && GoalDeSelStrs.Size()>0){
	                list<ProgressNote_ActionPlanChildren_mjo__c> tobedelList = New List<ProgressNote_ActionPlanChildren_mjo__c>();
	                tobedelList = [select id,goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where (goal__c In: GoalDeSelStrs Or objective__c In: GoalDeSelStrs) and progress_note__c=:insertedprogressnoteid];
	                if(tobedelList!=Null && tobedelList.size()>0)
	                    delete tobedelList;
	            }
	        }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));     
            return null;
        }
        
        newBlock = false;
        pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id+'&SelectedKey='+ GoalsSelected +'&Deselectedkey='+ GoalsDeSelected); //+'&sfdc.override=1');
        pageref.setredirect(true);
        return pageref;     
    }
    
    public void reformedittree(list<string> GoalSelStrs){
        if(GoalSelStrs.size()>0){
           string strToUpdate ='';
            for(string s: GoalSelStrs){
                strToUpdate = strToUpdate + s+',';
            }
            System.debug('M K ----->> strToUpdate ' +strToUpdate); 
            allGoals = new TMN_Tree(); 
            
            list<string> GoalsSelIdLst = New List<string>();
            list<string> ObjSelIdLst = New List<string>(); 
            System.debug('689  ----->> ' +GoalSelStrs);
            for(string s: GoalSelStrs){
                if(s!=Null && S!=''){
                    if(s.contains('a1A')){
                        GoalsSelIdLst.add(s);
                    }
                    else if(s.contains('a1B')){
                        ObjSelIdLst.add(s);
                    }
                }
            } 
            System.debug('700  ----->> ' +GoalsSelIdLst);
            System.debug('700  ----->> ' +ObjSelIdLst);
                
            nodes2 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r where id in: ObjSelIdLst) from Action_Plan_Goal__c where Id In: GoalsSelIdLst Order BY Sort_Order__c];
            allgoals1 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r where id in: ObjSelIdLst) from Action_Plan_Goal__c where Action_Plan__c = :ActivePlanId And Id In: GoalsSelIdLst Order BY Sort_Order__c];  
                allObjectives = [select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId And Id In: ObjSelIdLst] ;                               
                Map<id,Action_Plan_Goal__c> idGoalMap = New Map<id,Action_Plan_Goal__c>();    
                    for(Action_Plan_Goal__c g:allGoals1){
                        idGoalMap.put(g.id,g);
                        list<Action_plan_objective__c> objectiveList = New List<Action_plan_objective__c>();
                        for(Action_plan_objective__c o: g.action_plan_objectives__r){
                            list<action_plan_action__c> tmpLst = new list<action_plan_action__c>();
                            mapActions.put(o.id, tmpLst);
                            objectiveList.add(o);                
                        }
                        GoalObjMap.put(g.Id,objectiveList);
                    
                    }
                    
                    for(action_plan_objective__c o:[select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId And id in: ObjSelIdLst]){
                        mapActions.put(o.id, o.Action_Plan_Actions__r);
                    
                    } 
            
            string goalID ='';
            string objID ='';
            if(nodes2.size()>0){
            for(Action_Plan_Goal__c n: nodes2){ 
                    string curEleType1 = 'Goal';
                    string curID1 = n.id;
                    string title1 = n.description__c;
                    TMN_Tree.node g_node= new TMN_Tree.node(curID1, title1);
                    g_node.isFolder = true;g_node.isExpand = true;
                    allGoals.root.nodes.add(g_node);
                    goalID =curID1;
                    if(GoalObjMap !=null && GoalObjMap.get(n.Id)!=null){
                        for(action_plan_objective__c ob:GoalObjMap.get(n.Id)){
                            if(ob.description__c!=null && ob.description__c!=''){
                                string curEleType2 = 'Objective';
                                string curID2 = ob.id;
                                string title2 = ob.description__c;
                                TMN_Tree.node o_node= new TMN_Tree.node(curID2, title2);
                                
                                integer g_key = allGoals.root.getNode_Key(goalID );
                                allGoals.root.nodes.get(g_key).nodes.add(o_node);
                                objID =curID2;
                                if(mapActions !=null && mapActions.get(ob.Id)!=null){
                                    for(Action_Plan_Action__c actPln: mapActions.get(ob.id)){
                                        if(actPln.description__c!=null &&actPln.description__c!=''){
                                            string curEleType3 = 'Action';
                                            string curID3 = actPln.id;
                                            string title3 = actPln.description__c;
                                            TMN_Tree.node a_node= new TMN_Tree.node(curID3, title3);
                                            a_node.hideCheckbox = true;
                                            integer g_key1 = allGoals.root.getNode_Key(goalID );
                                            integer o_key1 = allGoals.root.nodes.get(g_key).getNode_Key(objID);
                                            if(o_key1 != -1){
                                                allGoals.root.nodes.get(g_key1).nodes.get(o_key1).nodes.add(a_node);
                                            }
                                        }
                                    } 
                                }
                            }                         
                        }
                    }
                }
            }    
        } 
    }
     
    
    public void retrieveAllGoals(){
        string dispMode = ApexPages.currentPage().getParameters().get('Mode');
        list<ProgressNote_ActionPlanChildren_mjo__c> lstJncObj = New List<ProgressNote_ActionPlanChildren_mjo__c>();
        if (dispMode == 'Inlineedit'){
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
            lstJncObj = [select goal__c,objective__c from ProgressNote_ActionPlanChildren_mjo__c where progress_note__c =: insertedprogressnoteid];
            for(ProgressNote_ActionPlanChildren_mjo__c jnc:lstjncobj){
                if(jnc.goal__C != Null ){
                    GoalSelStrs.add(jnc.goal__C);
                }else if(jnc.objective__c != Null ){
                    GoalSelStrs.add(jnc.objective__c);
                }
            }
        }
        list<string> GoalsSelIdLst = New List<string>();
        list<string> ObjSelIdLst = New List<string>(); 
        System.debug('780  ----->> ' +GoalSelStrs);
        for(string s: GoalSelStrs){
            if(s!=Null && S!=''){
                if(s.contains('a1A')){
                    GoalsSelIdLst.add(s);
                }
                else if(s.contains('a1B')){
                    ObjSelIdLst.add(s);
                }
            }
        }           
        allGoals = new TMN_Tree();  
        if(dispMode == 'New')
            nodes2 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Action_Plan__c = :ActivePlanId Order BY Sort_Order__c];
        else    
            nodes2 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Action_Plan__c =: ActivePlanId Order BY Sort_Order__c];
        string goalID ='';
        string objID ='';
        if(nodes2.size()>0){
            for(Action_Plan_Goal__c n: nodes2){ 
                string curEleType1 = 'Goal';
                string curID1 = n.id;
                string title1 = n.description__c;
                TMN_Tree.node g_node= new TMN_Tree.node(curID1, title1);
                if(GoalsSelIdLst.size()>0){
                    for(string str:GoalsSelIdLst ){
                        if(str==curID1){
                            g_node.isSelected = true;
                        }
                    }
                }g_node.isFolder = true;
                //g_node.isExpand = false;
                //g_node.isSelected = true;
                allGoals.root.nodes.add(g_node);
                goalID =curID1;
                if(GoalObjMap !=null && GoalObjMap.get(n.Id)!=null ){
                    for(action_plan_objective__c ob:GoalObjMap.get(n.Id)){
                        if(ob.description__c!=null && ob.description__c!=''){
                            string curEleType2 = 'Objective';
                            string curID2 = ob.id;
                            string title2 = ob.description__c;
                            TMN_Tree.node o_node= new TMN_Tree.node(curID2, title2);
                            for(string strObj:ObjSelIdLst ){
                                if(strObj==curID2){
                                    if(g_node.isSelected == true){
                                        o_node.isSelected = true;
                                    }
                                }
                            }
                            integer g_key = allGoals.root.getNode_Key(goalID );
                            allGoals.root.nodes.get(g_key).nodes.add(o_node);
                            objID =curID2;
                            if(mapActions !=null && mapActions.get(ob.Id)!=null ){
                                for(Action_Plan_Action__c actPln: mapActions.get(ob.id)){
                                    if(actPln.description__c!=null &&actPln.description__c!=''){
                                        string curEleType3 = 'Action';
                                        string curID3 = actPln.id;
                                        string title3 = actPln.description__c;
                                        TMN_Tree.node a_node= new TMN_Tree.node(curID3, title3);
                                        if(o_node.isSelected == true)
                                            a_node.isSelected = true;
                                        a_node.hideCheckbox = true;
                                        integer g_key1 = allGoals.root.getNode_Key(goalID );
                                        integer o_key1 = allGoals.root.nodes.get(g_key).getNode_Key(objID);
                                        if(o_key1 != -1){
                                            allGoals.root.nodes.get(g_key1).nodes.get(o_key1).nodes.add(a_node);
                                        }
                                    }
                                }
                            }
                        }                         
                    }
                }
            }
        }
    }
    
    /** Method called onclick Save on Inline Edit Page**/
    public pagereference saveProgressNoteInlineEdit(){

        // HOTFIX - EB-539 - start time must be before end time, reorder to do time checks before checking overlap
        if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates and times required.'));     
            return null;
    	}
        if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times must differ.'));     
            return null;
        } 
        if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date/time must be before end/date time'));     
            return null;
        }
        if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy'));     
            return null;
        } 
        if(pn.Sleep_Check_Conducted__c == true && pn.Purpose_Service_is_Billable__c == true){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This progress note cannot have the "Purpose/Service is Billable field" checked if the "Sleep Check Conducted" field is also checked'));     
            return null;
        }
        if ([select id from Action_Plan__c where id = :ActivePlanId and Status__c='Active Final'].size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot create note for action plan not in Active Final status.'));  
            return null;
        }
       upsert pn;
       return null;
    }
    
    /** Method called onclick Save on New Progrss Note Page**/
    public pagereference saveProgressNote(){
    	
        // HOTFIX - EB-539 - start time must be before end time, reorder to do time checks before checking overlap
        if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates and times required.'));     
            return null;
    	}
        if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times must differ.'));     
            return null;
        } 
        if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date/time must be before end/date time'));     
            return null;
        }
        if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy'));     
            return null;
        } 
        if(pn.Sleep_Check_Conducted__c == true && pn.Purpose_Service_is_Billable__c == true){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This progress note cannot have the "Purpose/Service is Billable field" checked if the "Sleep Check Conducted" field is also checked'));     
            return null;
        }
        if ([select id from Action_Plan__c where id = :ActivePlanId and Status__c='Active Final'].size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot create note for action plan not in Active Final status.'));  
            return null;
        }

		if(overlappingProgressNote.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end time overlaps with the start and end time of '+ overlappingProgressNote[0].Name+' note that you created. Please consider changing the start and end times.'));     
            return null;
        }else{
            return null;
        }
    }
    
    public List<Attachment> Attachments{
        get{
            if(Attachments==null){
                Attachments= [select Id, ParentId, Name, Description from Attachment where parentId=:theServAssign.person_being_served__c];
            }
            return Attachments;
        }
        set;
    }
}