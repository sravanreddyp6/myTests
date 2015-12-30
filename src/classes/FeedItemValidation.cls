public without sharing class FeedItemValidation {

    private boolean m_isExecuting = false;

    public FeedItemValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(FeedItem[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
           }

    public void OnAfterInsert(FeedItem[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(FeedItem[] oldObjects, FeedItem[] updatedObjects, Map<Id,FeedItem> newObjMap){
        // BEFORE UPDATE LOGIC
         }

    public void OnAfterUpdate(FeedItem[] oldObjects, FeedItem[] updatedObjects, Map<Id,FeedItem> newObjMap){
        // AFTER UPDATE LOGIC
     }

    public void OnBeforeDelete(list<feeditem> fi){
        // BEFORE DELETE LOGIC
        
         //list<Feeditem> fi = new list<Feeditem>();
        //fi = trigger.old;
    list<feedcomment> fcc = [Select createdbyid from FeedComment where FeedItemID in :fi];
        
    map<id, user> u = new map<id, user>();
    set <string> userids = new set<string>();
    
     for (FeedItem f : fi) {
        userids.add (f.createdbyid);
     }
     
     for (FeedComment feedc : fcc ){
        userids.add (feedc.createdbyid);
     }
     
     for (User usr : [select id, legal_custodian__c from user where id in :userids]){
        u.put(usr.id, usr);
     }
    

      for (FeedItem f : fi){
        for (FeedComment fc : fcc)
         {
      
          if (u.get(fc.createdbyid).legal_custodian__C)
          {
          f.adderror('This post cannot be deleted. It is being retained in accordance with the Network’s Chatter Usage Guidelines, Chatter Retention Policy and/or Legal Hold Policy.');
          }
         }
    
     //  If post creator is a legal custodian prevent deletion and display a message  
     if (u.get(f.createdbyid).legal_custodian__C){
        f.adderror('This post cannot be deleted. It is being retained in accordance with the Network’s Chatter Usage Guidelines, Chatter Retention Policy and/or Legal Hold Policy.');
                }
}
        
        
        
    }

    public void OnAfterDelete(FeedItem[] deletedObjects, Map<Id,FeedItem> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(FeedItem[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}