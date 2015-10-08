@isTest
public with sharing class ActionPlanSummaryViewTests {
	public static testmethod void simpleTests() {
		Action_Summary__c summary;
		ActionPlanSummaryView controller;
		PageReference reference;

		summary = new Action_Summary__c(
			Start_Date__c = Date.Today().addDays(-5),
			End_Date__c = Date.Today().addDays(5)
		);
		insert summary;
		controller = new ActionPlanSummaryView(
			new ApexPages.standardController(summary)
		);
		reference = controller.redirect();
		System.assertEquals(-1, reference.getUrl().indexOf('V2'));

		summary.New_Version__c = true;
		update summary;
		controller = new ActionPlanSummaryView(
			new ApexPages.standardController(summary)
		);
		reference = controller.redirect();
		System.assertNotEquals(-1, reference.getUrl().indexOf('V2'));
	}
}