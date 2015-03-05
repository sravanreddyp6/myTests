@isTest
public with sharing class CMShiftAssessmentListViewControllerTest {
	
	static testmethod void simpleTests(){
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		List<Evaluation__c> evals = new List<Evaluation__c>();
		For(integer i=0; i<10; i++){
			Evaluation__c e = new Evaluation__c();
			e.Status__c = 'Draft';
			e.ServiceAssignment__c = testData.theSA.Id;
			evals.add(e);
		}
		
		insert evals;
		
		PageReference pageRef = Page.CMShiftAssessmentListView;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('saId', testData.theSA.Id);
		CMShiftAssessmentListViewController controller = new CMShiftAssessmentListViewController();
		system.assert(controller.evaluations.size() > 0);
		controller.toggleSort();
		system.assert(controller.evaluations.size() > 0);
		 
		
	}

}