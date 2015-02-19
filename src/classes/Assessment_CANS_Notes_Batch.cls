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
   		system.debug('starting ex');
   		system.debug(scope);
		Assessment__c[] assessReqNote = Assessment_CANS_Notes_Batch_Ex.mostRecentAssessments(scope);
		system.debug(assessReqNote);
		// now with the most recent assessment we'll find out if they need an email/task note
		assessReqNote = Assessment_CANS_Notes_Batch_Ex.requiresEmail(assessReqNote);
		system.debug(assessReqNote);
		Messaging.sendEmail(Assessment_CANS_Notes_Batch_Ex.incompleteAssessmentNotes(assessReqNote) );
		system.debug('starting emails');
		system.debug(assessReqNote);
	}

	
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}