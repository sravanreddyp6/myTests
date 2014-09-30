public with sharing class Assessment_CANSdetail_Ex {
    assessment__c assess = new assessment__c();
    public Assessment_CANSdetail_Ex(ApexPages.StandardController controller) {
        assess= (assessment__c)controller.getRecord();
        id adminID = apexpages.currentpage().getparameters().get('admission');
        assess.Admission__c = adminID ;
        assess.Assessment_Type__c = apexpages.currentpage().getparameters().get('type');
        
        assess.accountperson__c = [select id, Person_Being_Served__r.Accountid from admission__c where id = :adminID].Person_Being_Served__r.Accountid;
        
    }

}