global class CMShiftAssessmentNotifications implements Database.Batchable<sObject> {
	global final string query;
	
	global CMShiftAssessmentNotifications(string q){
		query=q;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Evaluation__c> scope) {
		set<id> evalIds = new set<id>();
		for(Evaluation__c e: scope){
			evalIds.add(e.Id);
		}
		
		//Checking for existing task notification for the Shift Assessment to avoid duplicate notification
		Map<id,Task> existingTaskMap = new Map<id,Task>();
		for(Task task: [SELECT Id, WhatId FROM Task WHERE WhatId IN:evalIds]){
			existingTaskMap.put(task.WhatId,task);
		}
		
		List<Task> taskstoCreate = new List<Task>();
		for(Evaluation__c eval: scope){
			if(!existingTaskMap.containsKey(eval.Id)){
				Task t = new Task();
				t.OwnerId = eval.ownerId;
				t.WhatId = eval.id;
				t.subject = ' Nurses Shift Documentation Status Reminder';
				t.Status = 'In Progress';
				t.Priority = 'Normal';
				t.Description = ' Nurses Shift Documentation '+eval.Name+' is waiting to be finalized.'+ System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + eval.Id;
				t.WhoId = eval.ServiceAssignment__r.Admission__r.Person_being_served__c;
				t.ActivityDate = eval.Shift_End_Time__c.date();
				taskstoCreate.add(t);
			}
		}
		
		insert taskstoCreate;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

}