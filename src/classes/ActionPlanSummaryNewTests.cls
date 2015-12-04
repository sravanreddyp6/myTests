@isTest
public with sharing class ActionPlanSummaryNewTests {
	public static testmethod void simpleTests() {
		User tester = Referral_createTestData.createTestUser(
			'astest', 'astest@test.com', 'Action', 'Summary', 'Redwood'
		);
		tester.Operating_Group__c = 'Redwood';
		update tester;
		Action_Summary__c summary;
		ActionPlanSummaryNew controller;
		PageReference reference;

		System.runAs(tester) {
			summary = new Action_Summary__c();
			controller = new ActionPlanSummaryNew(
				new ApexPages.standardController(summary)
			);
			reference = controller.redirect();
			System.assertEquals(-1, reference.getUrl().indexOf('V2'));
		}
		tester = Referral_createTestData.createTestUser(
			'astest', 'astest@test.com', 'Action', 'Summary', 'Care Meridian'
		);
		tester.Operating_Group__c = 'Care Meridian';
		update tester;
		System.runAs(tester) {
			summary = new Action_Summary__c();
			controller = new ActionPlanSummaryNew(
				new ApexPages.standardController(summary)
			);
			reference = controller.redirect();
			System.assertNotEquals(-1, reference.getUrl().indexOf('V2'));
		}
	}
}