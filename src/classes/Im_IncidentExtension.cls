public with sharing class Im_IncidentExtension {
	public Im_Incident__c incident { get; set; }

	public Im_IncidentExtension(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) {
			stdController.addFields(new String[] { 'Status__c',  'ReportedEvent__c'});
		}
		incident = (Im_Incident__c) stdController.getRecord();
	}
	public PageReference redirectImIncidect() {
		if (incident.status__c == 'Event-Draft' || incident.Status__c == 'Event-Submitted' || incident.Status__c == 'Event-Disregarded'){
			DSPSubmitTxn txn = new DSPSubmitTxn();
			txn.requestType = 'Incident';
			txn.inputArgs = incident.id;
			return  txn.submitTxnRequest();
		}
		return new PageReference('/apex/IncidentManagement?id=' + this.incident.Id);
	}
}