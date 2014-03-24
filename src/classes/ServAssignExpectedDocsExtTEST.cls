/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ServAssignExpectedDocsExtTEST {

    static testMethod void myUnitTest() {

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
        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;

        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Status__c = 'Active'
        );
        insert Adm;
        
        Service_Assignment__c ServAssign = new Service_Assignment__c(
        	Name = 'TEST SERV ASSIGN',
        	Admission__c = Adm.Id,
        	Person_Being_Served__c = aContactId,
        	Start_Date__c = date.today(),
        	Projected_Treatment_End_Date__c = date.today() + 180,
        	Status__c = 'Active',
        	Program__c = 'IFCS'
        );
        
        test.startTest();
        insert ServAssign;
		
    	Document__c caseDoc = new Document__c(
			Name = 'Case Document',
			Active__c = true,
			Auto_Include__c = true,
			Relative_Due_Date_Event__c = 'Client Tx Start',
			Relative_Due_Date_UOM__c = 'Day(s)',
			Relative_Due_Date_Units__c = 1,
			Required_From_Date__c = date.newInstance(date.today().year(), 1, 1),
			Required_To_Date__c = date.newInstance(date.today().year(), 12, 31),
			State__c = 'NC',
			Type__c = 'Case Document'
		);

		insert caseDoc;

    	Document__c caseDoc2 = new Document__c(
			Name = 'Case Document 2',
			Active__c = true,
			Auto_Include__c = true,
			Relative_Due_Date_Event__c = 'Calendar Month End',
			Relative_Due_Date_UOM__c = 'Day(s)',
			Relative_Due_Date_Units__c = 3,
			Required_From_Date__c = date.newInstance(date.today().year(), 1, 1),
			Required_To_Date__c = date.newInstance(date.today().year(), 12, 31),
			State__c = 'NC',
			Type__c = 'Case Document'
		);

		insert caseDoc2;

		ServiceAssignment_Document_JO__c mySadjo = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			File_Status__c = 'Filed',
			Relative_Due_Date_Event__c = 'Client Tx Start',
			Relative_Due_Date_UOM__c = 'Day(s)',
			Relative_Due_Date_Units__c = 1,
			Relative_Due_Date_Resolved__c = date.newInstance(date.today().year(),date.today().month(),date.today().day())
		);
		insert mySadjo;

		ServiceAssignment_Document_JO__c mySadjo2 = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			File_Status__c = 'Not Filed',
			Fixed_Due_Date__c = date.today() + 15
		);
		insert mySadjo2;

		ServiceAssignment_Document_JO__c mySadjo3 = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			File_Status__c = 'Not Filed',
			Fixed_Due_Date__c = date.today() + 5
		);
		insert mySadjo3;

		ServiceAssignment_Document_JO__c mySadjo4 = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			File_Status__c = 'Not Filed',
			Fixed_Due_Date__c = date.today() - 1
		);
		insert mySadjo4;

		ServiceAssignment_Document_JO__c mySadjo5 = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			Fixed_Due_Date__c = date.today() - 1,
			File_Status__c = ''
		);
		insert mySadjo5;

		//Use the PageReference Apex class to instantiate a page
       	PageReference pageRef = Page.ServAssignExpectedDocs;

       	//In this case, the Visualforce page named 'ServAssignExpectedDocs' is the starting point of this test method.
       	Test.setCurrentPage(pageRef);

       	//Instantiate and construct the controller class.  
       	ApexPages.StandardController sc = new ApexPages.StandardController(ServAssign);
       	ServAssignExpectedDocsExt myConExt = new ServAssignExpectedDocsExt(sc);
        
        // INSERT a ServiceAssignment_Document_JO__c record with the saveFilings method.
        myConExt.sadjToSave = mySadjo.Id;
        myConExt.saveFilings();
        
        // SELECT the ServiceAssignment_Document_JO__c record into a variable.
        List<ServiceAssignment_Document_JO__c> testSadjo = [ SELECT Id FROM ServiceAssignment_Document_JO__c WHERE Id = :mySadjo.Id ];
        
        // Confirm that there is a saved record in the variable.
        System.assert(testSadjo.size()==1);
        
        // Confirm that the record(s) in the variable have the same ID as the test record(s) created in this test method.
        for(ServiceAssignment_Document_JO__c tS : testSadjo) {
        	System.assert(tS.Id==mySadjo.Id);
        }
        

        myConExt.sadjToSave = mySadjo2.Id;
		//myConExt.saveFilings();
		ServAssignExpectedDocsExt.saveSadjoRemote(mySadjo2.Id,'TEST NA REASON','Filed');
		// Confirm that the listOfDocFilings now contains one record.
		//System.assert(myConExt.listOfDocFilings.size()==1);
		System.debug('listOfDocFilings size: ' + myConExt.listOfDocFilings.size());
		
		myConExt.sadjToDelete = mySadjo2.Id;
		myConExt.RemoveDoc();
		
		
		// Try to select the document filing just deleted into a variable.
		List<ServiceAssignment_Document_JO__c> theDocFiling = [ SELECT Id FROM ServiceAssignment_Document_JO__c WHERE Id = :mySadjo2.Id ];
		
		// Confirm that the deleted document is gone by asserting that theDocFiling has size 0.
		System.assert(theDocFiling.size()==0);
		
		myConExt.RemoveDoc();
		

		ServiceAssignment_Document_JO__c mySadjo6 = new ServiceAssignment_Document_JO__c(
			Document__c = caseDoc.Id,
			Service_Assignment__c = ServAssign.Id,
			Filed_Date_Time__c = datetime.now(),
			Fixed_Due_Date__c = date.today()
		);
		insert mySadjo6;

		ServAssignExpectedDocsExt.saveSadjoRemote(mySadjo6.Id,'TEST NA REASON','Filed');
		ServAssignExpectedDocsExt.loadSadjo(mySadjo6.Id);
        
    }
}