@isTest
public class CMShiftAssessmentNotificationsTest {
	
	static testmethod void myTest(){
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		List<Evaluation__c> testEvals = new List<Evaluation__c>();
		for(integer i=0; i<10; i++ ){
			Evaluation__c e = new Evaluation__c();
			e.RecordTypeId = Utility.getEValuationRecordType('CMShiftAssessment');
			e.Status__c = 'Draft';
			e.Shift_Start_time__c = system.Now().addHours(-1);
			e.Shift_End_time__c = system.Now().addMinutes(-1);
			e.ServiceAssignment__c = testData.theSA.Id;
			testEvals.add(e);
		}
		
		insert testEvals;
		
		set<id> evalIds = new Set<id>();
		for(Evaluation__c e : testEvals){
			evalIds.add(e.Id);
		}
		
        String query = 'SELECT Id,Name,Owner.Id,ServiceAssignment__r.Admission__r.Person_Being_Served__c,Shift_End_time__c, Status__c FROM Evaluation__c WHERE RecordType.Name = \'CMShiftAssessment\' AND Status__c = \'Draft\'';
        Test.StartTest();
		CMShiftAssessmentNotifications b = new CMShiftAssessmentNotifications(query);
		Database.executebatch(b);
		Test.StopTest();
		
		List<Task> tobeCreated = [SELECT Id FROM Task WHERE WhatId IN: evalIds];
		system.assertNotEquals(0, tobeCreated.Size());
		
		
		
	}

}