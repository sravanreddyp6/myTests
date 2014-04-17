Public with sharing class ProgressNoteHandler{
      private boolean m_isExecuting = false;

    public ProgressNoteHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    public void OnBeforeInsert(Progress_Note__c[] newObjects){
    
        List<Id> acctIds = new List<Id>();
        for(Progress_Note__c prog : newObjects){
            acctIds.add(prog.Person_Being_Served__c);
        }
        
        List<Contact> pbsList = [SELECT Id, Owner_Role__c FROM Contact WHERE Id = :acctIds];
        List<Group> lstObjQueueName = [SELECT Id, Name FROM Group WHERE type='Queue'];
       // Map<Id, String> accroleMap = new Map<Id, String>();
        Map<String, Group> queueMap = new Map<String, Group>();
        for (Group g : lstObjQueueName){
            queueMap.put(g.Name,g);
        
        }
        
      //  for(Account a : pbsList){
        //    accroleMap.put(a.id,a.Owner_Role__c);
        
       // }
        
        for(Progress_Note__c pn : newObjects){
            for (Contact ac :pbsList){
                    if(pn.Person_Being_Served__c == ac.Id){
                    System.debug('ACCCCCOOOOUUUNNNNNTTTTTT ID-----'+ac.id);
                    Group gr = QueueMap.get(ac.Owner_Role__c);
                     system.debug('GGRRRROOUUUUUUUUPPPPP'+gr);
                     pn.OwnerId = gr.id;
        
                }
            }
        }
    
    }
    
     public void OnAfterInsert(Progress_Note__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC 
    }
    
      public void OnBeforeUpdate(Progress_Note__c[] oldObjects, Progress_Note__c[] updatedObjects, Map<Id,Progress_Note__c> newObjMap, Map<Id, Progress_Note__c> oldObjMap){
        // BEFORE UPDATE LOGIC  
    }
    
    public void OnAfterUpdate(Progress_Note__c[] oldObjects, Progress_Note__c[] updatedObjects, Map<Id,Progress_Note__c> newObjMap){
        // AFTER UPDATE LOGIC
    }
    
    public void OnBeforeDelete(Progress_Note__c[] ObjectsToDelete, Map<Id,Progress_Note__c> oldObjMap){
        // BEFORE DELETE LOGIC        
    }
    
    public void OnAfterDelete(Progress_Note__c[] deletedObjects, Map<Id,Progress_Note__c> oldObjMap){
        // AFTER DELETE LOGIC     
    }
    
     public void OnUndelete(Progress_Note__c[] restoredObjects){
        // AFTER UNDELETE LOGIC   
    }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
}