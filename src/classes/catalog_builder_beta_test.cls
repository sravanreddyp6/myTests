@isTest
private class catalog_builder_beta_test {
    
    @isTest static void test_method_one() {
        Clinical_Catalog__c Catalog = new Clinical_Catalog__c();
        //Clinical_Catalog_Element__c Eley1 = new Clinical_Catalog_Element__c();
        //Clinical_Catalog_Tree_Node__c Node1 = new Clinical_Catalog_Tree_Node__c(Type__c = 'Action');
        
        insert Catalog;
        ApexPages.StandardController sc = new ApexPages.StandardController(Catalog);  
        catalog_builder_beta ClassInTest = new catalog_builder_beta (sc);
        
        
        ClassInTest.refreshFormTree(); //selectedKeys = '';
        ClassInTest.newEley();
        ClassInTest.CurEley.Type__c = 'Goal';
        ClassInTest.upsertEley();
        ClassInTest.refreshFormTree();

        ApexPages.StandardController sc2 = new ApexPages.StandardController(Catalog);  
        catalog_builder_beta ClassInTest2 = new catalog_builder_beta (sc2);
        string goalKey  = [select name, id, Type__c, Description__c, status__c from Clinical_Catalog_Element__c limit 1].name;
        string eleyKey = [select name, id from Clinical_Catalog_Tree_Node__c limit 1].name;      
        
        ClassInTest2.curTreeNodeKey = eleyKey;
        ClassInTest2.editTreeNode();
        
        ClassInTest2.newEley();
        ClassInTest2.CurEley.Type__c = 'Objective';
        ClassInTest2.upsertEley();  
                
        ClassInTest2.selectedKeys = goalKey;
        ClassInTest2.newEley();
        ClassInTest2.CurEley.Type__c = 'Objective';
        ClassInTest2.upsertEley(); 
        ClassInTest2.refreshFormTree();
//ClassInTest.ctlgCmpntTypes();
       // ClassInTest.upsertCatalog();
    }
    

    
}