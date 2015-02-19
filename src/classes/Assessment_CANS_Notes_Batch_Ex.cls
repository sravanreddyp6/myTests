public with sharing class Assessment_CANS_Notes_Batch_Ex {
	public Assessment_CANS_Notes_Batch_Ex() {
		
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

			if(putIn){ mapMostRecent.put(admit, item); }

		}


		return mapMostRecent.values();

	}


	public static list<Assessment__c> requiresEmail (list<Assessment__c> AllAssess){
		list<Assessment__c> returnedItems = new list<Assessment__c>();
		
		for(Assessment__c item : AllAssess){
			Integer assessmentDaysFromToday = item.Assessment_Date__c.daysbetween(system.today() );
			system.debug('days from today' + assessmentDaysFromToday);
			if( assessmentDaysFromToday == 75 || assessmentDaysFromToday == 82 || assessmentDaysFromToday >= 87 ){
				returnedItems.add( item );
			}
		}
		return returnedItems;
	}


	public static list<Messaging.SingleEmailMessage> incompleteAssessmentNotes(list<Assessment__c> AllAssess){
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
}