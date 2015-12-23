
@isTest
private class ProgressNoteNotificationRunBatchTEST {

    static testMethod void myUnitTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='ESD General']; 
        User u = new User(Alias = 'testxxx1', Email='integration@testorg.com111', 
                    EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='integration@testorg.com222', LastName='integration');
          
        List<User> users = [ select id, name from user where lastname = 'integration'];
        if ( users.size() == 0 )
        	insert u;
        	
        User usr = [ SELECT Id FROM User WHERE LastName = 'integration' LIMIT 1];        
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='AZ',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        
        Contact myContact = new Contact(
            LastName = 'TEST'
        );
        insert myContact;
        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;
          
          
          Admission__c testAdm = new Admission__c(
                Name = 'TEST ADM',
                Person_Being_Served__c = aContactId,
                Effective_Date__c = date.today()-1,
                Admission_Effective_DateTime__c = DateTime.now().AddDays(-1)
          );
          insert testAdm;

          Admission__c testAdm2 = new Admission__c(
                Name = 'TEST ADM2',
                Person_Being_Served__c = myContact.Id,
                Effective_Date__c = date.today()-1,
                Admission_Effective_DateTime__c = DateTime.now().AddDays(-1)
          );
          insert testAdm2;
            
            Service_Assignment__c testServAssignment = new Service_Assignment__c(
              Admission__c = testAdm.Id,
              Person_Being_Served__c = aContactId,
              SA_Start_DateTime__c = DateTime.now()
              
            );
            insert testServAssignment;

            Service_Assignment__c testServAssignment2 = new Service_Assignment__c(
              Admission__c = testAdm2.Id,
              Person_Being_Served__c = myContact.Id,
              SA_Start_DateTime__c = DateTime.now()
            );
            insert testServAssignment2;
            
            Service_Code__c testServCode = new Service_Code__c(
              Service_Code__c = 'TEST SVC CODE',
              FacilityID__c = 'TEST FAC ID',
              Program_Code__c = 'TEST PROGRAM CODE',
              Start_Date__c = date.newInstance(2012,1,1) 
            );
            insert testServCode;
            
            
            List<RecordType> pnRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Progress_Note__c' AND IsActive = true];
            
            System.Debug('What is in pnRecordTypes: ' + pnRecordTypes);
            
            List<Progress_Note__c> pnsToInsert = new List<Progress_Note__c>();
            Integer pnsToInsertCounter = 0;             
            
            for(RecordType rt : pnRecordTypes){
                if(rt.DeveloperName != 'NC_TFC' && rt.DeveloperName != 'NC_Wks_1_6_TFC' && rt.DeveloperName != 'Therapy'){
                      pnsToInsert.add( 
                        new Progress_Note__c(
                          Service_Assignment__c = testServAssignment.Id, 
                          Service_Code__c = testServCode.Id, 
                          Admission__c = testAdm.ID,
                          Start_Time__c = datetime.now().addHours(-2),
                          End_Time__c = datetime.now(),
                          Person_Being_Served__c = aContactId,
                          No_Approval_Needed__c = false,
                          RecordTypeId = rt.Id,
                          Status__c = 'In Progress',
                          OwnerId = usr.Id)
                        );
                      pnsToInsert.add(
                        new Progress_Note__c(
                          Service_Assignment__c = testServAssignment.Id, 
                          Service_Code__c = testServCode.Id, 
                          Admission__c = testAdm.ID,
                          Start_Time__c = datetime.now().addHours(-2),
                          End_Time__c = datetime.now(),
                          Person_Being_Served__c = aContactId,
                          No_Approval_Needed__c = false,
                          RecordTypeId = rt.Id,
                          Status__c = 'Final',
                          OwnerId = usr.Id)
                      ); 
                    }
                if(rt.DeveloperName == 'NC_TFC' || rt.DeveloperName == 'NC_Wks_1_6_TFC' || rt.DeveloperName == 'Therapy'){
                    pnsToInsert.add( 
                    new Progress_Note__c(
                      Service_Assignment__c = testServAssignment.Id, 
                      Service_Code__c = testServCode.Id, 
                      Admission__c = testAdm.ID,
                      Start_Time__c = datetime.now().addHours(-2),
                      End_Time__c = datetime.now(),
                      Person_Being_Served__c = aContactId,
                      No_Approval_Needed__c = false,
                      RecordTypeId = rt.Id,
                      Status__c = 'In Progress',
                      Purpose_Service_is_Billable__c = false, //Avoid hitting validation rule.
                      OwnerId = usr.Id)
                    );
                  pnsToInsert.add(
                    new Progress_Note__c(
                      Service_Assignment__c = testServAssignment.Id, 
                      Service_Code__c = testServCode.Id, 
                      Admission__c = testAdm.ID,
                      Start_Time__c = datetime.now().addHours(-2),
                      End_Time__c = datetime.now(),
                      Person_Being_Served__c = aContactId,
                      No_Approval_Needed__c = false,
                      RecordTypeId = rt.Id,
                      Status__c = 'Final',
                      Purpose_Service_is_Billable__c = false, //Avoid hitting validation rule.
                      OwnerId = usr.Id)
                  ); 
                }           
            }

              pnsToInsert.add(
                new Progress_Note__c(
                  Service_Assignment__c = testServAssignment2.Id, 
                  Service_Code__c = testServCode.Id, 
                  Admission__c = testAdm2.ID,
                  Start_Time__c = datetime.now().addHours(-2),
                  End_Time__c = datetime.now(),
                  No_Approval_Needed__c = false,
                  Person_Being_Served__c = myContact.Id,
                  Status__c = 'Final',
                  OwnerId = usr.Id)
              );       
            
            insert pnsToInsert;
            
            SchedulableContext sc;
            ProgressNoteNotificationRunBatch pNNRB = new ProgressNoteNotificationRunBatch();
            
            Integer emailbefore = Limits.getEmailInvocations();
            pNNRB.execute(sc); 
            system.debug('emailbefore = ' + emailbefore + ';  Limits.getEmailInvocations() = ' + Limits.getEmailInvocations());

    }
}