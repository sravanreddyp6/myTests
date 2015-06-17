public with sharing class IncompleteShiftDocReport {
	public Evaluation__c[] shiftDocs { get; set; }
	public Boolean reportRan { get; set; }
	// This is a dummy evaluation just so that we can bind inputFields for Start/End Date to an
	// SObject Date fields for SF's datepicker.
	public Evaluation__c dummyEvaluation { get; set; }

	public IncompleteShiftDocReport() {
		shiftDocs = new Evaluation__c[]{};
		dummyEvaluation = new Evaluation__c();
		reportRan = false;
	}

	public void runReport() {
		Boolean errorFound = false;
		// We use the Evaluation_Date__c and Dialysis_Onset__c fields from the dummy SObject
		// to model Start Date and End Date.
		Date startDate = dummyEvaluation.Evaluation_Date__c;
		Date endDate = dummyEvaluation.Dialysis_Onset__c;
		if (startDate == null) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'Start Date cannot be blank.')
			);
		}
		if (startDate > Date.Today()) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'Start Date cannot be later than today.')
			);
		}
		if (endDate == null) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'End Date cannot be blank.')
			);
		}
		if (endDate > Date.Today().addDays(2)) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'End Date cannot be later than 2 days from today.')
			);
		}
		if (errorFound) {
			return;
		}
		shiftDocs = [
			SELECT Id, Name, ServiceAssignment__r.Admission__r.Person_Being_Served__c,
			       OwnerId, Shift_Start_Time__c, Shift_End_Time__c, ServiceAssignment__r.Status__c,
			       ServiceAssignment__c
			  FROM Evaluation__c
			 WHERE (RecordType.Name = 'CMShiftAssessment' OR RecordType.Name = 'CNA Workbook')
			   AND Shift_Start_Time__c <= :endDate.addDays(1)
			   AND Shift_End_Time__c >= :startDate
			   AND Status__c = 'Draft'
		];
		reportRan = true;
	}
}