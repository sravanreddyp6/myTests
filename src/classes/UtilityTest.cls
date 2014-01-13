@isTest
public with sharing class UtilityTest {
    static testmethod void simpleTests() {
        System.assertNotEquals(null, Utility.getEvaluationResponseRecordType('Allergy'));
    }
}