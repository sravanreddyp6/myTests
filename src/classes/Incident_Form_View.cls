public with sharing class Incident_Form_View {
	
	private Apexpages.StandardController controller;
	public Incident__c incident {get; set;}
	public Service_Assignment__c servAssign {get; set;}
	
	
	public Incident_Form_View(Apexpages.StandardController controller){
		this.Controller = controller;
		this.incident = (Incident__c)controller.getRecord();
		servAssign = new Service_Assignment__c();
		if(string.isNotBlank(string.valueOf(this.incident.Service_Assignment__c))){
			servAssign = [SELECT Id, Admission__c, Admission__r.Person_being_served__c FROM Service_Assignment__c WHERE Id=:this.incident.Service_Assignment__c ];
		}
		
	}
	
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