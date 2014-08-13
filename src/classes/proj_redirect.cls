public with sharing class proj_redirect {
    public project__c cur_proj {get; set;}
    public proj_redirect(ApexPages.StandardController controller) {
        cur_proj = (Project__c)controller.getRecord();
    }
    public pageReference gotoProjPage(){
        if(cur_proj.recordtype.DeveloperName =='Neuro_Restorative'){
            PageReference ref = new PageReference('/apex/proj_nr_form?id=' + cur_proj.id);           
            return ref;        
        
        }
            PageReference ref = new PageReference('/apex/Project_VS_Page_Layout?id=' + cur_proj.id);           
            return ref;
                    
        return null;
    }

}