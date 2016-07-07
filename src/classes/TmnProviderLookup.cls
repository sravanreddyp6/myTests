public with sharing class TmnProviderLookup {
	public Boolean searchInitiated { get; set; }
	public Tmn_Provider__c[] providers { get; set; }

	public Boolean approvedProvidersOnly { get; set; }
	public Id brokerageRestriction { get; set; }

	public String firstName { get; set; }
	public String lastName { get; set; }
	public String gender { get; set; }
	public Id brokerage { get; set; }
	public String agencyName { get; set; }
	public String servicesProvided { get; set; }

	private transient List<SelectOption> brokerageOptions;
	public List<SelectOption> getBrokerageOptions() {
		if (brokerageOptions != null) {
			return brokerageOptions;
		}
		brokerageOptions = new List<SelectOption>();
		Service_Location__c[] locations = [
			SELECT Id, Name, ProgramId__c, Location_Nickname__c
			  FROM Service_Location__c
			 WHERE State__c = 'OR'
			   AND Service_Type__c = 'CM - Case Management'
			 ORDER BY ProgramId__c
		];
		for (Service_Location__c location: locations) {
			brokerageOptions.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
		}
		return brokerageOptions;
	}

	private transient List<SelectOption> genderOptions;
	public List<SelectOption> getGenderOptions() {
		if (genderOptions != null) {
			return genderOptions;
		}
		genderOptions = new List<SelectOption>();
		Schema.PicklistEntry[] entries = Tmn_Provider__c.Gender__c.getDescribe().getPicklistValues();
		for (Schema.PicklistEntry entry: entries) {
			genderOptions.add(new SelectOption(entry.getLabel(), entry.getValue()));
		}
		return genderOptions;
	}

	public TmnProviderLookup() {
		this.searchInitiated = false;
	}

	public PageReference search() {
		this.providers = new Tmn_Provider__c[]{};

		String[] criterias = new String[]{};
		String nameCriteria = HomePageSearchController.buildCriteria(lastName, firstName, 'Last_Name__c', 'First_Name__c');
		if (nameCriteria != '()') {
			criterias.add(nameCriteria);
		}
		if (gender != null && gender != '') {
			criterias.add('Gender__c = :gender');
		}
		if (brokerageRestriction != null) {
			criterias.add('Brokerage__c = :brokerageRestriction');
		} else if (brokerage != null) {
			criterias.add('Brokerage__c = :brokerage');
		}

		if(agencyName != null && agencyName != '') {
			criterias.add('Company_Agency_Name__c LIKE \'%' + agencyName + '%\'');
		}

		if (approvedProvidersOnly) {
			criterias.add('Status__c = \'Approved\'');
		}

		String criteria;
		if (criterias.size() > 0) {
			criteria = ' WHERE ' + String.join(criterias, ' AND ');
		}

		String query =
			'SELECT Id, Name, Gender__c, Services_Provided__c, Company_Agency_Name__c, Brokerage__r.ProgramId__c, Brokerage__r.Location_Nickname__c' +
			'  FROM Tmn_Provider__c' +
			(criteria != null ? criteria : '') +
			' ORDER BY LastModifiedDate DESC' +
			' LIMIT 100';
		system.debug(query);

		providers = Database.query(query);

		if(servicesProvided != null && servicesProvided != '') {
			// Since we cannot filter long text area in SOQL, we'll have to do this the hard way...
			Tmn_Provider__c[] filteredProviders = new Tmn_Provider__c[]{};
			for (Tmn_Provider__c provider: providers) {
				if (provider.Services_Provided__c != null && provider.Services_Provided__c.indexOf(servicesProvided) != -1) {
					filteredProviders.add(provider);
				}
			}
			providers = filteredProviders;
		}

		searchInitiated = true;
		return null;
	}
}