@isTest
public with sharing class ActionSummaryCreateFormV2Tests {
    public static testmethod void simpleTests() {
        TMN_Generic_Core_TestData testD = new TMN_Generic_Core_TestData ();
        Action_Summary__c summary = new Action_Summary__c(Service_Assignment__c = testD.theSA.id );
        ActionSummaryCreateFormV2 controller = new ActionSummaryCreateFormV2(
            new ApexPages.standardController(summary)
        );
    }
}