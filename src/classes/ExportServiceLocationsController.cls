/**
 * Export service locations controller will read in all the service locations and 
 * make them available to the page to render as an excel spreadsheet.  It simply 
 * queries the service locations object, and loads the results into a list of that
 * type.
 *
 * @author Larry Tambascio
 */
 // comment added to create diff by AV
public with sharing class ExportServiceLocationsController {
	
	public String header{get;set;}
	
	public transient list<Service_location__c> locations {get;set;}
	
	public ExportServiceLocationsController(){
	}
	
	public void exportToExcel() {
		header = 'Alias,Operating Group,Program,iServe Program,Program Code,Facility ID,' +
				'Location Nickname,Network Service Line Offering,Population Served,' +
				'Physical Location,TMN Scope,Service Type,Residential Property Status,Capacity,' +
				'Facility Number (Oracle Fixed Assets),Room and Board Rate,PRN DS Per Hour,' + 
				'Per Productive Unit,Street,City,State,Zip Code,Phone,TIN,NPI,Source System,Status';
		this.locations = [SELECT Alias__c, Alias_lookup__r.Alias_Operating_Group__c, Program__c, 
						iServe_Program__c, ProgramID__c, FacilityID__c, Location_Nickname__c, 
						Network_Offering__c, Population_Served__c, Physical_Location__c, TMN_Scope__c, 
						Service_Type__c, Residential_Property_Status__c, Capacity__c, 
						Facility_Number_Oracle_Fixed_Assets__c, Room_and_Board_Rate__c, 
						PRN_DS_Per_Hour__c, Per_Productive_Unit__c, Street__c, City__c, State__c, 
						ZIP__c, Phone__c, TIN__c, NPI__c, Source_System__c, Status__c 
					FROM Service_location__c order by Alias__c, ProgramId__c asc];
	}
    
}