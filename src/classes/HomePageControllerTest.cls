@isTest
private class HomePageControllerTest{
	public static Person_Being_Referred__c createPersonBeingReferred(String FirstName, String LastName, double age, Date dob) {
		Person_Being_Referred__c pbr = new Person_Being_Referred__c();
		pbr.First_Name__c = FirstName;
		pbr.Last_Name__c = LastName;
		if (age != null && age > 0) {
			pbr.Age__c = age;
		}
		if (dob != null) {
			pbr.Date_of_Birth__c = dob;
		}
		pbr.Gender__c = 'Male';
		pbr.State__c = 'MA';
		insert pbr;
		Person_Being_Referred__c testPBR = [Select Id,Name,Full_Name__c,State__c,First_Name__c, Last_Name__c, Age__c, Date_of_Birth__c From Person_Being_Referred__c a WHERE a.Id = :pbr.Id];
		return testPBR;
	}
    public static User createTestUserWithRole(string userAlias, string userName, string firstName, string lastName, string OperatingGroup, string DeveloperName) {
		Profile prof = [select id, name from Profile where name ='System Administrator'];
        UserRole ur = [select Id, Name, DeveloperName from USerRole where DeveloperName =: DeveloperName ];
        User testUser = new User(alias = userAlias,
                                email='dsurfleet@appirio.com',
                                emailencodingkey='UTF-8',
                                lastname=lastName,firstname=firstName, languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id, UserRoleId=ur.Id, 
                                timezonesidkey='America/Los_Angeles',
                                username=username + System.currentTimeMillis());/*,
                                operating_group__c=OperatingGroup);*/
        insert testUser;
        Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c=OperatingGroup, Salesforce_User_Account__c=testUser.id);
        insert tmnUser;

        return testUser;
    }


	static testMethod void test(){
		User testUser;
        User testUser2;
        User testUser3;
		User testUser4;
        User currUsr = [select Name from User where Id =:UserInfo.getUserId()];
		system.runAs(currUsr){
		 testUser = createTestUserWithRole('testU','ReferralTestUser@tmn.com.test','Test','Test','Redwood', 'AZ_Phoenix_Clinical_Users');
         testUser2 = createTestUserWithRole('testU2','ReferralTestUser2@tmn.com.test','Test','Test','CareMeridian', 'IA');
		 testUser3 = createTestUserWithRole('testU3','ReferralTestUser3@tmn.com.test','Test','Test','NeuroRestorative','IA');
		 testUser4 = createTestUserWithRole('testU4','ReferralTestUser4@tmn.com.test','Test','Test','Cambridge','IA');
        }
        Service_Location__c testLoc = Referral_CreateTestData.createServiceLocation('Test565');    
        Person_Being_Referred__c pbr = createPersonBeingReferred('testfname','testlname',25, null);
		Related_Party__c rp = Referral_CreateTestData.createRelatedParty('Test565', 'Other', pbr);
		Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test565', pbr);

		Referral_Location__c loc = Referral_CreateTestData.createReferralLocation('Test Alias565', 'Test Location', 'New', testUser, ref );
		Agency_Involved_With_Individual__c agency = Referral_CreateTestData.createAgencyInvolved('Test Agency', 'Test Reason', ref);
		Funding_Source__c fund = Referral_CreateTestData.createFundingSource('Generic', 'Medicare', '123456', 'Pending Approval',
				'Seniors', null, ref);
		Task tsk = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started',
				testUser, Date.Today(), 'Test Comment', ref);
		Task tsk1 = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started',
				testUser, Date.Today()+1, 'Test Comment', ref);
		Task tsk2 = Referral_CreateTestData.createReferralTask('Test Subject', 'Normal', 'Not Started',
				testUser, Date.Today()-1, 'Test Comment', ref);
		
		Test.startTest();
		System.runAs(testUser){

			PageReference pageRef = new PageReference('/apex/HomePage_Search');
			Test.setCurrentPage(pageRef);

			HomePageController controller = new HomePageController();
			//system.assert(controller.refrportlst.size() != 0);
			system.assert(controller.populateTasks.size() > 1);
			controller.viewstsk = 'Overdue';
			controller.mineTasks();
			controller.viewstsk = 'Today';
			controller.mineTasks();
			controller.viewstsk = 'Today+Overdue';
			controller.mineTasks();
			controller.viewstsk = 'Tomorrow';
			controller.mineTasks();
			controller.viewstsk = 'Next 7 Days';
			controller.mineTasks();
			controller.viewstsk = 'Next 7 Days+Overdue';
			controller.mineTasks();
			controller.viewstsk = 'This Month';
			controller.mineTasks();
            ApexPages.currentPage().getParameters().put('isIARole', 'true');
			controller.NewPlan();
			controller.newResponse();
			controller.saveResponse();
			controller.checkOverlap(DateTime.parse('11/6/2013 12:00 AM'), DateTime.parse('11/6/2015 12:00 AM'),DateTime.parse('11/6/2012 12:00 AM'), DateTime.parse('11/6/2014 12:00 AM'));
		}
		System.runAs(testUser2){
			PageReference pageRef = new PageReference('/apex/HomePage_Search');
			Test.setCurrentPage(pageRef);

			HomePageController controller = new HomePageController();
			controller.FrstName = 'testfname';
			controller.LstName = 'testlname';
			controller.getsearchNames();
			controller.checkOverlap(DateTime.parse('11/6/2014 12:00 AM'), DateTime.parse('11/6/2013 12:00 AM'),DateTime.parse('11/6/2013 12:00 AM'), DateTime.parse('11/6/2014 12:00 AM'));
		}
		System.runAs(testUser3){
			PageReference pageRef = new PageReference('/apex/HomePage_Search');
			Test.setCurrentPage(pageRef);

			HomePageController controller1 = new HomePageController();
			controller1.getviewvalues();
			controller1.FrstName = '';
			controller1.LstName = '';
            controller1.checkOverlap(DateTime.parse('11/6/2014 12:00 AM'), null,DateTime.parse('11/6/2013 12:00 AM'), DateTime.parse('11/6/2014 12:00 AM'));

		}
		System.runAs(testUser4){
			PageReference pageRef = new PageReference('/apex/HomePage_Search');
			Test.setCurrentPage(pageRef);

			HomePageController controller = new HomePageController();
		}
		PageReference pageRef = new PageReference('/apex/HomePage_Search');
		Test.setCurrentPage(pageRef);


		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		insert new TMN_User__c(
				Salesforce_User_Account__c = UserInfo.getUserId(),
				Operating_Group__c = 'Corporate'
				);
		HomePageController controller = new HomePageController();
		controller.getSearchResults();
		controller.FrstName = testData.theAccount.FirstName;
		controller.getSearchResults();
		controller.searchResultPBS = testData.contactId;
		controller.highlightSearchResultPBS();

		controller.getListApprovals();
		controller.sortColumn = '1';
		controller.sortOrder = 'asc';
		controller.mineTasks();
		Test.stopTest();
	}

	// SHAUN-47:  Method added to test new code that checks for presence of TMN_User__c record, and throws error on ESD Home page if not present. J. Gilliam, 10/16/14.
	static testMethod void testTmnUserCheck() {
		Profile prof = [select id, name from Profile where name ='System Administrator'];
        UserRole ur = [select Id, Name, DeveloperName from USerRole where DeveloperName =: 'AZ_Phoenix_Clinical_Users' ];
		User testUserAlpha = new User(alias = 'testAlp',
				email='testAlpha@thementornetwork.com',
				emailencodingkey='UTF-8',
				lastname='TestAlphaLastName',firstname='TestAlphaFirstName', languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = prof.Id, UserRoleId=ur.Id,
				timezonesidkey='America/New_York',
				username='testAlpha' + System.currentTimeMillis() + '@thementornetwork.com');
		insert testUserAlpha;

		List<TMN_User__c> tmnUserRecs = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :testUserAlpha.Id LIMIT 1 ];
		Integer countTmnUsers = 0;
		for(TMN_User__c tu : tmnUserRecs) {
			countTmnUsers++;
		}

		System.assert(countTmnUsers==0);

		System.runAs(testUserAlpha) {
			PageReference pageRef = Page.Home;
			Test.setCurrentPage(pageRef);

			// Negative path test:  Confirm thrown error if user doesn't have a TMN_User__c record.
			try {
				HomePageController controller = new HomePageController();
			}
			catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}

			TMN_User__c aTmnUserRec = new TMN_User__c(Salesforce_User_Account__c = testUserAlpha.Id);
			insert aTmnUserRec;

			// Positive path test:  Confirm no error if user has a TMN_User__c record.
			HomePageController controller2 = new HomePageController();

			tmnUserRecs.clear();
			tmnUserRecs = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :testUserAlpha.Id LIMIT 1 ];
			countTmnUsers = 0;
			for(TMN_User__c tu : tmnUserRecs) {
				countTmnUsers++;
			}

			// Further confirms that more than zero TMN_User__c records exist for our user when instantiation of the constructor succeeds.
			System.assert(countTmnUsers>0);
		}

	}
    static testMethod void unitTest() {
        TMN_User__c tmnRW  = new TMN_User__c(Operating_Group__c = 'Redwood', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmnRW;
       	HomePageController homeCr = new HomePageController();
		List<String> objnm = homeCr.objname;
        String obj = homeCr.objectName;
        String og = homeCr.getOperatingGroup();
        Id saidAc = homeCr.serviceAssignmentIdForAction;
        HomePageController.wrapper homeCntr = new HomePageController.wrapper(Id.valueOf('000000000000000000'),Id.valueOf('000000000000000000'),Id.valueOf('000000000000000000'),'test',Datetime.now(),'test','test');
		homeCr.checkOverlap(DateTime.parse('11/6/2014 12:00 AM'), DateTime.parse('11/6/2014 12:00 AM'),DateTime.parse('11/6/2014 12:00 AM'), DateTime.parse('11/6/2014 12:00 AM'));

	}

}