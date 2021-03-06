@isTest
public with sharing class CareMeridianEvaluationEditTest {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id,Primary_Diagnosis__c='Test',RecordTypeId=Utility.getEValuationRecordType('CareMeridian'), Date_of_Injury_Onset__c = system.today());
        insert evaluation;
        Related_party__c rp = new Related_Party__c(
            Name='Test Party',
            Type__c='Guardian',
            Person_Being_Referred__c=pbr.Id
        );
        insert rp;
        evaluation = [
            SELECT Id, Referral__c, Referral__r.Person_Being_Referred__c, Referral__r.Person_Being_Served__c, RecordtypeId, Primary_Diagnosis__c, Secondary_Diagnosis__c, Date_of_Injury_Onset__c
            FROM Evaluation__c WHERE Id=:evaluation.Id
        ];
        CareMeridianEvaluationEditController controller = new CareMeridianEvaluationEditController(
            new ApexPages.StandardController(evaluation)
        );
        System.assertNotEquals(0, controller.getSliderOptions().size());
        System.assertEquals(0, controller.getAnnotations().size());
        System.assertNotEquals(null, controller.getRelatedParties());
        controller.showAddRelatedParty();
        System.assertEquals(null, controller.currentRelatedParty.Id);
        controller.currentRelatedPartyId = rp.Id;
        controller.showEditRelatedParty();
        System.assertEquals(rp.Id, controller.currentRelatedParty.Id);
        controller.currentRelatedParty.Name = 'New Name';
        controller.saveRelatedParty();
        CareMeridianEvaluationEditController.addOrModifyAnnotation(null, '', 1, 1, 1, 1, '', '', evaluation.Id);
        Evaluation_Response__c[] annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
        System.assertEquals(1, annotations.size());
        CareMeridianEvaluationEditController.addOrModifyAnnotation(annotations[0].Id, '', 2, 2, 2, 2, '', '', evaluation.Id);
        CareMeridianEvaluationEditController.deleteAnnotation(annotations[0].Id);
        annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
        System.assertEquals(0, annotations.size());
        controller.nextTab = 'diagsnosticTab';
        controller.changeTab();
        controller.save();
        referral = [SELECT ID, Date_of_Injury__c FROM Referral__c WHERE Id=:evaluation.Referral__c];
        system.assertEquals(system.today(),referral.Date_of_Injury__c);
    }
}