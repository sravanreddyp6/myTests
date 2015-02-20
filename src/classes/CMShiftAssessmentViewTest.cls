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
		eval.Shift_Start_time__c = system.Now();
		eval.Shift_End_time__c = system.Now()+5;
		insert eval;
		
		Task t = new Task();
		t.WhatID = eval.Id;
		t.WhoId = testData.contactID;
		t.status ='Open';
		
		insert t;
		
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
		
		controller.evaluation.Shift_Start_Time__c = system.Now().addMinutes(1);
		Datetime startTime = system.Now().addMinutes(1); 
		controller.updateshiftTime();
		system.assertEquals(startTime, controller.evaluation.shift_start_time__c);
		
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
		
		CMShiftAssessmentView.finddupeEval(datetime.Now().format(), system.Now().addMinutes(5).format(), testData.theSA.Id, controller.evaluation.Id);
		
		controller.disregardEval();
		Task tk = [SELECT Id, Status FROM Task WHERE WhatId =:controller.evaluation.Id LIMIT 1];
		system.assertEquals('Disregard',controller.evaluation.Status__c,controller.evaluation.Status__c);
		system.AssertEquals('Completed',tk.Status);
	
		controller.finalizeEval();
		system.assertEquals('Final',controller.evaluation.Status__c,controller.evaluation.Status__c);
		
	}
}