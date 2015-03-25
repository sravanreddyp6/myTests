/*
    if admin uncheck Read_Only__c field on plan, update hierarchicaly objectives, planObjectives and interventions
*/
trigger V2SA_Plan_ReadOnlyUpdate on Plan__c (after update) {


    if(trigger.isUpdate){
        set<string> setOfFields = new set<string>{
                    'Read_Only__c'
                };
        boolean change = false;
        for (integer i = 0; i < Trigger.new.size(); i++) {
            for (string field : setOfFields){
                if(trigger.new[i].get(field) != trigger.old[i].get(field)){
                    change = true;
                    break;
                }
            }
            if(change){
                break;
            }
        }
        if(!change){
            return;
        }

        set<Id> setIdPlans = new set<Id>();
        set<Id> setIdObjs = new set<Id>();
        set<Id> setIdPlanObjs = new set<Id>();
        set<Id> setIdInters = new set<Id>();
        
        for (integer i = 0; i < Trigger.new.size(); i++) {
            if(Trigger.new[i].Read_Only__c == false){
                setIdPlans.add(Trigger.new[i].Id);  
            }
        }
        
        map<Id,Short_Term_Goal__c> mapObjs = new map<Id,Short_Term_Goal__c>([SELECT Id, Read_Only__c FROM Short_Term_Goal__c WHERE Plan__c in :setIdPlans]); 
        map<Id,Objective__c> mapPlanObjs = new map<Id,Objective__c>([SELECT Id, Read_Only__c FROM Objective__c WHERE Short_Term_Goal__c in :mapObjs.keySet()]);
        map<Id,Intervention__c> mapInters = new map<Id,Intervention__c>([SELECT Id, Read_Only__c FROM Intervention__c WHERE Objective__c in :mapPlanObjs.keySet()]);
        for(Short_Term_Goal__c obj : mapObjs.values()) {
            obj.Read_Only__c = false;
        }
        
        for(Objective__c obj : mapPlanObjs.values()) {
            obj.Read_Only__c = false;
        }
        
        for(Intervention__c obj : mapInters.values()) {
            obj.Read_Only__c = false;
        }
        
        update mapObjs.values();
        update mapPlanObjs.values();
        update mapInters.values();
    }

}