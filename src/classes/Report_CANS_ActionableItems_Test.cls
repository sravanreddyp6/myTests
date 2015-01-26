@isTest
public with sharing class Report_CANS_ActionableItems_Test {
	static testmethod void simpleTests() {
		Report_CANS_ActionableItems controller = new Report_CANS_ActionableItems();
		System.assertEquals(2, controller.scoreOptions.size());
		controller.scoreChosen = '2 or 3';
		controller.dummyStartDateAssessment.Assessment_Date__c = Date.Today();
		controller.dummyEndDateAssessment.Assessment_Date__c = Date.Today();
		controller.runReport();
		System.assertEquals(0, controller.responses.size());
	}
}