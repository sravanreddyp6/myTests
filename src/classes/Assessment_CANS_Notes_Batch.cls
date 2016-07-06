global class Assessment_CANS_Notes_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	global final list<Assessment__c> query ;
	global string devMsg;
	global string devMsg2;
	
	global Assessment_CANS_Notes_Batch(List<Assessment__c> q, string msg, string msg2) {
		system.debug('starting construct');
		Query=q; devMsg = msg; devMsg2 = msg2;
		//devMsg = devmsg; 
	}
	
	global list<SObject> start(Database.BatchableContext bc) {
		system.debug('starting start');
		
		return Query;
	}

   	global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {

   		system.debug('starting ex');
   		//string devMsg = '';
   		try {

			Messaging.sendEmail(Assessment_CANS_Notes_Batch_Ex.missingAssessmentNotes(scope) );

			//now lets process any new task we need to create
			Integer taskCount =  Assessment_CANS_Notes_Batch_Ex.setupTasks( scope );
				devMsg += '<br/> requiring task size = ' + taskCount;

		}
		catch( Exception e ){
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			User idForAssmtDeveloper = [ SELECT Id FROM User WHERE Name = 'integration' LIMIT 1];

			mail.setTargetObjectId(idForAssmtDeveloper.Id);
			mail.setReplyTo('notifications@thementornetwork.com');
			mail.setSenderDisplayName('FAILURE: MENTOR CANS Notification');
			mail.setSubject('FAILURE: MENTOR CANS Notification');
			mail.setBccSender(false);
			//mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
			mail.setUseSignature(false);
			mail.setHtmlBody('Hello an error occured: <br/>' + e + '<br/>Stack trace:' + e.getStackTraceString() ) ;
			mail.setSaveAsActivity(false);
			List<Messaging.SingleEmailMessage> errorEmail = new List<Messaging.SingleEmailMessage>();
			errorEmail.add(mail);
			Messaging.sendEmail(errorEmail);

		}
	}

	
	
	global void finish(Database.BatchableContext BC) {
				Messaging.reserveSingleEmailCapacity(1);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				User idForAssmtDeveloper = [ SELECT Id FROM User WHERE Name = 'integration' LIMIT 1];

				mail.setTargetObjectId(idForAssmtDeveloper.Id);
				mail.setReplyTo('notifications@thementornetwork.com');
				mail.setSenderDisplayName('Complete: MENTOR Missing CANS Notification');
				mail.setSubject('Complete: MENTOR CANS Notification');
				mail.setBccSender(false);
				///mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
				mail.setUseSignature(false);
				mail.setHtmlBody('CANS notes processing finished <br/><br/> <b>data for the nerds:</b> <br/>' + devMsg + '<br/><br/> <b>Data filtering - </b><br/>' + devMsg2 ) ;
				mail.setSaveAsActivity(false);
				List<Messaging.SingleEmailMessage> devEmail = new List<Messaging.SingleEmailMessage>();
				devEmail.add(mail);
				Messaging.sendEmail(devEmail);		
	}
	
}