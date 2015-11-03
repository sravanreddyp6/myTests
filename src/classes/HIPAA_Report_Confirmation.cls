public with sharing class HIPAA_Report_Confirmation {
	public Task task { get; set; }
	public Boolean isEditMode { get; set; }
	public Attachment attachment { get; set; }

	public HIPAA_Report_Confirmation(ApexPages.StandardController controller) {
		this.task = (Task) controller.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();
		this.isEditMode = (params.containsKey('mode') && params.get('mode') == 'edit');
		this.attachment = new Attachment(ParentId=this.task.Id);
	}

	public PageReference checkEditMode() {
		if (isEditMode && (this.task.Status == 'Approved' || this.task.Status == 'Rejected')) {
			// Make sure the user cannot edit an approved or rejected task
			PageReference page = new PageReference('/apex/HIPAA_Report_Confirmation?id=' + this.task.Id);
			page.setRedirect(true);
			return page;
		}
		if (!isEditMode) {
			Attachment[] attachments = [SELECT Id, Name FROM Attachment WHERE ParentId=:this.task.Id];
			if (attachments.size() != 0) {
				this.attachment = attachments[0];
			}
		}
		return null;
	}

	public PageReference save() {
		if (this.attachment.name == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attachment is required'));
			return null;
		}
		if (this.task.Status != 'Approved' && this.task.Status != 'Rejected') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required'));
			this.task.Status = 'Not Approved';
			return null;
		}
		if (this.task.Status == 'Rejected') {
			if (this.task.Description == '' || this.task.Description == null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment is required'));
				return null;
			} else if (this.task.Description != null && this.task.Description.length() < 20) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment must be longer than 20 characters'));
				return null;
			}
		}
		insert this.attachment;
		update this.task;
		PageReference page = new PageReference('/apex/HIPAA_Report_Confirmation?id=' + this.task.Id);
		page.setRedirect(true);
		return page;
	}

	public PageReference cancel() {
		PageReference page = new PageReference('/apex/Home');
		page.setRedirect(true);
		return page;
	}
}