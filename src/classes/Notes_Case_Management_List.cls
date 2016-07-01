public with sharing class Notes_Case_Management_List {
	public Progress_Note__c[] caseManagementNotes { get; set; }
	public Id saId { get; set; }
	public Id admissionId { get; set; }
	public Id pbsId { get; set; }

	public Notes_Case_Management_List(ApexPages.StandardController controller) {
		Service_Assignment__c serviceAssignment = [
			SELECT Id, Admission__c, Admission__r.Person_Being_Served__c
			FROM Service_Assignment__c
			WHERE Id=:ApexPages.currentPage().getParameters().get('saId')
		];
		this.saId = serviceAssignment.Id;
		this.admissionId = serviceAssignment.Admission__c;
		this.pbsId = serviceAssignment.Admission__r.Person_Being_Served__c;
		caseManagementNotes = [
			SELECT name, id, createddate, CreatedBy.Name, CreatedBy.Id, status__c
			  FROM Progress_Note__c
			 WHERE Service_Assignment__c = :saId
			   AND RecordType.Name = 'Case Management Note'
			ORDER BY CreatedDate DESC
		];
	}
}