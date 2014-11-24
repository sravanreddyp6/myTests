public with sharing class CatalogSelector extends CatalogBase {
    public Action_Plan__c actionPlanForCtlgSel{get; set;}
    public String curCtlg {get; set;}
    public List<SelectOption> ctlgs{get; set;}
    
    public CatalogSelector(ApexPages.StandardController controller) {
        actionPlanForCtlgSel = (Action_Plan__c)controller.getRecord();
        
        List<Clinical_Programs__c> allPrgms = Clinical_Programs__c.getall().values();
        List<service_location__c> serLocatios = [select id, Service_Value__c from service_location__c where Alias__c = :actionPlanForCtlgSel.Service_Assignment__r.Alias__c];
        String serVal = serLocatios[0].Service_Value__c.substring(0,3);
        ctlgs = new List<SelectOption>();
        ctlgs.add(new SelectOption('',''));

        Set<SelectOption> ctlgsNew = new Set<SelectOption>();
                
        List<Clinical_Catalog_Program__c> ctlgWithPrgms = [select id, Name, Clinical_Catalog__r.id,Clinical_Catalog__r.Catalog_Name__c, Program_Custom_Setting__c from Clinical_Catalog_Program__c];
        for (Clinical_Catalog_Program__c ctlgWithPrgm :ctlgWithPrgms){
        	for (Clinical_Programs__c prgm :allPrgms){
	            if (prgm.ProgramID__c == ctlgWithPrgm.Program_Custom_Setting__c && prgm.Program_Name__c.contains(serVal) ){
	            	ctlgsNew.add(new SelectOption(ctlgWithPrgm.Clinical_Catalog__r.id, ctlgWithPrgm.Clinical_Catalog__r.Catalog_Name__c));
	                break;
	            }
            }
        }
        
        for (SelectOption op :ctlgsNew){
        	ctlgs.add(op);
        }        
        
/*        
        for (Clinical_Catalog__c c : [select id, Catalog_Name__c from Clinical_Catalog__c]){
             for (Clinical_Programs__c p :allPrgms){
                if (prg.Program_Custom_Setting__c == p.ProgramID__c && p.Program_Name__c.contains('ABI') ){
                    isABI = true;
                    break;
                }
                ctlgs.add(new SelectOption(c.id,c.Catalog_Name__c));
        }
    }
*/
        
    }



    public pageReference refreshHere(){
        if(curCtlg != null){
            curr_catalog = [select id, Catalog_Name__c from Clinical_Catalog__c where id = :curCtlg];
            retrieveAllGoals();
        }
        return null; 
    }



}