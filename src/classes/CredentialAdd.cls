public with sharing class CredentialAdd {

	public Id contactID {get;set;}
    public List<Credential_Profile__c> possibleCreds  {get;set;}
    public List<SelectOption> credSelectList {get;set;}
    public string[] selectedCreds {get;set;}
    public TMN_Contact__c thisTmnContact {get;set;}
    public String baseUrl { get; set; }
    public boolean canCreateCredRec {get;set;}
    
    public class CredentialException extends Exception{}
       
    public CredentialAdd() {
    
    	selectedCreds = new List<string>();
    	contactID = apexpages.currentpage().getparameters().get('contactid');
    
    	// 1.  Figure out what kind of TMN_Contact__c this is (Mentor? Co-Applicant? App Family?  App Child? Non-Relative? Pet?)
    	thisTmnContact = [ SELECT RecordTypeId, Related_Party_Type__c, Full_Name__c FROM TMN_Contact__c WHERE Id = :contactId ];
			
		string thisPersonsRecordTypeName;
			
		Schema.DescribeSObjectResult tmnContactSchemaInfo = TMN_Contact__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> tmnContactRecordTypes = tmnContactSchemaInfo.getRecordTypeInfos();
		
   		for(Schema.RecordTypeInfo sTrts : tmnContactRecordTypes) {
   			if(thisTmnContact.RecordTypeId==sTrts.RecordTypeId) {
   				thisPersonsRecordTypeName = sTrts.Name;
   			}
   		}    	
    	
    	// 2.  Select all Credential_Profile__c records that have "true" indicated for the Optional flag for that TMN_Contact__c type.
    	if(thisPersonsRecordTypeName=='Mentor') {
            possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Mentor__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
    	}
    	else if(thisPersonsRecordTypeName=='Household Member') {
            if(thisTmnContact.Related_Party_Type__c=='Co-Applicant') {
            	possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Co_Applicant__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Foster Parent\'s Relative') {
            	possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Foster_Parent_Relative__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Foster Parent\'s Child') {
            	possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Foster_Parent_Child__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Resident-Non Relative') {
            	possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Resident_Non_Relative__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Pet') {
            	possibleCreds = [SELECT Id, Name FROM Credential_Profile__c WHERE Optional_for_Pet__c = true AND Id NOT IN (SELECT Credential_Profile__c FROM Credential_Record__c WHERE TMN_Contact__c = :contactID) ORDER BY Name];
            }
            else {
            	// DO NOTHING; something is wrong.  Add error handling here...???
            }
    	}
    	else {
    		// DO NOTHING; something is wrong.  Add error handling here...???
    	}
    	
    	
    	credSelectList = new List<SelectOption>();
    	
    	if(possibleCreds!=null) {
	    	for(Credential_Profile__c cP : possibleCreds) {
	            credSelectList.add(new SelectOption(cp.Id,cp.Name));	
	    	}
    	}
    	
    	baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    
        Schema.DescribeSObjectResult credRecSchema = Credential_Record__c.sObjectType.getDescribe();
        canCreateCredRec = credRecSchema.IsCreateable();
    
    }
    
    public PageReference SaveAddCred() {
    	
    	
    	List<Credential_Record__c> creds = new List<Credential_Record__c>();
    	
    	for (String cred : selectedCreds  ) {
    		creds.Add( new Credential_Record__c( Credential_Profile__c = (ID)cred, TMN_Contact__c = contactID ));
    	}
			
		system.debug( 'SAVING: ' + creds);
		PageReference myPageRef;
		
		try {
			if(canCreateCredRec==true) {
				insert creds;
				system.debug('INSERTING CREDS:' + creds);
				myPageRef = new PageReference('/apex/Credential?contactid=' + contactID);
			}
			else {
				throw new CredentialException('You have insufficient privileges to create a credential record. Please click cancel or navigate away from this page to continue.');
			}
		}
		catch(CredentialException e) {
			ApexPages.addMessages(e);
		}
    	
    	return myPageRef;
    }
    
    public PageReference CancelCredAdd() {
    	PageReference cancelPageRef = new PageReference('/apex/Credential?contactid=' + contactID);
    	cancelPageRef.setRedirect(true);
    	return cancelPageRef;
    }
       
}