public with sharing class Incident_Form_View {
	
	private Apexpages.StandardController controller;
	public Incident__c incident {get; set;}
	
	
	public Incident_Form_View(Apexpages.StandardController controller){
		this.Controller = controller;
		this.incident = (Incident__c)controller.getRecord();
		
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