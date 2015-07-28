public with sharing class Incident_Form_CreateEdit {
	public Incident__c incident {get; set;}
	private Apexpages.standardController controller;
	public ID SAid = Apexpages.currentpage().getparameters().get('SAid');
	public ID recTypeId = apexpages.currentpage().getparameters().get('RecordtypeId'); 
	public string recordtypeName {get; set;}
	public boolean isNew{get; set;}
	public string dateOccurred {get; set;} //for military time - Incident Occurred
	public string dateReported {get; set;} //for militarytime - Incident reported
	
	public Incident_Form_CreateEdit(ApexPages.StandardController controller) {
		this.controller = controller;
		if(!test.isRunningTest()){
			controller.addFields(new list<String>{'Recordtype.Name'});// Add additonal fields here 	
		}
		this.incident = (Incident__c)controller.getRecord();
		//New record creation
		isNew = false;
		if(Apexpages.currentpage().getparameters().get('Id') == null){
			recordtypeName = Utility.getIncidentRecordTypeName(recTypeId);
			this.incident.RecordtypeId = recTypeId;
			isNew = true;
			if(SAid != null){
				this.incident.Service_Assignment__c = SAid;
			}
		}
		//for existing records
		if(apexpages.currentpage().getparameters().get('Id') != null){
			recordtypeName = this.incident.Recordtype.Name;
			isNew = false;
		}
		loadPage();
		
	}
	public void loadPage(){
		
		
	}
	
	public pageReference saveIncident(){
		if(hasErrors()){
				return null;
			}
		
		try{
			this.incident.Date_Occurred__c = Datetime.parse(dateOccurred);
			this.incident.Date_Reported__C = Datetime.parse(dateReported);
			upsert this.incident;
			//Pagereference pg = new pagereference('/apex/Incident_Form_View?Id='+this.Incident.Id);
			Pagereference pg = new pagereference('/'+this.Incident.Id);
			return pg;
		}
		catch(exception e){
			 ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			 return null;
		}
		
		return null;
		
	}
	
	public Service_Assignment__c servAssign {get{
		if(servAssign == null && this.incident.Service_Assignment__c != null){ 
			system.debug('i am in the getter');
			servAssign = [SELECT id, Admission__c, Admission__r.Person_being_served__c FROM Service_Assignment__c WHERE Id=: this.incident.Service_Assignment__c];
		}
		
		return servAssign;
	}	
	set;}
	
	public boolean hasErrors(){
		Boolean foundError = false;
		if(this.incident.Unknown_Date_Occurred__c == false && dateOccurred == null){
			foundError = true;
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Date/Time Incident Occurred'));
		}
		
		return foundError;
	}
	
	
}