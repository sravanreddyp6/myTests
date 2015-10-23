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

	   String Template = '<H4>Please log into Salesforce and on your home page you will see a task with the subject "Quarterly Employee Access Logs from '+quarter+'". </h4>';
				Template += '<OL> <LI> 	Click on the task called "Quarterly Employee Logs".';
				Template += '</LI> <LI>';
				Template += 'Please open the PDF you received in a separate email and review the Persons Being Served that your staff has accessed in the last quarter.';
				Template += ' </LI> <LI> If you agree the persons being served your staff viewed is appropriate:</LI>';
				Template += '<ul type="square">  <li>Upload the PDF within the task.</li>';
				Template += ' <li>Click the approve button. </li> </ul>  <LI>';
				Template += 'If you feel some of your staff may have viewed a person being served that shouldn\'t have then:</LI>';
				Template += ' <ul type="square"> <li>	Upload the PDF.</li> ';
				Template += '<li>	Put your reasoning in the "comments" field .</li> ';
				Template += '<li>	Press the Reject button.</li>';
				Template += ' </ul> </OL>';
				Template += '	Please call the help desk if you have any questions.';
		
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
			//mail.setTemplateId(managerTemplate.id);
			mail.setHtmlBody(Template);
			mail.setSubject('Quarterly Employee Access Logs from '+quarter);
			mail.SaveAsActivity = false;
			mails.add(mail);
			taskToInsert.add(
				new Task(Subject = 'Quarterly Event Log Report from  ' + quarter, Status = 'Not Approved', Priority = 'High',
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