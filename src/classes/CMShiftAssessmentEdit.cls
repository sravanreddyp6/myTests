public with sharing class CMShiftAssessmentEdit {
	public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    
	public CMShiftAssessmentEdit(Apexpages.StandardController controller){
		this.stdController = controller;
		evaluation = (Evaluation__c) stdController.getRecord();
		if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        	}
	}
	
   public PageReference save() {
        return this.save(false);
    }
    
   public PageReference submit() {
        return this.save(true);
    }	
    
   public PageReference changeTab() {
	     System.debug('nextTab: ' + nextTab);
	     // When the user changes tab, we need to save his/her progress on the
	     // previous tab as well. Therefore, if any validation error happens here,
	     // we'll need to keep the user on the previous tab to fix their input
	     // first.
	     if (this.save(false) != null) {
	         System.debug('Save successful!');
	         selectedTab = nextTab;
	     }
	    return null;
 	}
 	
 	public PageReference save(Boolean submitted) {
 		if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {

        }
        update this.evaluation;
        return new PageReference('/apex/CMShiftAssessmentView?id=' + evaluation.Id + '&tab=' + selectedTab);
 	}
}