@isTest
public with sharing class NeuroEvaluationViewControllerTest {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id);
        insert evaluation;
        Related_party__c rp = new Related_Party__c(
            Name='Test Party',
            Type__c='Guardian',
            Person_Being_Referred__c=pbr.Id
        );
        insert rp;
        NeuroEvaluationViewController controller = new NeuroEvaluationViewController(new ApexPages.StandardController(evaluation));
        System.assertNotEquals(0, controller.mobilitySliderOptions.size());
        System.assertNotEquals(0, controller.selfCareSliderOptions.size());
        System.assertNotEquals(0, controller.communicationSliderOptions.size());
        System.assertEquals(null, controller.bodyMapUrl);
        System.assertEquals(0, controller.annotations.size());
        System.assertNotEquals(null, controller.relatedParties);
        controller.showAddRelatedParty();
        System.assertEquals(null, controller.currentRelatedParty.Id);
        controller.currentRelatedPartyId = rp.Id;
        controller.showEditRelatedParty();
        System.assertEquals(rp.Id, controller.currentRelatedParty.Id);
        controller.currentRelatedParty.Name = 'New Name';
        controller.saveRelatedParty();
    }
}