public with sharing class progressnote_actionplan_embed_ex {
	
	public Boolean bHasObj { get; set; }
	
    public pagereference myUpdate(){
    ProgressNote_ActionPlanChildren_mjo__c childJO =  new ProgressNote_ActionPlanChildren_mjo__c();
    childJO.progress_note__c = note.id;
    try{
        if(MapItemInNote.get(updatingID)){
            
            if(isGoal){
                childJO.goal__c = updatingID;
            }
            else{
                childJO.Objective__c= updatingID;
            }
            insert childJO;
            MapItemInNote.put(updatingID, true);
            refChildMap.put(updatingID, childJO);
        }
        else{
            childJO = refChildMap.get(updatingID);
            delete childJO ;
            MapItemInNote.put(updatingID, false);
            childJO = new ProgressNote_ActionPlanChildren_mjo__c();
            refChildMap.put(updatingID, childJO);
        
        }
    }
    catch(DMLException e){ApexPages.addMessages(e); }

        return null;
    }
    
    Progress_Note__c note = new Progress_Note__c();
    map<id, ProgressNote_ActionPlanChildren_mjo__c> refChildMap = new map<id, ProgressNote_ActionPlanChildren_mjo__c>();
    public string updatingID{get; set;}
    public boolean isGoal{get; set;}
    public list<Action_Plan_Goal__c> allgoals = new list<Action_plan_Goal__c>();
    public list<Action_Plan_Goal__c> getallgoals(){return allGoals;}
    
    public map<string, list<action_plan_action__c>> mapActions = new map<string, list<action_plan_action__c>>();
    public map<string, list<action_plan_action__c>> getMapActions(){ return mapActions ;}
    
    public map<id, boolean> MapItemInNote = new map<id, boolean>();
    public map<id, boolean> getMapItemInNote(){return MapItemInNote ;}
    
    public progressnote_actionplan_embed_ex(ApexPages.StandardController controller) {
      //  controller.AddFields (new List<String> {'Service_Assignment__c', 'Admission__c', 'Action_Plan__c'});
        note = (Progress_Note__c )controller.getRecord();
        
        bHasObj = false;
        
        List<string> okstatus = new list<string>();
        okstatus.add ('In Progress');
        okstatus.add ('Revised');
        okstatus.add ('New'); 
        okstatus.add ('N/A');
                
        if (note.action_plan__c != null){
            allgoals = [select id, description__c, 
                            (select id, Description__c, status__c from action_plan_objectives__r where status__c in :okstatus Order BY Sort_Order__c) 
                                    from Action_Plan_Goal__c 
                                        where Action_Plan__c = :note.Action_Plan__c Order BY Sort_Order__c];  
                                        
            for(Action_Plan_Goal__c g:allGoals){
                MapItemInNote.put(g.id, false);
                for(Action_plan_objective__c o: g.action_plan_objectives__r){
                    MapItemInNote.put(o.id, false);
                    list<action_plan_action__c> tmpLst = new list<action_plan_action__c>();
                    mapActions.put(o.id, tmpLst);                
                }
            
            }
            
            for(action_plan_objective__c o:[select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :note.Action_Plan__c]){
                mapActions.put(o.id, o.Action_Plan_Actions__r);
            
            } 
            
            for(ProgressNote_ActionPlanChildren_mjo__c item: 
                            [select id, name, Progress_Note__c, Goal__c, Objective__c 
                                    From ProgressNote_ActionPlanChildren_mjo__c 
                                        Where Progress_Note__c = :note.id  ]){
            
                
                MapItemInNote.put(item.Goal__c, true);
                MapItemInNote.put(item.Objective__c, true);
                // CTEAE-67 - indicate whether there's an objective so we can suppress objective heading on output
                if ( item.Objective__c != null)
                	bHasObj = true;
                	
                refChildMap.put(item.Goal__c,item);
                refChildMap.put(item.Objective__c,item);
            }     
        }
        
        
        
    }
    


}