public without sharing class DSP_ShiftNoteList {
	private list<Progress_Note__c> pnotes;
	public String pbsId {get;set;}
    public String shiftnoteId {get;set;}
	
	public transient list<DSP_Shift_Note_Basic.NoteWrapper> pastnotes;
    public list<DSP_Shift_Note_Basic.NoteWrapper> getPastnotes(){
    	if (this.pastnotes == null){
	        pastnotes = new list<DSP_Shift_Note_Basic.NoteWrapper>();
	        for (Progress_Note__c pn : pnotes){
	            pastnotes.add(new DSP_Shift_Note_Basic.NoteWrapper(pn));
	        }
    	}
        return this.pastnotes;	
    } 
	
	public DSP_ShiftNoteList(Id pbsID){
		this.pbsId = pbsID;
        String strSQL =  'SELECT id, name, locked__c, Disregard_Note__c, Late_Entry__c, Start_Time__c, End_Time__c, Number_of_Required_Signatures__c, Narrative__c, Healthcare_Medical_Note__c,' +     
						'ownerId, createdby.Name, lastmodifiedby.Name, CreatedDate, LastModifiedDate, No_Approval_Needed__c, Approval_Status__c, Approval_Status_Date__c, Status__c, ' +  
						'Action_Plan__c, Service_Assignment__c, Admission__c, RecordTypeid, Person_Being_served__c, Person_Being_Served__r.Name, Signature_on_File__c  FROM Progress_Note__c WHERE RecordType.developername = \'Shift_Note\' and Person_Being_Served__c = \'' + pbsID + '\' and createddate = LAST_N_DAYS:30 order by Start_Time__c desc ';
        pnotes = (list<Progress_Note__c>) Database.query(strSQL);
        
	}

    public pagereference submitTxnRequest(){
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = this.shiftnoteId;
        try { 
            insert txn;
            PageReference pr =  Page.DSP_ShiftNote_Basic;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }              
    }
    
}