public with sharing class TmnProvider {
	public static final Id TASK_RECORD_TYPE = Schema.SObjectType.Task.getRecordTypeInfosByName()
		.get('Tmn Provider Application').getRecordTypeId();

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

	private transient Boolean updateable;
	public Boolean getUpdateable() {
		if (updateable == null) {
			updateable = Schema.sObjectType.Tmn_Provider__c.isUpdateable();
		}
		return updateable;
	}

	private transient Boolean applicationUpdateable;
	public Boolean getApplicationUpdateable() {
		if (applicationUpdateable == null) {
			applicationUpdateable = Schema.sObjectType.Tmn_Provider_Application__c.isUpdateable();
		}
		return applicationUpdateable;
	}

	private transient Boolean applicationCreateable;
	public Boolean getApplicationCreateable() {
		if (applicationCreateable == null) {
			applicationCreateable = Schema.sObjectType.Tmn_Provider_Application__c.isCreateable();
		}
		return applicationCreateable;
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
		AssociationAccess access = new AssociationAccess(this.provider.Id);
		associations = access.associations;
		return associations;
	}

	public Tmn_Provider_Application__c[] applications { get; set; }
	public Tmn_Provider_Application__c currentDisqualifiableApplication { get; set; }
	public Id currentPendingApplicationId { get; set; }

	public TmnProvider(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Name', 'Brokerage__c'
			});
		}
		this.provider = (Tmn_Provider__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
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
				if (application.Status__c == 'Approved' && !application.Disqualified__c && currentDisqualifiableApplication == null) {
					currentDisqualifiableApplication = application;
				}
				if (application.Status__c == 'Pending Approval') {
					if (!application.Disqualified__c) {
						this.currentPendingApplicationId = application.Id;
					}
					currentDisqualifiableApplication = application;
				}
			}
		} else {
			// This is a new Provider
			this.mode = 'new';
			this.provider.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
		}
	}

	public PageReference disqualify() {
		if (!TmnProviderApplication.validateDisqualifiedApplication(this.currentDisqualifiableApplication)) {
			return null;
		}
		this.currentDisqualifiableApplication.Disqualified__c = true;
		if (this.currentDisqualifiableApplication.Status__c == 'Pending Approval') {
			this.currentDisqualifiableApplication.Status__c = 'Disqualified';
		}
		upsert currentDisqualifiableApplication;

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
			((gender != null && gender != '') ? '   AND Gender__c = :gender' : '');
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
		return noError;
	}

	// Since we only need to display the associations, this class is here to get the association
	// records without having to specify sharing rules for them.
	public without sharing class AssociationAccess {
		public Service_Assignment_Provider_JO__c[] associations { get; set; }
		public AssociationAccess(Id providerId) {
			associations = [
				SELECT Id, Name, Status__c, Services_Provided__c, Start_Date__c, End_Date__c,
				       Service_Assignment__r.Name
				  FROM Service_Assignment_Provider_JO__c
				 WHERE Tmn_Provider__c = :providerId
				 ORDER BY CreatedDate DESC
			];
		}
	}
}