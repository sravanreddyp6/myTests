public with sharing class Assessment_RiskForm_Redirect {
	
	public Assessment__c assessment { get; set; }

    PageReference ref;
    
    public Assessment_RiskForm_Redirect(ApexPages.StandardController controller) {
       assessment = (Assessment__c) controller.getRecord();       
    }

    public PageReference assessmentRedirect() {
        if (assessment.Assessment_Type__r.name == 'CANS') {
            PageReference ref = new PageReference('/apex/AssessmentView?id=' + assessment.id);            
            return ref;
        }
        
        if (assessment.Assessment_Type__r.name == 'Risk') {
            PageReference ref = new PageReference('/apex/Assessment_RiskForm?id=' + assessment.id);           
            return ref;
        }        
       
        if (assessment.type__c == 'FAD Summary') {
            ref = new PageReference('/apex/Assessment_FAD_Form?id=' + assessment.id);
            return ref;       
        }
       
        if (assessment.type__c == 'ISSA') {
            ref = new PageReference('/apex/Assessment_IssaForm?id=' + assessment.id);
            return ref;       
        }      
        
        return null;

    } 

}