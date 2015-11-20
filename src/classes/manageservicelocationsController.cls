public with sharing class manageservicelocationsController {
	private Apexpages.StandardController controller {get;set;}
	public Service_location__c servicelocation {get;set;}
	public boolean manage {get; set;}
	public transient list<Service_location__c> locations {get;set;}
	public manageservicelocationsController(Apexpages.StandardController controller){
		this.controller = controller;
		this.servicelocation = (Service_location__c)controller.getRecord();
		this.locations = new list<Service_location__c>();
		this.manage = false;
	}
	
	public pageReference createNew(){
		 return new pageReference('/apex/ServiceLocationEdit');
	}
	
	public pageReference manageExisting(){
		this.manage = true;
		return null;
	}
	
	public void run(){
		if(string.isBlank(this.servicelocation.Alias_lookup__c)){
			apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Please Choose an alias'));
			return;
		}
		this.locations = [SELECT Id, Name, Alias__c, Alias_lookup__c, FacilityID__c, Location_Nickname__c, Network_Offering__c, Service_Type__c, Service_Value__c, Status__c FROM Service_location__c WHERE Alias_lookup__c =: this.servicelocation.Alias_lookup__c ];
		
		if(this.locations.size() == 0){
			apexpages.addmessage(new apexpages.message(ApexPages.Severity.INFO, 'Service locations does not exist for the Alias chosen'));
			return;
		}
	}

}