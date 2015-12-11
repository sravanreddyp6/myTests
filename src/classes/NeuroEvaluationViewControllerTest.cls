@isTest
public with sharing class NeuroEvaluationViewControllerTest {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c(Last_Name__c = 'Test PBR',
                                                                    Date_of_Birth__c = Date.newInstance(1980, 11, 11),
                                                                    age__c = 25);
        insert pbr;        
        
        pbr = [SELECT ID, Date_of_Birth__c,Age_year__c,Age_month__c,Age_days__c,Age__c,Age_text__c FROM Person_Being_Referred__c
               WHERE Id=: pbr.Id];
        
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
        evaluation = [select id, Hallucination_Types__c, Referral__r.Person_Being_Referred__c, Referral__r.Person_Being_Referred__r.Full_Name__c from Evaluation__c where Id =: evaluation.Id];
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