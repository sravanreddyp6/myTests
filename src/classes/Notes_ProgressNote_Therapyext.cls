public with sharing class Notes_ProgressNote_Therapyext {
    public Service_Assignment__c theServAssign { get; set; }
    public Id theServAssignId { get; set; }
    public boolean inlinemode{get; set;} 
    public Id admissionId { get; set; }
    Public String ModeofPage{get;set;}
    public Boolean NewBlock{get;set;}
    public boolean displayPopupComp {get; set;}     
    public string ContactName{get;set;}
    public string AdmName{get;set;}
    public string ServName{get;set;}
    public string SignedDoc {get;set;}
    public string SrvcLoc {get;set;}
    public boolean otCode {get;set;}
    public boolean canDisregard {get;set;}
    public id Thrapyid {get;set;}
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    Public string ErrorMsg{get;set;}
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public string selectedKeys{get; set;}
    public list <TMN_User__c> cuUser = [SELECT Id FROM TMN_User__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
    public string pbsName { get; set; }
    public Id insertedProgressNoteId{get;set;}
    private Final Progress_Note__c pn;
    public boolean displayPopup {get; set;} 
    public boolean displayPopupFinalize{get; set;}     
    public Progress_Note__c thePN = new Progress_Note__c(Start_Time__c=Datetime.now(),End_Time__c=Datetime.now());
    public Progress_Note__c getthePN(){return thePN;}
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c,Person_Being_Served__r.Name,Approval_User__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername from Progress_Note__c where id= :tmp.id limit 1];
        
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
        try{
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
            return null;
        }
        pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_Create_Flavor_PDF?id='+thePn.id+'&IsSubmitted=Yes');
        pageref.setredirect(true);
        return pageref;
    }
    
    /** Disregard Code for added custom button**/
    public PageReference disregardNote(){
		
			Boolean resetLocked = pn.Locked__c;
			
			// briefly unlock to get around validation rule
			if (resetLocked) {
				pn.No_Approval_Needed__c  = false;
				pn.Locked__c  = false;
				update thePN;
			}
			
			pn.Purpose_Service_is_Billable__c = false;
			pn.Disregard_Note__c = true;
			if (resetLocked)
				pn.No_Approval_Needed__c  = resetLocked;
			update pn;
			System.Debug('turned off billable: ' + pn);

            // Create a task reminder that indicates who marked the Progress Note as one to "Disregard."
            // Get the integrate account user ID to make the owner of the task.
            
            User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
            Id integrateUserId = integrateUser.Id;
            
            // CTEAE-73  fix datetime format on task info
            DateTime n = DateTime.now();
            Task t = new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = pn.Person_Being_Served__c, WhatId = pn.Id, ActivityDate = n.date());
            insert t;

			return new PageReference('/' + thePN.Id);
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
        if(pnValidations[0].Service_Location__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Location before continuing.'));   
        }
        if(pnValidations[0].Type_of_Contact__c == Null ||pnValidations[0].Type_of_Contact__c == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select the Type of Contact before continuing.'));  
        }
        if(pnValidations[0].Service_code__c == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Code before continuing.'));  
        }
        if(pnValidations[0].Type__c == 'Co-Treatment' && pnValidations[0].Clinician__c == null ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter CO-TREATMENT THERAPIST if the type of treatment is co-treatment'));    
        }
        if(pnValidations[0].Type_of_Contact__c == 'Face-To-Face' && pnValidations[0].Type__c == null ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'If type of contact is face to face , then type of treatment needs to be selected'));    
        }
        if(pnValidations[0].Therapy_Discipline__c  == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose a therapy discipline before finalizing'));  
        }
    }    
    
    /**Esign Validation **/ 
    public pagereference validateesign(){
        list<progress_note__c> pnValidations = [SELECT Id, service_location__C,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c, end_time__c, status__c, recordtype.Name,Service_code__c,People_Present__c,Approval_User__c, 
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Action_plan__c,Number_of_Required_Signatures__c ,Signature_on_File__c,Clinician__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        if( pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' || pnValidations[0].Action_plan__c == Null ||(pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0)||pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || pnValidations[0].Service_code__c == Null ||pnValidations[0].Interventions__c== Null || pnValidations[0].Notes_For_Next_Visit__c == Null  || pnValidations[0].progress__c == Null || pnValidations[0].Type_of_Contact__c == '' || pnValidations[0].progress__c == '' || pnValidations[0].Interventions__c== '') {
            validateFinalizeEsign(pnValidations,'NoGoal');
       }return null;
    }
     
    /** Finalize Validations And then rendering of the finalize popup on the screen Logic**/ 
    public pagereference showPopup() { 
        list<progress_note__c> pnValidations = [SELECT Id, service_location__C,Approval_Status__c,Type_of_Contact__c, 
                Person_being_served__r.Name, start_time__c, end_time__c,type__c, status__c, recordtype.Name,Service_code__c,People_Present__c,Approval_User__c, Clinician__c,
                Interventions__c, progress__c,Notes_For_Next_Visit__c,Therapy_Discipline__c,Number_of_Required_Signatures__c ,Signature_on_File__c,
                Owner.Name from Progress_Note__c
                where id =:thePn.Id];
        if( pnValidations[0].status__c == 'Final' || pnValidations[0].Approval_Status__c == 'Pending' ||pnValidations[0].Service_Location__c == Null || pnValidations[0].Type_of_Contact__c == Null || pnValidations[0].Service_code__c == Null || pnValidations[0].Type_of_Contact__c == ''
        ||(pnValidations[0].Type__c == 'Co-Treatment' && pnValidations[0].Clinician__c == null )||(pnValidations[0].Type_of_Contact__c == 'Face-To-Face' && pnValidations[0].Type__c == null )||(pnValidations[0].Therapy_Discipline__c  == Null)) {
            validateFinalizeEsign(pnValidations,'NoGoal');
            /*if(pnValidations[0].Signature_on_File__c != 'Y' && pnValidations[0].Number_of_Required_Signatures__c > 0 ){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Progress Note cannot be finalized without an Electronic Signature attached to the Progress Note. Please esign the document prior to finalization.'));  
            }*/
            return null;
        }
        else{
            displayPopup = true; 
            LoadData(thePN);
            return null;
        } 
    }
    
    public Notes_ProgressNote_Therapyext(ApexPages.StandardController controller){
      	if (!Test.isRunningTest()) {
                controller.addFields(new string[] {'RecordType.Name', 'Service_Assignment__r.Start_Date__c', 'Service_Assignment__r.End_Date__c'});
         }
       	pn = (Progress_Note__c) controller.getRecord();
       	pn.RecordtypeId = Schema.SObjectType.Progress_Note__c.getRecordTypeInfosByName().get('Therapy').getRecordTypeId();
        ErrorMsg ='';
    	otCode=false;
    	canDisregard = false;
    	PermissionSetAssignment[] assignments = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Name);
		}
		if (permissionSets.contains('ESD_Notes_Case_Handler_NR_Carbondale')){
			canDisregard = true;
		} 
		else {
			canDisregard = false;
		}
        string dispMode = ApexPages.currentPage().getParameters().get('Mode');
        ModeofPage = dispMode;
        if (dispMode =='Edit'){
            displayPopupFinalize = false;
            insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
            system.debug('------'+insertedProgressNoteId);
            List<String> OldIds = New List<String>();
            list<string> finallisttocreate = new list<string>();

            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Signature_on_File__c ,Service_Location__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            SignedDoc = pnedit.Signature_on_File__c;
            SrvcLoc = pnedit.Service_Location__c;
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
            pn.Start_Time__c = datetime.now();
            pn.End_Time__c = datetime.now();
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
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            if(pn.Service_Assignment__c!=Null)
            theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :pn.Service_Assignment__c];
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            admissionId = pnedit.Service_Assignment__r.Admission__c;  
            ContactName = pnedit.Service_Assignment__r.Person_Being_Served__r.Name;
        }//End Inline Edit Mode Block
        saveSVC();
    }//End Constructor Method
     
    /**Method called onclick edit button on Edit Page**/
    public pagereference editInline(){
        newBlock = false; 
        pagereference pagref = new Pagereference('/apex/Notes_Progressnote_Therapy?Mode=Inlineedit&id='+ApexPages.currentPage().getParameters().get('id'));
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
    
    public void popTherapist(){
      list <TMN_User__c> therapist1 = [SELECT Id, Discipline__c FROM TMN_User__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
      
      if(pn.Type__c == 'Individual'){
        pn.Clinician__c = therapist1[0].id;
        pn.Therapy_Discipline__c = therapist1[0].Discipline__c;
      }
      else{
        pn.Clinician__c =null;
        pn.Therapy_Discipline__c = null;
      }
    }
    public void popDiscipline(){
      if(pn.Type__c == 'Co-Treatment' && pn.Clinician__c !=null){
        list <TMN_User__c> therapist2 = [SELECT Id, Discipline__c FROM TMN_User__c where id = :pn.Clinician__c LIMIT 1];
        pn.Therapy_Discipline__c = therapist2[0].Discipline__c;
      }
      else{
        pn.Clinician__c =null;
        pn.Therapy_Discipline__c = null;
      }
    }
    public void saveSVC(){
      List<Service_Code__c> svcList= [SELECT id, Service_Value__c from Service_code__C where id=:pn.Service_code__c and Service_Value__c = 'OTHER-Other' LIMIT 1];
      if(svcList.size()>0){
        otCode = true;
      }
      else
      otCode= false;
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
            pagereference pageref = new Pagereference('/apex/Notes_Progressnote_Therapy?Mode=Edit&id='+pn.id +'&SelectedKey='+ '' +'&DeselectedKey='+ '' );
            pageref.setredirect(true);
            return pageref;
        }
    }
    
    
    Public Pagereference commonValidations(){
        ErrorMsg = '';
        if(theservAssign.End_Date__c!=null && (system.today() > theservAssign.End_Date__c.addDays(14))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Therapy note can be entered only upto 2 weeks after discharge'));     
            ErrorMsg = ErrorMsg + 'Late Entry';
            return null;
        }
        if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start and end dates and times required.'));     
            ErrorMsg = ErrorMsg + 'Required';
            return null;
        }
        if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your start and end times must differ.'));     
            ErrorMsg = ErrorMsg + 'Same Times';
            return null;
        } 
        if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start date/time must be before end/date time'));     
            ErrorMsg = ErrorMsg + 'Start Time Greater';
            return null;
        }
        if((pn.Date_of_Service__c > system.today()) || ( pn.start_Time__c > system.NOW() ) || ( pn.End_Time__c > system.NOW() )){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'All service dates and times must have occurred in the past. Please check your dates and try again.'));     
            ErrorMsg = ErrorMsg + 'Start,End Time Past';
            return null;
        }
        if(pn.Start_Time__c > system.now()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start time cannot be in the future'));     
            ErrorMsg = ErrorMsg + 'Start time future';
            return null;
        }
        if(theservAssign != Null && ((theservAssign.Start_Date__c > pn.Start_Time__c.date()) || ( theservassign.Start_Date__c > pn.End_Time__c.date()))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.'));     
            ErrorMsg = ErrorMsg + 'Date Range Incorrect';
            return null;
        }
    if(theservAssign != Null && theservassign.End_Date__c!=Null && ((theservassign.End_Date__c < pn.Start_Time__c.date()) || (theservassign.End_Date__c < pn.End_Time__c.date()))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.'));     
            ErrorMsg = ErrorMsg + 'Date Range Incorrect';
            return null;
        }
       if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy'));     
            ErrorMsg = ErrorMsg + 'More Than 120';
            return null;
        } 
        if(pn.Type__c=='Co-Treatment' && pn.Clinician__c==cuUser[0].id){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'When Type of Treatment is Co-Treatment, you cannot select yourself as the therapist'));     
            ErrorMsg = ErrorMsg + 'Self Therapist';
            return null;
        }
        if(pn.id==null && pn.Purpose_Service_is_Billable__c == true){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'For Therapy, the Purpose/Service is Billable field must be unchecked. Please un check that field and try again.'));
          ErrorMsg = ErrorMsg + 'Billable';
            return null;
        }
        if(pn.Service_Code__c==null){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Service Code before continuing.'));
          ErrorMsg = ErrorMsg + 'No Service Code';
            return null;
        }

        return null;
    }
    
    public pagereference RenderSelectedIds(){
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id'); 
        pn.Person_Being_Served__c = pbsName;
        pn.admission__c = admissionId;
        pn.Service_Assignment__c = theServAssignId;
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
        pagereference pageref = new Pagereference('/apex/Notes_Progressnote_Therapy?Mode=Edit&id='+pn.id);
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
}