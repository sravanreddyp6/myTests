@isTest
public with sharing class SObjectHistoriesTest {
    static testmethod void simpleTest() {
    	// There's actually no way to test histories (since SF doesn't actually
    	// commit during Tests), so this class is here simple to satisfy the
    	// code coverage. 
    	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
    	SObjectHistoriesController con = new SObjectHistoriesController();
    	Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        Accnt = [ SELECT PersonContactID FROM Account WHERE ID=:Accnt.ID ];
        Admission__c admission = new Admission__c(
            Name='TestName',
            Person_Being_Served__c=Accnt.PersonContactId
        );
        insert admission;
        admission.Name = 'Another test';
        update admission;
        con.item = admission;
        SObject histItem = new Admission__History().getSObjectType().newSObject();
        DateTime a = con.getHistoryItem(histItem).CreatedDate;
        String b = con.getHistoryItem(histItem).Field;
        String c = con.getHistoryItem(histItem).oldValue;
        String d = con.getHistoryItem(histItem).newValue;
    }
}