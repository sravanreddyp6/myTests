public with sharing class IncidentInvestigation {
	public ApexPages.standardController stdController;
	public Im_Investigation__c investigation { get; set; }
	public Im_Incident__c incident { get; set; }
	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit';
		}
	}

	public Boolean isFinalized {
		get {
			return this.investigation.Status__c == 'Finalized';
		}
	}

	public Boolean isLocked {
		get {
			return isFinalized;
		}
	}

	public IncidentInvestigation(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		if(!test.isRunningTest()){
			this.stdController.addFields(new List<String>{
				'Im_Incident__c'
			});
		}
		this.investigation = (IM_Investigation__c) stdController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (params.containsKey('incidentId')) {
			this.investigation.Im_Incident__c = params.get('incidentId');
			this.investigation.Status__c = 'Draft';
			this.mode = 'edit';
		} else if (params.containsKey('mode')) {
			this.mode = params.get('mode');
		} else {
			this.mode = 'view';
		}
		incident = [ SELECT Id, Name FROM Im_Incident__c WHERE Id=:this.investigation.Im_Incident__c ];
	}

	public PageReference save() {
		upsert investigation;
		return new PageReference('/' + investigation.Id);
	}

	public PageReference disregard() {
		update new Im_Investigation__c(
			Id = investigation.Id,
			Status__c = 'Disregarded'
		);
		return null;
	}

	public PageReference finalize() {
		update new Im_Investigation__c(
			Id = investigation.Id,
			Status__c = 'Finalized'
		);
		return null;
	}
}