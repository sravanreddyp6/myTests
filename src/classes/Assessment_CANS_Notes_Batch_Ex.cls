public with sharing class Assessment_CANS_Notes_Batch_Ex {
	public static string devMessage;
	public Assessment_CANS_Notes_Batch_Ex() {
		
	}



	public static string getIDfromList(list<Assessment__c> a){
		string str = '<br/>';
		for(Assessment__c item : a){
			str += item.id + '<br/>';
		}
		str += '<br/><br/>';
		return str;
	}
	public static list<Assessment__c> mostRecentAssessments(List<Assessment__c> AllAssess){
		//when given a list of assessments this method will return a list of the most recent assessment based on based on assessment date and group by admissions
		//
		Map<id, Assessment__c> mapMostRecent = new map<id, Assessment__c>();

		for(Assessment__c item : AllAssess){
			boolean putIn = false;
			Id admit = item.Admission__c;
			date curAssessDate = item.Assessment_Date__c;

			if( !mapMostRecent.containsKey(admit) ) { putIn = true;}
			else if( mapMostRecent.get(admit).Assessment_Date__c < curAssessDate ){ putIn = true; }

			if(putIn){ 
				mapMostRecent.put(admit, item); 
			}
		}

		return mapMostRecent.values();
	}


	public static list<Assessment__c> requiresEmail (list<Assessment__c> AllAssess){
		list<Assessment__c> returnedItems = new list<Assessment__c>();
		
		for(Assessment__c item : AllAssess){
			Integer assessmentDaysFromToday = item.Assessment_Date__c.daysbetween(system.today() );
			system.debug('days from today' + assessmentDaysFromToday);
			if( item.Interval__c != 'Discharge' && (assessmentDaysFromToday == 75 || assessmentDaysFromToday == 82 || assessmentDaysFromToday >= 87) ){
				returnedItems.add( item );
			}
		}
		return returnedItems;
	}

	public static Integer setupTasks(list<Assessment__c> AllAssess){
		set<id> admitIDs = new set<id>();
		for(Assessment__c item : AllAssess){
			admitIDs.add(item.Admission__c);
		}
		map<id, task> mapCurrentTasks = new map<id, task>();
		for(task item : [SELECT Id, Subject, Status, WhatId, OwnerId
										FROM Task
										WHERE Subject = 'CANS Assessment Reminder'
										  AND Status = 'In Progress'
										  AND WhatID IN : admitIDs]){
			mapCurrentTasks.put(item.WhatID, item);

		}
		list<task> newTasks = new list<task>();
		for(Assessment__c item : AllAssess){
			if( !mapCurrentTasks.containsKey(item.Admission__c) ){
				Task t = new Task(  Subject = 'CANS Assessment Reminder', 
									Status = 'In Progress', 
									Priority = 'Normal', 
									OwnerId = item.OwnerId, 
									Description = 'You have a person being served who appears to have a CANS assessment due or coming due: ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + item.Admission__c, 
									WhoId = item.AccountPerson__r.PersonContactId, 
									WhatId = item.Admission__c, 
									ActivityDate = system.today() );
				newTasks.add(t);
			}
		}

		insert newTasks;
		return newTasks.size();

	}

	public static list<Assessment__c> removeAndProcessInactiveUsers (list<Assessment__c> AllAssess){
		list<Assessment__c> returnedItems = new list<Assessment__c>();
		list<error__c> inactiveUserErrors = new list<error__c>();
		Id CANSInactiveUserErrorRecordType = [
				Select id from RecordType where sObjectType = 'Error__c' and developerName ='CANS_Inactive_User'
			].id;		
		for(Assessment__c item : AllAssess){

			if( !item.owner.isActive ){
				inactiveUserErrors.add(new Error__c(
					RecordTypeId = CANSInactiveUserErrorRecordType,
					Record_Id__c = item.Id,
					Description__c = 'Emails are not sent to inactive users' + item.owner.id
				));
			}
			else {
					returnedItems.add( item );
			}
		}
		insert inactiveUserErrors;
		return returnedItems;
	}

	public static list<Messaging.SingleEmailMessage> missingAssessmentNotes(list<Assessment__c> AllAssess){
		List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
		String TMP_STR = 'Hello {0},<br/>A CANS Assessment is due for client:{1}. <br /><br />Please go to the <a href="{2}">admission</a> to create the next Assessment';

		for(Assessment__c item : AllAssess){
			Messaging.reserveSingleEmailCapacity(1);

			// Processes and actions involved in the Apex transaction occur next,
			// which conclude with sending a list of emails.

			// Now create a new single email message object
			// that will send out a single email to the addresses in the To, CC & BCC list.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			// Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
			// which we are sending a notification.
			mail.setTargetObjectId(item.OwnerId);

			// Specify the address used when the recipients reply to the email.
			mail.setReplyTo('notifications@thementornetwork.com');


			// Specify the name used as the display name.
			mail.setSenderDisplayName('CANS Assessment Notification');


			// Specify the subject line for the email.
			mail.setSubject('A CANS Assessment is Due for ' + item.accountperson__r.PBS_Identifier__pc);

			// Set to True if you want to BCC yourself on the email.
			mail.setBccSender(false);

			// Optionally append the salesforce.com email signature to the email.
			// The email address of the user executing the Apex Code will be used.
			mail.setUseSignature(false);

			String [] args = new String[] { item.Owner.FirstName + ' ' + item.Owner.LastName,
											item.accountperson__r.PBS_Identifier__pc,
											System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + item.Admission__c
											 };

			mail.setPlainTextBody(String.format(TMP_STR, args) );
			mail.setHtmlBody(String.format(TMP_STR, args) );

			mail.setSaveAsActivity(false);

			allEmails.add(mail);
		}//end loop
		return allEmails;
	}

	public static list<Messaging.SingleEmailMessage> incompleteAssessmentNotes(list<Assessment__c> AllAssess){
		List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
		String TMP_STR = 'Hello {0},<br/>A CANS Assessment was started for client:{1}, however, it is not marked as \'Locked\' as of the 30 day mark <br /><br />Please click <a href="{2}">here</a> to finish the CANS Assessment';

		for(Assessment__c item : AllAssess){
			Messaging.reserveSingleEmailCapacity(1);


			// Processes and actions involved in the Apex transaction occur next,
			// which conclude with sending a list of emails.

			// Now create a new single email message object
			// that will send out a single email to the addresses in the To, CC & BCC list.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			// Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
			// which we are sending a notification.
			mail.setTargetObjectId(item.OwnerId);

			// Specify the address used when the recipients reply to the email.
			mail.setReplyTo('notifications@thementornetwork.com');


			// Specify the name used as the display name.
			mail.setSenderDisplayName('CANS Assessment Notification');


			// Specify the subject line for the email.
			mail.setSubject('A CANS Assessment is incomplete ' + item.accountperson__r.PBS_Identifier__pc);

			// Set to True if you want to BCC yourself on the email.
			mail.setBccSender(false);

			// Optionally append the salesforce.com email signature to the email.
			// The email address of the user executing the Apex Code will be used.
			mail.setUseSignature(false);

			String [] args = new String[] { item.Owner.FirstName + ' ' + item.Owner.LastName,
											item.accountperson__r.PBS_Identifier__pc,
											System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + item.id
											 };

			mail.setPlainTextBody(String.format(TMP_STR, args) );
			mail.setHtmlBody(String.format(TMP_STR, args) );

			mail.setSaveAsActivity(false);

			allEmails.add(mail);
		}//end loop
		return allEmails;	

	}
}