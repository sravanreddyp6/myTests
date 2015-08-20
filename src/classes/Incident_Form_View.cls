public with sharing class Incident_Form_View {
	
	private Apexpages.StandardController controller;
	public Incident__c incident {get; set;}
	public string recordtypeName {get; set;}
	public transient List<Incident_Person__c> relatedStaff { get; private set;}
	public transient List<Incident_Person__c> relatedMentor { get; private set;}
	public transient List<Incident_Person__c> relatedOther { get; private set;}
	public transient List<Incident_Person__c>relatedPEople { get; private set;}
	
	public Incident_Form_View(Apexpages.StandardController controller){
		this.Controller = controller;
		if(!test.isRunningTest()){
			controller.addFields(new list<string>{'Recordtype.name'});
		}
		this.incident = (Incident__c)controller.getRecord();
		recordtypeName = this.incident.Recordtype.Name;
		
		relatedStaff = [ select id, person_type__c, staff_member__c, staff_member__r.name, staff_member__r.employee_number__c, staff_member__r.job_title__c, createdbyid, createddate, lastmodifieddate, lastmodifiedbyid from incident_person__c where incident__c = :this.incident.id and recordtype.name='Staff' order by createddate ];
		relatedMentor = [ select id, person_type__c, mentor__c, mentor__r.full_name__c, mentor__r.name, mentor__r.role__c, createdbyid, createddate, lastmodifieddate, lastmodifiedbyid from incident_person__c where incident__c = :this.incident.id and recordtype.name='Mentor' order by createddate ];
		relatedOther= [ select id, person_type__c, title__c, other_people__c, createdbyid, createddate, lastmodifieddate, lastmodifiedbyid from incident_person__c where incident__c = :this.incident.id and recordtype.name='Other' order by createddate ];
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