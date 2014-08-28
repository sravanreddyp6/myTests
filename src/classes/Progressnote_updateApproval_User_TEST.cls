@isTest(SeeAllData = True) 
//Using SeeAllData as Salesforce will throw an internal server when trying to reassign approval process in test class. The test data required
//for batch class cannot be created and hence used SeeAllData+ true to get the batch class covered.
private class Progressnote_updateApproval_User_TEST {
    static testmethod void runTests(){
        
        /*TMN_Generic_Core_TestData data = new TMN_Generic_Core_TestData();
        User u = TMN_Generic_Core_TestData.createUser('System Administrator','ali','test@tetstststs.com','fName','Lname','Cambridge');
        Datetime startDateForNote = Datetime.newInstance(2014, 1, 1, 13, 0, 0);
        Datetime endDateForNote = Datetime.newInstance(2014, 1, 1, 15, 0, 0);
        Progress_Note__c notetoTest = new Progress_Note__c(Service_Assignment__c= data.theSA.Id,Service_Code__c = data.theServiceCode.Id,Person_Being_Served__c = data.contactID,Admission__c = data.theAdm.Id,Start_time__c = startDateForNote,End_time__c = endDateForNote);
        insert notetoTest;
        
        notetoTest = [SELECT ID, Approval_User__c FROM Progress_Note__c WHERE Id=:notetoTest.Id];
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval.');
        req.setObjectId(notetoTest.ID);
        req.setNextApproverIds(new Id[] {UserInfo.getUserID()});
        //Submit the Approval request
         Approval.ProcessResult result = Approval.process(req);
        
        notetoTest = [SELECT ID, Approval_User__c FROM Progress_Note__c WHERE Id=:notetoTest.Id];
        
        list<id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessworkitemRequest req2 = new Approval.ProcessworkitemRequest();
        req2.setComments('Reassigned. Away from me now!!');
        req2.setAction('Reassigned');
        req2.setWorkitemId(newWorkItemIds.get(0));
        req2.setNextApproverIds(new Id[] {u.id});
        Approval.ProcessResult result2 = Approval.process(req2); */
      
        string query = 'SELECT ProcessInstance.TargetObjectID,Id,ProcessInstanceId,StepStatus FROM ProcessInstanceStep WHERE StepStatus =\'Reassigned\' AND processInstance.Status =\'Pending\' LIMIT 10';
    
       	Test.startTest();
        Progressnote_updateApproval_User p = new Progressnote_updateApproval_User(query);
        Database.executebatch(p);
        Test.StopTest();
        
        
    }

}