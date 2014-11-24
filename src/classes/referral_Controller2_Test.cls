@isTest
public class referral_Controller2_Test{
    static testMethod void testView() {
        Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test');
        User testUser = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test');
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        ref.Person_Being_Served__c = null;
        Contact pbs = new Contact(LastName='Last Test', FirstName= 'Test First', Birthdate = Date.Today());
        insert pbs;
        Referral_Location__c loc = Referral_CreateTestData.createReferralLocation(testLoc.Name, '', 'New', testUser, ref );
        Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
        Funding_Source__c fund = Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval',
                                                        'Seniors', null, ref);
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started',
                                          testUser, Date.Today(), 'Test Comment', ref);

        PageReference pageRef = Page.referral2;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ref);
        referral_Controller2 controller = new referral_Controller2(sc);
        Funding_Source__c fundSourceProp = controller.fundingSource;
        system.assertEquals(Utility.getRecordTypeForFundingSource('Generic'), fundSourceProp.RecordTypeId);
        Task taskProp = controller.activity;
        system.assertEquals('Not Started', taskProp.status);
        Id refId = controller.currentRefId;
        system.assertEquals(null, refId);
        system.assertEquals(1, controller.relParties.size());
        system.assertEquals(1, controller.locations.size());
        system.assertEquals(1, controller.activities.size());
        system.assertEquals(1, controller.fundingSources.size());
        system.assertEquals(1, controller.agencies.size());

        controller.showAddRelParty();
        Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        controller.saveRelParty();
        system.assertEquals(2, controller.relParties.size());

        controller.showAddAgency();
        Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
        controller.saveAgency();
        system.assertEquals(2, controller.agencies.size());

        System.debug(controller.fundingSources);
        controller.showAddFundingSource();
        Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval', 'Seniors', null, ref);
        Funding_Source__c fs = controller.fundingSource;
        controller.saveFundingSource();
        controller.fundingSource.Id = fs.Id;
        controller.showEditFundingSource();
        System.debug(controller.fundingSources);
        system.assertEquals(3, controller.fundingSources.size());

        controller.showAddActivity();
        Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started', testUser, Date.Today(), 'Test Comment', ref);
        controller.saveActivity();
        system.assertEquals(2, controller.activities.size());

        controller.showAddLocation();

        Referral_CreateTestData.createServiceLocations('Testing',100);
        Referral_CreateTestData.createReferralLocation(testLoc.Name, '', 'New', testUser, ref );
        controller.saveLocation();
        system.assertEquals(2, controller.locations.size());
        System.assertEquals(0, controller.Attachments.size());
        System.assertEquals('', controller.OperatingGroup);

        ref.oldPBR__c = pbr.id;
        ref.person_being_referred__c = null;

        update ref;

        controller.unlinkPBR();

        ref.oldPBS__c = pbs.id;
        ref.person_being_served__c = null;
        update ref;

        controller.unlinkPBS();

        testUser.Operating_Group__c = 'Care meridian';
        update testUser;

        Tmn_user__c tmnUser = [SELECT ID, Operating_group__c FROM Tmn_user__c WHERE salesforce_user_account__c = :testUser.Id][0];
        tmnUser.operating_group__c = 'Care meridian';
        update tmnUser;
        system.runas(testUser){
            controller.addEvaluation();
        }

        controller.redirectToEdit();
        controller.redirectToSearch();
        controller.redirectToConversion();

        Referral__c rf = Referral_CreateTestData.createReferral('Generic', 'New', 'Test1235', pbr);
        rf.person_being_referred__c = null;
        update rf;
        sc = new ApexPages.StandardController(rf);
        controller = new referral_Controller2(sc);

        // Testing add referral tracking steps for Neuro
        insert new Neuro_Admission_Steps__c[] {
            new Neuro_Admission_Steps__c(Name='1', Subject__c='Subject 1'),
            new Neuro_Admission_Steps__c(Name='2', Subject__c='Subject 2'),
            new Neuro_Admission_Steps__c(Name='3', Subject__c='Subject 3')
        };
        Task[] tasks = [
            SELECT Id FROM Task WHERE WhatId = :rf.Id
        ];
        Integer oldNumTask = tasks.size();
        User u = [ SELECT ID FROM User ][0];
        controller.dummyTask.OwnerId = u.Id;
        controller.addNeuroAdmissionSteps();
        System.assertEquals(oldNumTask + 3, controller.activities.size());
    }
}