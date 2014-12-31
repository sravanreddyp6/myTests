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
private class TMN_ContactHandlerTEST {

    static User testUser1 { get; set; }
    static User testUser2 { get; set; }
    
    static testMethod void myUnitTest() {

		Profile profile = [SELECT Id FROM Profile WHERE Name='ESD General' LIMIT 1 ];

		List<User> userList = new List<User>();
		testUser1 = new User(
          	Alias = 'standt', 
          	Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='alpha@testorg.com'
		);
		testUser2 = new User(
          	Alias = 'standt2', 
          	Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='beta@testorg.com'		
		);
		userList.add(testUser1);
		userList.add(testUser2);
		insert userList;

		User usr = [Select id from User where Id = :UserInfo.getUserId()];
 
	     System.RunAs(usr)
	     {
	        Test.startTest();
	         myFunc2();
	         Test.stopTest();
	     }
		

		
		List<Credential_Profile__c> testCreds = [ SELECT Id, Name, Required_for_Mentor__c, Required_for_Co_Applicant__c, Required_for_Foster_Parent_Relative__c,
																Required_for_Foster_Parent_Child__c, Required_for_Resident_Non_Relative__c, Required_for_Pet__c FROM Credential_Profile__c ];
		integer countReqForMentor = 0;
		integer countReqForCoApp = 0;
		integer countReqForFpRelative = 0;
		integer countReqForFpChild = 0;
		integer countReqForResNonRel = 0;
		integer countReqForPet = 0;
		
		for(Credential_Profile__c testCred : testCreds) {
			if(testCred.Required_for_Mentor__c==true) {
				countReqForMentor++;
			}
			if(testCred.Required_for_Co_Applicant__c==true) {
				countReqForCoApp++;
			}
			if(testCred.Required_for_Foster_Parent_Relative__c==true) {
				countReqForFpRelative++;
			}
			if(testCred.Required_for_Foster_Parent_Child__c==true) {
				countReqForFpChild++;
			}
			if(testCred.Required_for_Resident_Non_Relative__c==true) {
				countReqForResNonRel++;
			}
			if(testCred.Required_for_Pet__c==true) {
				countReqForPet++;
			}
		}
		
		System.debug('countReqForMentor: ' + countReqForMentor);
		System.debug('countReqForCoApp: ' + countReqForCoApp);
		System.debug('countReqForFpRelative: ' + countReqForFpRelative);
		System.debug('countReqForFpChild: ' + countReqForFpChild);
		System.debug('countReqForResNonRel: ' + countReqForResNonRel);
		System.debug('countReqForPet: ' + countReqForPet);	
		
				
		List<RecordType> rts = [ SELECT Id, Name FROM RecordType WHERE SobjectType='TMN_Contact__c' ];
		
		Schema.DescribeSObjectResult personSchemaInfo = TMN_Contact__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> personRecordTypes = personSchemaInfo.getRecordTypeInfos();
		
		List<Schema.PicklistEntry> rpTypes = TMN_Contact__c.Related_Party_Type__c.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry rpType : rpTypes) {
			System.debug('rpType values from schema: ' + rpType);
		}

		List<TMN_Contact__c> newPersons = new List<TMN_Contact__c>();

		for(RecordType rt : rts) {
			if(rt.Name=='Mentor') {
				TMN_Contact__c myNewPerson = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					OwnerId = testUser1.Id
				);
				newPersons.add(myNewPerson);
			}
			else if(rt.Name=='Household Member') {
				TMN_Contact__c myNewPersonCoApp = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Co-Applicant',
					Email__c = 'test@test.com',
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonCoApp);
				
				TMN_Contact__c myNewPersonFpRel = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Foster Parent\'s Relative',
					Date_of_Birth__c = date.newInstance(1977,5,4),
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonFpRel);

				TMN_Contact__c myNewPersonFpRel2 = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Foster Parent\'s Relative',
					Date_of_Birth__c = date.newInstance(2010,5,4),
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonFpRel2);
				
				TMN_Contact__c myNewPersonFpChild = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Foster Parent\'s Child',
					Date_of_Birth__c = date.newInstance(1977,5,4),
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonFpChild);

				TMN_Contact__c myNewPersonFpChild2 = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Foster Parent\'s Child',
					Date_of_Birth__c = date.newInstance(2010,5,4),
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonFpChild2);
				
				TMN_Contact__c myNewPersonResNonRel = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Resident-Non Relative',
					Date_of_Birth__c = date.newInstance(1977,5,4),
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonResNonRel);
				
				TMN_Contact__c myNewPersonResNonRel2 = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Resident-Non Relative',
					Date_of_Birth__c = date.newInstance(2010,5,4)
				);
				newPersons.add(myNewPersonResNonRel2);
								
				TMN_Contact__c myNewPersonPet = new TMN_Contact__c(
					RecordTypeId = rt.Id,
					Related_Party_Type__c = 'Pet',
					OwnerId = testUser1.Id 
				);
				newPersons.add(myNewPersonPet);				
			}
			else {
				// No other types should occur...
			}
			//insert myNewPerson;
			//System.debug('The Person\'s ID is: ' + myNewPerson.Id);
			//System.debug('The Person\'s Record Type ID is: ' + myNewPerson.RecordTypeId);
		} 
		insert newPersons;      

		List<Credential_Record__c> credRecs = [ SELECT Id, Name, TMN_Contact__r.Id FROM Credential_Record__c WHERE TMN_Contact__c = :newPersons ];

		List<TMN_Contact__c> myPersons = [ SELECT Id, Name, RecordTypeId, Related_Party_Type__c FROM TMN_Contact__c ];
		for(TMN_Contact__c p : myPersons) {
			System.debug('newP7ersons loops is executing...');
			System.debug('The Person\'s Record Type ID is: ' + p.RecordTypeId);
			
			
			string thisPersonsRecordTypeName;
			for(Schema.RecordTypeInfo sPrts : personRecordTypes) {
   				if(p.RecordTypeId==sPrts.RecordTypeId) {
   					thisPersonsRecordTypeName = sPrts.Name;
   				}
   			}
			
			integer credRecCounter = 0;
			for(Credential_Record__c c : credRecs) {
				if(p.Id==c.TMN_Contact__r.Id) {
					System.debug('Person: ' + p.Id + '; Credential Record added: ' + c.Name);
					credRecCounter++;
				}
			}
			System.debug('Credential Records inserted for this person: ' + credRecCounter);
			if(thisPersonsRecordTypeName=='Mentor') {
				System.debug('Credential Records expected for this person: ' + countReqForMentor);
				System.assertEquals(credRecCounter,countReqForMentor,'ERROR: The count of credential records inserted for the Mentor record type does not match the expected count');
			}
			else if(thisPersonsRecordTypeName=='Related Party') {
				if(p.Related_Party_Type__c=='Co-Applicant') {
					System.debug('Credential Records expected for this person: ' + countReqForCoApp);
					System.assertEquals(credRecCounter,countReqForCoApp,'ERROR: The count of credential records inserted for the Related Party record type, Co-Applicant Related_Party_Type__c, does not match the expected count');
				}
				if(p.Related_Party_Type__c=='Foster Parent\'s Relative') {
					System.debug('Credential Records expected for this person: ' + countReqForFpRelative);
					System.assertEquals(credRecCounter,countReqForFpRelative,'ERROR: The count of credential records inserted for the Related Party record type, Foster Parent Relative Related_Party_Type__c, does not match the expected count');
				}
				if(p.Related_Party_Type__c=='Foster Parent\'s Child') {
					System.debug('Credential Records expected for this person: ' + countReqForFpChild);
					System.assertEquals(credRecCounter,countReqForFpChild,'ERROR: The count of credential records inserted for the Related Party record type, Foster Parent Child Related_Party_Type__c, does not match the expected count');
				}
				if(p.Related_Party_Type__c=='Resident-Non Relative') {
					System.debug('Credential Records expected for this person: ' + countReqForResNonRel);
					System.assertEquals(credRecCounter,countReqForResNonRel,'ERROR: The count of credential records inserted for the Related Party record type, Resident-Non Relative Related_Party_Type__c, does not match the expected count');
				}
				if(p.Related_Party_Type__c=='Pet') {
					System.debug('Credential Records expected for this person: ' + countReqForPet);
					System.assertEquals(credRecCounter,countReqForPet,'ERROR: The count of credential records inserted for the Related Party record type, Pet Related_Party_Type__c, does not match the expected count');
				}
			}
			else if(thisPersonsRecordTypeName=='Master') {
				// DO NOTHING
			}
			else {
				System.debug('RECORD TYPE WAS NOT ACCOUNTED FOR!');
			}
			
		}
		
		List<TMN_Contact__c> tmnContactsToUpdate = new List<TMN_Contact__c>();
		
		TMN_Contact__c mentorPerson	= [ SELECT Id, Date_of_Birth__c FROM TMN_Contact__c WHERE RecordType.Name = 'Mentor' LIMIT 1 ];		
		mentorPerson.Date_of_Birth__c = date.newInstance(1977,6,20);
		mentorPerson.Inactive__c = true;
		
		TMN_Contact__c coAppPerson = [ SELECT Id, Date_of_Birth__c FROM TMN_Contact__c WHERE RecordType.Name = 'Household Member' AND Related_Party_Type__c = 'Co-Applicant' LIMIT 1 ];
		coAppPerson.Date_of_Birth__c = date.newInstance(1978,12,16);
		coAppPerson.Mentor__c = mentorPerson.Id;
		coAppPerson.Inactive__c = true;
		update coAppPerson;

		update mentorPerson;
		delete mentorPerson;
		undelete mentorPerson;
		
		Mentor_Tracking_Report_Record__c mentorsMtrr = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :mentorPerson.Id ];
		mentorsMtrr.Status__c = 'Closed';
		update mentorsMtrr;
		
		Mentor_Tracking_Report_Record__c coAppsMtrr = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :coAppPerson.Id ];
		coAppsMtrr.Status__c = 'Closed';
		update coAppsMtrr;		
		
		List<TMN_Contact__c> tmnContactsForUpdate = new List<TMN_Contact__c>();
		List<Mentor_Tracking_Report_Record__c> mtrrsForUpdate = new List<Mentor_Tracking_Report_Record__c>();
		mentorPerson.Active__c = true;
		tmnContactsForUpdate.add(mentorPerson);
		mentorsMtrr.Status__c = 'Closed';
		mtrrsForUpdate.add(mentorsMtrr);
		
		update tmnContactsForUpdate;
		update mtrrsForUpdate;
		
		mentorPerson.OwnerId = testUser2.Id;
		update mentorPerson;
		 
		
		TMN_ContactHandler myObj = new TMN_ContactHandler(true);
		System.assert(myObj.IsTriggerContext==true,'IsTriggerContext does not return true as expected.');		

    }
    
    @future
	static void myFunc2()
	{
		PermissionSet credOnlyFullPermSet = [ SELECT Id FROM PermissionSet WHERE Name = 'ESD_Credentials_Only_Full' LIMIT 1 ];

		List<PermissionSetAssignment> permSetAssignsToInsert = new List<PermissionSetAssignment>();
		
		PermissionSetAssignment myPermSetAssignment = new PermissionSetAssignment(
			AssigneeId = testUser1.Id,
			PermissionSetId = credOnlyFullPermSet.Id
		);
		permSetAssignsToInsert.add(myPermSetAssignment);
		PermissionSetAssignment myPermSetAssignment2 = new PermissionSetAssignment(
			AssigneeId = testUser2.Id,
			PermissionSetId = credOnlyFullPermSet.Id			
		);
		permSetAssignsToInsert.add(myPermSetAssignment2);

		insert permSetAssignsToInsert;

		List<Credential_Profile__c> testCredentialProfiles = new List<Credential_Profile__c>();
        
		Credential_Profile__c birthCert = new Credential_Profile__c(					
			Name='Birth Certificate', 
			Required_for_Mentor__c=true, 
			Required_for_Co_Applicant__c=true, 
			Required_for_Foster_Parent_Child__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 1
		);
		testCredentialProfiles.add(birthCert);

		Credential_Profile__c socialSecurity = new Credential_Profile__c(					
			Name='Social Security (Copy of Card - only if over 18)', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 2
		);
		testCredentialProfiles.add(socialSecurity);		

		Credential_Profile__c maritalStatusDoc = new Credential_Profile__c(					
			Name='Marital Status Documentation', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 3 
		);
		testCredentialProfiles.add(maritalStatusDoc);		

		Credential_Profile__c faceSheet = new Credential_Profile__c(					
			Name='Face Sheet', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 4
		);
		testCredentialProfiles.add(faceSheet);		

		Credential_Profile__c certAnnualReLicensure = new Credential_Profile__c(					
			Name='Certificate of Annual Re-Licensure', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 5
		);
		testCredentialProfiles.add(certAnnualReLicensure);		

		Credential_Profile__c annualReview = new Credential_Profile__c(					
			Name='Annual Review Completed', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 6
		);
		testCredentialProfiles.add(annualReview);		

		Credential_Profile__c appAndConsent = new Credential_Profile__c(					
			Name='Application & Consent', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 7
		);
		testCredentialProfiles.add(appAndConsent);		

		Credential_Profile__c signedApp = new Credential_Profile__c(					
			Name='Signed Application', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 8
		);
		testCredentialProfiles.add(signedApp);		

		Credential_Profile__c driversLicense = new Credential_Profile__c(					
			Name='Drivers License', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 9
		);
		testCredentialProfiles.add(driversLicense);		

		Credential_Profile__c mvaDrivingRecord = new Credential_Profile__c(					
			Name='MVA Driving Record', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 10
		);
		testCredentialProfiles.add(mvaDrivingRecord);		

		Credential_Profile__c vehicleInsurance = new Credential_Profile__c(					
			Name='Vehicle Insurance', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 11
		);
		testCredentialProfiles.add(vehicleInsurance);		

		Credential_Profile__c vehicleRegistration = new Credential_Profile__c(					
			Name='Vehicle Registration', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 12
		);
		testCredentialProfiles.add(vehicleRegistration);

		Credential_Profile__c homeRentersInsurance = new Credential_Profile__c(					
			Name='Home/Renters Insurance', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 13
		);
		testCredentialProfiles.add(homeRentersInsurance);		

		Credential_Profile__c financialVerification = new Credential_Profile__c(					
			Name='Financial Verification', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 14
		);
		testCredentialProfiles.add(financialVerification);		

		Credential_Profile__c cpsClearance = new Credential_Profile__c(					
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
        	Order__c = 15
		);
		testCredentialProfiles.add(cpsClearance);				

		Credential_Profile__c cpsFullDisclosure = new Credential_Profile__c(					
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
        	Order__c = 16
		);
		testCredentialProfiles.add(cpsFullDisclosure);

		Credential_Profile__c stateCriminalHistory = new Credential_Profile__c(					
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
        	Order__c = 17
		);
		testCredentialProfiles.add(stateCriminalHistory);

		Credential_Profile__c fbiCriminalHistory = new Credential_Profile__c(					
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
        	Order__c = 18
		);
		testCredentialProfiles.add(fbiCriminalHistory);

		Credential_Profile__c fbiFullDisclosure = new Credential_Profile__c(					
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
        	Order__c = 19
		);
		testCredentialProfiles.add(fbiFullDisclosure);
		
		Credential_Profile__c historyOfPlacement = new Credential_Profile__c(					
			Name='History of Placement', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 20
		);
		testCredentialProfiles.add(historyOfPlacement);		

		Credential_Profile__c stateJudiciaryCaseSearch = new Credential_Profile__c(					
			Name='State Judiciary Case Search', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 21
		);
		testCredentialProfiles.add(stateJudiciaryCaseSearch);

		Credential_Profile__c sexOffenderRegistryCheck = new Credential_Profile__c(					
			Name='Sex Offender Registry Check', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 22
		);
		testCredentialProfiles.add(sexOffenderRegistryCheck);

		Credential_Profile__c schoolReference = new Credential_Profile__c(					
			Name='School Reference', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 23
		);
		testCredentialProfiles.add(schoolReference);
		
		Credential_Profile__c individualReference = new Credential_Profile__c(					
			Name='Individual Reference', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 24
		);
		testCredentialProfiles.add(individualReference);		

		Credential_Profile__c agencyReference = new Credential_Profile__c(					
			Name='Agency Reference', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 25
		);
		testCredentialProfiles.add(agencyReference);

		Credential_Profile__c jointReference = new Credential_Profile__c(					
			Name='Joint Reference', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 26
		);
		testCredentialProfiles.add(jointReference);

		Credential_Profile__c childSupport = new Credential_Profile__c(					
			Name='Child Support', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 27
		);
		testCredentialProfiles.add(childSupport);

		Credential_Profile__c oigCheck = new Credential_Profile__c(					
			Name='OIG (Office of Inspector General) Check', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 28
		);
		testCredentialProfiles.add(oigCheck);

		Credential_Profile__c generalMentorProviderAgreement = new Credential_Profile__c(					
			Name='General Mentor Provider Agreement', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 29
		);
		testCredentialProfiles.add(generalMentorProviderAgreement);

		Credential_Profile__c ackFormProvManualIc = new Credential_Profile__c(					
			Name='Acknowledgement Form-Provider Manual for IC', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 30
		);
		testCredentialProfiles.add(ackFormProvManualIc);

		Credential_Profile__c cocAck = new Credential_Profile__c(					
			Name='Code of Conduct Acknowledgement', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 31
		);
		testCredentialProfiles.add(cocAck);

		Credential_Profile__c individualServiceAgreement = new Credential_Profile__c(					
			Name='Individual Service Agreement', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 32
		);
		testCredentialProfiles.add(individualServiceAgreement);

		Credential_Profile__c safeNarrative = new Credential_Profile__c(					
			Name='SAFE Narrative', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 33
		);
		testCredentialProfiles.add(safeNarrative);

		Credential_Profile__c healthInspection = new Credential_Profile__c(					
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
        	Order__c = 34
		);
		testCredentialProfiles.add(healthInspection);

		Credential_Profile__c healthInspectionMove = new Credential_Profile__c(					
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
        	Order__c = 35
		);
		testCredentialProfiles.add(healthInspectionMove);

		Credential_Profile__c fireInspection = new Credential_Profile__c(					
			Name='Fire Inspection', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 36
		);
		testCredentialProfiles.add(fireInspection);

		Credential_Profile__c fireInspectionMove = new Credential_Profile__c(					
			Name='Fire Inspection-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 37
		);
		testCredentialProfiles.add(fireInspectionMove);

		Credential_Profile__c petImmunization = new Credential_Profile__c(					
			Name='Pet\'s Immunization', 
			Required_for_Pet__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 38
		);
		testCredentialProfiles.add(petImmunization);

		Credential_Profile__c medicalExam = new Credential_Profile__c(					
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
        	Order__c = 39
		);
		testCredentialProfiles.add(medicalExam);

		Credential_Profile__c tbTest = new Credential_Profile__c(					
			Name='TB Test', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 40
		);
		testCredentialProfiles.add(tbTest);

		Credential_Profile__c trainingHours = new Credential_Profile__c(					
			Name='Training Hours', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 41
		);
		testCredentialProfiles.add(trainingHours);

		Credential_Profile__c preServiceCert = new Credential_Profile__c(					
			Name='Pre-Service Certification', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 42
		);
		testCredentialProfiles.add(preServiceCert);

		Credential_Profile__c cpr = new Credential_Profile__c(					
			Name='CPR', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 43
		);
		testCredentialProfiles.add(cpr);

		Credential_Profile__c firstAid = new Credential_Profile__c(					
			Name='First Aid', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 44
		);
		testCredentialProfiles.add(firstAid);

		Credential_Profile__c unannouncedHomeVisit = new Credential_Profile__c(					
			Name='Unannounced Home Visit', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 45
		);
		testCredentialProfiles.add(unannouncedHomeVisit);

		Credential_Profile__c has = new Credential_Profile__c(					
			Name='HAS (Health and Safety Assessment)', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 46
		);
		testCredentialProfiles.add(has);

		Credential_Profile__c unannouncedHas = new Credential_Profile__c(					
			Name='Unannounced Health and Safety Assessment', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 47
		);
		testCredentialProfiles.add(unannouncedHas);

		Credential_Profile__c homeEvaluationInitial = new Credential_Profile__c(					
			Name='Home Evaluation-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 48
		);
		testCredentialProfiles.add(homeEvaluationInitial);

		Credential_Profile__c homeEvaluationAnnual = new Credential_Profile__c(					
			Name='Home Evaluation-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 49
		);
		testCredentialProfiles.add(homeEvaluationAnnual);
		
		Credential_Profile__c homeEvaluationMove = new Credential_Profile__c(					
			Name='Home Evaluation (MENTOR FORM NPA)-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 50
		);
		testCredentialProfiles.add(homeEvaluationMove);		

		Credential_Profile__c safeEvaluationUpdate = new Credential_Profile__c(					
			Name='SAFE Evaluation Update', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 51
		);
		testCredentialProfiles.add(safeEvaluationUpdate);

		Credential_Profile__c safeEvaluationUpdateMove = new Credential_Profile__c(					
			Name='SAFE Evaluation Update-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 52
		);
		testCredentialProfiles.add(safeEvaluationUpdateMove);

		Credential_Profile__c physEnvCheckInitial = new Credential_Profile__c(					
			Name='Physical Environment Checklist-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 53
		);
		testCredentialProfiles.add(physEnvCheckInitial);

		Credential_Profile__c physEnvCheckAnnual = new Credential_Profile__c(					
			Name='Physical Environment Checklist-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 54
		);
		testCredentialProfiles.add(physEnvCheckAnnual);

		Credential_Profile__c physEnvCheckMove = new Credential_Profile__c(					
			Name='Physical Environment Checklist-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 55
		);
		testCredentialProfiles.add(physEnvCheckMove);

		Credential_Profile__c contractualComplianceFormInitial = new Credential_Profile__c(					
			Name='Contractual Compliance Form-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 56
		);
		testCredentialProfiles.add(contractualComplianceFormInitial);

		Credential_Profile__c contractualComplianceFormAnnual = new Credential_Profile__c(					
			Name='Contractual Compliance Form-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 57
		);
		testCredentialProfiles.add(contractualComplianceFormAnnual);

		Credential_Profile__c fireSafetyInformationFormInitial = new Credential_Profile__c(					
			Name='Fire Safety Information Form-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 58
		);
		testCredentialProfiles.add(fireSafetyInformationFormInitial);

		Credential_Profile__c fireSafetyInformationFormAnnual = new Credential_Profile__c(					
			Name='Fire Safety Information Form-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 59
		);
		testCredentialProfiles.add(fireSafetyInformationFormAnnual);

		Credential_Profile__c fireSafetyInformationFormMove = new Credential_Profile__c(					
			Name='Fire Safety Information Form-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 60
		);
		testCredentialProfiles.add(fireSafetyInformationFormMove);

		Credential_Profile__c firePrevCheckInitial = new Credential_Profile__c(					
			Name='Fire Prevention Checklist-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 61
		);
		testCredentialProfiles.add(firePrevCheckInitial);

		Credential_Profile__c firePrevCheckAnnual = new Credential_Profile__c(					
			Name='Fire Prevention Checklist-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 62
		);
		testCredentialProfiles.add(firePrevCheckAnnual);

		Credential_Profile__c firePrevCheckMove = new Credential_Profile__c(					
			Name='Fire Prevention Checklist-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 63
		);
		testCredentialProfiles.add(firePrevCheckMove);

		Credential_Profile__c fireEscPlanInitial = new Credential_Profile__c(					
			Name='Fire Escape Plan-Initial', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 64
		);
		testCredentialProfiles.add(fireEscPlanInitial);

		Credential_Profile__c fireEscPlanAnnual = new Credential_Profile__c(					
			Name='Fire Escape Plan-Annual', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 65
		);
		testCredentialProfiles.add(fireEscPlanAnnual);

		Credential_Profile__c fireEscPlanMove = new Credential_Profile__c(					
			Name='Fire Escape Plan-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 66
		);
		testCredentialProfiles.add(fireEscPlanMove);

		Credential_Profile__c waterSafety = new Credential_Profile__c(					
			Name='Water Safety Assessment', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 67
		);
		testCredentialProfiles.add(waterSafety);

		Credential_Profile__c waterSafetyMove = new Credential_Profile__c(					
			Name='Water Safety Assessment-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 68
		);
		testCredentialProfiles.add(waterSafetyMove);

		Credential_Profile__c animalSafety = new Credential_Profile__c(					
			Name='Animal Safety Assessment', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 69
		);
		testCredentialProfiles.add(animalSafety);

		Credential_Profile__c animalSafetyMove = new Credential_Profile__c(					
			Name='Animal Safety Assessment-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 70
		);
		testCredentialProfiles.add(animalSafetyMove);

		Credential_Profile__c fireDrill = new Credential_Profile__c(					
			Name='Fire Drill', 
			Required_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 71
		);
		testCredentialProfiles.add(fireDrill);

		Credential_Profile__c fireDrillMove = new Credential_Profile__c(					
			Name='Fire Drill-Due to Move', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 72
		);
		testCredentialProfiles.add(fireDrillMove);

		Credential_Profile__c ssaTfcExceptionPacket = new Credential_Profile__c(					
			Name='SSA TFC Exception Packet', 
			Optional_for_Mentor__c=true,
			Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 73
		);
		testCredentialProfiles.add(ssaTfcExceptionPacket);

	   insert testCredentialProfiles;
	   
	}
    
}