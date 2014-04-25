global class SAUpdateBatch implements Database.Batchable<sObject> {

   global final String Query;
    //List<Service_Assignment__c> sa = [select ID, service_location__c, location_region__c, program__c, program_detail__c, service_line__c from service_assignment__c where admission__r.state__c = 'AZ' and status__c = 'Active'];

   global SAUpdateBatch (String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Service_Location__c sl = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where programid__c = '122874001'];
        integer dashpos = sl.Service_Value__c.indexOf('-');
      
        string progid = '';
      
      // START: Loop through all SAs passed into batch job.
      for(Sobject s : scope){
        
        progid = '';
        
        // Polymorph sObject to Assessment__c
        Service_Assignment__c sa = (Service_Assignment__c)s;
        
        if ( sa.Program__c == 'Miami'  ) {
            sa.Program__c = 'MENTOR';
            sa.Model__c = 'MENTOR';
            if (sa.Location_Region__c == 'S. Miami' && (sa.Service_Line__c == 'Intensive In-Home' || sa.Service_Line__c == 'Intensive In Home')) 
                progid = '010895001';
            if (sa.Location_Region__c == 'S. Miami' && sa.Service_Line__c == 'Outpatient Therapy')  
                progid = '010896001';
                
            if ( sa.Location_Region__c == 'N. Miami' )
                progid = '010898001';
        }
    
        if (sa.Program__C == 'Broward') {
            sa.Program__c = 'MENTOR';
            sa.Model__c = 'MENTOR';
            if (sa.Location_Region__c == 'S. Broward'  )
                progid = '010896001';
            if ( sa.Location_Region__c == 'N. Broward' )
                progid = '010897001';
        }
        
        if (progid != '' ) {
	        sl = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where programid__c = :progid];
	        if ( sl != null ) {
	            
	            dashpos = sl.Service_Value__c.indexOf('-');
	        
	            sa.service_location__c = sl.id;
	            sa.Program_Detail__c = sl.program__c;
	            if (sa.Model__c == null )
	                sa.Program__c = sl.Alias__c;
	                
	            sa.Location_Region__c = ''; //sl.City__c;
	            sa.Service_Line__c = (sl.Service_Value__c).substring(dashpos+1);
	            update s;
	        
	        }
        }
        
        
      } // for
   }
    
 
   
   

   global void finish(Database.BatchableContext BC){
  
            Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
                
                // Get user Id of this script's author.  Assumes we'll only have one person with this full name.
                // If changed to a more common name, recode for that.               
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Bridget Samuel'];     
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('Notifcations');
         
                // Specify the subject line the your email.      
                mail.setSubject('Batch is done');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The SAUpdateBatch job ran.'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                );
                
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The SAUpdateBatch job ran.'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 
    }
    
    
}