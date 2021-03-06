public with sharing class Notes_ProgressNote_CaseManagementExt {
 public Service_Assignment__c theServAssign { get; set; }  
    public Id theServAssignId { get; set; }
    public boolean inlinemode{get; set;} 
    public Id admissionId { get; set; }
    Public String PersonSelectedIds{get;set;}
    Public String ModeofPage{get;set;}
    public Boolean NewBlock{get;set;}
    public boolean displayPopupComp {get; set;}     
    public string ContactName{get;set;}
    public string AdmName{get;set;}
    public string srvcLocationName{get;set;}
    public string ServName{get;set;}
    public string SignedDoc {get;set;}
    public string HomePageData{get;set;}
    public string SrvcLoc {get;set;}
    public boolean updatePBs{get;set;}
    public boolean otCode {get;set;}
    Public String relatedpbstring{get;set;}
    public boolean canDisregard {get;set;}
    public id ProcessId{get;set;}
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    Public string ErrorMsg{get;set;}
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public string selectedKeys{get; set;}
    public list <TMN_User__c> cuUser = [SELECT Id, Discipline__c FROM TMN_User__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
    public string pbsName { get; set; }
    public Id insertedProgressNoteId{get;set;}
    //private Final Progress_Note__c pn;
    public progress_note__c pn{get;set;}
    Public boolean ShowPBS{get;set;}
    public boolean displayPopup {get; set;} 
    public boolean displayPopupFinalize{get; set;}     
    public Progress_Note__c thePN = new Progress_Note__c(Start_Time__c=system.today());
    public Progress_Note__c getthePN(){return thePN;}
    public String searchResultPBS { get; set; }
    public String searchResultSA { get; set; }
    public date eventDate {get; set;}
    
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c,Person_Being_Served__r.Name,Approval_User__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername, Locked__c from Progress_Note__c where id= :tmp.id limit 1];
        
    }
    /**Called when Submit for Approval Button Is Clicked, Added In code as the Standard Approval 
    process Was adding an additional page , where user used to select the next Approver**/
    public pagereference SubmitForApp(){
    	if (thePN.Approval_User__c == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose an Approver'));
			return null;
		}
    	insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
    	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(insertedProgressNoteId);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Progress_Notes_Approval');
        req1.setSkipEntryCriteria(true);
        list<id> listids = new list<id>();
        listids.add(thePN.Approval_User__c);
        req1.setNextApproverIds(listids);
        try{
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
        }

        //pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_Create_Flavor_PDF?id='+insertedProgressNoteId+'&IsSubmitted=CMYes');
        pagereference pageref = new Pagereference('/apex/Notes_Progressnote_CaseManagement?Mode=Edit&id='+pn.id);
        pageref.setredirect(true);
        return pageref;
    }
    
    /** Disregard Code for added custom button**/
    public PageReference disregardNote(){
            
            // Get the integrate account user ID to make the owner of the task.
            User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
            Id integrateUserId = integrateUser.Id;
            
            // CTEAE-73  fix datetime format on task info
            DateTime n = DateTime.now();
            
            Boolean resetLocked = thePN.Locked__c;
            
            // briefly unlock to get around validation rule
            if (resetLocked) {
                thePN.No_Approval_Needed__c  = false;
                thePN.Locked__c  = false;
                update thePN;
            }
            
            pn.Disregard_Note__c = true;
            if (resetLocked)
                thePN.No_Approval_Needed__c  = resetLocked;
            update thePN;
            // Create a task reminder that indicates who marked the Progress Note as one to "Disregard."
            Task t = new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = pn.Person_Being_Served__c, WhatId = pn.Id, ActivityDate = n.date());
            insert t;

			return new PageReference('/' + thePN.Id);
    }

    public PageReference myFinal(){
    	displayPopup = false;

        try{
            update thePN;
        }
            catch(DMLException e){
                thePN.addError(e.getMessage());
            }      
        
         pagereference pageref = new Pagereference('/apex/Notes_Progressnote_CaseManagement?Mode=Edit&id='+pn.id);
        pageref.setredirect(true);
        return pageref;
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
        if(pnValidations[0].status__c == 'Final'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note has already been finalized.'));  
        }
        if(pnValidations[0].Approval_Status__c == 'Pending'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'This Progress Note is pending approval.')); 
        }
    }    
     
    /** Finalize Validations And then rendering of the finalize popup on the screen Logic**/ 
    public pagereference showPopup() { 
        list<progress_note__c> pnValidations = [SELECT Id, service_location__c,RW_Signature_required__c,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c,type__c, status__c, recordtype.Name,Service_code__c,People_Present__c,Approval_User__c, Clinician__c,
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Therapy_Discipline__c,Number_of_Required_Signatures__c ,Signature_on_File__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        if(pnValidations[0].RW_Signature_required__c == true && pnValidations[0].Signature_on_File__c =='N'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'E-Signature is required before finalizing the note')); 
            return null;
        }
        else if( pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' ) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Note has already been submitted')); 
            return null;
        }
        else{
            displayPopup = true; 
            LoadData(thePN);
            return null;
        } 
    }
    
    /**Esign Validation **/ 
    public pagereference validateesign(){
        
       return null;
    }
    
    public Notes_ProgressNote_CaseManagementExt(ApexPages.StandardController controller){
        if (!Test.isRunningTest()) {
                controller.addFields(new string[] {'RecordType.Name', 'Service_Assignment__r.Start_Date__c', 'Service_Assignment__r.End_Date__c'});
         }
       	pn = (Progress_Note__c) controller.getRecord();
       	pn.RecordtypeId = Schema.SObjectType.Progress_Note__c.getRecordTypeInfosByName().get('RW Case Management').getRecordTypeId();
        ErrorMsg ='';
    	otCode=false;
        string dispMode = ApexPages.currentPage().getParameters().get('Mode');
        ModeofPage = dispMode;
        if (dispMode =='Edit'){
            displayPopupFinalize = false;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
            list<ProcessInstanceWorkitem> ProcessList = New list<ProcessInstanceWorkitem>();
            ProcessList = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: insertedProgressNoteId ];
            if(processlist.size()>0){
                ProcessId = ProcessList[0].Id;
            }
            List<String> OldIds = New List<String>();
            list<string> finallisttocreate = new list<string>();
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Signature_on_File__c ,Service_Location__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            eventDate =  pnedit.Start_time__c.date();
            SignedDoc = pnedit.Signature_on_File__c;
            SrvcLoc = pnedit.Service_Location__c;
            if(pn.Service_Assignment__c!=Null)
            theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :pn.Service_Assignment__c];
            if(test.isrunningTest())
            theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.name,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :ApexPages.currentPage().getParameters().get('ServAssignId') ];
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
        }//End Edit Mode Block
        inlinemode = false;
        if(dispMode == 'New'){
            //important - normalize the strings to lower case
        myState=myState.toLowerCase();
            NewBlock = true;
            string pbsId = ApexPages.currentPage().getParameters().get('person');
            if (!string.isBlank(pbsId)) {
                pbsname = [SELECT Name FROM Contact WHERE Id=:pbsId].Name;
            }
            pn.Start_Time__c = system.now();
            eventDate =  pn.Start_time__c.date();
            String programId ;
            if( ApexPages.currentPage() != null){
                theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.name,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :ApexPages.currentPage().getParameters().get('ServAssignId') ];
                theServAssignId = theServAssign.Id;
                pbsName = theServAssign.Person_Being_Served__c;
                programid = theServAssign.service_location__r.programid__c;
                admissionId = theServAssign.Admission__c;
                ContactName = theServAssign.Person_Being_Served__r.name;
                AdmName = theServAssign.Admission__r.name;
                servname = theServAssign.Name;
            }
            if(pn.id == null){
        	pn.Number_of_Required_Signatures__c = 0;
      		}
                
        }
        else if (dispMode == 'Inlineedit'){
            NewBlock = true;
            inlinemode = true;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,owner.name,Person_Being_Served__r.Name,Approval_User__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            if(pn.Service_Assignment__c!=Null)
            theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :pn.Service_Assignment__c];
            theServAssignId =  pnedit.Service_Assignment__c ;
            eventDate =  pnedit.Start_time__c.date();
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
            ContactName = pnedit.Service_Assignment__r.Person_Being_Served__r.Name;
        }//End Inline Edit Mode Block
    }//End Constructor Method
     
    /**Method called onclick edit button on Edit Page**/
    public pagereference editInline(){
        newBlock = false; 
        pagereference pagref = new Pagereference('/apex/Notes_Progressnote_CaseManagement?Mode=Inlineedit&id='+ApexPages.currentPage().getParameters().get('id'));
        pagref.setredirect(true);
        return pagref;
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
    /** Method called onclick Save on New Progress Note Page**/
    public pagereference saveProgressNote(){
        commonValidations();
        if(ModeofPage == 'New'){
            return null; 
        }else{
            pn.Person_Being_Served__c = pbsName;
            pn.admission__c = admissionId;
            pn.Service_Assignment__c = theServAssignId;
            try {
                update pn;
            }
            catch (Exception e) {
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
                return null;
            }
            insertedProgressNoteId = pn.Id;
            newBlock = false;
            pagereference pageref = new Pagereference('/apex/Notes_Progressnote_CaseManagement?Mode=Edit&id='+pn.id);
            pageref.setredirect(true);
            return pageref;
        }
    }
    
    
    Public Pagereference commonValidations(){
        ErrorMsg = '';
        if ( pn.start_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Start time is required.'));
            ErrorMsg = ErrorMsg + 'Required';
            return null;
        } 

        if((pn.Date_of_Service__c > system.today()) || ( pn.start_Time__c > system.NOW() )){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - All service dates and times must have occurred in the past. Please check your dates and try again.'));     
            ErrorMsg = ErrorMsg + 'Start,End Time Past';
            return null;
        }
        if(pn.Start_Time__c > system.now()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Start time cannot be in the future'));     
            ErrorMsg = ErrorMsg + 'Start time future';
            return null;
        }
        if(theservAssign != Null && ((theservAssign.Start_Date__c > pn.Start_Time__c.date()))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.'));     
            ErrorMsg = ErrorMsg + 'Date Range Incorrect';
            return null;
        }
        if(pn.Purpose_Service_is_Billable__c == true && pn.CM_Billable_Category__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose a billable category'));
            ErrorMsg = ErrorMsg + 'Billable category';
            return null;    
        }
        if(pn.Type_of_Contact__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose a Type of contact'));
            ErrorMsg = ErrorMsg + 'Type of contact';
            return null;    
        }
        if(pn.Narrative__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill in Narrative'));
            ErrorMsg = ErrorMsg + 'Narrative';
            return null;    
        }
        return null;
    }

     public pagereference RenderSelectedIds(){
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
        pn.Person_Being_Served__c = pbsName;
        pn.admission__c = admissionId;
        pn.Service_Assignment__c = theServAssignId;
        Date dToday =   eventDate;
        Datetime dt = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
        dt = dt.addHours(4);
        pn.Start_Time__c = dt;
        commonValidations();
        if(ErrorMsg != ''){
            return null;
        }
        try {
            upsert pn;
            insertedProgressNoteId = pn.Id;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));     
            return null;
        }
        newBlock = false;
        pagereference pageref = new Pagereference('/apex/Notes_Progressnote_CaseManagement?Mode=Edit&id='+pn.id);
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
    
    transient public List<ProcessInstanceHistory> approvalHistory;
		public List<ProcessInstanceHistory> getApprovalHistory () {
		approvalHIstory = new List<ProcessInstanceHistory>();
		List<ProcessInstance> pi = [
			SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate
			              FROM StepsAndWorkitems
			            ORDER BY IsPending DESC, createddate desc)
			FROM ProcessInstance where  targetobjectid = :thePn.Id
			ORDER BY createddate desc];

		for ( ProcessInstance p : pi ) {
			approvalHistory.addAll (p.stepsandworkitems);
		}
		return approvalHistory;

    }
    
}