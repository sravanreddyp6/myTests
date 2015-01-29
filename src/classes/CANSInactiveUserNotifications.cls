public with sharing class CANSInactiveUserNotifications {
	public static void sendReport() {
		Id CANSInactiveUserErrorRecordType = [
			Select id from RecordType where sObjectType = 'Error__c' and developerName ='CANS_Inactive_User'
		].id;
		Set<String> inactiveUserIds = new Set<String>();
		for (Error__c[] errors: [SELECT Id, Record_Id__c FROM Error__c WHERE RecordTypeId = :CANSInactiveUserErrorRecordType AND CreatedDate = LAST_N_DAYS:7]) {
			for (Error__c error: errors) {
				inactiveUserIds.add(error.Record_Id__c);
			}
		}
		if (inactiveUserIds.size() == 0) {
			System.debug('No inactive users. Exiting...');
			return;
		}
		User[] inactiveUsers = [SELECT Id, Name FROM User WHERE Id IN :inactiveUserIds];
		Set<Id> recipientIds = new Set<Id>();
		for (CANS_Inactive_User_Report_Recipients__c recipient: [SELECT Name, User_Id__c FROM CANS_Inactive_User_Report_Recipients__c]) {
			recipientIds.add((Id) recipient.User_Id__c);
		}
		List<String> recipientEmails = new List<String>();
		for (User recipient: [SELECT Id, Email FROM User WHERE Id IN :recipientIds]) {
			recipientEmails.add(recipient.Email);
		}
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setBccAddresses(recipientEmails);
		mail.setReplyTo('notifications@thementornetwork.com');
		mail.setSenderDisplayName('MENTOR Assessment Notification');
		mail.setSubject('Inactive Users Notification from the MENTOR Salesforce Assessment App');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		String plainTextBody = 'Hello,\r\n\r\n' +
			'The following users are owners of one or more CANS Assessment, ' +
			'but they are no longer Active in Salesforce. Please take appropriate ' +
			'actions:\r\n';
		String htmlBody = 'Hello,<br /><br />' +
			'The following users are owners of one or more CANS Assessment, ' +
			'but they are no longer Active in Salesforce. Please take appropriate ' +
			'actions:<br /><ul>';
		for (User inactiveUser: inactiveUsers) {
			plainTextBody += '- ' + inactiveUser.Name + '\r\n';
			htmlBody += '<li><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + inactiveUser.Id + '">' + inactiveUser.Name + '</a></li>';
		}
		plainTextBody += '\r\nThanks!\r\nThe MENTOR Salesforce Assessment App';
		htmlBody += '</ul><br />Thanks!<br />The MENTOR Salesforce Assessment App';
		mail.setPlainTextBody(plainTextBody);
		mail.setHtmlBody(htmlBody);
		mail.setSaveAsActivity(false);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
	}
}