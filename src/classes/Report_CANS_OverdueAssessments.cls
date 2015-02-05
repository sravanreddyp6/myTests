public with sharing class Report_CANS_OverdueAssessments {
	public transient List<List<Assessment__c>> listWrapper { get; set; }
	public String baseUrl {
		get {
			return System.URL.getSalesforceBaseUrl().toExternalForm();
		}
	}

	public Report_CANS_OverdueAssessments() {
		List<Id> assessmentIds = new List<Id>();
		// The following data set can be very large, so we iterate it in the
		// way that Salesforce recommended
		// HCANS-23 - Update logic for entry inclusion in the report
		for (Admission__c[] admissions: [ SELECT Id, (SELECT Id, Assessment_Date__c, Disregard__c, Interval__c, Status__c FROM Assessments__r WHERE Assessment_Type__r.Name = 'CANS' ORDER BY CreatedDate DESC) FROM Admission__c ]) {
			for (Admission__c admission: admissions) {
				if (admission.Assessments__r != null && admission.Assessments__r.size() > 0) {
					System.debug('Assessment__r: ' + admission.Assessments__r);
					System.debug('Assessment__r size: ' + admission.Assessments__r.size());
					if (isIncludedInReport(admission.Assessments__r, 0, false)) {
						assessmentIds.add(admission.Assessments__r[0].Id);
					}
				}
			}
		}
		// We can't just assign the query result to the assessments variable,
		// because that result is ridiculously big and we will run into the
		// governer limit extremely quickly. This is a workaround for that issue.
		listWrapper = new List<List<Assessment__c>>();
		Integer totalCounter = 0;
		Integer listCounter = 0;
		for (Assessment__c[] assessments: [ SELECT Id, Name, Admission__r.Person_Being_Served__r.Name, Admission__r.Person_Being_Served__r.Owner.Name, Admission__r.Person_Being_Served__r.Owner.Id, Assessment_Date__c, Owner.Name, Owner.Id, Status__c, Disregard__c FROM Assessment__c WHERE Id IN :assessmentIds ]) {
			for (Assessment__c assessment: assessments) {
				listCounter = totalCounter / 999;
				System.debug('List Counter: ' + listCounter);
				System.debug('Listwrapper size: ' + listWrapper.size());
				if (listWrapper.size() <= listCounter) {
					listWrapper.add(new List<Assessment__c>());
				}
				listWrapper[listCounter].add(assessment);
				totalCounter += 1;
			}
		}
	}

	// Recursive function to determine whether an assessment should be included
	// in the report or not
	private Boolean isIncludedInReport(Assessment__c[] assessments, Integer index, Boolean resultSoFar) {
		System.debug('index: ' + index);
		if (assessments.size() < index + 1) {
			return resultSoFar;
		}
		if (assessments[index].Disregard__c) {
			// Recursively checking whether the next assessment within the last
			// 90 days should make the PBS appear in the report or not
			return isIncludedInReport(assessments, index + 1, resultSoFar);
		}
		// At this point we know the assessment is not disregarded
		if (assessments[index].Status__c != 'Locked') {
			return isIncludedInReport(assessments, index + 1, true);
		}
		// At this point we know the assessment is not disregarded and has been
		// finalized
		if (assessments[index].Interval__c == 'Discharge') {
			return false;
		}
		// At this point we know the assessment is not disregarded, has been
		// finalized and is not a discharge assessment
		if (assessments[index].Assessment_Date__c.daysBetween(Date.Today()) < 90) {
			return false;
		}
		return isIncludedInReport(assessments, index + 1, true);
	}
}