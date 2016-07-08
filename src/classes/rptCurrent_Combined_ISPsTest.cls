@isTest
private class rptCurrent_Combined_ISPsTest {

    static testMethod void simpleTest() {
    	TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
    	
        Case_Management_Plan__c plan = new Case_Management_Plan__c();
        plan.Name = 'Test plan 1';
        plan.Service_Assignment__c = testData.theSA.id;
        plan.Status__c = 'Active Final';
        insert plan;
        
        rptCurrent_Combined_ISPs report = new rptCurrent_Combined_ISPs();
        
        list<Case_Management_Plan__c> rptData = report.rptData;
        
        system.assertEquals(1, rptData.size());
    }
}