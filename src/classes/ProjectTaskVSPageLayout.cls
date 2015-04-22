public with sharing class ProjectTaskVSPageLayout {
    public Project_Task__c projTask {get; set;}
    public ProjectTaskVSPageLayout(ApexPages.StandardController controller) {
        projTask = (Project_Task__c) controller.getRecord();       
    }
    public pageReference CheckForRD(){
        if(projTask.Project__r.RecordType.DeveloperName=='Neuro_Restorative'){
            PageReference ref = new PageReference('/apex/proj_nr_form?id=' + projTask.Project__r.id + '&gotoID=' + projTask.id);            
            return ref;
    }
        return null;
    }
    
    
    

}