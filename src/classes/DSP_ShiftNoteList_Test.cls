@isTest
private class DSP_ShiftNoteList_Test {

    static testMethod void testOne() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        //create a new transactionQueue request for DSP list view type
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note List';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = String.ValueOf([select Id from contact limit 1].Id);
        insert txn;
 
        PageReference pageRef = Page.DSP_ShiftNoteList;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        system.assert(controller.shiftNoteList.getPastnotes().size() == 0);
    }
    

    static testMethod void testTwo() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
    	//create a shift note ensure that it shows up in the list
	    DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
	    DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
	    RecordType rt = [select id from recordtype where name='Shift Note'];
	    
	    Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = mydata.thesa.Id,
	                                                                    Service_Code__c = mydata.theservicecode.Id, 
	                                                                    Admission__c = mydata.theadm.ID,
	                                                                    Start_Time__c = startDateTime,
	                                                                    End_Time__c = endDateTime,
	                                                                    Person_Being_Served__c = mydata.contactID,
	                                                                    No_Approval_Needed__c = true,
	                                                                    Approval_Status__c = 'Approved',
	                                                                    recordtypeId = rt.Id,
	                                                                    Status__c = 'Final');
	    insert thisProgressNote;
    	
        //create a new transactionQueue request for DSP list view type
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note List';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = String.ValueOf([select Id from contact limit 1].Id);
        insert txn;
 
        PageReference pageRef = Page.DSP_ShiftNoteList;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        system.assert(controller.shiftNoteList.getPastnotes().size() == 1);
    }

    static testMethod void testThree() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        //create a shift note ensure that it shows up in the list
        DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
        DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
        RecordType rt = [select id from recordtype where name='Shift Note'];
        Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = mydata.thesa.Id,
                                                                        Service_Code__c = mydata.theservicecode.Id, 
                                                                        Admission__c = mydata.theadm.ID,
                                                                        Start_Time__c = startDateTime,
                                                                        End_Time__c = endDateTime,
                                                                        Person_Being_Served__c = mydata.contactID,
                                                                        No_Approval_Needed__c = true,
                                                                        Approval_Status__c = 'Approved',
                                                                        recordtypeId = rt.Id,
                                                                        Status__c = 'Final');
        insert thisProgressNote;
        
        //create a new transactionQueue request for DSP list view type
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Shift Note List';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = String.ValueOf([select Id from contact limit 1].Id);
        insert txn;
 
        PageReference pageRef = Page.DSP_ShiftNoteList;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        
        controller.shiftNoteList.shiftnoteId = String.ValueOf(thisProgressNote.Id);
        pagereference pr = controller.shiftNoteList.submitTxnRequest();
        system.assert(pr.getRedirect());
        system.assert(pr.getUrl().containsIgnoreCase('DSP_ShiftNote_Basic'));
    }


   /* 
   @testSetup static void myDataSetup(){
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();   	
   } */
   
}