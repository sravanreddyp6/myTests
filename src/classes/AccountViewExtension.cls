public with sharing class AccountViewExtension {
    public Account acct { get; set; }

    public AccountViewExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
          stdController.addFields(new String[] { 'PersonContactID' });
        }
        acct = (Account) stdController.getRecord();
    }
    public PageReference redirectToContact() {
        return new PageReference('/apex/PersonBeingServedEditNew?id=' + acct.PersonContactId);
    }
}