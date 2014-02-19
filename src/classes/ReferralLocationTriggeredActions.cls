public with sharing class ReferralLocationTriggeredActions {

    private boolean m_isExecuting = false;

    public ReferralLocationTriggeredActions(boolean isExecuting){
        m_isExecuting = isExecuting;
    }


    public void OnBeforeInsert(list<Referral_Location__c>  newObjects){
        // EXECUTE BEFORE INSERT LOGIC
       
        list<Referral_Location__c> rl = new list<Referral_Location__c>();
        rl = trigger.new;
        set <id> rid = new set <id>();
        for (Referral_Location__c rlid : rl){
            rid.add (rlid.referral__c);
            //rid.add (rlid.id);
        }
        set <id> id = new set <id>();
        for (Referral_Location__c loc : rl){
            id.add (loc.id);
        }
        
        set <id> uid = new set <id>(); 
        for (Referral_Location__c rlid2 : rl){
            uid.add (rlid2.User_Assigned__c);
        }
               
        set <string> status = new set <string>(); 
        for (Referral_Location__c statusval : rl){
            status.add (statusval.Status__c);
        }
               
        
                
        list<referral__c> r = [select id, Assigned_users__c from Referral__c where ID in :rid];
        map<id,user> fullnames = new Map<id,user>([select id, name, myfullname__c from user where id = :uid]);     
       
        for (referral__c rr : r){
            string theAssignedUsers;
            theassignedusers = rr.Assigned_users__c;
            
            for(referral_Location__c au : newobjects){
            
				// REF-141 - All users are copied to referral irrespective of Status
                if (au.referral__c == rr.id) {
                    user u = fullnames.get(au.user_assigned__c);
                    if(string.isempty(theAssignedUsers))
                    {
                        theAssignedUsers  = u.name;
                    }
                    else
                    {   
                        theAssignedUsers += ', ' +  u.name;
                    }
                }
            }
            
                
                System.Debug('What is in theassignedusers:' + theAssignedUsers);
                rr.Assigned_users__c = theAssignedUsers;
                update r;
            
        }   
       
        
    }
        
    
    
    
   
    public void OnBeforeUpdate(list<Referral_Location__c> updatedObjects, Map<Id,Referral_Location__c> oldObjMap){
        // BEFORE UPDATE LOGIC
        
        List<Referral_Location__c> rl = new list<Referral_Location__c>();
        rl = trigger.new;
        set <id> rid = new set <id>();
        for (Referral_Location__c rlid : rl){
            rid.add (rlid.referral__c);
            //rid.add (rlid.id);
        }
        set <id> id = new set <id>();
        for (Referral_Location__c loc : rl){
            id.add (loc.id);
        }
        
        set <id> uid = new set <id>(); 
        for (Referral_Location__c rlid2 : rl){
            uid.add (rlid2.User_Assigned__c);
        }
        for (Referral_Location__c rlid2 : oldObjMap.values()) {
            uid.add (rlid2.User_Assigned__c);
        }
               
        set <string> status = new set <string>(); 
        for (Referral_Location__c statusval : rl){
            status.add (statusval.Status__c);
        }
               
        
                
        list<referral__c> r = [select id, Assigned_users__c from Referral__c where ID in :rid];
        map<id,user> fullnames = new Map<id,user>([select id, name from user where id = :uid]);     
               
       
        for (referral__c rr : r){
            string theAssignedUsers='';
            if (rr.Assigned_users__c != null) theassignedusers = rr.Assigned_users__c;
            
            
            for(referral_Location__c au : updatedobjects){
                    
	            referral_location__c old = oldObjMap.get(au.id);
	            
	            string oldAssnUser = '';
	            string newAssnUser = '';
	            if (old.user_assigned__c != null) oldAssnUser = fullnames.get(old.user_assigned__c).name;
	            if (au.user_assigned__c != null) newAssnUser = fullnames.get(au.user_assigned__c).name;
	            System.Debug('What is in the old user:' + oldAssnUser);
	            System.Debug('What is in the new user:' + newAssnUser);
	                    
	            if (au.referral__c == rr.id) {
		            //If assigned user value changes remove old value from string and add new value if status is active 
		            if (oldAssnUser != newAssnUser)
		            {
		                theassignedusers = theassignedusers.replace(oldAssnUser, newAssnUser);
		            }
	            }

				// REF-141 - All users are copied to referral irrespective of Status
				// Have to add any that are not already in the list
				if (!theAssignedUsers.Contains(newAssnUser)){
					theAssignedUsers += ', ' +  newAssnUser;
				}
				
            }
        
            //Clean up extra commas
            theassignedusers = theassignedusers.replace(',,', ',');
            
            if (theassignedusers.startsWith(', '))
            {
                theassignedusers = theassignedusers.removestart(', ');
            }
        
            
            System.Debug('What is in theassignedusers:' + theAssignedUsers);
            rr.Assigned_users__c = theAssignedUsers;
            update r;
            
        }   
       

    
    }

   
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}