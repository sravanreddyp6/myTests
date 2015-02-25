@isTest
public class referral_Controller_Helper_Test{    
    static testmethod  void testLoadRelatedParty(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        
        test.startTest();
        Related_Party__c testRP = referral_Controller_Helper.loadRelatedParty(rp.Id);
        system.assert(testRP.Name == rp.Name);
        
        test.stopTest();
    }
    
    static testmethod  void testSaveRelatedParty(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        
        test.startTest();
        Related_Party__c testRP = referral_Controller_Helper.saveRelatedParty(
            rp.Id, 'Updated Test', 'Other', null, null, null, null, null, null, null, pbr.Id);
        system.assert(testRP.Name == 'Updated Test');
        system.assert(testRP.Id == rp.ID);
        
        Related_Party__c testRP2 = referral_Controller_Helper.saveRelatedParty(
            '', 'New Test', 'Other', null, null, null, null, null, null, null, pbr.Id);
        system.assert(testRP2.Name == 'New Test');
        test.stopTest();
    }
    
    static testmethod  void testLoadReferralLocation(){
        Profile prof = [select id, name from Profile where name ='System Administrator'];
        User testUser = new User(alias = 'testU',
                                email='dsurfleet@appirio.com',
                                emailencodingkey='UTF-8',
                                lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id,
                                timezonesidkey='America/Los_Angeles',
                                username='ReferralTestUser@tmn.com.test');
        insert testUser;
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'New', testUser, ref );
        
        test.startTest();
        PageReference pageRef = Page.Referral2;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ref);
        referral_Controller_Helper refC = new referral_Controller_Helper(sc);

        Referral_Location__c testLoc = referral_Controller_Helper.loadReferralLocation(loc.Id);
        system.assert(testLoc.User_Assigned__c == loc.User_Assigned__c);
        test.stopTest();
    }
    
    static testmethod  void testSaveReferralLocation(){
       
        User testUser = Referral_CreateTestData.createTestUser('testU','ReferralTestUser@tmn.com.test');
        User testUser2 = Referral_CreateTestData.createTestUser('testU2','ReferralTestUser2@tmn.com.test');
        
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'New', testUser, ref );
        
        test.startTest();
        Referral_Location__c testLoc = referral_Controller_Helper.saveReferralLocation(
            loc.Id, testUser2.Id, null, null, 'Primary', ref.Id);
        system.assert(testLoc.User_Assigned__c == testUser2.Id);
        system.assert(testLoc.Id == loc.ID);
        
        Referral_Location__c testLoc2 = referral_Controller_Helper.saveReferralLocation(
           '',  null, null, null, null, ref.Id);
        system.assert(testLoc2.Id != loc.ID);
        test.stopTest();
    }
    
    static testmethod  void testLoadAgencyInvolved(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
            
        test.startTest();
        Agency_Involved_With_Individual__c testAgency = referral_Controller_Helper.loadAgencyInvolved(agency.Id);
        system.assert(testAgency.Name == agency.Name);
        
        test.stopTest();
    }
    
    static testmethod  void testSaveAgencyInvolved(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
        
        test.startTest();
        Agency_Involved_With_Individual__c testAgency = referral_Controller_Helper.saveAgencyRemote(
            agency.Id, 'Updated Test', null, null, null, ref.Id);
        system.assert(testAgency.Name == 'Updated Test');
        system.assert(testAgency.Id == agency.ID);
        
        Agency_Involved_With_Individual__c testAgency2 = referral_Controller_Helper.saveAgencyRemote(
           '', 'New Test',  null, null, null,  ref.Id);
        system.assert(testAgency2.Name == 'New Test');
        test.stopTest();
    }
    
    static testmethod  void testLoadFundingSource(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Funding_Source__c fund = Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval', 
                                                        'Seniors', null, ref);
            
        test.startTest();
        Funding_Source__c testfund = referral_Controller_Helper.loadFundingSource(fund.Id);
        system.assert(testfund.Funding_Source_ID__c == fund.Funding_Source_ID__c);
        
        test.stopTest();
    }

    static testmethod  void testSaveFundingSource(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Funding_Source__c fund = Referral_CreateTestData.createFundingSource('California', 'Medicare', '123456', 'Pending Approval', 
                                                        'Seniors', null, ref);
            
        test.startTest();
        Funding_Source__c testFund = referral_Controller_Helper.saveFundingRemote(
            fund.Id, 'Medicaid', null, null, null,null, ref.Id);
        system.assert(testFund.recordTypeId == fund.recordTypeId, 'recordtype ids do not match: testFund=' + testFund.recordTypeId + '; fund=' + Fund.recordTypeId);
        system.assert(testFund.Funding_Source__c == 'Medicaid');
        system.assert(testFund.Id == fund.ID);
        
        Funding_Source__c testFund2 = referral_Controller_Helper.saveFundingRemote(
           '', 'Medicaid',  null, null, null,null,  ref.Id);
        system.assert(testFund2.Funding_Source__c == 'Medicaid');
        system.assert(testFund2.recordTypeId == Utility.getRecordTypeForFundingSource('Generic'), 'expected funding source record type of Generic.');
        
        test.stopTest();
    }  
    
    static testmethod void testLoadTask() {
        Profile prof = [select id, name from Profile where name ='System Administrator'];
        User testUser = new User(alias = 'testU',
                                email='dsurfleet@appirio.com',
                                emailencodingkey='UTF-8',
                                lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id,
                                timezonesidkey='America/Los_Angeles',
                                username='ReferralTestUser@tmn.com.test');
        insert testUser;
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started', 
                                          testUser, Date.Today(), 'Test Comment', ref);
        
        test.startTest();
        Task testTask = referral_Controller_Helper.loadTask(tsk.Id);
        system.assert(testTask.Subject == tsk.Subject);
        test.stopTest();
    }
    
    static testmethod void testSaveTask() {
        Profile prof = [select id, name from Profile where name ='System Administrator'];
        User testUser = new User(alias = 'testU',
                                email='dsurfleet@appirio.com',
                                emailencodingkey='UTF-8',
                                lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id,
                                timezonesidkey='America/Los_Angeles',
                                username='ReferralTestUser@tmn.com.test');
        insert testUser;
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started', 
                                          testUser, Date.Today(), 'Test Comment', ref);
        
        test.startTest();
        Task testTask = referral_Controller_Helper.saveTask(
            tsk.Id, 'Updated Subject', 'Normal', 'Not Started', testUser.Id, Date.Today().format(), 
                    'Test Comment', ref.Id);
        system.assert(testTask.Subject == 'Updated Subject');
        system.assert(testTask.Id == tsk.ID);
        
        Task testTask2 = referral_Controller_Helper.saveTask(
           '', 'New Subject', 'Normal', 'Not Started', testUser.Id, Date.Today().format(), 
                    'Test Comment', ref.Id);
        system.assert(testTask2.Subject == 'New Subject');        
        test.stopTest();
    }
}