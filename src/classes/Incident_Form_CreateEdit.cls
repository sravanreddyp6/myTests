public with sharing class Incident_Form_CreateEdit {
	public Incident__c Incident {get; set;}
	public ID SAid = apexpages.currentpage().getparameters().get('SAid');
	public ID recTypeId = apexpages.currentpage().getparameters().get('RecordtypeId');
	
	public Incident_Form_CreateEdit(ApexPages.StandardController controller) {
		incident = (Incident__c)controller.getRecord();
		incident.RecordtypeId = recTypeId;
		loadPage();
	}
	public void loadPage(){
		
		
	}
}