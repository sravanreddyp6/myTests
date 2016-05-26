public with sharing class IncidentSidebar {
	public Id incidentId {
		get;
		set {
			if (incidentId == value) {
				return;
			}
			incidentId = value;
			incident = [
				SELECT Id, Name, Status__c, Investigation_Not_Required__c, ReportedEvent__c,
				       ReportedEvent__r.Name,
				       (SELECT Id, Name, Status__c, CreatedDate FROM Im_Investigations__r ORDER BY CreatedDate DESC)
				  FROM Im_Incident__c
				 WHERE Id = :incidentId
			];
			incidentName = incident.Name + ' - ' + incident.Status__c.split('-')[1];

			this.newInvestigationAllowed = true;
			this.investigationRequirementToggleAllowed = true;
			for (Im_Investigation__c investigation: incident.Im_Investigations__r) {
				if (investigation.Status__c != 'Disregarded') {
					this.newInvestigationAllowed = false;
					this.investigationRequirementToggleAllowed = false;
				}
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

	public PageReference toggleInvestigationRequired() {
		incident = new Im_Incident__c(
			Id = incident.Id,
			Investigation_Not_Required__c = incident.Investigation_Not_Required__c
		);
		update incident;
		return new PageReference('/' + incident.Id);
	}

	public PageReference createInvestigation() {
		Im_Investigation__c investigation = IncidentInvestigationModel.createInvestigation(incidentId);
		return new PageReference('/apex/IncidentInvestigation?id=' + investigation.Id + '&mode=edit');
	}
}