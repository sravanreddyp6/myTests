@isTest
public with sharing class ActionSummaryCreateFormV2Tests {
	public static testmethod void simpleTests() {
		Action_Summary__c summary = new Action_Summary__c();
		ActionSummaryCreateFormV2 controller = new ActionSummaryCreateFormV2(
			new ApexPages.standardController(summary)
		);
	}
}