public with sharing class ServiceLocationEdit {
	Apexpages.StandardController controller;
	public Service_Location__c location {get; set;}
	
	public ServiceLocationEdit(Apexpages.StandardController controller){
		this.controller = controller;
		if(!test.isRunningTest()){
			controller.addFields(new List<String>{'Service_Value__c'});
		}
		this.location = (Service_Location__c)controller.getrecord();
		
	}
	
	public pageReference Save(){
		this.location.Location_nickname__c = string.isBlank(this.location.Location_nickname__c) ? this.location.city__c+' '+this.location.Physical_Location__c : this.location.Location_nickname__c;
		this.location.iServe_Program__c = this.location.State__c+' - '+this.location.Service_Type__c+' - '+this.location.Location_Nickname__c+' - '+this.location.Network_Offering__c;
		if(string.isBlank(this.location.Service_Value__c) && this.location.Source_System__c == 'AVATAR'){ // Should not happen mostly
			this.location.Service_Value__c = this.location.Network_offering__c;
		}
		if(this.location.Source_System__c == 'iServe' && (!this.location.Service_Value__c.Contains(this.location.Network_offering__c))){
			this.location.Service_Value__c = this.location.Network_offering__c; // If Someone changes the network service location offering of iServe location
		}
		this.location.UniqueID__c = this.location.FacilityID__c+'||'+this.location.ProgramID__c; // Not necessary as users will not update Program Code and Facility Id but Just in case
		try{
			update this.location;
			PageReference pg = new PageReference('/apex/ServiceLocationView?id='+location.Id);
			pg.setRedirect(true);//flush out View State
			return pg;
		}catch(exception e){
			Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Cannot update Service Location due to the error -'+e.getMessage()));
			return null;
		}
			
	}

}