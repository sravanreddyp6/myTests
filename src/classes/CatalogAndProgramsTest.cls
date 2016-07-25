@isTest
private class CatalogAndProgramsTest {

    static testMethod void myUnitTest() {
    	createData();
    	CatalogAndPrograms cp = new CatalogAndPrograms();
    	system.AssertEquals(cp.ctlgs.size(), 3);
    	
    	string ctlg = [select id from Clinical_Catalog__c limit 1].id ;
    	cp.curCtlg = ctlg;
    	system.AssertEquals(cp.editCatalog().getUrl().contains('/apex/catalog_builder_beta?Id=' + ctlg), true );	
    }
    
    static testMethod void updatePrgAssocUnitTest() {
    	createData();
    	CatalogAndPrograms cp = new CatalogAndPrograms();
    	string ctlg = [select id from Clinical_Catalog__c limit 1].id ;
    	cp.curCtlg = ctlg;
    	
    	cp.refreshHere();
    	
    	cp.prgms.get(0).isSelected = true;
    	cp.updatePrgAssoc();
    	system.AssertEquals([select id from Clinical_Catalog_Program__c].size(), 1);
    	
    	cp.prgms.get(0).isSelected = false;
    	cp.updatePrgAssoc();
    	system.AssertEquals([select id from Clinical_Catalog_Program__c].size(), 0);
    	
    }
    
    static void createData(){
    	
    	insert (new Clinical_Programs__c(ProgramID__c = 1, Program_Name__c='IDD', Name ='IDD'));
    	insert (new Clinical_Catalog__c(Catalog_Name__c='Catalog One'));
    	
    	
    }
    
    
}