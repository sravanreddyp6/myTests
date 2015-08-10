public with sharing class IncompleteShiftDocReport {
	public Evaluation__c[] shiftDocs { get; set; }
	public Boolean reportRan { get; set; }
	// This is a dummy evaluation just so that we can bind inputFields for Start/End Date to an
	// SObject Date fields for SF's datepicker.
	public Evaluation__c dummyEvaluation { get; set; }

	public List<String> leftSelectedPrograms { get; set; }
	public List<SelectOption> leftPrograms { get; set; }
	public List<String> rightSelectedPrograms { get; set; }
	public List<SelectOption> rightPrograms { get; set; }
	public List<Id> selectedPBS { get; set; }
	public List<SelectOption> pbsList { get; set; }

	public IncompleteShiftDocReport() {
		shiftDocs = new Evaluation__c[]{};
		dummyEvaluation = new Evaluation__c();

		pbsList = new List<SelectOption>();
		rightPrograms = new List<SelectOption>();
		leftPrograms = new List<SelectOption>();
		selectedPbs = new List<Id>();
		leftSelectedPrograms = new List<String>();
		rightSelectedPrograms = new List<String>();

		for (AggregateResult program: [
				SELECT service_location__r.id slID, service_location__r.Alias__c alias,
				       service_location__r.program__c prgm
				  FROM service_assignment__c
				 GROUP BY service_location__r.id, service_location__r.program__c,
				          service_location__r.Alias__c
				HAVING COUNT(service_location__r.id) > 0
				 ORDER BY service_location__r.program__c]) {
			leftPrograms.add(new SelectOption((String) program.get('alias'),
				String.valueOf(program.get('alias')) + '-' + String.valueOf(program.get('prgm')))
			);
		}

		reportRan = false;
	}

	public void addPrograms() {
		for (String p: leftSelectedPrograms){
			for(Integer i=0; i < leftPrograms.size(); i++){
				if (leftPrograms.get(i).getValue() == p) {
					rightPrograms.add(new SelectOption(leftPrograms.get(i).getValue(),
						leftPrograms.get(i).getLabel()));
					leftPrograms.remove(i);
					break;
				}
			}
		}
		updateProgramSelections();
	}

	public void removePrograms(){
		for (String p: rightSelectedPrograms){
			for(Integer i=0; i < rightPrograms.size(); i++){
				if (rightPrograms.get(i).getValue() == p) {
					leftPrograms.add(new SelectOption(rightPrograms.get(i).getValue(),
						rightPrograms.get(i).getLabel()));
					rightPrograms.remove(i);
					break;
				}
			}
		}
		updateProgramSelections();
	}

	public void updateProgramSelections(){
		List<String> selectedAliases = new List<String>();
		for (SelectOption so : rightPrograms){
			selectedAliases.add(so.getValue());
		}

		pbsList.clear();
		for (Service_Assignment__c serviceAssignment: [
				SELECT Id, Person_Being_Served__r.Account.Lastname,
				       Person_Being_Served__r.Account.Firstname
				  FROM Service_Assignment__c
				 WHERE Service_Location__r.Alias__c In :selectedAliases
				 ORDER BY Person_Being_Served__r.Account.Lastname,
				          Person_Being_Served__r.Account.Firstname
		]) {
			pbsList.add(
				new SelectOption(
					serviceAssignment.Id,
					serviceAssignment.Person_Being_Served__r.Account.Lastname + ', ' + serviceAssignment.Person_Being_Served__r.Account.Firstname
				)
			);
		}
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
		if (selectedPbs.size() == 0) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'You must choose at least 1 Person Being Served'
			));
		}
		if (errorFound) {
			return;
		}
		shiftDocs = [
			SELECT Id, Name, ServiceAssignment__r.Admission__r.Person_Being_Served__c,
			       OwnerId, Shift_Start_Time__c, Shift_End_Time__c, Status__c, ServiceAssignment__c
			  FROM Evaluation__c
			 WHERE Shift_Start_Time__c <= :endDate.addDays(1)
			   AND Shift_End_Time__c >= :startDate
			   AND ServiceAssignment__c IN :selectedPBS
			   AND ((Status__c = 'Draft' AND RecordType.Name = 'CMShiftAssessment')
			        OR ((Status__c = 'Draft' OR Status__c = 'Un-Approved') AND RecordType.Name = 'CNA Workbook'))
		];
		reportRan = true;
	}
}