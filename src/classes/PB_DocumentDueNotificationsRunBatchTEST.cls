@isTest
private class PB_DocumentDueNotificationsRunBatchTEST {
    private static Contact person;  
    private static PB_AssociatedDoc__c assocDoc;
    
    static testMethod void myUnitTest() {
        SchedulableContext sc;
        PB_DocumentDueNotificationsRunBatch assocDocNotifier = new PB_DocumentDueNotificationsRunBatch();
        assocDocNotifier.execute(sc);
    }
    
    public class TestException extends Exception{
    }
    
    static testMethod void newTaskCreated() {
        createData();
        Database.BatchableContext BC;        
        PB_DocumentDueNotifications notif = new PB_DocumentDueNotifications('');
        notif.execute(BC, Database.query(PB_DocumentDueNotificationsRunBatch.query));
        System.assertequals([select id from task].size(), 1);
        notif.sendErrorEmail(new TestException());
    }        

    static testMethod void taskUpdated() {
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
                
        Database.BatchableContext BC;        
        PB_DocumentDueNotifications notif = new PB_DocumentDueNotifications('');
        notif.execute(BC, Database.query(PB_DocumentDueNotificationsRunBatch.query));
        System.assertequals([select id from task].size(), 1);  // no new task is created... instead the same is updated.
        System.assertequals([select id, Subject from task].get(0).Subject, 'Admission Document overdue');  // no new task is created... instead the same is updated.
    }    

    private static void createData(){
        //create a PBS and admission
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
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
                                            IsAdded__c = true,
                                            Due_Date__c = Date.TODAY().addDays(-1));
        insert assocDoc;
        
     
    }
}