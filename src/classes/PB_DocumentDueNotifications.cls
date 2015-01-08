global class PB_DocumentDueNotifications implements Database.Batchable<sObject> {
    global final String query;
    public static final String TASK_SUBJECT = 'Admission Document Reminder';
    public static final String TASK_OVERDUE_SUBJECT = 'Admission Document overdue';

    global PB_DocumentDueNotifications(String q){
            query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PB_AssociatedDoc__c> scope){
        
        Set<Id> admIdsFromScope = new Set<Id>();
        List<Id> assocIdsFromScope = new List<Id>();
        for(PB_AssociatedDoc__c assocDoc : scope){
            admIdsFromScope.add(assocDoc.sObject_Id__c); // The documents are associated to Admission; in future when they are associated to other sObjects, this would need to account for that.
            assocIdsFromScope.add(assocDoc.Id);
        }
        
        // the admission records for the associated documents that are overdue or due in seven days and not yer received... see the batch query
        Map<Id,Admission__c> adm = new Map<Id, Admission__c>([Select Id, Name,Person_Being_Served__c, Person_Being_Served__r.Contact_Name_from_Account__c,
                                                                    Person_Being_Served__r.Account.LastName, Person_Being_Served__r.Account.FirstName,
                                                                    Person_Being_Served__r.OwnerId
                                                               From Admission__c
                                                              Where Id =: admIdsFromScope] // the admission Ids of the associated docs
                                                              );
                                                              
 
        // the existing tasks that are not closed. look into these before creating a new one.                                                             
        Map<Id,Task> existingTasksMap = new Map<Id, Task>();
		for(Task task : [Select id, subject, WhatId, Description 
                           from Task
                          where WhatId =: assocIdsFromScope   // the associated doc Ids 
                            And status!= 'Completed'] ){
			existingTasksMap.put(task.WhatId, task);
		}

        List<Task> newtasks = new List<Task>();
        List<Task> updatetasks = new List<Task>();
        for(PB_AssociatedDoc__c assocDoc : scope){
        	Admission__c admisson = adm.get(assocDoc.sObject_Id__c);
        	
            // create a new if a task not already exists, 
            if(! existingTasksMap.containsKey(assocDoc.Id)){
	            newtasks.add(new Task( Subject = TASK_SUBJECT, 
	                                Status = 'In Progress', 
	                                Priority = 'Normal', 
	                                OwnerId = admisson.Person_Being_Served__r.OwnerId, //owner of the person being served
	                                Description = 'Document: '+ assocDoc.Document__r.Document_Name__c + ' for Admission: ' + admisson.Name + ' is due. ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + assocDoc.sObject_Id__c,
	                                WhoId = admisson.Person_Being_Served__c, // person being served/contact id
	                                WhatId = assocDoc.Id,                   // the associated document id
	                                ActivityDate = assocDoc.Due_Date__c) );
            }
            //if a task already exists and its already past due, change the subjet and description to overDue
            else if(existingTasksMap.containsKey(assocDoc.Id) && assocDoc.Due_Date__c == Date.today() ){
            	Task t = existingTasksMap.get(assocDoc.Id);
            	t.subject = TASK_OVERDUE_SUBJECT;
            	t.Description = 'Document: '+ assocDoc.Document__r.Document_Name__c + ' for Admission: ' + admisson.Name + ' is overdue. ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + assocDoc.sObject_Id__c;
            	updatetasks.add(t);
            }
        }
        insert newtasks;
        update updatetasks;
    }
   
    global void finish(Database.BatchableContext BC){
       
    }
    
}