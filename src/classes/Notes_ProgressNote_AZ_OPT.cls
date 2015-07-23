public with sharing class Notes_ProgressNote_AZ_OPT {
    public Progress_Note__c CurrentRecord {get; set;} 
    public Service_Assignment__c theServAssign { get; set; }
    public Id theServAssignId { get; set; }
    public boolean editmode{get; set;}  
    public boolean savemode{get; set;}
    public boolean inlinemode{get; set;}
    Public Id ActivePlanId{get;set;}
    public Admission__c admission { get; set; }
    public Id admissionId { get; set; }
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    Public Boolean NewBlock{get;set;}
    Public String ContactName{get;set;}
    public ApexPages.StandardController stdCtrl {get; set;}
    Public String SignedDoc {get;set;}
    Public list<sTRING> GoalSelStrs {get;set;}
   public string GoalsSelected{get;set;}
   public Map<Id, GoalWrapper> treeModel = new Map<Id, GoalWrapper>();
   public list<action_plan_objective__c> allObjectives  = new list<action_plan_objective__c>();
   public list<action_plan_objective__c> getallObjectives (){return allObjectives ;}
   public list<Action_Plan_Goal__c> allgoals1 = new list<Action_plan_Goal__c>();
   Map<id,Action_Plan_Goal__c> GoalMap = New Map<Id,Action_Plan_Goal__c>();
   Map<id,list<Action_plan_objective__c>> GoalObjMap = New Map<id,list<Action_plan_objective__c>>();
    public list<Action_Plan_Goal__c> getallgoals1(){return allGoals1;}
    public map<string, list<action_plan_action__c>> mapActions = new map<string, list<action_plan_action__c>>();
    public map<string, list<action_plan_action__c>> getMapActions(){ return mapActions ;}
    public list<Action_Plan_Goal__c> nodes2 {get;set;}
   
   public list<Clinical_Catalog_Tree_Node__c > currentInsertedNodes {get; set;}
    //this tree will be used in the form for selected a goal to related an objective to as well as objectives to relate actions to.
    public TMN_Tree formTree {get; set;}
    public TMN_Tree allGoals {get; set;}
    public list<Clinical_Catalog_Tree_Node__c> nodes {get; set;}
    public Clinical_Catalog__c curr_catalog {get; set;}
    public Clinical_Catalog_Element__c CurEley {get; set;}
    public Clinical_Catalog_Tree_Node__c CurTreeNode {get; set;}
    //keys returned by the fancy tree comp are stored here
    public string selectedKeys{get; set;}
    //used on the edit link to pass the Catalog Elemnt ID
    public string eleyID {get; set;}
    public string curTreeNodeKey {get; set;}    
    public List<SelectOption> pickList {get; set;}
   
    public string RTid;
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public Id AZ_OPT_ID, SHIFT_NOTE_ID;
    public String pbsName { get; set; }
    Public Boolean AsmntOnly{get;set;}
    private string usrOpGrp;
    Public Id insertedProgressNoteId{get;set;}
    public list<SelectOption> rtOptions = new list<SelectOption>();
    public list<SelectOption> getrtOptions(){return rtOptions ;}
    public RecordType defaultRt { get; set; }

    private Final Progress_Note__c pn;
    public boolean displayPopup {get; set;}     
    
    public Progress_Note__c thePN = new Progress_Note__c();
    public Progress_Note__c getthePN(){return thePN;}
    public List<Progress_Note__c> pnOverlap {get; set;} 
    // SHAUN-40 - update to only show overlap for AZ-OPT notes - 09/05/2014
    public boolean hasOverlap {get { return (pnOverlap.size() > 0 && thePN.recordtype.developername == 'AZ_OPT');} }
    
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c,Person_Being_Served__r.Name,next_approver__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername from Progress_Note__c where id= :tmp.id limit 1];
        
      List<Progress_Note__c> samepbsNotes = [select id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c, Owner.Name from Progress_Note__c 
              where id != :thePN.id 
              and Person_Being_Served__c = :thePN.Person_Being_Served__c
              and Admission__c = :thePN.Admission__c
              and  Service_Assignment__c = :thePN.Service_Assignment__c
              and Plan__c = :thePN.Plan__c
              and (
                  (start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
                or   (end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
                or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
                )
                ];   
       //Added by Sravan to display the Progress Notes with overlapping time with a different PBS. EB-188 08/12/2014 12:26 PM      
       List<Progress_Note__c> diffpbsNotes = [SELECT Id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c, Owner.Name from Progress_Note__c 
              where id != :thePN.id 
              and Person_Being_Served__c != :thePN.Person_Being_Served__c
              and Owner.Name = :thePN.Owner.Name
              and (
                  (start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
                or   (end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
                or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
                ) 
                ]; 
                
        pnOverlap.addall(samepbsNotes);
        pnOverlap.addall(diffpbsNotes);    
    }
    
    Public pagereference SubmitForApp(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(thePn.id);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Progress_Notes_Approval');
        req1.setSkipEntryCriteria(true);
        list<id> listids = new list<id>();
        listids.add(thePN.next_approver__c);
        req1.setNextApproverIds(listids);
        Approval.ProcessResult result = Approval.process(req1);
        pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+thePn.id+'&sfdc.override=1');
        pageref.setredirect(true);
        return pageref;
    }
    
    
    public PageReference myFinal(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_Create_Flavor_PDF');
        pageRef.getParameters().put('id', thePN.id);
        
        try{
            update thePN;
            return pageRef;
        }
            catch(DMLException e){
                thePN.addError(e.getMessage());
            }      
        return null;
    }
    
    public PageReference disregardNote(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_AddlActions');
        pageRef.getParameters().put('id', thePN.id);
        return pageRef;
        
    }
    
    public boolean displayPopupComp {get; set;}     
    
    public void closePopupComp() {        
        displayPopupComp = false;    
    }     
    public void showPopupComp() {        
        displayPopupComp = true;    
    }
    public void closePopup() {        
        displayPopup = false;    
    }     
    public pagereference showPopup() { 
        list<progress_note__c> pnValidations = [SELECT Id, service_location__C,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c, end_time__c, status__c, recordtype.Name,Service_code__c,People_Present__c,
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Action_plan__c,Number_of_Required_Signatures__c ,Signature_on_File__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        boolean HasGoal = false;
        List<ProgressNote_ActionPlanChildren_mjo__c> GoalList = [SELECT Id, Progress_Note__c, Goal__c from ProgressNote_ActionPlanChildren_mjo__c where Progress_Note__c =: thePN.id];
        for(ProgressNote_ActionPlanChildren_mjo__c p:GoalList){
            if(p.goal__c!=Null){
                hasGoal = True ;
            }
        } 
        if(/***!hasgoal || **/pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' || pnValidations[0].Action_plan__c == Null ||
        (pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0)||
        pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || pnValidations[0].Service_code__c == Null ||pnValidations[0].Interventions__c== Null || pnValidations[0].Notes_For_Next_Visit__c == Null  || pnValidations[0].progress__c == Null || pnValidations[0].Type_of_Contact__c == '' || pnValidations[0].progress__c == '' || pnValidations[0].Interventions__c== '') {
            //if(!hasGoal){
            //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a "Goal" before continuing.'));   
            //}
            if(pnValidations[0].status__c == 'Final'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note has already been Finalized'));  
            }
            if(pnValidations[0].Approval_Status__c == 'Pending'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note is pending Approval')); 
            }
            if(pnValidations[0].Action_plan__c == Null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Action Plan before continuing'));    
            }
            if(pnValidations[0].Service_Location__c == Null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Location before continuing'));   
            }
            if(pnValidations[0].Type_of_Contact__c == Null ||pnValidations[0].Type_of_Contact__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select the Type of Contact before continuing'));  
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
         GoalsSelected='';
         GoalSelStrs = New List<String>();
         String dispMode = ApexPages.currentPage().getParameters().get('Mode');
        if(dispMode!='Edit'){
            ActivePlanId = ApexPages.currentPage().getParameters().get('plan');
        }else if (dispMode =='Edit'){
        	 insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
             progress_note__c pn = [select Service_Assignment__c ,End_Time__c,Start_Time__c,Signature_on_File__c,GoalIds_AZOPTPage__c ,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
             this.thePN = pn;
             GoalsSelected = Apexpages.currentPage().getParameters().get('selectedKey');
             list<Id> GoalSelIds = New List<Id>();
             if(GoalsSelected == null || GoalsSelected == '')
             	GoalsSelected = pn.GoalIds_AZOPTPage__c;
             
             SignedDoc = pn.Signature_on_File__c;
             pnOverlap = new List<Progress_Note__c>();
             theServAssignId =  Pn.Service_Assignment__c ;
             pbsName = pn.Service_Assignment__r.Person_Being_Served__c;
             admissionId = pn.Service_Assignment__r.Admission__c;  
             ActivePlanId = pn.Action_Plan__c;
             if(GoalsSelected!=null && GoalsSelected !=''){
             	GoalSelStrs = (GoalsSelected.split(','));
                reformedittree(GoalSelStrs);
             }
        }
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
                    if(o.Action_Plan_Actions__r!= null){
                    mapActions.put(o.id, o.Action_Plan_Actions__r);
                    System.debug('------here 253');
                    }
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
            if (!String.isBlank(pbsId)) {
                pbsname = [SELECT Name FROM Contact WHERE Id=:pbsId].Name;
            }
            if (!Test.isRunningTest()) {
                controller.addFields(new String[] {'RecordType.Name'});
                
            }
            pn = (Progress_Note__c) controller.getRecord();
            ID saID = ApexPages.currentPage().getParameters().get('ServAssignId');
            Service_Assignment__c sa = [select id, name, service_location__r.programid__c,recordtype.name from service_assignment__c where id = :saID LIMIT 1];
    
           User currUser = [ select id, Operating_Group__c from User where id = :UserInfo.getUserId()];
           usrOpGrp = currUser.Operating_Group__c;
            
            // If Progress Note is AZ-OPT, we have to default some fields here, but only for non-CM AZ
            if (myState == 'AZ') {
                if ( sa.service_location__r.programid__c != '114165002') {
                    pn.Number_of_Required_Signatures__c = 1;
                    pn.RecordTypeId = AZ_OPT_ID;
                } else {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                }
            }
            //Added By Amruth for EB-436
            if(sa.recordtype.name == 'Assessment Only' && currUser != null && currUser.Operating_Group__c == 'NeuroRestorative'){
                AsmntOnly = true;
            }   
            if (currUser != null ) {
                if (( myState == 'MN' || myState == 'IN' || myState == 'CA') && currUser.Operating_Group__c == 'Redwood') {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                    // special case for CM Ludlow is handled above in AZ
                }
            } else {
                // add error to page that shift note cannot be created
            }
            
            loadData();
            if(Controller.getRecord()!= null) 
                editmode= false;
            savemode = true;
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
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
          this.thePN = pn;
            pnOverlap = new List<Progress_Note__c>();
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
            ActivePlanId = pnedit.Action_Plan__c;
            ContactName = pnedit.Service_Assignment__r.Person_Being_Served__r.Name;
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
                if ( pnedit.Service_Assignment__r.service_location__r.programid__c != '114165002') {
                    pn.Number_of_Required_Signatures__c = 1;
                    
               } else {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                }
            }   
        }
    }
    
     public pagereference editInline(){
        newBlock = false; 
        pagereference pagref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Inlineedit&id='+ApexPages.currentPage().getParameters().get('id')+'&plan='+ActivePlanId);
        pagref.setredirect(true);
        return pagref;
    } 
    
    public pagereference saveModifiedProgressNote(){
       if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
      		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy')); 	
       		return null;
       }
       pn.recordtypeid = AZ_OPT_ID ; 
       pn.Person_Being_Served__c = pbsName;
       pn.admission__c = admissionId;
       pn.Service_Assignment__c = theServAssignId;
       pn.Action_Plan__c = ActivePlanId;
       update pn;
       insertedProgressNoteId = pn.Id;
       newBlock = false;
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id +'&SelectedKey='+ GoalsSelected );
       pageref.setredirect(true);
       return pageref;
        
    } 
    
    public pagereference cancelEditNote(){
        newBlock = false; 
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id+'&sfdc.override=1');
        pageref.setredirect(true);
        return pageref;
    }
    
    public pagereference RenderSelectedIds(){
        GoalsSelected = Apexpages.currentPage().getParameters().get('selectedKey');
        System.debug('>> ' + GoalsSelected );
        pn.recordtypeid = AZ_OPT_ID ;
        
       pn.Person_Being_Served__c = pbsName;
       pn.admission__c = admissionId;
       pn.Service_Assignment__c = theServAssignId;
       pn.Action_Plan__c = ActivePlanId;
       pn.GoalIds_AZOPTPage__c = GoalsSelected;
       
       //ensure that we dont create a new note with the inactive action plan
       if ([select id from Action_Plan__c where id = :ActivePlanId and Status__c='Active Final'].size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot create note for action plan not in Active Final status.'));  
            return null;
       }
       system.debug('++++++++++++'+(pn.End_Time__c.getTime())/1000/60+ '-------------');
      		
       if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
       	    system.debug('++++++++++++'+pn.End_Time__c.getTime()+ '-------------'+integer.valueof(pn.End_Time__c.getTime() - pn.Start_Time__c.getTime())*24*60);
      		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy')); 	
       		return null;
       }
       upsert pn;
       insertedProgressNoteId = pn.Id;
       newBlock = false;
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id+'&SelectedKey='+ GoalsSelected +'&sfdc.override=1');
       pageref.setredirect(true);
       return pageref;     
            
    }
    
    public void reformedittree(list<string> GoalSelStrs){
    	/**progress_note__c p = new progress_note__C();
    	if(GoalSelStrs.size()==0)
    		p = [select id, GoalIds_AZOPTPage__c from Progress_Note__c where id =: pn.id limit 1];
        GoalsSelected = p.GoalIds_AZOPTPage__c;
        list<Id> GoalSelIds = New List<Id>();
        GoalSelStrs = (GoalsSelected.split(','));**/
        if(GoalSelStrs.size()>0){
	             
	        allGoals = new TMN_Tree();      
	        nodes2 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Id In: GoalSelStrs Order BY Sort_Order__c];
	        allgoals1 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Action_Plan__c = :ActivePlanId Order BY Sort_Order__c];  
	            allObjectives = [select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId] ;                               
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
	                
	                for(action_plan_objective__c o:[select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :ActivePlanId]){
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
		            g_node.isFolder = true;
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
        allGoals = new TMN_Tree();  
        System.debug('))))))))))))'+ ActivePlanId);    
        nodes2 = [select id, description__c, (select id, Description__c, status__c from action_plan_objectives__r ) from Action_Plan_Goal__c where Action_Plan__c = :ActivePlanId Order BY Sort_Order__c];
        string goalID ='';
        string objID ='';
        if(nodes2.size()>0){
	        for(Action_Plan_Goal__c n: nodes2){ 
	            string curEleType1 = 'Goal';
	            string curID1 = n.id;
	            string title1 = n.description__c;
	            TMN_Tree.node g_node= new TMN_Tree.node(curID1, title1);
	            g_node.isFolder = true;
	            allGoals.root.nodes.add(g_node);
	            goalID =curID1;
	            if(GoalObjMap !=null && GoalObjMap.get(n.Id)!=null ){
	            	for(action_plan_objective__c ob:GoalObjMap.get(n.Id)){
		            	if(ob.description__c!=null && ob.description__c!=''){
			                string curEleType2 = 'Objective';
			                string curID2 = ob.id;
			                string title2 = ob.description__c;
			                TMN_Tree.node o_node= new TMN_Tree.node(curID2, title2);
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
     
    private void ctlgCmpntTypes(){
        pickList = new List<SelectOption>();
        pickList.add(new SelectOption('','--None--'));
        pickList.add(new SelectOption('Goal','Goal'));
        pickList.add(new SelectOption('Objective','Objective'));
        pickList.add(new SelectOption('Action','Action'));
    }
    
    
    public pagereference saveProgressNote(){
    	progress_note__c pn = [select Service_Assignment__c ,End_Time__c,Start_Time__c,Signature_on_File__c,GoalIds_AZOPTPage__c ,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
     	this.thePN = pn;
        if(decimal.valueof((thePN.End_Time__c.getTime())/1000/60 - (thePN.Start_Time__c.getTime())/1000/60) > 120.0){
      		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy')); 	
       		return null;
       }
       return null;
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
    
    public List<Task> taskOnCurrentPBSAccount{
        get{ 
            return [select id,WhoId,Who.Name,Owner.Name,WhatID,Status,subject,OwnerId,LastModifiedDate from Task where WhatId=:theServAssign.person_being_served__r.AccountId order by createddate desc limit 10];
        }
        set;
    }
    
    public List<Event> eventOnCurrentPBSAccount{
        get{
            return [select id, WhoId,subject,LastModifiedDate ,Who.Name,whatId,ActivityDate,OwnerId,Owner.Name from Event where WhatId=:theServAssign.person_being_served__r.AccountId order by createddate desc limit 10];
        }
        set;
    }
    
    public PageReference savepage(){
        upsert CurrentRecord ;
        editmode = true;
        savemode = false;
        return null;     
    }
    
    public PageReference editpage(){
        editmode = false;
        savemode = true;
        return null;
    }
    
    public Notes_ProgressNote_AZ_OPT() {
        String dispMode = ApexPages.currentPage().getParameters().get('Mode');
        if(dispMode == 'New'){
            myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c' ORDER BY Name];
            loadData();
        }
    }
    //load
    public void loadData(){
        myState=myState.toLowerCase();
        //create record type selection option there is an escape option so is the filter is incorrect as a short term messure -go to the url and remove state in the VF page | (state=) < null or blank |
        SelectOption SO;
        for (RecordType thisRT : myRTs){
            string myName = thisRT.Name.toLowerCase();
            if(String.isBlank(myState)){
                SO = new SelectOption(thisRt.Id, thisRt.Name);
                rtOptions.Add(SO);
            }
            else if ( myName == 'shift note' && pn.RecordTypeId == SHIFT_NOTE_ID) {
                SO = new SelectOption( thisRt.Id, thisRt.Name);
                rtOptions.Add(SO);
                break;
            }
            
            else {
                if(myName.StartsWith(myState)){
                    SO = new SelectOption(thisRt.Id, thisRt.Name);
                    rtOptions.Add(SO);
                }
            }
            if( AsmntOnly && myname == 'therapy'){
                    SO = new SelectOption(thisRt.Id, thisRt.Name);
                    rtOptions.Add(SO);
            }
        }
        if(rtOptions.size()==1) {
            Id defaultRtId;
            for(SelectOption o : rtOptions) {
                defaultRtId = o.getValue();
            }
            defaultRt = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :defaultRtId ];
            pn.RecordTypeId = defaultRt.Id;
        }
        List<RecordType> rtsForZeroSigs = new List<RecordType>();
        rtsForZeroSigs = [ SELECT Name, DeveloperName FROM RecordType WHERE DeveloperName = 'IN_FCT' OR DeveloperName = 'MA_FCT'
                            OR DeveloperName = 'MD_FCT' OR DeveloperName = 'OH_FCT' Or Name = 'Therapy'];
        for(RecordType rtForLoop : rtsForZeroSigs) {
            if(rtForLoop.Id==pn.RecordTypeId && pn.Number_of_Required_Signatures__c==null) {
                pn.Number_of_Required_Signatures__c = 0;
            }
        }

    }
    // redirect if necessary
    public PageReference redirect(){
        ID planID = ApexPages.currentPage().getParameters().get('plan');
        ID admID = ApexPages.currentPage().getParameters().get('admission');
        ID saID = ApexPages.currentPage().getParameters().get('ServAssignId');
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if ( pn.RecordTypeId == SHIFT_NOTE_ID ) {
            PageReference prShiftNote;
            
            // EC-196 - CM gets different shift note form
            if ( usrOpGrp == 'Care Meridian') {
                prShiftNote = Page.shiftnote_narrative_form;
            } else {
                prShiftNote = Page.shiftnote_basic_form;
                prShiftNote.getParameters().put('planID', planId);
            }
            prShiftNote.getParameters().put('admID', admId);
            prShiftNote.getParameters().put('saID', saID);
            prShiftNote.getParameters().put('retURL', retURL);
            prShiftNote.setRedirect(true);
            return prShiftNote;
        }
        else
            return null;
                
    }
    
    public class goalWrapper {
        public Action_Plan_Goal__c goalSel;
        public list<Action_plan_objective__c> ObjectivesSel;
        public List<Action_plan_Action__c > ActionSel;
        public boolean isAssocPresent = false;       // to indiate if the packet-Doc junction is already present in the association table
        public boolean isChanged = false;
        public boolean isNew = false;
        
        
        public goalWrapper(Action_Plan_Goal__c goal, list<Action_plan_objective__c> objList, List<Action_plan_Action__c> ActList){
            this.goalSel = goal;
            this.ObjectivesSel = objList;
            this.ActionSel = ActList;
        }
    }
}