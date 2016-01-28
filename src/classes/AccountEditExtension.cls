public with sharing class AccountEditExtension {
	public Account acct { get; set; }

	public AccountEditExtension(ApexPages.StandardController stdController) {
		if (!Test.isRunningTest()) {
		  stdController.addFields(new String[] { 'PersonContactID' });
		}
		acct = (Account) stdController.getRecord();
	}
    public PageReference redirectToContact() {
        return new PageReference('/apex/PersonBeingServedEditNew?id=' + acct.PersonContactId + '&edit=true');
    }
}