@isTest
private class CMShiftAssessmentEditTest {
	
	private static testmethod void myTests() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		Evaluation__c eval = new Evaluation__c ();
		eval.ServiceAssignment__c = testData.theSA.Id;
		eval.Details_Section_Completed__c = true;
		insert eval;
		
		PageReference pg = Page.CMShiftAssessmentEdit;
		Test.setCurrentPage(pg);
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		system.assertEquals(controller.evaluation, eval);
		system.assertNotEquals(null, controller.baseUrl);
		system.assertNotEquals(null, controller.painSliderOptions);
		system.assertEquals(1,controller.pains.Size());
		system.assertEquals(0,controller.annotations.size());
		system.assertEquals(0, controller.pUlcers.size());
		
		controller.getcopingValues();
		controller.getneuroOrientValues();
		controller.getmoodValues();
		controller.getbreatheSounds();
		controller.getDysreflexiaValues();
		controller.getverbalExpressionValues();
		controller.showAddVitalsDetail();
		
		system.assertEquals(null,controller.currentVitalsDetail.Id);
		controller.saveVitalsDetail();
		system.assertEquals(Utility.getEvaluationResponseRecordType('Vitals Details Shift Assessment'),controller.currentVitalsDetail.RecordTypeId);
		controller.currentVitalsDetailId = [SELECT ID,Name,Date__c,Heart_Rate__c FROM Evaluation_Response__c WHERE Evaluation__c=:eval.Id AND RecordType.Name='Vitals Details Shift Assessment' LIMIT 1].Id;
		controller.showEditVitalsDetail();
		controller.currentVitalsDetail.Heart_rate__c = '72';
		controller.saveVitalsDetail();
		
		Related_Party__c rp = new Related_Party__c();
		rp.Name = 'rpTest';
		rp.Person_Being_served__c = eval.ServiceAssignment__r.Admission__r.Person_Being_Served__c;
		rp.Type__c='Physician - Primary';
		insert rp;
		system.assertEquals(controller.getprimaryPhysician(),rp.Name);
		
		controller.showAddpUlcerDetail();
		system.assertEquals(null,controller.currentpUlcerDetail.Id);
		controller.savepUlcerDetail();
		system.assertEquals(1,controller.pUlcers.size());
		controller.currentpUlcerDetailId  = controller.currentpUlcerDetail.Id;
		controller.showEditpUlcerDetail();
		controller.savepUlcerDetail();
		
		CMShiftAssessmentEdit.addOrModifyAnnotation(null, '', 1, 1, 1, 1, '', '', eval.Id);
		Evaluation_Response__c[] Annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:eval.Id
        ];
        System.assertEquals(1, annotations.size());
        CMShiftAssessmentEdit.addOrModifyAnnotation(annotations[0].Id, '', 2, 2, 2, 2, '', '', eval.Id);
        CMShiftAssessmentEdit.deleteAnnotation(annotations[0].Id);
        annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:eval.Id
        ];
        System.assertEquals(0, annotations.size());
		controller.nextTab = 'diagsnosticTab';
        controller.changeTab();
        controller.save();
        
        system.assertnotEquals(0,controller.errorMap.keyset().size());
        system.assertnotEquals(0, controller.errorMap.Values().size());
        system.assertEquals(false,controller.evaluation.Diagnostics_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Cardio_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Ortho_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Neuro_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Psycho_Social_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Nutrition_Section_Completed__c);
        system.assertEquals(false,controller.evaluation.Skin_Section_Completed__c);
		
		controller.evaluation.Requires_Isolation_Picklist__c = 'Yes';
		controller.evaluation.DiagnosisIsolation_Type__c = null;
		controller.evaluation.IV_Site_Issues__c = 'Yes';
		controller.evaluation.IV_Narrative_Note__c = '';
		controller.save();
		system.assertnotEquals(0,controller.errorMap.get('diagnosticTab').size());
		controller.evaluation.DiagnosisIsolation_Type__c = 'test';
		controller.evaluation.IV_Narrative_Note__c = 'test';
		controller.save();
		system.assert(controller.evaluation.Diagnostics_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('diagnosticTab').size(),controller.errorMap.get('diagnosticTab'));
		
		controller.evaluation.Heart_Sounds__c = 'Irregular';
		controller.evaluation.Heart_Intervention_Need_Picklist__c = null;
		controller.evaluation.Peripheral_Pulses_Present__c = 'No';
		controller.evaluation.Peripheral_Pulses_Describe__c = null;
		controller.evaluation.Autonomic_Dysreflexia__c = 'Yes';
		controller.evaluation.Dysreflexia_issue_resolved__c = null;
		controller.evaluation.Dysreflexia_Issue_Describe__c = null;
		controller.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c = '';
		controller.save();
		system.assertNotEquals(0,controller.errorMap.get('cardioTab').size());
		controller.evaluation.Heart_Sounds__c = 'Regular';
		controller.evaluation.Autonomic_Dysreflexia__c = 'No';
		controller.evaluation.Peripheral_Pulses_Present__c = 'Yes';
		controller.evaluation.Suctioning_Picklist__c = 'No';
		controller.evaluation.Trach_Picklist__c = 'No';
		controller.evaluation.O2_Picklist__c = 'No';
		controller.evaluation.Ventilator_Picklist__c = 'No';
		controller.save();
		system.assert(controller.evaluation.Cardio_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('cardioTab').size(),controller.errorMap.get('cardioTab'));
		
		//GU/GI Nutrition Tab
		controller.selectedOptionsMap.put('nutrition_route__c',new List<string>{'Oral,PEG'});
		controller.evaluation.Oral_Health_Check__c = 'No';
		controller.evaluation.Bowel_Issues__c = 'No';
		controller.evaluation.Dialysis_Picklist__c = 'No';
		controller.save();
		system.assert(controller.evaluation.Nutrition_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('nutritionTab').size(),controller.errorMap.get('nutritionTab'));
		
		//Skin/Body Tab
		controller.evaluation.Skin_Color__c = 'test';
		controller.evaluation.Skin_Temperature__c  = 'test';
		controller.evaluation.Skin_Moisture__c  = 'test';
		controller.evaluation.Skin_Turgor__c  = 'test';
		controller.evaluation.Skin_Behavior__c  = 'test';
		controller.evaluation.Skin_Edema__c = 'No';
		controller.evaluation.Skin_Intact_Picklist__c = 'Yes';
		controller.save();
		system.assert(controller.evaluation.Skin_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('skinBodyTab').size(),controller.errorMap.get('skinBodyTab'));
		
		
				
	}

}