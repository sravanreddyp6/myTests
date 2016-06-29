@isTest
private class ActionPlan_FormWithoutSharing_Test {
    private static TMN_Generic_Core_TestData testData;
    static testMethod void testForInvalidTxnInput() {
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com', 'Action', 'Summary', 'Redwood');
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            testData.loadData('MN');
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Action Plan';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(testData.ContactID);
            try {
                insert txn;  // a dmlException will be thrown here since there is not action plan created yet... and the Id being passed in is pbsID instead of apID 
                PageReference pageRef = Page.DSPActionPlan;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('txnID', txn.ID);
                TxnQueueResponseController controller = new TxnQueueResponseController();
                throw new DataCreateException('We should have never come to this line of code.');
            } catch(DMLException e) {
                system.assert(true);
            } catch(Exception e) {
                throw e ;
            } 
        }
    }
    public class DataCreateException extends Exception{
    } 
    
    static testMethod void myUnitTest() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            Action_Plan__c ap = createAction_Plan();
            ap.Status__c = 'Active Final';
            ap.finalized_by__c = UserInfo.getUserId();
            ap.Finalized_Date__c = system.today();
            update ap;
            
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Action Plan';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(ap.Id);
            insert txn;
            
            PageReference pageRef = Page.DSPActionPlan;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            
            TxnQueueResponseController controller = new TxnQueueResponseController();
            system.assert(controller.response.isRedwood);
            system.assert(controller.response.GETplanStuff().keySet().size() > 0);
            
            DSPSubmitTxn extension = new DSPSubmitTxn(controller);
            extension.ackAPID = ap.Id;
            extension.initials = 'Test';
            pageRef = extension.ackActionPlan();
            Test.setCurrentPage(pageRef);
            controller = new TxnQueueResponseController();
            
            // assert that the ack recrod exists for this assessment, and the page after ACK was indeed the ISSA page.
            system.assert(pageRef.getRedirect());
            system.assert(pageRef.getUrl().containsIgnoreCase('DSPActionPlan'));
            system.assert(controller.response.ackwraplist.size() == 1);
        }
    }
    
    private static void createData(){
        testData = new TMN_Generic_Core_TestData();
    }
    
    private static Action_Plan__c createAction_Plan(){
        createData();
        
        Action_Plan__c ap = new Action_Plan__c(
            Service_Assignment__c = testData.theSA.id,
            Target_Date__c = testData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = testData.theSA.start_Date__c
        );        
        insert ap; 
        
        Action_Plan_Goal__c apg = new Action_Plan_Goal__c(
            Description__c = 'a goal',
            Action_Plan__c = ap.id,
            sort_order__c = 'g'
        );
        insert apg;
        
        Action_Plan_Objective__c apo = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'an Objective',
            Type__c = 'skill',
            Target_End_Date__c = testData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = testData.theSA.Start_Date__c,
            sort_order__c = 'o'
        );
        insert apo;
        
        Action_Plan_Action__c apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.Start_Date__c = testData.theSA.Start_Date__c;
        apa.End_Date__c = testData.theSA.Start_Date__c.addDays(1);
        apa.Status__c = 'New';
        insert apa;
        
        return ap;
    }
    
}