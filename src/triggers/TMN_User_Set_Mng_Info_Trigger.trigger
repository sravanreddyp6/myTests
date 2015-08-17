trigger TMN_User_Set_Mng_Info_Trigger on TMN_User__c (before insert,before update) {
    List<TMN_User__c> updUsers = new List<TMN_User__c>();
    for(TMN_User__c thisUser: trigger.new){
        List<TMN_User__c> MngId = [SELECT Id FROM TMN_User__c WHERE Email__c =:thisUser.Manager_Email__c LIMIT 1];
        List<TMN_User__c> MngName = [SELECT Name FROM TMN_User__c WHERE Id =:thisUser.Manager_Lookup__c LIMIT 1];
        List<TMN_User__c> MngEmail = [SELECT Email__c FROM TMN_User__c WHERE Id =:thisUser.Manager_Lookup__c LIMIT 1];
        if(thisUser.Manager_Lookup__c==null){
            thisUser.Manager_Lookup__c = MngId[0].Id;            
        } else {
            thisUser.Manager_Name__c = MngName[0].Name;
            thisUser.Manager_Email__c = MngEmail[0].Email__c;
        }
    }
}