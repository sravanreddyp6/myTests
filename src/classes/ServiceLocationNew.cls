public with sharing class ServiceLocationNew {
	private Apexpages.StandardController controller;
	public Service_Location__c location {get; set;}
	
	public Alias__c alias{get {
		if(string.isNotBlank(this.location.Alias_lookup__c)){
			return [SELECT Id, Name, Alias_Operating_Group__c,Alias_Business_Unit__c,Alias_Description__c, Alias_Level__c,  Alias_Region__c, Alias_State__c, Alias_Service_Line__c, Alias_Responsibility_Center_Code__c FROM Alias__c WHERE Id= :this.location.Alias_lookup__c];
			}
			return null;
		} set;}
	
	public ServiceLocationNew(Apexpages.StandardController controller){
		this.controller = controller;
		this.location = (Service_location__c) controller.getRecord();
		this.location.Source_System__c = 'iServe';
		this.alias = new Alias__c();
		
	}
	
	public pageReference save(){
		
		if(string.isBlank(this.location.Alias_lookup__c)){
			Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Alias is mandatory for a service location'));
			return null;
		}
		this.location.Name = alias.Name;
		this.location.Alias__c = alias.Name;
		this.location.UniqueID__c = location.FacilityID__c+'||'+location.ProgramID__c;
		this.location.State__c = alias.Alias_State__c;
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
	
	public void setlocationFields(){
		if(string.isNOTBLANK(this.location.Alias_lookup__c)){
			
			List<Service_location__c> existingLocs = [SELECT Id, Name, ProgramID__c, FacilityID__c, Program_Rollup__c, Alias_lookup__r.Name FROM Service_location__c WHERE Alias_lookup__c = :this.location.Alias_lookup__c order by CreatedDate desc LIMIT 1];
			
			if(existingLocs.size() == 0){
				this.location.ProgramID__c = this.alias.Name+'001';
				this.location.Program_Rollup__c = this.alias.Name+'001';
				this.location.FacilityID__c = null;
			}else{
				this.location.ProgramID__c = (null != existingLocs[0].ProgramID__c  && existingLocs[0].ProgramID__c.isNumeric()) ? String.valueof(integer.valueOf(existingLocs[0].ProgramID__c)+1) : null;
				this.location.Program_Rollup__c = (null != existingLocs[0].Program_Rollup__c && existingLocs[0].Program_Rollup__c.isNumeric()) ? string.valueof(integer.valueof(existingLocs[0].Program_Rollup__c)+1) : null;
				this.location.FacilityID__c = existingLocs[0].FacilityID__c;
			}
			
		}else{
			this.location.ProgramID__c = null;
			this.location.Program_Rollup__c = null;
			this.location.FacilityID__c = null;
			
		}
		
	}
	
	/*public string setProgramCode(){
		List<Service_location__c> existingLocs = [SELECT Id, Name, ProgramID__c, Alias_lookup__r.Name FROM Service_location__c WHERE Alias_lookup__c = :this.location.Alias_lookup__c order by CreatedDate desc LIMIT 1];
		if(existingLocs.size() == 0){
			return existingLocs[0].Alias_lookup__r.Name+'000';
		}else{
			return existingLocs[0].Alias_lookup__r.Name+1;
		}	
	}*/
}