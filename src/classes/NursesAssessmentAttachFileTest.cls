@isTest
private class NursesAssessmentAttachFileTest {
	static testmethod void attachTest(){
		pageReference pageRef = Page.NursesAssessmentEsignPostBack;
		Test.setCurrentPage(pageRef);
		
		TMN_Generic_Core_TestData testdata = new TMN_Generic_Core_TestData();
		Evaluation__c evaluation = new Evaluation__c();
		evaluation.ServiceAssignment__c = testdata.theSA.Id;
		insert evaluation;
		
		NursesAssessmentAttachFile controller = new NursesAssessmentAttachFile();
		ApexPages.currentPage().getParameters().put('id', evaluation.Id);
		ApexPages.currentPage().getParameters().put('img', 'SGVsbG8gV29ybGQ=');
		controller.upload();
		system.assertNotEquals(0,[SELECT ID FROM Attachment WHERE ParentId = :testdata.theSA.Id].size());
	}

}