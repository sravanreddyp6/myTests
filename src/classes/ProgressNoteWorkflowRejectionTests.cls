@isTest
public with sharing class ProgressNoteWorkflowRejectionTests {
    static testmethod void simpleTests() {
        /*Contact c = new Contact(LastName = 'Last');
        insert c;
        Progress_Note__c pn = new Progress_Note__c(
            Person_Being_Served__c = c.Id,
            Start_Time__c = DateTime.now().addMinutes(-1),
            End_Time__c = DateTime.now(),
            Signature_on_File__c = 'Y',
            Approval_Status__c = 'Pending'
        );
        insert pn;
        pn.Approval_Status__c = 'Needs Refinement';
        update pn;
        pn = [
            SELECT Id, Signature_on_File__c FROM Progress_Note__c WHERE Id=:pn.Id
        ];
        System.assertEquals('N', pn.Signature_on_File__c); */
        
        TMN_Generic_Core_TestData data = new TMN_Generic_Core_TestData();
        
        Datetime startDateForNote = Datetime.newInstance(2014, 1, 1, 13, 0, 0);
        Datetime endDateForNote = Datetime.newInstance(2014, 1, 1, 15, 0, 0);
       	Progress_Note__c notetoTest = new Progress_Note__c(Service_Assignment__c= data.theSA.Id,Service_Code__c = data.theServiceCode.Id,Person_Being_Served__c = data.contactID,Admission__c = data.theAdm.Id,Start_time__c = startDateForNote,End_time__c = endDateForNote);
       	insert notetoTest;
       	
        notetoTest = [SELECT Id, Name, Approval_user__c,Approval_Status__c FROM progress_Note__c WHERE Id=:notetoTest.Id ];
        system.debug('Progress Note '+notetoTest);
        
        Test.startTest();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval.');
        req.setObjectId(notetoTest.Id);
        req.setNextApproverIds(new Id[] {UserInfo.getUserID()});
        system.debug('User id in context '+Userinfo.getUserId());
       	//Submit the Approval request
       	Approval.ProcessResult result = Approval.process(req);
       	system.debug('Result '+result.isSuccess());
       	system.debug('Approval Status '+notetoTest.Approval_status__c);
       	Test.stopTest();
       	
        notetoTest = [SELECT id, Approval_user__c, Approval_Status__c FROM Progress_Note__c WHERE id=:notetoTest.Id];
       	system.assertEquals(notetoTest.Approval_User__c, UserInfo.getUserID());
       	
       	List<id> newWorkItemIds = result.getNewWorkitemIds();
       	Approval.ProcessworkitemRequest req2 = new Approval.ProcessworkitemRequest();
       	req2.setComments('Approved. Enjoy!!!');
       	req2.setAction('Approve');
       	req2.setWorkitemId(newWorkItemIds.get(0));
       	Approval.ProcessResult result2 = Approval.process(req2);
       	
       	system.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        system.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
        
       	
    }
}