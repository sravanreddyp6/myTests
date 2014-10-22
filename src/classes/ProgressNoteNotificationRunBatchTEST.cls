/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Shaun Added a comment here for a Demo with Sravan.
 */
@isTest
private class ProgressNoteNotificationRunBatchTEST {

    static testMethod void myUnitTest() {
          User usr = [ SELECT Id FROM User WHERE LastName = 'Gilliam' AND FirstName = 'Josh' LIMIT 1];
        
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
                Effective_Date__c = date.today()
          );
          insert testAdm;

          Admission__c testAdm2 = new Admission__c(
                Name = 'TEST ADM2',
                Person_Being_Served__c = myContact.Id,
                Effective_Date__c = date.today()
          );
          insert testAdm2;
            
            Service_Assignment__c testServAssignment = new Service_Assignment__c(
              Admission__c = testAdm.Id,
              Person_Being_Served__c = aContactId
            );
            insert testServAssignment;

            Service_Assignment__c testServAssignment2 = new Service_Assignment__c(
              Admission__c = testAdm2.Id,
              Person_Being_Served__c = myContact.Id
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
            	if(rt.DeveloperName != 'NC_TFC' && rt.DeveloperName != 'NC_Wks_1_6_TFC'){
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
              	if(rt.DeveloperName == 'NC_TFC' || rt.DeveloperName == 'NC_Wks_1_6_TFC'){
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