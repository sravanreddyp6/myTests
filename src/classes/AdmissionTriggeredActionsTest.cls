@isTest
private class AdmissionTriggeredActionsTest {
    private static Contact person;  
    private static PB_AssociatedDoc__c assocDoc;
    
    static testMethod void noAssocDocCreated() {
        createData();
        // create an admission should create the associatedDocs as well
        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
        insert adm;
        
        System.assertequals([select id from PB_AssociatedDoc__c].size(), 0);  // this is because only care Meridian user are allowed to create admission Docs with Admission record creation.
    }
    
    static testMethod void assocDocCreated() {
        createData();
        
        User careMeridianUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Care Meridian');
        
        List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
            TMN_Generic_Core_TestData.permsetAssign(permsets, careMeridianUser.Id);
        }
        TMN_User__c careMeridiantmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: careMeridianUser.id];
        
        system.runas(careMeridianUser){
	        // create an admission should create the associatedDocs as well
	        Admission__c adm = new Admission__c();
	        adm.person_being_served__c = person.id;
	        adm.Network_offering__c = 'ABI';
	        adm.Admission_Effective_Datetime__c = DateTime.Now();
	        insert adm;
	        
	        System.assertequals([select id from PB_AssociatedDoc__c].size(), 3);            
        }
    }
    
    private static void createData(){
    	
    	SystemSettings__c settings = SystemSettings__c.getOrgDefaults();
        settings.PB_AdmissionDocumentFeature__c = true;
        upsert settings;
    	
        //create a PBS and admission
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;
        
        //create document
        Id docRectypeID = Schema.SObjectType.PB_Document__c.getRecordTypeInfosByName().get('ABI').getRecordTypeId();
        PB_Document__c doc = new PB_Document__c(Document_Name__c = 'Test Doc', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null, RecordtypeId = docRectypeID, 
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Annually', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc1 = new PB_Document__c(Document_Name__c = 'Test Doc1', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  RecordtypeId = docRectypeID,
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Monthly', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        PB_Document__c doc2 = new PB_Document__c(Document_Name__c = 'Test Doc2', Due__c = 'Other', Effective_Date__c = Date.parse('10/10/2014'), Expiration_Date__c = null,  RecordtypeId = docRectypeID,
                                                 Recurring_Frequency__c = 'Recurring', Recurring_Interval__c = 'Quarterly', Status__c = 'Active', Type__c = 'Standard', Version__c = 1, External_ID__c = String.valueOf(Math.abs(Math.random())) );
        List<PB_Document__c> docs= new List<PB_Document__c>();
        docs.add(doc);
        docs.add(doc1);
        docs.add(doc2);
        insert docs;                                        
        
        //create a packet
        Id pktrectypeId = Schema.SObjectType.PB_DOCPacket__c.getRecordTypeInfosByName().get('ABI').getRecordTypeId();
        PB_DocPacket__c pckt = new PB_DocPacket__c(Packet_Name__c='Test Packet One', Status__c='Active', Default_Admission_Packet__c =true, Recordtypeid = pktrectypeId, External_ID__c = String.valueOf(Math.abs(Math.random())));
        insert pckt;
        
        //create the JOs 
        PB_DocPacket_Document_JO__c jo1 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc1.id);
        PB_DocPacket_Document_JO__c jo2 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc2.id);
        PB_DocPacket_Document_JO__c jo3 = new PB_DocPacket_Document_JO__c(DocPacket__c = pckt.id, Document__c = doc.id);
        List<PB_DocPacket_Document_JO__c> joList = new List<PB_DocPacket_Document_JO__c>();
        joList.add(jo1);
        joList.add(jo2);
        joList.add(jo3);
        insert (joList);
     
    }
}