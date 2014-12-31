@isTest
private class CredentialAddTEST {

    static testMethod void myUnitTest() {
    	
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
        insert HealthInspection_Profile;
    	
        PageReference credAdd = Page.CredentialAdd;
        Test.setCurrentPage(credAdd);
        
        RecordType mentorRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Mentor' AND SObjectType = 'TMN_Contact__c' ];
        TMN_Contact__c tmnContact = new TMN_Contact__c(
        	RecordType = mentorRecordType
        );
        insert tmnContact;
        
        ApexPages.currentPage().getParameters().put('contactid', tmnContact.Id);
		CredentialAdd controller = new CredentialAdd();
		// set the selected item
		controller.selectedCreds.Add(HealthInspection_Profile.Id);
		controller.SaveAddCred();
		
		String nextPage = controller.CancelCredAdd().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		nextPage = controller.SaveAddCred().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		
		PageReference credAdd2 = Page.CredentialAdd;
		Test.setCurrentPage(credAdd2);
		
		
		RecordType householdMemberRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Household Member' AND SObjectTYpe = 'TMN_Contact__c' ];
		System.debug('householdMemberRecordType: ' + householdMemberRecordType);
		List<TMN_Contact__c> tmnContactsToInsert = new List<TMN_Contact__c>();
		TMN_Contact__c coApplicant = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Co-Applicant',
			Email__c = 'test@test.com'
		);
		tmnContactsToInsert.add(coApplicant);
		TMN_Contact__c fosterParentChild = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Foster Parent\'s Child'
		);
		tmnContactsToInsert.add(fosterParentChild);
		TMN_Contact__c fosterParentRelative = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Foster Parent\'s Relative'
		);
		tmnContactsToInsert.add(fosterParentRelative);
		TMN_Contact__c nonResident = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Resident-Non Relative'
		);
		tmnContactsToInsert.add(nonResident);
		TMN_Contact__c pet = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Pet'
		);
		tmnContactsToInsert.add(pet);
		insert tmnContactsToInsert;
		System.debug('The coApplicant: ' + coApplicant);
		
		ApexPages.currentPage().getParameters().put('contactid', coApplicant.Id);
		CredentialAdd controller2 = new CredentialAdd();
		
		// set the selected item
		controller2.selectedCreds.Add(HealthInspection_Profile.Id);
		controller2.SaveAddCred();
		
		// make sure that it was inserted
		System.Debug( 'Checking for: ' + coApplicant.Id);
		List<Credential_Record__c> existCreds = [SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :coApplicant.Id];
		system.AssertEquals( 1, existCreds.Size());
		
		ApexPages.currentPage().getParameters().put('contactid', fosterParentChild.Id);
		CredentialAdd controller3 = new CredentialAdd();		

		ApexPages.currentPage().getParameters().put('contactid', fosterParentRelative.Id);
		CredentialAdd controller4 = new CredentialAdd();		

		ApexPages.currentPage().getParameters().put('contactid', nonResident.Id);
		CredentialAdd controller5 = new CredentialAdd();

		ApexPages.currentPage().getParameters().put('contactid', pet.Id);
		CredentialAdd controller6 = new CredentialAdd();
    }
}