public with sharing class proj_nr_form {
    public project__c cur_proj {get; set;}
    public TMN_Tree projTree {get; set;}
    public boolean hasError{ get; set;}
    public string PTid {get; set;}
    public string startingOption {get; set;}
    public string selectedTemplate{get; set;}

    //construct
    public proj_nr_form(ApexPages.StandardController controller) {
        cur_proj = (Project__c)controller.getRecord(); 
        startingOption = 'blank';
        projTree = new TMN_Tree();        
        if(cur_proj.id == null){
            cur_proj.external_id__c = GenID(16);
            projTree.root.refID = cur_proj.external_id__c; 
            projTree.root.IsNew = true;
            projTree.root.IsInserted = true;
        }
        else{
            projTree.root.refID = cur_proj.id;
        }
        projTree.root.Proj = cur_proj;
        refreshProjTree();
        
    }
    //end contruct
    
    //starting options
    public List<SelectOption> getStartOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('blank','Create a Blank Project'));
        options.add(new SelectOption('new_temp','Create a new Project Template'));
        options.add(new SelectOption('create_from_temp','Create a new Project Based a Template'));

        return options;
    }    
    public List<SelectOption> getTemplates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none','--None--'));
        for(project__c p : [select id, name from Project__c where isTemplate__c = true]){
            options.add(new SelectOption(p.id,p.name));        
        }

        return options;
    } 
    //end starting options 
        
    //methods to ad items to the project tree
    public pageReference AddProjectTask(){
        Project_task__c PT = new Project_task__c();
        string tmpID = GenId(16);
        PT.External_ID__c = tmpID;
        if(projTree.root.isNew){
            Project__c p = new Project__c();
            p.External_ID__c = projTree.root.Proj.External_ID__c;    
            PT.Project__r = p;          
        }    
        else{
            PT.Project__c = projTree.root.Proj.id;
        }    
        tmn_tree.node tmpPTnode = new tmn_tree.node(tmpID, 'task');
        tmpPTnode.ProjTask = PT;
        projTree.root.nodes.add(tmpPTnode);
        return null;
    }        
    public pageReference AddProjectTaskActivity(){
        //page send PTid via apex:Param
        Project_Task_Activity__c PTA = new Project_Task_Activity__c ();
        string tmpID = GenId(16);        
        integer i = projTree.root.getNode_Key(PTid);
        if(projTree.root.nodes.get(i).isNew){
            Project_task__c PT = new Project_task__c();
            PT.External_ID__c = PTid;
            PTA.Project_Task__r = PT;
        }
        else{
            PTA.Project_Task__c = projTree.root.nodes.get(i).ProjTask.id;
        }
        
        tmn_tree.node tmpPTnode = new tmn_tree.node(tmpID, 'activity');
        tmpPTnode.ProjTaskAct = PTA;
        projTree.root.nodes.get(i).nodes.add(tmpPTnode);
        return null;
    }  
    //end methods to add to tree        
    //methods to save the project
    public pageReference Save(){
        Savepoint sp = Database.setSavepoint();
        hasError = false;
        if(projTree.root.Proj.id == null){
            saveNewProj();
            //ApexPages.currentPage().getParameters().get('id') = '123';
        }
        else{updateProj();}
        
        refreshProjTree();
        return null;
    }
    public void updateProj(){
        Savepoint sp = Database.setSavepoint();
        list<Project_Task__c> PTs = new list<Project_Task__c>();
        list<Project_Task_Activity__c> PTAs = new list<Project_Task_Activity__c>();
        list<Project_Task__c> newPTs = new list<Project_Task__c>();
        list<Project_Task_Activity__c> newPTAs = new list<Project_Task_Activity__c>();        
        
        try{
            for(TMN_Tree.Node t: ProjTree.root.Nodes){
                if(t.isNew){newPTs.add(t.ProjTask);}
                else{PTs.add(t.ProjTask);}
                
                for(tmn_tree.node a: t.nodes){
                    if(a.isNew){newPTAs.add(a.ProjTaskAct);}
                    else{PTAs.add(a.ProjTaskAct);}
                }
            }
            
            update ProjTree.root.Proj;
            update PTs;
            update PTAs;
            insert newPTs;
            insert newPTAs;
        }
        
        catch(Exception e){
            hasError = true;
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }       
    }
    public void saveNewProj(){
        Savepoint sp = Database.setSavepoint();
        list<Project_Task__c> PTs = new list<Project_Task__c>();
        list<Project_Task_Activity__c> PTAs = new list<Project_Task_Activity__c>();
        
        try{
            for(TMN_Tree.Node t: ProjTree.root.Nodes){
                PTs.add(t.ProjTask);
                for(tmn_tree.node a: t.nodes){
                    PTAs.add(a.ProjTaskAct);
                }
            }
            
            if(startingOption == 'new_temp'){
              ProjTree.root.Proj.isTemplate__c = true;  
            }
            insert ProjTree.root.Proj;
            insert PTs;
            insert PTAs;
        }
        
        catch(Exception e){
            hasError = true;
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
    
    }
    //end methods to save project
    
    //helper methods
    public pageReference CopyFromTemp(){
        if(selectedTemplate == 'none'){
            ProjTree.root.nodes.clear();
            return null;
        }
        else{
            list<Project_Task__c> PTs = new list<Project_Task__c>();
            PTs = [select ID, name, description__c, start_date__c, due_date__c, Complete__c, Project__c, Assigned_To__c, External_ID__c,
                     (select id, name, description__c, complete__c, start_date__c, due_date__c, Assigned_To__c, Project_Task__c from Project_Task_Activities__r) 
                         From Project_Task__c Where Project__c = :selectedTemplate];
            project__c pr = [select id, name, description__c from project__c where id = :selectedTemplate];
            ProjTree.root.Proj.Description__c = pr.description__c;
            
                         
            ProjTree.root.nodes.clear();            
            for(Project_Task__c t : PTs){
                string tmpID = GenId(16);
                TMN_Tree.node tN = new TMN_Tree.node(tmpID , 'task');
                Project_Task__c newT = new Project_Task__c();
                newT.name = t.name;
                newT.description__c = t.description__c;
                    Project__c p = new Project__c();
                    p.External_ID__c = projTree.root.Proj.External_ID__c;    
                    newT.Project__r = p;
                
                newT.External_ID__c = tmpID;                                 
                tN.ProjTask = newT;
                tN.isNew = true;
                tN.isInserted = false;
                ProjTree.root.nodes.add(tN);
                
                for(Project_Task_Activity__c a : t.Project_Task_Activities__r){
                    TMN_Tree.node aN = new TMN_Tree.node(a.id, 'task');
                    Project_Task_Activity__c newA = new Project_Task_Activity__c ();
                    newA.Name = a.Name;
                    newA.Description__c = a.Description__c;
                        Project_task__c PT = new Project_task__c();
                        PT.External_ID__c = tmpID;
                        newA.Project_Task__r = PT;                    
                    aN.ProjTaskAct = newA;
                    aN.isNew = true;
                    aN.isInserted = false;
                    integer i = projTree.root.getNode_Key(tmpID);
                    ProjTree.root.nodes.get(i).nodes.add(aN);             
                }
            }            
            
            
            
        }
        return null;
    
    
    }
    public void refreshProjTree(){
        list<Project_Task__c> PTs = new list<Project_Task__c>();
        PTs = [select ID, name, description__c, start_date__c, due_date__c, Complete__c, Project__c, Assigned_To__c, External_ID__c ,
                 (select id, name, description__c, complete__c, start_date__c, due_date__c, Assigned_To__c, Project_Task__c from Project_Task_Activities__r) 
                     From Project_Task__c Where Project__c = :ProjTree.root.Proj.id];
                     
         ProjTree.root.nodes.clear();            
         for(Project_Task__c t : PTs){
             TMN_Tree.node tN = new TMN_Tree.node(t.id, 'task');
             tN.ProjTask = t;
             tN.isNew = false;
             tN.isInserted = true;
             ProjTree.root.nodes.add(tN);
             for(Project_Task_Activity__c a : t.Project_Task_Activities__r){
                 TMN_Tree.node aN = new TMN_Tree.node(a.id, 'task');
                 aN.ProjTaskAct = a;
                 aN.isNew = false;
                 aN.isInserted = true;
                 integer i = projTree.root.getNode_Key(t.id);
                 ProjTree.root.nodes.get(i).nodes.add(aN);             
             }
         }
    
    }
    public string GenId(integer len){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);            
        
        return h.substring(0,len);
    
    }
    
    
    //end help methods
    public class myException extends Exception {}
}