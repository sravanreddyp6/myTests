public with sharing class CatalogSelector {
    public Action_Plan__c ActionPlan;
    public String curCtlg {get; set;}
    public Clinical_Catalog__c curr_catalog {get; set;}    
    public List<SelectOption> ctlgs{get; set;}
    public TMN_Tree allGoals {get; set;}
    
    public CatalogSelector(ApexPages.StandardController controller) {
        ActionPlan = (Action_Plan__c)controller.getRecord();
        
        ctlgs = new List<SelectOption>();
        ctlgs.add(new SelectOption('',''));
        for (Clinical_Catalog__c c : [select id, Catalog_Name__c from Clinical_Catalog__c]){
                ctlgs.add(new SelectOption(c.id,c.Catalog_Name__c));
            }
    }


    public pageReference refreshHere(){
    	List<Clinical_Catalog_Tree_Node__c> nodes;
    	allGoals = new TMN_Tree();
    	
        if(curCtlg != null){
            curr_catalog = [select id, Catalog_Name__c from Clinical_Catalog__c where id = :curCtlg];
            nodes = [select id, name, Catalog_Element__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, ID_Goal__c, ID_Objective__c, ID_Action__c, Status__c  from Clinical_Catalog_Tree_Node__c Where Catalog__r.id =:curr_catalog.id Order By ID_Goal__c , ID_Objective__c , ID_Action__c ];
            
	        string goalID ='';
	        string objID ='';
	        for(Clinical_Catalog_Tree_Node__c n: nodes){            
	            string curEleType = n.Catalog_Element__r.type__c;
	            string curID = n.name;
	            string title = n.Catalog_Element__r.description__c;
	            
	            if(curEleType == 'Goal'){
	                TMN_Tree.node g_node= new TMN_Tree.node(curID, title);
	                g_node.CatTreeNode = n;
	                g_node.isFolder = true;
	                allGoals.root.nodes.add(g_node);
	                goalID =curID;
	            }
        
	            if(curEleType == 'Objective'){
	                TMN_Tree.node o_node= new TMN_Tree.node(curID, title);
	                o_node.CatTreeNode = n;
	                integer g_key = allGoals.root.getNode_Key(goalID );
	                allGoals.root.nodes.get(g_key).nodes.add(o_node);
	                objID =curID;
	            }
            
	            if(curEleType == 'Action'){                
	                TMN_Tree.node a_node= new TMN_Tree.node(curID, title);
	                a_node.CatTreeNode = n;
	                integer g_key = allGoals.root.getNode_Key(goalID );
	                integer o_key = allGoals.root.nodes.get(g_key).getNode_Key(objID);
	                if(o_key != -1){
	                    allGoals.root.nodes.get(g_key).nodes.get(o_key).nodes.add(a_node);
	                }
                }                          
            }
        }
        return null; 
    }

}