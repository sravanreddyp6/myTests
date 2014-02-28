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
private class CredentialRecordHandlerTEST {

    static testMethod void myUnitTest() {
        // When a "HAS (Health and Safety Assessment)" record is inserted or update for a MENTOR, update the Date_Most_Recent_HHSI__c field for ALL household members
        // with the value of the received date field for that Mentor's record.
        
        Credential_Profile__c HAS_Profile = new Credential_Profile__c(
        	Name = 'HAS (Health and Safety Assessment)',
        	Required_for_Mentor__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Expiration_Date__c = true,
        	Applies_Note__c = true
        );
        insert HAS_Profile; 
        
        TMN_Contact__c myTmnContact = new TMN_Contact__c(
        	First_Name__c = 'Test',
        	Last_Name__c = 'Mentor',
        	Chessie_Id__c = '12345',
        	Date_of_Birth__c = Date.newInstance(1977,5,4),
        	Marital_Status__c = 'Married',
        	Race__c = 'Multi-Racial',
        	Street_1__c = '123 Whatever St.',
        	Street_2__c = 'Apt. 1A',
        	City__c = 'Louisville',
        	State__c = 'KY',
        	Primary_Phone__c = '502-618-1548',
        	Secondary_Phone__c = '919-333-1425',
        	In_Progress__c = true,
        	In_Progress_Date__c = Date.newInstance(2014,2,1)
        );
        insert myTmnContact;
        
        Credential_Record__c myCredRec = [ SELECT Id, Name FROM Credential_Record__c WHERE Credential_Profile__r.Name = 'HAS (Health and Safety Assessment)' ];
        
        Mentor_Tracking_Report_Record__c myReptRec = new Mentor_Tracking_Report_Record__c();
        myReptRec = [ SELECT Id, Name, Date_Most_Recent_HHSI__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :myTmnContact.Id ];
        
        System.assert(myReptRec.Date_Most_Recent_HHSI__c==null,'There is a value for Date_Most_Recent_HHSI__c, but should not be, on TMN_Contact__c insert,');
        
        myCredRec.Received_Date__c = Date.newInstance(2014,2,1);
        update myCredRec;
        
        System.assert(myReptRec.Date_Most_Recent_HHSI__c==Date.newInstance(2014,2,1),'After test update, the value for Date_Most_Recent_HHSI__c on the Mentor\' record is expected to be 2-1-14, but it is not.');
        
    }
}