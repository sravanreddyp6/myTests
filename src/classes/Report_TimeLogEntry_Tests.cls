@isTest
public with sharing class Report_TimeLogEntry_Tests {
	public static testmethod void simpleTests() {
		User user = TMN_Generic_Core_TestData.createUser('ESD General' , 'alias', 'testUser@TMN.com', 'Test', 'User', 'Redwood');
		TMN_User__c tmnUser = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c=:user.Id ];
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		insert new Evaluation_Response__c(
			RecordTypeID = Utility.getEvaluationResponseRecordType('Time Log'),
			Service_Assignment__c = testData.theSA.Id,
			Start_Date_Time__c = DateTime.newInstance(2015, 7, 11),
			End_Date_Time__c = DateTime.newInstance(2015, 8, 1),
			TMN_User__c = tmnUser.Id,
			Location__c = 'Test Location',
			Service_Type__c = 'Pre-Vocational',
			Narrative_Note__c = 'Narrative Notes',
			Is_Late_Entry__c = true
		);
		Report_TimeLogEntry controller = new Report_TimeLogEntry();
		System.assert(controller.programsList.size() > 0);
		controller.selectedPrograms = new List<Id>();
		controller.selectedPrograms.add(controller.programsList[0].getValue());
		controller.addPrograms();
		controller.select2PrmIds = new List<Id>();
		controller.select2PrmIds.add(controller.getSelect2List()[0].getValue());
		controller.removePrograms();
		controller.selectedPrograms.add(controller.getProgramsList()[0].getValue());
		controller.addPrograms();
		controller.runReport();  // this will generate errors because of no pbs was selected
		controller.selectedPBS.add(controller.getPbsList()[0].getValue());

		controller.runReport();  // this will generate errors because of blank start/end dates
		controller.startDate = Date.newInstance(2015, 8, 31);
		controller.endDate = Date.newInstance(2015, 8, 1);
		controller.runReport();  // error because start Date > end Date

		controller.startDate = Date.newInstance(2015, 7, 1);
		controller.endDate = Date.newInstance(2015, 8, 31);
		controller.runReport();

		controller.runPdf();
		controller.runExcel();
		controller.cancelToNewRun();
	}
}