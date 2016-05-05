public with sharing class ServiceAssignment_Contract_JOValidation {

    private boolean m_isExecuting = false;

    public ServiceAssignment_Contract_JOValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(ServiceAssignment_Contract_JO__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(ServiceAssignment_Contract_JO__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    
    	// START:  Contract Concatenation Field Update Code    
        Map<Id,List<String>> servAssignsToUpdate = new Map<Id,List<String>>();
                
        List<ServiceAssignment_Contract_JO__c> sadjos = [ SELECT Service_Assignment__c, Contract__r.Name, Service_Assignment__r.Contract_Concatenation__c 
        													FROM ServiceAssignment_Contract_JO__c
        													WHERE Id IN :newObjects ];
        
        Set<Id> servAssignIds = new Set<Id>();
        
        
        for(ServiceAssignment_Contract_JO__c s : sadjos) {
        	servAssignIds.add(s.Service_Assignment__c);
        }
        
        for(Id iD : servAssignIds) {
        	List<String> stringsToAddForThisServAssign = new List<String>();
	        for(ServiceAssignment_Contract_JO__c s : sadjos) {
	        	if(iD==s.Service_Assignment__c) {
		        	System.debug('s.Service_Assignment__c: ' + s.Service_Assignment__c);
		        	System.debug('s.Contract__c: ' + s.Contract__c);
		        	System.debug('s.Service_Assignment__r.Contract_Concatenation__c: ' + s.Service_Assignment__r.Contract_Concatenation__c);
		        
		        
		        	if(s.Service_Assignment__r.Contract_Concatenation__c==null) {
		        		stringsToAddForThisServAssign.add('~' + s.Contract__r.Name + '~');
		        	}
		        	else if(!s.Service_Assignment__r.Contract_Concatenation__c.contains('~' + s.Contract__r.Name + '~')) {
		        		stringsToAddForThisServAssign.add('~' + s.Contract__r.Name + '~');	
		        	} 
	        	}
	        }        
	        servAssignsToUpdate.put(iD,stringsToAddForThisServAssign);
        }
        
		List<Service_Assignment__c> listOfServAssigns = [ SELECT Id, Contract_Concatenation__c FROM Service_Assignment__c WHERE Id = :servAssignIds ];
		List<Service_Assignment__c> listOfServAssignsToUpdate = new List<Service_Assignment__c>();

		for(Service_Assignment__c sA : listOfServAssigns) {
			Service_Assignment__c aServAssignToUpdate = new Service_Assignment__c();
			aServAssignToUpdate = sA;
			for(Id i : servAssignsToUpdate.keySet()) {
				if(sA.Id==i) {
					System.debug('servAssignsToUpdate VALUE: ' + servAssignsToUpdate.get(i));
					for(String s : servAssignsToUpdate.get(i)) {
						System.debug('STRINGS TO ADD');			
						if(aServAssignToUpdate.Contract_Concatenation__c==null){
							aServAssignToUpdate.Contract_Concatenation__c = s;
						}
						else {
							aServAssignToUpdate.Contract_Concatenation__c += s;
						}
					}
								
				}
			}
			listOfServAssignsToUpdate.add(aServAssignToUpdate);			
		}

		update listOfServAssignsToUpdate;        
        
        
        
                
// ---
// ---
/*        
        List<Id> servAssignIds = new List<Id>();
        for(Id i : servAssignsToUpdate.keySet()) {
        	servAssignIds.add(i);
        }
        
        List<Service_Assignment__c> listOfServAssigns = [ SELECT Id, Contract_Concatenation__c FROM Service_Assignment__c WHERE Id = :servAssignIds ];
        List<Service_Assignment__c> listOfServAssignsToUpdate = new List<Service_Assignment__c>();
        
        for(Service_Assignment__c sA : listOfServAssigns) {    
	        for(Id i : servAssignsToUpdate.keySet()) {
	     		if(sA.Id==i) {
	     			sA.Contract_Concatenation__c = (sA.Contract_Concatenation__c + servAssignsToUpdate.get(i)).replaceFirst('null','');
	     			listOfServAssignsToUpdate.add(sA);
	     		}   
	        }
        }
        
        update listOfServAssignsToUpdate;
        // END:  Contract Concatenation Field Update Code
*/
    }

    public void OnBeforeUpdate(ServiceAssignment_Contract_JO__c[] oldObjects, ServiceAssignment_Contract_JO__c[] updatedObjects, Map<Id,ServiceAssignment_Contract_JO__c> newObjMap){
        // BEFORE UPDATE LOGIC
    }

    public void OnAfterUpdate(ServiceAssignment_Contract_JO__c[] oldObjects, ServiceAssignment_Contract_JO__c[] updatedObjects, Map<Id,ServiceAssignment_Contract_JO__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(ServiceAssignment_Contract_JO__c[] ObjectsToDelete, Map<Id,ServiceAssignment_Contract_JO__c> oldObjMap){
    	// BEFORE DELETE LOGIC
    	System.debug('BEFORE DELETE KICKOFF!');
        // START: Contract Concatenation Field Update Code


        Map<Id,List<String>> servAssignsToUpdate = new Map<Id,List<String>>();
                
        List<ServiceAssignment_Contract_JO__c> sadjos = [ SELECT Service_Assignment__c, Contract__r.Name, Service_Assignment__r.Contract_Concatenation__c 
        													FROM ServiceAssignment_Contract_JO__c
        													WHERE Id IN :ObjectsToDelete ];
      
        Set<Id> servAssignIds = new Set<Id>();
        
        
        for(ServiceAssignment_Contract_JO__c s : sadjos) {
        	servAssignIds.add(s.Service_Assignment__c);
        }
              
        
        for(Id iD : servAssignIds) {
        	List<String> stringsToRemoveForThisServAssign = new List<String>();
	        for(ServiceAssignment_Contract_JO__c s : sadjos) {
	        	System.debug('s.Service_Assignment__c: ' + s.Service_Assignment__c);
	        	System.debug('s.Contract__c: ' + s.Contract__c);
	        	System.debug('s.Service_Assignment__r.Contract_Concatenation__c: ' + s.Service_Assignment__r.Contract_Concatenation__c);
	        
	        	if(iD==s.Service_Assignment__c) {
		        	if(s.Service_Assignment__r.Contract_Concatenation__c==null) {
						// DO NOTHING.  THIS CASE MIGHT OCCUR IF MULTIPLE ServiceAsssignment_Contract_JO__c UPDATES FOR THE SAME
						// CONTRACT AND SERVICE ASSIGNMENT OCCUR SIMULTANEOUSLY, BUT AS OF 10/31/13, NO SUCH USE CASES EXIST.
		        	}
		        	else if(s.Service_Assignment__r.Contract_Concatenation__c.contains('~' + s.Contract__r.Name + '~')) {
		        		stringsToRemoveForThisServAssign.add('~' + s.Contract__r.Name + '~');
		        	} 	        		        		
	        	}
	        	
	        }
	        System.debug('IS BLOCK WITH servAssignsToUpdate PUT STATEMENT IS EXECUTING!');
	        servAssignsToUpdate.put(iD,stringsToRemoveForThisServAssign);
        }

		List<Service_Assignment__c> listOfServAssigns = [ SELECT Id, Contract_Concatenation__c FROM Service_Assignment__c WHERE Id = :servAssignIds ];
		List<Service_Assignment__c> listOfServAssignsToUpdate = new List<Service_Assignment__c>();

		for(Service_Assignment__c sA : listOfServAssigns) {
			Service_Assignment__c aServAssignToUpdate = new Service_Assignment__c();
			aServAssignToUpdate = sA;
			for(Id i : servAssignsToUpdate.keySet()) {
				if(sA.Id==i) {
					System.debug('servAssignsToUpdate VALUE: ' + servAssignsToUpdate.get(i));
					for(String s : servAssignsToUpdate.get(i)) {
						System.debug('STRINGS TO REPLACE');			
						aServAssignToUpdate.Contract_Concatenation__c = sA.Contract_Concatenation__c.replace(s,'');
					}
								
				}
			}
			listOfServAssignsToUpdate.add(aServAssignToUpdate);			
		}

		update listOfServAssignsToUpdate;

    } 

    public void OnAfterDelete(ServiceAssignment_Contract_JO__c[] deletedObjects, Map<Id,ServiceAssignment_Contract_JO__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(ServiceAssignment_Contract_JO__c[] restoredObjects){} // ADD AFTER UNDELETE LOGIC BETWEEN BRACES

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
// ------------------------------------
//
//
// END TRIGGER HANDLER TEMPLATE
//
// ---------------------------------------
// 
// START METHODS FOR WORK IN THIS HANDLER
// 
// 
// --------------------------------------- 

}