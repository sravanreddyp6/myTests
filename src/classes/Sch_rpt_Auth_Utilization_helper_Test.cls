@isTest
public with sharing class Sch_rpt_Auth_Utilization_helper_Test {
	public static testmethod void simpleTests() {
		Tmn_Generic_Core_TestData testData = new Tmn_Generic_Core_TestData();

		Map<String, Schema.RecordTypeInfo> progressNoteRTMap = Progress_Note__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		TestUtils.ProgressNoteBuilder progressNoteBuilder = new TestUtils.ProgressNoteBuilder();
		Progress_Note__c[] progressNotes = new Progress_Note__c[] {
			progressNoteBuilder
				.setServiceAssignmentId(testData.theSA.Id)
				.setServiceCodeId(testData.theServiceCode.Id)
				.setAdmissionId(testData.theAdm.Id)
				.setStartTime(Date.today().addDays(-5))
				.setEndTime(Date.today())
				.setPersonBeingServedId(testData.contactId)
				.setNoApprovalNeeded(true)
				.setApprovalStatus('Approved')
				.setStatus('Final')
				.setPurposeServiceIsBillable(false)
				.setTherapyDiscipline('PT')
				.setRecordType('Therapy')
				.getInstance(),
			progressNoteBuilder.setTherapyDiscipline('OT').getInstance(),
			progressNoteBuilder.setTherapyDiscipline('SLP').getInstance(),
			progressNoteBuilder.setTherapyDiscipline('Counseling').getInstance(),
			progressNoteBuilder.setTherapyDiscipline('BIT').getInstance()
		};
		insert progressNotes;

		Funding_Source__c fundingSource = new Funding_Source__c(
			Service_Assignment__c = testData.theSA.Id,
			Type_of_Coverage__c='Primary'
		);
		insert fundingSource;
		Map<String, Schema.RecordTypeInfo> authorizationRTMap = Authorization__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		Authorization__c authorization = new Authorization__c(
			Person_Being_Served__c = testData.contactID,
			Service_Assignment__c = testData.theSA.Id,
			Funding_Source__c = fundingSource.id,
			RecordTypeId = authorizationRTMap.get('Costs_TherapyNR').getRecordTypeId(),
			Days_Authorized_From__c = Date.today().addDays(-5),
			Days_Authorized_To__c = Date.today()
		);
		insert authorization;

		Date startDate = Date.today().addDays(-30);
		Date endDate = Date.today().addDays(30);
		Sch_rpt_Auth_Utilization_helper controller = new Sch_rpt_Auth_Utilization_helper(startDate, endDate);

		System.assertNotEquals('', controller.getAttach());
		System.assertEquals('6/24/2016', controller.simpleDate(Date.newInstance(2016, 6, 24)));
	}
}