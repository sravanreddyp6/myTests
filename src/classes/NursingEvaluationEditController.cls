public with sharing class NursingEvaluationEditController {
	public Evaluation__c evaluation { get; set; }
	public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    public Related_Party__c[] relatedParties { set;
        get {
            return [
                SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                       Phone_2__c, Phone_2_Type__c, Comments__c
                FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.Admission__r.Person_Being_Served__r.Id
            ];
        }
    }
    
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }
    
    public Related_Party__c currentRelatedParty { get; set; }
    public Id currentRelatedPartyId { get; set; }
    
    
    public NursingEvaluationEditController(ApexPages.StandardController stdcontroller) {
    	this.stdController = stdController;
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

    /**
     * This method needs to know about whether the request is ready for submission,
     * and also the currently selected tab, because we need to group validation
     * on both the online form and the paper form in one place.
     */
    public PageReference save(Boolean submitted) {
        // All the validation goes here, partitioned by page. We can't do
        // object-level validation, because if there are 2 errors on 2 pages,
        // the user won't be able to save at all.
        if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {

        }
        update this.evaluation;
        //update this.pbr;
        //return stdController.view();
        return new PageReference('/apex/CareMeridianEvaluationView?id=' + evaluation.Id + '&tab=' + selectedTab);
    }
    

}