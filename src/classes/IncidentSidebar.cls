public with sharing class IncidentSidebar {
	public Id incidentId {
		get;
		set {
			incidentId = value;
			incident = [
				SELECT Id, Name, Status__c, ReportedEvent__c, ReportedEvent__r.Name
				  FROM Im_Incident__c
				 WHERE Id = :incidentId
			];
			incidentName = incident.Name + ' - ' + incident.Status__c.split('-')[1];
		}
	}

	public String incidentName { get; set; }
	public Im_Incident__c incident { get; set; }
	public Boolean isIncidentStage {
		get {
			return incident.Status__c.startsWith('Incident');
		}
	}
}