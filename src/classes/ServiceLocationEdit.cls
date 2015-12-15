public with sharing class ServiceLocationEdit {
	Apexpages.StandardController controller;
	public Service_Location__c location {get; set;}
	
	public ServiceLocationEdit(Apexpages.StandardController controller){
		this.controller = controller;
		this.location = (Service_Location__c)controller.getrecord();
		
	}
	
	public pageReference Save(){
		this.location.Location_nickname__c = string.isBlank(this.location.Location_nickname__c) ? this.location.city__c+' '+this.location.Physical_Location__c : this.location.Location_nickname__c;
		this.location.iServe_Program__c = this.location.State__c+' - '+this.location.Service_Type__c+' - '+this.location.Location_Nickname__c+' - '+this.location.Network_Offering__c;
		if(string.isBlank(this.location.Service_Value__c) && this.location.Source_System__c == 'AVATAR'){ // Should not happen mostly
			this.location.Service_Value__c = this.location.Service_Type__c;
		}
		if(this.location.Source_System__c == 'iServe' && this.location.Service_Type__c != this.location.Service_Value__c){
			this.location.Service_Value__c = this.location.Service_Type__c; // If Someone changes the Service ype of iServe location
		}
		try{
			update location;
			PageReference pg = new PageReference('/apex/ServiceLocationView?id='+location.Id);
			pg.setRedirect(true);
			return pg;
		}catch(exception e){
			Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Cannot Create Service Location due to the error -'+e.getMessage()));
			return null;
		}
			
	}

}