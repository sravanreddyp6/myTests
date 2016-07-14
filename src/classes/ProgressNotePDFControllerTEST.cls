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
 
 /*
 Need to vary my test cases so that I hit the if/else statements
 
 43         if (!serviceCodeList.isEmpty()){
 44             serviceNum = serviceCodeList[0].Name;
 45         }else{
 46             serviceNum = '';
 47         }
 48         personsBeingServed = [SELECT Id, Other_ID__pc from Account where PersonContactId =: progressNoteValues.Person_Being_Served__c];
 49         if(!personsBeingServed.isEmpty()){
 50             otherId = personsBeingServed[0].Other_ID__pc;
 51         }else{
 52             otherId = '';
 53         }
 54         serviceAssignments = [SELECT Id, Name from Service_Assignment__c where id =: progressNoteValues.Service_Assignment__c];
 55         recordTypes = [SELECT Id, Name, DeveloperName from RecordType where id =: progressNote.RecordTypeId];
 */
@isTest
private class ProgressNotePDFControllerTEST {       
    
    static testMethod void myUnitTest1() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
                
        List<RecordType> personAccountIds = new List<RecordType>();
        personAccountIds = [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
        
        List<RecordType> rtypes =  new List<RecordType>();
        rtypes = [SELECT id from RecordType where SobjectType = 'Progress_note__c' limit 1];
        Integer counter = 0;
        Boolean even = false;
        test.startTest();
        for(RecordType record_type: rtypes){
            /*counter++;
            Date myDate = date.newinstance(1960, 2, 17);
            
            Account acct = new Account(
            RecordTypeID=personAccountIds[0].id,
            FirstName= 'Test FName' + counter,
            LastName='Test LName' + counter,
            PersonBirthdate = myDate,
            PersonMailingStreet='test'  + counter + '@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='FL',
            PersonEmail='test'  + counter + '@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            Other_ID__pc = 'Other' + counter
            );
            insert acct; */
            
            upsert myData.theAccount;
            
           /*Id aPersonContactId;
           List<Account> myPersonContactIdList = [SELECT PersonContactId FROM Account WHERE Id = :acct.Id];
           aPersonContactId = myPersonContactIdList[0].PersonContactId;
            Contact contact = new Contact(
                LastName = 'Test LName' + counter,
                Other_ID__c = 'Other' + counter,
                account = acct
            );
            insert contact;*/
            
            //System.debug('PersonContactId = ' + aPersonContactId);
            //Admission__c testAdm = new Admission__c(
            //    Name = 'TEST ADM' + counter,
            //    Person_Being_Served__c = aPersonContactId,
            //    Effective_Date__c = date.today()
            //);
            //System.debug('On test number ' + counter + ' Record Type "' + record_type + '"');
            upsert myData.theAdm;
            
            /* Service_Assignment__c testServAssignment = new Service_Assignment__c(
                Admission__c = myData.theAdm.id,
                Person_Being_Served__c = aPersonContactId
            );
            insert testServAssignment; */
            upsert myData.theSA;   
               
                
            Service_Code__c testServCode = new Service_Code__c(
                Start_Date__c = date.newInstance(2012,1,1),
                FacilityID__c = 'TEST FAC ID' + counter,
                Program_Code__c = 'TEST PROGRAM CODE' + counter 
            );
            insert testServCode;
            
            Progress_Note__c testPN = new Progress_Note__c(
                Service_Assignment__c = myData.theSA.Id,
                Admission__c = myData.theAdm.id,
                Purpose_Service_is_Billable__c = false,
                RecordTypeId = record_type.id,
                Start_Time__c = myData.theSA.start_Date__c.addDays(1),
                End_Time__c = myData.theSA.start_Date__c.addDays(2),
                Person_Being_Served__c = myData.contactID,
                No_Approval_Needed__c = true,
                Approval_Status__c = 'Approved'
            );
            insert testPN;      
            Plan__c testPlan = new Plan__c(
            Total_Interventions__c = 1,
            Total_Objectives__c = 1,
            Total_Short_Term_Goals__c = 1,
            Status__c = 'Inactive',
            Admission__c = myData.theAdm.id,
            Long_term_Goal_1__c = 'TEST LONG TERM GOAL'         
            );
            insert testPlan;
            Short_Term_Goal__c testSTG = new Short_Term_Goal__c(
                Plan__c = testPlan.Id
            );
            insert testSTG;
            
            Objective__c testOBJ = new Objective__c(
                Plan__c = testPlan.Id,
                Short_Term_Goal__c = testSTG.Id
            );
            insert testOBJ;
            
            Intervention__c testINT = new Intervention__c(
                Objective__c = testOBJ.Id
            );
            insert testINT;
            PageReference pageRef = Page.Notes_ProgressNote_PDF_FL_FSS;
            Test.setCurrentPageReference(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testPN);
            ProgressNotePDFController objTestPDF = new ProgressNotePDFController(sc);
            objTestPDF.runOnInit();         

        }
        test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        List<RecordType> personAccountIds = new List<RecordType>();
        personAccountIds = [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
        //System.debug('SHOW personAccountIds: ' + personAccountIds);
        
        List<RecordType> rtypes =  new List<RecordType>();
        rtypes = [SELECT id from RecordType where SobjectType = 'Progress_note__c' limit 1];
        Integer counter = 0;
        Boolean even = false;
        test.startTest();
        for(RecordType record_type: rtypes){
            /* counter++;
            Date myDate = date.newinstance(1960, 2, 17);
            Account acct = new Account(
            RecordTypeID=personAccountIds[0].id,
            FirstName= 'Test FName' + counter,
            LastName='Test LName' + counter,
            PersonBirthdate = myDate,
            PersonMailingStreet='test'  + counter + '@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test'  + counter + '@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
            );
            insert acct; */
            
            upsert myData.theAccount;
            
           Id aPersonContactId;
           List<Account> myPersonContactIdList = [SELECT PersonContactId FROM Account WHERE Id = :myData.theAccount.id];
           aPersonContactId = myPersonContactIdList[0].PersonContactId;
            
           //System.debug('Show acct: ' + acct);  
           //System.debug('Show acct.PersonContactId: ' + acct.PersonContactId);
           //System.debug('aPersonContactId = ' + aPersonContactId);   
                
           // Contact contact = new Contact(
            //  LastName = 'Test LName' + counter,
            //  Other_ID__c = 'Other' + counter,
            //  account = acct
            //);
            //insert contact;
            ////System.debug('PersonContactId = ' + contact.id);
            
            
            /* Admission__c testAdm = new Admission__c(
                Name = 'TEST ADM' + counter,
                Person_Being_Served__c = aPersonContactId,
                Effective_Date__c = date.today()
            );
            //System.debug('On test number ' + counter + ' Record Type "' + record_type + '"');
            insert testAdm; */
            
            upsert myData.theAdm;
            
            /* Service_Assignment__c testServAssignment = new Service_Assignment__c(
                Admission__c = myData.theAdm.id,
                Person_Being_Served__c = aPersonContactId
            );
            insert testServAssignment; */
            
            upsert myData.theSA;
            
            Service_Code__c testServCode = new Service_Code__c(
                Start_Date__c = date.newInstance(2012,1,1),
                Service_Code__c = 'TEST SVC CODE' + counter,
                FacilityID__c = 'TEST FAC ID' + counter,
                Program_Code__c = 'TEST PROGRAM CODE' + counter 
            );
            insert testServCode;
                
            Progress_Note__c testPN = new Progress_Note__c(
                Service_Assignment__c = myData.theSA.id, 
                Service_Code__c = testServCode.Id, 
                Admission__c = myData.theAdm.id,
                Purpose_Service_is_Billable__c = false,
                RecordTypeId = record_type.id,
                Start_Time__c = myData.theSA.start_Date__c.addDays(1),
                End_Time__c = myData.theSA.start_Date__c.addDays(2),
                Person_Being_Served__c = aPersonContactId,
                No_Approval_Needed__c = true,
                Approval_Status__c = 'Approved'
            );
            insert testPN;
            Plan__c testPlan = new Plan__c(
            Total_Interventions__c = 1,
            Total_Objectives__c = 1,
            Total_Short_Term_Goals__c = 1,
            Status__c = 'Inactive',
            Admission__c = myData.theAdm.id,
            Long_term_Goal_1__c = 'TEST LONG TERM GOAL'         
            );
            insert testPlan;
            Short_Term_Goal__c testSTG = new Short_Term_Goal__c(
                Plan__c = testPlan.Id
            );
            insert testSTG;
            
            Objective__c testOBJ = new Objective__c(
                Plan__c = testPlan.Id,
                Short_Term_Goal__c = testSTG.Id
            );
            insert testOBJ;
            
            Intervention__c testINT = new Intervention__c(
                Objective__c = testOBJ.Id
            );
            insert testINT;
            
            ProgressNote_ServiceAssignment_mJO__c testPNAmjo = new ProgressNote_ServiceAssignment_mJO__c(
                Intervention__c = testINT.Id,
                Objective__c = testOBJ.Id,
                Short_Term_Goal__c = testSTG.Id,
                Progress_Note__c = testPN.Id
            );
            insert testPNAmjo;
            
            //Test the Visualforce Page and its controller
            PageReference pageRef = Page.Notes_ProgressNote_PDF_FL_FSS;
            Test.setCurrentPageReference(pageRef);
            
            //System.debug('Show me testPN here at the end... : ' + testPN);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testPN);
            ProgressNotePDFController objTestPDF = new ProgressNotePDFController(sc);
            objTestPDF.runOnInit();

        }
        test.stopTest();
    }
}