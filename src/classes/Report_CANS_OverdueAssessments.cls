public with sharing class Report_CANS_OverdueAssessments {
	public List<Assessment__c> assessments { get; set; }

	public Report_CANS_OverdueAssessments() {
		List<Admission__c> admissions = [
			SELECT Id, (
				SELECT Id, Interval__c FROM Assessments__r
				WHERE Assessment_Type__r.Name = 'CANS'
				  AND Past_Due_Date__c = true
				ORDER BY Assessment_Date__c DESC LIMIT 1
			)
			FROM Admission__c
		];
		List<Id> assessmentIds = new List<Id>();
		for (Admission__c admission: admissions) {
			if (admission.Assessments__r != null && admission.Assessments__r.size() > 0 && admission.Assessments__r[0].Interval__c != 'Discharge') {
				assessmentIds.add(admission.Assessments__r[0].Id);
			}
		}
		assessments = [
			SELECT Id, Name, Admission__r.Person_Being_Served__r.Name,
			       Admission__r.Person_Being_Served__r.Owner.Name,
			       Admission__r.Person_Being_Served__r.Owner.Id,
			       Assessment_Date__c, Owner.Name, Owner.Id
			  FROM Assessment__c
			 WHERE Id IN :assessmentIds
		];
	}
}