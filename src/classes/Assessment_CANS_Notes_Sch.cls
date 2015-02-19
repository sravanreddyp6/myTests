global class Assessment_CANS_Notes_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
		Assessment_CANS_Notes_Batch b = new Assessment_CANS_Notes_Batch([select id, name, status__c, assessment_date__c, 
								admission__c, accountperson__c, accountperson__r.PBS_Identifier__pc,
								owner.id, owner.isActive, Owner.LastName, Owner.FirstName
									from Assessment__c 
										Where Status__c = 'Locked'
											AND Disregard__c = false 
											AND Admission__r.status__c = 'Active'
											AND Assessment_Type__r.name = 'CANS']);
		database.executebatch(b);
	}
}