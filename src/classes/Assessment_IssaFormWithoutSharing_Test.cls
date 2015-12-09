@isTest
private class Assessment_IssaFormWithoutSharing_Test {
    private static TMN_Generic_Core_TestData myData;
    
    static testMethod void myUnitTestForInvalidTxn() {
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            myData.loadData('MN');
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'ISSA';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(string.valueOf(myData.theAdm.Id));
            try {
	            insert txn;  // a dmlException will be thrown here since there is no ISSA created yet. 
	            PageReference pageRef = Page.DSP_Assessment_ISSAForm;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('txnID', txn.ID);
	            TxnQueueResponseController controller = new TxnQueueResponseController();
                throw new DataCreate.DataCreateException('We should have never come to this line of code.');
			} catch(DMLException e) {
                system.assert(true);
            } catch(Exception e) {
                throw e ;
			} 
        }
    }
    
    static testMethod void myUnitTest() {
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            myData.loadData('MN');
            
            //create ISSA assessment
            createAssessData();
            Assessment__c myIssa = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'ISSA', null, null, false);
            List<Assessment_Response__c> ars = [ SELECT Response__c, Rating__c FROM Assessment_Response__c WHERE Assessment__c = : myIssa.Id ];
            for(Assessment_Response__c ar : ars) {
                ar.Response__c = 'TEST';
                ar.Rating__c = 'Yes';
            }
            update ars;
            myIssa.Status__c = 'Active Final';
            myIssa.Approval_Date__c = date.newInstance(2014, 01, 01);
            update myIssa;
            
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'ISSA';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(string.valueOf(myData.theAdm.Id));
            
            insert txn;  
            PageReference pageRef = Page.DSP_Assessment_ISSAForm;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            TxnQueueResponseController controller = new TxnQueueResponseController();

            system.assert(controller.assessmentIssaResponse != null);
            system.assert(controller.assessmentIssaResponse.getMapCurrentResps() != null);
            system.assert(controller.assessmentIssaResponse.getAssessmentWrapper() != null);
            system.assert(controller.assessmentIssaResponse.getMapQuestions() != null);
            system.assert(controller.assessmentIssaResponse.getmapDomainHasRisk() != null);
            system.assert(controller.assessmentIssaResponse.getDomainsInScope().size() > 0);
            
            DSPSubmitTxn extension = new DSPSubmitTxn(controller);
            pageRef = extension.ackAssessment();
            Test.setCurrentPage(pageRef);
            controller = new TxnQueueResponseController();
            extension = new DSPSubmitTxn(controller);
            
            // assert that the ack recrod exists for this assessment, and the page after ACK was indeed the ISSA page.
            system.assert(pageRef.getRedirect());
	        system.assert(pageRef.getUrl().containsIgnoreCase('DSP_Assessment_ISSAForm'));
	        system.assert(controller.assessmentIssaResponse.ackwrapList.size() == 1);
        }
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }
    public static void createAssessData(){
        Assessment_Domain__c testDomain = new Assessment_Domain__c(Name = 'Other', Assessment_Type2__c = 'ISSA');
        insert testDomain;
        Assessment_Question__c testQuestion = new Assessment_Question__c(Question_Title__c = 'TEST QUESTION',Question_Description__c = 'A TEST QUESTION',Question_Domain__c = testDomain.Id);
        insert testQuestion;   
        Assessment_Question_Option__c op1 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = 'Presents a Risk');
        insert op1;
        Assessment_Question_Option__c op2 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = 'Does Not Present a Risk');
        insert op2;            
    }
    
}