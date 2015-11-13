public with sharing class ServiceLocationNew {
	private Apexpages.StandardController controller;
	public Service_Location__c location {get; set;}
	public Alias__c alias{get; set;}
	
	public ServiceLocationNew(Apexpages.StandardController controller){
		this.controller = controller;
		this.location = (Service_location__c) controller.getRecord();
		this.location.Source_System__c = 'iServe';
		this.alias = new Alias__c();
		
	}
	
	public pageReference save(){
		this.alias = [SELECT Id, Name, Alias_Operating_Group__c,Alias_Business_Unit__c,Alias_Description__c, Alias_Level__c,  Alias_Region__c, Alias_State__c, Alias_Service_Line__c FROM Alias__c WHERE Id= :this.location.Alias_lookup__c];
		this.location.Name = alias.Name;
		this.location.Alias__c = alias.Name;
		this.location.UniqueID__c = location.FacilityID__c+'||'+location.ProgramID__c;
		try{
			insert location;
			PageReference pg = new PageReference('/apex/ServiceLocationEdit?id='+location.Id);
			pg.setRedirect(true);
			return pg;
		}catch(exception e){
			apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		
	}

}