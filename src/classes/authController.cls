public with sharing class authController {
	public Authorization__c auth { get; set; }

	public authController(ApexPages.StandardController controller) {
		this.auth = (Authorization__c) controller.getRecord();
	}

	public PageReference redirect() {
		Id recordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByName().get('Costs_TherapyNR').getRecordTypeId();
		PageReference page;
		if (this.auth.RecordTypeId == recordTypeId) {
			page = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + this.auth.Id);
		}
		return page;
	}
    
}