@isTest
private class DSPPersonBeingServed_WithoutSharing_Test {
    private static TMN_Generic_Core_TestData testData;
    
    static testMethod void myUnitTestNoReleatedData() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            createData();
            
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Person Being Served';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(testData.ContactID);
            insert txn;
            
            PageReference pageRef = Page.DSPPersonBeingServedView;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            
            TxnQueueResponseController controller = new TxnQueueResponseController();
            
            system.assert(controller.pbsViewResponse.PBSId == testData.ContactID);
            system.assert(controller.pbsViewResponse.relPartiesWrapper.size() == 0);
            system.assert(controller.pbsViewResponse.diaglist.size() == 0);
        }
    }
    static testMethod void myUnitTest() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            createData();
            
            //created a related party, Diagnosis and one of evaluation response types
            Related_Party__c relParty = new Related_Party__c ( Name='rp name', type__c = 'Guardian', Person_Being_Served__c = testData.ContactID); insert relParty; 
            ICD__c icd = new ICD__c(Code_Type__c = 'ICD-10', Icd_Description__c = 'testing'); insert icd;
            Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active', Type__c = 'Admission', PBS__c  = testData.ContactID, ICD__c = icd.Id); insert diag;
            
	        List<RecordType> rt = [select id from RecordType where DeveloperName = 'Allergy' and sObjectType = 'Evaluation_Response__c' limit 1];
	        insert new Evaluation_Response__c(Person_Being_Served__c = testData.ContactID, RecordTypeId = rt[0].Id, Allergy_type__c = 'Food', Allergy_Details__c = 'Rice', Life_Threatening__c = false);
            
            Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
            txn.request_type__c = 'Person Being Served';
            txn.requested_date_time__c = DateTime.Now();
            txn.input_params__c = string.valueOf(testData.ContactID);
            insert txn;
            
            PageReference pageRef = Page.DSPPersonBeingServedView;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('txnID', txn.ID);
            
            TxnQueueResponseController controller = new TxnQueueResponseController();
            
            system.assert(controller.pbsViewResponse.PBSId == testData.ContactID);
            system.assert(controller.pbsViewResponse.relPartiesWrapper.size() == 1);
            system.assert(controller.pbsViewResponse.diaglist.size() == 1);
            system.assert(controller.pbsViewResponse.getMapEvalResponses().containsKey('Allergy'));
            system.assert(controller.pbsViewResponse.getmapEvalResponseFldLbls() != null);
            system.assert(controller.pbsViewResponse.getmapEvalResponseFlds() != null);
        }
    }
    
    private static void createData(){
        testData = new TMN_Generic_Core_TestData();
    }
    
}