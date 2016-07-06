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
private class DhrReportSubmitTEST {

    static testMethod void myUnitTest() {
        PageReference dhrReportSubmit = Page.DhrReportSubmit;
        Test.setCurrentPage(dhrReportSubmit);

        List<TMN_Contact__c> tmnContactListForInsert = new List<TMN_Contact__c>();
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
        
        List<RecordType> allTmnContactRecordTypes = [ SELECT DeveloperName FROM RecordType WHERE SObjectType = 'TMN_Contact__c' ];
        for(RecordType rT : allTmnContactRecordTypes) {
            System.debug('rT.DeveloperName: ' + rT.DeveloperName);
        }
        
        RecordType householdMemberRecordType = [ SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'TMN_Contact__c' AND DeveloperName = 'Household_Member' LIMIT 1 ];
        System.debug('householdMemberRecordType.DeveloperName: ' + householdMemberRecordType.DeveloperName);
        
        TMN_Contact__c myCoApplicant = new TMN_Contact__c(
            RecordTypeId = householdMemberRecordType.Id,
            Related_Party_Type__c = 'Co-Applicant',
            Mentor__c = myTmnContact.Id,
            First_Name__c = 'Test',
            Last_Name__c = 'Co Applicant',
            Chessie_Id__c = '12346',
            Date_of_Birth__c = Date.newInstance(1978,12,16),
            Marital_Status__c = 'Married',
            Race__c = 'Multi-Racial',
            Street_1__c = '123 Whatever St.',
            Street_2__c = 'Apt. 1A',
            City__c = 'Louisville',
            State__c = 'KY',
            Primary_Phone__c = '502-555-5555',
            Secondary_Phone__c = '502-555-5556',
            Email__c = 'test@test.com'          
        );
        tmnContactListForInsert.add(myCoApplicant);
        
        insert tmnContactListForInsert; 

        Mentor_Tracking_Report_Record__c myMtrr = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :myTmnContact.Id LIMIT 1 ];
        myMtrr.Submitted_At_Least_Once__c = false;
        myMtrr.Status__c = 'New';
        update myMtrr;

        DhrReportSubmit controller = new DhrReportSubmit();
        controller.showhistory();//added by Sravan to cover the showhistory method.
        system.assertEquals(True,controller.showtable);
        controller.clearhistory();// added by Sravan to cover clearhistory method.
        system.assertEquals(False,controller.showtable);
        string homeurl = URL.getSalesforceBaseUrl().toExternalForm();
        system.assertEquals(controller.baseurl, homeUrl);
        
        String nextPage = controller.SubmitDhr().getUrl();
        
        System.assertEquals('/apex/TmnContactListView', nextPage);
        
        nextPage = controller.Cancel().getUrl();
        System.assertEquals('/apex/TmnContactListView', nextPage);
        
        myMtrr.Status__c = 'Update';
        update myMtrr;      

        DhrReportSubmit controller2 = new DhrReportSubmit();
        nextPage = controller2.SubmitDhr().getUrl();
        
        System.assertEquals('/apex/TmnContactListView', nextPage);
        
        nextPage = controller2.Cancel().getUrl();
        System.assertEquals('/apex/TmnContactListView', nextPage);

        myMtrr.Status__c = 'Closed';
        update myMtrr;

        DhrReportSubmit controller3 = new DhrReportSubmit();
        nextPage = controller3.SubmitDhr().getUrl();
        
        System.assertEquals('/apex/TmnContactListView', nextPage);
        
        nextPage = controller3.Cancel().getUrl();
        System.assertEquals('/apex/TmnContactListView', nextPage);
              
    }
}