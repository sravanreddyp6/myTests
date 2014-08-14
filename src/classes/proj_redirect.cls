public with sharing class proj_redirect {
    public project__c cur_proj {get; set;}
    public proj_redirect(ApexPages.StandardController controller) {
        cur_proj = (Project__c)controller.getRecord();
    }
    public pageReference gotoProjPage(){
        string RT = ApexPages.currentPage().getParameters().get('RecordType');
        string myID = ApexPages.currentPage().getParameters().get('ID');
        if(RT == '012Z00000004rbS'){
            PageReference ref = new PageReference('/apex/proj_nr_form');           
            return ref;
        }
        if(myID != null){
        if(cur_proj.recordtype.DeveloperName =='Neuro_Restorative'){
            PageReference ref = new PageReference('/apex/proj_nr_form?id=' + myID);           
            return ref;        
        
        }
            PageReference ref = new PageReference('/apex/Project_VS_Page_Layout?id=' + myID);           
            return ref;  
        }                  
        return null;
    }
}