public with sharing class TMN_UserTriggerHandler {
    private boolean m_isExecuting = false;
    public TMN_UserTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    
    public void OnAfterInsertUpdate(map<Id, TMN_User__c> oldObjMap, list<TMN_User__c> newObj, map<Id, TMN_User__c> newObjMap){
    	map<String,id> emailMap = new map<String,id>();
    	map<String,id> nameMap = new map<String,id>();
    	list<TMN_User__c> tmnForTask = new list<TMN_User__c>();
    	list<Task> taskToInsert = new list<Task>();
    	
    	for (TMN_User__c usr: newObj) {
    		// prepare the list of emails/userNames to select the lists of salesforce users (recruiters) that would get the a task for pre-hire
    		if (usr.Current_Person_Type__C == 'Pre-hire' && oldObjMap.get(usr.id).Current_Person_Type__C != 'Pre-hire' && 
    		     (String.isNotBlank(usr.Recruiter_Email_Address__c) || String.isNotBlank(usr.Recruiter_Name__c) )
    		   ) {
    			if (String.isNotBlank(usr.Recruiter_Email_Address__c)) emailMap.put(usr.Recruiter_Email_Address__c, null);
    			else nameMap.put(usr.Recruiter_Name__c, null);
    			
    			tmnForTask.add(usr);
    		}
    	}
    	
        for (User u : [Select id, name, email from User where name IN :nameMap.keySet() OR email IN :emailMap.keySet()]){
        	if (emailMap.containsKey(u.email)) emailMap.put(u.email, u.id);
        	else nameMap.put(u.name, u.id);
        }
        
        for (TMN_User__c tmn : tmnForTask){
        	taskToInsert.add(new Task(Subject = 'Pre-Hire Provisioning', Status = 'New', Priority = 'Normal', 
        	                           OwnerId = emailMap.containsKey(tmn.Recruiter_Email_Address__c) ? emailMap.get(tmn.Recruiter_Email_Address__c) : emailMap.get(tmn.Recruiter_Email_Address__c),
        	                           Description = 'Pre-Hire Provisioning. Name of the new hire: ' + tmn.Last_Name__c + ' ' + tmn.Last_Name__c
        	                           + '. Hire Date: ' + tmn.Hire_Date__c.format() + '. Job Title: ' + tmn.Job_Title__c + '. Manager Name: ' + tmn.Manager_Name__c + '.', 
        	                           WhatId = tmn.Id, ActivityDate = Date.Today().AddDays(1)));        	
        }        
        insert taskToInsert;
    }
    
}