public with sharing class CMShiftAssessmentView {
	 public Evaluation__c evaluation { get; set; }
     public ApexPages.standardController stdController;
     public String selectedTab { get; set; }
	
	public CMShiftAssessmentView(Apexpages.StandardController controller){
		  this.stdController = controller;
		  evaluation = (Evaluation__c) stdController.getRecord();
		  selectedTab = ApexPages.currentPage().getParameters().get('tab');
	}

}