@isTest
private class PB_DocPack_Admin_FormTest {

    static testMethod void myUnitTest() {
        PB_DocPacket__c pckt = new PB_DocPacket__c(Default_Admission_Packet__c=true,
                                                External_ID__c = String.ValueOf(Math.random()),
                                                Packet_Name__c = 'Test Packet' + String.ValueOf(Math.random()),
                                                Status__c = 'Active');
        insert pckt;
                                                
        PB_Document__c doc1 = new PB_Document__c(Document_Name__c = 'Test Doc One', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc2 = new PB_Document__c(Document_Name__c = 'Test Doc Two', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc3 = new PB_Document__c(Document_Name__c = 'Test Doc Three', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        List<PB_Document__c> docList = new List<PB_Document__c>();
        docList.add(doc1);
        docList.add(doc2);
        docList.add(doc3);
        insert (docList);
                                                        
        PB_DocPacket_Document_JO__c jo1 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc1.id);
        PB_DocPacket_Document_JO__c jo2 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc2.id);
        PB_DocPacket_Document_JO__c jo3 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc3.id);
        List<PB_DocPacket_Document_JO__c> joList = new List<PB_DocPacket_Document_JO__c>();
        joList.add(jo1);
        joList.add(jo2);
        joList.add(jo3);
        insert (joList);
        
    	PageReference ref = new PageReference('/apex/PB_DocPack_Admin_Form');
        Test.setCurrentPage(ref);
        
        
        PB_DocPack_Admin_Form cntroller = new PB_DocPack_Admin_Form(new ApexPages.StandardController(pckt));
        cntroller.SelectedDocPacket.Packet_Name__c = 'Test Packet New';
        cntroller.SavePack();
        
        cntroller.SelectedDocument = new PB_Document__c(Document_Name__c = 'Test Doc One - new', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', 
                                                 Version__c = 1 );
        cntroller.miniFormTreeSelectedKeys = string.valueOf(pckt.id);

        cntroller.SaveDoc();
        
        cntroller.resetMiniForm();
        Apexpages.currentPage().getParameters().put('itemID', jo1.id);
        cntroller.editItem();
        System.assertequals(true, cntroller.dataTree != null);                 
    }
    
    
    
}