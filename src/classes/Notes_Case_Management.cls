public with sharing class Notes_Case_Management implements AuthenticatedAction {
	public Progress_Note__c progressNote;

	public Boolean isEditMode { get; set; }

	public Notes_Case_Management() {
		// Only here for authenticated handler
	}

	public Notes_Case_Management(ApexPages.StandardController controller) {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		this.progressNote = (Progress_Note__c) controller.getRecord();
		if (this.progressNote.Id == null) {
			Service_Assignment__c serviceAssignment = [
				SELECT Id, Admission__c, Admission__r.Person_Being_Served__c
				FROM Service_Assignment__c
				WHERE Id=:params.get('saId')
			];
			this.progressNote.Service_Assignment__c = serviceAssignment.Id;
			this.progressNote.Admission__c = serviceAssignment.Admission__c;
			this.progressNote.Person_Being_Served__c = serviceAssignment.Admission__r.Person_Being_Served__c;
			this.progressNote.RecordTypeid = [SELECT id FROM RecordType where DeveloperName='Case_Management_Note' and SobjectType='Progress_Note__c' limit 1].id;
			this.progressNote.Status__c = 'Draft';
			this.progressNote.Start_Time__c = DateTime.now().addDays(-10);
			this.progressNote.End_Time__c = DateTime.now().addDays(-9);
		}

		isEditMode = this.progressNote.Id == null || (params.containsKey('mode') && params.get('mode') == 'edit');
		System.debug('Progress Note: ' + this.progressNote);
	}

	public PageReference save() {
		upsert this.progressNote;
		PageReference page = new PageReference('/apex/Notes_Case_Management?id=' + this.progressNote.Id);
		page.setRedirect(true);
		return page;
	}

	public PageReference disregard() {
		this.progressNote.Status__c = 'Disregard';
		return this.save();
	}

	public PageReference cancel() {
		PageReference page;

		if (this.progressNote.Id == null) {
			page = new PageReference('/apex/ServiceAssignmentEditNew?id=' + this.progressNote.Service_Assignment__c + '#caseManagementNotes');
		} else {
			page = new PageReference('/apex/Notes_Case_Management?id=' + this.progressNote.Id);
			page.setRedirect(true);
		}
		return page;
	}

	public PageReference handle(Id recordId, Id userId) {
		System.assertNotEquals(null, recordId);
		Progress_Note__c note = [SELECT Id, Service_Assignment__r.Id FROM Progress_Note__c WHERE Id=:recordId];

		note.Status__c = 'Final';
		note.Approval_Status__c = 'Approved';
		note.Approval_Status_Date__c = Date.Today();
		note.Approval_User__c = UserInfo.getUserId();
		note.Signature_On_File__c = 'Y';
		update note;

		return new PageReference('/apex/Notes_Case_Management?id=' + note.Id);
	}
}