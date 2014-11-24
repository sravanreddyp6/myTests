@isTest
public with sharing class EvaluationViewControllerTests {
    public static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(
            Person_Being_Referred__c=pbr.Id
        );
        insert referral;
        Evaluation__c eval = new Evaluation__c(
            Referral__c = referral.Id,
            RecordTypeId = Utility.getEvaluationRecordType('NeuroRestorative')
        );
        insert eval;
        EvaluationViewController controller = new EvaluationViewController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/NeuroEvaluationView?id='+eval.id,
            controller.redirect().getUrl()
        );

        eval = new Evaluation__c(
            Referral__c = referral.Id,
            RecordTypeId = Utility.getEvaluationRecordType('NursesAssessment')
        );
        insert eval;
        controller = new EvaluationViewController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/NursingEvaluationView?id='+eval.id,
            controller.redirect().getUrl()
        );

        eval = new Evaluation__c(
            Referral__c = referral.Id,
            RecordTypeId = Utility.getEvaluationRecordType('CareMeridian')
        );
        insert eval;
        controller = new EvaluationViewController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/CareMeridianEvaluationView?id='+eval.id,
            controller.redirect().getUrl()
        );
    }
}