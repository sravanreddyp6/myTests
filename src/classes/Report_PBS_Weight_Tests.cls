@isTest
public with sharing class Report_PBS_Weight_Tests {
	static testmethod void simpleTest() {
		Report_PBS_Weight controller = new Report_PBS_Weight();
		controller.runReport();  // this will generate errors because of blank start/end dates
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(1);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(3);
		controller.runReport(); // this will generate errors because of invalid start/end dates

		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		Id residentialRecordTypeId = Utility.getEvaluationRecordType('NursesAssessment');
		Id cnaRecordTypeId = Utility.getEvaluationRecordType('CNA Workbook');
		Evaluation__c[] evaluations = new Evaluation__c[]{
			new Evaluation__c(
				RecordTypeId = residentialRecordTypeId,
				Status__c = 'Final',
				Shift_Start_Time__c = Date.Today().addDays(-2),
				Shift_End_Time__c = Date.Today().addDays(-1),
				ServiceAssignment__c = myData.theSA.Id
			),
			new Evaluation__c(
				RecordTypeId = cnaRecordTypeId,
				Status__c = 'Final',
				Shift_Start_Time__c = Date.Today().addDays(-2),
				Shift_End_Time__c = Date.Today().addDays(-1),
				ServiceAssignment__c = myData.theSA.Id
			)
		};
		insert evaluations;

		Eval_type__c[] evalTypes = new Eval_Type__c[] {
			new Eval_Type__c(
				Name = 'Residential',
				Category__c = 'Care Meridian'
				),
			new Eval_Type__c(
				Name = 'CNA Workbook',
				Category__c = 'Care Meridian'
			)
		};
		insert evalTypes;

		Eval__c[] evals = new Eval__c[] {
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Diagnostics',
				Sub_Category__c = 'Vitals Signs',
				Field_Name__c = 'Weight At Admission',
				htmlid__c = 'weightAtAdmission'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Diagnostics',
				Sub_Category__c = 'Vitals Signs',
				Field_Name__c = 'Signs Date/Time',
				htmlid__c = 'signsDateTime'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'Diagnostics',
				Sub_Category__c = 'Vitals Signs',
				Field_Name__c = 'Height At Admission',
				htmlid__c = 'heightAtAdmission'
				)
		};
		insert evals;
		DateTime now = DateTime.now();
		DateTime later = now.addMinutes(5);
		insert new Eval_Value__c[] {
			new Eval_Value__c(
				Eval__c = evals[0].Id,
				Text_Under_250__c = '70',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[1].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[0].Id,
				Text_Under_250__c = '80',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(  // this will not be included because there's no associated weight entry
				Eval__c = evals[1].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section3',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[1].Id,
				Date_Time__c = later,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[2].Id,
				Text_Under_250__c = '160',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section',
				What_Id__c = evaluations[1].Id
				)
		};

		controller = new Report_PBS_Weight();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.rightSelectedPrograms.add((String) controller.rightPrograms[0].getValue());
		controller.removePrograms();
		controller.leftSelectedPrograms.add((String) controller.leftPrograms[0].getValue());
		controller.addPrograms();
		controller.dummyEvaluation.Evaluation_date__c = Date.Today().addDays(-10);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(1);
		controller.selectedPbs = new Id[]{ myData.theSA.Id };
		controller.runReport(); // this will run correctly

		System.assertEquals(1, controller.pbsMap.size());
		System.assertEquals(2, controller.pbsMap.get(myData.theSA.Id).weights.size());
		System.assertEquals(70, controller.pbsMap.get(myData.theSA.Id).weights[0].kg);
		System.assertEquals(now, controller.pbsMap.get(myData.theSA.Id).weights[0].observedDateTime);
		System.assertEquals(80, controller.pbsMap.get(myData.theSA.Id).weights[1].kg);
		System.assertEquals(later, controller.pbsMap.get(myData.theSA.Id).weights[1].observedDateTime);
		System.assertEquals(160, controller.pbsMap.get(myData.theSA.Id).height.cm);
	}
}