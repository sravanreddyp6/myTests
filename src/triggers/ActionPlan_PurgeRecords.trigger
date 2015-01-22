trigger ActionPlan_PurgeRecords on Action_Plan__c (after update) {
list<Action_Plan__c> AP2Delete = new list<Action_Plan__c>();
set<id> id2delete = new set<id>();
  for(Action_Plan__c ap: trigger.new){
      if(ap.Purge_Record__c){id2delete.add(ap.id);}
  
  
  }
    delete [select id from action_plan__c where id in:id2delete];

}