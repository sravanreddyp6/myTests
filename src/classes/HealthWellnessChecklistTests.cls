@isTest
private class HealthWellnessChecklistTests {
	static testMethod void myUnitTest() {
		Health_Wellness_Checklist__c checklist = new Health_Wellness_Checklist__c();
		PageReference pageRef = Page.HealthWellnessChecklist;
		Test.setCurrentPage(pageRef);
		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();

		myData.theAccount.PersonBirthdate = Date.today().addYears(-20);
		update myData.theAccount;

		Apexpages.currentPage().getParameters().put('admissionId', myData.theAdm.Id);

		ApexPages.StandardController stdController = new ApexPages.StandardController(checklist);
		HealthWellnessChecklist controller = new HealthWellnessChecklist(stdController);

		System.assert(controller.cancel().getUrl().indexOf(myData.theAdm.Id) != -1);

		System.assertEquals(true, controller.firstTimeEdit, 'firstTimeEdit should be true');
		System.assertEquals(true, controller.isEditMode, 'isEditMode should be true');
		System.assertEquals(false, controller.isViewMode, 'initially the page should be in Edit mode');
		System.assertEquals(false, controller.canEdit);
		System.assertEquals(false, controller.canFinalize);
		System.assertEquals(false, controller.canRevise);
		System.assertEquals(false, controller.isPostAnnualPhysical);
		System.assertEquals(false, controller.rxPrimary);
		System.assertEquals(false, controller.rxPsych);
		System.assertEquals(false, controller.rxOther);
		System.assertEquals(1, controller.healthCareProviders.size(), 'There should only be None option for health care providers');

		System.assertEquals(myData.theAdm.Id, checklist.Admission__c);
		System.assertEquals('Inactive Draft', checklist.Status__c);
		System.assertEquals('Preparation for Annual Physical', checklist.Status_of_Physical__c);
		System.assertEquals(
			Schema.SObjectType.Health_Wellness_Checklist__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
			checklist.RecordTypeId
		);

		System.assertEquals(null, controller.save(), 'Initial save should fail because of validations');

		checklist.Date_of_Physical__c = Date.today();
		checklist.Taking_Prescription_Medications__c = 'Yes';
		checklist.Dental_Visit_Within_Last_Year__c = 'Yes';
		checklist.Other_Condition_1__c = true;
		checklist.Other_Condition_2__c = true;
		checklist.Other_Condition_3__c = true;
		System.assertEquals(null, controller.save(), 'Save should fail because of dependent validations');

		checklist.Taking_Psychotropic_Medications__c = 'Yes';
		checklist.Other_Condition_1_Specify__c = 'Specify 1';
		checklist.Other_Condition_2_Specify__c = 'Specify 2';
		checklist.Other_Condition_3_Specify__c = 'Specify 3';
		System.assertEquals(null, controller.save(), 'Save should still fail because of dependent validations');

		checklist.How_Many_Psychotropic_Medications__c = '2';
		checklist.Psychotropic_Medications_Prescribed_By__c = 'Primary Care; Psychiatrist; Other';
		System.assertEquals(null, controller.save(), 'Save should still fail because of dependent validations');

		checklist.Medications_Prescribed_By_Other__c = 'Prescribed By Other';
		System.assertNotEquals(null, controller.save(), 'Save should pass validations');

		System.assertEquals(true, controller.rxPrimary);
		System.assertEquals(true, controller.rxPsych);
		System.assertEquals(true, controller.rxOther);

		Admission__c admission = [SELECT Id, Has_Inactive_Draft_Checklist__c FROM Admission__c WHERE ID=:myData.theAdm.Id LIMIT 1];
		// There's a trigger that updates this field after saving the checklist, so we assert on it here
		System.assertEquals(true, admission.Has_Inactive_Draft_Checklist__c);

		// Add a Related Party that can be used as a health care provider to the PBS
		Account account = [SELECT Id, PersonContactId From Account WHERE Id = :myData.theAccount.Id];
		Related_Party__c rp = new Related_Party__c(
			Name = 'Medical Party',
			Person_Being_Served__c = account.PersonContactId,
			Status__c = 'Active',
			Type__c = 'Medical'
		);
		insert rp;

		ApexPages.currentPage().getParameters().put('id', checklist.Id);
		ApexPages.currentPage().getParameters().put('mode', 'VIEW');
		controller = new HealthWellnessChecklist(new ApexPages.StandardController(checklist));
		System.assertNotEquals(null, controller.cancel());
		System.assertEquals(0, controller.under18);
		System.assertEquals('20 Years', controller.ageAtPhysicalStr);
		System.assertEquals(2, controller.healthCareProviders.size(), 'There should be 2 options for health care providers');
		System.assertEquals(rp.Name, controller.healthCareProviders[1].getValue(), 'Health care provider should be populated correctly from Related Party');

		System.assertEquals(false, controller.isEditMode);
		System.assertEquals(true, controller.isViewMode);
		System.assertEquals(false, controller.canFinalize);
		System.assertEquals(true, controller.canEdit);
		System.assertEquals(false, controller.canFinalize);
		System.assertEquals(false, controller.canRevise);

		ApexPages.currentPage().getParameters().put('id', checklist.Id);
		ApexPages.currentPage().getParameters().put('mode', 'EDIT');
		controller = new HealthWellnessChecklist(new ApexPages.StandardController(checklist));

		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(false, controller.isViewMode);
		checklist.Status_of_Physical__c = 'Post Annual Physical';
		System.assertEquals(null, controller.save(), 'Initial Post Annual Save should fail because of validations');

		checklist.Health_Care_Provider_Name__c = rp.Name;
		checklist.PBS_Accompanied_to_Physical_By__c = 'Staff';
		checklist.Height_Not_Collected__c = true;
		System.assertEquals('N/A', controller.bmi);
		checklist.Height_Not_Collected__c = false;
		checklist.Height_Ft__c = 6;
		checklist.Weight_Lb__c = 150;
		System.assertEquals('N/A', controller.bmi);
		checklist.Height_Cm__c = 182.88;
		checklist.Weight_Kg__c = 68.04;
		System.assertEquals('20.3', controller.bmi);
		checklist.Blood_Pressure_Systolic__c = 120;
		checklist.Blood_Pressure_Diastolic__c = 80;
		checklist.Asthma__c = true;
		checklist.Arthritis__c = true;
		checklist.Chronic_Obstructive_Pulmonary_Disease__c = true;
		checklist.Diabetes__c = true;
		checklist.Heart_Disease__c = true;
		checklist.Mental_Health_Condition__c = true;
		checklist.Seizure_Disorder__c = true;
		checklist.Medication_List_Reviewed__c = 'Yes';
		checklist.Date_of_Last_Dental_Visit__c = Date.today();
		checklist.Preventive_Health_Screenings_Discussed__c = 'Yes';
		System.assertEquals(null, controller.save());

		checklist.PBS_Accompanied_to_Physical_By__c = 'Mentor';
		System.assertEquals(null, controller.save());

		checklist.PBS_Accompanied_to_Physical_By__c = 'Other';
		System.assertEquals(null, controller.save());

		checklist.PBS_Accompanied_By_Other__c = 'Other';
		System.assertEquals(null, controller.save());

		checklist.PBS_Accompanied_By_Other_Role__c = 'Other Role';
		System.assertEquals(null, controller.save());

		checklist.Date_of_Physical__c = Date.today().addYears(-19);  // to test the under 18 part
		controller.recalculateAge();
		System.assertEquals(1, controller.under18);
		System.assertEquals(null, controller.save());

		checklist.Date_of_Physical__c = Date.today();
		controller.recalculateAge();
		checklist.Asthma_Management_Discussed__c = 'Yes';
		checklist.Arthritis_Management_Discussed__c = 'Yes';
		checklist.COPD_Management_Discussed__c = 'Yes';
		checklist.Diabetes_Management_Discussed__c = 'Yes';
		checklist.Heart_Disease_Management_Discussed__c = 'Yes';
		checklist.Mental_Health_Condition_Discussed__c = 'Yes';
		checklist.Seizure_Disorder_Management_Discussed__c = 'Yes';
		checklist.Other_Condition_1_Management_Discussed__c = 'Yes';
		checklist.Other_Condition_2_Management_Discussed__c = 'Yes';
		checklist.Other_Condition_3_Management_Discussed__c = 'Yes';
		System.assertNotEquals(null, controller.save(), 'Post Annual Physical Save should pass validations');

		controller.finalize();
		admission = [SELECT Id, Has_Inactive_Draft_Checklist__c FROM Admission__c WHERE ID=:myData.theAdm.Id LIMIT 1];
		System.assertEquals(false, admission.Has_Inactive_Draft_Checklist__c);

		PageReference revisedChecklistPage = controller.revise();
		Health_Wellness_Checklist__c newChecklist = [
			SELECT Id, Previous_Checklist__c, Asthma__c
			  FROM Health_Wellness_Checklist__c
			 WHERE ID=:revisedChecklistPage.getParameters().get('id')
		];
		System.assertEquals(checklist.Id, newChecklist.Previous_Checklist__c);
		// Make sure that fields are carried over
		System.assertEquals(true, newChecklist.Asthma__c);
		ApexPages.currentPage().getParameters().put('lastUrl', 'http://google.com');
		System.assertEquals('http://google.com', controller.cancel().getUrl());
		ApexPages.currentPage().getParameters().remove('lastUrl');

		controller.attachPdf = false;
		System.assertEquals(null, controller.viewAttachPdf());
		controller.attachPdf = true;
		controller.viewAttachPdf();
		Attachment[] attachments = [SELECT Id FROM Attachment WHERE parentId=:myData.theAdm.Id AND Name LIKE 'HealthWellnessChecklist%'];
		System.assertNotEquals(0, attachments.size(), 'The PDF should be attached to the Admission');

		// Check the custom controller
		ApexPages.currentPage().getParameters().put('id', checklist.Id);
		controller = new HealthWellnessChecklist();
		System.assertEquals(checklist.Id, controller.checklist.Id);
	}
}