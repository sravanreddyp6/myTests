@isTest
public with sharing class ReferralLocationTriggeredActionsTest {
 // Test creating new PBR
  // Test creating new Referral w/child object records

  static testMethod void testNew() {
      Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test');
      User testUser = Referral_CreateTestData.createTestUser('testUzz','ReferralTestUser@tmn.com.test');
      User testUser2 = Referral_CreateTestData.createTestUser('testU2zz','ReferralTestUser2@tmn.com.test');
      
      Test.startTest();
      system.debug('TestNew');
      System.runAs(testUser){
  ApexPages.StandardController sc = new ApexPages.StandardController(new Referral__c());
    referrals_Controller controller = new referrals_Controller(sc);
    
      //create Person Being Served + Related Party
      controller.personBeingRefRecord.first_Name__c = 'Test';
      controller.personBeingRefRecord.last_Name__c = 'Test';
      controller.personBeingRefRecord.state__c = 'Massachusetts';
      controller.showAddRelParty();
      controller.relParty.Name = 'Test Party';
      controller.relParty.Type_String__c = 'Other';
      controller.saveRelParty();
      system.assert(controller.relParties.size() == 1);
      controller.createPBR();
      system.assert(controller.referralRecord.State_for_Preferred_Service__c == controller.personBeingRefRecord.state__c);
      
      //Create Location
      controller.showAddLocation();
      controller.location.Service_Location__c = testLoc.Id;
      controller.location.User_assigned__c = testUser.Id;
      controller.location.Status__c = 'Active';
      controller.saveLocation();
      
      
      //system.assert(controller.referralRecord.Assigned_Users__c  == 'Testing' );
      
      
          
       controller.referralRecord.Referral_Source_Type__c = 'Attorney';
          PageReference ref = controller.saveRef();
          system.assert(ref != null);
      }
    Test.stopTest();
  }

    static testMethod void testEdit() {
        system.debug('TestEdit');
        User testUser = Referral_CreateTestData.createTestUser('testUzz','ReferralTestUser@tmn.com.test','John','Smith');
        User testUser2 = Referral_CreateTestData.createTestUser('testU2zz','ReferralTestUser2@tmn.com.test','Bob','Jones');
        User testUser3 = Referral_CreateTestData.createTestUser('testU3zz','ReferralTestUser3@tmn.com.test','Mary','Miller');
        User testUser4 = Referral_CreateTestData.createTestUser('testU4zz','ReferralTestUser4@tmn.com.test','Pat','Johnson');
      
          
        
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'Closed', testUser, ref );
        Referral_Location__c loc2 = Referral_CreateTestData.createReferralLocation('Test Alias2', 'Test Location2', 'Active', testUser2, ref );
        Referral_Location__c loc3 = Referral_CreateTestData.createReferralLocation('Test Alias3', 'Test Location3', 'Active', testUser3, ref );
        
            
       /* 
        PageReference pageRef = Page.referral;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ref);
        referrals_Controller controller = new referrals_Controller(sc);
        system.debug(controller);
        system.assert(controller.locations.size() == 3);
        //system.assert(controller.referralRecord.Assigned_users__c == 'Bob Jones, Mary Miller');
       */
        loc.Status__c = 'Active';
        update loc;
        loc2.Status__c = 'Closed';
        update loc2;
        loc3.user_assigned__c = testuser4.id;
        update loc3;
        
      
    }

}