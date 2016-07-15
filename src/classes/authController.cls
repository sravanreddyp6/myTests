public with sharing class authController {
	public Authorization__c auth { get; set; }

	public authController(ApexPages.StandardController controller) {
		this.auth = (Authorization__c) controller.getRecord();
	}

	public PageReference redirect() {
		Id costtherapyId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByName().get('Costs_TherapyNR').getRecordTypeId();
		Id adhAuthId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByName().get('Funding Source Auth ADH').getRecordTypeId();
		PageReference page;
		if (this.auth.RecordTypeId == costtherapyId ) {
			page = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + this.auth.Id);
		}
		
		else if( this.auth.RecordTypeId == adhAuthId) {
			page = new PageReference('/apex/AuthorizationNRView?id=' + this.auth.Id);
		}
		return page;
	}
    
}