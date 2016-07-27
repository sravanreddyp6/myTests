@isTest
private class DSP_shiftnote_summary_rpt_Test {
    private static TMN_Generic_Core_TestData myData;
    private static Progress_Note__c pn;
    private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    

    static testMethod void myUnitTest() {
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
        	createData();
            myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
            upsert myData.theSA;
            
            DateTime startDateTime = DateTime.NewInstance(2014,12,1,1,0,0);
            DateTime endDateTime = DateTime.NewInstance(2014,12,1,2,0,0);
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
            
            list<ProgressNote_ActionPlanChildren_mjo__c> pnAssociations = new list<ProgressNote_ActionPlanChildren_mjo__c>();
            pnAssociations.add(new ProgressNote_ActionPlanChildren_mjo__c(Goal__c = apg.Id, Progress_note__c = thisProgressNote.id));
            pnAssociations.add(new ProgressNote_ActionPlanChildren_mjo__c(Objective__c = apo.Id, Progress_note__c = thisProgressNote.id));
            insert pnAssociations;
            
            PageReference pageRef = new PageReference('/apex/DSP_ShiftNote_summary_rpt');
            Test.setCurrentPage(pageRef); 
            pageRef.getParameters().put('selectedPBS', String.valueOf(mydata.contactID));
            pageRef.getParameters().put('currentPBSList', JSON.Serialize(new list<String>{String.valueOf(mydata.contactID)}));
            
            DSP_shiftnote_summary_rpt cntl = new DSP_shiftnote_summary_rpt();
            
            cntl.startdate =  Date.newInstance(2014,11,30);
            cntl.enddate = Date.newInstance(2014,12,2);
            
            cntl.runReport();
            system.assert(cntl.getnotes().size() == 1);
            system.assert(cntl.getNote_Goals().size() == 1);
            system.assert(cntl.getNote_Objs().size() == 1);
            
            pageRef = cntl.cancelToNewRun();
	        system.assert(pageRef.getRedirect());
	        system.assert(pageRef.getUrl().containsIgnoreCase('DSP_ShiftNote_summary_rpt'));
        }
    }
    
    private static Action_Plan__c createData(){
        myData = new TMN_Generic_Core_TestData();
        ap = new Action_Plan__c(
            Service_Assignment__c = myData.theSA.id,
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