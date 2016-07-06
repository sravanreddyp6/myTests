public with sharing class TmnProvider {
	public Tmn_Provider__c provider { get; set; }
	private transient ApexPages.StandardController standardController;
	private static transient Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Tmn_Provider__c.getRecordTypeInfosByName();

	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			System.debug(this.mode);
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
		return false;
	}

	public List<Tmn_Provider__c> similarProviders { get; set; }

	public String getTitle() {
		if (isEditMode && this.provider.Id == null) {
			return 'New Applicant';
		}
		return this.provider.Name;
	}

	private transient List<SelectOption> brokerageOptions;

	public List<SelectOption> getBrokerageOptions() {
		if (brokerageOptions != null) {
			return brokerageOptions;
		}
		brokerageOptions = new List<SelectOption>();
		Service_Location__c[] locations = [
			SELECT Id, Name, ProgramId__c, Location_Nickname__c
			  FROM Service_Location__c
			 WHERE State__c = :Schema.SObjectType.Tmn_Provider__c.getRecordTypeInfosById().get(this.provider.RecordTypeId).getName()
			   AND Service_Type__c = 'CM - Case Management'
			 ORDER BY ProgramId__c
		];
		System.debug(locations);
		for (Service_Location__c location: locations) {
			brokerageOptions.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
		}
		return brokerageOptions;
	}

	private transient String brokerage;
	public String getBrokerage() {
		if (brokerage != null) {
			return brokerage;
		}
		if (this.provider.Brokerage__c == null) {
			brokerage = 'N/a';
		} else {
			Service_Location__c location = [
				SELECT Id, Name, ProgramId__c, Location_Nickname__c
				  FROM Service_Location__c
				 WHERE Id = :this.provider.Brokerage__c
			];
			brokerage = location.ProgramId__c + ' - ' + location.Location_Nickname__c;
		}
		return brokerage;
	}

	private transient Service_Assignment_Provider_JO__c[] associations;

	public Service_Assignment_Provider_JO__c[] getAssociations() {
		if (associations != null) {
			return associations;
		}
		associations = [
			SELECT Id, Name, Status__c, Services_Provided__c, Start_Date__c, End_Date__c,
			       Service_Assignment__r.Name
			  FROM Service_Assignment_Provider_JO__c
			 WHERE Tmn_Provider__c = :this.provider.Id
			 ORDER BY CreatedDate DESC
		];
		return associations;
	}

	public Tmn_Provider_Application__c[] applications { get; set; }
	public Tmn_Provider_Application__c currentApprovedApplication { get; set; }

	public Boolean hasPendingApplication { get; set; }

	public TmnProvider(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Name'
			});
		}
		this.provider = (Tmn_Provider__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
		this.hasPendingApplication = false;
		this.similarProviders = new List<Tmn_Provider__c>();

		this.applications = new Tmn_Provider_Application__c[]{};

		if (this.provider.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
			this.applications = [
				SELECT Id, Name, Status__c, Effective_Date__c, Expiration_Date__c, Disqualified__c,
				       Disqualification_Date__c, Reason_for_Disqualification__c
				  FROM Tmn_Provider_Application__c
				 WHERE Provider__c = :this.provider.Id
				 ORDER BY CreatedDate DESC
			];
			for (Tmn_Provider_Application__c application: applications) {
				if (application.Status__c == 'Approved' && !application.Disqualified__c && currentApprovedApplication == null) {
					currentApprovedApplication = application;
				}
				if (application.Status__c == 'Pending Approval') {
					this.hasPendingApplication = true;
				}
			}
		} else {
			// This is a new Provider
			this.mode = 'new';
			this.provider.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
		}
	}

	public PageReference disqualify() {
		if (!TmnProviderApplication.validateDisqualifiedApplication(this.currentApprovedApplication)) {
			return null;
		}
		this.currentApprovedApplication.Disqualified__c = true;
		upsert currentApprovedApplication;

		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.provider.Id);
		page.setRedirect(true);
		return page;
	}

	public PageReference save() {
		Boolean dedupeNeeded = false;
		if (isNewMode) {
			dedupeNeeded = true;
		}
		PageReference saveRef = this.save(true, dedupeNeeded);
		if (saveRef != null && isNewMode) {
			saveRef = Page.TmnProviderApplication;
			saveRef.getParameters().put('applicantId', this.provider.Id);
		}
		return saveRef;
	}

	public PageReference saveWithoutDedupe() {
		PageReference saveRef = this.save(true, false);
		if (saveRef != null && isNewMode) {
			saveRef = Page.TmnProviderApplication;
			saveRef.getParameters().put('applicantId', this.provider.Id);
		}
		return saveRef;
	}

	public PageReference save(Boolean validateNeeded, Boolean dedupeNeeded) {
		if (validateNeeded && !validate(this.provider)) {
			return null;
		}
		if (dedupeNeeded) {
			this.similarProviders = dedupe(this.provider);
			if (this.similarProviders.size() != 0) {
				return null;
			}
		}
		upsert this.provider;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.provider.Id);
		page.setRedirect(true);
		return page;
	}

	private static List<Tmn_Provider__c> dedupe(TMN_Provider__c provider) {
		String gender = provider.Gender__c;  // for use in the query
		String query =
			'SELECT Id, Name, First_Name__c, Last_Name__c, Gender__c, (SELECT Id, Name FROM Tmn_Provider_Applications__r WHERE Status__c = \'Pending Approval\')' +
			'  FROM Tmn_Provider__c' +
			' WHERE ' + HomePageSearchController.buildCriteria(provider.Last_Name__c, provider.First_Name__c, 'Last_Name__c', 'First_Name__c') +
			'   AND Gender__c = :gender';
		system.debug(query);
		return Database.query(query);
	}

	private static Boolean validate(Tmn_Provider__c provider) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (provider.First_Name__c == '' || provider.First_Name__c == null) {
			provider.First_Name__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (provider.Last_Name__c == '' || provider.Last_Name__c == null) {
			provider.Last_Name__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (provider.Gender__c == '' || provider.Gender__c == null) {
			provider.Gender__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		return noError;
	}
}