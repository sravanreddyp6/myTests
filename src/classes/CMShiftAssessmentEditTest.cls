@isTest
private class CMShiftAssessmentEditTest {
	static Evaluation__c eval;
	private static void createData() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		eval = new Evaluation__c ();
		eval.ServiceAssignment__c = testData.theSA.Id;
		eval.Details_Section_Completed__c = true;
		insert eval;
	
	}
	
	private static testmethod void myTests() {
		createData();
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
		controller.getbowelValues();
		controller.getbladderValues();
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
		
	}
	
	private static testmethod void testDiagnostics() {
		//Diagnostics Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
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
	}
	
	private static testmethod void testCardio(){	
		//Cardio Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		
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
		controller.evaluation.Heart_Sounds__c = 'Irregular';
		controller.evaluation.Heart_Intervention_Need_Picklist__c = null;
		controller.save();
		controller.evaluation.Heart_Intervention_Need_Picklist__c = 'Yes';
		controller.evaluation.Heart_Rate_Intervention_Describe__c = '';
		controller.evaluation.Peripheral_Pulses_Present__c = 'No';
		controller.evaluation.Peripheral_Pulses_Describe__c = null;
		controller.evaluation.Autonomic_Dysreflexia__c = 'Yes';
		controller.evaluation.Dysreflexia_issue_resolved__c = null;
		controller.evaluation.Dysreflexia_Issue_Describe__c = null;
		controller.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c = '';
		controller.save();
		controller.evaluation.Dysreflexia_issue_resolved__c = 'No';
		controller.evaluation.Dysreflexia_Issue_Describe__c = null;
		controller.evaluation.Trach_Picklist__c = 'Yes';
		controller.evaluation.Trach_Type__c = null;
		controller.evaluation.Trach_Size__c = null;
		controller.evaluation.PMV_Picklist__c = null;
		controller.save();
		controller.evaluation.Trach_Type__c = 'Other';
		controller.evaluation.Trach_Type_Other__c = null;
		controller.evaluation.Trach_Size__c = 'Other';
		controller.evaluation.Trach_Size_Other__c = null;
		controller.evaluation.O2_Picklist__c = 'Yes';
		controller.evaluation.O2_Intervention_Needed__c = null;
		controller.evaluation.O2_Documentation_Required__c = null;
		controller.evaluation.Ventilator_Picklist__c = 'Yes';
		controller.evaluation.Ventilator_Type__c = null;
		controller.save();
		controller.evaluation.Ventilator_Type__c = 'Intermittent';
		controller.evaluation.If_Intermittent_Schedule__c = null;
		controller.selectedDysreflexia = new List<string>{'Bladder Distended','Pain'};
		controller.selectedSounds = new List<string>{'Clear','Rhonchi'};
		controller.save();
		system.assert(!controller.evaluation.Cardio_Section_Completed__c);
		system.assertNotEquals(0,controller.errorMap.get('cardioTab').size());
	}
	
	private static testmethod void testGUGI(){
		//GU/GI Nutrition Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		
		controller.selectedOptionsMap.put('nutrition_route__c',new List<string>{'Oral,PEG'});
		controller.evaluation.Oral_Health_Check__c = 'No';
		controller.evaluation.Bowel_Issues__c = 'No';
		controller.evaluation.Dialysis_Picklist__c = 'No';
		controller.evaluation.Bowel_Continence__c = 'Continent';
		controller.evaluation.Bladder_Continence__c = 'Continent';
		controller.evaluation.Urinary_Issues_Checkbox__c = 'No';
		controller.save();
		system.assert(controller.evaluation.Nutrition_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('nutritionTab').size(),controller.errorMap.get('nutritionTab'));
		controller.evaluation.Oral_Health_Check__c = 'Yes';
		controller.evaluation.Issues_Noted__c = null;
		controller.save();
		controller.evaluation.Issues_Noted__c = 'Yes';
		controller.evaluation.tongue__c = '';
		controller.evaluation.Gums__c = '';
		controller.evaluation.Cheeks__c = '';
		controller.evaluation.Lips__c = '';
		controller.evaluation.Saliva__c = '';
		controller.evaluation.Narrative_Note__c = '';
		controller.evaluation.PEDS_History_of_Tonsils__c = 'Yes';
		controller.evaluation.PEDS_Tonsil_History_Describe__c = null;
		controller.evaluation.RUQ__c = 'Abnormal';
		controller.evaluation.RUQ_Describe__c = null;
		controller.evaluation.LUQ__c = 'Abnormal';
		controller.evaluation.LUQ_Describe__c = null;
		controller.evaluation.RLQ__c = 'Abnormal';
		controller.evaluation.RLQ_Describe__c = null;
		controller.evaluation.LLQ__c = 'Abnormal';
		controller.evaluation.LLQ_Describe__c = null;
		controller.evaluation.Bowel_Continence__c = 'Incontinent';
		controller.evaluation.Elimination_Bowel_No_Continent_Appliance__c = '';
		controller.evaluation.Bowel_Issues__c = 'Yes';
		controller.evaluation.bowel_issue_type__c = '';
		controller.evaluation.Bowel_Issues_Additional_Information__c = null;
		controller.evaluation.Bladder_Continence__c = 'Incontinent';
		controller.evaluation.Elimination_Bladder_No_Continent_Details__c = '';
		controller.evaluation.Urinary_Issues_Checkbox__c = 'Yes';
		controller.evaluation.Dialysis_Picklist__c = 'Yes';
		controller.evaluation.dialysis_type__c = '';
		controller.save();
		system.assert(!controller.evaluation.Nutrition_Section_Completed__c);
		system.assertNotEquals(0,controller.errorMap.get('nutritionTab').size());
	}
	
	private static testmethod void testskinBody(){
		//Skin/Body Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		
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
		controller.evaluation.Skin_Edema__c = 'Yes';
		controller.evaluation.Skin_Edema_Location__c = null;
		controller.evaluation.Skin_Edema_Pitting__c = null;
		controller.save();
		system.assert(!controller.evaluation.Skin_Section_Completed__c);
		system.assertNotEquals(0,controller.errorMap.get('skinBodyTab').size());
	}
	
	private static testmethod void testNeuro() {
		//Neuro Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		controller.evaluation.Cognition_Intact__c = 'Yes';
		controller.evaluation.Cooperative__c = true; //Behavior checkbox is mandatory
		controller.selectedMoods = new List<string>{'Angry','Anxious'};
		controller.evaluation.Able_to_make_Needs_Known__c = 'Yes';
		//controller.evaluation.Rancho_Level__c = '(1) No Response';
		controller.evaluation.Safety_Awareness__c = 'Intact';
		controller.evaluation.Pain_Present__c = 'No';
		controller.save();
		system.assert(controller.evaluation.Neuro_Section_Completed__c);
		system.assertEquals(0,controller.errorMap.get('neuroTab').size(),controller.errorMap.get('neuroTab'));
		
		controller.evaluation.cognition_Intact__c = 'No';
		controller.save();
		controller.evaluation.Rancho_Level__c = '(2) Generalized Response';
		controller.selectedNeuroOrient = new List<string>{'Person','Situation'};
		controller.selectedMoods = new List<string>{'Sad','Flat'};
		controller.evaluation.Desire_to_hurt_themselves__c = null;
		controller.save();
		controller.evaluation.Desire_to_hurt_themselves__c = 'Yes';
		controller.evaluation.Plan_to_Harm_themselves__c = null;
		controller.evaluation.Able_to_make_Needs_Known__c = 'No';
		controller.evaluation.Expression__c = null;
		controller.save();
		controller.evaluation.Expression__c = 'Non-Verbal';
		controller.selectedVerbalExpression = new List<String>();
		controller.save();
		controller.selectedVerbalExpression = new List<string>{'Gesture','Sign Language'};
		controller.evaluation.Pain_Present__c = 'Yes';
		controller.addPainResponse();
		controller.save();
		controller.evaluation.Pain_Present__c = 'No';
		controller.updatePainResponses();
		controller.save();
		system.assert(!controller.evaluation.Neuro_Section_Completed__c);
		system.assertNotEquals(0,controller.errorMap.get('neuroTab').size());
	}
	
	private static testmethod void testOrtho() {
		//OrthoTab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		
		controller.evaluation.Cast_Picklist__c = 'No';
		controller.evaluation.External_Device_Picklist__c = 'No';
		controller.evaluation.Traction_Picklist__c = 'No';
		controller.save();
		system.assert(controller.evaluation.Ortho_Section_Completed__c );
		system.assertEquals(0,controller.errorMap.get('orthoTab').size(),controller.errorMap.get('orthoTab'));
		controller.evaluation.Cast_Picklist__c = 'Yes';
		controller.evaluation.Ortho_Cast_Location__c = null;
		controller.save();
		controller.evaluation.Ortho_Cast_Location__c = 'Other';
		controller.evaluation.Cast_Location__c = null;
		controller.evaluation.External_Device_Picklist__c = 'Yes';
		controller.evaluation.External_Devices_Location__c = null;
		controller.evaluation.External_Devices_Type__c = null;
		controller.evaluation.Traction_Picklist__c = 'Yes';
		controller.evaluation.Traction_Location__c = null;
		controller.evaluation.Traction_Type__c = null;
		controller.evaluation.Traction_Weight__c = null;
		controller.save();
		system.assert(!controller.evaluation.Ortho_Section_Completed__c );
		system.assertnotEquals(0,controller.errorMap.get('orthoTab').size());
	}
	
	private static testmethod void testpsycho() {	
		//Psycho/Social Tab
		createData();
		ApexPages.StandardController sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentEdit controller = new CMShiftAssessmentEdit(sc);
		
		controller.evaluation.Resident_Coping_Well__c = null;
		controller.save();
		controller.evaluation.Resident_Coping_Well__c = 'No';
		controller.evaluation.Coping_Description__c = null;
		controller.selectedCoping = new List<string>{'Grieving','Recent Life Changes'};
		controller.save();
		system.assert(!controller.evaluation.Psycho_Social_Section_Completed__c );
		system.assertnotEquals(0,controller.errorMap.get('psychoSocialTab').size());
		controller.evaluation.Resident_Coping_Well__c  = 'Yes';
		controller.save();
		system.assert(controller.evaluation.Psycho_Social_Section_Completed__c );
		system.assertEquals(0,controller.errorMap.get('psychoSocialTab').size(),controller.errorMap.get('psychoSocialTab'));		
	} 

}