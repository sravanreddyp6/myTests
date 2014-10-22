@isTest
private class Notes_ProgressNote_AddlActionsTEST {

    static testMethod void myUnitTest() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ESD General']; 
        
        User u = new User(Alias = 'testxxx1', Email='standarduser@testorg.com111', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com222');
        insert u;           
        
        // update permissions
        PermissionSet ps = [ select Id from PermissionSet where name='ESD_Notes_Clinical_Data_User'];
        PermissionSetAssignment psa = new PermissionSetAssignment( assigneeid=u.id, permissionsetid= ps.id);
        insert psa;
        
        // user is not in correct permission set yet
        System.runAs(u) {      
        // create a progress note
        
        List<RecordType> personAccountIds = new List<RecordType>();
        personAccountIds = [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
        
        List<RecordType> rtypes =  new List<RecordType>();
        rtypes = [SELECT id, DeveloperName from RecordType where SobjectType = 'Progress_note__c' AND IsActive = true AND DeveloperName Not IN ('NC_TFC','NC_Wks_1_6_TFC') LIMIT 1 ]; //Added by Sravan to Prevent validation error due to  Purpose_Service_is_Billable__c = true. 10/22/2014 4:15 PM.  
        Integer counter = 0;
        Boolean even = false;
        test.startTest();
        for(RecordType record_type: rtypes){
            counter++;
            TMN_Generic_Core_TestData myLoopData = new TMN_Generic_Core_TestData();
            
            /*
            Date myDate = date.newinstance(1960, 2, 17);
            
            Account acct = new Account(
            RecordTypeID=personAccountIds[0].id,
            FirstName= 'Test FName' + counter,
            LastName='Test LName' + counter,
            PersonBirthdate = myDate,
            PersonMailingStreet='test'  + counter + '@yahoo.com222',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SF',
            PersonMailingStateCode='NC',
            PersonEmail='test'  + counter + '@yahoo.com222',
            PersonHomePhone='1234567899',
            PersonMobilePhone='1234567899',
            Other_ID__pc = 'Other' + counter
            );
            insert acct;
            
           Id aPersonContactId;
           List<Account> myPersonContactIdList = [SELECT PersonContactId FROM Account WHERE Id = :acct.Id];
           aPersonContactId = myPersonContactIdList[0].PersonContactId;
                        
            Admission__c testAdm = new Admission__c(
                Name = 'TEST ADM' + counter,
                Person_Being_Served__c = aPersonContactId,
                Effective_Date__c = date.today(),
                state__c  = 'NC'
                
            );
            
            insert testAdm;
            
            Service_Assignment__c testServAssignment = new Service_Assignment__c(
                Admission__c = testAdm.Id,
                Person_Being_Served__c = aPersonContactId
            );
            insert testServAssignment;
            */    
            Service_Code__c testServCode = new Service_Code__c(
                Start_Date__c = date.newInstance(2012,1,1),
                FacilityID__c = '7',
                Program_Code__c = 'TEST PROGRAM CODE' + counter ,
                Location__c = 'TEST LOC CODE' + counter,
                Service_Line__c = 'TEST SVC LINE' + counter
            );
            insert testServCode;
            
            Progress_Note__c testPN = new Progress_Note__c(
                Service_Assignment__c = myLoopData.theSA.Id,
                Admission__c = myLoopData.theAdm.ID,
                Purpose_Service_is_Billable__c = true,
                Disregard_note__c = false,
                RecordTypeId = record_type.id,
              //  Start_Time__c = myLoopData.theSA.start_date__c.addDays(1),
                Start_Time__c = DateTime.newInstance(myLoopData.theSA.start_date__c.addDays(1),Time.newInstance(0, 0, 0, 0)),
              //  End_Time__c = myLoopData.theSA.start_date__c.addMinutes(30),
                End_time__c = DateTime.newInstance(myLoopData.theSA.start_date__c.addDays(1),Time.newInstance(0, 0, 30, 0)),
                Person_Being_Served__c = myLoopData.contactID ,
                No_Approval_Needed__c = true,
                Interventions__c = 'test',
                Notes_For_Next_Visit__c ='test',
                Progress__c ='test',
                Approval_Status__c = 'Approved'
            );
            insert testPN;  
            
            testPN.No_Approval_Needed__c  = true;
            update testPN;
                
            Plan__c testPlan = new Plan__c(
            Total_Interventions__c = 1,
            Total_Objectives__c = 1,
            Total_Short_Term_Goals__c = 1,
            Status__c = 'Inactive',
            Admission__c = myLoopData.theAdm.ID,
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
            
        }
        
        Progress_Note__c newtestPN = [ select id, Purpose_Service_Is_Billable__c, Disregard_Note__c, approval_status__c, ownerid from Progress_Note__c LIMIT 1];
        
        // now attempt the update
        System.AssertEquals(newtestPN.Purpose_Service_is_Billable__c, true);
        System.AssertEquals(newtestPN.Disregard_note__c, false);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newtestPN);
        Notes_ProgressNote_AddlActions objTestExt = new Notes_ProgressNote_AddlActions(sc);
        objTestExt.updateLocked();
        newtestPN = [ select id, Purpose_Service_Is_Billable__c, disregard_note__c, approval_status__c, ownerid from Progress_Note__c LIMIT 1];
        
        System.AssertEquals(newtestPN.Purpose_Service_is_Billable__c, false);
        System.AssertEquals(newtestPN.Disregard_note__c, true);
        
        Boolean userallowed = objTestExt.canDisregard;
        System.AssertEquals(true, userallowed);
        
        // update permissions to allow again
        ps = [ select Id from PermissionSet where name='ESD_Notes_Supervisor'];
        psa = new PermissionSetAssignment( assigneeid=u.id, permissionsetid= ps.id);
        insert psa;

        userallowed = objTestExt.canDisregard;
        System.AssertEquals(true, userallowed); 

        }
    }

}