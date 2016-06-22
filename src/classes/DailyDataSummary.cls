public with sharing class DailyDataSummary {
	
    public DailyDataSummary() {
    }
    public PageReference redirect() {
        String saId = ApexPages.currentPage().getParameters().get('saId');
        String serviceDate = ApexPages.currentPage().getParameters().get('serviceDate');
        list<Service_Assignment__c> servAssign = [Select Id, Name, Service_location__r.state__c, Service_location__r.Network_Offering__c, Service_location__r.Alias_lookup__r.Alias_Operating_Group__c from Service_Assignment__c where Id =: saId];
        if (servAssign.size() != 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid Service Assignment.'));
            return null;
        } else if (servAssign[0].Service_location__r.Alias_lookup__r.Alias_Operating_Group__c.equalsIgnoreCase('Redwood') && 
                    servAssign[0].Service_location__r.state__c == 'IA'){
            return new PageReference('/apex/IowaDailyDataSummary?saId=' + saId + '&serviceDate=' + serviceDate);
        } else if (servAssign[0].Service_location__r.Alias_lookup__r.Alias_Operating_Group__c.equalsIgnoreCase('Redwood') && 
                    servAssign[0].Service_location__r.state__c == 'OH' && 
                    'IDD'.equalsIgnoreCase(servAssign[0].Service_location__r.Network_Offering__c)) {
            return new PageReference('/apex/OhioDailyDataSummary?saId=' + saId + '&serviceDate=' + serviceDate);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Daily Data Summary feature is not available for this service offering.'));
            return null;
        }
    }
}