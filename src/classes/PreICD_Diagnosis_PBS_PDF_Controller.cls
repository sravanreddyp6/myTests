public with sharing class PreICD_Diagnosis_PBS_PDF_Controller {
	
	public list<Diagnosis__c> diagnosis {get; set;}
    
    public PreICD_Diagnosis_PBS_PDF_Controller(){
        
        diagnosis = new List<Diagnosis__c>();
        diagnosis = [SELECT Id, Effective_Date__c,Primary_Diagnosis__c,Secondary_Diagnosis__c,Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c,Comments__c FROM Diagnosis__c WHERE Service_Assignment__r.Person_being_served__c = :Apexpages.currentpage().getparameters().get('id')];
        
        
    }
	

}