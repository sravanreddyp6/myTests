@isTest
private class CMShiftAssessmentViewTest {

	private static testmethod void myTests() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		Evaluation__c eval = new Evaluation__c ();
		eval.ServiceAssignment__c = testData.theSA.Id;
		insert eval;
	}
}