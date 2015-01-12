@isTest
public with sharing class CMShiftAssessmentEsignTest {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id);
        insert evaluation;
        CMShiftAssessmentEsign handler = new CMShiftAssessmentEsign();
        User user = [ SELECT Id FROM User LIMIT 1 ];
        handler.handle(evaluation.Id, user.Id);
        evaluation = [ SELECT Id, Is_Signed__c FROM Evaluation__c WHERE Id=:evaluation.Id ];
        Evaluation_Response__c[] responses = [ SELECT Id FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id AND RecordType.Name='E-Signature' ];
        System.assertEquals(true, evaluation.Is_Signed__c);
        System.assertEquals(1, responses.size());
    }
}