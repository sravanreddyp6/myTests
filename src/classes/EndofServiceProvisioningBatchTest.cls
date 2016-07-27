@isTest
public with sharing class EndofServiceProvisioningBatchTest {
    @testSetup static void testData() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tUser', 'tUser@tmn.com' + System.currentTimeMillis(), 'CaseManagement', 'Test', 'Redwood');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','iServe_Case_Management','ESD_Referrals_Intaker_Light','  ESD_Referrals_Common','ESD_Referrals_Intaker', 'iServe_Provider_Management'}, testUser.id);
        }
    }
    static testMethod void simpleTests() {
        User u = [Select id from User where FirstName = 'CaseManagement' Limit 1];
        Test.startTest();
        system.runas( u ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData('OR');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'OR', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'OR', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            
            TMN_Provider__c tmnProvider = New TMN_Provider__c(First_Name__c='First',Last_Name__c='Last',Gender__c='Male',Provider_Type__c='General Business',
            Company_Agency_Name__c='TestCorp.',Website__c='www.abctest.com',Brokerage__c = newSLid1, Services_Provided__c ='All Services',
            Address_Street_1__c='address 123',Address_Street_2__c='	123 main street',City__c='salem',State__c ='OR',Status__c ='Approved');
            insert tmnProvider;
            
            TMN_Provider_Application__c TmnProviderApplication = New TMN_Provider_Application__c(Address_Street_1__c='ABC Street',Address_Street_2__c='APT 32332',City__c='Salem',State__c ='OR',
            Application_Date__c = date.today(),Enrollment_Type__c = 'New',Expiration_Date__c=date.today(),Provider__c=tmnProvider.id,status__c ='Approved');
            insert TmnProviderApplication;
            
            list<Service_Assignment_Provider_JO__c> juncObjList = New List<Service_Assignment_Provider_JO__c>();
            Service_Assignment_Provider_JO__c juncObjRecord = New Service_Assignment_Provider_JO__c(
               Disregard__c=False,Service_Assignment__c=coredata.theSA.Id,TMN_Provider__c=tmnProvider.id,Status__c ='Active',Start_Date__c=date.today(),end_date__c=date.today(),Services_Provided__c='All Test Services');
            juncObjList.add(juncObjRecord);
            Service_Assignment_Provider_JO__c juncObjRecord2 = New Service_Assignment_Provider_JO__c(
               Disregard__c=False,Service_Assignment__c=coredata.theSA.Id,TMN_Provider__c=tmnProvider.id,Status__c ='Pending',Start_Date__c=date.today(),end_date__c=date.today(),Services_Provided__c='All Test Services 2');
            juncObjList.add(juncObjRecord2);
            
            insert juncObjList;
            
            Id batchJobId = Database.executeBatch(new EndofServiceProvisioningBatch(), 30);
            
        }
        Test.stopTest();
    } 
    
    
    static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
        Service_location__c newSL = new Service_location__c( alias__c = alias,Service_Type__c='CM - Case Management', programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
        insert newSL;
        return newSL.Id;
    }
    static void permsetAssign(string[]permSets, Id assigntoId){
        system.debug('calling permsetassign');
        List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN :permSets];
        List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();
        for(PermissionSet ps : theSets){
            thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = assigntoId));
        }
        insert thepermAssigns;
    }
}