public with sharing class Notes_ProgressNote_AZ_OPT {
    public Progress_Note__c CurrentRecord {get; set;} 
    public Service_Assignment__c theServAssign { get; set; }
    public Id theServAssignId { get; set; }
    public boolean editmode{get; set;}  
    public boolean savemode{get; set;}
    Public Id ActivePlanId{get;set;}
    public Admission__c admission { get; set; }
    public Id admissionId { get; set; }
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    Public Boolean NewBlock{get;set;}
    Public String ContactName{get;set;}
    public ApexPages.StandardController stdCtrl {get; set;}
    
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
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Action_plan__c,
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
        pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || /**pnValidations[0].Service_code__c == Null ||**/
        pnValidations[0].Interventions__c== Null || pnValidations[0].Notes_For_Next_Visit__c == Null  || pnValidations[0].progress__c == Null || pnValidations[0].Type_of_Contact__c == '' || pnValidations[0].progress__c == '' || pnValidations[0].Interventions__c== '') {
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
            //if(pnValidations[0].Service_code__c == Null){
            //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Code before continuing.'));  
            //}
            if(pnValidations[0].Interventions__c== Null|| pnValidations[0].Interventions__c== ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Intervention field before continuing.'));    
            }
            if(pnValidations[0].Notes_For_Next_Visit__c == Null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Notes For Next Visit field before continuing.'));  
            }
            if(pnValidations[0].progress__c == Null|| pnValidations[0].progress__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must populate the Progress field before continuing.'));  
            
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
         
         insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
         progress_note__c pn = [select Service_Assignment__c ,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
         this.thePN = pn;
         pnOverlap = new List<Progress_Note__c>();
         theServAssignId =  Pn.Service_Assignment__c ;
         pbsName = pn.Service_Assignment__r.Person_Being_Served__c;
         admissionId = pn.Service_Assignment__r.Admission__c;  
         ActivePlanId = pn.Action_Plan__c;
            
        }
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
}