public with sharing class ActionPlanSummaryNew {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController stdController;

	public final String operatingGroup = [
		SELECT operating_group__c From User
		WHERE ID=:UserInfo.getUserId() LIMIT 1
	].operating_group__c;

	public ActionPlanSummaryNew(ApexPages.standardController stdController) {
		this.stdController = stdController;
	}

	public PageReference redirect() {
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		PageReference returnURL;
		if (operatingGroup == 'Redwood') {
			returnURL = new PageReference('/apex/ActionSummaryCreate');
		} else {
			returnURL = new PageReference('/apex/ActionSummaryCreateV2');
		}
		for (String key: parameters.keySet()) {
			returnUrl.getParameters().put(key, parameters.get(key));
		}
		return returnURL;
	}
}