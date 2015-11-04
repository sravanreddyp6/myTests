public with sharing class UserTriggeredActions {

    private boolean m_isExecuting = false;

    public UserTriggeredActions(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeUpdate(list<user> updatedObjects, Map<Id,user> oldObjMap){
        // BEFORE UPDATE LOGIC
            
            
            
            for(user newusr : updatedobjects){
                    
            user old = oldObjMap.get(newusr.id);
            
            boolean oldCust;
            boolean newCust;
            if (old.legal_custodian__c != null) oldCust = old.legal_custodian__c;
            if (newusr.legal_custodian__c != null) newCust = newusr.legal_custodian__c;
            //System.Debug('What is in the old user:' + oldAssnUser);
            //System.Debug('What is in the new user:' + newAssnUser);
                    
            //If legal custodian value has changed update the update date and update by field 
            if (oldCust != NewCust)
            {
               newusr.legal_custodian_Update_Date__c = date.today();
               newusr.legal_custodian_Update_By__c = Userinfo.getname();
            }
        
       }

    
    }

   
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}