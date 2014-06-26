public with sharing class CatalogSelector extends CatalogBase {
    public Action_Plan__c ActionPlan;
    public String curCtlg {get; set;}
    public List<SelectOption> ctlgs{get; set;}
    
    public CatalogSelector(ApexPages.StandardController controller) {
        ActionPlan = (Action_Plan__c)controller.getRecord();
        
        ctlgs = new List<SelectOption>();
        ctlgs.add(new SelectOption('',''));
        for (Clinical_Catalog__c c : [select id, Catalog_Name__c from Clinical_Catalog__c]){
                ctlgs.add(new SelectOption(c.id,c.Catalog_Name__c));
            }
    }

    public pageReference refreshHere(){
        if(curCtlg != null){
            curr_catalog = [select id, Catalog_Name__c from Clinical_Catalog__c where id = :curCtlg];
            retrieveAllGoals();
        }
        return null; 
    }



}