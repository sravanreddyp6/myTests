@isTest
private class DSP_PbsSeizureListing_Test {
    private static TMN_Generic_Core_TestData myData;
    
    static testMethod void myUnitTest() {
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            myData.loadData('MN');
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Seizures';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(myData.ContactID);
            insert txn;
            
            PageReference pageRef = Page.DSP_PbsSeizureListing;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            
            TxnQueueResponseController controller = new TxnQueueResponseController();
            DSP_PbsSeizureListing extension = new DSP_PbsSeizureListing(controller);
            
            system.assert(extension.getSeizuresWrapper().size() == 0);
            system.assert(extension.getIsRwMN());
            
            String stStartTime = extension.seizure.seizureStart_DateTime = Datetime.now().addHours(-5).format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
            String stEndTime = extension.seizure.seizureEnd_DateTime = Datetime.now().addHours(-4).format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
            extension.seizure.observedByNameC = 'test';
            extension.seizure.comments = 'comments';
            
            pageRef = extension.saveSeizure();
            Test.setCurrentPage(pageRef);
            controller = new TxnQueueResponseController();
            extension = new DSP_PbsSeizureListing(controller);
            
            system.assert(extension.getSeizuresWrapper().size() == 1);
            system.assert(extension.getSaOptions().size() == 1);
            
            pageRef.getParameters().put('seizureId', extension.getSeizuresWrapper()[0].Id);
            
            extension.showEditSeizure();
            system.assert(extension.seizure.observedByNameC == UserInfo.getName());
            system.assert(DSP_PbsSeizureListing.findDuplicateSeizure(stStartTime, stEndTime, Id.ValueOf(extension.seizure.serviceAssignmentId), null) );
            
        }
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }
}