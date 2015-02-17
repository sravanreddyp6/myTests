@isTest
public with sharing class Report_CANS_OverdueAssessments_Test {
	static testmethod void simpleTests() {
		Assessment_Type__c cans = new Assessment_Type__c(Name='CANS');
		insert cans;

		String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName',
			LastName='Test LName',
			PersonMailingStreet='test@yahoo.com',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SFO',
			PersonMailingStateCode='AZ',
			PersonEmail='test@yahoo.com',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678'
		);
		insert Accnt;
		List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
		Id aContactId = testAcct[0].PersonContactId;
		Id aAccountId = testAcct[0].Id;

		Admission__c admission = new Admission__c(
			Name = 'TEST ADM 2',
			Person_Being_Served__c = aContactId,
			Effective_Date__c = date.newInstance(2013, 7, 1),
			Network_Offering__c = 'ARY',
			State__c = 'AZ'
		);
		insert admission;

		Assessment__c assmt1 = new Assessment__c(
			Admission__c = admission.Id,
			Assessment_Type__c = cans.Id,
			Assessment_Date__c = Date.today().addDays(-100),
			Interval__c = 'Intake',
			Status__c = 'Locked',
			AccountPerson__c = aAccountId
		);
		insert assmt1;

		Assessment__c[] assmts = new Assessment__c[] {
			new Assessment__c(
				Admission__c = admission.Id,
				Assessment_Type__c = cans.Id,
				Assessment_Date__c = Date.today(),
				Interval__c = 'Quarterly',
				Quarter__c = 1,
				AccountPerson__c = aAccountId,
				Disregard__c = true
			)
		};
		insert assmts;
		Report_CANS_OverdueAssessments controller = new Report_CANS_OverdueAssessments();
		Set<Id> results = new Set<Id>();
		for (Assessment__c[] partialList: controller.listWrapper) {
			for (Assessment__c individualAsmt: partialList) {
				results.add(individualAsmt.Id);
			}
		}
		System.assertEquals(1, results.size());
		System.assertNotEquals(null, controller.baseUrl);
	}
}