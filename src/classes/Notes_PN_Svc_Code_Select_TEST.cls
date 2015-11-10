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
private class Notes_PN_Svc_Code_Select_TEST {

    static testMethod void myUnitTest() {
        
        Contact testContact = new Contact(
            LastName = 'TestLastName'
        );
        insert testContact;
        
        Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today()
        );
        insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
            Admission__c = testAdm.Id,
            Person_Being_Served__c = testContact.Id
        );
        insert testServAssignment;
        
        Service_Code__c testServCode = new Service_Code__c(
        	Service_Code__c = 'TEST SVC CODE',
        	FacilityID__c = 'TEST FAC ID',
        	Program_Code__c = 'TEST PROGRAM CODE',
        	Program__c = 'TEST PROGRAM',
        	Location__c = 'TEST LOCATION',
        	Service_Line__c = 'TEST SERVICE LINE',
        	start_Date__c = date.newinstance(2012,1,1) 
        	        );
        insert testServCode;
        
        Progress_Note__c testPN = new Progress_Note__c(
            Service_Assignment__c = testServAssignment.Id, 
            Service_Code__c = testServCode.Id, 
            Admission__c = testAdm.ID,
            Start_Time__c = datetime.newInstance(2012, 1, 1, 13, 0, 0),
            End_Time__c = datetime.newInstance(2012, 1, 1, 15, 0, 0),
            Person_Being_Served__c = testContact.Id
        );
        insert testPN;

        
        PageReference pageRef = Page.Notes_ProgressNote_Svc_Code_Selection;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testPN);
        Notes_ProgressNote_Svc_Code_Selection objTestPNSCST = new Notes_ProgressNote_Svc_Code_Selection(sc);
    
        objTestPNSCST.getAuths();
        objTestPNSCST.getCodes();
        
        Notes_ProgressNote_GetFieldsAudit_PDF trashTest = new Notes_ProgressNote_GetFieldsAudit_PDF (sc);
        trashTest.getPN();
    
    }
}