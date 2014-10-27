@isTest
public with sharing class UtilityTest {
    static testmethod void simpleTests() {
    	
    	Id RecId = [ SELECT r.Id, r.Name, r.DeveloperName FROM RecordType r WHERE sObjectType = 'Referral__c'AND DeveloperName='CareMeridian_R'].Id;
    	Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id, RecordTypeId= RecId);
        insert referral;
        system.assertNotEquals(null, Utility.getRelatedPartyRecordTypeFromReferral(referral));
        system.assertNotEquals(null,Utility.getFundingSourceRecordTypeFromReferral(referral));
        system.assertEquals('CareMeridian',Utility.getRecordTypeForReferral(RecID));
        system.assertNotEquals(null,Utility.getRecordTypeNameForReferralObject(referral));
        system.assertNotEquals(null,Utility.getRecordTypeForReferral('CareMeridian'));
        system.assertNotEquals(null,Utility.getRecordTypeForTask('Referral Tasks'));
        system.assertNotEquals(null,Utility.getRecordTypeForFundingSource('CareMeridian'));
        system.assertNotEquals(null, Utility.getEvaluationResponseRecordType('Allergy'));
        system.assertNotEquals(null,Utility.getEValuationRecordType('NursesAssessment'));
        system.assertNotEquals(null,Utility.getRelatedPartyRecordType('CareMeridian'));
        system.assertEquals('Florida',Utility.getStateNameFromCode('FL'));
        system.assertEquals('FL',Utility.getStateCodeFromName('Florida'));
        Evaluation__c evaluation = new Evaluation__c();
        system.assertNotEquals(null,Utility.getPicklistValues(evaluation, 'Family_Communication_Status__c'));
    }
}