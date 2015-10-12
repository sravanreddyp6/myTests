public with sharing class ActionSummaryCreateFormV2 {
	public Action_Summary__c summary { get; set; }
	public Service_Assignment__c serviceAssignment { get; set; }
	public ApexPages.standardController controller { get; set; }
	public Id pbsId { get; set; }

	public ActionSummaryCreateFormV2(ApexPages.standardController controller) {
		this.controller = controller;
		if (!Test.isRunningTest()) {
			controller.addFields(new String[] {
				'Service_Assignment__r.Person_Being_Served__r.Name'
			});
		}
		summary = (Action_Summary__c) controller.getRecord();
		serviceAssignment = [
			SELECT Person_Being_Served__r.Id, Person_Being_Served__r.Name,
			       Admission__c
			  FROM Service_Assignment__c
			 WHERE Id = :summary.service_assignment__c
		];
		pbsId = serviceAssignment.Person_Being_Served__r.Id;
	}

	public PageReference save() {
		summary.Name = String.format('{0} - {1} - {2}', new List<String>{
			serviceAssignment.Person_being_served__r.name,
			Datetime.newInstance(summary.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy'),
			Datetime.newInstance(summary.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy')
		});
		summary.New_Version__c = true;
		try {
			upsert summary;
			return new ApexPages.standardController(summary).view();
		} catch (Exception ex) {
			ApexPages.addMessages(ex);
		}
		return null;
	}
}