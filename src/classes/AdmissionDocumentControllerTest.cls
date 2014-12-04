@isTest
private class AdmissionDocumentControllerTest {
	static Contact person;
	static Admission__c adm;
	static List<PB_DocPacket_Document_JO__c> joList;
	static PB_DocPacket__c pckt;
	static PB_Document__c doc1;
		
    static testMethod void AddOneDoc() {
    	createObjects();
    	
		PageReference pageRef = Page.AdmissionView;
        Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('selectedKey', joList[0].id);
		Apexpages.currentPage().getParameters().put('isSelected', String.valueOf(true));

    	AdmissionDocumentController extension =  new AdmissionDocumentController(new ApexPages.StandardController(adm));		
		System.assertequals(0, extension.getAllAssociatedDocs().size());
		
		extension.updateDocSelection();	
		extension.saveAdmissionDoc();		
		System.assertequals(1, extension.getAllAssociatedDocs().size());

    }

    static testMethod void EditAssocDoc() {
    	createObjects();
    	
    	PB_AssociatedDoc__c newDoc = new PB_AssociatedDoc__c (	DocPacket__c = pckt.id, 
																Document__c = doc1.id,
																sObject_Id__c = adm.id,
																sObject_Type__c = 'Admission',
																Status__c = 'Initial');
    	insert newDoc;
    	
		PageReference pageRef = Page.AdmissionView;
        Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('selectedKey', joList[0].id);

    	AdmissionDocumentController extension =  new AdmissionDocumentController(new ApexPages.StandardController(adm));		
		System.assertequals(1, extension.getAllAssociatedDocs().size());
		
		extension.editTreeNode();
		extension.currrentAssocDoc.Status__c ='Signed';
		extension.saveAdmissionDoc();

		System.assertequals('Signed', extension.getAllAssociatedDocs()[0].Status__c);
    }


    static testMethod void AddOnePacket() {
    	createObjects();
    	
		PageReference pageRef = Page.AdmissionView;
        Test.setCurrentPage(pageRef);
		Apexpages.currentPage().getParameters().put('selectedKey', pckt.id);		
		Apexpages.currentPage().getParameters().put('isSelected', String.valueOf(true));
    	AdmissionDocumentController extension =  new AdmissionDocumentController(new ApexPages.StandardController(adm));		

		extension.updateDocSelection();
		extension.saveAdmissionDoc();
		System.assertequals(3, extension.getAllAssociatedDocs().size());
    }

    
    
   private static void createObjects(){
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        adm = new Admission__c();
        adm.person_being_served__c = person.id;
        insert adm;

		//create a packet		
		pckt = new PB_DocPacket__c(Packet_Name__c='Test Packet One', Status__c='Active', External_ID__c = String.valueOf(Math.abs(Math.random())));
		insert pckt;

		//create three documents 
		doc1 = new PB_Document__c(Document_Name__c = 'Test Doc One', Due_Days__c	= 2, Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
												 Recurring__c = 'No', Recurring_Frequency__c = null, Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
		PB_Document__c doc2 = new PB_Document__c(Document_Name__c = 'Test Doc Two', Due_Days__c	= 2, Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  
												 Recurring__c = 'No', Recurring_Frequency__c = null, Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
		PB_Document__c doc3 = new PB_Document__c(Document_Name__c = 'Test Doc Three', Due_Days__c	= 2, Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,
												 Recurring__c = 'No', Recurring_Frequency__c = null, Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
		List<PB_Document__c> docList = new List<PB_Document__c>();
		docList.add(doc1);
		docList.add(doc2);
		docList.add(doc3);
		insert (docList);
		
		//create the JOs 
		PB_DocPacket_Document_JO__c jo1 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc1.id);
		PB_DocPacket_Document_JO__c jo2 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc2.id);
		PB_DocPacket_Document_JO__c jo3 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc3.id);
		joList = new List<PB_DocPacket_Document_JO__c>();
		joList.add(jo1);
		joList.add(jo2);
		joList.add(jo3);
		insert (joList);
			

    }
}