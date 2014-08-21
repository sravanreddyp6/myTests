@isTest
private class NursingEvaluationEditTest {
	static testmethod void editTest(){
		
		TMN_Generic_Core_TestData testdata = new TMN_Generic_Core_TestData();
		
		Evaluation__c evaluation = new Evaluation__c();
		evaluation.RecordTypeId = Utility.getEValuationRecordType('NursesAssessment');
		evaluation.ServiceAssignment__c = testdata.theSA.Id;
		evaluation.Breathe_Sounds__c = 'Test;Test2';
		evaluation.Cheeks__c = 'Test;Tesst2';
		evaluation.Urinary_Issues__c ='Test;Test2';
		evaluation.Urine_Clarity__c ='Test';
		evaluation.Tongue__c = 'Tet;Test2';
		evaluation.Gums__c = 'Test;Test2';
		evaluation.Cheeks__c ='Test;test2';
		evaluation.Lips__c = 'test;test2';
		evaluation.Saliva__c ='testr;test2';
		evaluation.Dentures_Type__c ='test;test2';
		evaluation.Abdomen__c ='test;test2';
		evaluation.Hallucination_Types__c ='test;test2';
		evaluation.Typeof_Spiritual_belief_Effects__c ='test;test2';
		evaluation.Preferred_Method_of_Learning__c ='test;test2';
		evaluation.Resident_Demonstrating_Issues__c ='test;test2';
		evaluation.Resident_s_Communication_Status__c ='test;test2';
		evaluation.Resident_s_Emotional_Barriers__c ='test;test2';
		evaluation.Resident_s_Learning_needs_related_to__c ='test;test2';
		evaluation.Rancho_level_Resident_Orientation__c ='test;test2';
		evaluation.Oriented_to_the_Following__c ='test;test2';
		evaluation.Family_Member_s_Emotional_Barriers__c ='test;test2';
		evaluation.Family_Communication_Status__c ='test;test2';
		evaluation.Family_Member_s_Learning_related_to__c ='test;test2';
		evaluation.Diagnostics_GYN_Experiences__c ='test;test2';
		evaluation.Orthopedic_diagnostic_types__c ='test;test2';
		evaluation.Orthodics_Types__c ='test;test2';
		evaluation.Orthopedic_Medications__c ='test;test2';
		evaluation.Prosthetic_Types__c ='test;test2';
		evaluation.Mood__c ='test;test2';
		evaluation.Negative_Impact_on_ADLs__c ='test;test2';
		evaluation.Alleviating_Factors__c ='test;test2';
		evaluation.Manner_of_Expressing_Pain__c ='test;test2';
		evaluation.Neuro_Pain_Types__c ='test;test2';
		evaluation.Neuro_Pain_Alleviating_Factors__c ='test;test2';
		evaluation.Neuro_Pain_neg_Impact_on_ADLs__c ='test;test2';
		evaluation.Neuro_Pain_Types__c ='test;test';
		evaluation.Neuro_Pain_Alleviating_Factors__c ='test;test2';
		evaluation.Neuro_Pain_neg_Impact_on_ADLs__c ='test;test2';
		evaluation.Neuro_Pain_Manner_of_Exp__c ='test;test2';
		evaluation.Neuro_pain_Descriptors__c ='test;test2';
		insert evaluation;
		
		Related_Party__c rp = new Related_Party__c();
		rp.Name = 'Relatedparty Test';
		rp.Type__c = 'Guardian';
		rp.Person_Being_Served__c = testdata.contactID;
		insert rp;
		
		evaluation =[SELECT Id, ServiceAssignment__c,Breathe_Sounds__c,Urinary_Issues__c,Urine_Clarity__c,Tongue__c,
					 Gums__c,Cheeks__c,Lips__c,Saliva__c,Dentures_Type__c,Abdomen__c,Hallucination_Types__c,Typeof_Spiritual_belief_Effects__c,
					 Preferred_Method_of_Learning__c,Resident_Demonstrating_Issues__c,Resident_s_Communication_Status__c,Resident_s_Emotional_Barriers__c,
					 Resident_s_Learning_needs_related_to__c,Rancho_level_Resident_Orientation__c,Oriented_to_the_Following__c,Family_Member_s_Emotional_Barriers__c,
					 Family_Communication_Status__c,Family_Member_s_Learning_related_to__c,Diagnostics_GYN_Experiences__c,Orthopedic_diagnostic_types__c,
					 Orthodics_Types__c,Orthopedic_Medications__c,Prosthetic_Types__c,Mood__c,Negative_Impact_on_ADLs__c,Alleviating_Factors__c,
					 Manner_of_Expressing_Pain__c,Neuro_Pain_Types__c,Neuro_Pain_Alleviating_Factors__c,Neuro_Pain_neg_Impact_on_ADLs__c,Neuro_Pain_Manner_of_Exp__c,Neuro_pain_Descriptors__c,	 	
					 RecordType.Name,ServiceAssignment__r.Admission__r.Person_Being_Served__c FROM Evaluation__c Where id=:evaluation.Id ];
					 
		evaluation.Beliefs_that_could_affect_Treatment__c ='Yes';
		evaluation.Prosthetics__c = 'Yes';
		evaluation.Dentures__c ='Yes';
		evaluation.Hallucinations__c = true;
		evaluation.Orthodics__c = 'Yes';
		evaluation.Pain_Present__c = 'Yes';
		
		update evaluation;
		
		NursingEvaluationEditController controller = new NursingEvaluationEditController(new ApexPages.StandardController(evaluation));
		
		System.assertNotEquals(0,controller.sliderOptions.size());
		System.assertEquals(0, controller.annotations.size());
        System.assertNotEquals(null, controller.relatedParties);
        controller.showAddRelatedParty();
        System.assertEquals(null, controller.currentRelatedParty.Id);
        controller.currentRelatedPartyId = rp.Id;
        controller.showEditRelatedParty();
        System.assertEquals(rp.Id, controller.currentRelatedParty.Id);
        controller.currentRelatedParty.Name = 'New Name';
        controller.saveRelatedParty();
      	controller.getbreatheSounds();
      	controller.geturinaryIssues();
      	controller.geturineClarities();
      	controller.gettongueValues();
      	controller.getgumValues();
      	controller.getcheekValues();
      	controller.getlipValues();
      	controller.getsalivaValues();
      	controller.getdentureValues();
      	controller.getabdomenValues();
      	controller.gethallValues();
      	controller.getbeliefValues();
      	controller.getlearningValues();
      	controller.getcopingValues();
      	controller.getcommunicationValues();
      	controller.getbarrierValues();
      	controller.getneedValues();
      	controller.getorientValues();
      	controller.getorientationValues();
      	controller.getfambarrierValues();
      	controller.getfamcommunicationValues();
      	controller.getfamlearningValues();
      	controller.getexperienceValues();
      	controller.getdiagnosisValues();
      	controller.getmedicationValues();
      	controller.getprostheticValues();
      	controller.getmoodValues();
      	controller.getalleviatorValues();
      	controller.getadlValues();
      	controller.getexpressionValues();
      	controller.getpaintypeValues();
      	controller.getpainalleviatorValues();
      	controller.getpainadlValues();
      	controller.getpainexpressionValues();
      	controller.getpaindescriptorValues();
      	controller.getorthodicsValues();
      	
		NursingEvaluationEditController.addOrModifyAnnotation(null,'Neurotab',1,1,1,1,'','',evaluation.Id);
		Evaluation_Response__c[] neuroAnnotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='NeuroAnnotation' AND Evaluation__c=:evaluation.Id
        ];
		system.assertEquals(1,neuroAnnotations.size());
		system.assertEquals(0,controller.immuneAttachments.size());
		NursingEvaluationEditController.addorModifyAnnotation(null,'',1,1,1,1,'','',evaluation.Id);
		Evaluation_Response__c[] annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
		system.assertEquals(1,annotations.size());
		NursingEvaluationEditController.addorModifyAnnotation(neuroAnnotations[0].Id,'neuroTab',2,2,2,2,'','',evaluation.Id);
		NursingEvaluationEditController.deleteAnnotation(neuroAnnotations[0].id);
		neuroAnnotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='NeuroAnnotation' AND Evaluation__c=:evaluation.Id
        ];
		system.assertEquals(0,neuroAnnotations.size());
		controller.nextTab = 'diagnosticTab';
		controller.changeTab();
		controller.save();
		controller.selectedpainDescriptors = new List<String>();
		controller.selectedMoods = new List<String>();
		controller.selectedpainExpressions = new List<String>();
		controller.selectedPaintypes = new List<String>();
		controller.selectedExpressions = new List<String>();
		controller.selectedBarriers = new List<String>();
		controller.selectedCoping = new List<String>();
		controller.selectedLearning = new List<String>();
		controller.selectedCommunications = new List<string>();
		controller.selectedBeliefs = new List<string>();
		controller.selectedHalls = new List<String>();
		controller.selectedAbdomen = new List<String>();
		controller.selectedDentures = new List<String>();
		controller.selectedSaliva = new List<String>();
		controller.selectedCheeks = new List<String>();
		controller.selectedGums = new List<String>();
		controller.selectedTongues = new List<String>();
		controller.selectedClarities = new List<String>();
		controller.selectedSounds = new List<String>();
		controller.selectedIssues = new List<String>();
		controller.selectedLips = new List<String>();
		controller.selectedNeeds = new List<string>();
		controller.selectedOrients = new List<String>();
		controller.selectedOrientations = new List<String>();
		controller.selectedFambarriers = new List<String>();
		controller.selectedFamcommunications = new List<String>();
		controller.selectedFamlearnings = new List<String>();
		controller.selectedExperiences = new List<String>();
		controller.selectedDiagnosis = new List<String>();
		controller.selectedMedications = new List<String>();
		controller.selectedProsthetics = new List<string>();
		controller.selectedOrthodics = new List<string>();
		controller.selectedAlleviators = new List<string>();
		controller.selectedAdls = new List<string>();
		controller.selectedpainAlleviators = new List<String>();
		controller.selectedpainAdls = new List<String>();
		
		controller.save();
		
	}

}