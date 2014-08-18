public with sharing class proj_nr_activity_rpt {
    
    public TMN_Tree allData {get; set;}
    
    public proj_nr_activity_rpt(ApexPages.StandardController controller) {
        TMN_Tree allData = new TMN_Tree();
        runRpt();
    }
    
    public pagereference RunRpt(){
        allData = new TMN_Tree();
        set<id> projIDs = new set<id>();
        
        list<Project__c> projs = [select id, name, start_date__c, due_date__c, description__c, Complete__c, Service_Line__c, Interested_Party_1__c, Interested_Party_2__c, Interested_Party_3__c from Project__c where isTemplate__c = false ORDER By Start_Date__c];
        
        for(project__c p : projs){
            projIDs.add(p.id);            
            tmn_tree.node n = new TMN_Tree.node (p.id, p.name);
            n.Proj = p;
            allData.root.nodes.add(n);
        
        }
        list<Project_Task__c> PTs = new list<Project_Task__c>();
        PTs = [select ID, name, status__c, description__c, start_date__c, due_date__c, Complete__c, Project__c, Assigned_To__c, External_ID__c, Project__r.id,
                             (select id, name, status__c, description__c, complete__c, start_date__c, due_date__c, Assigned_To__c, Project_Task__c from Project_Task_Activities__r Order By Start_Date__c) 
                                 From Project_Task__c Where Project__c IN :projIDs Order By Start_Date__c] ;        
        for(Project_Task__c t: PTs){
            tmn_tree.node n = new TMN_Tree.node (t.id, t.name);
            n.ProjTask = t;
            integer i = allData.root.getNode_Key(t.project__r.id); 
            allData.root.nodes.get(i).nodes.add(n);       
            for(Project_Task_Activity__c a: t.Project_Task_Activities__r ){
                
                tmn_tree.node n2 = new TMN_Tree.node (a.id, a.name);
                n2.ProjTaskAct = a;
                integer i2 = allData.root.nodes.get(i).getNode_Key(t.id);
                allData.root.nodes.get(i).nodes.get(i2).nodes.add(n2);
                
                
            }
        
        }
    
        return null;
    }

}