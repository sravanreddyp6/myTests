public with sharing class TmnProviderLookup {
	public Boolean searchInitiated { get; set; }
	public Tmn_Provider__c[] providers { get; set; }

	public TmnProviderLookup() {
		this.searchInitiated = false;
	}

	public PageReference search() {
		this.providers = new Tmn_Provider__c[]{};

		searchInitiated = true;
		return null;
	}
}