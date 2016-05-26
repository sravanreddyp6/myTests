public with sharing class IncidentSidebar {
	public Id incidentId {
		get;
		set {
			incidentId = value;
			incident = [
				SELECT Id, Name, Status__c, Investigation_Not_Required__c, ReportedEvent__c,
				       ReportedEvent__r.Name,
				       (SELECT Id, Name, Status__c FROM Im_Investigations__r)
				  FROM Im_Incident__c
				 WHERE Id = :incidentId
			];
			incidentName = incident.Name + ' - ' + incident.Status__c.split('-')[1];

			this.investigations = [
				SELECT Id, Status__c
				  FROM Im_Investigation__c
				 WHERE Im_Incident__c = :incident.Id
			];
			this.newInvestigationAllowed = true;
			this.investigationRequirementToggleAllowed = true;
			for (Im_Investigation__c investigation: this.investigations) {
				if (investigation.Status__c != 'Draft') {
					this.newInvestigationAllowed = false;
				}
				this.investigationRequirementToggleAllowed = false;
			}
			if (incident.Status__c != 'Incident-Draft') {
				this.newInvestigationAllowed = false;
				this.investigationRequirementToggleAllowed = false;
			}
			if (incident.Investigation_Not_Required__c) {
				this.newInvestigationAllowed = false;
			}
		}
	}

	public String incidentName { get; set; }
	public Im_Incident__c incident { get; set; }
	public Boolean isIncidentStage {
		get {
			return incident.Status__c.startsWith('Incident');
		}
	}

	public Boolean isFinalized {
		get {
			return incident.Status__c == 'Incident-Finalized';
		}
	}

	public Boolean newInvestigationAllowed { get; set; }
	public Boolean investigationRequirementToggleAllowed { get; set; }
	public Im_Investigation__c[] investigations { get; set; }

	public PageReference toggleInvestigationRequired() {
		incident = new Im_Incident__c(
			Id = incident.Id,
			Investigation_Not_Required__c = !incident.Investigation_Not_Required__c
		);
		update incident;
		return new PageReference('/' + incident.Id);
	}
}