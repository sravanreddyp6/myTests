public with sharing class Incident_Form_CreateEdit {
	public Incident__c incident {get; set;}
	private Apexpages.standardController controller;
	public ID SAid = apexpages.currentpage().getparameters().get('SAid');
	public ID recTypeId = apexpages.currentpage().getparameters().get('RecordtypeId'); //Using RecordtypeId as the name of the Param as standardontroller can identify the picklist value differences just like standard pages - Sravan
	
	public Incident_Form_CreateEdit(ApexPages.StandardController controller) {
		this.controller = controller;
		this.incident = (Incident__c)controller.getRecord();
		if(recTypeId != null){
			incident.RecordtypeId = recTypeId;
		}
		if(SAid != null){
			this.incident.Service_Assignment__c = SAid;
		}
		
		
		loadPage();
		
	}
	public void loadPage(){
		
		
	}
	
	public Service_Assignment__c servAssign {get{
		if(servAssign == null && this.incident.Service_Assignment__c != null){ 
			system.debug('i am in the getter');
			servAssign = [SELECT id, Admission__c, Admission__r.Person_being_served__c FROM Service_Assignment__c WHERE Id=: this.incident.Service_Assignment__c];
		}
		
		return servAssign;
	}	
	set;}
	
	
	
}