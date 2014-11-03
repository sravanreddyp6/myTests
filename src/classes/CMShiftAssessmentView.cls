public with sharing class CMShiftAssessmentView {
	 public Evaluation__c evaluation { get; set; }
     public ApexPages.standardController stdController;
     public String selectedTab { get; set; }
     
     public List<selectOption>copingValues ;
     public List<string>selectedCoping {get;set;}
     
     public string getprimaryPhysician(){
    	List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
    	if(rp.size()>0) return rp[0].Name;
    	else return null;
    }
	
	public CMShiftAssessmentView(Apexpages.StandardController controller){
		  this.stdController = controller;
		  evaluation = (Evaluation__c) stdController.getRecord();
		  selectedTab = ApexPages.currentPage().getParameters().get('tab');
		  copingValues = new List<selectOption>();
		  selectedCoping = new List<String>();
		  
		  if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
				selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');
	}
	
	 public List<selectoption> getcopingValues(){
   		List<Selectoption> copingValue = Utility.getPicklistValues(evaluation, 'Resident_Demonstrating_Issues__c');
   		return copingValue; 
   }

}