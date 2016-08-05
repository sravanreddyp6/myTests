public with sharing class PlanTriggeredActions {

    private boolean m_isExecuting = false;

    public PlanTriggeredActions(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Plan__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        
        Plan__c[] thesePlans = (Plan__c[])newObjects;
        
        List<Id> admIdsFromThesePlans = new List<Id>();
        
        for(Plan__c tPs : thesePlans){
        	admIdsFromThesePlans.add(tPs.Admission__c);
      	} 
      
        list<Service_Assignment__c> listOfServAssigns = [SELECT Id, Program__c, Location_Region__c, Admission__c FROM Service_Assignment__c WHERE Admission__c = :admIdsFromThesePlans];
        
        for(Plan__c x : thesePlans){
        	string thePlansServAssignPrograms;
        	string thePlansServAssignLocations;
			for(Service_Assignment__c sa : listOfServAssigns){
				if(sa.Admission__c == x.Admission__c){
					if(sa.Program__c != null){
						if(String.isEmpty(thePlansServAssignPrograms)){
							thePlansServAssignPrograms = sa.Program__c + ';';
						}
						else{
							thePlansServAssignPrograms += ' ' + sa.Program__c + ';';
						}
					}
					if(sa.Location_Region__c != null){
						if(String.isEmpty(thePlansServAssignLocations)){
							thePlansServAssignLocations = sa.Location_Region__c + ';';
						}
						else{
							thePlansServAssignLocations += ' ' + sa.Location_Region__c + ';';
						}
					}					
				}				
			}
			x.Plan_Program_Names__c = thePlansServAssignPrograms;
			x.Plan_Location_Names__c = thePlansServAssignLocations;
        } 	
    }

    public void OnAfterInsert(Plan__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
        
    }

    public void OnBeforeUpdate(Plan__c[] oldObjects, Plan__c[] updatedObjects, Map<Id,Plan__c> newObjMap){
        // BEFORE UPDATE LOGIC
        
        Plan__c[] thesePlans = (Plan__c[])updatedObjects;
        
        List<Id> admIdsFromThesePlans = new List<Id>();
        
        for(Plan__c tPs : thesePlans){
        	admIdsFromThesePlans.add(tPs.Admission__c);
      	} 
      
        list<Service_Assignment__c> listOfServAssigns = [SELECT Id, Program__c, Location_Region__c, Admission__c FROM Service_Assignment__c WHERE Admission__c = :admIdsFromThesePlans];
        
        for(Plan__c x : thesePlans){
        	string thePlansServAssignPrograms;
        	string thePlansServAssignLocations;
			for(Service_Assignment__c sa : listOfServAssigns){
				if(sa.Admission__c == x.Admission__c){
					if(sa.Program__c != null){
						if(String.isEmpty(thePlansServAssignPrograms)){
							thePlansServAssignPrograms = sa.Program__c + ';';
						}
						else{
							thePlansServAssignPrograms += ' ' + sa.Program__c + ';';
						}
					}
					if(sa.Location_Region__c != null){
						if(String.isEmpty(thePlansServAssignLocations)){
							thePlansServAssignLocations = sa.Location_Region__c + ';';
						}
						else{
							thePlansServAssignLocations += ' ' + sa.Location_Region__c + ';';
						}
					}					
				}				
			}
			x.Plan_Program_Names__c = thePlansServAssignPrograms;
			x.Plan_Location_Names__c = thePlansServAssignLocations;
        } 	
    }

    public void OnAfterUpdate(Plan__c[] oldObjects, Plan__c[] updatedObjects, Map<Id,Plan__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Plan__c[] ObjectsToDelete, Map<Id,Plan__c> oldObjMap){
        // BEFORE DELETE LOGIC
        
    }

    public void OnAfterDelete(Plan__c[] deletedObjects, Map<Id,Plan__c> oldObjMap){
        // AFTER DELETE LOGIC
        
    }

    public void OnUndelete(Plan__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
        
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}