@isTest
public with sharing class TmnProviderApplicationTest {
	public static testmethod void simpleTests() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		generator.aliasBuilder.setState('OR');
		generator.serviceLocationBuilder.setState('OR');
		generator.serviceLocationBuilder
			.setServiceType('CM - Case Management')
			.setProgramId('111111000')
			.setLocationNickname('Brokerage 1');
		TestUtils.CoreData coreData = generator.persistData();

		Tmn_Provider_Application__c application = new Tmn_Provider_Application__c();
		TmnProviderApplication controller = new TmnProviderApplication(new ApexPages.StandardController(application));
		System.assertNotEquals(null, controller.redirectNew());  // it should redirect to the new provider page

		Tmn_Provider__c provider = new Tmn_Provider__c(
			First_Name__c = 'First',
			Last_Name__c = 'Last',
			Gender__c = 'Male'
		);
		insert provider;

		PageReference pageRef = Page.TmnProviderApplication;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('applicantId', provider.Id);
		controller = new TmnProviderApplication(new ApexPages.StandardController(application));
		System.assertEquals(null, controller.redirectNew());

		System.assertEquals(false, controller.isViewMode);
		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(false, controller.getIsLocked());
		System.assertEquals('Create New Application', controller.getTitle());
		System.assertEquals('New', controller.application.Enrollment_Type__c);

		System.assertNotEquals(null, controller.save());

		// Testing task system here
		controller.dummyTask = new Task();
		controller.createTasks();  // validation error since no owner id is specified
		controller.populateTasks();
		System.assertEquals(0, controller.tasks.size());

		controller.dummyTask.OwnerId = UserInfo.getUserId();
		controller.createTasks();
		controller.populateTasks();
		System.assert(controller.tasks.size() > 0);

		System.assertNotEquals(null, controller.currentTask);
		controller.showAddTask();
		controller.currentTask.Subject = 'Hello';
		controller.saveTask();
		controller.closeTask();

		pageRef.getParameters().put('taskId', controller.tasks[0].Id);
		controller.showEditTask();
		System.assertNotEquals(null, controller.currentTask.Id);

		// Testing the doc compliance feature
		createDocComplianceObjects();
		controller = new TmnProviderApplication(new ApexPages.StandardController(controller.application));
		System.assertequals(0, controller.getAllAssociatedDocs().size());
		Pb_DocPacket_Document_JO__c[] docPacketAssociations = [ SELECT Id FROM Pb_DocPacket_Document_JO__c ];

		Apexpages.currentPage().getParameters().put('selectedKey', docPacketAssociations[0].Id);
		Apexpages.currentPage().getParameters().put('isSelected', String.valueOf(true));

		System.assertNotEquals(null, controller.treeModel);
		System.assertNotEquals(null, controller.treeData);
		controller.showAddEditDoc();
		System.debug(controller.treeModel);
		controller.updateDocSelection();
		controller.saveDoc();
		controller.cancelSelection();

		System.assertequals(1, controller.getAllAssociatedDocs().size());
		System.assertequals(1, controller.associatedDocs.size());

		// Back to the application flow
		controller.approve();  // should not success since there's a bunch of validation error
		System.assertEquals('Pending Approval', controller.application.Status__c);

		provider.SPD_Number__c = '111111';
		provider.eXPRS_Number__c = '222222';
		provider.Brokerage__c = coreData.serviceLocation.Id;
		update provider;

		application = [ SELECT Id, Name FROM Tmn_Provider_Application__c WHERE Id = :application.Id ];
		controller = new TmnProviderApplication(new ApexPages.StandardController(application));
		System.assertEquals('First Last Application 1', controller.getTitle());
		controller.application.Provider__r = provider;
		controller.application.Application_Date__c = Date.today();
		controller.application.Effective_Date__c = Date.today();
		controller.application.Expiration_Date__c = Date.today().addYears(1);
		controller.application.SPD_Number__c = provider.SPD_Number__c;
		controller.application.eXPRS_Number__c = provider.eXPRS_Number__c;

		controller.approve();
		System.assertEquals('Approved', controller.application.Status__c);

		controller.disqualifyApprovedApplication();  // validation errors
		System.assertEquals('Approved', controller.application.Status__c);
		System.assertEquals(false, controller.application.Disqualified__c);

		controller.application.Disqualification_Date__c = Date.today();
		controller.application.Reason_for_Disqualification__c = 'Test Reason';
		controller.disqualifyApprovedApplication();
		System.assertEquals('Approved', controller.application.Status__c);
		System.assertEquals(true, controller.application.Disqualified__c);
		System.assertEquals(true, [SELECT Id, Disqualified__c FROM Tmn_Provider_Application__c].Disqualified__c);

		pageRef.getParameters().put('applicantId', provider.Id);
		controller = new TmnProviderApplication(new ApexPages.StandardController(new Tmn_Provider_Application__c()));
		System.assertEquals('Re-Enrollment', controller.application.Enrollment_Type__c);

		controller.application.Application_Date__c = Date.today();
		controller.application.Effective_Date__c = Date.today();
		controller.application.Expiration_Date__c = Date.today().addYears(1);
		controller.save();

		controller.disqualify();  // validation errors
		System.assertEquals('Pending Approval', controller.application.Status__c);

		controller.application.Disqualification_Date__c = Date.today();
		controller.application.Reason_for_Disqualification__c = 'Test Reason';
		controller.disqualify();
		System.assertEquals('Disqualified', controller.application.Status__c);
		System.assertEquals(true, controller.application.Disqualified__c);
	}

	private static void createDocComplianceObjects() {
		//create a packet
		PB_DocPacket__c packet = new PB_DocPacket__c(
			RecordTypeId = Schema.SObjectType.Pb_DocPacket__c.getRecordTypeInfosByName().get('Tmn Provider Application').getRecordTypeId(),
			Packet_Name__c = 'OR Brokerage Standard Qualification Document',
			Status__c = 'Active',
			External_ID__c = String.valueOf(Math.abs(Math.random()))
		);
		insert packet;

		//create three documents
		Id rtId = Schema.SObjectType.PB_Document__c.getRecordTypeInfosByName().get('Tmn Provider Application').getRecordTypeId();
		Pb_Document__c[] documents = new Pb_Document__c[] {
			new Pb_Document__c(
				Document_Name__c = 'Provider Enrollment Application/Approval',
				Due__c = 'N/A',
				Effective_Date__c = Date.today(),
				RecordTypeId = rtId,
				External_Id__c = 'TmnProviderApplicationDoc1',
				Recurring__c = 'No',
				Recurring_Frequency__c = 'One-Time',
				Status__c = 'Active',
				Type__c = 'Standard',
				Version__c = 1
			),
			new Pb_Document__c(
				Document_Name__c = 'eXPRS Enrollment Form',
				Due__c = 'N/A',
				Effective_Date__c = Date.today(),
				RecordTypeId = rtId,
				External_Id__c = 'TmnProviderApplicationDoc2',
				Recurring__c = 'No',
				Recurring_Frequency__c = 'One-Time',
				Status__c = 'Active',
				Type__c = 'Standard',
				Version__c = 1
			),
			new Pb_Document__c(
				Document_Name__c = 'Intake Packet',
				Due__c = 'N/A',
				Effective_Date__c = Date.today(),
				RecordTypeId = rtId,
				External_Id__c = 'TmnProviderApplicationDoc3',
				Recurring__c = 'No',
				Recurring_Frequency__c = 'One-Time',
				Status__c = 'Active',
				Type__c = 'Standard',
				Version__c = 1
			),
			new Pb_Document__c(
				Document_Name__c = 'CRIMS Background Check',
				Due__c = 'N/A',
				Effective_Date__c = Date.today(),
				RecordTypeId = rtId,
				External_Id__c = 'TmnProviderApplicationDoc4',
				Recurring__c = 'No',
				Recurring_Frequency__c = 'One-Time',
				Status__c = 'Active',
				Type__c = 'Standard',
				Version__c = 1
			),
			new Pb_Document__c(
				Document_Name__c = 'Fiscal Intermediary Documents',
				Due__c = 'N/A',
				Effective_Date__c = Date.today(),
				RecordTypeId = rtId,
				External_Id__c = 'TmnProviderApplicationDoc5',
				Recurring__c = 'No',
				Recurring_Frequency__c = 'One-Time',
				Status__c = 'Active',
				Type__c = 'Standard',
				Version__c = 1
			)
		};
		insert documents;

		//create the JOs
		Pb_DocPacket_Document_JO__c[] jos = new Pb_DocPacket_Document_JO__c[]{
			new PB_DocPacket_Document_JO__c(
				DocPacket__c = packet.id,
				Document__c = documents[0].id
			),
			new PB_DocPacket_Document_JO__c(
				DocPacket__c = packet.id,
				Document__c = documents[1].id
			),
			new PB_DocPacket_Document_JO__c(
				DocPacket__c = packet.id,
				Document__c = documents[2].id
			),
			new PB_DocPacket_Document_JO__c(
				DocPacket__c = packet.id,
				Document__c = documents[3].id
			),
			new PB_DocPacket_Document_JO__c(
				DocPacket__c = packet.id,
				Document__c = documents[4].id
			)
		};
		insert jos;
	}
}