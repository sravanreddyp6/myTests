public with sharing class CredentialAdd {

	public Id contactID = apexpages.currentpage().getparameters().get('contactid');
    public List<Credential_Profile__c> possibleCreds  {get;set;}
       
    public CredentialAdd() {
    
    	// 1.  Figure out what kind of TMN_Contact__c this is (Mentor? Co-Applicant? App Family?  App Child? Non-Relative? Pet?)
    	TMN_Contact__c thisTmnContact = [ SELECT RecordTypeId, Related_Party_Type__c FROM TMN_Contact__c WHERE Id = :contactId ];
			
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
            possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Mentor__c = true ORDER BY Name];
    	}
    	else if(thisPersonsRecordTypeName=='Related Party') {
            if(thisTmnContact.Related_Party_Type__c=='Co-Applicant') {
            	possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Co_Applicant__c = true ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Foster Parent\'s Relative') {
            	possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Foster_Parent_Relative__c = true ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Foster Parent\'s Child') {
            	possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Foster_Parent_Child__c = true ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Resident-Non Relative') {
            	possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Resident_Non_Relative__c = true ORDER BY Name];
            }
            else if(thisTmnContact.Related_Party_Type__c=='Pet') {
            	possibleCreds = [SELECT Name FROM Credential_Profile__c WHERE Optional_for_Pet__c = true ORDER BY Name];
            }
            else {
            	// DO NOTHING; something is wrong.  Add error handling here...???
            }
    	}
    	else {
    		// DO NOTHING; something is wrong.  Add error handling here...???
    	}
    }   

}