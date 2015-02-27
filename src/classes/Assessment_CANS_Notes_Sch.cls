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

		datetime daysAgo = system.now().addDays(-30);
		set<id> inactiveAdmitsWithLastAssessment = new set<id>();
		for(Assessment__c item: [select id, admission__c 
										from assessment__c 
											where Assessment_Type__r.name = 'CANS' 
											AND Interval__c = 'Discharge'
											AND Disregard__c = false 
											AND Admission__r.Status__c != 'Active'
											AND Status__c = 'Locked' ]){
			inactiveAdmitsWithLastAssessment.add(item.admission__c);

		}		

		list<Assessment__c> incompAssess = [select id, name, assessment_date__c, CreatedDate,
															owner.id, owner.isActive, Owner.LastName, Owner.FirstName,
															admission__c, accountperson__c, accountperson__r.PBS_Identifier__pc,
															status__c, Interval__c 
																from assessment__c 
																	where CreatedDate <= :daysAgo
																		AND Status__c <> 'Locked'
																		AND owner.isActive = true
																		AND Disregard__c = false 
																		AND (
																				(
																					admission__r.Status__c = 'Active' 
																				)
																				OR(
																					admission__c NOT IN :inactiveAdmitsWithLastAssessment 
																				)
																			)
																		AND Assessment_Type__r.name = 'CANS'];	
		devMsg2 = '<br/>' + Assessment_CANS_Notes_Batch_Ex.getIDfromList(incompAssess);																		
		Assessment_CANS_Notes_Batch2 b2 = new Assessment_CANS_Notes_Batch2(incompAssess, 'Imcomplete size - ' + incompAssess.size(), devMsg2);
		database.executebatch(b2);																			
	}

}