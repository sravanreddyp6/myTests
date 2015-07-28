public with sharing class Incident_Form_View {
	
	private Apexpages.StandardController controller;
	public Incident__c incident {get; set;}
	public string recordtypeName {get; set;}
	public transient List<Incident_Person__c> relatedPeople { get; private set;}
	
	public Incident_Form_View(Apexpages.StandardController controller){
		this.Controller = controller;
		if(!test.isRunningTest()){
			controller.addFields(new list<string>{'Recordtype.name'});
		}
		this.incident = (Incident__c)controller.getRecord();
		recordtypeName = this.incident.Recordtype.Name;
		
		relatedPeople = [ select id, person_type__c, staff_member__c, mentor__c, other_people__c, recordtype.name, createdbyid, createddate, lastmodifieddate, lastmodifiedbyid from incident_person__c where incident__c = :this.incident.id];
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
		pageReference pg = new pageReference('/apex/Incident_Form_CreateEdit?id='+this.incident.Id);
		return pg;
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