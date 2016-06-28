public with sharing class TmnProvider {
	public Tmn_Provider__c provider { get; set; }
	private transient ApexPages.StandardController standardController;

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

	public TmnProvider(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Name'
			});
		}
		this.provider = (Tmn_Provider__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
		this.similarProviders = new List<Tmn_Provider__c>();

		if (this.provider.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else {
			// This is a new Provider
			this.mode = 'new';
		}
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