public with sharing class TaskController {
	public Task task { get; set; }

	public TaskController(ApexPages.StandardController controller) {
		if (!Test.isRunningTest()) {
			controller.addFields(new String[] { 'Status' });
		}
		this.task = (Task) controller.getRecord();
	}

	public PageReference redirect() {
		Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('EventLogging').getRecordTypeId();
		PageReference page;
		if (this.task.RecordTypeId == recordTypeId) {
			String mode = (this.task.Status == 'Approved' || this.task.Status == 'Rejected') ? 'view' : 'edit';
			page = new PageReference('/apex/HIPAA_Report_Confirmation?id=' + this.task.Id + '&mode=' + mode);
		}
		return page;
	}
}