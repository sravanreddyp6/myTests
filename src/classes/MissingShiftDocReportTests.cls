@isTest
public with sharing class MissingShiftDocReportTests {
	public static testmethod void simpleTests() {
		MissingShiftDocReport controller = new MissingShiftDocReport();
		controller.runReport();  // this will generate errors because start date is later than end date
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(3);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(1);
		controller.runReport();

		// Generate test data here
		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		Id nsdRecordTypeId = Utility.getEvaluationRecordType('CMShiftAssessment');
		Id cnaRecordTypeId = Utility.getEvaluationRecordType('CNA Workbook');
		insert new Evaluation__c[] {
			new Evaluation__c(
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(-4),
				Shift_End_Time__c = Date.Today().addDays(-2),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this won't be included because of Status
				RecordTypeId = cnaRecordTypeId,
				Status__c = 'Final',
				Shift_Start_Time__c = Date.Today().addDays(-3),
				Shift_End_Time__c = Date.Today().addDays(-3),
				ServiceAssignment__c = myData.theSA.Id
			)
		};

		controller = new MissingShiftDocReport();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.rightSelectedPrograms.add((String) controller.rightPrograms[0].getValue());
		controller.removePrograms();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(-5);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today();
		controller.selectedPbs = new Id[]{ myData.theSA.Id };
		controller.runReport(); // this will run correctly
	}
}