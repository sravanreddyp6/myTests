@isTest
public with sharing class Report_CANS_OverdueAssessments_Test {
	static testmethod void simpleTests() {
		Report_CANS_OverdueAssessments controller = new Report_CANS_OverdueAssessments();
		System.assertEquals(0, controller.assessments.size());
	}
}