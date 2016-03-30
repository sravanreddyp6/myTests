@isTest
public with sharing class PlanTriggeredActionsTests {
    static testmethod void simpleTests() {
    
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
                
        Plan__c plan = new Plan__c(Admission__c = myData.theAdm.id);
        insert plan;
        update plan;
        delete plan;
        undelete plan;
    }
}