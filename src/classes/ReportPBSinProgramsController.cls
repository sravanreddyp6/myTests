public with sharing class ReportPBSinProgramsController {
	
	public Date fromDate {get;set;}
	public Date toDate {get;set;}
	public Service_Assignment__c SA{get; set;}
	public ReportPBSinProgramsController(){
		this.SA = new Service_Assignment__c();
		this.SA.Status__c = null;
	}
	
	
	
	@RemoteAction
	//Perfroming the SOQL; string generation in Remote action as apex has built in methods to parse the data easily - Sravan - 17/11/2015
	public static Service_Assignment__c[] getServiceAssignments(string fromD, string toD, string ageMax, string ageMin, string gender,
													string admissionState, string admissionStatus, string servAssignStatus,
													string aliasName, string SLtmnScope, string SLserviceType, string SLnetworkLine,
													string SLpopulationServed, string SLphysicalLocation  ){
														
		string SOQL = 'SELECT id, Person_being_served__r.Name, Person_being_served__r.Age__c, Person_being_served__r.Gender__c, Person_being_served__r.Does_the_person_Identify__c,Person_being_served__r.Race__c, Person_being_served__r.MailingStateCode,';
				SOQL = SOQL+' admission__r.Name, Admission__r.State__c, Admission__r.Status__c, Admission__r.Admission_Effective_DateTime__c, Admission__r.Discharged_Date__c, Name, Status__c, SA_Start_DateTime__c FROM Service_Assignment__c WHERE id!= null';
		
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
		
		Service_Assignment__c[] servAssigns = Database.Query(SOQL+whereClause);
		return servAssigns;
	}

}