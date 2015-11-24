public with sharing class CANSInactiveUserNotifications {
	public static void sendReport() {
		Id CANSInactiveUserErrorRecordType = [
			Select id from RecordType where sObjectType = 'Error__c' and developerName ='CANS_Inactive_User'
		].id;
		Set<String> inactiveAssessmentIds = new Set<String>();
		for (Error__c[] errors: [SELECT Id, Record_Id__c FROM Error__c WHERE RecordTypeId = :CANSInactiveUserErrorRecordType AND CreatedDate = LAST_N_DAYS:7]) {
			for (Error__c error: errors) {
				inactiveAssessmentIds.add(error.Record_Id__c);
			}
		}
		if (inactiveAssessmentIds.size() == 0) {
			System.debug('No inactive users. Exiting...');
			return;
		}
		Assessment__c[] inactiveAssessments = [
			SELECT Id, Admission__r.Person_Being_Served__r.Id, Admission__r.Person_Being_Served__r.Name,
			       Owner.Id, Owner.Name, Admission__r.State__c
			  FROM Assessment__c WHERE Id IN :inactiveAssessmentIds
		];
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
			'The following Persons Being Served have CANS Assessments whose ' +
			'Owners are Inactive in Salesforce. Please take appropriate ' +
			'actions:\r\n';
		String htmlBody = 'Hello,<br /><br />' +
			'The following Persons Being Served have CANS Assessments whose ' +
			'Owners are Inactive in Salesforce. Please take appropriate ' +
			'actions:<br /><br />' +
			'<table style="border:1px solid black;border-collapse:collapse;">' +
			'<thead><tr><th style="border:1px solid black; padding: 3px;">Person Being Served</th>' +
			'<th style="border:1px solid black; padding: 3px;">State</th>' +
			'<th style="border:1px solid black; padding: 3px;">Assessment Owner</th></tr></thead><tbody>';
		Set<Id> processedPBS = new Set<Id>();
		for (Assessment__c inactiveAssessment: inactiveAssessments) {
			if (processedPBS.contains(inactiveAssessment.Admission__r.Person_Being_Served__r.Id)) {
				continue;  // So that we don't have duplicate PBS in the report
			}
			plainTextBody += '- ' + inactiveAssessment.Admission__r.Person_Being_Served__r.Name + ' - ' + inactiveAssessment.Admission__r.State__c + ' - ' + inactiveAssessment.Owner.Name + '\r\n';
			htmlBody += '<tr><td style="border:1px solid black; padding: 3px;"><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + inactiveAssessment.Admission__r.Person_Being_Served__r.Id + '">' + inactiveAssessment.Admission__r.Person_Being_Served__r.Name + '</a></td>' +
				'<td style="border:1px solid black; padding: 3px;">' + inactiveAssessment.Admission__r.State__c + '</td>' +
				'<td style="border:1px solid black; padding: 3px;"><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + inactiveAssessment.Owner.Id + '">' + inactiveAssessment.Owner.Name + '</a></td>' +
				'</tr>';
			processedPBS.add(inactiveAssessment.Admission__r.Person_Being_Served__r.Id);
		}
		plainTextBody += '\r\nThanks!\r\nThe MENTOR Salesforce Assessment App';
		htmlBody += '</tbody></table><br />Thanks!<br />The MENTOR Salesforce Assessment App';
		mail.setPlainTextBody(plainTextBody);
		mail.setHtmlBody(htmlBody);
		mail.setSaveAsActivity(false);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
	}
}