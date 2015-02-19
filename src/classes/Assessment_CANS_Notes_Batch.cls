global class Assessment_CANS_Notes_Batch implements Database.Batchable<sObject> {
	
	global final list<Assessment__c> query ;
	
	global Assessment_CANS_Notes_Batch(List<Assessment__c> q) {
		system.debug('starting construct');
		Query=q;
	}
	
	global list<SObject> start(Database.BatchableContext bc) {
		system.debug('starting start');
		return Query;
	}

   	global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {
   	//this list will get distilled down over the next few steps into a list of assessment for which we need to send an email to the owner
   	// because a new assessment is due
   	//;ets get a baseline to start with
   	// we'll distill the following query to just the most recent assessments
   		string devMsg = '';
   		try {
	   			system.debug('starting ex');
	   			system.debug(scope);
   				devMsg += 'initail scope size = ' + scope.size();
			Assessment__c[] assessReqNote = Assessment_CANS_Notes_Batch_Ex.mostRecentAssessments(scope);
				system.debug('starting requires email');
				system.debug(assessReqNote);
				devMsg += '<br/> after finding most recent assessment size = ' + assessReqNote.size();
			// now with the most recent assessment we'll find out if they need an email/task note
			assessReqNote = Assessment_CANS_Notes_Batch_Ex.requiresEmail(assessReqNote);
				system.debug('starting remove inactive users');
				system.debug(assessReqNote);
				devMsg += '<br/> requiring email size = ' + assessReqNote.size();

			assessReqNote = Assessment_CANS_Notes_Batch_Ex.removeAndProcessInactiveUsers(assessReqNote);
				system.debug('starting emails');
				system.debug(assessReqNote);
				devMsg += '<br/> after inactive users removed size = ' + assessReqNote.size();
			Messaging.sendEmail(Assessment_CANS_Notes_Batch_Ex.missingAssessmentNotes(assessReqNote) );

			//now lets process any new task we need to create
			Integer taskCount =  Assessment_CANS_Notes_Batch_Ex.setupTasks( assessReqNote );
				devMsg += '<br/> requiring task size = ' + taskCount;


			//we also need to send notes for assessments that are not incomplete and over 30 days old
			// if gov limits are hit we can move this check to a new batch class/sched.
			date daysAgo = system.today().addDays(-30);
			list<Assessment__c> incompAssess = [select id, name, assessment_date__c, CreatedDate,
													owner.id, owner.isActive, Owner.LastName, Owner.FirstName,
													admission__c, accountperson__c, accountperson__r.PBS_Identifier__pc,
													status__c 
														from assessment__c 
															where CreatedDate <= :daysAgo
																AND Status__c <> 'Locked'
																AND Admission__r.status__c = 'Active'
																AND Assessment_Type__r.name = 'CANS'];
			Messaging.sendEmail(Assessment_CANS_Notes_Batch_Ex.incompleteAssessmentNotes(incompAssess) );
				devMsg += '<br/> requiring note because assessment is not finished = ' + incompAssess.size();
				
				Messaging.reserveSingleEmailCapacity(1);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];

				mail.setTargetObjectId(idForAssmtDeveloper.Id);
				mail.setReplyTo('notifications@thementornetwork.com');
				mail.setSenderDisplayName('Complete: MENTOR CANS Notification');
				mail.setSubject('Complete: MENTOR CANS Notification');
				mail.setBccSender(false);
				mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
				mail.setUseSignature(false);
				mail.setHtmlBody('CANS notes processing finished <br/><br/> <b>data for the nerds:</b> <br/>' + devMsg ) ;
				mail.setSaveAsActivity(false);
				List<Messaging.SingleEmailMessage> devEmail = new List<Messaging.SingleEmailMessage>();
				devEmail.add(mail);
				Messaging.sendEmail(devEmail);

		}
		catch( Exception e ){
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];

			mail.setTargetObjectId(idForAssmtDeveloper.Id);
			mail.setReplyTo('notifications@thementornetwork.com');
			mail.setSenderDisplayName('FAILURE: MENTOR CANS Notification');
			mail.setSubject('FAILURE: MENTOR CANS Notification');
			mail.setBccSender(false);
			mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
			mail.setUseSignature(false);
			mail.setHtmlBody('Hello an error occured: <br/>' + e + '<br/>Stack trace:' + e.getStackTraceString() ) ;
			mail.setSaveAsActivity(false);
			List<Messaging.SingleEmailMessage> errorEmail = new List<Messaging.SingleEmailMessage>();
			errorEmail.add(mail);
			Messaging.sendEmail(errorEmail);

		}
	}

	
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}