@isTest
private class CMShiftAssessmentViewTest {

	private static testmethod void myTests() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		Evaluation__c eval = new Evaluation__c ();
		eval.ServiceAssignment__c = testData.theSA.Id;
		eval.Resident_Demonstrating_Issues__c ='test;test2';
		eval.Orientation__c = 'test;test2';
		eval.Mood__c = 'test;test2';
		eval.Breathe_sounds__c ='test;test2';
		eval.Autonomic_Dysreflexia_Areas_Assessed__c = 'test;test2';
		insert eval;
		
		PageReference pg = Page.CMShiftAssessmentView;
		test.setCurrentpage(pg);
		Apexpages.standardcontroller sc = new ApexPages.StandardController(eval);
		CMShiftAssessmentView controller = new CMShiftAssessmentView(sc);
		system.assertEquals(controller.evaluation, eval);
		system.assertNotEquals(null, controller.baseUrl);
		system.assertNotEquals(null, controller.painSliderOptions);
		system.assertEquals(0,controller.pains.Size());
		system.assertEquals(0,controller.annotations.size());
		system.assertEquals(0, controller.pUlcers.size());
		
		controller.getcopingValues();
		controller.getneuroOrientValues();
		controller.getmoodValues();
		controller.getbreatheSounds();
		controller.getDysreflexiaValues();
		
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
		
		controller.disregardEval();
		system.assertEquals('Disregard',controller.evaluation.Status__c,controller.evaluation.Status__c);
		
		controller.finalizeEval();
		system.assertEquals('Final',controller.evaluation.Status__c,controller.evaluation.Status__c);
	}
}