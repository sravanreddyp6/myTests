@isTest
public with sharing class NursesShiftDocAddModalControllerTest {
	static Service_Assignment__c serviceAssignment;
	static User usr;
	static Admission__c Adm;

	testmethod static void simpleTests() {
		CreateObjects();
		NursesShiftDocAddModalController controller = new NursesShiftDocAddModalController();
		controller.serviceAssignmentId = serviceAssignment.Id;
		controller.evalType = 'CMShiftAssessment';
		controller.showAddShiftDoc();
		DateTime startTime = System.now();
		DateTime endTime = System.now().addMinutes(30);
		controller.shiftDoc.Shift_Start_time__c = startTime;
		controller.shiftDoc.Shift_End_time__c = endTime;
		controller.saveShiftDoc();
		List<Evaluation__c> shiftAsmts = [SELECT Id, NAME FROM Evaluation__c WHERE ServiceAssignment__c =:serviceAssignment.Id AND RecordType.Name = 'CMShiftAssessment'];
		System.assertEquals(1, shiftAsmts.size());
		System.assertEquals(true,
			NursesShiftDocAddModalController.findDupeEval(startTime.format(), endTime.format(), serviceAssignment.Id, 'CMShiftAssessment')
		);
	}
	private static void CreateObjects(){
		// Get System Admin profile ID.
		String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;

		usr = new User(
			USERNAME='test@thementornetwork.com',
			LASTNAME = 'TestLastName',
			FIRSTNAME = 'TestFirstName',
			EMAIL = 'test@thementornetwork.com',
			ALIAS = 'ttest',
			COMMUNITYNICKNAME = 'test.test',
			TIMEZONESIDKEY = 'America/New_York',
			LOCALESIDKEY = 'en_US',
			EMAILENCODINGKEY = 'ISO-8859-1',
			PROFILEID = ProfileId,
			LANGUAGELOCALEKEY = 'en_US',
			ISACTIVE = true,
			legal_custodian__c=true
		);


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

		Adm = new Admission__c(
			Name = 'TEST ADM',
			Person_Being_Served__c = aContactId,
			Effective_Date__c = date.newInstance(2013, 1, 1),
			Status__c = 'Active',
			State__c = 'NC'
		);
		insert Adm;

		string tmp = String.ValueOf(system.currentTimeMillis());
		Service_Location__c svl = new Service_Location__c(
			Street__c = '10 Main St.',
			State__c = 'CA',
			Setting__c = 'Residential',
			Service_Value__c = 'IDD',
			Program__c = 'Redwood Res',
			UniqueID__c = '10031' + tmp.Substring(tmp.length()-6, tmp.length()-1),
			ProgramID__c = '10005',
			Phone__c = '213-555-5555',
			FacilityID__c = 20,
			City__c = 'Bakersfield',
			Alias__c ='10001' + tmp.Substring(tmp.length()-6,tmp.length()-1)
		);

		insert svl;


		serviceAssignment = new Service_Assignment__c(
			Name = 'TEST SERV ASSIGN',
			Admission__c = Adm.Id,
			Person_Being_Served__c = aContactId,
			Start_Date__c = date.newInstance(2013, 1, 1),
			Status__c = 'Active',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT',
			Service_Location__c = svl.id
		);
		insert serviceAssignment;
	}
}