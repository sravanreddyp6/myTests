@isTest
public with sharing class ActionSummaryReportV2Tests {
    public static testmethod void simpleTests() {
        Action_Summary__c summary = new Action_Summary__c(End_Date__c = system.today(), Start_date__c = system.today() );
        insert summary;
        ActionSummaryReportV2 controller = new ActionSummaryReportV2(
            new ApexPages.standardController(summary)
        );
    }
}