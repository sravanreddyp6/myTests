@isTest
private class Assessment_RiskFormWithoutSharing_Test {
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
            txn.request_type__c = 'Risk';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(string.valueOf(myData.theAdm.Id));
            try {
                insert txn;  // a dmlException will be thrown here since there is no Risk assessment created yet. 
                PageReference pageRef = Page.DSP_Assessment_RiskForm;
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
        User tester = Referral_createTestData.createTestUser(
            'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
        );
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            createData();
            myData.loadData('MN');
            
            //create RISK assessment
	        Assessment_Type__c testAssmtType = new Assessment_Type__c(
	            Name = 'RISK'           
	        );
	        insert testAssmtType;
	        
	        Assessment_Domain__c testDomain = new Assessment_Domain__c(
	            Name = 'TEST DOMAIN',
	            Assessment_Type__c = testAssmtType.Id
	        );
	        insert testDomain;
	        
	        Assessment_Question__c testQuestion = new Assessment_Question__c(
	            Question_Title__c = 'TEST QUESTION',
	            Question_Description__c = 'A TEST QUESTION',
	            Question_Domain__c = testDomain.Id
	        );
	        insert testQuestion;
	   
	        Assessment__c assessment = new assessment__c(Assessment_Type__c = testAssmtType.id, Admission__c = myData.theAdm.id, Assessment_Date__c = myData.theSA.Start_Date__c, Service_Assignment__c = myData.theSA.id);      
	        insert (assessment);
        
            List<Assessment_Response__c> ars = [ SELECT Response__c, Rating__c FROM Assessment_Response__c WHERE Assessment__c = : assessment.Id ];
            for(Assessment_Response__c ar : ars) {
                ar.Response__c = 'TEST';
                ar.Rating__c = 'Presents a Risk';
            }
            update ars;
            assessment.Status__c = 'Active Final';
            assessment.Approval_Date__c = date.newInstance(2014, 01, 01);
            update assessment;
            
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Risk';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(string.valueOf(myData.theAdm.Id));
            
            insert txn;  
            PageReference pageRef = Page.DSP_Assessment_RiskForm;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            TxnQueueResponseController controller = new TxnQueueResponseController();

            system.assert(controller.assessmentResponse != null);
            system.assert(controller.assessmentResponse.getMapCurrentResps() != null);
            system.assert(controller.assessmentResponse.getAssessmentWrapper() != null);
            system.assert(controller.assessmentResponse.getMapQuestions() != null);
            system.assert(controller.assessmentResponse.getDomainsInScope().size() > 0);
            
            system.assert(controller.assessmentResponse.getLevel_Required_ResidentialServices().size() == 0);
            system.assert(controller.assessmentResponse.getLevel_Required_DayServices().size() == 0);
            
            DSPSubmitTxn extension = new DSPSubmitTxn(controller);
            pageRef = extension.ackAssessment();
            Test.setCurrentPage(pageRef);
            controller = new TxnQueueResponseController();
            extension = new DSPSubmitTxn(controller);
            
            // assert that the ack recrod exists for this assessment, and the page after ACK was indeed the Risk page.
            system.assert(pageRef.getRedirect());
            system.assert(pageRef.getUrl().containsIgnoreCase('DSP_Assessment_RiskForm'));
            system.assert(controller.assessmentResponse.ackwrapList.size() == 1);
            
            
        }
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }
    
}