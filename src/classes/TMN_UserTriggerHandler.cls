public with sharing class TMN_UserTriggerHandler {
    private boolean m_isExecuting = false;
    public TMN_UserTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    //Before Insert
    public void onBeforeInsert(List<TMN_user__c> newObjects){
    	setManagerLookup(newObjects, null);
    }
    
    //Before update
    public void onBeforeUpdate(List<TMN_user__c> updatedObjects, map<Id, TMN_User__c> newObjMap,List<TMN_user__c> oldObjects, map<Id, TMN_User__c> oldObjMap){
    	setManagerLookup(updatedObjects, oldObjMap);
    }
    
    public void OnAfterInsertUpdate(map<Id, TMN_User__c> oldObjMap, list<TMN_User__c> newObj, map<Id, TMN_User__c> newObjMap){
    	map<String,id> emailMap = new map<String,id>();
    	map<String,id> nameMap = new map<String,id>();
    	list<TMN_User__c> tmnForTask = new list<TMN_User__c>();
    	list<Task> taskToInsert = new list<Task>();
    	
    	for (TMN_User__c usr: newObj) {
    		// prepare the list of emails/userNames to select the lists of salesforce users (recruiters) that would get the a task for pre-hire
    		//Sravan - Added "oldObjMap!= null" or else the trigger will error out in case a new record is inserted. Trigger.old variable is not available for insert operations. 
    		if (usr.Current_Person_Type__c == 'Pre-hire' && (oldObjMap!= null && oldObjMap.containsKey(usr.id) ? oldObjMap.get(usr.id).Current_Person_Type__C != 'Pre-hire' : true ) && 
    		     (String.isNotBlank(usr.Recruiter_Email_Address__c) || String.isNotBlank(usr.Recruiter_Name__c) )
    		   ) 
    		   
    		   {
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
        	if ( (emailMap.containsKey(tmn.Recruiter_Email_Address__c) ? String.isNotBlank(emailMap.get(tmn.Recruiter_Email_Address__c)) : false) || 
        	     (nameMap.containsKey(tmn.Recruiter_Name__c) ? String.isNotBlank(nameMap.get(tmn.Recruiter_Name__c)) : false) )         	     
	        	taskToInsert.add(new Task(Subject = 'Pre-Hire Provisioning', Status = 'New', Priority = 'Normal', 
	        	                           OwnerId = emailMap.containsKey(tmn.Recruiter_Email_Address__c) ? emailMap.get(tmn.Recruiter_Email_Address__c) : nameMap.get(tmn.Recruiter_Name__c),
	        	                           Description = 'Pre-Hire Provisioning. Name of the new hire: ' + tmn.First_Name__c + ' ' + tmn.Last_Name__c
	        	                           + '. Hire Date: ' + (tmn.Hire_Date__c != null ? tmn.Hire_Date__c.format() : 'Not Filled')  
	        	                           + '. Job Title: ' + tmn.Job_Title__c 
	        	                           + '. Manager Name: ' + tmn.Manager_Name__c + '.', 
	        	                           WhatId = tmn.Id, ActivityDate = Date.Today().AddDays(1)));
        }
                
        insert taskToInsert;
    }
    
    //Set the Manager lookup field based on the email address provided - Sravan - 10/13/2015
    public void setManagerLookup(List<TMN_User__c> tmnUsers, Map<id,TMN_user__c> oldVersion){
    	set<string> managerEmails = new set<string>();
    	map<string, id> emailMap = new map<string,id>();
    	
    	if(null == oldVersion){
	    	for(TMN_user__c t: tmnUsers){
	    		if(string.isNotBlank(t.Manager_Email__c) && string.isBLANK(t.Manager_Lookup__c)){
	    			managerEmails.add(t.Manager_Email__c);
	    		}
	    	}
    	}else if(oldVersion.size() > 0){
    		for(TMN_user__c t: tmnUsers){
	    		if( (string.isNotBlank(t.Manager_Email__c) && string.isBLANK(t.Manager_Lookup__c)) || (null != oldVersion.get(t.Id).Manager_Email__c && null != t.Manager_Email__c && oldVersion.get(t.Id).Manager_Email__c != t.Manager_Email__c) ){
	    			managerEmails.add(t.Manager_Email__c);
	    		}
	    		else if(null != oldVersion.get(t.Id).Manager_Email__c && string.isBLANK(t.Manager_Email__c)){
	    			t.Manager_lookup__c = null;
	    		}
	    	}
    		
    	}
    	
    	for(TMN_user__c m: [SELECT Id, Email__c FROM TMN_user__c WHERE Email__c IN: managerEmails]){
    		emailMap.put(m.Email__c, m.Id);
    	}
    	
    	if(emailMap.keySet().size() > 0){
    		for(TMN_user__c t: tmnUsers){
	    		if(emailMap.containsKey(t.Manager_Email__c)){
	    			t.Manager_lookup__c = emailMap.get(t.Manager_Email__c);
	    		}
    		
    		}
    	}
    		
    }
    
}