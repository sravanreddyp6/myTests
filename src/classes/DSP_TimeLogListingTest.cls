@isTest
private class DSP_TimeLogListingTest {
    private static TMN_Generic_Core_TestData myData;
    
    static testMethod void myUnitTest() {
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            myData.loadData('IA');
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'TimeLog';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(myData.theSA.Id);
            insert txn;
            
            PageReference pageRef = Page.DSP_TimeLogListing;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            
            TxnQueueResponseController controller = new TxnQueueResponseController();
            DSP_TimeLogListing extension = new DSP_TimeLogListing(controller);
            
            system.assert(extension.pbsId != null);
        }
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }
}