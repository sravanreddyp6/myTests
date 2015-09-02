@isTest
public class referrals_Controller_Test{
    static testMethod void testEdit2(){
        User testUser = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test','myfirst','mylast','NeuroRestorative');

        PageReference pageRef = Page.referral;
pageRef.getParameters().put('firstName','');
pageRef.getParameters().put('lastName','');
pageRef.getParameters().put('personGender','Male');
pageRef.getParameters().put('personAge','0');
pageRef.getParameters().put('personDOB','10/10/2010');


        Test.setCurrentPage(pageRef);
        recordtype rt = [select id from recordtype where DeveloperName ='NeuroRestorative' AND SobjectType ='Referral__c'];
        ApexPages.StandardController sc = new ApexPages.StandardController(new Referral__c(recordtype = rt));
        referrals_Controller controller = new referrals_Controller(sc);
        System.assert(controller.relParty != null);
        System.assert(controller.relPartyFile != null);
        System.assert(controller.currentRefId == null);
        controller.checkRedFlags();

//adding some extra items for %
//referralRecordType
        string myStr = controller.userIdToAssignTasks;
        boolean myBool = controller.showNeuroFeatures;
        integer myInt = controller.searchedServiceLocationResultSize;
        myInt = controller.searchedServiceLocationResultSize2;
        myBool = controller.gethasPrimaryFS();
        myStr = controller.relPartiesJSON;
        myStr = controller.locationsJSON;
        myBool = controller.hasNonClosedPrimaryLocation;
        myBool = controller.isLinkedPersonBeingServed;
        //myBool = controller.checkNRRequiredCloseAdmitFields();
        //myBool = controller.checkNRRequiredCloseNonAdmitFields();
       // controller.referralRecord.oldPBS__c = '123';
       // controller.unlinkPBS();
        controller.unsetStatusHelperFiels();

//


        controller.personBeingRefRecord.first_name__c = 'Kossi';
        controller.personBeingRefRecord.middle_initial__c ='T' ;
        controller.personBeingRefRecord.last_name__c = 'last';

        controller.createPBR();

        controller.ReferralRecord.state_for_preferred_service__c = 'indiana';

        controller.search2();

        controller.nameFilter2 = '*';
        controller.search2();

        controller.nameFilter2 = 'None';
        controller.search2();

        controller.cityFilter2 = '*';
        controller.search2();

        controller.cityFilter2 = 'None';
        controller.search2();

        controller.stateFilter2 = '*';
        controller.search2();

        controller.stateFilter2 = 'ca';
        controller.search2();

        controller.nameFilter2 = '';

        controller.cityFilter2 = '*';
        controller.search2();

        controller.cityFilter2 = 'None';
        controller.search2();

        controller.cityFilter2 = '';

        controller.stateFilter2 = 'ca';
        controller.search2();

        controller.stateFilter2 = '*';
        controller.search2();

        System.AssertEquals(controller.tmpResults2.size(),[select count() from service_location__c where state__c like '%']);    
    
    
        controller.nameFilter = '*';
        controller.search();

        controller.nameFilter = 'None';
        controller.search();

        controller.cityFilter = '*';
        controller.search();

        controller.cityFilter = 'None';
        controller.search();

        controller.stateFilter = '*';
        controller.search();

        controller.stateFilter = 'ca';
        controller.search();

        controller.nameFilter = '';

        controller.cityFilter = '*';
        controller.search();

        controller.cityFilter = 'None';
        controller.search();

        controller.cityFilter = '';

        controller.stateFilter = 'ca';
        controller.search();

        controller.stateFilter = '*';
        controller.search();

        System.AssertEquals(controller.tmpResults.size(),[select count() from service_location__c where state__c like '%']);    
    
    }


    static testMethod void testEdit() {
        User testUser = Referral_CreateTestData.createTestUser('testU3','ReferralTestUser3@tmn.com.test','myfirst','mylast','NeuroRestorative');

        PageReference pageRef = Page.referral;
        Test.setCurrentPage(pageRef);
        recordtype rt = [select id from recordtype where DeveloperName ='NeuroRestorative' AND SobjectType ='Referral__c'];
        ApexPages.StandardController sc = new ApexPages.StandardController(new Referral__c(recordtype = rt));
        referrals_Controller controller = new referrals_Controller(sc);
        System.assert(controller.relParty != null);
        System.assert(controller.relPartyFile != null);
        System.assert(controller.currentRefId == null);
        controller.checkRedFlags();

        controller.personBeingRefRecord.first_name__c = 'Kossi';
        controller.personBeingRefRecord.middle_initial__c ='T' ;
        controller.personBeingRefRecord.last_name__c = 'last';

        controller.createPBR();

        controller.ReferralRecord.state_for_preferred_service__c = 'indiana';

        Referral_CreateTestData.createServiceLocations('Testings',100);
        controller.resetSearchItems2();
        controller.search2();
        controller.getOffsetSize2();
        controller.Last2();
        controller.getDisableNext2();
        controller.getDisablePrevious2();
        controller.First2();
        controller.getDisableNext2();
        controller.getDisablePrevious2();
        controller.Next2();
        controller.Previous2();

        system.assert(controller.relParties.size() == 0);
        system.assert(controller.locations.size() == 0);
        system.assert(controller.activities.size() == 0);
        system.assert(controller.fundingSources.size() == 0);
        system.assert(controller.agencies.size() == 0);

        controller.showAddRelParty();
        controller.saveRelParty();
        system.assert(controller.relParties.size() == 1);

        controller.showAddAgency();
        controller.saveAgency();
        system.assert(controller.agencies.size() == 1);

        controller.showAddFundingSource();
        controller.saveFundingSource();
        system.assert(controller.fundingSources.size() == 1);

        controller.showAddActivity();
        controller.saveActivity();
        system.assert(controller.activities.size() == 1);

        controller.showAddLocation();
        controller.search();



        Referral_CreateTestData.createServiceLocations('Testing',100);
        controller.resetSearchItems();
        controller.search();
        controller.getOffsetSize();
        controller.Last();
        controller.getDisableNext();
        controller.getDisablePrevious();
        controller.First();
        controller.getDisableNext();
        controller.getDisablePrevious();
        controller.Next();
        controller.Previous();

        controller.saveLocation();
        system.assert(controller.locations.size() == 1);

        controller.saveRef();

        system.assert(controller.referralrecord.id!=null);

        sc = new ApexPages.StandardController(controller.referralrecord);
        controller = new referrals_Controller(sc);

        controller.referralrecord.oldPBR__c = controller.personbeingrefrecord.id;
        controller.referralrecord.person_being_referred__c = null;

        controller.saveRef();

        controller.unlinkPBR();

        system.assert([select oldpbr__c from referral__c where id =:controller.referralRecord.id].oldPBR__C==null && [select person_being_referred__c from referral__c where id =:controller.referralRecord.id].person_being_referred__c==controller.personbeingrefrecord.id);

        controller.redirectToSearch();

        Tmn_user__c tmnUser= [select id, operating_group__c from tmn_user__c where salesforce_user_account__c = :testUser.Id][0];
        tmnUser.operating_group__c= 'care meridian';
        update tmnUser;
        //update new User(id=testuser.id,operating_group__c='caremeridian');

        sc = new ApexPages.StandardController(new Referral__c(state_for_preferred_service__c='Indiana',person_being_referred__c=controller.personBeingRefRecord.id));
        controller = new referrals_Controller(sc);
        controller.saveRef();
        system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'+controller.referralrecord.name);
        System.assert(controller.referralrecord.name == 'IN' );
        System.assert([select name from referral__c where id=:controller.referralrecord.id].name.startsWithIgnoreCase('IN-'));
        System.assert([select name from referral__c where id=:controller.referralrecord.id].name !='IN-');
        System.assert([select name from referral__c where id=:controller.referralrecord.id].name.endsWith('2'));

        system.runas(testUser){
            sc = new ApexPages.StandardController(new Referral__c(person_being_referred__c=controller.personBeingRefRecord.id));
            controller = new referrals_Controller(sc);
            controller.saveRef();
            System.Assert([select name from recordtype where id =:controller.referralRecord.recordtypeid].name == 'CareMeridian');
            System.assert([select name from referral__c where id=:controller.referralrecord.id].name.endsWith('1'));
        }

        system.runas(testUser){
            sc = new ApexPages.StandardController(new Referral__c(person_being_referred__c=controller.personBeingRefRecord.id));
            controller = new referrals_Controller(sc);
            controller.saveRef();
            System.Assert(controller.referralrecord.name.startsWithIgnoreCase('CM'));
            System.assert([select name from referral__c where id=:controller.referralrecord.id].name.startsWithIgnoreCase('CM-'));
            System.assert([select name from referral__c where id=:controller.referralrecord.id].name !='CM-');
            System.assert([select name from referral__c where id=:controller.referralrecord.id].name.endsWith('2'));

        }

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
        Integer numberOfStepSubjects = Admission_Step__c.getAll().size();
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c rf = Referral_CreateTestData.createReferral('NeuroRestorative', 'New', 'Test123', pbr);
        sc = new ApexPages.StandardController(rf);
        controller = new referrals_Controller(sc);
        Task[] tasks = [
            SELECT Id FROM Task WHERE WhatId = :rf.Id
        ];
        Integer oldNumTask = tasks.size();
        User u = [ SELECT ID FROM User ][0];
        controller.dummyTask.OwnerId = u.Id;
        controller.addAdmissionSteps();
        System.assertEquals(oldNumTask + numberOfStepSubjects, controller.activities.size());
        
        controller.unlinkPBS();
    }
}