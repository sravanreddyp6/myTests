public with sharing class Assessment_RiskForm_Redirect {
    
    public Assessment__c assessment { get; set; }
    public Evaluation__c eval;
    PageReference ref;
    
    public Assessment_RiskForm_Redirect(ApexPages.StandardController controller) {
       assessment = (Assessment__c) controller.getRecord();   
       assessment = [SELECT Id, Name, Type__c, Assessment_Type__r.Name, Evaluation__c FROM Assessment__c WHERE Id=:assessment.Id]; // Using Explicit Query here as all the users are not expected to have FLS on Evaluation__c field - Sravan -04/28/2015  
       if(String.isNotBlank(string.valueOf(assessment.Evaluation__c))){
       		eval = [SELECT Id, RecordType.Name FROM Evaluation__c WHERE Id=: assessment.Evaluation__c];
       }
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
        if (assessment.type__c == 'Resident Assessment' || assessment.type__c == 'Restraint Reduction') {
            ref = new PageReference('/'+eval.Id); // To include all Types of Evaluations - Evaluation View Controller will decide the redirection
            return ref;       
        }         
        return null;
    } 
    //this is if the user clicked the edit link
    public PageReference assessmentRedirectEdit() {
        string prefix = string.valueof(assessment.id);
        prefix = prefix.left(3);
        if (assessment.Assessment_Type__r.name == 'CANS') {
            PageReference ref = new PageReference('/' + prefix + '/e?id='+ assessment.id +'&retURL=/' + assessment.id);            
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