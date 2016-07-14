@isTest
public with sharing class TaskControllerTests {
	static testmethod void redirectionTests() {
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('EventLogging').getRecordTypeId();
		Task eventLoggingTask = new Task(
			Subject = 'Quarterly Report',
			RecordTypeId = recordTypeId,
			Status = 'Not Approved'
		);
		Task normalTask = new Task(
			Subject = 'Normal Task',
			Status = 'Not Completed'
		);
		insert eventLoggingTask;
		insert normalTask;
		TaskController controller = new TaskController(new ApexPages.StandardController(eventLoggingTask));
		System.assert(controller.redirect().getUrl().indexOf('HIPAA_Report_Confirmation') != -1);
		controller = new TaskController(new ApexPages.StandardController(normalTask));
		System.assertEquals(null, controller.redirect());
	}
}