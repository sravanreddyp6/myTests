@isTest
public with sharing class ReferralTrigger_Helper_Tests {
    static testmethod void testHighRisk() {
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Arizona', 'New', 'Test123', pbr);
        ref.Physically_Aggressive_to_Peers__c = true;
        update ref;
        ref = [
            SELECT ID, High_Risk__c, Red_Flag_Description_Boolean__c, Red_Flag_Description_Other__c
            FROM Referral__c WHERE Id=:ref.Id
        ];
        System.assertEquals(true, ref.High_Risk__c);
        System.assertEquals(Referral__c.Physically_Aggressive_to_Peers__c.getDescribe().getLabel(),
            ref.Red_Flag_Description_Boolean__c);
        System.assertEquals(null, ref.Red_Flag_Description_Other__c);
        // Reverse it
        ref.Physically_Aggressive_to_Peers__c = false;
        update ref;
        ref = [
            SELECT ID, High_Risk__c, Red_Flag_Description_Boolean__c, Red_Flag_Description_Other__c
            FROM Referral__c WHERE Id=:ref.Id
        ];
        System.assertEquals(false, ref.High_Risk__c);
        System.assertEquals(null, ref.Red_Flag_Description_Boolean__c);
        System.assertEquals(null, ref.Red_Flag_Description_Other__c);
        // Non-boolean stuffs
        ref = Referral_CreateTestData.createReferral('California', 'New', 'Test123', pbr);
        ref.Restricted_Health_Conditions__c = 'test';
        update ref;
        ref = [
            SELECT ID, High_Risk__c, Red_Flag_Description_Boolean__c, Red_Flag_Description_Other__c
            FROM Referral__c WHERE Id=:ref.Id
        ];
        System.assertEquals(true, ref.High_Risk__c);
        System.assertEquals(null, ref.Red_Flag_Description_Boolean__c);
        System.assertEquals(Referral__c.Restricted_Health_Conditions__c.getDescribe().getLabel() + ': test',
            ref.Red_Flag_Description_Other__c);
    }
}