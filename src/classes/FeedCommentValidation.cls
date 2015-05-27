public without sharing class FeedCommentValidation {

    private boolean m_isExecuting = false;

    public FeedCommentValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(FeedComment[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
           }

    public void OnAfterInsert(FeedComment[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

   
    public void OnBeforeDelete(list<feedcomment> fc){
        // BEFORE DELETE LOGIC
        
        list<feedcomment> fcc = new list<feedcomment>();
        fcc = trigger.old;
        set <id> fiid = new set <id>();
        for (feedcomment fcid : fcc){
            fiid.add (fcid.feeditemid);
        }
        list<feeditem> fi = [select createdbyid from FeedItem where ID in :fiid];

        map<id, user> u = new map<id, user>();
        set <string> userids = new set<string>();
    
        for (FeedComment feedc : fcc) {
            userids.add (feedc.createdbyid);
        }   
    
        for (FeedItem f : fi) {
            userids.add (f.createdbyid);
        }
    
        for (User usr : [select id, legal_custodian__c from user where id in :userids]){
            u.put(usr.id, usr);
        }


        for (FeedComment fca : fcc) {
            for (FeedItem f  : fi)
            {
                if (u.get(f.createdbyid).legal_custodian__C )
                {
                     fca.adderror('This post cannot be deleted. It is being retained in accordance with the Network’s Chatter Usage Guidelines, Chatter Retention Policy and/or Legal Hold Policy.');
                }
        
            }
            if (u.get(fca.createdbyid).legal_custodian__C){
            fca.adderror('This comment cannot be deleted. It is being retained in accordance with the Network’s Chatter Usage Guidelines, Chatter Retention Policy and/or Legal Hold Policy.');
        
    
        }

    }
        
        
        
    }

    public void OnAfterDelete(FeedComment[] deletedObjects, Map<Id,FeedComment> oldObjMap){
        // AFTER DELETE LOGIC
    }

 
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
        
   }
   }