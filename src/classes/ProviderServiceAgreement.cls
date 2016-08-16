public with sharing class ProviderServiceAgreement {
	public Service_Assignment_Provider_JO__c agreement { get; set; }
	private static transient Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Service_Assignment_Provider_JO__c.getRecordTypeInfosByName();

	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit' || isNewMode;
		}
	}

	public Boolean isNewMode {
		get {
			return this.mode == 'new';
		}
	}

	private transient Boolean isLocked;

	public Boolean getIsLocked() {
		return this.agreement.Status__c != 'In Progress';
	}

	public ProviderServiceAgreement(ApexPages.StandardController standardController) {
		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Disregard__c', 'Tmn_Provider__r.Name'
			});
		}
		this.agreement = (Service_Assignment_Provider_JO__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();

		if (this.agreement.Id != null) {
			this.mode = 'view';
			if (!this.getIsLocked() && params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else {
			// This is a new Agreement
			this.mode = 'new';
			this.agreement.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
			this.agreement.Service_Assignment__c = params.get('saId');
			this.agreement.Service_Assignment__r = [
				SELECT Id, Service_Location__c, Admission__c, Admission__r.Person_Being_Served__c
				  FROM Service_Assignment__c
				 WHERE Id = :this.agreement.Service_Assignment__c
			];
			this.agreement.Status__c = 'In Progress';
		}
	}

	public String getTitle() {
		if (isNewMode) {
			return 'New Provider Service Agreement Association';
		}
		return this.agreement.Tmn_Provider__r.Name;
	}

	public Id chosenProvider {
		get;
		set {
			this.agreement.Tmn_Provider__c = value;
			this.agreement.Tmn_Provider__r = [
				SELECT Id, Name
				  FROM Tmn_Provider__c
				 WHERE Id = :value
			];
		}
	}

	private transient String providerApplicationDates;
	public String getProviderApplicationDates() {
		if (providerApplicationDates != null) {
			return providerApplicationDates;
		}
		TMN_Provider_Application__c[] applications = [
			SELECT Id, Effective_Date__c, Expiration_Date__c
			  FROM TMN_Provider_Application__c
			 WHERE Status__c = 'Approved'
			   AND Provider__c = :agreement.Tmn_Provider__r.Id
			   AND Disqualified__c = false
		];
		String[] providers = new String[]{};
		for (Tmn_Provider_Application__c application: applications) {
			providers.add(application.Effective_Date__c.format() +' - '+ application.Expiration_Date__c.format());
		}
		providerApplicationDates = String.join(providers, ', ');
		return providerApplicationDates;
	}

	public PageReference disregard() {
		this.agreement.Disregard__c = true;
		return this.save(false);
	}

	public PageReference terminate() {
		if (this.agreement.Status__c != 'Active') {
			throw new Utility.CustomException('Only Active Provider Associations can be terminated');
		}
		this.agreement.Status__c = 'Terminated';
		return this.save(true);
	}

	public PageReference finalize() {
		if (this.agreement.Status__c != 'In Progress') {
			throw new Utility.CustomException('Only In Progress Provider Associations can be finalized');
		}
		if (this.agreement.Start_Date__c > Date.today()) {
			this.agreement.Status__c = 'Pending';
		} else if (this.agreement.End_Date__c < Date.today()) {
			this.agreement.Status__c = 'Expired';
		} else {
			this.agreement.Status__c = 'Active';
		}
		return this.save(false);
	}

	public PageReference save() {
		return this.save(true);
	}

	public PageReference save(Boolean validateNeeded) {
		if (validateNeeded && !validate(this.agreement)) {
			return null;
		}
		upsert this.agreement;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.agreement.Id);
		page.setRedirect(true);
		return page;
	}

	public static Boolean validate(Service_Assignment_Provider_JO__c agreement) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (agreement.Tmn_Provider__c == null) {
			agreement.Tmn_Provider__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Start_Date__c == null) {
			agreement.Start_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.End_Date__c == null) {
			agreement.End_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Start_Date__c != null && agreement.End_Date__c != null) {
			if (agreement.Start_Date__c >= agreement.End_Date__c) {
				agreement.End_Date__c.addError('Service Agreement Expiration Date must be later than Service Agreement Effective Date.');
				noError = false;
			} else if (agreement.Tmn_Provider__c != null) {
				Tmn_Provider_Application__c[] relevantApplications = [
					SELECT Id
					  FROM TMN_Provider_Application__c
					 WHERE Status__c = 'Approved'
					   AND Disqualified__c = false
					   AND Provider__c = :agreement.Tmn_Provider__c
					   AND Effective_Date__c <= :agreement.Start_Date__c
					   AND Expiration_Date__c >= :agreement.End_Date__c
					 LIMIT 1
				];
				if (relevantApplications.size() == 0) {
					agreement.End_Date__c.addError('Service Agreement Date range must fall completely within the Approval Date range of an Approved Provider Application.');
					noError = false;
				}
			}
		}
		if (agreement.Status__c == 'Terminated') {
			if (agreement.Termination_Date__c == null) {
				agreement.Termination_Date__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (agreement.Termination_Reason__c == null || agreement.Termination_Reason__c == '') {
				agreement.Termination_Reason__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
		}
		return noError;

	}
}