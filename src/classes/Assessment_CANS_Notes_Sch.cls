global class Assessment_CANS_Notes_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
			string devMsg = '';
			string devMsg2 = '';
			Assessment__c[] assessReqNote = [select id, name, status__c, assessment_date__c, 
								admission__c, Interval__c,
								accountperson__c, accountperson__r.PBS_Identifier__pc, AccountPerson__r.PersonContactId,
								owner.id, owner.isActive, Owner.LastName, Owner.FirstName
									from Assessment__c 
										Where Status__c = 'Locked'
											AND Disregard__c = false 
											AND Admission__r.status__c = 'Active'
											AND Assessment_Type__r.name = 'CANS'];
	   			
	   			system.debug(assessReqNote);
   				devMsg += 'initail scope size = ' + assessReqNote.size();
   				devMsg2 += 'Inital recs:' + Assessment_CANS_Notes_Batch_Ex.getIDfromList(assessReqNote);
			assessReqNote = Assessment_CANS_Notes_Batch_Ex.mostRecentAssessments( assessReqNote);

				system.debug('starting requires email');
				system.debug(assessReqNote);
				devMsg += '<br/> after finding most recent assessment size = ' + assessReqNote.size();
				devMsg2 += 'most recenet recs:' + Assessment_CANS_Notes_Batch_Ex.getIDfromList(assessReqNote);
			// now with the most recent assessment we'll find out if they need an email/task note
			assessReqNote = Assessment_CANS_Notes_Batch_Ex.requiresEmail(assessReqNote);

				system.debug('starting remove inactive users');
				system.debug(assessReqNote);
				devMsg += '<br/> requiring email size = ' + assessReqNote.size();
				devMsg2 += 'req email recs:' + Assessment_CANS_Notes_Batch_Ex.getIDfromList(assessReqNote);

			assessReqNote = Assessment_CANS_Notes_Batch_Ex.removeAndProcessInactiveUsers(assessReqNote );

				system.debug('starting emails');
				system.debug(assessReqNote);				
				devMsg += '<br/> after inactive users removed size = ' + assessReqNote.size();	
				devMsg2 += 'after inactive removed recs:' + Assessment_CANS_Notes_Batch_Ex.getIDfromList(assessReqNote);	

		Assessment_CANS_Notes_Batch b = new Assessment_CANS_Notes_Batch(assessReqNote, devMsg, devMsg2);
		database.executebatch(b);
	}

}