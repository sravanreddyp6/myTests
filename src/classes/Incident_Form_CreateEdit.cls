public with sharing class Incident_Form_CreateEdit {
	public Incident__c Incident {get; set;}
	public ID SAid = apexpages.currentpage().getparameters().get('SAid');
	public ID recTypeId = apexpages.currentpage().getparameters().get('RecordtypeId'); //Using RecordtypeId as the name of the Param as standardontroller can identify the picklist value differences just like standard pages - Sravan
	
	public Incident_Form_CreateEdit(ApexPages.StandardController controller) {
		incident = (Incident__c)controller.getRecord();
		if(recTypeId != null){
			incident.RecordtypeId = recTypeId;
		}
		if(SAid != null){
			incident.Service_Assignment__c = SAid;
		}
		
		loadPage();
	}
	public void loadPage(){
		
		
	}
}