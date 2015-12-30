@isTest
public with sharing class RestraintReductionReportTests {
	public static testmethod void simpleTests() {
		// Set up test data
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

		PageReference pageRef = Page.RestraintReductionReport;
		Test.setCurrentPage(pageRef);

		Evaluation__c evaluation = new Evaluation__c(
				ServiceAssignment__c = testData.theSA.Id
				);
		insert evaluation;

		Eval_type__c evalType = new Eval_Type__c(
				Name = 'Restraint Event',
				Category__c = 'Care Meridian'
				);
		insert evalType;

		Eval__c[] evals = new Eval__c[] {
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Dropdown',
					htmlid__c = 'testdropdown',
					Field_Type__c = 'Dropdown'
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Boolean Dropdown',
					htmlid__c = 'testbooleandropdown',
					Field_Type__c = 'Boolean',
					Field_Sub_Type__c = 'Dropdown'
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Multiselect Long',
					htmlid__c = 'testmultiselectlong',
					Field_Type__c = 'Multiselect',
					Field_Sub_Type__c = 'Checkbox',
					Length__c = 5000
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Multiselect Short',
					htmlid__c = 'testmultiselectshort',
					Field_Type__c = 'Multiselect',
					Field_Sub_Type__c = 'Checkbox',
					Length__c = 100
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Start Date/Time',
					htmlid__c = 'startTime',
					Field_Type__c = 'Datetime'
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Short String',
					htmlid__c = 'testshortstring',
					Field_Type__c = 'String',
					Length__c = 100
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Long String field',
					htmlid__c = 'testlongstringfield',
					Field_Type__c = 'String',
					Length__c = 5000
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Date Field',
					htmlid__c = 'testdatefield',
					Field_Type__c = 'Date'
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Int Field',
					htmlid__c = 'int',
					Field_Type__c = 'Int'
					),
				new Eval__c(
					Eval_Type__c = evalType.Id,
					Category__c = 'Pre-Restraint Review',
					Sub_Category__c = 'Pre-Restraint Review',
					Field_Name__c = 'Test Double Field',
					htmlid__c = 'testdoublefield',
					Field_Type__c = 'Double'
					)
		};
		insert evals;

		insert new Eval_Value__c[] {
				new Eval_Value__c(
						Eval__c = evals[0].Id,
						Text_Under_250__c = 'Dropdown Option 1',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[1].Id,
						Text_Under_250__c = '1',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[2].Id,
						Text_Over_250__c = 'Test Long Text',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[3].Id,
						Text_Under_250__c = 'Test Short Text',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[4].Id,
						Date_Time__c = DateTime.now(),
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[5].Id,
						Text_Under_250__c = 'Test Short String Value',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[6].Id,
						Text_Over_250__c = 'Test Long String Value',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[7].Id,
						Date_Time__c = DateTime.now(),
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[8].Id,
						Number_No_Decimal__c = 50,
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						),
				new Eval_Value__c(
						Eval__c = evals[9].Id,
						Text_Under_250__c = '350.54',
						What_Id_Object__c = 'Evaluation__c',
						Eval_Section_Id__c = 'section',
						What_Id__c = evaluation.Id
						)
		};

		Assessment_Domain__c restraintDomain = new Assessment_Domain__c(
				Name = 'Restraint Questions',
				Assessment_Type2__c = 'Restraint Reduction',
				Sort_Order__c = 1
		);
		insert restraintDomain;


		Assessment_Question__c[] questions = new Assessment_Question__c[] {
			new Assessment_Question__c(
					Question_Title__c = 'Res Test',
					Question_Domain__c = restraintDomain.Id
			),
			new Assessment_Question__c(
					Question_Title__c = 'Res Test 2',
					Question_Domain__c = restraintDomain.Id
			)
		};
		insert questions;

		String sectionId = Userinfo.getUserId()+'-' + DateTime.now().getTime();
		Assessment__c asmt = new Assessment__c(
				Name = sectionId,
				Evaluation__c = evaluation.Id,
				Service_Assignment__c = testData.theSA.Id,
				Admission__c = testData.theSA.Admission__c,
				Type__c = 'Restraint Reduction'
		);
		insert asmt;

		ApexPages.currentPage().getParameters().put('startDate', Date.Today().addDays(-1).format());
		ApexPages.currentPage().getParameters().put('endDate', Date.Today().addDays(1).format());
		ApexPages.currentPage().getParameters().put('type', 'Detailed');
		ApexPages.currentPage().getParameters().put('saId', testData.theSA.Id);

		RestraintReductionReport controller = new RestraintReductionReport();
		System.assertEquals(1, controller.restraints.size());
		System.assertEquals(1, controller.restraints.values()[0].reductions.size());
		System.assertEquals(10, controller.restraints.values()[0].preRestraintKeyOrder.size());
	}
}