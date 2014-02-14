public with sharing class AdmissionEditExtension {
    public Admission__c admission { get; set; }
    public Boolean showPersonalCard { get; set; }
    public ApexPages.StandardController stdController;
    public AdmissionEditExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        // Salesforce Bug: addFields cannot be called when tests are running:
        // http://bobbuzzard.blogspot.com/2011/04/dynamic-visualforce-bindings-and.html
        if(!Test.isRunningTest()) {
            this.stdController.addFields(new String[] {'Name', 'Effective_Date__c',
                'Status__c', 'Discharged_Date__c',
                'Network_Offering__c', 'Reason_for_Discharge__c', 'State__c',
                'Referred_Out_Date__c', 'Referred_Out_Agency_Name__c', 'Referred_Out_Reason__c',
                'Person_Being_Served__c', 'Discharged_Status__c'});
        }
        this.admission = (Admission__c) stdController.getRecord();
        if ( this.admission.Id == null ) {
	        if (ApexPages.currentPage().getParameters().get('pbsId')==null) {
	            showPersonalCard = false;
	        } else {
	            showPersonalCard = true;
	            this.admission.Person_Being_Served__c = ApexPages.currentPage().getParameters().get('pbsId');
	        }
	        this.admission.Name = '(autofilled on save)';
        } else {
        	showPersonalCard = true;
        
        }
        	
    }
}