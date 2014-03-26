@isTest
public with sharing class AccountEditTest {
    static testmethod void simpleTests() {
    	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
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
        Accnt = [
            SELECT ID, PersonContactId FROM Account WHERE ID=:Accnt.ID LIMIT 1
        ];
        AccountEditExtension con = new AccountEditExtension(new ApexPages.Standardcontroller(Accnt));
        PageReference ref = con.redirectToContact();
        System.assertEquals('/apex/PersonBeingServedEditNew?edit=true&id=' + Accnt.PersonContactID,
            ref.getUrl());
            
        AccountviewExtension con2 = new AccountViewExtension(new ApexPages.Standardcontroller(Accnt));
        PageReference ref2 = con2.redirectToContact();
        System.assertEquals('/apex/PersonBeingServedEditNew?id=' + Accnt.PersonContactID,
            ref2.getUrl());
            
        delete Accnt;
 
        
    }
}