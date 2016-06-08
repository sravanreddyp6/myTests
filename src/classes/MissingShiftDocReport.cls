public with sharing class MissingShiftDocReport {
	public Boolean reportRan { get; set; }
	public transient List<List<Day>> days { get; set; }
	// This is a dummy evaluation just so that we can bind inputFields for Start/End Date to an
	// SObject Date fields for SF's datepicker.
	public Evaluation__c dummyEvaluation { get; set; }

	public List<String> leftSelectedPrograms { get; set; }
	public List<SelectOption> leftPrograms { get; set; }
	public List<String> rightSelectedPrograms { get; set; }
	public List<SelectOption> rightPrograms { get; set; }
	public List<Id> selectedPBS { get; set; }
	public List<SelectOption> pbsList { get; set; }

	public MissingShiftDocReport() {
		dummyEvaluation = new Evaluation__c();
		days = new List<List<Day>>();

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
		days = new List<List<Day>>();
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
		if (endDate == null) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'End Date cannot be blank.')
			);
		}
		if (startDate != null && endDate != null && startDate > endDate) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'Start Date cannot be later than End Date.')
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
		// This is how it works: first it looks for all the active service assignments within the
		// date range, then it looks for all the existing non-disregarded NSD & CNA within that
		// date range. Afterwards we build a list of dates/SAs that lack the documentations.
		Set<Date> dateRange = new Set<Date>();
		for (Date i=startDate; i<=endDate; i=i.addDays(1)) {
			dateRange.add(i);
		}

		Map<Id, Map<Date, Day>> saMap = new Map<Id, Map<Date, Day>>();
		for (Service_Assignment__c serviceAssignment: [
			SELECT Id, Name, Start_Date__c, Program_Detail__c,
			       Admission__r.Person_Being_Served__r.Id, Admission__r.Person_Being_Served__r.Name
			  FROM Service_Assignment__c
			 WHERE Status__c = 'Active'
			   AND Start_Date__c <= :endDate
			   AND (End_Date__c >= :startDate OR End_Date__c = null)
			   AND Id IN :selectedPbs
		]) {
			saMap.put(serviceAssignment.Id, new Map<Date, Day>());
			for (Date day: dateRange) {
				saMap.get(serviceAssignment.Id).put(day, new Day(serviceAssignment, day));
			}
		}

		for (Evaluation__c evaluation: [
			SELECT Id, ServiceAssignment__r.Id, Shift_Start_Time__c, Shift_End_Time__c,
			       RecordType.Name
			  FROM Evaluation__c
			 WHERE (RecordType.Name = 'CMShiftAssessment' OR RecordType.Name = 'CNA Workbook')
			   AND Shift_Start_Time__c <= :endDate.addDays(1)
			   AND Shift_End_Time__c >= :startDate
			   AND Status__c != 'Disregard'
		]) {
			if (!saMap.containsKey(evaluation.ServiceAssignment__r.Id)) {
				continue;
			}
			Date shiftStartDate = evaluation.Shift_Start_Time__c.date();
			Date shiftEndDate = evaluation.Shift_End_Time__c.date();
			for (Date i=shiftStartDate; i<=shiftEndDate; i=i.addDays(1)) {
				if (!dateRange.contains(i)) {
					continue;
				}
				Day d = saMap.get(evaluation.ServiceAssignment__r.Id).get(i);
				if (evaluation.RecordType.Name == 'CMShiftAssessment') {
					d.numNsdDone++;
				} else {
					d.numCnaDone++;
				}
			}
		}
		Integer totalCounter = 0;
		Integer listCounter = 0;

		for (Id saId: saMap.keySet()) {
			Day[] orderedDays = new Day[] {};  // We use this to make sure the result is sorted
			for (Date d: saMap.get(saId).keySet()) {
				Day day = saMap.get(saId).get(d);
				if (day.numNsdDone == 0 || day.numCnaDone == 0) {
					orderedDays.add(day);
				}
			}
			orderedDays.sort();
			for (Day day: orderedDays) {
				// We can't just add all the things in orderedDays to another list
				// because that result is ridiculously big and we will run into the
				// governer limit extremely quickly. This is a workaround for that issue.
				listCounter = totalCounter / 999;
				if (days.size() <= listCounter) {
					days.add(new List<Day>());
				}
				days[listCounter].add(day);
				totalCounter += 1;
			}
		}
		reportRan = true;
	}

	class Day implements Comparable {
		public Service_Assignment__c serviceAssignment { get; set; }
		public Date day { get; set; }
		public Integer numCnaDone { get; set; }
		public Integer numNsdDone { get; set; }

		public Day(Service_Assignment__c serviceAssignment, Date day) {
			this.serviceAssignment = serviceAssignment;
			this.day = day;
			this.numCnaDone = 0;
			this.numNsdDone = 0;
		}

		public Integer compareTo(Object anotherDayObj) {
			Day anotherDay = (Day) anotherDayObj;
			if (this.day > anotherDay.day) {
				return 1;
			} else if (this.day == anotherDay.day) {
				return 0;
			} else {
				return -1;
			}
		}
	}

}