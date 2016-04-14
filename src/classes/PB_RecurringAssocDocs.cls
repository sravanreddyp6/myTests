global class PB_RecurringAssocDocs implements Database.Batchable<sObject> {
	
	/*
	 * Will Upload
	 */
    global final String query;

    global PB_RecurringAssocDocs(String q){
            query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PB_AssociatedDoc__c> scope){

        try {
	        List<PB_AssocDocRecurrence__c> recurrs = new List<PB_AssocDocRecurrence__c>();
	        for(PB_AssociatedDoc__c assocDoc : scope){
	        	
	        	recurrs.add(new PB_AssocDocRecurrence__c(PB_AssociatedDoc__c = assocDoc.id,
	                                                     Status__c = assocDoc.Status__c,
	                                                     Status_Date__c = assocDoc.Status_Date__c));
	                                                     
	            if(assocDoc.Document__r.Recurring_Frequency__c == 'As Needed'){
	            	assocDoc.Due_Date__c = null;
	            }else{
	            	assocDoc.Due_Date__c = getDueDate(assocDoc.Status_Date__c, assocDoc.Document__r.Recurring_Interval__c);
	            }
	            
	            assocDoc.Status__c = 'Pending';
	            assocDoc.Status_Date__c = Null;            
	        }
	
	        insert recurrs;
	        update scope;
        } catch (Exception e) {
            sendErrorEmail(e);
        }
    }
   
    private Date getDueDate(Date dueDate, String recurr){
        Date recurrDueDate;
        if (recurr == 'Annually')  recurrDueDate = dueDate.addYears(1); 
        else if (recurr == 'Monthly') recurrDueDate = dueDate.addMonths(1);
        else if (recurr == 'Quarterly') recurrDueDate = dueDate.addMonths(3);
        return recurrDueDate;
    }
    
    global void finish(Database.BatchableContext BC){
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Kate Salines-Johnston'];
                Id userID = userIds[0].Id;
                mail.setTargetObjectId(userID);
                mail.setReplyTo('notifications@thementornetwork.com');
                mail.setSenderDisplayName('ESD Batch Jobs');
                mail.setSubject('Recurring Admission Documents Batch Confirmation');
                mail.setBccSender(false);
                mail.setUseSignature(false);

                mail.setPlainTextBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job ran.  '
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job ran.  '
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Application'
                );
                
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @TestVisible   
    private void sendErrorEmail(Exception e){
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Kate Salines-Johnston'];
                Id userID = userIds[0].Id;
                mail.setTargetObjectId(userID);
                mail.setReplyTo('notifications@thementornetwork.com');
                mail.setSenderDisplayName('ESD Batch Jobs');
                mail.setSubject('Starting Recurring Admission Documents Batch');
                mail.setBccSender(false);
                mail.setUseSignature(false);

                mail.setPlainTextBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch FAILED!!!! '
                + '/r/n/r/n'
                + e.getStackTraceString()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch FAILED!!!! '
                + '<br /><br />'
                + e.getStackTraceString()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Application'
                );
                
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}