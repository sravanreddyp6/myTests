@isTest
private class Report_dischargeBacklogController_Test {
	
	static testmethod void myUnitTest(){
		
		TMN_Generic_Core_TestData data = New TMN_Generic_Core_TestData ();
		Progress_Note__c p = TMN_Generic_Core_TestData.createProgressNote(data.theSA,data.theAdm,data.theServiceCode,data.contactID);
		PageReference pageRef = Page.Report_dischargedatabacklog;
		Test.setCurrentPageReference(pageRef);
		Report_dischargeBacklogController controller = new Report_dischargeBacklogController();
		Test.startTest();
		controller.runReport();
		Test.StopTest();
		system.assertEquals(controller.lineItems.size(), 0);
	}
}