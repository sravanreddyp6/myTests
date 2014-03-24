@isTest(seeAllData=true)
private class HomePageSearchControllerTest {

    static testMethod void myUnitTest() {
        HomePageSearchController con = new HomePageSearchController();
        con.FirstNM = 'TestFirst';
        con.LastNM = 'TestLast';
        User testUser = Referral_CreateTestData.createTestUser('testU','ReferralTestUser@tmn.com.test','Test','Test','Redwood');
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(con.FirstNM,con.LastNM,25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        con.getTotalList();
       // con.Wrapper conwrapper = new con.Wrapper();
        //conwrapper.
    }
}