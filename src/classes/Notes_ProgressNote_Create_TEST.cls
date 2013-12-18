@isTest(SeeAllData=true)
private class Notes_ProgressNote_Create_TEST {

    static testMethod void myUnitTest() {
 
 		String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FNamefff',
			LastName='Test LNamefff',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com2222',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/1980')
		);
 		insert Accnt;
 		Accnt = [ select id, personcontactid from account where id= :Accnt.id ];
 		
 		
 		Progress_Note__c p = new Progress_Note__c();
 		ApexPages.StandardController sc = new ApexPages.StandardController(p);
 		
        PageReference pageRef = Page.Notes_ProgressNote_Create;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.currentPage().getParameters().put('state', 'NC');
        ApexPages.currentPage().getParameters().put('person', Accnt.personcontactid);
        Notes_ProgressNote_Create objNpncTest = new Notes_ProgressNote_Create(sc);
        System.Assert( objNpncTest.myRTs.size() > 0 );
        System.Assert( objNpncTest.rtOptions.size() > 0 );
        
       	ApexPages.currentPage().getParameters().put('state', '');
        objNpncTest = new Notes_ProgressNote_Create(sc);
           
       	ApexPages.currentPage().getParameters().put('state', 'AZ');
        objNpncTest = new Notes_ProgressNote_Create(sc);
		System.AssertEquals(1, p.Number_of_Required_Signatures__c);
		
		Notes_ProgressNote_Create objVoid = new Notes_ProgressNote_Create();
    }
}