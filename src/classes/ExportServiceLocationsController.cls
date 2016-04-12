/**
 * Export service locations controller will read in all the service locations and 
 * make them available to the page to render as an excel spreadsheet.  It simply 
 * queries the service locations object, and loads the results into a list of that
 * type.
 *
 * @author Larry Tambascio
 */
public with sharing class ExportServiceLocationsController {
	
	public String header{get;set;}
	
	public transient list<Service_location__c> locations {get;set;}
	
	public ExportServiceLocationsController(){
	}
	
	public void exportToExcel() {
		header = 'Id,Name,Alias Lookup,Alias Lookup Name,Program ID,Nickname,Street,City,State,Zip Code,Phone,TMN Scope,Population Served,Physical Location,Service Type,Network Offering,Status,Source System';
		this.locations = [SELECT Id, Name, Alias_lookup__c, Alias_lookup__r.Name, ProgramID__c, Location_Nickname__c, Street__c, City__c, State__c, ZIP__c, Phone__c, TMN_Scope__c, Population_Served__c, Physical_Location__c,
						Service_Type__c, Network_Offering__c, Status__c, Source_System__c FROM Service_location__c order by State__c, Name, ProgramId__c asc];
	}
    
}