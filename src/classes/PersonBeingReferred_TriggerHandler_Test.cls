/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PersonBeingReferred_TriggerHandler_Test {

    static testMethod void PersonBeingServedAgeUpdateTest() { 
    	test.startTest();
    	Person_Being_Referred__c noAge = Referral_CreateTestData.createPersonBeingReferred(null, Date.today().addYears(-18));
     	system.assert(noAge.Age__c == 18);

    	Person_Being_Referred__c ageOnly = Referral_CreateTestData.createPersonBeingReferred(18, null);
    	system.assert(ageOnly.Age__c == 18);
 
     	Person_Being_Referred__c ageAndDate = Referral_CreateTestData.createPersonBeingReferred(18, Date.today().addYears(-20));
    	system.assert(ageAndDate.Age__c == 20);
    	test.stopTest();
    }
}