public with sharing class ReportPBSinProgramsController {
	
	public List<Service_Assignment__c> servAssigns {get;set;}
	public Service_Assignment__c SA{get; set;}
	public string queryString;
	public ReportPBSinProgramsController(){
		this.servAssigns = new list<Service_Assignment__c>();
		this.SA = new Service_Assignment__c();
		this.SA.Status__c = null;
		queryString = 'SELECT Id, Person_Being_Served__r.PBS_Identifier__c, Person_being_served__r.LastName,Person_being_served__r.FirstName, Person_being_served__r.Age__c, Person_being_served__r.Gender__c, Person_Being_Served__r.Does_the_person_Identify__c, Person_being_served__r.Race__c, Person_being_served__r.MailingStateCode,';
		queryString = queryString+' admission__r.Name, Admission__r.State__c, Admission__r.Status__c, Admission__r.Admission_Effective_DateTime__c, Admission__r.Discharged_Date__c, Name, Status__c, SA_Start_DateTime__c, End_Date__c, Alias__c, Service_Location__r.Location_Nickname__c,';
		queryString = queryString+' Service_Location__r.TMN_Scope__c, Service_Location__r.Network_Offering__c,Service_Location__r.Population_Served__c, Service_Location__r.Physical_Location__c, Service_Location__r.Service_Type__c,';
		queryString = queryString+' Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c,Highest_Level_of_Education_at_Start__c,Service_Began_via_Acquisition_Company__c,Service_Ended_via_Business_Divested__c,Was_dissatisfaction_reason_for_service_e__c,Who_was_dissatisfied__c, Primary_Reason_for_Dissatisfaction__c FROM Service_Assignment__c WHERE id!= null';
		this.servAssigns = Database.Query(queryString + ' LIMIT 10000');
	}
	
	public void run(){
		this.servAssigns = Database.Query(queryString);
	}
	
	public pageReference exporttoExcel(){
		//this.servAssigns = Database.Query(queryString);
		PageReference pg = new pageReference('/apex/ReportPBSinProgramsExcel');
		pg.getHeaders().put('content-disposition', 'attachment;');
		pg.setRedirect(false);
		return pg;
	}
	
	
	
	@RemoteAction
	//Perfroming the SOQL; string generation in Remote action as apex has built in methods to parse the data easily - Sravan - 17/11/2015
	public static Service_Assignment__c[] getServiceAssignments(string fromD, string toD, string ageMax, string ageMin, string gender,
													string admissionState, string admissionStatus, string servAssignStatus,
													string aliasName, string SLtmnScope, string SLserviceType, string SLnetworkLine,
													string SLpopulationServed, string SLphysicalLocation  ){
														
		string SOQL = 'SELECT Id, Person_Being_Served__r.PBS_Identifier__c, Person_being_served__r.LastName,Person_being_served__r.FirstName, Person_being_served__r.Age__c, Person_being_served__r.Gender__c, Person_Being_Served__r.Does_the_person_Identify__c, Person_being_served__r.Race__c, Person_being_served__r.MailingStateCode,';
				SOQL = SOQL+' admission__r.Name, Admission__r.State__c, Admission__r.Status__c, Admission__r.Admission_Effective_DateTime__c, Admission__r.Discharged_Date__c, Name, Status__c, SA_Start_DateTime__c, End_Date__c, Alias__c, Service_Location__r.Location_Nickname__c,';
				SOQL = SOQL+' Service_Location__r.TMN_Scope__c, Service_Location__r.Network_Offering__c,Service_Location__r.Population_Served__c, Service_Location__r.Physical_Location__c, Service_Location__r.Service_Type__c,';
				SOQL = SOQL+' Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c,Highest_Level_of_Education_at_Start__c,Service_Began_via_Acquisition_Company__c,Service_Ended_via_Business_Divested__c,Was_dissatisfaction_reason_for_service_e__c,Who_was_dissatisfied__c, Primary_Reason_for_Dissatisfaction__c FROM Service_Assignment__c WHERE id!= null';
		
		system.debug('fromDate>>>> '+fromD);
		system.debug('todate>>>> '+toD);
		system.debug('ageMax>>>> '+ageMax);
		system.debug('ageMin>>>> '+ageMin);
		system.debug('Gender>>>> '+gender);
		system.debug('admissionState>>>> '+admissionState);
		system.debug('admissionStatus>>>> '+admissionStatus);
		system.debug('servAssignStatus>>>> '+servAssignStatus);
		system.debug('aliasName>>>> '+aliasName);
		system.debug('SLtmnScope>>>> '+SLtmnScope);
		system.debug('SLserviceType>>>> '+SLserviceType);
		system.debug('SLnetworkLine>>>> '+SLnetworkLine);
		system.debug('SLpopulationServed>>>> '+SLpopulationServed);
		system.debug('SLphysicalLocation>>>> '+SLphysicalLocation);
		
		string whereClause = '';				
		if(gender != null){
			system.debug('Gender>>>> '+gender);
			whereClause += ' AND Person_being_served__r.Gender__c = :gender';
		}
		if(admissionState != null){
			system.debug('admissionState>>>> '+admissionState);
			whereClause += ' AND Admission__r.State__c = :admissionState';
		}
		if(admissionStatus != null){
			system.debug('admissionStatus>>>> '+admissionStatus);
			whereClause += ' AND Admission__r.Status__c = :admissionStatus';
		}
		if(servAssignStatus != null){
			system.debug('servAssignStatus>>>> '+servAssignStatus);
			whereClause += ' AND Status__c = :servAssignStatus';
		}
		if(SLtmnScope != null){
			system.debug('SLtmnScope>>>> '+SLtmnScope);
			whereClause += ' AND Service_location__r.TMN_Scope__c = :SLtmnScope';
		}
		if(SLserviceType != null){
			system.debug('SLserviceType>>>> '+SLserviceType);
			whereClause += ' AND Service_location__r.Service_Type__c = :SLserviceType';
		}
		if(SLnetworkLine != null){
			system.debug('SLnetworkLine>>>> '+SLnetworkLine);
			whereClause += ' AND Service_location__r.Network_offering__c = :SLnetworkLine';
		}
		if(SLpopulationServed != null){
			system.debug('SLpopulationServed>>>> '+SLpopulationServed);
			whereClause += ' AND Service_location__r.Population_Served__c = :SLpopulationServed';
		}
		if(SLphysicalLocation != null){
			system.debug('SLphysicalLocation>>>> '+SLphysicalLocation);
			whereClause += ' AND Service_location__r.Population_Served__c = :SLphysicalLocation';
		}
				      	
		System.debug('SOQL>>>>>>>>>>>>>> '+SOQL+whereClause);
		
		Service_Assignment__c[] servAssigns = Database.Query(SOQL+' LIMIT 500');
		return servAssigns;
	}

}