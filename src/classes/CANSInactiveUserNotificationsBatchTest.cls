@isTest
public with sharing class CANSInactiveUserNotificationsBatchTest {
	static testmethod void simpleTests() {
		insert new CANS_Inactive_User_Report_Recipients__c(
			Name = 'Test (Integration)',
			User_Id__c = '005U0000001Btzp'
		);
		CANSInactiveUserNotificationsRunBatch batch = new CANSInactiveUserNotificationsRunBatch();
		batch.execute(null);

		Id CANSInactiveUserErrorRecordType = [
			Select id from RecordType where sObjectType = 'Error__c' and developerName ='CANS_Inactive_User'
		].id;
		insert new Error__c(
			RecordTypeId = CANSInactiveUserErrorRecordType,
			Record_Id__c = '005U0000001Btzp'
		);
		batch.execute(null);
	}
}