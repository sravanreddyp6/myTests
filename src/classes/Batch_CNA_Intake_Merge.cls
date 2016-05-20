global without sharing class Batch_CNA_Intake_Merge implements Database.Batchable<sObject>, Database.Stateful {
	global final Id observedDateTimeId;
	global final Id mLConsumedId;
	global final Id isValidId;
	global final Id errorMsgId;
	global final Id liquidConsumedId;

	global String currentCompositeKey;

	global Map<String, Boolean> sectionErrorFound;

	global Batch_CNA_Intake_Merge() {
		this.sectionErrorFound = new Map<String, Boolean>();

		List<Eval__c> evalsToUpdate = new List<Eval__c>();

		Boolean mlConsumedFound = false;
		for (Eval__c mealRecord: [
			SELECT Id, Sub_Category__c, Visible__c, HtmlId__c
			  FROM Eval__c
			 WHERE Eval_Type__r.Name = 'CNA Workbook'
			   AND Category__c = 'Intake'
			   AND Sub_Category__c = 'Meals'
		]) {
			if (mealRecord.HtmlId__c == 'ObservedDateTime20') {
				this.observedDateTimeId = mealRecord.Id;
			} else if (mealRecord.HtmlId__c == 'intakemLConsumed') {
				if (!mlConsumedFound) {  // There are 2 in the systems that satisfy this right now
					this.mLConsumedId = mealRecord.Id;
					mealRecord.Visible__c = true;
					mlConsumedFound = true;
				}
			} else if (mealRecord.HtmlId__c == 'IsValid') {
				this.isValidId = mealRecord.Id;
			} else if (mealRecord.HtmlId__c == 'ErrorMsg') {
				this.errorMsgId = mealRecord.Id;
			} else if (mealRecord.HtmlId__c == 'liquidConsumed' && mealRecord.Visible__c) {
				this.liquidConsumedId = mealRecord.Id;
			}
			mealRecord.Sub_Category__c = 'All';
			evalsToUpdate.add(mealRecord);
		}
		System.assertNotEquals(null, observedDateTimeId);
		System.assertNotEquals(null, mLConsumedId);
		System.assertNotEquals(null, isValidId);
		System.assertNotEquals(null, errorMsgId);
		System.assertNotEquals(null, liquidConsumedId);

		update evalsToUpdate;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			'SELECT Id, Eval__r.HtmlId__c, Eval_Section_Id__c, Text_Under_250__c, Eval_Section_Type__c,' +
			'       Text_Over_250__c, What_ID__c, What_ID_Object__c, Eval__r.Visible__c, OwnerId' +
			'  FROM Eval_Value__c' +
			' WHERE Eval__r.Eval_Type__r.Name = \'CNA Workbook\'' +
			'   AND Eval__r.Category__c = \'Intake\'' +
			'   AND Eval__r.Sub_Category__c = \'Liquid\'' +
			'ORDER BY Eval_Section_Id__c'
		);
	}

	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		//  We don't need these this in a *global* context, so we initialize them here to avoid serialization
		List<Eval_Value__c> valuesToDelete = new List<Eval_Value__c>();
		List<Eval_Value__c> valuesToInsert = new List<Eval_Value__c>();

		List<Eval_Value__c> values = (List<Eval_Value__c>) scope;
		for (Eval_Value__c value: values) {
			String compositeKey = value.Eval_Section_Id__c + '+' + value.What_Id__c;
			if (!sectionErrorFound.keySet().contains(compositeKey)) {
				sectionErrorFound.put(compositeKey, false);
			}
			if (value.Eval__r.Visible__c) {
				value.Eval_Section_Type__c = 'Activity Log';
				if (value.Eval__r.HtmlId__c == 'mLConsumed') {
					value.Eval__c = this.mLConsumedId;
					valuesToInsert.add(new Eval_Value__c(
						Eval__c = this.liquidConsumedId,
						Eval_Section_Id__c = value.Eval_Section_Id__c,
						Text_Under_250__c = '1',
						Eval_Section_Type__c = value.Eval_Section_Type__c,
						What_Id__c = value.What_Id__c,
						What_Id_Object__c = value.What_Id_Object__c,
						OwnerId = value.OwnerId
					));
				} else if (value.Eval__r.HtmlId__c == 'liquidDateTime') {
					value.Eval__c = this.observedDateTimeId;
				} else if (value.Eval__r.HtmlId__c == 'IsValid') {
					value.Boolean__c = false;
					value.Eval__c = this.isValidId;
				} else if (value.Eval__r.HtmlId__c == 'ErrorMsg') {
					value.Text_Over_250__c = '<li>Tube Fed field is mandatory.</li>' + value.Text_Over_250__c;
					value.Eval__c = this.errorMsgId;
					sectionErrorFound.put(compositeKey, true);
				}
			} else {
				valuesToDelete.add(value);
			}
			if (currentCompositeKey != null && !sectionErrorFound.get(currentCompositeKey) && currentCompositeKey != compositeKey) {
				valuesToInsert.add(new Eval_Value__c(
					Eval__c = errorMsgId,
					Text_Over_250__c = '<li>Tube Fed field is mandatory.</li>',
					Eval_Section_Id__c = currentCompositeKey.split('\\+', 0)[0],
					What_Id__c = currentCompositeKey.split('\\+', 0)[1],
					What_Id_Object__c = 'Evaluation__c'
				));
			}
			currentCompositeKey = compositeKey;
		}
		update values;
		insert valuesToInsert;
		delete valuesToDelete;
	}

	global void finish(Database.BatchableContext bc) {
		delete [
			SELECT Id, Field_Name__c, HtmlId__c, Visible__c
			  FROM Eval__c
			 WHERE Eval_Type__r.Name = 'CNA Workbook'
			   AND Category__c = 'Intake'
			   AND Sub_Category__c = 'Liquid'
		];
	}
}