@isTest
private class rptCurrent_Combined_ISPsTest {

	@testsetup
	static void setupData () {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

    	List<RecordType> rt = [ select id from Recordtype where sobjecttype = 'Case_Management_Plan__c' and developername = 'OR_Combined_ISP' ];
    	system.assertEquals(1, rt.size());
    		
        Case_Management_Plan__c plan = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        plan.Name = 'Test plan 1';
        plan.Service_Assignment__c = testData.theSA.id;
        plan.Status__c = 'Active Final';
        insert plan;
        
        plan = new Case_Management_Plan__c( recordtypeID = rt[0].Id);
        plan.Name = 'Test plan 2';
        plan.Service_Assignment__c = testData.theSA.id;
        plan.Status__c = 'Inactive Draft';
        insert plan;
        
        plan = new Case_Management_Plan__c(recordtypeID = rt[0].Id);
        plan.Name = 'Test plan 3';
        plan.Service_Assignment__c = testData.theSA.id;
        plan.Status__c = 'Inactive Final';
        insert plan;
        
        

	}
    static testMethod void simpleTest() {
    	
        rptCurrent_Combined_ISPs report = new rptCurrent_Combined_ISPs();
        
        list<Case_Management_Plan__c> rptData = report.rptData;
        
        system.assertEquals(2, rptData.size());
    }


}