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
		this.location.Status__c = 'Active';
		this.alias = new Alias__c();
	}
	
	public pageReference save(){
		List<String> errors = new list<string>();
		
		if(string.isBlank(this.location.Alias_lookup__c)){
			Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Alias is mandatory for a service location'));
			return null;
		}
		if(this.location.ProgramID__c == null){
			errors.add('Program Code is Mandatory');
		}
		if(this.location.Physical_Location__c == null){
			errors.add('Physical Location is Mandatory');
		}
		if(this.location.FacilityID__c == null){
			errors.add('Facility Id is Mandatory');
		}
		if(this.location.TMN_Scope__c == null){
			errors.add('TMN Scope is Mandatory');
		}
		if(this.location.Network_Offering__c == null){
			errors.add('Network Service Line Offering is Mandatory');
		}
		if(this.location.Service_Type__c == null){
			errors.add('Service type is Mandatory');
		}
		if(this.location.Population_Served__c == null){
			errors.add('Population Served is Mandatory');
		}
		/*if(this.location.Residential_Property_Status__c == null){
			errors.add('Residential Property Status is Mandatory');
		}
		if(this.location.Capacity__c == null){
			errors.add('Capacity is Mandatory');
		}*/
		if(this.location.Street__c == null){
			errors.add('Street is Mandatory');
		}
		if(this.location.City__c == null){
			errors.add('City is Mandatory');
		}
		if(this.location.State__c == null){
			errors.add('State is Mandatory');
		}
		if(this.location.Zip__c == null){
			errors.add('Zip Code is Mandatory');
		}
		if(this.location.Status__c == null){
			errors.add('Status is Mandatory');
		}
		
		if(errors.size() > 0){
			for(string e: errors){
				Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, e));
			}
			return null;
			
		}else{
			this.location.Name = alias.Name;
			this.location.Alias__c = alias.Name;
			this.location.State__c = alias.Alias_State__c;
			this.location.Source_System__c = 'iServe';
			this.location.UniqueID__c = location.FacilityID__c+'||'+location.ProgramID__c;
			this.location.Location_nickname__c = string.isBlank(this.location.Location_nickname__c) ? this.location.city__c+' '+this.location.Physical_Location__c : this.location.Location_nickname__c;
			this.location.Program__c = this.location.State__c+' - '+this.location.Service_Type__c+' - '+this.location.Location_Nickname__c+' - '+this.location.Network_Offering__c;
			this.location.iServe_Program__c = this.location.Program__c;
			//Sravan - Many places in the app Service Value is used. This is to prevent any failures until all the business rules are figured out - 12/08/2015
			this.location.Service_Value__c = this.location.Service_Type__c;
			try{
				insert location;
				PageReference pg = new PageReference('/apex/ServiceLocationView?id='+location.Id);
				pg.setRedirect(true);
				return pg;
			}catch(exception e){
				if(e.getMessage().contains('duplicate value found')){
					Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.ERROR,'Another Service Location exists with this Program Code and Facility ID'));
					return null;
				}
				else{
					Apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Cannot Create Service Location due to the error -'+e.getMessage()));
					return null;
				}
			}
		}
	
	}
	
	public void setlocationFields(){
		
		if(string.isNOTBLANK(this.location.Alias_lookup__c)){
			Alias__c a = this.alias;
			this.location.State__c = a.Alias_State__c;
			//Query most recently created service location in the System for the selected alias
			List<Service_location__c> existingLocs = [SELECT Id, Name, ProgramID__c, FacilityID__c, Program_Rollup__c, Alias_lookup__r.Name FROM Service_location__c WHERE Alias_lookup__c = :this.location.Alias_lookup__c order by CreatedDate desc LIMIT 1];
			if(existingLocs.size() == 0){
				this.location.ProgramID__c = a.Name+'001';
				this.location.Program_Rollup__c = a.Name+'001';
			}else{
				this.location.ProgramID__c = (null != existingLocs[0].ProgramID__c  && existingLocs[0].ProgramID__c.isNumeric()) ? String.valueof(integer.valueOf(existingLocs[0].ProgramID__c)+1) : null;
				this.location.Program_Rollup__c = (null != existingLocs[0].Program_Rollup__c && existingLocs[0].Program_Rollup__c.isNumeric()) ? string.valueof(integer.valueof(existingLocs[0].Program_Rollup__c)+1) : null;
				this.location.FacilityID__c = existingLocs[0].FacilityID__c;
			}
			
			if(this.location.FacilityID__c == null){
				//populate the facility ID based based on the alias State or Operating group (NR and CM)
				if(a.Alias_Operating_Group__c == 'Care Meridian' || a.Alias_Operating_Group__c == 'CareMeridian'){
					this.location.FacilityID__c = Utility.FACILITYID_MAP.get('CareMeridian'); //13
				}else if(a.Alias_Operating_Group__c == 'NeuroRestorative'){
					this.location.FacilityID__c = Utility.FACILITYID_MAP.get('NeuroRestorative'); //20
				}else{
					this.location.FacilityID__c =  Utility.FACILITYID_MAP.containsKey(a.Alias_State__c) ? Utility.FACILITYID_MAP.get(a.Alias_State__c) : null;
				}
			}
		}else{
			this.location.ProgramID__c = null;
			this.location.Program_Rollup__c = null;
			this.location.FacilityID__c = null;
			this.location.State__c = null;
		}
		
	}
	
	public pageReference cancel(){
		PageReference pg = new PageReference('/apex/manageServiceLocations');
		pg.setRedirect(true);
		return pg;
	}
	
}