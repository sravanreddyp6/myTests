@isTest
private class REF_HomePageController_Test{
    static testMethod void test(){
        createHomePageSetting();
        
      Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test');
      	User testUser = Referral_CreateTestData.createTestUser('testUref','ReferralTestUser@tmn.com.test1111','Test','Test','Redwood');
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'New', testUser, ref );
        Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
        Funding_Source__c fund = Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval', 
                                                        'Seniors', null, ref);
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started', 
                                          testUser, Date.Today(), 'Test Comment', ref);
        

      User testUser2 = Referral_CreateTestData.createTestUser('testU2','ReferralTestUser2@tmn.com.test','Test','Test','Care Meridian');
      User testUser3 = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test','Test','Test','NeuroRestorative');
      User testUser4 = Referral_CreateTestData.createTestUser('testU4','ReferralTestUser4@tmn.com.test','Test','Test','Cambridge');
        
      Test.startTest();
      System.runAs(testUser){
        PageReference pageRef = Page.ReferralHome;
        Test.setCurrentPage(pageRef);
        REF_HomePageController controller = new REF_HomePageController();
        system.assert(controller.refReports.size() == 0);
        system.assert(controller.listGroupChatter.size() == 0);
        system.assert(controller.listESDNews.size() == 0);
        system.assert(controller.myTasks.size() == 1);
        system.assert(controller.referralPrefix == Referral__c.sObjectType.getDescribe().getKeyPrefix());
        system.assert(controller.GroupChatterId == '000000000000001');
		system.assert(controller.GroupChatterLabel == 'Redwood News', 'Expecting GroupChatterLabel = Redwood; actually: ' + controller.GroupChatterLabel);
        system.assert(controller.refReports2.size() == 0);
        system.assert(controller.getrefVfReports().size() == 0);
        system.assert(controller.getReportsToShow('Redwood').contains('Active_Referrals_With_Diagnosis'));
      }
      System.runAs(testUser2){
        PageReference pageRef = Page.ReferralHome;
        Test.setCurrentPage(pageRef);
        REF_HomePageController controller = new REF_HomePageController();
		system.assert(controller.GroupChatterLabel == 'CareMeridian News', 'Expecting GroupChatterLabel = CareMeridian; actually: ' + controller.GroupChatterLabel);
        system.assert(controller.GroupChatterId == '000000000000002');
        system.assert(controller.refReports2.size() == 0);
        system.assert(controller.getrefVfReports().size() == 0);
        system.assert(controller.getReportsToShow('CareMeridian').contains('Referrals_with_Funding_and_Location'));
      }
        
      System.runAs(testUser3){
        PageReference pageRef = Page.ReferralHome;
        Test.setCurrentPage(pageRef);
        REF_HomePageController controller = new REF_HomePageController();
		system.assert(controller.GroupChatterLabel == 'NeuroRestorative News', 'Expecting GroupChatterLabel = Neuro; actually: ' + controller.GroupChatterLabel);
        system.assert(controller.GroupChatterId == '000000000000003');
        system.assert(controller.refReports2.size() == 0);
        system.assert(controller.getrefVfReports().size() == 0);
        system.assert(controller.getReportsToShow('NeuroRestorative').contains('Daily_Referrals'));
      }
      
      System.runAs(testUser4){
        PageReference pageRef = Page.ReferralHome;
        Test.setCurrentPage(pageRef);
        REF_HomePageController controller = new REF_HomePageController();
		system.assert(controller.GroupChatterLabel == 'Cambridge News', 'Expecting GroupChatterLabel = Cambridge; actually: ' + controller.GroupChatterLabel);
        system.assert(controller.GroupChatterId == '000000000000004');
        system.assert(controller.refReports2.size() == 0);
        system.assert(controller.getrefVfReports().size() == 0);
        system.assert(controller.getReportsToShow('Cambridge').contains('GA_Referrals_FIT_Program'));
      }
      Test.stopTest();
    }
    
    static void createHomePageSetting() {
        Home_Page_Settings__c settings = new Home_Page_Settings__c(
            			SetupOwnerId=UserInfo.getOrganizationID(),
            			Redwood_Chatter_Group_Label__c = 'Redwood News',
            			CareMeridian_Chatter_Group_Label__c = 'CareMeridian News',
            			Neuro_Chatter_Group_Label__c = 'NeuroRestorative News',
            			Cambridge_Chatter_Group_Label__c = 'Cambridge News',
        				Redwood_Chatter_Id__c = '000000000000001',
        				CareMeridian_Chatter_Group_Id__c = '000000000000002',
        				Neuro_Chatter_Group_Id__c = '000000000000003',
        				Cambridge_Chatter_Group_Id__c = '000000000000004');
		
        insert settings;
    }
}