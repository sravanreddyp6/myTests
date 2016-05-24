public with sharing class Notes_ProgressNote_Therapyext {
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
    public string ServName{get;set;}
    public string SignedDoc {get;set;}
    public string HomePageData{get;set;}
    public string SrvcLoc {get;set;}
    public boolean updatePBs{get;set;}
    public boolean otCode {get;set;}
    Public String relatedpbstring{get;set;}
    public boolean canDisregard {get;set;}
    public id Thrapyid {get;set;}
    public id ProcessId{get;set;}
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}
    Public string ErrorMsg{get;set;}
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public string selectedKeys{get; set;}
    public list <TMN_User__c> cuUser = [SELECT Id, Discipline__c FROM TMN_User__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
    public string pbsName { get; set; }
    public Id insertedProgressNoteId{get;set;}
    private Final Progress_Note__c pn;
    public boolean displayPopup {get; set;} 
    public boolean displayPopupFinalize{get; set;}     
    public Progress_Note__c thePN = new Progress_Note__c(Start_Time__c=Datetime.now(),End_Time__c=Datetime.now());
    public Progress_Note__c getthePN(){return thePN;}
    
    @RemoteAction public static list<SelOption> getPBS(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        list<SelOption> retVal = new list<SelOption>();
        for(Service_Assignment__c t: [SELECT Id, Person_Being_Served__c,pbsLastName__c, pbsFirstName__c,  person_Being_served__r.name, 
            admission__c, Service_Location__r.location_nickname__c,  service_location__r.state__c,
            service_location__r.alias_lookup__r.Alias_Operating_Group__c,
            Service_Location__r.Alias__c, admission__r.state__c, name, recordtype.developername,
            status__c, end_date__c, service_location__r.tmn_scope__c,Flavor__c FROM Service_Assignment__c where status__c = : 'Active' 
            and (Flavor__c like: ('Neuro'+'%')) and
            (pbsFirstName__c like : searchTerm OR pbsLastName__c like : searchTerm) order by Name]){
            retVal.add(new SelOption(t));
        }
        return retVal;
    }
    public class SelOption {
        String id;
        String text;
        String email;
        String jobTitle;
        sobject obj;
        SelOption(sobject obj){
            this.id = String.valueOf(obj.get('Id'));
			if (obj instanceof Service_Assignment__c){
            	Service_Assignment__c tmnUser = (Service_Assignment__c) obj;
	            this.text = tmnUser.person_Being_served__r.name + ' ' + tmnUser.Service_Location__r.Alias__c + ' - ' + tmnUser.Service_Location__r.location_nickname__c;
            }
            else if (obj instanceof Service_Assignment__c){
            }
            this.obj = obj;
        }
    }
    public String searchResultPBS { get; set; }
    public String searchResultSA { get; set; }
    
    public List<Service_Assignment__c> getPBSforselect(){
        ID uid = UserInfo.getUserid();
        User u = [ select id, favorite_PBS__c from User where id = :uid LIMIT 1];
        String pbsJoin = u.favorite_PBS__c;
        List<String> favePBS = new List<String>();
        List<String> faveSA = new List<String>();
        searchResultPBS = '';
        searchResultSA = '';   
        if ( pbsJoin != null ) {
            List<String> tmplist = pbsJoin.Split(';');
            for (String tmp : tmplist) { 
                String[] moretmp = tmp.split('-');
                if (moretmp.size() == 2) {
                    favePBS.add(moretmp[0]);
                    searchresultPBS += moretmp[0] + ',';
                    faveSA.add(moretmp[1]);
                    searchresultSA += moretmp[1] + ',';
                }
            }
        }
        List<String> searchPBS = searchResultPBS.split(',');
        List<String> searchSA = searchResultSA.split(',');
        List<Service_Assignment__c> focusPBSList = new list<Service_Assignment__c>();
        if (searchResultPBS.length() == 0)
            return null;
        ELSE{
        focusPBSList = [SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
            admission__c, Service_Location__r.location_nickname__c,  service_location__r.state__c,
            service_location__r.alias_lookup__r.Alias_Operating_Group__c,
            Service_Location__r.Alias__c, admission__r.state__c, name, recordtype.developername,
            status__c, end_date__c, service_location__r.tmn_scope__c,Flavor__c
            FROM Service_Assignment__c WHERE Person_Being_Served__c in :searchPBS
            AND ID in :searchSA 
           ];
        
        }
        
        if((relatedpbstring != '' && relatedpbstring != Null) && ApexPages.currentPage().getParameters().get('Mode')=='New'){
            list<Service_Assignment__c> AllServAssgn = [SELECT Id,name,person_Being_served__r.name,Service_Location__r.Alias__c,Service_Location__r.location_nickname__c FROM Service_Assignment__c where id in: relatedpbstring.split(',') And id !=: theServAssignId];
	        list<Service_Assignment__c> finalSAs = new list<Service_Assignment__c>();
	        IF(focusPBSList.SIZE()>0){
	            for(Service_Assignment__c saAdd:focusPBSList){
	                boolean found = false;
	                for(Service_Assignment__c sa:AllServAssgn){
	                    if(sa.id == saAdd.Id)
	                        found = true;
	                }
	                if(found == false)
	                    AllServAssgn.add(saAdd);
	            }
	            String commaSepratedList='';
                for(Service_Assignment__c slist:AllServAssgn){
	                commaSepratedList += slist.id + ',';
                }
                commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length());
                HomePageData = commaSepratedList;
	        }
	        for(Service_Assignment__c saAdd:AllServAssgn){
	            if(saAdd.id != theServAssignId)
	                finalSAs.add(saAdd);
	        }
	        //AllServAssgn.remove(theServAssign);
	        return finalSAs;
        }
        //Added for Inline page
        if((relatedpbstring != '' && relatedpbstring != Null) && ApexPages.currentPage().getParameters().get('Mode')!='New'){
            list<Service_Assignment__c> AllServAssgn = [SELECT Id,name,person_Being_served__r.name,Service_Location__r.Alias__c,Service_Location__r.location_nickname__c FROM Service_Assignment__c where id in: relatedpbstring.split(',') and id !=: theServAssignId];
	        list<Service_Assignment__c> finalSAs = new list<Service_Assignment__c>();//IF(focusPBSList.SIZE()>0){
	            String commaSepratedList='';
                for(Service_Assignment__c slist:AllServAssgn){
	                commaSepratedList += slist.id + ',';
                }
                commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length());
                HomePageData = commaSepratedList;
	        //}
	        for(Service_Assignment__c saAdd:AllServAssgn){
	            if(saAdd.id != theServAssignId)
	                finalSAs.add(saAdd);
	        }
	        return finalSAs;
        }
        else if(focusPBSList.SIZE()>0 && (relatedpbstring == ''||relatedpbstring == Null) && ApexPages.currentPage().getParameters().get('Mode')=='New'){
            list<Service_Assignment__c> finalSAs = new list<Service_Assignment__c>();string commaseplist ='';
            for(Service_Assignment__c slist:focusPbsList){
                commaseplist += slist.id + ',';
                //HomePageData  += slist.id + ',';
            }
            HomePageData = commaseplist;
            for(Service_Assignment__c saAdd:focusPBSList){
	            if(saAdd.id != theServAssignId)
	                finalSAs.add(saAdd);
	        }
	        return finalSAs;
            //return focusPBSList;
        }
        else
            return null;
    }
    
    public static List<Service_Assignment__c> getSelectedPBS(){
        ID uid = UserInfo.getUserid();
        User u = [ select id, favorite_PBS__c from User where id = :uid LIMIT 1];
        String pbsJoin = u.favorite_PBS__c;
        List<String> favePBS = new List<String>();
        List<String> faveSA = new List<String>();
        if ( pbsJoin != null ) {
            List<String> tmplist = pbsJoin.Split(';');
            for (String tmp : tmplist) { 
                String[] moretmp = tmp.split('-');
                if (moretmp.size() == 2) {
                    favePBS.add(moretmp[0]);
                    faveSA.add(moretmp[1]);
                }
            }
        }
        list<Service_Assignment__c> SelectedServAssgn = 
        [   SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
            admission__c, Service_Location__r.location_nickname__c,  service_location__r.state__c,
            service_location__r.alias_lookup__r.Alias_Operating_Group__c,
            Service_Location__r.Alias__c, admission__r.state__c, name, recordtype.developername,
            status__c, end_date__c, service_location__r.tmn_scope__c,Flavor__c FROM Service_Assignment__c where Person_Being_Served__c in :favePBS
            AND ID in :faveSA
           ];
           
        return SelectedServAssgn;
    }
    
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c,Person_Being_Served__r.Name,Approval_User__c, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name, recordtype.developername from Progress_Note__c where id= :tmp.id limit 1];
        
    }
    public list<TMN_User__c> Therapist2 {get;set;}
    /**Called when Submit for Approval Button Is Clicked, Added In code as the Standard Approval 
    process Was adding an additional page , where user used to select the next Approver**/
    public pagereference SubmitForApp(){
        string updt = 'No';
        list<Approval.ProcessResult> appres = new list<Approval.ProcessResult>();
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
        updt = ApexPages.currentPage().getParameters().get('UpdateAll')==Null?'No':ApexPages.currentPage().getParameters().get('UpdateAll');
        progress_note__c pnode = [select name,Purpose_Service_is_Billable__c,recordtype.name,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId];
        if(updt == 'Yes' && (pnode.Related_note_IDs__c!= Null || pnode.Related_note_IDs__c!='')){
            List<Progress_note__c> NotestoUpdate = [Select name,Purpose_Service_is_Billable__c,recordtype.name,Service_Code__r.Service_Value__c, Authorization__r.Display_Name__c,Person_Being_Served__r.Medicaid_ID__c,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id In: pnode.Related_note_IDs__c.split(',')];
            list<attachment> listofAttachments = New List<Attachment>();
            String allErrors = '';
            for(progress_note__c pNoteNew:NotestoUpdate){
                String NoteError = validateEachnotebeforeFinalize(pNoteNew);
                if(NoteError!='No Errors')
                    allErrors = allerrors + pnotenew.name + '-->' + NoteError + '\n';
            }
            if(allErrors != ''){
                allErrors = 'Cannot submit for approval,These issues were found with the related notes' + '\n' + allErrors ;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,allErrors));
                return null;
            }else{
                for(progress_note__c pNoteNew:NotestoUpdate){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(pNoteNew.id);
                    req1.setSubmitterId(UserInfo.getUserId());
                    req1.setProcessDefinitionNameOrId('Progress_Notes_Approval');
                    req1.setSkipEntryCriteria(true);
                    list<id> listids = new list<id>();
                    listids.add(userinfo.getuserid());
                    req1.setNextApproverIds(listids);
                    try{
                        Approval.ProcessResult result = Approval.process(req1);
                    }
                    catch (Exception e) {
                        ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
                        return null;
                    }
                    //Add an attachment
                    Attachment attachmentPDF = new Attachment();           
                    attachmentPDF.parentId = pNoteNew.id;
                    attachmentPDF.Name = 'State Template (no signature) - ' + pNoteNew.Person_Being_Served__r.Name + ' - ' + pNoteNew.RecordType.Name +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';
                    if(Test.isrunningtest()==false){ 
                        Blob testBlob = Blob.valueOf('FLAVOR PDF BODY CONTENTS');
                        attachmentPDF.body = testBlob;
                    }
                    else{
                        Blob testBlob = Blob.valueOf('FLAVOR PDF BODY CONTENTS');
                        attachmentPDF.body = testBlob;
                    } 
                    listofAttachments.add(attachmentPDF);
                    /**PageReference pageRef2 = new PageReference('/apex/V2SA_ProgressNotesPDF');
                    pageRef2.getParameters().put('id', pNoteNew.id);**/
                    Attachment attachmentPDF2 = new Attachment();
                    attachmentPDF2.parentId = pNoteNew.id;
                    attachmentPDF2.Name = pNoteNew.Person_Being_Served__r.Name + ' - ' + pNoteNew.RecordType.Name +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';          
                    if(Test.isrunningtest()==false){ 
                        //attachmentPDF2.body = pageRef2.getContent();
                        Blob testBlob = Blob.valueOf('FLAVOR PDF BODY CONTENTS');
                        attachmentPDF2.body = testBlob;
                    }
                    else{
                        Blob testBlob2 = Blob.valueOf('TEST 123');
                        attachmentPDF2.body = testBlob2;
                    }   
                    listofAttachments.add(attachmentPDF2);
                    
                } 
                insert listofAttachments;
                pagereference pageref = new Pagereference('/'+pnode.id);
                pageref.setredirect(true);
                return pageref;
            }
        }
        else{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(pnode.id);
            req1.setSubmitterId(UserInfo.getUserId());
            req1.setProcessDefinitionNameOrId('Progress_Notes_Approval');
            req1.setSkipEntryCriteria(true);
            list<id> listids = new list<id>();
            listids.add(userinfo.getuserid());
            req1.setNextApproverIds(listids);
            try{
                Approval.ProcessResult result = Approval.process(req1);
            }
            catch (Exception e) {
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
                return null;
            }
            pagereference pageref = new Pagereference('/apex/Notes_ProgressNote_Create_Flavor_PDF?id='+pnode.id+'&IsSubmitted=Yes');
            pageref.setredirect(true);
            return pageref;
        }
    }
    
    /** Disregard Code for added custom button**/
    public PageReference disregardNote(){
        User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
        Id integrateUserId = integrateUser.Id;
        DateTime n = DateTime.now();
        string updt = 'No';
        LIST<Progress_note__c> progNotetoUpdate = new list<Progress_note__c>();
        LIST<Progress_note__c> progNotetoUpdate2 = new list<Progress_note__c>();
        List<task> taskstoinsert = new list<task>();
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
        updt = (ApexPages.currentPage().getParameters().get('UpdateAll')==Null || ApexPages.currentPage().getParameters().get('UpdateAll')==Null)?'No':ApexPages.currentPage().getParameters().get('UpdateAll');
        System.debug('-------' +insertedProgressNoteId +  'Came here' + updt);
        progress_note__c pnode = [select Purpose_Service_is_Billable__c,Locked__c,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId];
        if(updt == 'Yes' && (pnode.Related_note_IDs__c!= Null || pnode.Related_note_IDs__c!='')){
            List<Progress_note__c> NotestoUpdate = [Select Locked__c,Person_Being_Served__c,Disregard_Note__c,Purpose_Service_is_Billable__c,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id In: pnode.Related_note_IDs__c.split(',') AND DISREGARD_NOTE__C =: False];
            for(progress_note__c pNoteNew:NotestoUpdate){
                Boolean resetLocked = pNoteNew.Locked__c;
                if (resetLocked) {
                    pNoteNew.No_Approval_Needed__c  = false;
                    pNoteNew.Locked__c  = false;
                    progNotetoUpdate2.add(pNoteNew);
                }
            }
            update progNotetoUpdate2;
            for(progress_note__c pNoteNew:NotestoUpdate){
                pnotenew.Purpose_Service_is_Billable__c = false;
                pNoteNew.Disregard_Note__c = true;
                progNotetoUpdate.add(pnotenew);
                Task t = new Task(
                    Subject = 'Disregard', 
                    Status = 'Completed', 
                    Priority = 'Normal', 
                    OwnerId = integrateUserId, 
                    Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), 
                    WhoId = pnotenew.Person_Being_Served__c, 
                    WhatId = pnotenew.Id, 
                    ActivityDate = n.date()
                );
                taskstoinsert.add(t);
            }
            update progNotetoUpdate;
            insert taskstoinsert;
        } 
        else{
            Boolean resetLocked = pnode.Locked__c;
            if (resetLocked) {
                pnode.No_Approval_Needed__c  = false;
                pnode.Locked__c  = false;
                update pnode;
            }
            pnode.Purpose_Service_is_Billable__c = false;
            pnode.Disregard_Note__c = true;
            if (resetLocked)
                pnode.No_Approval_Needed__c  = resetLocked;
            update pnode;
            Task t = new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = pnode.Person_Being_Served__c, WhatId = pnode.Id, ActivityDate = n.date());
            insert t;
        }
			return new PageReference('/' + insertedProgressNoteId); 
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
    
    Public String validateEachnotebeforeFinalize(progress_note__c pnValidations){
        String ListErrors = 'No Errors';
        if(pnValidations.Type_of_Contact__c == 'Face-To-Face' && pnValidations.Type__c == null )
            ListErrors = 'If type of contact is face to face , then type of treatment needs to be selected';
        if(pnValidations.Therapy_Discipline__c  == Null){
            if(ListErrors == 'No Errors')
                ListErrors = 'Please choose a therapy discipline before finalizing';
            else
                ListErrors = ListErrors + ',' + 'Please choose a therapy discipline before finalizing';
        }
        if(pnValidations.Type_of_Contact__c == Null ||pnValidations.Type_of_Contact__c == ''){
            if(ListErrors == 'No Errors')
                ListErrors = 'You must select the Type of Contact before continuing.';
            else
                ListErrors = ListErrors + ',' + 'You must select the Type of Contact before continuing.';
        }
        return ListErrors; 
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
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter Co-Treatment Therapist if the type of treatment is co-treatment'));    
        }
        if(pnValidations[0].Type_of_Contact__c == 'Face-To-Face' && pnValidations[0].Type__c == null ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'If type of contact is face to face , then type of treatment needs to be selected'));    
        }
        if(pnValidations[0].Therapy_Discipline__c  == Null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose a therapy discipline before finalizing'));  
        }
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
            return null;
        }
        else{
            displayPopup = true; 
            LoadData(thePN);
            return null;
        } 
    }
    public Notes_ProgressNote_Therapyext(ApexPages.StandardController controller){
        relatedpbstring='';HomePageData ='';updatePBs = false;
      	if (!Test.isRunningTest()) {
                controller.addFields(new string[] {'RecordType.Name', 'Service_Assignment__r.Start_Date__c', 'Service_Assignment__r.End_Date__c'});
         }
         
       	pn = (Progress_Note__c) controller.getRecord();
       	Therapist2 = new list<TMN_User__c>();
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
            list<ProcessInstanceWorkitem> ProcessList = New list<ProcessInstanceWorkitem>();
            ProcessList = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: insertedProgressNoteId ];
            if(processlist.size()>0){
                ProcessId = ProcessList[0].Id;
            }
            List<String> OldIds = New List<String>();
            list<string> finallisttocreate = new list<string>();
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Signature_on_File__c ,Service_Location__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c ,Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
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
            progress_note__c pnedit = [select Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId ];
            this.thePN = pn;
            if(pn.Service_Assignment__c!=Null)
            theServAssign = [ SELECT Id, Name, Start_date__c, End_date__c, Person_Being_Served__c,service_location__r.programid__c,Person_Being_Served__r.name,Admission__c,Admission__r.Person_Being_Served__c,Person_Being_Served__r.AccountId, person_being_served__r.LastName, person_being_served__r.ownerid FROM Service_Assignment__c WHERE Id = :pn.Service_Assignment__c];
            theServAssignId =  pnedit.Service_Assignment__c ;
            pbsName = pnedit.Service_Assignment__r.Person_Being_Served__c;
            relatedpbstring = pnedit.Related_Person_Being_Served__c;
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
    
    /***public void popTherapist(){
      if(pn.Type__c == 'Individual'){
        pn.Therapy_Discipline__c = cuUser[0].Discipline__c;
      }
      else{
        pn.Clinician__c =null;
        pn.Therapy_Discipline__c = null;
      }
    }***/
    public void popDiscipline(){
      therapist2 = [SELECT Id, Last_Day__c, Job_Status__c, Discipline__c FROM TMN_User__c where id = :pn.Clinician__c LIMIT 1];
      system.debug('---here---');
      if(pn.Type__c == 'Co-Treatment' && pn.Clinician__c !=null){
        pn.Therapy_Discipline__c = therapist2[0].Discipline__c;
      }
      else{
        pn.Clinician__c =null;
        pn.Therapy_Discipline__c = Null;
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
        if((null != theservAssign.End_Date__c)){
        	if(system.today() > theservAssign.End_Date__c.addDays(14)){
        		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Therapy note can be entered only upto 2 weeks after discharge'));
        		ErrorMsg = ErrorMsg + 'Late Entry';
            	return null;
        	} 
        }
        if ( pn.start_time__c == null || pn.end_time__c == null ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Start and end dates and times required.'));
            ErrorMsg = ErrorMsg + 'Required';
            return null;
        }
        if(pn.End_Time__c.getTime()==pn.Start_Time__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Your start and end times must differ.'));   
            ErrorMsg = ErrorMsg + 'Same Times';
            return null;
        } 
        if( pn.start_time__c > pn.end_time__c ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Start date/time must be before end/date time'));    
            ErrorMsg = ErrorMsg + 'Start Time Greater';
            return null;
        }
        if((pn.Date_of_Service__c > system.today()) || ( pn.start_Time__c > system.NOW() ) || ( pn.End_Time__c > system.NOW() )){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - All service dates and times must have occurred in the past. Please check your dates and try again.'));     
            ErrorMsg = ErrorMsg + 'Start,End Time Past';
            return null;
        }
        if(pn.Start_Time__c > system.now()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Start time cannot be in the future'));     
            ErrorMsg = ErrorMsg + 'Start time future';
            return null;
        }
        if(theservAssign != Null && ((theservAssign.Start_Date__c > pn.Start_Time__c.date()) || ( theservassign.Start_Date__c > pn.End_Time__c.date()))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.'));     
            ErrorMsg = ErrorMsg + 'Date Range Incorrect';
            return null;
        }
        if(theservAssign != Null && theservassign.End_Date__c!=Null && ((theservassign.End_Date__c < pn.Start_Time__c.date()) || (theservassign.End_Date__c < pn.End_Time__c.date()))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.'));     
            ErrorMsg = ErrorMsg + 'Date Range Incorrect';
            return null;
        }
       if(decimal.valueof((pn.End_Time__c.getTime())/1000/60 - (pn.Start_Time__c.getTime())/1000/60) > 120.0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - The total duration cannot be more than 120 mins. Please correct start and/or end time for accuracy'));     
            ErrorMsg = ErrorMsg + 'More Than 120';
            return null;
        } 
        if((pn.Type__c=='Co-Treatment' || pn.Type__c=='Group') && pn.Clinician__c==cuUser[0].id){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - When Type of Treatment is Co-Treatment or Group, you cannot select yourself as the therapist'));     
            ErrorMsg = ErrorMsg + 'Self Therapist';
            return null;
        }
        if(pn.id==null && pn.Purpose_Service_is_Billable__c == true){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - For Therapy, the Purpose/Service is Billable field must be unchecked. Please un check that field and try again.'));
          ErrorMsg = ErrorMsg + 'Billable';
            return null;
        }
        if(pn.Service_Code__c==null){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - You must select a Service Code before continuing.'));
          ErrorMsg = ErrorMsg + 'No Service Code';
            return null;
        }
        if(Therapist2.size()>0 && Therapist2[0].Job_Status__c !='Active' &&  pn.start_time__c.date() >= Therapist2[0].Last_Day__c ){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, theservAssign.Name + ' - Co-treatment Therapist inactive on the day of therapy. Please revise your selection.'));
          ErrorMsg = ErrorMsg + 'Inactive Therapist';
            return null;
        }

        return null;
    }
    Public String validateEachnote(progress_note__c pn,Service_Assignment__c relatedServAssgn){
       String ListErrors = 'No Errors';
       System.debug('----related Serv Assignment --> '+ relatedServAssgn+ 'End Date ' + relatedServAssgn.End_Date__c);
       if((null != relatedServAssgn.End_Date__c)){
        	if(system.today() > relatedServAssgn.End_Date__c.addDays(14))
        	    ListErrors = 'Therapy note can be entered only upto 2 weeks after discharge';
        }
        if(relatedServAssgn != Null && ((relatedServAssgn.Start_Date__c > pn.Start_Time__c.date()) || ( relatedServAssgn.Start_Date__c > pn.End_Time__c.date()))){
            if(ListErrors == 'No Errors')
                ListErrors = 'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.';
            else
                ListErrors = ListErrors + ',' + 'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.';
        }
        
        if(relatedServAssgn != Null && relatedServAssgn.End_Date__c!=Null && ((relatedServAssgn.End_Date__c < pn.Start_Time__c.date()) || (relatedServAssgn.End_Date__c < pn.End_Time__c.date()))){
            if(ListErrors == 'No Errors')
                ListErrors = 'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.';
            else
                ListErrors = ListErrors + ',' + 'The date range you have specified for this Note does not seem to fall completely within the selected Service Assignment.';
        }
        return ListErrors; 
    }
    public pagereference userupdatedpbs(){
        updatePBs = true;
        return null;
    }
    
    public pagereference RenderSelectedIds(){
        insertedProgressNoteId = ApexPages.currentPage().getParameters().get('id');
        string updt = 'No';
        updt = ApexPages.currentPage().getParameters().get('UpdateAll')==Null?'No':ApexPages.currentPage().getParameters().get('UpdateAll');
        if(cuUser.size()>0 && pn.Type__c == 'Individual'){
            pn.Clinician__c = cuUser[0].id;
            pn.Therapy_Discipline__c = cuUser[0].Discipline__c;
        }
        if(ApexPages.currentPage().getParameters().get('Mode')=='New' && (relatedpbstring == '' || pn.Related_Person_Being_Served__c == Null)&& updatePBs == false)
            pn.Related_Person_Being_Served__c = HomePageData ;
        pn.Person_Being_Served__c = pbsName;
        pn.admission__c = admissionId;
        pn.Service_Assignment__c = theServAssignId;
        System.debug(pn.Related_Person_Being_Served__c);
        commonValidations();//pn
        if(ErrorMsg != ''){
            return null;
        }
        
        //Add NEW Progress Notes 
        try {
            upsert pn;
            insertedProgressNoteId = pn.Id;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));     
            return null;
        }
        progress_note__c pnode = [select Purpose_Service_is_Billable__c,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id =: insertedProgressNoteId];
         if(pnode.type__c == 'Group'){
            IF((pnode.Related_Person_Being_Served__c == NULL ||pnode.Related_Person_Being_Served__c == '')&&  updatePBs == false){
                pnode.Related_Person_Being_Served__c = HomePageData;
            }
            if(pnode.Related_Person_Being_Served__c != ''&& pnode.Related_Person_Being_Served__c != Null ){
                list<Service_Assignment__c> sa = [select id,End_Date__c,Start_Date__c,Person_Being_Served__c,admission__c,Person_Being_Served__r.name from Service_Assignment__c where id in:pnode.Related_Person_Being_Served__c.split(',')];
                map<id,id> servassgntopbs = new map<id,id>();
                map<id,string> servassgntopbsname = new map<id,string>();
                map<id,id> servassgntoAdmsn = new map<id,id>();
                map<id,Service_assignment__c> idtoservassgn = new map<id,Service_assignment__c>();
                for(Service_Assignment__c sassgn:sa){
                    servassgntopbs.put(sassgn.id,sassgn.Person_Being_Served__c);
                    servassgntopbsname.put(sassgn.id,sassgn.Person_Being_Served__r.name);
                    servassgntoAdmsn.put(sassgn.id,sassgn.Admission__c);
                    idtoservassgn.put(sassgn.id,sassgn);
                }
                pnode.Related_Person_Being_Served__c = pnode.Related_Person_Being_Served__c.remove(pn.id+',');
                pnode.Related_Person_Being_Served__c = pnode.Related_Person_Being_Served__c.remove(pnode.Service_Assignment__c+',');
                list<Progress_note__c> listofNotes = new list<Progress_note__c>();
                String allErrors = '';
                for(string s:pnode.Related_Person_Being_Served__c.split(',')){
                    progress_note__c pNoteNew = new Progress_note__c();
                    pNoteNew.Start_Time__c = pnode.Start_Time__c;
                    pNoteNew.End_Time__c = pnode.End_Time__c;
                    pNoteNew.Service_Location__c = pnode.Service_Location__c;
                    pNoteNew.Type_of_Contact__c = pnode.Type_of_Contact__c;
                    pNoteNew.People_Present__c = pnode.People_Present__c;
                    pNoteNew.Type__c = pnode.Type__c;
                    pNoteNew.Therapy_Discipline__c = pnode.Therapy_Discipline__c;
                    pNoteNew.Number_of_Required_Signatures__c = pnode.Number_of_Required_Signatures__c;
                    pNoteNew.Purpose_Service_is_Billable__c = pnode.Purpose_Service_is_Billable__c;
                    pnotenew.Related_Person_Being_Served__c = pnode.Related_Person_Being_Served__c;
                    pNoteNew.Service_Assignment__c = s;
                    pNoteNew.person_being_served__c = servassgntopbs.get(s);
                    pNoteNew.Admission__c = servassgntoAdmsn.get(s);
                    pNoteNew.recordtypeId =pnode.recordtypeid;
                    pNoteNew.Service_Code__c = pnode.Service_Code__c;
                    String NoteError = validateEachnote(pnotenew,idtoservassgn.get(s));
                    if(NoteError!='No Errors')
                        allErrors = allerrors + servassgntopbsname.get(s) + '--> ' + NoteError + '\r\n';
                    listofNotes.add(pNoteNew);
                }
                if(allErrors != ''){
                    allErrors = 'Cannot create a new note for related Person being served,These issues were found ' + '\r\n' + allErrors ;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,allErrors));
                    return null;
                }ELSE{
                    if(listofNotes.size()>0){
                        insert listofNotes;
                    }
                }
            }    
                if(pnode.Related_note_IDs__c == null || pnode.Related_note_IDs__c == ''){
                
                    List<Progress_note__c> NotesCreated = [Select id,Start_Time__c,End_Time__c,Related_note_IDs__c from progress_note__c where start_time__c =: pnode.Start_Time__c and End_Time__c =: pnode.End_Time__c and CreatedById =: UserInfo.getUserId() and recordtypeId =: pnode.recordtypeid];
                    String ReltedNotesIds;
                    if(NotesCreated.Size()>0){
                        for(progress_note__c p:notesCreated){
                            ReltedNotesIds = ReltedNotesIds + p.id + ',';
                        }
                        ReltedNotesIds = ReltedNotesIds.remove('null');
                        for(progress_note__c p:notesCreated){
                            p.Related_note_IDs__c = ReltedNotesIds;
                        }
                        update NotesCreated;
                    }
                }else{
                    if(updt == 'Yes'){
                        List<Progress_note__c> NotestoUpdate = [Select Purpose_Service_is_Billable__c,Related_note_IDs__c,Service_Code__c,recordtypeid,Number_of_Required_Signatures__c,type__c,Therapy_Discipline__c,Type_of_Contact__c,People_Present__c,Service_Location__c,Is_Note_Late__c,Service_Assignment__r.Admission__r.State__c,Related_Person_Being_Served__c ,owner.name,Person_Being_Served__r.Name,Approval_User__c,End_Time__c,Start_Time__c,Service_Assignment__c ,Service_Assignment__r.service_location__r.programid__c,No_Approval_Needed__c , Service_Assignment__r.Person_Being_Served__c,Service_Assignment__r.Person_Being_Served__r.Name,Action_Plan__c ,Service_Assignment__r.Admission__c from progress_note__c where id In: pnode.Related_note_IDs__c.split(',')];
                        for(progress_note__c pNoteNew:NotestoUpdate){
                            pNoteNew.Start_Time__c = pnode.Start_Time__c;
                            pNoteNew.End_Time__c = pnode.End_Time__c;
                            pNoteNew.Service_Location__c = pnode.Service_Location__c;
                            pNoteNew.Type_of_Contact__c = pnode.Type_of_Contact__c;
                            pNoteNew.People_Present__c = pnode.People_Present__c;
                            pNoteNew.Type__c = pnode.Type__c;
                            pNoteNew.Therapy_Discipline__c = pnode.Therapy_Discipline__c;
                            pNoteNew.Number_of_Required_Signatures__c = pnode.Number_of_Required_Signatures__c;
                            pNoteNew.Purpose_Service_is_Billable__c = pnode.Purpose_Service_is_Billable__c;
                            pnotenew.Related_Person_Being_Served__c = pnode.Related_Person_Being_Served__c;
                            pNoteNew.Service_Code__c = pnode.Service_Code__c; 
                        }
                        update NotestoUpdate;
                    }
                }
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
    
    transient public List<ProcessInstanceHistory> approvalHistory;
	public List<ProcessInstanceHistory> getApprovalHistory () {
		approvalHIstory = new List<ProcessInstanceHistory>();
		List<ProcessInstance> pi = [
			SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate
			              FROM StepsAndWorkitems
			            ORDER BY createddate desc)
			FROM ProcessInstance where  targetobjectid = :thePn.Id
			ORDER BY createddate desc];

		for ( ProcessInstance p : pi ) {
			approvalHistory.addAll (p.stepsandworkitems);
		}
		return approvalHistory;

    }
    
}