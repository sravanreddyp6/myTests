public with sharing class Notes_ProgressNote_Action_Plan_Chlrn {
    public list<Action_Plan_Goal__c> GoalsAndObjs = new List<Action_plan_goal__c> ();
    public list<Action_Plan_Goal__c> getGoalsAndObjs(){ return GoalsAndObjs ;}
    public set<id> childrenScope = new set<id>();
    public set<id> getchildrenScope() {return childrenScope ;}    

    public Progress_Note__c CurrentRec = new Progress_Note__c();

    public Set<ID> AllIds = new Set<ID>();
    public Set<ID> getALLids (){return ALLids;}
    
    public List<Short_Term_Goal__c> MyGoals = new List<Short_Term_Goal__c>();
    public List<Short_Term_Goal__c> getMyGoals(){ return 
        [Select Frequency_and_Duration__c, Status__c, Short_Term_Goal_Description__c,
          (Select Id, Objective_Description__c, Frequency_and_Duration__c, Status__c 
              From Objectives__r
              Where Id IN :Allids) 
                  From Short_Term_Goal__c
                      Where Id IN :Allids];
  }
  
  public Map<id, Objective__c> MapOBJ = new Map<id, Objective__c>();
  public Map<id, Objective__c> getMapOBJ(){ return MapOBJ;}
    
    public Notes_ProgressNote_Action_Plan_Chlrn(ApexPages.StandardController controller) {
         this.CurrentRec = (Progress_Note__c)controller.getRecord();

         
         List<ProgressNote_ServiceAssignment_mJO__c> mjo = 
         [Select  Name, Short_Term_Goal__c, Objective__c, Intervention__c From ProgressNote_ServiceAssignment_mJO__c Where Progress_Note__c = :CurrentRec.id];
         
         
         for (ProgressNote_ServiceAssignment_mJO__c local : mjo){
             AllIds.add(local.Short_Term_Goal__c);
             AllIds.add(local.Objective__c);
             AllIds.add(local.Intervention__c ); 
         }
         
         for (Objective__c local : [Select ID, (Select Intervention_Description__c From Interventions__r Where Id IN :ALLids) From Objective__c Where Id IN: ALLids]){
             MapOBJ.put(local.id, local);         
         }
         
         for (ProgressNote_ActionPlanChildren_mjo__c item: 
                        [select id, name, Progress_Note__c, Goal__c, Objective__c 
                                From ProgressNote_ActionPlanChildren_mjo__c 
                                    Where Progress_Note__c = :CurrentRec.id ]){
                
                  childrenScope.add(item.Goal__c);                  
                  childrenScope.add(item.Objective__c);
            }        
         
    
         GoalsAndObjs =[select id, description__c, 
                        (select id, Description__c from action_plan_objectives__r where id in :childrenScope) 
                                from Action_Plan_Goal__c 
                                    where id in :childrenScope];    
    
    
    
    }

}