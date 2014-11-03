public with sharing class CMShiftAssessmentEdit {
	public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    
    public List<selectOption>copingValues ;
    public List<string>selectedCoping {get;set;}
    
    public string getprimaryPhysician(){
    	List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
    	if(rp.size()>0) return rp[0].Name;
    	else return null;
    }
    
	public CMShiftAssessmentEdit(Apexpages.StandardController controller){
		this.stdController = controller;
		evaluation = (Evaluation__c) stdController.getRecord();
		if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        	}
        	
        copingValues = new List<selectOption>();
        selectedCoping = new List<String>();
        if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
               selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');
                
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
        // For Resident Coping Well Multi-Picklist
                string cpg ='';
                for(string cp: selectedCoping)
                cpg += cp+';';
                        if(cpg!=''){
                                cpg = cpg.Substring(0,cpg.length()-1);
                                this.evaluation.Resident_Demonstrating_Issues__c = cpg;
                        } 
                        else
                        this.evaluation.Resident_Demonstrating_Issues__c ='';
        update this.evaluation;
        return new PageReference('/apex/CMShiftAssessmentView?id=' + evaluation.Id + '&tab=' + selectedTab);
 	}
 	
 	public List<selectoption> getcopingValues(){
                List<Selectoption> copingValue = Utility.getPicklistValues(evaluation, 'Resident_Demonstrating_Issues__c');
                return copingValue; 
   }
}