public with sharing class catalog_builder_beta extends CatalogBase {
    public list<Clinical_Catalog_Tree_Node__c > currentInsertedNodes {get; set;}
    //this tree will be used in the form for selected a goal to related an objective to as well as objectives to relate actions to.
    public TMN_Tree formTree {get; set;}
    
    public Clinical_Catalog_Element__c CurEley {get; set;}
    public Clinical_Catalog_Tree_Node__c CurTreeNode {get; set;}
    //keys returned by the fancy tree comp are stored here
    public string selectedKeys{get; set;}
    //used on the edit link to pass the Catalog Elemnt ID
    public string eleyID {get; set;}
    public string curTreeNodeKey {get; set;}    
    
    public List<SelectOption> pickList {get; set;}
    public boolean ctlgHasABI {get; set;}
    
    public catalog_builder_beta(ApexPages.StandardController controller) {
        curr_catalog = (Clinical_Catalog__c)controller.getRecord();
        
        if (curr_catalog == null){
            curr_catalog = new Clinical_Catalog__c();	
        }        
        selectedKeys ='';
        CurEley = new Clinical_Catalog_Element__c ();
        currentInsertedNodes = new list<Clinical_Catalog_Tree_Node__c >();
        ctlgCmpntTypes();
        retrieveAllGoals();
    }
    public pageReference upsertCatalog(){
        upsert curr_catalog;
        return null;
    }  
    
    public pageReference editTreeNode(){
    	eleyID = [select Catalog_Element__r.id from Clinical_Catalog_Tree_Node__c Where name =:curTreeNodeKey].Catalog_Element__r.id;
        CurEley = [select name, id, Type__c, Description__c, status__c from Clinical_Catalog_Element__c Where id =:eleyID];
        refreshFormTree();
        return null;
    }
    
    public pageReference newEley(){
        CurEley = new Clinical_Catalog_Element__c ();
        CurEley.Status__c = 'Active';
        return null;
    }
    
    
    
       
public pageReference upsertEley(){

    upsert CurEley;
    CurEley = [select name, id, Type__c, Description__c, status__c from Clinical_Catalog_Element__c Where id =:CurEley.id];
    string curEleyType = CurEley.Type__c;
    
    list<Clinical_Catalog_Tree_Node__c > NewNodes = new list<Clinical_Catalog_Tree_Node__c >();
    list<Clinical_Catalog_Tree_Node__c > PurgeNodes = new list<Clinical_Catalog_Tree_Node__c >();
        
    if(curEleyType == 'Goal' && currentInsertedNodes.size() == 0){
        Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
        newNode.Catalog__c = curr_catalog.id;
        newNode.Catalog_Element__c = CurEley.id;
        newNode.ID_Goal__c = integer.valueof(CurEley.name);
        newNode.ID_Objective__c = 0;
        newNode.ID_Action__c = 0;
        NewNodes.add(newNode); 
    }
    
    //import the keys the fancy tree gave us
    list<string> items = new list<string>();
    items = selectedKeys.split(',');        
    formTree.inputSelectedKeys(items, true);  
    //loop over goals  
    
    for(TMN_Tree.node n :formTree.root.nodes){
        //check for pre-exsiting join
        if(curEleyType == 'Objective'){
            boolean hasRecord = false;
            for(Clinical_Catalog_Tree_Node__c selN :currentInsertedNodes ){
                if(selN.name == n.CatTreeNode.name){
                    hasRecord = true;
                    if(!n.isSelected){ PurgeNodes .add(selN);}
                }
            }
            if(!hasRecord && n.isSelected){
                    Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
                    newNode.Catalog__c = curr_catalog.id;
                    newNode.Catalog_Element__c = CurEley.id;
                    newNode.ID_Goal__c = n.CatTreeNode.ID_Goal__c;
                    newNode.ID_Objective__c = integer.valueof(CurEley.name);
                    newNode.ID_Action__c = 0;
                    NewNodes.add(newNode);
            }
            
        }
        // loop over objectives when
        if(curEleyType == 'Action'){
            for(TMN_Tree.node o :n.nodes) {
                boolean hasRecord = false;
                for(Clinical_Catalog_Tree_Node__c selN :currentInsertedNodes ){
                    if(selN.name == o.CatTreeNode.name){
                        hasRecord = true;
                        if(!o.isSelected){ PurgeNodes.add(selN);}
                    }
                }
                if(!hasRecord && o.isSelected){
                        Clinical_Catalog_Tree_Node__c newNode = new Clinical_Catalog_Tree_Node__c();
                        newNode.Catalog__c = curr_catalog.id;
                        newNode.Catalog_Element__c = CurEley.id;
                        newNode.ID_Goal__c = o.CatTreeNode.ID_Goal__c;
                        newNode.ID_Objective__c = o.CatTreeNode.ID_Objective__c;
                        newNode.ID_Action__c = integer.valueof(CurEley.name);
                        NewNodes.add(newNode);
                } 
            }               
        }                    
    }    

    
    list<Clinical_Catalog_Tree_Node__c > inactivateNodes = new list<Clinical_Catalog_Tree_Node__c >();    
    
    if (CurEley.status__c == 'Inactive') {
	    for (Clinical_Catalog_Tree_Node__c n :nodes){
            if(curEleyType == 'Goal' && n.ID_Goal__c.toPlainString() == CurEley.name && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }
            if(curEleyType == 'Objective' && n.ID_Objective__c.toPlainString() == CurEley.name && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }
            if(curEleyType == 'Action' && n.ID_Action__c.toPlainString()== CurEley.name && n.Status__c == 'Active'){
                inactivateNodes.add(n);
            }            
        }        
        for (Clinical_Catalog_Tree_Node__c inActNd :inactivateNodes) {
            	inActNd.Status__c = 'Inactive';
        }
        upsert inactivateNodes;        
    }    
    
    /*
    if(curEleyType == 'Objective'){
    nodes = [select id, name, Catalog_Element__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, ID_Goal__c, ID_Objective__c, ID_Action__c  from Clinical_Catalog_Tree_Node__c Where Catalog__r.id =:curr_catalog.id AND Catalog_Element__r.type__c = 'Action' ];
       for(Clinical_Catalog_Tree_Node__c action :nodes){
           for(Clinical_Catalog_Tree_Node__c purge :PurgeNodes){           
               if((action.ID_Goal__c == purge.ID_Goal__c)&& (action.ID_Objective__c == purge.ID_Objective__c)){
                   PurgeNodes.add(action);
               }           
           } 
       }
    }
    */
    insert NewNodes;
    delete PurgeNodes;
    CurEley = new Clinical_Catalog_Element__c ();
    retrieveAllGoals();
    return null;
}

public list<Clinical_Catalog_Tree_Node__c > updateSelected(id eID){
    list<Clinical_Catalog_Tree_Node__c> tmpLst2 = new list<Clinical_Catalog_Tree_Node__c>();
    tmpLst2 = [select id, name, ID_Goal__c, ID_Objective__c, ID_Action__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, status__c from Clinical_Catalog_Tree_Node__c Where Catalog_Element__r.id =:eid AND Catalog__c =:curr_catalog.id Order By name ];
    return tmpLst2;

}
    public pageReference refreshFormTree(){
    	    formTree = new TMN_Tree();
            list<Clinical_Catalog_Tree_Node__c> curActive = updateSelected(CurEley.id);
            currentInsertedNodes = curActive;
            system.debug('here -' + curActive );
            list<string> myType = new list<string>();
            string curEleyType = CurEley.Type__c;
            if(curEleyType  == 'Action'){
                myType.add('Objective');
                myType.add('Goal');
            }
            if(curEleyType  == 'Objective'){
                myType.add('Goal');
            }        
            if(curEleyType  == 'Goal'){
                return null;
            }
                
        list<Clinical_Catalog_Tree_Node__c> tmpNodes = new list<Clinical_Catalog_Tree_Node__c>(); 
        tmpNodes = [select id, name, ID_Goal__c, ID_Objective__c, ID_Action__c, Catalog_Element__r.name, Catalog_Element__r.type__c, Catalog_Element__r.description__c, status__c from Clinical_Catalog_Tree_Node__c Where Catalog_Element__r.type__c in :mytype AND Catalog__c =:curr_catalog.id Order By ID_Goal__c , ID_Objective__c , ID_Action__c ];
        
        
        string goalID ='';
        string objID ='';
        for(Clinical_Catalog_Tree_Node__c n: tmpNodes ){            
            string thisEleType = n.Catalog_Element__r.type__c;
            string thisID = n.name;
            string thisTitle = n.Catalog_Element__r.description__c;
            
            if(thisEleType == 'Goal'){
                TMN_Tree.node g_node= new TMN_Tree.node(thisID , thisTitle );
                g_node.CatTreeNode = n;
                //an action is related to an objective, the goal checkbox needs to be deactivated
                if(curEleyType =='Action'){
                    g_node.hideCheckbox = true;
                    g_node.isFolder = true;
                }
                if(curEleyType =='Objective' ){
                    for(Clinical_Catalog_Tree_Node__c selectedN: curActive ){
                        if(n.ID_Goal__c == selectedN.ID_Goal__c){
                            g_node.CatTreeNode = selectedN;
                            g_node.isSelected = true;
                        }
                    }
                }
                formTree.root.nodes.add(g_node);
                goalID = thisID ;
            }
        
            if(thisEleType == 'Objective'){
                TMN_Tree.node o_node= new TMN_Tree.node(thisID , thisTitle );
                o_node.CatTreeNode = n;
                if(curEleyType =='Action' ){
                    for(Clinical_Catalog_Tree_Node__c selectedN: curActive ){
                        if((n.ID_Goal__c == selectedN.ID_Goal__c)&&(n.ID_Objective__c == selectedN.ID_Objective__c)){
                                o_node.CatTreeNode = selectedN;
                                o_node.isSelected = true;
                            }
                        }
                 }                    
                 integer g_key = allGoals.root.getNode_Key(goalID );
                 formTree.root.nodes.get(g_key).nodes.add(o_node);
                 objID = thisID ;
            }
        }              
        selectedKeys = formTree.GetSelectedNodeStr;
        return null;
    }
    
    private void ctlgCmpntTypes(){
        pickList = new List<SelectOption>();
        pickList.add(new SelectOption('','--None--'));
        ctlgHasABI = isABIpresent(); 
        if (ctlgHasABI){
	        pickList.add(new SelectOption('Goal','Problem'));
	        pickList.add(new SelectOption('Objective','Goal'));
	        pickList.add(new SelectOption('Action','Intervention'));        	
        } else {
            pickList.add(new SelectOption('Goal','Goal'));
            pickList.add(new SelectOption('Objective','Objective'));
            pickList.add(new SelectOption('Action','Action'));
        }
    }
    
    private boolean isABIpresent(){
        boolean isABI = false;
        List<Clinical_Catalog_Program__c> selPrgrms = [select id, Name, Clinical_Catalog__c, Program_Custom_Setting__c from Clinical_Catalog_Program__c where Clinical_Catalog__c = :curr_catalog.Id];
        List<Clinical_Programs__c> allPrgms = Clinical_Programs__c.getall().values();

        for (Clinical_Catalog_Program__c prg :selPrgrms){
            for (Clinical_Programs__c p :allPrgms){
                if (prg.Program_Custom_Setting__c == p.ProgramID__c && p.Program_Name__c.contains('ABI') ){
                    isABI = true;
                    break;
                }
            }
            if (isABI){
                break;
            }
        }
        return isABI;
    }
    
}