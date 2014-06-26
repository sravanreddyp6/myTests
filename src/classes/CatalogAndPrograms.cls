public with sharing class CatalogAndPrograms {
    public static final String CREATE_NEW_PLAN = '[Create New Catalog]';
    public static final String CREATE_NEW_PLAN_CD = 'Create_New_Plan_code';
    
    public String curCtlg {get; set;}
    public Clinical_Catalog__c curr_catalog {get; set;}  
    private List<Clinical_Programs__c> allPrgms {get; set;} 
    
    public List<Programs> prgms {get; set; }
    public List<SelectOption> ctlgs{get; set;}
    
    public CatalogAndPrograms() {
    	allPrgms = Clinical_Programs__c.getall().values();
    	initPlanList();
   }
    
    public pageReference editCatalog(){
        PageReference pg = new PageReference('/apex/catalog_builder_beta?Id=' + curCtlg);
        pg.setRedirect(true);
        return pg; 
    }
  
    public boolean showRes{get; set;}
    
    public pageReference updatePrgAssoc(){
	    upsert curr_catalog;
	    curCtlg = curr_catalog.id;	   
    	
    	List<Clinical_Catalog_Program__c> prgmsToDel = new List<Clinical_Catalog_Program__c>();
    	List<Clinical_Catalog_Program__c> prgmsToInsrt = new List<Clinical_Catalog_Program__c>();
            	
    	for (Programs p :prgms){
            if (p.isSelected && p.selectedPrgm==null){
                Clinical_Catalog_Program__c newRel = new Clinical_Catalog_Program__c();
                newRel.Program_Custom_Setting__c = p.clincalPrgm.ProgramID__c;
                newRel.Clinical_Catalog__c = curr_catalog.id;
            	prgmsToInsrt.add(newRel);
            }
            
            else if(!p.isSelected && p.selectedPrgm!=null){
            	prgmsToDel.add(p.selectedPrgm);
            } 
        }
        delete prgmsToDel;
        insert prgmsToInsrt;
    	prgms = getAllProgramsForCtlg();
    	initPlanList();
        return null;
    }       

    public pageReference refreshHere(){
        if (curCtlg == CREATE_NEW_PLAN_CD){
            curr_catalog = new Clinical_Catalog__c();
	    }
	    else if(curCtlg != null){
	    	curr_catalog = [select id, Catalog_Name__c from Clinical_Catalog__c where id = :curCtlg];
	    }
	    prgms = getAllProgramsForCtlg();
        return null; 
    }    
    
    private List<Programs> getAllProgramsForCtlg(){
        prgms = new List<programs>();        
    
        List<Clinical_Catalog_Program__c> selPrgrms = [select id, Name, Clinical_Catalog__c, Program_Custom_Setting__c 
        from Clinical_Catalog_Program__c where Clinical_Catalog__c = :curCtlg];

        for(Clinical_Programs__c p :allPrgms){
                Programs prog = new Programs();
                prog.clincalPrgm = p;
                for (Clinical_Catalog_Program__c ctlgPrg :selPrgrms){
                    if (ctlgPrg.Program_Custom_Setting__c == p.ProgramID__c){
                        prog.isSelected = true;
                        prog.selectedPrgm = ctlgPrg;
                    	break;
                    }
                }
                prgms.add(prog);
            }
            return prgms;
    }

    private void initPlanList(){
        ctlgs = new List<SelectOption>();
        ctlgs.add(new SelectOption('',''));
        ctlgs.add(new SelectOption(CREATE_NEW_PLAN_CD, CREATE_NEW_PLAN));
        for (Clinical_Catalog__c c : [select id, Catalog_Name__c from Clinical_Catalog__c]){
            ctlgs.add(new SelectOption(c.id,c.Catalog_Name__c));
            }
    }

    public class Programs{
        public Clinical_Programs__c clincalPrgm {get; set;}
        public Boolean isSelected {get; set;}
        public Clinical_Catalog_Program__c selectedPrgm {get; set;}
    }
}