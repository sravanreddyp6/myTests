public with sharing class TmnProviderApplication {
	public Tmn_Provider_Application__c application { get; set; }
	private transient ApexPages.StandardController standardController;
	private static transient Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Tmn_Provider_Application__c.getRecordTypeInfosByName();

	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit';
		}
	}

	private transient Boolean isLocked;

	public Boolean getIsLocked() {
		if (this.isLocked == null) {
			this.isLocked = this.application.Status__c != 'Pending Approval';
		}
		return this.isLocked;
	}

	public String getTitle() {
		if (isEditMode && this.application.Id == null) {
			return 'Create New Application';
		}
		return this.application.Name;
	}

	public PageReference redirectNew() {
		// Redirect to the new Provider page if necessary
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (!params.containsKey('applicantId') && this.application.Id == null) {
			return Page.TmnProvider;
		}
		return null;
	}

	public TmnProviderApplication(ApexPages.StandardController standardController) {
		this.standardController = standardController;

		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Name'
			});
		}

		this.application = (Tmn_Provider_Application__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();

		if (this.application.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else if (params.containsKey('applicantId')) {
			// This is a new Application
			this.mode = 'edit';
			this.application.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
			this.application.Status__c = 'Pending Approval';
			this.application.Provider__c = params.get('applicantId');

			Tmn_Provider__c provider = [
				SELECT Id, Address_Street_1__c, Address_Street_2__c, City__c, State__c, Zip__c,
				       Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c, First_Name__c, Middle_Name__c,
				       Last_Name__c, Gender__c, SPD_Number__c, eXPRS_Number__c,
				       (SELECT Id FROM Tmn_Provider_Applications__r)
				  FROM Tmn_Provider__c
				 WHERE Id = :this.application.Provider__c
			];
			this.application.Address_Street_1__c = provider.Address_Street_1__c;
			this.application.Address_Street_2__c = provider.Address_Street_2__c;
			this.application.City__c = provider.City__c;
			this.application.State__c = provider.State__c;
			this.application.Zip__c = provider.Zip__c;
			this.application.Phone_1__c = provider.Phone_1__c;
			this.application.Phone_2__c = provider.Phone_2__c;
			this.application.Fax__c = provider.Fax__c;
			this.application.Primary_Email__c = provider.Primary_Email__c;

			if (provider.Tmn_Provider_Applications__r.size() == 0) {
				this.application.Enrollment_Type__c = 'New';
			} else {
				this.application.Enrollment_Type__c = 'Re-Enrollment';
			}

			this.application.Provider__r = provider;
		}
	}

	public PageReference save() {
		return this.save(true);
	}

	public PageReference approve() {
		String originalStatus = this.application.Status__c;
		this.application.Status__c = 'Approved';
		PageReference pageRef = this.save(true);
		if (pageRef == null) {
			this.application.Status__c = originalStatus;
		}
		return pageRef;
	}

	public PageReference disqualify() {
		if (application.Reason_for_Disqualification__c == '' || application.Reason_for_Disqualification__c == null) {
			application.Reason_for_Disqualification__c.addError('Field is required');
			return null;
		}
		String originalStatus = this.application.Status__c;
		this.application.Status__c = 'Disqualified';
		PageReference pageRef = this.save(false);
		if (pageRef == null) {
			this.application.Status__c = originalStatus;
		}
		return pageRef;
	}

	public PageReference save(Boolean validateNeeded) {
		if (validateNeeded && !validate(this.application)) {
			return null;
		}
		upsert this.application;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.application.Id);
		page.setRedirect(true);
		return page;
	}

	private static Boolean validate(Tmn_Provider_Application__c application) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (application.Enrollment_Type__c == '' || application.Enrollment_Type__c == null) {
			application.Enrollment_Type__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (application.Status__c == '' || application.Status__c == null) {
			application.Status__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		} else if (application.Status__c == 'Disqualified' && (application.Reason_for_Disqualification__c == null || application.Reason_for_Disqualification__c == '')) {
			application.Reason_for_Disqualification__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		return noError;
	}
}