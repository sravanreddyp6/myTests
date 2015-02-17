trigger SA_Doc_JO_FadNote on ServiceAssignment_Document_JO__c (before insert, before update) {
 boolean HasRecordInScope = false;
 List<ServiceAssignment_Document_JO__c> ScopedRecs = new List<ServiceAssignment_Document_JO__c>();
 set<id> SAid = new set<id>();
 list<Service_Assignment__c> ScopedSAs = new list<Service_Assignment__c>();
 set<string> okFiledStatus = new set<string>();
 okFiledStatus.add('Filed');
 // step 1 see whats in scope form batch
 for (ServiceAssignment_Document_JO__c item : Trigger.new) {
     IF(item.File_Status__c!= null){
         if(item.Document_Name__c == 'Our Plan for Difficult Times'){
             if(okFiledStatus.contains(item.File_Status__c) ){
                 if(Trigger.oldMap.get(item.id).File_Status__c!= item.File_Status__c){
                    system.debug('yep');
                    HasRecordInScope = true;
                    ScopedRecs.add(item); 
                    SAid.add(item.service_Assignment__c);           
                }
             }
         }
     }
 }
    if(hasRecordInScope){
        Map<id, Assessment__c> mapAssess = new Map<id, Assessment__c>();
        for(Assessment__c assess:[ Select id, Service_Assignment__c  from Assessment__c Where Service_Assignment__c IN :SAid AND Phase__c = 'Final' AND Disregard__c = False]){
             mapAssess.put(assess.Service_Assignment__c, assess);
         }
        ScopedSAs = [select Id, Status__c, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName,
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name 
                        from Service_Assignment__c Where ID IN :SAid ];
                                 
         for (Service_Assignment__c theSA : ScopedSAs) {
          
               if (!mapAssess.containsKey(theSA.id)) {
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
                mail.setSubject('A Final FAD Assessment may be due');
                mail.setHtmlBody('Hello ' +
                theSA.Person_Being_Served__r.Owner.Name + ','+ 
                '<br/>A Final FAD Assessment Summary may be due for  ' + 
                theSA.Person_Being_Served__r.FirstName + ' ' + theSA.Person_Being_Served__r.LastName.substring(0,1) + ' if discharge is planned soon. <br/>' +
                'Please click on the link below to access the Person Being Served\'s record. <br/>' +
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
         }//end loop
     }//end has rec in scope
 
}