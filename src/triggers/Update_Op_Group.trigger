trigger Update_Op_Group on TMN_User__c (after insert, after update) {
set<id> userids = new Set<id>();
if(!Test.isRunningTest()) { 
for (TMN_User__c tu: Trigger.new){
        //get al user ids in scope
        userids.add(tu.Salesforce_User_Account__c) ; 
    }
    //build map for lookup
    map<id, user> userrecs = new map<id, user>();
    for(user u : [select Operating_Group__c, id from user where id in :userids]){     
        userrecs.put(u.id, u);     
    }
    
    
    list<user> UserRecsToUpdate =  new List<user>();
    for (TMN_User__c tu: Trigger.new){
        if(userrecs.containsKey(tu.Salesforce_User_Account__c)){
            user tmpU = userrecs.get(tu.Salesforce_User_Account__c);
         //   system.debug('tu - ' + tu.Operating_Group__c);
          //  system.debug('user - ' + tmpU.Operating_Group__c );
            if (tmpU.Operating_Group__c != tu.Operating_Group__c){
                tmpU.Operating_Group__c = tu.Operating_Group__c;
                UserRecsToUpdate.add(tmpU);
            }
        }
    }
    
        update UserRecsToUpdate; 
}

}