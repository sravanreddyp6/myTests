public with sharing class Incident_Form_View {
	
	private Apexpages.StandardController controller;
	public Incident__c incident {get; set;}

	
	public Incident_Form_View(Apexpages.StandardController controller){
		this.Controller = controller;
		this.incident = (Incident__c)controller.getRecord();
	}
	
	//Making sure to issue a Query only if the type of the incident is 'PBS. Make sure servAssign == null before query, otherwise Query will be called whenever servAssign is referred in the Page
	public Service_Assignment__c servAssign {get{
		if(servAssign == null && this.incident.Service_Assignment__c != null){ 
			system.debug('i am in the getter');
			servAssign = [SELECT id, Admission__c, Admission__r.Person_being_served__c FROM Service_Assignment__c WHERE Id=: this.incident.Service_Assignment__c];
		}
		
		return servAssign;
	}	
	set;}
	
	
	public pageReference editIncident(){
		
		return null;
	}
	public pageReference disregardIncident(){
		
		
		return null;
	}
	public pageReference submitIncident(){
		
		return null;
	}
	
	public pagereference reviewIncident(){
		
		return null;
	}
	
}