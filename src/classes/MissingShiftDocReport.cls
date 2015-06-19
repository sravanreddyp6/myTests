public with sharing class MissingShiftDocReport {
	public Boolean reportRan { get; set; }
	public Day[] days { get; set; }
	// This is a dummy evaluation just so that we can bind inputFields for Start/End Date to an
	// SObject Date fields for SF's datepicker.
	public Evaluation__c dummyEvaluation { get; set; }

	public MissingShiftDocReport() {
		dummyEvaluation = new Evaluation__c();
		days = new Day[] {};
		reportRan = false;
	}

	public void runReport() {
		days = new Day[] {};
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
			SELECT Id, Name, Start_Date__c, Program_Detail__c, Admission__r.Person_Being_Served__c
			  FROM Service_Assignment__c
			 WHERE Status__c = 'Active'
			   AND Start_Date__c <= :endDate
			   AND (End_Date__c >= :startDate OR End_Date__c = null)
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
					d.hasNSD = true;
				} else {
					d.hasCNA = true;
				}
			}
		}
		for (Id saId: saMap.keySet()) {
			Day[] orderedDays = new Day[] {};  // We use this to make sure the result is sorted
			for (Date d: saMap.get(saId).keySet()) {
				Day day = saMap.get(saId).get(d);
				if (!day.hasNSD || !day.hasCNA) {
					orderedDays.add(day);
				}
			}
			orderedDays.sort();
			days.addAll(orderedDays);
		}
		reportRan = true;
	}

	class Day implements Comparable {
		public Service_Assignment__c serviceAssignment { get; set; }
		public Date day { get; set; }
		public Boolean hasCNA { get; set; }
		public Boolean hasNSD { get; set; }

		public Day(Service_Assignment__c serviceAssignment, Date day) {
			this.serviceAssignment = serviceAssignment;
			this.day = day;
			this.hasCNA = false;
			this.hasNSD = false;
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