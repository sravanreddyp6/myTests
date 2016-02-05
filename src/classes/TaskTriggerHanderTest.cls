@isTest
private class TaskTriggerHanderTest {
    private static Contact person;	
    private static PB_AssociatedDoc__c assocDoc;
    private static Evaluation__c eval;
    

    static testMethod void taskUpdateFailUntilDocUpdate() {
        createData();
    	
    	//create a task for this associated Doc
        Task task = new Task( Subject = 'Admission Document Reminder', 
                                        Status = 'In Progress', 
                                        Priority = 'Normal', 
                                        OwnerId = UserInfo.getUserId(),
                                        Description = 'Document: '+ assocDoc.Document__r.Document_Name__c + ' for Admission: ' + person.FirstName + ' is due. ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + assocDoc.sObject_Id__c,
                                        WhoId = person.id, // person being served/contact id
                                        WhatId = assocDoc.Id,                
                                        ActivityDate = assocDoc.Due_Date__c);
        insert task;
        
        //try to update task when the asociated doc is still pending.. the update fails        
    	try {
	    	task.Status = 'Completed';
	    	update task;
    	} catch (Exception e){
    		System.assertequals('System.DmlException', e.getTypeName());
    		System.assertequals(e.getMessage().contains('Task can not be completed until the associated document status is updated to Received.'),true);
    	}
    }
    
    static testMethod void taskUpdateFailCMShiftAssessment() {
       createData();
        
        //create a task for the shift assessment
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.WhatId = eval.id;
        t.subject = 'Nurses Shift Documentation Status Reminder';
        t.Status = 'In Progress';
        t.Priority = 'Normal';
        t.Description = 'Nurses Shift Documentation '+eval.Name+' is waiting to be finalized.'+ System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + eval.Id;
        t.WhoId = person.id;
        t.ActivityDate = eval.Shift_End_Time__c.date();
        insert t;

        //try to update task when the asociated doc is still pending.. the update fails 
        try {
            t.Status = 'Completed';
            update t;
        } catch (Exception e){
            System.assertequals('System.DmlException', e.getTypeName());
            System.assertequals(e.getMessage().contains('This task cannot be upated as the Associated Nurses Shift Documentation is not finalized or Disregarded'),true);
        }
    }    
    
    private static void createData(){
    	//create a PBS and admission
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
        adm.Admission_Effective_DateTime__c = DateTime.now();
        insert adm;
        
        //create a document
        PB_Document__c doc = new PB_Document__c(Document_Name__c = 'Test Doc Two', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        insert doc;                                         
        
        //create a packet
        PB_DocPacket__c pckt = new PB_DocPacket__c(Packet_Name__c='Test Packet One', Status__c='Active', External_ID__c = String.valueOf(Math.abs(Math.random())));
        insert pckt;
        
        //create an associated doc.
        assocDoc = new PB_AssociatedDoc__c (DocPacket__c = pckt.id, 
                                            Document__c = doc.id,
                                            sObject_Id__c = adm.id,
                                            sObject_Type__c = 'Admission',
                                            Status__c = 'Pending',
                                            Due_Date__c = Date.TODAY());
        insert assocDoc;
        
        //create a Service_Assignment
        //create an Evaluation with the record type CMShiftAssessment 
        eval = new Evaluation__c (
                        //Name = 'test',
			            Status__c = 'Draft',
			            Shift_End_Time__c = Date.TODAY().AddDays(-1),
			            RecordtypeId = Utility.getEValuationRecordType('CMShiftAssessment') );
        insert eval;
    }
}