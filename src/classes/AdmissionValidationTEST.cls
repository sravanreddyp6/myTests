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
 */
@isTest
private class AdmissionValidationTEST {

    static testMethod void myUnitTest() {

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

        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;

        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 1, 1, 0,0,0),
            Discharged_Date__c = date.newInstance(2013, 6, 30),
            Status__c = 'Discharged',
            Discharged_Status__c = 'Positive',
            Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
            Network_Offering__c = 'ARY',
            State__c = 'AZ'
        );
        insert Adm;

        Admission__c Adm2 = new Admission__c(
            Name = 'TEST ADM 2',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.newInstance(2013, 7, 1),
            Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 7, 1, 0,0,0),
            Network_Offering__c = 'ARY',
            State__c = 'AZ'
        );
        insert Adm2;

        Admission__c Adm3 = new Admission__c(
            Name = 'TEST ADM 3',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.newInstance(2013, 9, 1),
            Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 9, 1, 0,0,0),
            Network_Offering__c = 'ARY',
            State__c = 'AZ'
        );
        try{

            insert Adm3;
        }
        catch(DmlException e){
            System.Assert( e.getMessage().contains('This Admission can not be set to Active until there are no other Active Admissions for this PBS'), e.getMessage() );
        }


        Service_Assignment__c ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            SA_Start_Datetime__c = DateTime.newInstance( 2013, 1, 1, 0, 0, 0),
            End_Date__c = date.newInstance(2013, 1, 31),
            Status__c = 'Inactive'
        );
        insert ServAssign;

        Service_Assignment__c ServAssign2 = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN 2',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 2, 1),
            End_Date__c = date.newInstance(2013, 2, 28),
            Status__c = 'Inactive'
        );
        //insert ServAssign2;

        Service_Assignment__c ServAssign3 = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN3',
            Admission__c = Adm2.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 7, 1),
            Status__c = 'Active'
        );
        //insert ServAssign3;

        Service_Assignment__c ServAssign4 = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN 4',
            Admission__c = Adm2.Id,
            Person_Being_Served__c = aContactId,
            SA_Start_Datetime__c = DateTime.newInstance( 2013, 8, 1, 0, 0, 0),
            Start_Date__c = date.newInstance(2013, 8, 1),
            Status__c = 'Active'
        );
        //insert ServAssign4;


        List<Admission__c> myListOfAdms = new List<Admission__c>();

        myListOfAdms.add(Adm);

		// try to add another active admission - cannot do it
        Adm.Status__c = 'Active';
        Adm.Discharged_Date__c = NULL;
        Adm.Discharged_Status__c = NULL;
        Adm.Reason_for_Discharge__c = NULL;
        try  {
        	update Adm;
        }
        catch (DmlException e ) {
        	System.Assert( e.getMessage().contains('This Admission can not be set to Active until there are no other Active Admissions for this PBS'), e.getMessage() );
        }


        ServAssign.Status__c = 'Active';
        ServAssign.End_Date__c = NULL;

        ServAssign3.Status__c = 'Inactive';
        ServAssign3.End_Date__c = date.newInstance(2013,7,31);

 		// update the service assignment to active - cannot do it while admission is inactive
		try {
        	update ServAssign;
		}
		catch ( DMLException e ) {
			System.Assert( e.getMessage().contains('Service Assignments cannot be saved as Active when their Admission is set to Discharged.'), e.getMessage() );
		}
        
        // add a service assignment on active admission
        insert ServAssign4;
        


        // set the admission date to after the SA start date
        Adm2.Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 9, 1, 0,0,0);
        try{
               update Adm2;
        }
        catch(DmlException e){
        	System.Assert( e.getMessage().contains('Admission Date cannot be after a Service Assignment Start Date'), e.getMessage() );
        }

        // discharge the active admission - cannot do it
        Adm2.Status__c = 'Discharged';
        Adm2.Discharged_Date__c = date.newInstance(2013, 10, 31);
        Adm2.Discharged_Status__c = 'Positive';
        Adm2.Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE';
        try{
               update Adm2;
        }
        catch(DmlException e){
            System.Assert( e.getMessage().contains('Service Assignment'), e.getMessage() );
        }
        
        // get some coverage on other trigger actions
        delete adm;
        undelete adm;
        
    }

    static testmethod void unitTest2() {
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

        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;

        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 1, 1, 0,0,0),
            Discharged_Date__c = null,
            Status__c = 'Active',
            Discharged_Status__c = null,
            Reason_for_Discharge__c = null,
            Network_Offering__c = 'ARY',
            State__c = 'AZ'
        );
        insert Adm;

        Adm.Status__c = 'Discharged';
        Adm.Discharged_Date__c = date.newInstance(2013, 7, 31);
        Adm.Discharged_Status__c = 'Positive';
        Adm.Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE';

        Service_Assignment__c ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            End_Date__c = date.newInstance(2013, 1, 31),
            Status__c = 'Inactive'
        );
        insert ServAssign;

        ServAssign.Status__c = 'Inactive';
        ServAssign.End_Date__c = date.newInstance(2013, 8, 1);

        update ServAssign;

        try{
            update Adm;
        }
        catch(DmlException e){
            System.Assert( e.getMessage().contains('Discharged Date cannot be before a Service Assignment End Date'), e.getMessage() );
        }

        ServAssign.End_Date__c = date.newInstance(2013, 7, 31);
        update ServAssign;
        update Adm;

        Admission__c Adm4 = new Admission__c(
            Name = 'TEST ADM 4',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Admission_Effective_DateTime__c = DateTime.NewInstance(2013, 1, 1, 0,0,0),
            Discharged_Date__c = date.newInstance(2013, 6, 30),
            Status__c = 'Discharged',
            Discharged_Status__c = 'Positive',
            Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
            Network_Offering__c = 'ARY'
        );
        try  {
        	insert Adm4;
        } catch (DMLException e) {
        	System.Assert( e.getMessage().contains('overlap'), e.getMessage() );
        }
    }
}