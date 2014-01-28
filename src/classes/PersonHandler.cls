public with sharing class PersonHandler {
    private boolean m_isExecuting = false;

    public PersonHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Person__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(Person__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
		
		// Put incoming list of Person__c records into a more user-friendly variable name, and declare a variable for a list or Person__c IDs. 
    	List<Person__c> thesePersons = newObjects;
		List<Id> personIds = new List<Id>();

		Schema.DescribeSObjectResult personSchemaInfo = Person__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> personRecordTypes = personSchemaInfo.getRecordTypeInfos();
    
        // Get ALL credential profiles into a list so we can later filter out only the ones for a given new person's 'type' without putting a query in a loop.
        List<Credential_Profile__c> credList = new List<Credential_Profile__c>();
        credList = [ SELECT Id, Name, Required_for_Mentor__c, Optional_for_Mentor__c, Required_for_Co_Applicant__c, Optional_for_Co_Applicant__c, 
        			Required_for_Foster_Parent_Relative__c, Optional_for_Foster_Parent_Relative__c, Required_for_Foster_Parent_Child__c, 
        			Optional_for_Foster_Parent_Child__c, Required_for_Resident_Non_Relative__c, Optional_for_Resident_Non_Relative__c,
        			Required_for_Pet__c, Optional_for_Pet__c FROM Credential_Profile__c ];
       System.debug('credList holds: ' + credList);
       // Loop through the person records that were just created, and determine which Credential_Profile__c records matter for them, based on the Person__c        
		for (Person__c p : thesePersons) {
       		System.debug('The persons loop in PersonHandler.cls is executing...');
       		System.debug('What is p in the persons loop in PersonHandler.cls: ' + p);

			string thisPersonsRecordTypeName;

   			for(Schema.RecordTypeInfo sPrts : personRecordTypes) {
   				System.debug('sPrts.Name: ' + sPrts.Name);
   				System.debug('p.RecordTypeId: ' + p.RecordTypeId);
   				System.debug('sPrts.RecordTypeId: ' + sPrts.RecordTypeId);
   				if(p.RecordTypeId==sPrts.RecordTypeId) {
   					thisPersonsRecordTypeName = sPrts.Name;
   				}
   			}

       		// Initialize a list variable for the credential records we'll eventually insert for each person.
       		List<Credential_Record__c> credRecs = new List<Credential_Record__c>();
       		
       		for(Credential_Profile__c cp : credList) {
       			System.debug('This person\'s Record Type ID is: ' + p.RecordTypeId);
       			System.debug('This person\'s RecordType.Name is: ' + p.RecordType.Name);
       			System.debug('This credential\'s cp.Required_for_Mentor__c value is: ' + cp.Required_for_Mentor__c);
       			if(thisPersonsRecordTypeName=='Mentor' && cp.Required_for_Mentor__c==true) {
   					Credential_Record__c credRec = new Credential_Record__c(
   						Credential_Profile__c = cp.Id,
   						Person__c = p.Id
   					);			
   					credRecs.add(credRec);
   					System.debug('Added a Credential Record (' + cp.Name + ') to credRecs for a \'Mentor\' Record Type...');
       			}
       			if(thisPersonsRecordTypeName=='Related Party') {
	   				if(p.Related_Party_Type__c=='Co-Applicant' && cp.Required_for_Co_Applicant__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						Person__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Relative' && cp.Required_for_Foster_Parent_Relative__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						Person__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Child' && cp.Required_for_Foster_Parent_Child__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						Person__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Resident-Non Relative' && cp.Required_for_Resident_Non_Relative__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						Person__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Pet' && cp.Required_for_Pet__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						Person__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}       				 
       			}    			
       		}
       		insert credRecs;
       }
        
    }

    public void OnBeforeUpdate(Person__c[] oldObjects, Person__c[] updatedObjects, Map<Id,Person__c> newObjMap){
        // BEFORE UPDATE LOGIC 	
    }

    public void OnAfterUpdate(Person__c[] oldObjects, Person__c[] updatedObjects, Map<Id,Person__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Person__c[] ObjectsToDelete, Map<Id,Person__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Person__c[] deletedObjects, Map<Id,Person__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Person__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
}