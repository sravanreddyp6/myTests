@isTest
public with sharing class Report_PBS_Weight_Tests {
	static testmethod void simpleTest() {
		Report_PBS_Weight controller = new Report_PBS_Weight();
		controller.runReport();  // this will generate errors because of blank start/end dates
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(1);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(3);
		controller.runReport(); // this will generate errors because of invalid start/end dates
	}
}