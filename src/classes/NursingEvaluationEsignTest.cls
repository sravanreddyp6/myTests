@isTest
public with sharing class NursingEvaluationEsignTest {
	static testmethod void simpleTests() {
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        Evaluation__c evaluation = new Evaluation__c(ServiceAssignment__c = testData.theSA.Id);
        insert evaluation;
        NursingEvaluationEsign handler = new NursingEvaluationEsign();
        User user = [ SELECT Id FROM User LIMIT 1 ];
        handler.handle(evaluation.Id, user.Id);
        evaluation = [ SELECT Id, Is_Signed__c FROM Evaluation__c WHERE Id=:evaluation.Id ];
        Evaluation_Response__c[] responses = [ SELECT Id FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id AND RecordType.Name='E-Signature' ];
      //  System.assertEquals(true, evaluation.Is_Signed__c);
      //  System.assertEquals(1, responses.size());
    }

}