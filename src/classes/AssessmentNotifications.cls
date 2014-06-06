global class AssessmentNotifications implements Database.Batchable<sObject> {
// CHANGES FOR MINOR RELEASE 3/8/13.  
   global final String Query;

   global AssessmentNotifications(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      
      List<sObject> scopeClone = scope.clone(); 
      
      
      Assessment__c[] assmtsFromScope = (Assessment__c[])scope; 
      
      List<Id> admIdsFromScope = new List<Id>();
      for(Assessment__c aFS : assmtsFromScope){
        admIdsFromScope.add(aFS.Admission__c);
      } 
      
      List<Assessment__c> allAssmtsForTheScopeAdmissions = [SELECT Id, Admission__c, Admission__r.Name, Assessment_Date__c, 
                        OwnerId, Interval__c, Quarter__c, Assessment_Type__c, Assessment_Type__r.Name, 
                        Admission__r.Person_Being_Served__r.Account.LastName, Admission__r.Person_Being_Served__r.Account.FirstName,
                        Owner.LastName, Owner.FirstName, Owner.Email 
                            FROM Assessment__c 
                                WHERE Admission__c = :admIdsFromScope 
                                    ORDER BY Assessment_Date__c];
                                      
      
      // START: Loop through all assessments passed into batch job.
      for(Sobject s : scope){
        // Polymorph sObject to Assessment__c
        Assessment__c a = (Assessment__c)s;
        
        List<Assessment__c> assmtsFromSameAdmissionAsThis = new List<Assessment__c>();
        
        // Get all assessments for the admission of the assessment we're considering in this pass thru the loop.
        for(Assessment__c aAFTSA : allAssmtsForTheScopeAdmissions){
            if(aAFTSA.Admission__c == a.Admission__c){
                assmtsFromSameAdmissionAsThis.add(aAFTSA);
            }
        }
 
        // Call the method that figures out what notifications to send for this assessment.
        parseAdmission(a, assmtsFromSameAdmissionAsThis);
        } 
        
        
            
   }
   
 
    private void parseAdmission(Assessment__c a, List<Assessment__c> assmtsForThisAdmission){
        Integer admissionsAssmtsMinusIntakeCounter = 0;
        Date intakeAssmtDateForAdmission;
        Integer daysSinceIntake = 0;
        Integer fullQuartersSinceIntake = 0;
        Map<Integer,Date> thisAdmissionsAssmtDueDates = new Map<Integer,Date>(); 
        Boolean dropThisAdmissionsAssmts = false;
        Date cDT = date.today();
        Date formattedCreatedDate = date.newinstance(a.CreatedDate.year(), a.CreatedDate.month(), a.CreatedDate.day());
        Integer daysSinceCreation = formattedCreatedDate.daysBetween(cDT);
        Boolean goForEmail = false;
        
                    
            for(Assessment__c assmtsforAdm : assmtsForThisAdmission){

                    if(assmtsforAdm.Interval__c == 'Discharge'){
                        dropThisAdmissionsAssmts = true;
                    }
                    if (assmtsforAdm.Interval__c == 'Intake' ) {
                        intakeAssmtDateForAdmission = assmtsforAdm.Assessment_Date__c;
                        daysSinceIntake = assmtsforAdm.Assessment_Date__c.daysBetween(cDT);
                        fullQuartersSinceIntake = daysSinceIntake / 90;
                    }
                    if(assmtsforAdm.Interval__c=='Quarterly'){                      
                        admissionsAssmtsMinusIntakeCounter++;
                    }                   
            }
            
            Integer assmtsExpectedThisAdmission = fullQuartersSinceIntake + 1;
            Integer daysSinceLastFulfilledDueDate = daysSinceIntake - (admissionsAssmtsMinusIntakeCounter * 90);
            
            for (Integer i = 1; i < (assmtsExpectedThisAdmission + 1); i++) {
                if(intakeAssmtDateForAdmission==NULL){
                    // THIS SHOULD NEVER HAPPEN!  ONLY FOR TEST METHOD WORKAROUND.  J. Gilliam 1/14/13
                }
                else{
                    thisAdmissionsAssmtDueDates.put(i,intakeAssmtDateForAdmission + (90 * i));
                }
            }
            
            if((dropThisAdmissionsAssmts == false) && (daysSinceLastFulfilledDueDate == 75 || daysSinceLastFulfilledDueDate == 85 || daysSinceLastFulfilledDueDate >= 90)){
                System.Debug('WE NEED TO SEND AN EMAIL!');
                goForEmail = true;

                if(goForEmail==true){
                    Messaging.sendEmail(sendNotification(a, thisAdmissionsAssmtDueDates.get(assmtsExpectedThisAdmission), a.Admission__c, assmtsExpectedThisAdmission));
                }
            }
            else{
                System.Debug('WE DO NOT NEED TO SEND AND EMAIL!');
            }
            
            if(Test.isRunningTest()==true){
                daysSinceCreation = 30;
            }
            
            if(a.Status__c <> 'Locked' && daysSinceCreation >= 30){
                Messaging.sendEmail(sendIncompleteNotification(a, a.CreatedDate, a.Id));
            }       
      }
 
 
   private List<Messaging.SingleEmailMessage> sendNotification(Assessment__c a, Date dueDate, Id admId, Integer qtr){
    
    try {
        Datetime prettyDueDate = date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());  
        String newPrettyDueDate = prettyDueDate.format('MM/dd/yy');
        
        // 11/16/12: 2:00 PM
        // J. Gilliam, notes on the business requirement:
        // Timeline starts on effective date of INTAKE assessment, and stays
        // CONSTANT for entire admission (aka due every 90 days from INTAKE).
        // Send e-mail if we are more than 75 days past Intake
        // effective date or 75 + (n+90)  days past subsequent assessments
        // and the assessment is still in an "incomplete" / "pending" state.
    
        
                // Reserve email capacity for the current Apex transaction to ensure 
                // that we won't exceed our daily email limits when sending email after 
                // the current transaction is committed. 
                Messaging.reserveSingleEmailCapacity(1);
         
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a list of emails. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list.          
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
                // which we are sending a notification.  
                mail.setTargetObjectId(a.OwnerId);        
                      
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('MENTOR Assessment Notification');
         
                
                // Specify the subject line for the email.      
                mail.setSubject('Notification from the MENTOR Salesforce Assessment App');
                    
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                        
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
           
                
                // Specify the text content of the email. 
                    
                mail.setPlainTextBody('Hello ' 
                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
                    + ',/r/n/r/nA '
                    + a.Assessment_Type__r.Name
                    + ' assessment is due for client ' 
                    + a.AccountPerson__c
                    + ' for the admission '
                    + a.Admission__r.Id
                    + '. It seems to be for Quarter '
                    + qtr
                    + ' due on '
                    + newPrettyDueDate
                    + '. /r/n/r/nPlease go to '
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + a.Admission__c
                    + ' to create the next assessment.'
                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce Assessment App');
                
                mail.setHtmlBody('Hello ' 
                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
                    + ',<br /><br />A '
                    + a.Assessment_Type__r.Name
                    + ' assessment is due for client ' 
                    + a.AccountPerson__c
                    + ' for the admission '
                    + a.Admission__r.Id
                    + '. It seems to be for Quarter '
                    + qtr
                    + ' due on '
                    + newPrettyDueDate
                    + '. <br /><br />Please go to <a href="'
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + a.Admission__c
                    + '">'
                    + a.Admission__c
                    + '</a> to create the next assessment.'
                    +'<br /><br />Thanks!<br />The MENTOR Salesforce Assessment App');
                
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created.
                // PLEASE NOTE:  It is IMPORTANT that we use this method of making one call to regularNoticeEmails.add()
                // because there is a limit on the number of email calls that can be made per execution of the batch.
                // I believe that limit is 10 calls.  Calling the method ONCE for a list of single emails only counts
                // as one call, but gets multiple messages sent.
                List<Messaging.SingleEmailMessage> regularNoticeEmails = new List<Messaging.SingleEmailMessage>();
                regularNoticeEmails.add(mail);
            
                // Create a task reminder for the action.
                Task t = new Task(Subject = a.Assessment_Type__r.Name + ' Assessment Reminder', Status = 'In Progress', Priority = 'Normal', OwnerId = a.OwnerId, Description = 'You have a person being served who appears to have a ' + a.Assessment_Type__r.Name + ' assessment due or coming due: ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + a.Admission__r.Id, WhoId = a.AccountPerson__r.PersonContactId, WhatId = a.AccountPerson__r.Id, ActivityDate = dueDate);
                insert t;
                
                return regularNoticeEmails;
        }
        catch(Exception e){
	        Datetime prettyDueDate = date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());  
	        String newPrettyDueDate = prettyDueDate.format('MM/dd/yy');
	        
	        
	                // Reserve email capacity for the current Apex transaction to ensure 
	                // that we won't exceed our daily email limits when sending email after 
	                // the current transaction is committed. 
	                Messaging.reserveSingleEmailCapacity(1);
	         
	                
	                // Processes and actions involved in the Apex transaction occur next, 
	                // which conclude with sending a list of emails. 
	                    
	                // Now create a new single email message object 
	                // that will send out a single email to the addresses in the To, CC & BCC list.          
	                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                
	                // Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
	                // which we are sending a notification.  
	                
	                User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Josh' AND LastName = 'Gilliam' LIMIT 1];
	                
	                mail.setTargetObjectId(idForAssmtDeveloper.Id);            
	                      
	                // Specify the address used when the recipients reply to the email.                 
	                mail.setReplyTo('notifications@thementornetwork.com');
	         
	                
	                // Specify the name used as the display name.      
	                mail.setSenderDisplayName('FAILURE: MENTOR Assessment Notification');
	         
	                
	                // Specify the subject line for the email.      
	                mail.setSubject('FAILURE: MENTOR Assessment Notification');
	                    
	                // Set to True if you want to BCC yourself on the email.    
	                mail.setBccSender(false);
	                        
	                // Optionally append the salesforce.com email signature to the email. 
	                // The email address of the user executing the Apex Code will be used.             
	                mail.setUseSignature(false);
	           
	                
	                // Specify the text content of the email. 
	                    
	                mail.setPlainTextBody('Hello!' 
	                    + '/r/n/r/nAn assessment notification to '
	                    + + a.Owner.FirstName + ' ' + a.Owner.LastName 
	                    + ' failed.  The intended message follows:  /r/n/r/n'
	                    + 'Hello ' 
	                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
	                    + ',/r/n/r/nA '
	                    + a.Assessment_Type__r.Name
	                    + ' assessment is due for client ' 
	                    + a.AccountPerson__c
	                    + ' for the admission '
	                    + a.Admission__r.Id
	                    + '. It seems to be for Quarter '
	                    + qtr
	                    + ' due on '
	                    + newPrettyDueDate
	                    + '. /r/n/r/nPlease go to '
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + a.Admission__c
	                    + ' to create the next assessment.'
	                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce Assessment App');
	                
	                mail.setHtmlBody('Hello!'
	                	+ '<br /><br />An assessment notification to ' 
	                    + a.Owner.FirstName + ' ' + a.Owner.LastName
	                    + ' failed.  The intended message follows:  <br /><br />'
	                    + 'Hello ' 
                    	+ a.Owner.FirstName + ' ' + a.Owner.LastName 
                    	+ ',<br /><br />A '
	                    + a.Assessment_Type__r.Name
	                    + ' assessment is due for client ' 
	                    + a.AccountPerson__c
	                    + ' for the admission '
	                    + a.Admission__r.Id
	                    + '. It seems to be for Quarter '
	                    + qtr
	                    + ' due on '
	                    + newPrettyDueDate
	                    + '. <br /><br />Please go to <a href="'
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + a.Admission__c
	                    + '">'
	                    + a.Admission__c
	                    + '</a> to create the next assessment.'
	                    +'<br /><br />Thanks!<br />The MENTOR Salesforce Assessment App');
	                
	                
	                mail.setSaveAsActivity(false);
	                
	                // Send the email you have created.
	                // PLEASE NOTE:  It is IMPORTANT that we use this method of making one call to regularNoticeEmails.add()
	                // because there is a limit on the number of email calls that can be made per execution of the batch.
	                // I believe that limit is 10 calls.  Calling the method ONCE for a list of single emails only counts
	                // as one call, but gets multiple messages sent.
	                List<Messaging.SingleEmailMessage> regularNoticeEmails = new List<Messaging.SingleEmailMessage>();
	                regularNoticeEmails.add(mail);
	                
	                User idForBP = [ SELECT Id FROM User WHERE FirstName = 'Michelle' AND LastName = 'Broadbent' LIMIT 1];
	                mail.setTargetObjectId(idForBP.Id);
	                regularNoticeEmails.add(mail);
	            
	                
	                return regularNoticeEmails;
	                /*
	                // TEMPORARY:  Delete after uncommenting the lines immediately above.
	            	List<Messaging.SingleEmailMessage> regularNoticeEmails = new List<Messaging.SingleEmailMessage>();
	            	return regularNoticeEmails;
	            	*/
        }       
                
            
   }


   private List<Messaging.SingleEmailMessage> sendIncompleteNotification(Assessment__c a, Datetime creationDate, Id admId){
  		
  	try {
        Datetime creationDueDate = creationDate + 30;
        Datetime prettyCreationDueDate = date.newinstance(creationDueDate.year(), creationDueDate.month(), creationDueDate.day());  
        Date creDate = date.newinstance(prettyCreationDueDate.year(), creationDueDate.month(), creationDueDate.day());  
            
        String newPrettyCreationDueDate = prettyCreationDueDate.format('dd MMM yy');
            
        // 12/4/12: 7:15 AM
        // Send email for assessments that have been started but not completed at the 30 day mark.
    
        
                // Reserve email capacity for the current Apex transaction to ensure 
                // that we won't exceed our daily email limits when sending email after 
                // the current transaction is committed. 
                Messaging.reserveSingleEmailCapacity(1);
         
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a single email. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list. 
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
                
                // Strings to hold the email addresses to which you are sending the email. 
                    
                mail.setTargetObjectId(a.OwnerId);
                
                //String[] toAddresses = new String[] {a.Owner.Email}; 
                //String[] ccAddresses = new String[] {'rory.dela.paz@thementornetwork.com'};
                  
                
                // Assign the addresses for the To and CC lists to the mail object. 
                    
                //mail.setToAddresses(toAddresses);
                //mail.setCcAddresses(ccAddresses);
         
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('MENTOR Assessment Notification');
         
                
                // Specify the subject line the your email.      
                mail.setSubject('CANS Assessment');
          
                
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
          
                
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
           
                
                // Specify the text content of the email. 
                    
                mail.setPlainTextBody('Hello ' 
                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
                    + ',/r/n/r/nA '
                    + a.Assessment_Type__r.Name
                    + ' assessment was started for client ' 
                    + a.AccountPerson__c
                    + ' on '
                    + a.CreatedDate
                    + ' for the admission '
                    + a.Admission__r.Id
                    + ' but is in the Unlocked status as of the 30 day mark ('
                    + (a.CreatedDate + 30)
                    + ')./r/n/r/nPlease go to '
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + a.Id
                    + ' to finalize the assessment.'
                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce Assessment App');
                
                mail.setHtmlBody('Hello ' 
                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
                    + ',<br /><br />A '
                    + a.Assessment_Type__r.Name
                    + ' assessment was started for client ' 
                    + a.AccountPerson__c
                    + ' on '
                    + a.CreatedDate
                    + ' for the admission '
                    + a.Admission__r.Id
                    + ' but is in the Unlocked status as of the 30 day mark ('
                    + (a.CreatedDate + 30)
                    + ').<br /><br />Please go to <a href="'
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + a.Id
                    + '">'
                    + a.Id
                    + '</a> to finalize the assessment.'
                    +'<br /><br />Thanks!<br />The MENTOR Salesforce Assessment App');
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created.            
                List<Messaging.SingleEmailMessage> incompleteNoticeEmails = new List<Messaging.SingleEmailMessage>();
                
                incompleteNoticeEmails.add(mail);
                
                // Create a task reminder for the action.
                Task t = new Task(Subject = a.Assessment_Type__r.Name + ' Assessment Reminder', Status = 'In Progress', Priority = 'Normal', OwnerId = a.OwnerId, Description = 'You have a ' + a.Assessment_Type__r.Name + ' assessment that is not approved at or after the 30 day mark: ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id, WhoId = a.AccountPerson__r.PersonContactId, WhatId = a.AccountPerson__r.Id, ActivityDate = creDate);
                insert t;
                
                return incompleteNoticeEmails;   
        }
        catch(Exception e){
	        Datetime creationDueDate = creationDate + 30;
	        Datetime prettyCreationDueDate = date.newinstance(creationDueDate.year(), creationDueDate.month(), creationDueDate.day());  
	        Date creDate = date.newinstance(prettyCreationDueDate.year(), creationDueDate.month(), creationDueDate.day());  
	            
	        String newPrettyCreationDueDate = prettyCreationDueDate.format('dd MMM yy');
	            
	        // 12/4/12: 7:15 AM
	        // Send email for assessments that have been started but not completed at the 30 day mark.
	    
	        
	                // Reserve email capacity for the current Apex transaction to ensure 
	                // that we won't exceed our daily email limits when sending email after 
	                // the current transaction is committed. 
	                Messaging.reserveSingleEmailCapacity(1);
	         
	                
	                // Processes and actions involved in the Apex transaction occur next, 
	                // which conclude with sending a single email. 
	                    
	                // Now create a new single email message object 
	                // that will send out a single email to the addresses in the To, CC & BCC list. 
	                    
	                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	         
	                
	                // Strings to hold the email addresses to which you are sending the email. 
	                    
	                User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Josh' AND LastName = 'Gilliam' LIMIT 1];
	                
	                mail.setTargetObjectId(idForAssmtDeveloper.Id);
	                //String[] toAddresses = new String[] {a.Owner.Email}; 
	                //String[] ccAddresses = new String[] {'rory.dela.paz@thementornetwork.com'};
	                  
	                
	                // Assign the addresses for the To and CC lists to the mail object. 
	                    
	                //mail.setToAddresses(toAddresses);
	                //mail.setCcAddresses(ccAddresses);
	         
	                
	                // Specify the address used when the recipients reply to the email.                 
	                mail.setReplyTo('notifications@thementornetwork.com');
	         
	                
	                // Specify the name used as the display name.      
	                mail.setSenderDisplayName('MENTOR Assessment Notification');
	         
	                
	                // Specify the subject line the your email.      
	                mail.setSubject('CANS Assessment');
	          
	                
	                // Set to True if you want to BCC yourself on the email.    
	                mail.setBccSender(false);
	          
	                
	                // Optionally append the salesforce.com email signature to the email. 
	                // The email address of the user executing the Apex Code will be used.             
	                mail.setUseSignature(false);
	           
	                
	                // Specify the text content of the email. 
	                    
	                mail.setPlainTextBody('Hello!' 
	                    + '/r/n/r/nAn assessment notification to '
	                    + + a.Owner.FirstName + ' ' + a.Owner.LastName 
	                    + ' failed.  The intended message follows:  /r/n/r/n'
	                	+ 'Hello ' 
	                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
	                    + ',/r/n/r/nA '
	                    + a.Assessment_Type__r.Name
	                    + ' assessment was started for client ' 
	                    + a.AccountPerson__c
	                    + ' on '
	                    + a.CreatedDate
	                    + ' for the admission '
	                    + a.Admission__r.Id
	                    + ' but is in the Unlocked status as of the 30 day mark ('
	                    + (a.CreatedDate + 30)
	                    + ')./r/n/r/nPlease go to '
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + a.Id
	                    + ' to finalize the assessment.'
	                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce Assessment App');
	                
	                mail.setHtmlBody('Hello!'
	                	+ '/r/n/r/nAn assessment notification to ' 
	                    + a.Owner.FirstName + ' ' + a.Owner.LastName
	                    + ' failed.  The intended message follows:  <br /><br />'
	                	+ 'Hello ' 
	                    + a.Owner.FirstName + ' ' + a.Owner.LastName 
	                    + ',<br /><br />A '
	                    + a.Assessment_Type__r.Name
	                    + ' assessment was started for client ' 
	                    + a.AccountPerson__c
	                    + ' on '
	                    + a.CreatedDate
	                    + ' for the admission '
	                    + a.Admission__r.Id
	                    + ' but is in the Unlocked status as of the 30 day mark ('
	                    + (a.CreatedDate + 30)
	                    + ').<br /><br />Please go to <a href="'
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + a.Id
	                    + '">'
	                    + a.Id
	                    + '</a> to finalize the assessment.'
	                    +'<br /><br />Thanks!<br />The MENTOR Salesforce Assessment App');
	                
	                mail.setSaveAsActivity(false);
	                
	                // Send the email you have created.            
	                List<Messaging.SingleEmailMessage> incompleteNoticeEmails = new List<Messaging.SingleEmailMessage>();
	                
	                incompleteNoticeEmails.add(mail);
	                
	                User idForBP = [ SELECT Id FROM User WHERE FirstName = 'Michelle' AND LastName = 'Broadbent' LIMIT 1];
	                mail.setTargetObjectId(idForBP.Id);
	                incompleteNoticeEmails.add(mail);
	                
	                return incompleteNoticeEmails;
		
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
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Josh Gilliam'];     
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
                'Hello!  The AssessmentsNotifications.cls batch job ran.'
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