public with sharing class ProgressNote_Esign {
    Progress_Note__c note = new Progress_Note__c();
    set<id> IdsInScope = new set<id>();
    public list<Action_Plan_Goal__c> apg = new List<Action_Plan_Goal__c>();
    public list<Action_Plan_Goal__c> getapg(){
        return apg;
    }
    public map<id, list<Action_Plan_Action__c>> apo = new map<id, list<Action_Plan_Action__c>>();
    public map<id, list<Action_Plan_Action__c>> getapo(){
        return apo;
    } 
    public ProgressNote_Esign(ApexPages.StandardController controller) {
        note = (Progress_Note__c )controller.getRecord();
        
        
            for(ProgressNote_ActionPlanChildren_mjo__c item: 
                            [select id, name, Progress_Note__c, Goal__c, Objective__c 
                                    From ProgressNote_ActionPlanChildren_mjo__c 
                                        Where Progress_Note__c = :note.id  ]){
            
                
                IdsInScope.add(item.Goal__c);
                IdsInScope.add(item.Objective__c);

            }
            
            apg = [select id, description__c, 
                            (select id, Description__c, status__c from action_plan_objectives__r where id in :IdsInScope Order BY Sort_Order__c) 
                                    from Action_Plan_Goal__c 
                                        where id in :IdsInScope Order BY Sort_Order__c];          
                                        
            for(action_plan_objective__c o:[select id, (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) from action_plan_objective__c where action_plan_goal__r.action_plan__c = :note.Action_Plan__c]){
                apo.put(o.id, o.Action_Plan_Actions__r);            
            }        
        
        
    }

}