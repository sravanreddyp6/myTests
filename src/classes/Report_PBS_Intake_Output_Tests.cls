@isTest
public with sharing class Report_PBS_Intake_Output_Tests {
	static testmethod void simpleTests() {
		Report_PBS_Intake_Output controller = new Report_PBS_Intake_Output();
		controller.runReport();  // this will generate errors because of blank start/end dates
		controller.dummyEvaluation.Evaluation_Date__c = Date.Today().addDays(1);
		controller.dummyEvaluation.Dialysis_Onset__c = Date.Today().addDays(3);
		controller.runReport(); // this will generate errors because of invalid start/end dates

		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		Id nsdRecordType = Utility.getEvaluationRecordType('CMShiftAssessment');
		Id cnaRecordTypeId = Utility.getEvaluationRecordType('CNA Workbook');
		Evaluation__c[] evaluations = new Evaluation__c[]{
			new Evaluation__c(
				RecordTypeId = nsdRecordType,
				Status__c = 'Completed',
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
				Name = 'Head to Toe',
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
				Category__c = 'Intake',
				Sub_Category__c = 'All',
				Field_Name__c = 'Observed Date/Time',
				htmlid__c = 'ObservedDateTime20'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Intake',
				Sub_Category__c = 'All',
				Field_Name__c = 'mL Consumed',
				htmlid__c = 'intakemLConsumed'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'Observed Date/Time',
				htmlid__c = 'outputDateTime'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'Void Amount',
				htmlid__c = 'outputVoidAmount'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'Vomitus Amount',
				htmlid__c = 'vomAmount'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'BM Amount',
				htmlid__c = 'outputBMAmount'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'BM Color',
				htmlid__c = 'outputBMColor'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[1].Id,
				Category__c = 'Output',
				Sub_Category__c = 'All',
				Field_Name__c = 'Consistency',
				htmlid__c = 'outputConsistency'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Fluid Intake',
				Field_Name__c = 'Observed Date/Time',
				htmlid__c = 'ObservedDateTime20'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Fluid Intake',
				Field_Name__c = 'Feeding Type',
				htmlid__c = 'feedingType'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Fluid Intake',
				Field_Name__c = 'Fluid Type',
				htmlid__c = 'fluidType'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Fluid Intake',
				Field_Name__c = 'Fluid Volume',
				htmlid__c = 'fluidVolume'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Elimination - Bladder',
				Field_Name__c = 'Observed Date/Time',
				htmlid__c = 'ObservedDateTime20'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Elimination - Bladder',
				Field_Name__c = 'Continence',
				htmlid__c = 'bladderContinence'
				),
			new Eval__c(
				Eval_Type__c = evalTypes[0].Id,
				Category__c = 'GU/GI/Nutrition',
				Sub_Category__c = 'Elimination - Bladder',
				Field_Name__c = 'Devices',
				htmlid__c = 'bladderContinenceDevices'
				)
		};
		insert evals;
		DateTime now = DateTime.now();
		DateTime later = now.addMinutes(5);
		insert new Eval_Value__c[] {
			new Eval_Value__c(
				Eval__c = evals[0].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[1].Id,
				Text_Under_250__c = '10',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section',
				What_Id__c = evaluations[1].Id
				),

			new Eval_Value__c(
				Eval__c = evals[2].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[3].Id,
				Text_Under_250__c = '20',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[4].Id,
				Text_Over_250__c = '40',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[5].Id,
				Text_Under_250__c = 'Amount 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[6].Id,
				Text_Under_250__c = 'Color 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),
			new Eval_Value__c(
				Eval__c = evals[7].Id,
				Text_Under_250__c = 'Consistency 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section2',
				What_Id__c = evaluations[1].Id
				),

			new Eval_Value__c(
				Eval__c = evals[8].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section3',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[9].Id,
				Text_Under_250__c = 'Feeding Type 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section3',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[10].Id,
				Text_Under_250__c = 'Fluid Type 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section3',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[11].Id,
				Text_Under_250__c = '70',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section3',
				What_Id__c = evaluations[0].Id
				),

			new Eval_Value__c(
				Eval__c = evals[8].Id,
				Date_Time__c = now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'sectionWrong',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[11].Id,
				Text_Under_250__c = '70 mL',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'sectionWrong',
				What_Id__c = evaluations[0].Id
				),  // specifically to test issue when a non number is included in the system

			new Eval_Value__c(
				Eval__c = evals[12].Id,
				Date_Time__c = Now,
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section4',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[13].Id,
				Text_Under_250__c = 'Continence 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section4',
				What_Id__c = evaluations[0].Id
				),
			new Eval_Value__c(
				Eval__c = evals[14].Id,
				Text_Over_250__c = 'Devices 1',
				What_Id_Object__c = 'Evaluation__c',
				Eval_Section_Id__c = 'section4',
				What_Id__c = evaluations[0].Id
				)
		};

		controller = new Report_PBS_Intake_Output();
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

		Report_PBS_Intake_Output.ObservedDate observedDate = controller.pbsMap.values()[0].observedDates[0];
		System.assertEquals(now.Date(), observedDate.day);
		System.assertEquals(70, observedDate.totalVolume);
		System.assertEquals(10, observedDate.totalLiquidConsumed);
		System.assertEquals(20, observedDate.totalVoidAmount);
		System.assertEquals(40, observedDate.totalVomitusAmount);
	}
}