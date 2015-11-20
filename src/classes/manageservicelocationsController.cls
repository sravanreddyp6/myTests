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
		this.locations = [SELECT Id, Name, Alias_lookup__c, ProgramID__c, Location_Nickname__c, Street__c, City__c, State__c, ZIP__c, Phone__c, TMN_Scope__c, Population_Served__c, Physical_Location__c,
							Service_Type__c, Network_Offering__c, Status__c, Source_System__c FROM Service_location__c WHERE Alias_lookup__c =: this.servicelocation.Alias_lookup__c order by State__c, Name, ProgramId__c asc];
		
		if(this.locations.size() == 0){
			apexpages.addmessage(new apexpages.message(ApexPages.Severity.INFO, 'Service locations does not exist for the Alias chosen'));
			return;
		}
	}

}