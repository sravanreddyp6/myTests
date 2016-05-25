public with sharing class IncidentSidebar {
	public Id incidentId {
		get;
		set {
			incidentId = value;
			incident = [
				SELECT Id, Name, ReportedEvent__c, ReportedEvent__r.Name
				  FROM Im_Incident__c
				 WHERE Id = :incidentId
			];
		}
	}

	public Im_Incident__c incident { get; set; }

}