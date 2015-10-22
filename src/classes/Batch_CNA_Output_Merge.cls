global without sharing class Batch_CNA_Output_Merge implements Database.Batchable<sObject>, Database.Stateful {
	global Id observedDateTime;
	global Id sectionCompleted;
	global Id isValid;
	global Id errorMsg;
	global Id output;

	global final Eval_Type__c evalType = [SELECT Id FROM Eval_Type__c WHERE Name = 'CNA Workbook'];
	global List<Eval__c> evalsToInsert;
	// We use this to keep track of the sections that need the Result field
	// populated.
	global Set<String> evalSectionIds;

	global Batch_CNA_Output_Merge() {
		List<Eval__c> evalsToUpdate = new List<Eval__c>();
		evalSectionIds = new Set<String>();

		for (Eval__c voidRecord: [
			SELECT Id, Sub_Category__c, Visible__c, HtmlId__c
			  FROM Eval__c
			 WHERE Eval_Type__r.Name = 'CNA Workbook'
			   AND Category__c = 'Output'
			   AND Sub_Category__c = 'Void and BM'
		]) {
			if (voidRecord.HtmlId__c == 'outputDateTime' && voidRecord.Visible__c) {
				observedDateTime = voidRecord.Id;
			} else if (voidRecord.HtmlId__c == 'outputSectionComplete' && voidRecord.Visible__c) {
				sectionCompleted = voidRecord.Id;
			} else if (voidRecord.HtmlId__c == 'IsValid' && voidRecord.Visible__c) {
				isValid = voidRecord.Id;
			} else if (voidRecord.HtmlId__c == 'ErrorMsg' && voidRecord.Visible__c) {
				errorMsg = voidRecord.Id;
			} else if (voidRecord.HtmlId__c == 'outputResult' && voidRecord.Visible__c) {
				output = voidRecord.Id;
				voidRecord.Dependent_Fields__c = '{&quot;Void&quot;: [&quot;outputVoidAmount&quot;,&quot;outputVoidOdor&quot;,&quot;outputVoidColor&quot;,&quot;outputClarity&quot;,&quot;outputVoidInclusions&quot;],&quot;BM&quot;:[&quot;outputBMAmount&quot;,&quot;outputBMOdor&quot;,&quot;outputBMColor&quot;,&quot;outputConsistency&quot;,&quot;outputBMInclusions&quot;],&quot;Void and BM&quot;: [&quot;outputVoidAmount&quot;,&quot;outputVoidOdor&quot;,&quot;outputVoidColor&quot;,&quot;outputClarity&quot;,&quot;outputVoidInclusions&quot;,&quot;outputBMAmount&quot;,&quot;outputBMOdor&quot;,&quot;outputBMColor&quot;,&quot;outputConsistency&quot;,&quot;outputBMInclusions&quot;],&quot;Incontinent&quot;: [&quot;outputVoidAmount&quot;,&quot;outputVoidOdor&quot;,&quot;outputVoidColor&quot;,&quot;outputClarity&quot;,&quot;outputVoidInclusions&quot;,&quot;outputBMAmount&quot;,&quot;outputBMOdor&quot;,&quot;outputBMColor&quot;,&quot;outputConsistency&quot;,&quot;outputBMInclusions&quot;],&quot;Vomitus&quot;: [&quot;vomDescription&quot;,&quot;vomAmount&quot;]}';
			}
			voidRecord.Sub_Category__c = 'All';
			evalsToUpdate.add(voidRecord);
		}
		System.assertNotEquals(null, observedDateTime);
		System.assertNotEquals(null, sectionCompleted);
		System.assertNotEquals(null, isValid);
		System.assertNotEquals(null, errorMsg);
		System.assertNotEquals(null, output);

		evalsToInsert = new Eval__c[] {
			new Eval__c(
				Category__c = 'Output',
				Category_Sequence__c = 4,
				Cat_Seq_Text__c = '1004',
				Eval_Type__c = evalType.Id,
				Field_Name__c = 'Vomitus Amount (mL)',
				Field_Sequence__c = 7.3,
				Field_Type__c = 'Double',
				HtmlId__c = 'vomAmount',
				Length__c = 3000,
				Required__c = false,
				Sub_Category__c = 'All',
				Sub_Category_Sequence__c = 1,
				SubCat_Seq_Text__c = '1001',
				SubSubCat_Seq_Text__c = '1001',
				Visibility_Row_Rules__c = false,
				Visible__c = true
			),
			new Eval__c(
				Category__c = 'Output',
				Category_Sequence__c = 4,
				Cat_Seq_Text__c = '1004',
				Eval_Type__c = evalType.Id,
				Dependent_Fields__c = '{&quot;Other&quot;: [&quot;vomOther&quot;]}',
				Field_Name__c = 'Vomitus Description',
				Field_Sequence__c = 7.2,
				Field_Type__c = 'Dropdown',
				HtmlId__c = 'vomDescription',
				Length__c = 3000,
				Required__c = false,
				Sub_Category__c = 'All',
				Sub_Category_Sequence__c = 1,
				SubCat_Seq_Text__c = '1001',
				SubSubCat_Seq_Text__c = '1001',
				Visibility_Row_Rules__c = false,
				Visible__c = true
			),
			new Eval__c(
				Category__c = 'Output',
				Category_Sequence__c = 4,
				Cat_Seq_Text__c = '1004',
				Eval_Type__c = evalType.Id,
				Field_Name__c = 'Other',
				Field_Sequence__c = 7.4,
				Field_Type__c = 'String',
				HtmlId__c = 'vomOther',
				Length__c = 3000,
				Required__c = false,
				Sub_Category__c = 'All',
				Sub_Category_Sequence__c = 1,
				SubCat_Seq_Text__c = '1001',
				SubSubCat_Seq_Text__c = '1001',
				Visibility_Row_Rules__c = false,
				Visible__c = true
			),
			new Eval__c(
				Category__c = 'Output',
				Category_Sequence__c = 4,
				Cat_Seq_Text__c = '1004',
				Eval_Type__c = evalType.Id,
				Field_Name__c = 'Blank Space',
				Field_Sequence__c = 7.3,
				Field_Type__c = 'Hidden',
				HtmlId__c = 'BlankSpace73',
				Required__c = false,
				Sub_Category__c = 'All',
				Sub_Category_Sequence__c = 1,
				SubCat_Seq_Text__c = '1001',
				SubSubCat_Seq_Text__c = '1001',
				Visibility_Row_Rules__c = false,
				Visible__c = true
			)
		};

		insert evalsToInsert;
		update evalsToUpdate;

		insert new Eval_Drop_Down__c[] {
			new Eval_Drop_Down__c(
				Option_Name__c = 'Bile',
				Option_Value__c = 'Bile',
				Sequence__c = 1,
				Visibility_Row_Rules__c = false,
				WhatId__c = evalsToInsert[1].Id,
				What_Id_Object__c = 'Eval__c'
			),
			new Eval_Drop_Down__c(
				Option_Name__c = 'Undigested Food',
				Option_Value__c = 'Undigested Food',
				Sequence__c = 2,
				Visibility_Row_Rules__c = false,
				WhatId__c = evalsToInsert[1].Id,
				What_Id_Object__c = 'Eval__c'
			),
			new Eval_Drop_Down__c(
				Option_Name__c = 'Coffee Grounds',
				Option_Value__c = 'Coffee Grounds',
				Sequence__c = 3,
				Visibility_Row_Rules__c = false,
				WhatId__c = evalsToInsert[1].Id,
				What_Id_Object__c = 'Eval__c'
			),
			new Eval_Drop_Down__c(
				Option_Name__c = 'Other',
				Option_Value__c = 'Other',
				Sequence__c = 4,
				Visibility_Row_Rules__c = false,
				WhatId__c = evalsToInsert[1].Id,
				What_Id_Object__c = 'Eval__c'
			),
			new Eval_Drop_Down__c(
				Option_Name__c = 'Vomitus',
				Option_Value__c = 'Vomitus',
				Sequence__c = 6,
				Visibility_Row_Rules__c = false,
				WhatId__c = output,
				What_Id_Object__c = 'Eval__c'
			)
		};
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			'SELECT Id, Eval__r.HtmlId__c, Eval_Section_Id__c, Text_Under_250__c, Eval_Section_Type__c,' +
			'       Text_Over_250__c, What_ID__c, What_ID_Object__c, Eval__r.Visible__c' +
			'  FROM Eval_Value__c' +
			' WHERE Eval__r.Eval_Type__r.Name = \'CNA Workbook\'' +
			'   AND Eval__r.Category__c = \'Output\'' +
			'   AND Eval__r.Sub_Category__c = \'Vomitus\''
		);
	}

	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		//  We don't need these this in a *global* context, so we initialize them here to avoid serialization
		List<Eval_Value__c> valuesToDelete = new List<Eval_Value__c>();
		List<Eval_Value__c> values = (List<Eval_Value__c>) scope;
		List<Eval_Value__c> valuesToUpdate = new List<Eval_Value__c>();
		List<Eval_Value__c> valuesToInsert = new List<Eval_Value__c>();

		for (Eval_Value__c vomValue: values) {
			if (vomValue.Eval__r.Visible__c) {
				vomValue.Eval_Section_Type__c = 'Activity Log';
				if (vomValue.Eval__r.HtmlId__c == 'vomDescription') {
					vomValue.Eval__c = evalsToInsert[1].Id;
					valuesToUpdate.add(vomValue);
					if (!evalSectionIds.contains(vomValue.Eval_Section_Id__c)) {
						valuesToInsert.add(new Eval_Value__c(
							Eval__c = output,
							Eval_Section_Id__c = vomValue.Eval_Section_Id__c,
							Text_Under_250__c = 'Vomitus',
							Eval_Section_Type__c = vomValue.Eval_Section_Type__c,
							What_Id__c = vomValue.What_Id__c,
							What_Id_Object__c = vomValue.What_Id_Object__c
						));
						evalSectionIds.add(vomValue.Eval_Section_Id__c);
					}
				} else if (vomValue.Eval__r.HtmlId__c == 'vomAmount') {
					vomValue.Eval__c = evalsToInsert[0].Id;
					System.debug('Found vomAmount');
					valuesToUpdate.add(vomValue);
					if (!evalSectionIds.contains(vomValue.Eval_Section_Id__c)) {
						valuesToInsert.add(new Eval_Value__c(
							Eval__c = output,
							Eval_Section_Id__c = vomValue.Eval_Section_Id__c,
							Text_Under_250__c = 'Vomitus',
							Eval_Section_Type__c = vomValue.Eval_Section_Type__c,
							What_Id__c = vomValue.What_Id__c,
							What_Id_Object__c = vomValue.What_Id_Object__c
						));
						evalSectionIds.add(vomValue.Eval_Section_Id__c);
					}
				} else if (vomValue.Eval__r.HtmlId__c == 'vomOther') {
					vomValue.Eval__c = evalsToInsert[2].Id;
					System.debug('Found vomOther');
					valuesToUpdate.add(vomValue);
					if (!evalSectionIds.contains(vomValue.Eval_Section_Id__c)) {
						valuesToInsert.add(new Eval_Value__c(
							Eval__c = output,
							Eval_Section_Id__c = vomValue.Eval_Section_Id__c,
							Text_Under_250__c = 'Vomitus',
							Eval_Section_Type__c = vomValue.Eval_Section_Type__c,
							What_Id__c = vomValue.What_Id__c,
							What_Id_Object__c = vomValue.What_Id_Object__c
						));
						evalSectionIds.add(vomValue.Eval_Section_Id__c);
					}
				} else if (vomValue.Eval__r.HtmlId__c == 'vomDateTime') {
					vomValue.Eval__c = observedDateTime;
					System.debug('Found vomDateTime');
					valuesToUpdate.add(vomValue);
				} else if (vomValue.Eval__r.HtmlId__c == 'IsValid') {
					vomValue.Boolean__c = false;
					vomValue.Eval__c = isValid;
					System.debug('Found IsValid');
					valuesToUpdate.add(vomValue);
				} else if (vomValue.Eval__r.HtmlId__c == 'vomNoData') {
					vomValue.Eval__c = sectionCompleted;
					System.debug('Found vomNoData');
					valuesToUpdate.add(vomValue);
				} else if (vomValue.Eval__r.HtmlId__c == 'ErrorMsg') {
					vomValue.Eval__c = errorMsg;
					System.debug('Found ErrorMsg');
					valuesToUpdate.add(vomValue);
				}
			} else {
				valuesToDelete.add(vomValue);
			}
		}
		update valuesToUpdate;
		insert valuesToInsert;
		delete valuesToDelete;
	}

	global void finish(Database.BatchableContext bc) {
		List<Eval__c> oldEvals = [
			SELECT Id, HtmlId__c, Visible__c
			  FROM Eval__c
			 WHERE Eval_Type__r.Name = 'CNA Workbook'
			   AND Category__c = 'Output'
			   AND Sub_Category__c = 'Vomitus'
		];
		List<Id> oldEvalIds = new List<Id>();
		for (Eval__c eval: oldEvals) {
			oldEvalIds.add(eval.Id);
		}
		delete [
			SELECT Id
			  FROM Eval_Drop_Down__c
			 WHERE WhatId__c IN :oldEvalIds
		];
		delete oldEvals;
	}
}