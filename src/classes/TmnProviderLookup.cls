public with sharing class TmnProviderLookup {
	public Boolean searchInitiated { get; set; }
	public Tmn_Provider__c[] providers { get; set; }

	public Tmn_Provider__c dummyProvider { get; set; }  // We use this record to set bindings only

	public Boolean approvedProvidersOnly { get; set; }
	public Id brokerageRestriction { get; set; }

	public TmnProviderLookup() {
		this.searchInitiated = false;
		this.dummyProvider = new Tmn_Provider__c();
	}

	public PageReference search() {
		this.providers = new Tmn_Provider__c[]{};

		// For use in the query
		String gender = dummyProvider.Gender__c;
		String firstName = dummyProvider.First_Name__c;
		String lastName = dummyProvider.Last_Name__c;

		String[] criterias = new String[]{};
		String nameCriteria = HomePageSearchController.buildCriteria(dummyProvider.Last_Name__c, dummyProvider.First_Name__c, 'Last_Name__c', 'First_Name__c');
		if (nameCriteria != '()') {
			criterias.add(nameCriteria);
		}
		if (gender != null && gender != '') {
			criterias.add('Gender__c = :gender');
		}
		if (brokerageRestriction != null) {
			criterias.add('Brokerage__c = :brokerageRestriction');
		}
		if (approvedProvidersOnly) {
			criterias.add('Status__c = \'Approved\'');
		}

		String criteria;
		if (criterias.size() > 0) {
			criteria = ' WHERE ' + String.join(criterias, ' AND ');
		}

		String query =
			'SELECT Id, Name, Gender__c' +
			'  FROM Tmn_Provider__c' +
			(criteria != null ? criteria : '');
		system.debug(query);

		providers = Database.query(query);

		searchInitiated = true;
		return null;
	}
}