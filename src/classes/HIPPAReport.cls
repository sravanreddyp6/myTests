global class HIPPAReport implements Database.Batchable<sObject> {

	 global List<String> managerIds  ;
	global List<TMN_User__c> tmnUsers;
	global list<Task> taskToInsert;
	global String query = '';
	global HIPPAReport() {
		   managerIds = new List<String>();
		tmnUsers = new List<TMN_User__c>();
		taskToInsert = new list<Task>();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		query =	'SELECT Name,Email__c,Manager_Name__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Salesforce_User_Account__c  FROM TMN_User__c limit 1';
		return  Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('EventLogging').getRecordTypeId();

	   Integer month = Date.today().month();
       Integer year = Date.today().year();
       String quarter ='';
       if (month==1){
            quarter ='Oct-'+(year-1)+' to Dec-'+(year-1);
       }else if (month==4){
           quarter = 'Jan-'+year+' to Mar-'+year;
       }else if (month==7){
            quarter ='Apr-'+year+' to Jun-'+year;
       }else if (month==10){
           quarter ='Jul-'+year+' to Sep-'+year;
       }
		
	  	list<AggregateResult> userAggregateResult = [select Manager_Email__c from TMN_User__c where  manager_email__c <> '' and Alias__c in ('001130','001140','114190','114100','114050') and (not manager_email__c  like '%bruce.nardella%') group by manager_email__c];
       for(AggregateResult ag:userAggregateResult) {
           			managerIds.add(string.valueof(ag.get('Manager_Email__c')).toLowerCase());
       }
 		EmailTemplate managerTemplate = [Select id,name from EmailTemplate where Name =: 'HIPPA Report'];
		query  = 'SELECT Name,Email__c,Manager_Name__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Salesforce_User_Account__c  FROM TMN_User__c where';
 			     query  +=' Salesforce_User_Account__r.isActive= true  and  email__c in : managerIds';	
		List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
		tmnUsers = Database.query(query);
		for(TMN_User__c tmn:tmnUsers) {
			Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(tmn.Salesforce_User_Account__c);
			//mail.setWhatId(tmn.Salesforce_User_Account__c);
			mail.setTemplateId(managerTemplate.id);
			mail.SaveAsActivity = false;
			mails.add(mail);
			taskToInsert.add(
				new Task(Subject = 'Quarterly Event Log Report for  ' + quarter, Status = 'Not Approved', Priority = 'High',
					OwnerId = tmn.Salesforce_User_Account__c,
					RecordTypeId = recordTypeId,WhatId = tmn.Id,
					ActivityDate = Date.Today()
				)
			);
		}

		insert taskToInsert;
		Messaging.sendEmail(mails);
		System.debug('Total Number of Emails and Tasks ' + mails.size());
	}

	global void finish(Database.BatchableContext BC) {

	}



}