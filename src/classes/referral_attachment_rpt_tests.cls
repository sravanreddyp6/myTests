@isTest
public with sharing class referral_attachment_rpt_tests {
	static testmethod void simpleTests() {
		Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(
			30,
			Date.valueOf('1983-01-01')
		);
		Referral__c referral = Referral_CreateTestData.createReferral(
			'California',
			'Active',
			'Conversion Test',
			'CA',
			pbr
		);
		insert new Attachment(
			ParentId=referral.Id,
			Name='PlanOfCare-1.txt',
			Body=Blob.valueOf('Test Body')
		);
		referral_attachment_rpt controller = new referral_attachment_rpt();
		controller.runReport();  // error because of no start/end date
		controller.startDate = Date.newInstance(2015, 06, 01);
		controller.endDate = Date.newInstance(2015, 05, 31);
		controller.runReport();  // error because start time > end time
		controller.startDate = Date.Today().addDays(-2);
		controller.endDate = Date.Today().addDays(2);
		controller.runReport();
		System.assertEquals(1, controller.numFiles);
	}
}