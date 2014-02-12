public class CredentialController {

	public Id contactID = apexpages.currentpage().getparameters().get('contactid');
    public List<Credential_Record__c> AllRecords  {get;set;}
       
    public CredentialController() {
            AllRecords = [SELECT Name, Requested_Date__c, Received_Date__c, Expiration_Date__c, Note__c, Exam_Date__c, Credential_Profile__r.Name, 
                Credential_Profile__r.Applies_Requested_Date__c, Credential_Profile__r.Applies_Received_Date__c, 
                Credential_Profile__r.Applies_Expiration_Date__c, Credential_Profile__r.Applies_Note__c, Credential_Profile__r.PBI__c,
                Credential_Profile__r.Applies_CPS_Full_Disclosure__c, CPS_Full_Disclosure_Required__c, Credential_Profile__r.Applies_State_Conviction__c,
                State_Conviction__c, Type_of_Conviction_State__c, Credential_Profile__r.Applies_Type_of_Conviction_State__c,
                Credential_Profile__r.Applies_Conviction_Past_5_State__c, Conviction_Past_5_Years_State__c,
                Credential_Profile__r.Applies_Federal_Conviction__c, Federal_Conviction__c, Type_of_Conviction_Federal__c, 
                Credential_Profile__r.Applies_Type_of_Conviction_Federal__c,
                Credential_Profile__r.Applies_Conviction_Past_5_Federal__c, Conviction_Past_5_Years_Federal__c, 
                Credential_Profile__r.Applies_FBI_Full_Disclosure__c, FBI_Full_Disclosure_Required__c,
                Credential_Profile__r.Applies_Exam_Date__c, Credential_Profile__r.Help_Text__c
                FROM Credential_Record__c WHERE TMN_Contact__c = :contactID ORDER BY Credential_Profile__r.Name];
    }
    
    public PageReference SaveCreds() {
    	
    	update AllRecords;
    	
    	PageReference myPageRef = new PageReference('/apex/MentorView?id=' + contactID);
    	return myPageRef;
    	
    }   
}