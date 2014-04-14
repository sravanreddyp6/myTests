trigger ServiceAssignment_FAD_Notes on Service_Assignment__c (before update) {
 boolean HasRecordInScope = false;
 List<Service_Assignment__c> ScopedSAs = new List<Service_Assignment__c>();
 for (Service_Assignment__c SA : Trigger.new) {
     IF(SA.Program__c != null && SA.Service_Line__c != null){
         if(SA.Program__c == 'IFCS' && SA.Service_Line__c.Contains('FCT') ){
           // 
            HasRecordInScope = true;
            ScopedSAs.add(SA);
            
         }
     }
 }
 IF(HasRecordInScope ){
     ScopedSAs = [select Id, Status__c, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName,
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name 
                        from Service_Assignment__c Where ID IN :ScopedSAs];
    Map<id, Assessment__c> mapAssess = new Map<id, Assessment__c>();
     for(Assessment__c assess:[ Select id, Service_Assignment__c  from Assessment__c Where Service_Assignment__c IN :ScopedSAs AND Phase__c = 'Final' AND Disregard__c = False]){
     mapAssess.put(assess.Service_Assignment__c, assess);
     
     }
     for (Service_Assignment__c theSA : ScopedSAs) {
         
        // Access the "old" record by its ID in Trigger.oldMap
        Service_Assignment__c oldSA = Trigger.oldMap.get(thesa.Id);
    
        // Trigger.new records are conveniently the "new" versions!
        String oldStatus = Trigger.oldMap.get(thesa.Id).Status__c;
        String newStatus = Trigger.newMap.get(thesa.Id).Status__c;
         system.debug('old '+oldStatus ); 

         system.debug('new '+newStatus );

        // Check that the field was changed to the correct value
        if (oldStatus != newStatus && newStatus =='Inactive' && !mapAssess.containsKey(theSA.id)) {
                    Messaging.reserveSingleEmailCapacity(1);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
                    // which we are sending a notification.  
                    //
                    mail.setTargetObjectId(theSA.Person_Being_Served__r.OwnerId);
                    
                    // Specify the address used when the recipients reply to the email.                 
                    mail.setReplyTo('notifications@thementornetwork.com');
                    
                    
                    // Specify the name used as the display name.      
                    mail.setSenderDisplayName('MENTOR Assessment Notification');
                           
                    // Set to True if you want to BCC yourself on the email.    
                    mail.setBccSender(false);
                            
                    // Optionally append the salesforce.com email signature to the email. 
                    // The email address of the user executing the Apex Code will be used.             
                    mail.setUseSignature(false);      
                    mail.setSubject('A Final FAD Assessment is due');
                    mail.setHtmlBody('Hello ' +
                    theSA.Person_Being_Served__r.Owner.Name + ','+ 
                    '<br/>A FAD Assessment Summary is due for ' + 
                    theSA.Person_Being_Served__r.FirstName + ' ' + theSA.Person_Being_Served__r.FirstName +
                    '. Please click on the link below to access the Person Being Serveds record. <br/>' +
                     '<a href="'+ 
                     System.Url.getSalesforceBaseUrl().toExternalForm()+ 
                     '/' +
                     theSA.id + '">Click Here</a>'
                     
                     );
                    
                    
                    mail.setSaveAsActivity(false);
                    
                    // Send the email you have created.
                    // PLEASE NOTE:  It is IMPORTANT that we use this method of making one call to regularNoticeEmails.add()
                    // because there is a limit on the number of email calls that can be made per execution of the batch.
                    // I believe that limit is 10 calls.  Calling the method ONCE for a list of single emails only counts
                    // as one call, but gets multiple messages sent.
                    List<Messaging.SingleEmailMessage> regularNoticeEmails = new List<Messaging.SingleEmailMessage>();
                    regularNoticeEmails.add(mail); 
                    
                    Messaging.sendEmail(regularNoticeEmails); 
        }
      }
  }
}