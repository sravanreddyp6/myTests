public with sharing class Report_CANS_ActionableItems {
	public List<Assessment_Response__c> responses { get; set; }
	// In order to use the datepicker using inputField
	public Assessment__c dummyStartDateAssessment { get; set; }
	public Assessment__c dummyEndDateAssessment { get; set; }
	public String scoreQuery = '';
	public String scoreChosen { get;
		set {
			if (value == '2 or 3') {
				scoreQuery = 'Rating__c = \'2\' OR Rating__c = \'3\'';
			} else {
				scoreQuery = 'Rating__c = \'3\'';
			}
			scoreChosen = value;
		}
	}
	public List<SelectOption> scoreOptions {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('2 or 3', '2 or 3'));
			options.add(new SelectOption('Only 3', 'Only 3'));
			return options;
		}
	}
	public void runReport() {
		Boolean errorFound = false;
		if (dummyStartDateAssessment.Assessment_Date__c == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date is required.'));
			errorFound = true;
		}
		if (dummyEndDateAssessment.Assessment_Date__c == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date is required.'));
			errorFound = true;
		}
		if (errorFound) {
			scoreChosen = '';
			return;
		}
		// Because dynamic SOQL does not bind dot-notationed variables, we have
		// to explicitly set them here
		Date startDate = dummyStartDateAssessment.Assessment_Date__c;
		Date endDate = dummyEndDateAssessment.Assessment_Date__c;
		responses = Database.query('SELECT Id, Name, Rating__c, Question__r.Question_Title__c, CreatedBy.Name, CreatedById, Assessment__r.Owner.Id, Assessment__r.Owner.Name, Assessment__r.Assessment_Date__c, Assessment__r.Id, Assessment__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Id FROM Assessment_Response__c WHERE (' + scoreQuery + ') AND Assessment__r.Assessment_Date__c > :startDate AND Assessment__r.Assessment_Date__c < :endDate');
	}
	public Report_CANS_ActionableItems() {
		dummyStartDateAssessment = new Assessment__c();
		dummyEndDateAssessment = new Assessment__c();
	}
}