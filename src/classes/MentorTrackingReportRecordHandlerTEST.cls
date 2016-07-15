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
private class MentorTrackingReportRecordHandlerTEST {

    static testMethod void myUnitTest() {
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
        	Active__c = true,
        	Active_Date__c = Date.newInstance(2014,2,1)
        );
        //tmnContactListForInsert.add(myTmnContact);
        insert myTmnContact;
        
        Mentor_Tracking_Report_Record__c myMtrr = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :myTmnContact.Id ];
        myMtrr.Submitted_At_Least_Once__c = true;
        update myMtrr;
        
        delete myMtrr;
        undelete myMtrr;
        
        MentorTrackingReportRecordHandler mtrrh = new MentorTrackingReportRecordHandler(true);
        Boolean b = mtrrh.IsTriggerContext;
        System.assert(b==true, 'The IsTriggerContext boolean is not equal to true, counter to expectations.');
        
    }
}