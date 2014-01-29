public with sharing class MentorViewAllController {
    public TMN_Contact__c contact { get; set; }

    public MentorViewAllController(ApexPages.standardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new String[] {'Mentor__c', 'RecordType.Name'});
        }
        contact = (TMN_Contact__c) stdController.getRecord();
    }

    public PageReference routeRequest() {
        // If a request is made to a non-mentor record (e.g. a Co-applicant),
        // reroute that request to the main Mentor page and go to Household
        // Member section.
        System.debug('Contact: ' + contact);
        if (contact.RecordType.Name.indexOf('Mentor') == -1) {
            PageReference ref = new PageReference('/apex/MentorView?id=' + contact.Mentor__c);
            ref.setAnchor('householdMembers');
            return ref;
        }
        return new PageReference('/apex/MentorView?id=' + contact.Id);
    }
}