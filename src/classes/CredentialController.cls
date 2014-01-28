public class CredentialController {

	public Id personID = apexpages.currentpage().getparameters().get('personid');
    public List<Credential_Record__c> AllRecords  {get;set;}
       
    public CredentialController() {
            AllRecords = [SELECT Name, Requested_Date__c, Received_Date__c, Expiration_Date__c, Note__c, Credential_Profile__r.Name, 
                Credential_Profile__r.Applies_Requested_Date__c, Credential_Profile__r.Applies_Received_Date__c, 
                Credential_Profile__r.Applies_Expiration_Date__c, Credential_Profile__r.Applies_Note__c
                FROM Credential_Record__c WHERE Person__c = :personID ORDER BY Credential_Profile__r.Name];
    }   
}