@isTest
private class DSP_WeeklySkillTracking_Test {

    private static TMN_Generic_Core_TestData testData;
    private static Progress_Note__c pn;
    private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    
    static testMethod void testSkillTracking() {
    
		createData();
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Skill';
        txn.requested_date_time__c = DateTime.Now();
        
        // first test the creation of worksheet from the action plan ID
        txn.input_params__c = ap.Id;
        insert txn;
        
        PageReference pageRef = Page.DSPWeeklySkillTracking;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('txnID', txn.ID);
        
        TxnQueueResponseController controller = new TxnQueueResponseController();
        system.debug( controller.skillResponse);
        system.assert(controller.skillResponse.startdate == Date.Today().toStartOfWeek() + 1);
        
        ID newWSId = controller.skillResponse.wsId;
        
        DSP_WeeklySkillTracking wstPage = new DSP_WeeklySkillTracking( controller) ;
        System.Assert ( wstPage.prompts.size() > 0 );
        System.Assert ( wstPage.metlist.size() > 0 );
		System.Assert ( wstPage.wsID == newWSID);
		System.Assert(  controller.skillResponse.getdaysofweek().size() == 7);
		
		System.Assert( controller.skillResponse.objectivesMap.size() == 1);
        
       
        // now get the data to show
        /*
        List<DSP_BehaviorTracking.Table> tables = controller.skillResponse.Tables;
        for ( DSP_BehaviorTracking.Table t : tables ) {
        	system.assert( t.objectivedescription == apo.description__c);
        	system.assert( t.istimebased);
        	system.assert( t.getRows().size() > 0 );
        	Map<integer, DSP_BehaviorTracking.Row> myrows = t.getRows();
        	for ( Integer k : t.FirstKeys ) {
        		for ( Date d : t.PartOneSecondKeys ) {
        			
        			if ( t.Active( k, d )) {
        				system.debug('inside loop for '  + k + ', ' + d);
        				System.Assert( myrows.get(k).getItems().get(d).DataObject.strnumoccurred == null );
        				System.Assert( myrows.get(k).getItems().get(d).DataObject.Occurred == null );
        				System.Assert( myrows.get(k).getItems().get(d).DataObject.Occurrences == null );
        			}
        		}
        	}
        }
        */
        /*
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
        */   
}


    
   private static Action_Plan__c createData(){
		testData = new TMN_Generic_Core_TestData();
        ap = new Action_Plan__c(
            Service_Assignment__c = testData.theSA.id,
            Target_Date__c = system.today()+30,
            Effective_Date__c = system.today()-365,
            status__c = 'Active Final'
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
            Type__c = 'Skill',
            Target_End_Date__c = system.today()+7,
            Effective_Date__c = system.today()-7,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.start_Date__c = system.today()-7;
        apa.End_Date__c = system.today()+7;
        apa.Status__c = 'New';
        insert apa;
        
        return ap;   
        
       
        
    }
    

    

}