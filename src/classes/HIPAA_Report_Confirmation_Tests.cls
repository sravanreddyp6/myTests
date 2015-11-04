@isTest
public with sharing class HIPAA_Report_Confirmation_Tests {
	static testmethod void simpleTests() {
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('EventLogging').getRecordTypeId();
		Task[] tasks = new Task[] {
			new Task(
				Subject = 'Quarterly Task',
				RecordTypeId = recordTypeId,
				Status = 'Approved'
			),
			new Task(
				Subject = 'Quarterly Task',
				RecordTypeId = recordTypeId,
				Status = 'Not Approved'
			)
		};
		insert tasks;
		PageReference pageRef = new PageReference('/apex/HIPAA_Report_Confirmation');
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('mode', 'edit');
		HIPAA_Report_Confirmation controller = new HIPAA_Report_Confirmation(new ApexPages.StandardController(tasks[0]));
		PageReference page = controller.checkEditMode();
		System.assertNotEquals(-1, page.getUrl().indexOf('HIPAA_Report_Confirmation'));
		System.assertEquals(-1, page.getUrl().indexOf('mode'));

		controller = new HIPAA_Report_Confirmation(new ApexPages.StandardController(tasks[1]));
		page = controller.checkEditMode();
		System.assertEquals(null, page);
		System.assertNotEquals(-1, controller.cancel().getUrl().indexOf('Home'));

		System.assertEquals(null, controller.save());  // won't succeed because there's no attachment
		controller.attachment.Name='Test Attachment';
		controller.attachment.Body=Blob.valueOf('Test Body');
		System.assertEquals(null, controller.save());  // won't succeed because there's no status

		controller.task.Status = 'Rejected';
		System.assertEquals(null, controller.save());  // won't succeed because there's no comment

		controller.task.Description = 'Test';
		System.assertEquals(null, controller.save());  // won't succeed because comment is too short

		controller.task.Description = 'Test Longer Comment so that it satisfies rejection criteria';
		System.assertNotEquals(-1, controller.save().getUrl().indexOf('HIPAA_Report_Confirmation'));

		System.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId = :controller.task.Id].size());

		controller.task.Status = 'Not Approved';
		controller.isEditMode = false;
		System.assertEquals(null, controller.checkEditMode());
	}
}