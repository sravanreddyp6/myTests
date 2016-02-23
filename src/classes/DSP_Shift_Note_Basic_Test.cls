@isTest
private class DSP_Shift_Note_Basic_Test {
    private static TMN_Generic_Core_TestData testData;
    private static Progress_Note__c pn;
    private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    
    static testMethod void createShiftNote() {
        createData();
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = json.serialize(new Map<String, String>{'pbsID'=>string.valueOf(testData.ContactID),
            'saID'=>string.valueOf(testData.theSA.id),
            'admID'=>string.valueOf(testData.theAdm.Id),
            'apID'=>string.valueOf(ap.Id)});
        insert txn;
        
        PageReference pageRef = Page.DSP_ShiftNote_Basic;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        controller.shiftNote.noteWrapper.Start_Time = DateTime.NewInstance(2014,11,1,12,0,0); 
        controller.shiftNote.noteWrapper.End_Time = DateTime.NewInstance(2014,12,31,12,0,0);
        controller.shiftNote.noteWrapper.Narrative = 'Narrative'; 
        controller.shiftNote.selectedKeys = String.valueOf(apg.Id) + ',' + String.valueOf(apo.Id);
        
        pageRef = controller.shiftNote.mySave();
        system.assert(pageRef.getRedirect());
        system.assert(pageRef.getUrl().containsIgnoreCase('DSP_ShiftNote_Basic'));
        system.assert([select id from progress_note__c].size() == 1);
        
        Test.setCurrentPage(pageRef);
        //after save it should be the view mode of the note
        controller = new TxnQueueResponseController();
        system.assert(!controller.shiftNote.editMode); // shift note view mode of the screen        
        controller.shiftNote.myEdit();
        system.assert(controller.shiftNote.editMode);
        
        Test.setCurrentPage(pageRef);
        controller = new TxnQueueResponseController(); //get the view of shift note again
        
        //eSign and finalize Note
        CMEsignAZOPT auth = new CMEsignAZOPT();
        auth.handle([select id from progress_note__c].Id, UserInfo.getUserId());
        
        system.assert(!controller.shiftNote.noteWrapper.No_Approval_Needed); // not finalized yet
        
        pageRef = controller.shiftNote.myFinal();
        
        Test.setCurrentPage(pageRef);
        controller = new TxnQueueResponseController();
        system.assert(controller.shiftNote.noteWrapper.No_Approval_Needed); // finalized.        
    }
    
    
    static testMethod void DisregardShiftNote() {
        createData();
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = json.serialize(new Map<String, String>{'pbsID'=>string.valueOf(testData.ContactID),
            'saID'=>string.valueOf(testData.theSA.id),
            'admID'=>string.valueOf(testData.theAdm.Id),
            'apID'=>string.valueOf(ap.Id)});
        insert txn;
        
        PageReference pageRef = Page.DSP_ShiftNote_Basic;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        controller.shiftNote.noteWrapper.Start_Time = DateTime.NewInstance(2014,11,1,12,0,0); 
        controller.shiftNote.noteWrapper.End_Time = DateTime.NewInstance(2014,12,31,12,0,0);
        controller.shiftNote.noteWrapper.Narrative = 'Narrative';         
        pageRef = controller.shiftNote.mySave();
        
        Test.setCurrentPage(pageRef);
        controller = new TxnQueueResponseController();
        system.assert(! controller.shiftNote.noteWrapper.Disregard_Note); // not disregarded yet.        
        
        pageRef = controller.shiftNote.updateLocked();
        Test.setCurrentPage(pageRef);
        controller = new TxnQueueResponseController();
        system.assert(controller.shiftNote.noteWrapper.Disregard_Note); // disreagrded.
    }
    
    private static Action_Plan__c createData(){
        testData = new TMN_Generic_Core_TestData();
        ap = new Action_Plan__c(
            Service_Assignment__c = testData.theSA.id,
            Target_Date__c = system.today(),
            Effective_Date__c = system.today()-365
        );        
        insert ap; 
        
        apg = new Action_Plan_Goal__c(
            Description__c = 'a goal',
            Action_Plan__c = ap.id,
            sort_order__c = 'g'
        );
        insert apg;
        
        apo = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'an Objective',
            Type__c = 'skill',
            Target_End_Date__c = system.today(),
            Effective_Date__c = system.today()-365,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.start_Date__c = system.today()-365;
        apa.End_Date__c = system.today();
        apa.Status__c = 'New';
        insert apa;
        
        return ap;   
    }
    
}