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
		for (Admission__c[] admissions: [ SELECT Id, (SELECT Id, Interval__c FROM Assessments__r WHERE Assessment_Type__r.Name = 'CANS' AND Past_Due_Date__c = true AND Disregard__c = false ORDER BY Assessment_Date__c DESC, CreatedDate DESC LIMIT 1) FROM Admission__c ]) {
			for (Admission__c admission: admissions) {
				if (admission.Assessments__r != null && admission.Assessments__r.size() > 0 && admission.Assessments__r[0].Interval__c != 'Discharge') {
					assessmentIds.add(admission.Assessments__r[0].Id);
				}
			}
		}
		// We can't just assign the query result to the assessments variable,
		// because that result is ridiculously big and we will run into the
		// governer limit extremely quickly. This is a workaround for that issue.
		listWrapper = new List<List<Assessment__c>>();
		Integer totalCounter = 0;
		Integer listCounter = 0;
		for (Assessment__c[] assessments: [ SELECT Id, Name, Admission__r.Person_Being_Served__r.Name, Admission__r.Person_Being_Served__r.Owner.Name, Admission__r.Person_Being_Served__r.Owner.Id, Assessment_Date__c, Owner.Name, Owner.Id FROM Assessment__c WHERE Id IN :assessmentIds ]) {
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
}