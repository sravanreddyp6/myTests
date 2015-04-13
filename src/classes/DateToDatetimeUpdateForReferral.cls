global class DateToDatetimeUpdateForReferral implements Database.Batchable<sObject> {
    global final String query;
    global final String targetSobj;

    global DateToDatetimeUpdateForReferral(String q, String target){
            query=q;
            targetSobj = target;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        if (targetSobj == 'Referral__c') {
	        try {
	            for(sObject s : scope){
	            	Referral__c ref = (Referral__c) s;
	            	if (ref.Anticipated_Admission_Date__c != null)
	            	   ref.Anticipated_Admission_DateTime__c = DateTime.newInstance(ref.Anticipated_Admission_Date__c, Time.newInstance(0, 0, 0, 0));
	            }
	            update scope;
	        } catch (Exception e) {
	            sendErrorEmail(e);
	        }
        } else if(targetSobj == 'Admission__c'){
            try {
                for(sObject s : scope){
                    Admission__c adm = (Admission__c) s;
                    if (adm.Effective_Date__c != null)
                       adm.Admission_Effective_DateTime__c = DateTime.newInstance(adm.Effective_Date__c, Time.newInstance(0, 0, 0, 0));
                }
                update scope;
            } catch (Exception e) {
                sendErrorEmail(e);
            }
        } else if(targetSobj == 'Service_Assignment__c'){
            try {
                for(sObject s : scope){
                    Service_Assignment__c sa = (Service_Assignment__c) s;
                    if (sa.Start_Date__c != null)
                       sa.SA_Start_DateTime__c = DateTime.newInstance(sa.Start_Date__c, Time.newInstance(0, 0, 0, 0));
                }
                update scope;
            } catch (Exception e) {
                sendErrorEmail(e);
            }            
        }
       
    }
       
    global void finish(Database.BatchableContext BC){
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Neeraj Gupta'];
                Id userID = userIds[0].Id;
                mail.setTargetObjectId(userID);
                mail.setReplyTo('notifications@thementornetwork.com');
                mail.setSenderDisplayName('EC-120 Date to DateTime Conversion.');
                mail.setSubject('EC-120 Date to DateTime Conversion Batch Confirmation.');
                mail.setBccSender(false);
                mail.setUseSignature(false);

                mail.setPlainTextBody(
                'Hello!  The EC-120 Date to DateTime Conversion (DateToDatetimeUpdate.cls) batch job ran for  ' + targetSobj 
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The EC-120 Date to DateTime Conversion (DateToDatetimeUpdateForReferral.cls) batch job ran for  ' + targetSobj 
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
    private void sendErrorEmail(Exception e){
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Neeraj Gupta'];
                Id userID = userIds[0].Id;
                mail.setTargetObjectId(userID);
                mail.setReplyTo('notifications@thementornetwork.com');
                mail.setSenderDisplayName('EC-120 Date to DateTime Conversion');
                mail.setSubject('Error processing the date to datetime conversion for ' + targetSobj );
                mail.setBccSender(false);
                mail.setUseSignature(false);

                mail.setPlainTextBody(
                'Hello!  Error processing the date to datetime conversion for ' + targetSobj + ' (DateToDatetimeUpdateForReferral.cls) batch FAILED!!!! '
                + '/r/n/r/n'
                + e.getStackTraceString()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  Error processing the date to datetime conversion for referrals. (DateToDatetimeUpdateForReferral.cls) batch FAILED!!!! '
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