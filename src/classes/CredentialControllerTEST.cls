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
private class CredentialControllerTEST {

    static testMethod void myUnitTest() {
        PageReference cred = Page.Credential;
        Test.setCurrentPage(cred);

        List<Credential_Profile__c> credProfsToInsert = new List<Credential_Profile__c>();
        Credential_Profile__c HealthInspection_Profile = new Credential_Profile__c(
        	Name = 'Health Inspection',
        	Required_for_Mentor__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Household',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 1
        );
        credProfsToInsert.add(HealthInspection_Profile);
        
        Credential_Profile__c HealthInspectionD2M_Profile = new Credential_Profile__c(
        	Name = 'Health Inspection-Due to Move',
        	Optional_for_Mentor__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Household',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 2
        );
        credProfsToInsert.add(HealthInspectionD2M_Profile);        
  
        Credential_Profile__c MedExam_Profile = new Credential_Profile__c(
        	Name = 'Medical Exam',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_Under_18__c = true,
        	Needed_for_18_Over__c = true,
        	OLM_Requirement__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 3
        );
        credProfsToInsert.add(MedExam_Profile);  

        Credential_Profile__c CPS_Clearance_Profile = new Credential_Profile__c(
        	Name = 'CPS Clearance',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_CPS_Full_Disclosure__c = true,
        	Applies_Documented_Date__c = true,
        	Applies_Outcome_of_Clearance__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 4
        );
        credProfsToInsert.add(CPS_Clearance_Profile);
  
        Credential_Profile__c CPS_FullDisc_Profile = new Credential_Profile__c(
        	Name = 'CPS Full Disclosure',
        	Optional_for_Mentor__c = true,
        	Optional_for_Co_Applicant__c = true,
        	Optional_for_Foster_Parent_Relative__c = true,
        	Optional_for_Foster_Parent_Child__c = true,
        	Optional_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	Applies_Outcome_of_Clearance__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 5
        );
        credProfsToInsert.add(CPS_FullDisc_Profile);  

        Credential_Profile__c FBI_Crim_Hx_Profile = new Credential_Profile__c(
        	Name = 'FBI Criminal History',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_Federal__c = true,
        	Applies_Type_of_Conviction_Federal__c = true,
        	Applies_Federal_Conviction__c = true,
        	Applies_FBI_Full_Disclosure__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 6
        );
        credProfsToInsert.add(FBI_Crim_Hx_Profile);

        Credential_Profile__c FBI_Full_Disc_Profile = new Credential_Profile__c(
        	Name = 'FBI Full Disclosure',
        	Optional_for_Mentor__c = true,
        	Optional_for_Co_Applicant__c = true,
        	Optional_for_Foster_Parent_Relative__c = true,
        	Optional_for_Foster_Parent_Child__c = true,
        	Optional_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_Federal__c = true,
        	Applies_Type_of_Conviction_Federal__c = true,
        	Applies_Federal_Conviction__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 7
        );
        credProfsToInsert.add(FBI_Full_Disc_Profile);

        Credential_Profile__c State_Crim_Hx_Profile = new Credential_Profile__c(
        	Name = 'State Criminal History',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_State__c = true,
        	Applies_Type_of_Conviction_State__c = true,
        	Applies_State_Conviction__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 8
        );
        credProfsToInsert.add(State_Crim_Hx_Profile);  

  		insert credProfsToInsert;
        
        RecordType mentorRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Mentor' AND SObjectType = 'TMN_Contact__c' ];
        TMN_Contact__c tmnContact = new TMN_Contact__c(
        	RecordTypeId = mentorRecordType.Id
        );
        insert tmnContact;
        
        ApexPages.currentPage().getParameters().put('contactid', tmnContact.Id);

		CredentialController controller = new CredentialController();
		String nextPage = controller.CancelCreds().getUrl();
		
		System.assertEquals('/apex/Credential?contactId=' + tmnContact.Id, nextPage);
		
		nextPage = controller.SaveCreds().getUrl();

		System.assertEquals('/apex/Credential?contactId=' + tmnContact.Id, nextPage);

    }
}