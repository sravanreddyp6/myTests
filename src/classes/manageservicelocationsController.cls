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
		this.locations = [SELECT Id, Name, Alias__c, Alias_lookup__c FROM Service_location__c WHERE Alias_lookup__c =: this.servicelocation.Alias_lookup__c ];
	}

}