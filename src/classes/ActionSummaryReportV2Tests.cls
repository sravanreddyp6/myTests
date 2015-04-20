@isTest
public with sharing class ActionSummaryReportV2Tests {
	public static testmethod void simpleTests() {
		Action_Summary__c summary = new Action_Summary__c();
		insert summary;
		ActionSummaryReportV2 controller = new ActionSummaryReportV2(
			new ApexPages.standardController(summary)
		);
	}
}