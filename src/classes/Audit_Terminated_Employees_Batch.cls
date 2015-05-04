global class Audit_Terminated_Employees_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	global final list<TMN_User__c> query ;
	global string devMsg;
	global datetime dayMonday = system.now().addDays(-7).addHours(-8);
	//global datetime dayFriday = system.now().addDays(-3).addHours(-8);
	global datetime dayNextMonday = system.now().addHours(-8);

	global Audit_Terminated_Employees_Batch(List<TMN_User__c> q, string msg) {
		system.debug('starting construct');
		query=q; devMsg = msg;
	}
	global list<SObject> start(Database.BatchableContext bc) {
		system.debug('starting start');
		return query;
	}
   	global void execute(Database.BatchableContext BC, List<TMN_User__c> scope) {
   		system.debug('starting ex');
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<audit_emails__c> emails = audit_emails__c.getAll().values();
			List<string> emailAddresses = new List<string>();
			for(Audit_Emails__c email: emails){
				emailAddresses.add(email.Name);
			}
			mail.setToAddresses(emailAddresses);
			mail.setReplyTo(emailAddresses[0]);
			mail.setSenderDisplayName('FAILURE');
			mail.setSubject('Audit Termination Failture');
			mail.setBccSender(false);
			//mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
			mail.setUseSignature(false);
			mail.setHtmlBody('Audit termination batch for week '+ dayMonday + 'to' + dayNextMonday);
			mail.setSaveAsActivity(false);
			List<Messaging.SingleEmailMessage> errorEmail = new List<Messaging.SingleEmailMessage>();
			errorEmail.add(mail);
			Messaging.sendEmail(errorEmail);
	}
	global void finish(Database.BatchableContext BC) {
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<audit_emails__c> emails = audit_emails__c.getAll().values();
			List<string> emailAddresses = new List<string>();
			for(Audit_Emails__c email: emails){
				emailAddresses.add(email.Name);
			}
			mail.setToAddresses(emailAddresses);
			mail.setReplyTo(emailAddresses[0]);
			mail.setSenderDisplayName('Complete');
			mail.setSubject('Complete: Audit Termination Report');
			mail.setBccSender(false);
			///mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
			mail.setUseSignature(false);
			mail.setHtmlBody('These are the names of employees terminated from days ' + dayMonday + ' to ' + dayNextMonday 
				+ ': ' + devMsg);
			mail.setSaveAsActivity(false);
			List<Messaging.SingleEmailMessage> devEmail = new List<Messaging.SingleEmailMessage>();
			devEmail.add(mail);
			Messaging.sendEmail(devEmail);		
	}
	public static string getNamefromList(list<TMN_User__c> a){
		string str = '<br/>';
		for(TMN_User__c item : a){
			str += item.name + '<br/>';
		}
		str += '<br/><br/>';
		return str;
	}
	public static list<TMN_User__c> getsInactive (list<TMN_User__c> AllUsers){
		list<TMN_User__c> returnedItems = new list<TMN_User__c>();
		for(TMN_User__c item : AllUsers){
			if( item.job_status__c != 'Inactive'){
				returnedItems.add( item );
			}
		}
		return returnedItems;
	}
}