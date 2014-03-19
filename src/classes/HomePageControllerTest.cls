@isTest(seeAllData=true)
private class HomePageControllerTest{
    static testMethod void test(){
     
        Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test');
        User testUser = Referral_CreateTestData.createTestUser('testU','ReferralTestUser@tmn.com.test','Test','Test','Redwood');
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'New', testUser, ref );
        Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
        Funding_Source__c fund = Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval', 
                                                        'Seniors', null, ref);
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started', 
                                          testUser, Date.Today(), 'Test Comment', ref);
       

        User testUser2 = Referral_CreateTestData.createTestUser('testU2','ReferralTestUser2@tmn.com.test','Test','Test','CareMeridian');
        User testUser3 = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test','Test','Test','NeuroRestorative');
        User testUser4 = Referral_CreateTestData.createTestUser('testU4','ReferralTestUser4@tmn.com.test','Test','Test','Cambridge');
        
        
       
        Test.startTest();
        System.runAs(testUser){
            PageReference pageRef = Page.ReferralHome;
            Test.setCurrentPage(pageRef);
            HomePageController controller = new HomePageController();
            system.assert(controller.refrportlst.size() != 0);
           	ProcessInstanceWorkitem PIWI = [select Id,ProcessInstanceId,CreatedDate,ActorId,CreatedById,CreatedBy.Name,ProcessInstance.LastModifiedBy.Name,ProcessInstance.TargetObject.Name,ProcessInstance.LastModifiedById,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem order by CreatedDate desc limit 1];
            controller.getListApprovals();
            system.assert(controller.populateTasks.size() == 1);
            system.assert(controller.referralPrefix == Referral__c.sObjectType.getDescribe().getKeyPrefix());
           // system.asser(controller.ListApprovals.size()>1);
               }
        System.runAs(testUser2){
            PageReference pageRef = Page.ReferralHome;
            Test.setCurrentPage(pageRef);
            HomePageController controller = new HomePageController();
               }
        System.runAs(testUser3){
            PageReference pageRef = Page.ReferralHome;
            Test.setCurrentPage(pageRef);
            HomePageController controller = new HomePageController();
             }
        System.runAs(testUser4){
            PageReference pageRef = Page.ReferralHome;
            Test.setCurrentPage(pageRef);
            HomePageController controller = new HomePageController();
              }
        PageReference pageRef = Page.Home;
        Test.setCurrentPage(pageRef);
        HomePageController controller = new HomePageController();
        System.assertNotEquals('', controller.personsBeingServedViews.get('me'));
        System.assertNotEquals('', controller.personsBeingServedViews.get('all'));
        System.assertNotEquals('', controller.personsBeingServedViews.get('recent'));
        System.assertNotEquals('', controller.personsBeingServedViews.get('new'));
        Test.stopTest();
    }

}