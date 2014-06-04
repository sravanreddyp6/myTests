global class Assessment_FAD_Notifications implements Database.Batchable<sObject> {
  global final String Query;
  public Service_Assignment__c[] SAs = new Service_Assignment__c[]{};

   global Assessment_FAD_Notifications(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
  // Service_Assignment__c[]List<Service_Assignment__c> All
        SAs = (Service_Assignment__c[])scope;
        date d1 = system.today().addDays(-7);
        List<Assessment__c> assess;
        set<id> saids = new set<id>();
        
        for(Service_Assignment__c theSA: SAs){
            saids.add(theSA.id);
        }
        /*
        SAs = [select Id, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName, 
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name 
                        from Service_Assignment__c 
                        Where Program__c = 'IFCS' 
                         AND
                        Phase_1_Start_Date__c = :d1 ];
                        
                        */                       
        SAs = [select Id, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName, 
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name 
                        from Service_Assignment__c 
                        Where ID in :saids
                         AND
                        Phase_1_Start_Date__c = :d1 ];                        
        assess = [select id, Service_Assignment__c, Phase__c From Assessment__c Where Service_Assignment__c IN :SAs AND Disregard__c = false];
        //Initial Check
        for(Service_Assignment__c theSA: SAs){
            boolean addMail = true;
            for(Assessment__c a: assess){
                IF(a.Service_Assignment__c == theSA.id && a.Phase__c == 'Initial'){
                    addMail = false;
                }
            
            }
            
            if(addMail){
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
                mail.setSubject('An Initial FAD Assessment is due');
                mail.setHtmlBody('Hello ' +
                theSA.Person_Being_Served__r.Owner.Name + ','+ 
                '<br/>A FAD Assessment Summary is due for ' + 
                theSA.Person_Being_Served__r.FirstName + ' ' + theSA.Person_Being_Served__r.LastName.substring(0,1) + '.<br/>' +
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
        }  
        
        
        
        
        //3 month
        d1 = system.today().addDays(-80);
        SAs = [select Id, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, 
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name , Person_Being_Served__r.LastName
                        from Service_Assignment__c 
                        Where ID in :saids 
                         AND 
                        Phase_1_Start_Date__c = :d1 ];
        assess = [select id, Service_Assignment__c, Phase__c From Assessment__c Where Service_Assignment__c IN :SAs AND Disregard__c = false];
        //Initial Check
        for(Service_Assignment__c theSA: SAs){
            boolean addMail = true;
            for(Assessment__c a: assess){
                IF(a.Service_Assignment__c == theSA.id && a.Phase__c == '30 Day'){
                    addMail = false;
                }
            
            }
            
            if(addMail){
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
                mail.setSubject('A 3 Month FAD Assessment is due');
                mail.setHtmlBody('Hello ' +
                theSA.Person_Being_Served__r.Owner.Name + ','+ 
                '<br/>A FAD Assessment Summary is due for ' + 
                theSA.Person_Being_Served__r.FirstName + ' ' + theSA.Person_Being_Served__r.LastName.substring(0,1) + '. <br/>' +
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
        }  
        
        
        d1 = system.today().addDays(-160);
        SAs = [select Id, Phase_1_Start_Date__c, Person_Being_Served__r.FirstName, 
                    Person_Being_Served__r.OwnerId, Person_Being_Served__r.Owner.Name , Person_Being_Served__r.LastName
                        from Service_Assignment__c 
                        Where ID in :saids 
                         AND 
                        Phase_1_Start_Date__c = :d1 ];
        assess = [select id, Service_Assignment__c, Phase__c From Assessment__c Where Service_Assignment__c IN :SAs AND Disregard__c = false];
        //Initial Check
        for(Service_Assignment__c theSA: SAs){
            boolean addMail = true;
            for(Assessment__c a: assess){
                IF(a.Service_Assignment__c == theSA.id && a.Phase__c == 'Final'){
                    addMail = false;
                }
            
            }
            
            if(addMail){
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
                theSA.Person_Being_Served__r.FirstName + ' ' + theSA.Person_Being_Served__r.LastName.substring(0,1) + '. <br/>' +
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
        }                        
        
  }
  
   global void finish(Database.BatchableContext BC){
                Messaging.reserveSingleEmailCapacity(1);
         
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a single email. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list. 
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
                
                // Get user Id of this script's author.  Assumes we'll only have one person with this full name.
                // If changed to a more common name, recode for that.               
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Paul Perisic'];     
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('Assessment Batch Confirmation');
         
                // Specify the subject line the your email.      
                mail.setSubject('Assessment Batch Confirmation');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The AssessmentsNotifications.cls batch job ran.'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Assessment Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The Assessments FAD Notifications batch job ran. with ' + SAs.size() +
                
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Assessment Application'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }  
}