@isTest
private class NursingEvaluationViewTest {
	static testmethod void viewTests(){
		
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
		
		NursingEvaluationViewController controller = new NursingEvaluationViewController(new ApexPages.StandardController(evaluation));
		system.assertNotEquals(0,controller.sliderOptions.size());
		system.assertNotEquals(0,controller.painsliderOptions.size());
	    system.assertEquals(0, controller.annotations.size());
	    system.assertEquals(0,controller.neuroAnnotations.size());
	    system.assertEquals(0,controller.immuneAttachments.size());
	    system.assertNotEquals(null, controller.relatedParties);
	    controller.showAddRelatedParty();
	    system.assertEquals(null, controller.currentRelatedParty.Id);
	    controller.currentRelatedPartyId = rp.Id;
	    controller.showEditRelatedParty();
	    system.assertEquals(rp.Id, controller.currentRelatedParty.Id);
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
		
	}
	
	
}