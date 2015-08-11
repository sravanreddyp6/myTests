@isTest
public with sharing class IncompleteShiftDocReportTests {
	public static testmethod void simpleTests() {
		IncompleteShiftDocReport controller = new IncompleteShiftDocReport();
		controller.runReport();  // this will generate errors because of blank start/end dates
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(1);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(3);
		controller.runReport(); // this will generate errors because of invalid start/end dates

		// Generate test data here
		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		Id nsdRecordTypeId = Utility.getEvaluationRecordType('CMShiftAssessment');
		Id cnaRecordTypeId = Utility.getEvaluationRecordType('CNA Workbook');
		insert new Evaluation__c[] {
			new Evaluation__c(  // this will be included
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(2),
				Shift_End_Time__c = Date.Today().addDays(3),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this won't be included because of Status
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Final',
				Shift_Start_Time__c = Date.Today().addDays(2),
				Shift_End_Time__c = Date.Today().addDays(3),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this will be included
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(-1),
				Shift_End_Time__c = Date.Today(),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this will be included
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(-5),
				Shift_End_Time__c = Date.Today().addDays(5),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this will be included
				RecordTypeId = nsdRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(1),
				Shift_End_Time__c = Date.Today().addDays(2),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(  // this will be included
				RecordTypeId = cnaRecordTypeId,
				Status__c = 'Draft',
				Shift_Start_Time__c = Date.Today().addDays(2),
				Shift_End_Time__c = Date.Today().addDays(3),
				ServiceAssignment__c = myData.theSA.Id
			)
		};

		controller = new IncompleteShiftDocReport();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.rightSelectedPrograms.add((String) controller.rightPrograms[0].getValue());
		controller.removePrograms();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.dummyEvaluation.Evaluation_date__c = Date.Today();
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(2);
		controller.selectedPbs = new Id[]{ myData.theSA.Id };
		controller.runReport(); // this will run correctly
		System.assertEquals(5, controller.shiftDocs.size());
	}
}