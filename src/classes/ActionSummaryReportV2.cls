public with sharing class ActionSummaryReportV2 {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController controller { get; set; }
	public ActionSummaryReportV2(ApexPages.standardController controller) {
		this.controller = controller;
		summary = (Action_Summary__c) controller.getRecord();
	}
}