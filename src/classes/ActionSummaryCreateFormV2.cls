public with sharing class ActionSummaryCreateFormV2 {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController controller { get; set; }

	public ActionSummaryCreateFormV2(ApexPages.standardController controller) {
		this.controller = controller;
		summary = (Action_Summary__c) controller.getRecord();
	}
}