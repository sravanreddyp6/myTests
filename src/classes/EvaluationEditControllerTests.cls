@isTest
public with sharing class EvaluationEditControllerTests {
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
        EvaluationEditController controller = new EvaluationEditController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/NeuroEvaluationEdit?id='+eval.id,
            controller.redirect().getUrl()
        );

        eval = new Evaluation__c(
            Referral__c = referral.Id,
            RecordTypeId = Utility.getEvaluationRecordType('NursesAssessment')
        );
        insert eval;
        controller = new EvaluationEditController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/NursingEvaluationEdit?id='+eval.id,
            controller.redirect().getUrl()
        );

        eval = new Evaluation__c(
            Referral__c = referral.Id,
            RecordTypeId = Utility.getEvaluationRecordType('CareMeridian')
        );
        insert eval;
        controller = new EvaluationEditController(
            new ApexPages.StandardController(eval)
        );
        System.assertEquals(
            '/apex/CareMeridianEvaluationEdit?id='+eval.id,
            controller.redirect().getUrl()
        );
        
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        eval = new Evaluation__c(
        	ServiceAssignment__c = testData.theSA.Id,
        	RecordTypeId = Utility.getEvaluationRecordType('CMShiftAssessment'),
        	Status__c = 'Draft',
        	OwnerId = UserInfo.getUserId()
        );
        insert eval;
        controller = new EvaluationEditController(
            new ApexPages.StandardController(eval)
        );
      
        System.assertEquals(
            '/apex/CMShiftAssessmentEdit?id='+eval.id,
            controller.redirect().getUrl()
        );
        
    }
}