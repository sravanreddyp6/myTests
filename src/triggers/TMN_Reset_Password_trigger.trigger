trigger TMN_Reset_Password_trigger on User (before update) {
 list<User> myUsers = new list<User>();
 
 
    for (User thisUser: trigger.new){
        if(thisUser.Reset_Password__c && thisUser.isActive){
            System.resetPassword(thisUser.id, true);
            thisUser.Reset_Password__c = false;
            myUsers.add(thisUser);
        }
    
    }
    TMN_Reset_Password.doReset rp = new TMN_Reset_Password.doReset(myUsers);
    
    


}