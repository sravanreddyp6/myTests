/*

Database.executeBatch(new EC120_DateToDatetimeUpdate('SELECT Id, Anticipated_Admission_Date__c, Anticipated_Admission_DateTime__c from Referral__c where Anticipated_Admission_Date__c != null and Anticipated_Admission_DateTime__c = null', 'Referral__c'),500);
Database.executeBatch(new EC120_DateToDatetimeUpdate('SELECT Id, Effective_Date__c, Admission_Effective_DateTime__c from Admission__c where Effective_Date__c != null and Admission_Effective_DateTime__c = null', 'Admission__c'),500);
Database.executeBatch(new EC120_DateToDatetimeUpdate('SELECT Id, Start_Date__c, SA_Start_DateTime__c from Service_Assignment__c where Start_Date__c != null and SA_Start_DateTime__c = null', 'Service_Assignment__c'),500);
*/

global class EC120_DateToDatetimeUpdate implements Database.Batchable<sObject> {
    private final String query;
    private final String targetSobj;

    global EC120_DateToDatetimeUpdate(String q, String target){
            query=q;
            targetSobj = target;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
	        if (targetSobj == 'Referral__c') {
                for(sObject s : scope){
                    Referral__c ref = (Referral__c) s;
		            ref.Anticipated_Admission_DateTime__c = DateTime.newInstance(ref.Anticipated_Admission_Date__c, Time.newInstance(0, 0, 0, 0));
	           }
	        } else if(targetSobj == 'Admission__c'){
                for(sObject s : scope){
	               Admission__c adm = (Admission__c) s;
	               adm.Admission_Effective_DateTime__c = DateTime.newInstance(adm.Effective_Date__c, Time.newInstance(0, 0, 0, 0));
                }
	        } else if(targetSobj == 'Service_Assignment__c'){
                for(sObject s : scope){
	               Service_Assignment__c sa = (Service_Assignment__c) s;
	               sa.SA_Start_DateTime__c = DateTime.newInstance(sa.Start_Date__c, Time.newInstance(0, 0, 0, 0));
                }
	        }
            update scope;
	    } catch (Exception e) {
	        sendErrorEmail(e);
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