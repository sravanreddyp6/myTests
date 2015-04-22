@isTest
public with sharing class CareMeridianEvaluationViewTest {
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
        CareMeridianEvaluationViewController controller = new CareMeridianEvaluationViewController(new ApexPages.StandardController(evaluation));
        System.assertNotEquals(0, controller.sliderOptions.size());
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