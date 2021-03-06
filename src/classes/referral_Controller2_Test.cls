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
        Diagnosis__c diag = new Diagnosis__c(Status__c = 'InActive', PBR__c = pbr.Id); insert diag;
        Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started',
                                          testUser, Date.Today(), 'Test Comment', ref);

        PageReference pageRef = Page.referral2;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(ref);
        referral_Controller2 controller = new referral_Controller2(sc);
        Test.startTest();
        Funding_Source__c fundSourceProp = controller.fundingSource;
        system.assertEquals(Utility.getRecordTypeForFundingSource('Generic'), fundSourceProp.RecordTypeId);
        Diagnosis__c diagn = controller.diag;
        Task taskProp = controller.activity;
        system.assertEquals('Not Started', taskProp.status);
        Id refId = controller.currentRefId;
        system.assertEquals(null, refId);
        system.assertEquals(1, controller.relParties.size());
        system.assertEquals(1, controller.locations.size());
        system.assertEquals(1, controller.activities.size());
        system.assertEquals(1, controller.fundingSources.size());
        system.assertEquals(1, controller.diagnoses.size());
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
        
        controller.showAddDiagnosis();
        controller.saveDiagnosis();
        String digeditId = controller.diagEditId;
        ApexPages.currentPage().getParameters().put('diagnosisId',diag.Id);
        controller.showEditDiagnosis();        

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
        System.assertEquals(null, controller.OperatingGroup);

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

        Referral__c rf = Referral_CreateTestData.createReferral('NeuroRestorative', 'New', 'Test1235', pbr);
        rf.person_being_referred__c = null;
        update rf;
        sc = new ApexPages.StandardController(rf);
        controller = new referral_Controller2(sc);

        // Testing add referral tracking steps for Neuro
        insert new Admission_Step__c[] {
            new Admission_Step__c(Name='1', Subject__c='Subject 1', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro1'),
            new Admission_Step__c(Name='2', Subject__c='Subject 2', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro2'),
            new Admission_Step__c(Name='3', Subject__c='Subject 3', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro3'),
            new Admission_Step__c(Name='4', Subject__c='Schedule Assessment', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro4'),
            new Admission_Step__c(Name='5', Subject__c='Complete Assessment', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro5'),
            new Admission_Step__c(Name='6', Subject__c='Assessment follow-up with Referral Source', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro6'),
            new Admission_Step__c(Name='7', Subject__c='Upload CAT to iServe', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro7'),
            new Admission_Step__c(Name='8', Subject__c='Schedule a Red Flag call (if applicable)', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro8'),
            new Admission_Step__c(Name='9', Subject__c='Admission Scheduled', Record_Type__c='NeuroRestorative', Unique_Id__c='neuro9')
        };
        Task[] tasks = [
            SELECT Id FROM Task WHERE WhatId = :rf.Id
        ];
        Integer oldNumTask = tasks.size();
        User u = [ SELECT ID FROM User ][0];
        controller.dummyTask.OwnerId = u.Id;
        controller.addAdmissionSteps();
        System.assertEquals(oldNumTask + 9, controller.activities.size());
        
        List<Person_Being_Referred__c> refResults = controller.refResults;
        Id reflocId = controller.referralLocationId;
        String reflocName  = controller.referralLocationName;
        
        
        Related_Party__c rp1 = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        List<Related_Party__c> relParties = controller.relParties;
        relParties.add(rp1);
        String myStr = controller.relPartiesJSON;
        
        Referral_Location__c rl = new Referral_Location__c(referral__c =ref.id, Status__c = 'Active', Rank__c ='Primary');
        insert rl;
        List<Referral_Location__c> rloc = controller.locations;        
        rloc.add(rl);        
        Id nonCloId = controller.nonClosedPrimaryLocationId;
        
        Id uId  = controller.userIdToAssignTasks;
        Id pBRId = controller.personBeingRefId;
        Id pBSId = controller.personBeingServedId;
        boolean bool = controller.canConvert;
        boolean primFs = controller.gethasPrimaryFS();
        Boolean canUref = controller.canUpdateReferral;
        Boolean canUEval = controller.canUpdateEvaluation;
        Boolean canCEval = controller.canCreateEvaluation;
        Boolean showNF = controller.showNeuroFeatures;
        controller.saveAdmissionLocation();
        boolean checkRF = controller.checkRequiredFields();
        Funding_Source__c fund1 = new Funding_Source__c(referral__c =ref.id, Type_of_Coverage__c  = 'primary', Payer_Type__c = 'testing'); insert fund1;
        List<Funding_Source__c> fs1 = controller.fundingSources; fs1.add(fund1);
        Diagnosis__c diagnew = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id); insert diagnew;
        List<Diagnosis__c> diagl = controller.diagnoses; diagl.add(diagnew);
        boolean checkRF1 = controller.checkRequiredFields();
               
        Test.stopTest();
    }
    static testMethod void testView2() {
      
        Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test');
        User testUser = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test');
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test', 'Other', pbr);
        Referral__c rfcm = Referral_CreateTestData.createReferral('CareMeridian', 'New', 'Test1235', pbr);
        rfcm.Person_Being_Served__c = null;
        Contact pbs = new Contact(LastName='Last Test', FirstName= 'Test First', Birthdate = Date.Today());
        insert pbs;
        
        PageReference pageRef = Page.referral2;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(rfcm);
        referral_Controller2 controller = new referral_Controller2(sc);
        Test.startTest();
        
        boolean checkRF = controller.checkRequiredFields();
        Referral_Location__c rl = new Referral_Location__c(referral__c =rfcm.id, Status__c = 'Active', Rank__c ='Primary'); insert rl;
        List<Referral_Location__c> rloc = controller.locations;  rloc.add(rl);     
        
        Funding_Source__c fund = new Funding_Source__c(referral__c =rfcm.id, Type_of_Coverage__c  = 'primary'); insert fund;
        List<Funding_Source__c> fs = controller.fundingSources; fs.add(fund);
        boolean checkRF1 = controller.checkRequiredFields();
        boolean primFS = controller.gethasPrimaryFS();
        controller.redirectToConversion();
        
        Referral__c rf1 = Referral_CreateTestData.createReferral('Cambridge North Carolina', 'New', 'Test1235', pbr);
        rf1.person_being_referred__c = null;
        update rf1;
        sc = new ApexPages.StandardController(rf1);
        controller = new referral_Controller2(sc);
        boolean checkRF2 = controller.checkRequiredFields();
        
        Test.stopTest();
        
    }
    
}