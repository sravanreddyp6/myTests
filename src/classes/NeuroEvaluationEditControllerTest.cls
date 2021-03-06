@isTest
public with sharing class NeuroEvaluationEditControllerTest {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(
            Referral__c=referral.Id,
            Hallucination_Types__c='Auditory;Visual'
        );
        insert evaluation;
        Related_party__c rp = new Related_Party__c(
            Name='Test Party',
            Type__c='Guardian',
            Person_Being_Referred__c=pbr.Id
        );
        insert rp;
        evaluation = [
            SELECT Id, Referral__c, Referral__r.Person_Being_Referred__c,
                   RecordtypeId, Primary_Diagnosis__c, Secondary_Diagnosis__c,
                   Date_of_Injury_Onset__c, Hallucination_Types__c,
                   Hallucinations__c, Neuro_Pain_Alleviating_Factors__c
            FROM Evaluation__c WHERE Id=:evaluation.Id
        ];
        NeuroEvaluationEditController controller = new NeuroEvaluationEditController(new ApexPages.StandardController(evaluation));
        System.assertNotEquals(0, controller.mobilitySliderOptions.size());
        System.assertNotEquals(0, controller.selfCareSliderOptions.size());
        System.assertNotEquals(0, controller.communicationSliderOptions.size());
        System.assertNotEquals(0, controller.hallValues.size());
        System.assertNotEquals(null, controller.baseUrl);
        System.assertEquals(0, controller.annotations.size());
        System.assertNotEquals(null, controller.relatedParties);
        controller.showAddRelatedParty();
        System.assertEquals(null, controller.currentRelatedParty.Id);
        controller.currentRelatedPartyId = rp.Id;
        controller.showEditRelatedParty();
        System.assertEquals(rp.Id, controller.currentRelatedParty.Id);
        controller.currentRelatedParty.Name = 'New Name';
        controller.saveRelatedParty();

        NeuroEvaluationEditController.addOrModifyAnnotation(null, '', 1, 1, 1, 1, '', '', evaluation.Id);
        Evaluation_Response__c[] annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
        System.assertEquals(1, annotations.size());
        NeuroEvaluationEditController.addOrModifyAnnotation(annotations[0].Id, '', 2, 2, 2, 2, '', '', evaluation.Id);
        NeuroEvaluationEditController.deleteAnnotation(annotations[0].Id);
        annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
        System.assertEquals(0, annotations.size());
        controller.nextTab = 'diagsnosticTab';
        controller.changeTab();
        controller.save();
    }
}