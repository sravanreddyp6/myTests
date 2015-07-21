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
   
   //goal starts 
    public list<Clinical_Catalog_Tree_Node__c> nodes {get; set;}
    public Clinical_Catalog__c curr_catalog {get; set;}   
   public TMN_Tree allGoals {get; set;}
   public list<Clinical_Catalog_Tree_Node__c > currentInsertedNodes {get; set;}
    //this tree will be used in the form for selected a goal to related an objective to as well as objectives to relate actions to.
    public TMN_Tree formTree {get; set;}
    
    public Clinical_Catalog_Element__c CurEley {get; set;}
    public Clinical_Catalog_Tree_Node__c CurTreeNode {get; set;}
    //keys returned by the fancy tree comp are stored here
    public string selectedKeys{get; set;}
    //used on the edit link to pass the Catalog Elemnt ID
    public string eleyID {get; set;}
    public string curTreeNodeKey {get; set;}    
    
    public List<SelectOption> pickList {get; set;}
    public boolean ctlgHasABI {get; set;}
  
   
    public void retrieveAllGoals(){
        allGoals = new TMN_Tree();
        nodes = [select id, name, Catalog_Element__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, ID_Goal__c, ID_Objective__c, ID_Action__c, Status__c  from Clinical_Catalog_Tree_Node__c Where Catalog__r.id =:curr_catalog.id Order By ID_Goal__c , ID_Objective__c , ID_Action__c];
        
        string goalID ='';
        string objID ='';
        for(Clinical_Catalog_Tree_Node__c n: nodes){            
            string curEleType = n.Catalog_Element__r.type__c;
            string curID = n.name;
            string title = n.Catalog_Element__r.description__c;
            
            if(curEleType == 'Goal'){
                TMN_Tree.node g_node= new TMN_Tree.node(curID, title);
                g_node.CatTreeNode = n;
                g_node.isFolder = true;
                allGoals.root.nodes.add(g_node);
                goalID =curID;
            }
        
            if(curEleType == 'Objective'){
                TMN_Tree.node o_node= new TMN_Tree.node(curID, title);
                o_node.CatTreeNode = n;
                integer g_key = allGoals.root.getNode_Key(goalID );
                allGoals.root.nodes.get(g_key).nodes.add(o_node);
                objID =curID;
            }
            
            if(curEleType == 'Action'){                
                TMN_Tree.node a_node= new TMN_Tree.node(curID, title);
                a_node.CatTreeNode = n;
                integer g_key = allGoals.root.getNode_Key(goalID );
                integer o_key = allGoals.root.nodes.get(g_key).getNode_Key(objID);
                if(o_key != -1){
                    allGoals.root.nodes.get(g_key).nodes.get(o_key).nodes.add(a_node);
                }
            }                          
        }
    }
    
    
    
    public pageReference upsertCatalog(){
        upsert curr_catalog;
        return null;
    }  
    
    public pageReference editTreeNode(){
        eleyID = [select Catalog_Element__r.id from Clinical_Catalog_Tree_Node__c Where name =:curTreeNodeKey].Catalog_Element__r.id;
        CurEley = [select name, id, Type__c, Description__c, status__c from Clinical_Catalog_Element__c Where id =:eleyID];
        refreshFormTree();
        return null;
    }
    
    public pageReference newEley(){
        CurEley = new Clinical_Catalog_Element__c ();
        CurEley.Status__c = 'Active';
        return null;
    }
    
    
    
       
public pageReference upsertEley(){

    //import the keys the fancy tree gave us
    list<string> items = new list<string>();
    items = selectedKeys.split(',');        

    if ((CurEley.Type__c == 'Objective' || CurEley.Type__c == 'Action' ) && selectedKeys.length() == 0){
        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'You must associate this to at least one component from the catalog.'));
        return null;
    } 

    upsert CurEley;
    CurEley = [select name, id, Type__c, Description__c, status__c from Clinical_Catalog_Element__c Where id =:CurEley.id];
    string curEleyType = CurEley.Type__c;
    
    list<Clinical_Catalog_Tree_Node__c > NewNodes = new list<Clinical_Catalog_Tree_Node__c >();
    list<Clinical_Catalog_Tree_Node__c > PurgeNodes = new list<Clinical_Catalog_Tree_Node__c >();
        
    if(curEleyType == 'Goal' && currentInsertedNodes.size() == 0){
        Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
        newNode.Catalog__c = curr_catalog.id;
        newNode.Catalog_Element__c = CurEley.id;
        newNode.ID_Goal__c = integer.valueof(CurEley.name);
        newNode.ID_Objective__c = 0;
        newNode.ID_Action__c = 0;
        NewNodes.add(newNode); 
    }
    


    formTree.inputSelectedKeys(items, true);  
    //loop over goals  
    
    for(TMN_Tree.node n :formTree.root.nodes){
        //check for pre-exsiting join
        if(curEleyType == 'Objective'){
            boolean hasRecord = false;
            for(Clinical_Catalog_Tree_Node__c selN :currentInsertedNodes ){
                if(selN.name == n.CatTreeNode.name){
                    hasRecord = true;
                    if(!n.isSelected){ PurgeNodes .add(selN);}
                }
            }
            if(!hasRecord && n.isSelected){
                    Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
                    newNode.Catalog__c = curr_catalog.id;
                    newNode.Catalog_Element__c = CurEley.id;
                    newNode.ID_Goal__c = n.CatTreeNode.ID_Goal__c;
                    newNode.ID_Objective__c = integer.valueof(CurEley.name);
                    newNode.ID_Action__c = 0;
                    NewNodes.add(newNode);
            }
            
        }
        // loop over objectives when
        if(curEleyType == 'Action'){
            for(TMN_Tree.node o :n.nodes) {
                boolean hasRecord = false;
                for(Clinical_Catalog_Tree_Node__c selN :currentInsertedNodes ){
                    if(selN.name == o.CatTreeNode.name){
                        hasRecord = true;
                        if(!o.isSelected){ PurgeNodes.add(selN);}
                    }
                }
                if(!hasRecord && o.isSelected){
                        Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
                        newNode.Catalog__c = curr_catalog.id;
                        newNode.Catalog_Element__c = CurEley.id;
                        newNode.ID_Goal__c = o.CatTreeNode.ID_Goal__c;
                        newNode.ID_Objective__c = o.CatTreeNode.ID_Objective__c;
                        newNode.ID_Action__c = integer.valueof(CurEley.name);
                        NewNodes.add(newNode);
                } 
            }               
        }                    
    }    

    
    list<Clinical_Catalog_Tree_Node__c > inactivateNodes = new list<Clinical_Catalog_Tree_Node__c >();    
    
    if (CurEley.status__c == 'Inactive') {
        for (Clinical_Catalog_Tree_Node__c n :nodes){
            if(curEleyType == 'Goal' && Integer.valueOf(n.ID_Goal__c) == Integer.valueOf(CurEley.name) && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }
            if(curEleyType == 'Objective' && Integer.valueOf(n.ID_Objective__c) == Integer.valueOf(CurEley.name) && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }
            if(curEleyType == 'Action' && Integer.valueOf(n.ID_Action__c) == Integer.valueOf(CurEley.name) && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }            
        }        
        for (Clinical_Catalog_Tree_Node__c inActNd :inactivateNodes) {
                inActNd.Status__c = 'Inactive';
        }
        upsert inactivateNodes;        
    }    


    list<Clinical_Catalog_Tree_Node__c > activateNodes = new list<Clinical_Catalog_Tree_Node__c >();    
    if (CurEley.status__c == 'Active') {
        for (Clinical_Catalog_Tree_Node__c n :nodes){
            if(curEleyType == 'Goal' && Integer.valueOf(n.ID_Goal__c) == Integer.valueOf(CurEley.name) && n.Status__c == 'Inactive'){
                activateNodes.add(n);
            }
            if(curEleyType == 'Objective' && Integer.valueOf(n.ID_Objective__c) == Integer.valueOf(CurEley.name) && n.Status__c == 'Inactive'){
                activateNodes.add(n);
            }
            if(curEleyType == 'Action' && Integer.valueOf(n.ID_Action__c)== Integer.valueOf(CurEley.name) && n.Status__c == 'Inactive'){
                activateNodes.add(n);
            }            
        }        
        for (Clinical_Catalog_Tree_Node__c actNd :activateNodes) {
                actNd.Status__c = 'Active';
        }
        upsert activateNodes;        
    }
    
    /*
    if(curEleyType == 'Objective'){
    nodes = [select id, name, Catalog_Element__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, ID_Goal__c, ID_Objective__c, ID_Action__c  from Clinical_Catalog_Tree_Node__c Where Catalog__r.id =:curr_catalog.id AND Catalog_Element__r.type__c = 'Action' ];
       for(Clinical_Catalog_Tree_Node__c action :nodes){
           for(Clinical_Catalog_Tree_Node__c purge :PurgeNodes){           
               if((action.ID_Goal__c == purge.ID_Goal__c)&& (action.ID_Objective__c == purge.ID_Objective__c)){
                   PurgeNodes.add(action);
               }           
           } 
       }
    }
    */
    insert NewNodes;
    delete PurgeNodes;
    CurEley = new Clinical_Catalog_Element__c ();
    retrieveAllGoals();
    return null;
}

public list<Clinical_Catalog_Tree_Node__c > updateSelected(id eID){
    list<Clinical_Catalog_Tree_Node__c> tmpLst2 = new list<Clinical_Catalog_Tree_Node__c>();
    tmpLst2 = [select id, name, ID_Goal__c, ID_Objective__c, ID_Action__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, status__c from Clinical_Catalog_Tree_Node__c Where Catalog_Element__r.id =:eid AND Catalog__c =:curr_catalog.id Order By name ];
    return tmpLst2;

}
    public pageReference refreshFormTree(){
            formTree = new TMN_Tree();
            list<Clinical_Catalog_Tree_Node__c> curActive = updateSelected(CurEley.id);
            currentInsertedNodes = curActive;
            system.debug('here -' + curActive );
            list<string> myType = new list<string>();
            string curEleyType = CurEley.Type__c;
            if(curEleyType  == 'Action'){
                myType.add('Objective');
                myType.add('Goal');
            }
            if(curEleyType  == 'Objective'){
                myType.add('Goal');
            }        
            if(curEleyType  == 'Goal'){
                return null;
            }
                
        list<Clinical_Catalog_Tree_Node__c> tmpNodes = new list<Clinical_Catalog_Tree_Node__c>(); 
        tmpNodes = [select id, name, ID_Goal__c, ID_Objective__c, ID_Action__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, status__c from Clinical_Catalog_Tree_Node__c Where Catalog_Element__r.type__c in :mytype AND Catalog__c =:curr_catalog.id Order By ID_Goal__c , ID_Objective__c , ID_Action__c ];
        
        
        string goalID ='';
        string objID ='';
        for(Clinical_Catalog_Tree_Node__c n: tmpNodes ){            
            string thisEleType = n.Catalog_Element__r.type__c;
            string thisID = n.name;
            string thisTitle = n.Catalog_Element__r.description__c;
            
            if(thisEleType == 'Goal'){
                TMN_Tree.node g_node= new TMN_Tree.node(thisID , thisTitle );
                g_node.CatTreeNode = n;
                //an action is related to an objective, the goal checkbox needs to be deactivated
                if(curEleyType =='Action'){
                    g_node.hideCheckbox = true;
                    g_node.isFolder = true;
                }
                if(curEleyType =='Objective' ){
                    for(Clinical_Catalog_Tree_Node__c selectedN: curActive ){
                        if(n.ID_Goal__c == selectedN.ID_Goal__c){
                            g_node.CatTreeNode = selectedN;
                            g_node.isSelected = true;
                        }
                    }
                }
                formTree.root.nodes.add(g_node);
                goalID = thisID ;
            }
        
            if(thisEleType == 'Objective'){
                TMN_Tree.node o_node= new TMN_Tree.node(thisID , thisTitle );
                o_node.CatTreeNode = n;
                if(curEleyType =='Action' ){
                    for(Clinical_Catalog_Tree_Node__c selectedN: curActive ){
                        if((n.ID_Goal__c == selectedN.ID_Goal__c)&&(n.ID_Objective__c == selectedN.ID_Objective__c)){
                                o_node.CatTreeNode = selectedN;
                                o_node.isSelected = true;
                            }
                        }
                 }                    
                 integer g_key = allGoals.root.getNode_Key(goalID );
                 formTree.root.nodes.get(g_key).nodes.add(o_node);
                 objID = thisID ;
            }
        }              
        selectedKeys = formTree.GetSelectedNodeStr;
        return null;
    }
    
    private void ctlgCmpntTypes(){
        pickList = new List<SelectOption>();
        pickList.add(new SelectOption('','--None--'));
        ctlgHasABI = isABIpresent(); 
        if (ctlgHasABI){
            pickList.add(new SelectOption('Goal','Problem'));
            pickList.add(new SelectOption('Objective','Goal'));
            pickList.add(new SelectOption('Action','Intervention'));            
        } else {
            pickList.add(new SelectOption('Goal','Goal'));
            pickList.add(new SelectOption('Objective','Objective'));
            pickList.add(new SelectOption('Action','Action'));
        }
    }
    
    private boolean isABIpresent(){
        boolean isABI = false;
        List<Clinical_Catalog_Program__c> selPrgrms = [select id, Name, Clinical_Catalog__c, Program_Custom_Setting__c from Clinical_Catalog_Program__c where Clinical_Catalog__c = :curr_catalog.Id];
        List<Clinical_Programs__c> allPrgms = Clinical_Programs__c.getall().values();

        for (Clinical_Catalog_Program__c prg :selPrgrms){
            for (Clinical_Programs__c p :allPrgms){
                if (prg.Program_Custom_Setting__c == p.ProgramID__c && p.Program_Name__c.contains('ABI') ){
                    isABI = true;
                    break;
                }
            }
            if (isABI){
                break;
            }
        }
        return isABI;
    }
    
    
    
    
    
    //goal ends
    public string RTid;
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public Id AZ_OPT_ID, SHIFT_NOTE_ID;
    public String pbsName { get; set; }
    Public Boolean AsmntOnly{get;set;}
    private string usrOpGrp;
    Public Id insertedProgressNoteId{get;set;}

    public list<SelectOption> rtOptions = new list<SelectOption>();
    public list<SelectOption> getrtOptions(){return rtOptions ;}
    
    // ADDED FOR WVPN-6 to give us a way to identify RecordType default for unsaved note when only one Record Type option is present.
    // J. Gilliam, 3/19/14.
    public RecordType defaultRt { get; set; }

    private Final Progress_Note__c pn;
    public boolean displayPopup {get; set;}     
    //goal starts 
    
    //goal ends
    
    
    public Progress_Note__c thePN = new Progress_Note__c();
    public Progress_Note__c getthePN(){return thePN;}
    public List<Progress_Note__c> pnOverlap {get; set;} 
    // SHAUN-40 - update to only show overlap for AZ-OPT notes - 09/05/2014
    public boolean hasOverlap {get { return (pnOverlap.size() > 0 && thePN.recordtype.developername == 'AZ_OPT');} }
    
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c, Person_Being_Served__r.Name,next_approver__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername from Progress_Note__c where id= :tmp.id limit 1];
        
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
        String dispMode = ApexPages.currentPage().getParameters().get('Mode');
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
            
            // EC-196 - CM uses Shift Notes 
           //if ( usrOpGrp == 'Care Meridian')
            //  pn.RecordTypeId = SHIFT_NOTE_ID;
            
            //Added By Amruth for EB-436
            if(sa.recordtype.name == 'Assessment Only' && currUser != null && currUser.Operating_Group__c == 'NeuroRestorative'){
                AsmntOnly = true;
            }   
            
            
            // get the user's operating group
            //TMN_User__c currUserTMN = [ select operating_group__c from TMN_User__c where Salesforce_User_Account__c = :UserInfo.getUserId() LIMIT 1];
            
            System.Debug('user op group is: ' + currUser.Operating_Group__c );
            if (currUser != null ) {
                if (( myState == 'MN' || myState == 'IN' || myState == 'CA') && currUser.Operating_Group__c == 'Redwood') {
                    pn.RecordTypeId = SHIFT_NOTE_ID;
                    // special case for CM Ludlow is handled above in AZ
                }
            } else {
                // add error to page that shift note cannot be created
            }
            
            //EC-196 - skip this step for CM
            //if (  usrOpGrp != 'Care Meridian')
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
        else if( dispMode == 'Edit'){
         
         //Goal  Starts
         
         //curr_catalog = (Clinical_Catalog__c)controller.getRecord();
        
        if (curr_catalog == null){
            curr_catalog = new Clinical_Catalog__c();   
        }        
        selectedKeys ='';
        CurEley = new Clinical_Catalog_Element__c ();
        currentInsertedNodes = new list<Clinical_Catalog_Tree_Node__c >();
        ctlgCmpntTypes();
        retrieveAllGoals();
         
         
         //Goal Ends
         
         
         insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
         progress_note__c pn = [select Service_Assignment__c ,Signature_on_File__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
         this.thePN = pn;
         SignedDoc = pn.Signature_on_File__c;
         pnOverlap = new List<Progress_Note__c>();
         theServAssignId =  Pn.Service_Assignment__c ;
         pbsName = pn.Service_Assignment__r.Person_Being_Served__c;
         admissionId = pn.Service_Assignment__r.Admission__c;  
         ActivePlanId = pn.Action_Plan__c;
          //goal   
        
        
        }
   		else if (dispMode == 'Inlineedit'){
            NewBlock = true;
            inlinemode = true;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
            pn = (Progress_Note__c) controller.getRecord();
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
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
        pagereference pagref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Inlineedit&id='+ApexPages.currentPage().getParameters().get('id'));
        pagref.setredirect(true);
        return pagref;
    } 
    
    public pagereference saveModifiedProgressNote(){
       pn.recordtypeid = AZ_OPT_ID ; 
       pn.Person_Being_Served__c = pbsName;
       pn.admission__c = admissionId;
       pn.Service_Assignment__c = theServAssignId;
       pn.Action_Plan__c = ActivePlanId;
       update pn;
       insertedProgressNoteId = pn.Id;
       newBlock = false;
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id);
       pageref.setredirect(true);
       return pageref;
        
    } 
    
    public pagereference cancelEditNote(){
        newBlock = false; 
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id+'&sfdc.override=1');
        pageref.setredirect(true);
        return pageref;
    } 
    
    public pagereference saveProgressNote(){
       //pn.start_time__C = date.today();
       pn.recordtypeid = AZ_OPT_ID ;
       pn.Person_Being_Served__c = theServAssign.Person_Being_Served__c;
       pn.admission__c = theServAssign.Admission__c;
       pn.Service_Assignment__c = theServAssign.Id;
       pn.Action_Plan__c = ActivePlanId;
       insert pn;
       insertedProgressNoteId = pn.Id;
       newBlock = false;
       pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_AZ_OPT?Mode=Edit&id='+pn.id+'&sfdc.override=1');
       pageref.setredirect(true);
       return pageref;
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
        //important - normalize the strings to lower case
        myState=myState.toLowerCase();
        
        //create record type selection option there is an escape option so is the filter is incorrect as a short term messure -go to the url and remove state in the VF page | (state=) < null or blank |
        SelectOption SO;
       // SelectOption SO2;
        
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
            
            //Added by Amruth
            if( AsmntOnly && myname == 'therapy'){
                    SO = new SelectOption(thisRt.Id, thisRt.Name);
                    rtOptions.Add(SO);
            }
            
        }
        
        // START: ADDED FOR WVPN-6; default selection if only one record type is present on the page (J. Gilliam, 3/19/14)
        if(rtOptions.size()==1) {
            Id defaultRtId;
            for(SelectOption o : rtOptions) {
                defaultRtId = o.getValue();
            }
            defaultRt = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :defaultRtId ];
            pn.RecordTypeId = defaultRt.Id;
        }
        // END: ADDED FOR WVPN-6; default selection if only one record type is present on the page (J. Gilliam, 3/19/14)


        // WVPN-6
        // GET RECORD TYPES THAT SHOULD HAVE DEFAULT 0 FOR pn.Number_Of_Required_Signatures__c
        List<RecordType> rtsForZeroSigs = new List<RecordType>();
        rtsForZeroSigs = [ SELECT Name, DeveloperName FROM RecordType WHERE DeveloperName = 'IN_FCT' OR DeveloperName = 'MA_FCT'
                            OR DeveloperName = 'MD_FCT' OR DeveloperName = 'OH_FCT' Or Name = 'Therapy'];
        // LOOP THROUGH THOSE RECORD TYPES AND COMPARE TO RECORD TYPES OF THIS NOTE.  IF SAME, THEN DEFAULT SIGS TO 0
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
    
    
    
    ///goal starts
    
    
// goal ends



}