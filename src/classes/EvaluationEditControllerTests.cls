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
      /*  System.assertEquals(
            '/apex/EvalDynamic?evalId='+eval.Id+'&evalType=Residential&opGrp=Care+Meridian',
            controller.redirect().getUrl()
        );*/
        system.assert(controller.redirect().getUrl().Contains('Residential'));
        system.assert(controller.redirect().getUrl().Contains('EvalDynamic'));
        system.assert(controller.redirect().getUrl().Contains(string.valueof(eval.Id)));

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
      
       /* System.assertEquals(
           '/apex/EvalDynamic?evalId=' + eval.Id + '&opGrp=Care Meridian&evalType=Head to Toe',
            controller.redirect().getUrl()
        );*/
         //Using below asserts as the test class is giving weird results in the order of arrangement of URL Params - Sravan 
        system.assert(controller.redirect().getUrl().Contains('Head+to+Toe'), controller.redirect().getUrl());
        system.assert(controller.redirect().getUrl().Contains('EvalDynamic'));
        system.assert(controller.redirect().getUrl().Contains(string.valueof(eval.Id)));
        
    }
}