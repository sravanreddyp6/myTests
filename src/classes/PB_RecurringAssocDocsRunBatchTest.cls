@isTest
private class PB_RecurringAssocDocsRunBatchTest {
    
    static testMethod void myUnitTest() {
        SchedulableContext sc;
        PB_RecurringAssocDocsRunBatch recurrDoc = new PB_RecurringAssocDocsRunBatch();
        recurrDoc.execute(sc);
    }
    
    public class TestException extends Exception{
    }
    
    static testMethod void newRecurrDocCreated() {
        createData();
        Database.BatchableContext BC;        
        PB_RecurringAssocDocs recurr = new PB_RecurringAssocDocs('');
        system.debug('The associated Docs: ' + Database.query(PB_RecurringAssocDocsRunBatch.query));
        recurr.execute(BC, Database.query(PB_RecurringAssocDocsRunBatch.query));
        
        system.assertequals([select id from PB_AssocDocRecurrence__c].size(), 3); //new recurr doc created
        system.assertequals([select id, Status__c from PB_AssociatedDoc__c].get(0).Status__c, 'Pending'); //the existing one is marked due again
        
        recurr.sendErrorEmail(new TestException());
    }
    
    private static void createData(){
        //create a PBS and admission
        Contact person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
        adm.Admission_Effective_DateTime__c = DateTime.now();
        insert adm;
        
        //create document
        PB_Document__c doc = new PB_Document__c(Document_Name__c = 'Test Doc', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc1 = new PB_Document__c(Document_Name__c = 'Test Doc1', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Monthly', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc2 = new PB_Document__c(Document_Name__c = 'Test Doc2', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Quarterly', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        List<PB_Document__c> docs= new List<PB_Document__c>();
        docs.add(doc);
        docs.add(doc1);
        docs.add(doc2);
        insert docs;
        
        //create a packet
        PB_DocPacket__c pckt = new PB_DocPacket__c(Packet_Name__c='Test Packet One', Status__c='Active', External_ID__c = String.valueOf(Math.abs(Math.random())));
        insert pckt;
        
        //create an associated doc.
        PB_AssociatedDoc__c assocDoc = new PB_AssociatedDoc__c (DocPacket__c = pckt.id, 
                                            Document__c = doc.id,
                                            sObject_Id__c = adm.id,
                                            sObject_Type__c = 'Admission',
                                            Status__c = 'Received',
                                            IsAdded__c = true,
                                            Status_Date__c = Date.TODAY().addDays(-1).addYears(-1));
        //create an associated doc.
        PB_AssociatedDoc__c assocDoc1 = new PB_AssociatedDoc__c (DocPacket__c = pckt.id, 
                                            Document__c = doc1.id,
                                            sObject_Id__c = adm.id,
                                            sObject_Type__c = 'Admission',
                                            Status__c = 'Received',
                                            IsAdded__c = true,
                                            Status_Date__c = Date.TODAY().addDays(-1).addYears(-1));
        //create an associated doc.
        PB_AssociatedDoc__c assocDoc2 = new PB_AssociatedDoc__c (DocPacket__c = pckt.id, 
                                            Document__c = doc2.id,
                                            sObject_Id__c = adm.id,
                                            sObject_Type__c = 'Admission',
                                            Status__c = 'Received',
                                            IsAdded__c = true,
                                            Status_Date__c = Date.TODAY().addDays(-1).addYears(-1));
        List<PB_AssociatedDoc__c> assocdocs= new List<PB_AssociatedDoc__c>();
        assocdocs.add(assocdoc);
        assocdocs.add(assocdoc1);
        assocdocs.add(assocdoc2);
        insert assocdocs;
     
    }
}