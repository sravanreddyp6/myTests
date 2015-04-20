public with sharing class ActionPlanSummaryView {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController stdController;

	public ActionPlanSummaryView(ApexPages.standardController stdController) {
		this.stdController = stdController;
		if (!Test.isRunningTest()) {
			stdController.addFields(new String[] { 'New_Version__c' });
		}
		summary = (Action_Summary__c) stdController.getRecord();
	}

	public PageReference redirect() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		PageReference returnURL;
		if (summary.New_Version__c) {
			returnURL = new PageReference('/apex/ActionSummaryReportV2');
		} else {
			returnURL = new PageReference('/apex/ActionSummaryReport');
		}
		for (String key: parameters.keySet()) {
			returnUrl.getParameters().put(key, parameters.get(key));
		}
		return returnURL;
	}

	public PageReference redirectEdit() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		PageReference returnURL;
		if (summary.New_Version__c) {
			returnURL = new PageReference('/apex/ActionSummaryReportV2');
			returnUrl.getParameters().put('mode', 'edit');
		} else {
			returnURL = new PageReference('/apex/ActionSummaryReport');
		}
		for (String key: parameters.keySet()) {
			returnUrl.getParameters().put(key, parameters.get(key));
		}
		return returnURL;
	}
}