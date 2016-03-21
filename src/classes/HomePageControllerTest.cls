@isTest
private class HomePageControllerTest{
    private static TMN_Generic_Core_TestData testData;

    static testMethod void myUnitNoTmnUser() {
        try{
            HomePageController cntrlr = new HomePageController();
        } catch (HomePageController.TMN_User_Exception e){
            system.assert(true);
        } catch (Exception e2){
            throw new HomePageController.TMN_User_Exception('We should have never come here, thats because the tmn record isnt created yet and this class doesnt see all the org data.');
        }
    }
    
   
	static testMethod void testSearchAndStar() {
	
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith222', 'joe', 'smith', 'Redwood');
        List<UserRole> roles = [ select id from userrole where developername = 'MN' LIMIT 1];
        
        redwoodUser.userroleid = roles[0].id;
        update redwoodUser;
        
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
        	
      	    createData();
		    HomePageController cntrlr = new HomePageController();
            cntrlr.setPBSList();
            system.assertEquals(0, cntrlr.myPBSList.size());
            
            cntrlr.FrstName = 'FName';
            cntrlr.LstName = '';
            cntrlr.Prgm = '';
            cntrlr.getSearchResults();
            system.assertEquals(1, cntrlr.searchResultList.size());
            
            cntrlr.searchResultPBS = cntrlr.searchResultList.get(0).recordId;
            cntrlr.searchResultSA = cntrlr.searchResultList.get(0).saID;
            cntrlr.searchResultIsFav = true;
            cntrlr.setfocusPBS();
            system.assertEquals( 1, cntrlr.myPBSList.size());
            
            String userCookie = [ select favorite_pbs__c from user where id = :UserInfo.getUserId() LIMIT 1].favorite_pbs__c;
            system.assert( userCookie == cntrlr.searchResultPBS + '-' + cntrlr.searchResultSA + ';');
            
            cntrlr.searchResultIsFav = false;
            cntrlr.toggleFavorite();
            
            userCookie = [ select favorite_pbs__c from user where id = :UserInfo.getUserId() LIMIT 1].favorite_pbs__c;
            system.debug('whats fav: ' + userCookie );
            system.assert(String.IsBlank(userCookie));
        }
        
            
	}



   static testMethod void myUnitTestForTasks() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith222', 'joe', 'smith', 'Redwood');
        List<UserRole> roles = [ select id from userrole where developername = 'MN' LIMIT 1];
        
        redwoodUser.userroleid = roles[0].id;
        update redwoodUser;
        
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
        	Test.startTest();
            
            PageReference pageRef = Page.Home;
            Test.setCurrentPage(pageRef);
            
            //create ActionPlan, Assessment and Tasks for this user to ACK
            Action_Plan__c ap = createAction_Plan('MN');
            ap.Status__c = 'Active Final';
            ap.finalized_by__c = UserInfo.getUserId();
            ap.Finalized_Date__c = system.today();
            update ap;
            
            createAssessData();
            Assessment__c myIssa = TMN_Generic_Core_TestData.createAssessment(testData.theAdm, testData.theSA, 'ISSA', null, null, false);
            List<Assessment_Response__c> ars = [ SELECT Response__c, Rating__c FROM Assessment_Response__c WHERE Assessment__c = : myIssa.Id ];
            for(Assessment_Response__c ar : ars) {
                ar.Response__c = 'TEST';
                ar.Rating__c = 'Yes';
            }
            update ars;
            myIssa.Status__c = 'Active Final';
            myIssa.Approval_Date__c = date.newInstance(2014, 01, 01);
            update myIssa;
            
            list<Task> tasks = new list<Task>();
            tasks.add(new task(whatid=ap.id, OwnerId = UserInfo.getUserId(), Subject = 'Action Plan Acknowledgment',
                               Description = 'Please acknowledge that you have read the new version of the Action Plan', 
                               whoID = testData.ContactID));
            tasks.add(new task(whatid=myIssa.id, OwnerId = UserInfo.getUserId(), Subject = 'Action Plan Acknowledgment',
                               Description = 'Please acknowledge that you have read the new version of the Action Plan', 
                               whoID = testData.ContactID));
            tasks.add(new task(OwnerId = UserInfo.getUserId(), Subject = 'User Task',
                               Description = 'User task'));
            tasks.add(new task(OwnerId = UserInfo.getUserId(), Subject = 'User Task',
                               Description = 'User task', whoID = testData.ContactID));
            insert tasks;                    
            
            HomePageController cntrlr = new HomePageController();
            cntrlr.sortColumn = '1';
            cntrlr.sortOrder = 'Asc';
            cntrlr.mineTasks();
            system.assert(cntrlr.populateTasks.size() == 4);
            
            system.assert(cntrlr.getviewvalues().size() > 0);
            
            //create new ACK records
            list<Acknowledgment__c> acks = new list<Acknowledgment__c>();
            acks.add(new Acknowledgment__c(Assessment__c = myIssa.id, User__c = UserInfo.getUserId()));
            acks.add(new Acknowledgment__c(Action_Plan__c = ap.id, User__c = UserInfo.getUserId()));            
            insert acks;
            cntrlr.mineTasks();
            system.assert(cntrlr.populateTasks.size() == 2);
            
            Test.stopTest();
        }
    }
    
    private static void createData(){
        testData = new TMN_Generic_Core_TestData();
    }
    
    public static void createAssessData(){
        Assessment_Domain__c testDomain = new Assessment_Domain__c(Name = 'Other', Assessment_Type2__c = 'ISSA');
        insert testDomain;
        Assessment_Question__c testQuestion = new Assessment_Question__c(Question_Title__c = 'TEST QUESTION',Question_Description__c = 'A TEST QUESTION',Question_Domain__c = testDomain.Id);
        insert testQuestion;   
        Assessment_Question_Option__c op1 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = 'Presents a Risk');
        Assessment_Question_Option__c op2 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = 'Does Not Present a Risk');
        list<Assessment_Question_Option__c> questions = new list<Assessment_Question_Option__c>();
        questions.add(op1);
        questions.add(op2);
        insert questions;            
    }
    
    private static Action_Plan__c createAction_Plan( string state ){
        createData();
        testData.loadData( state);
        
        Action_Plan__c ap = new Action_Plan__c(
            Service_Assignment__c = testData.theSA.id,
            Target_Date__c = testData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = testData.theSA.start_Date__c
        );        
        insert ap; 
        
        Action_Plan_Goal__c apg = new Action_Plan_Goal__c(
            Description__c = 'a goal',
            Action_Plan__c = ap.id,
            sort_order__c = 'g'
        );
        insert apg;
        
        Action_Plan_Objective__c apo = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'an Objective',
            Type__c = 'skill',
            Target_End_Date__c = testData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = testData.theSA.Start_Date__c,
            sort_order__c = 'o'
        );
        insert apo;
        
        Action_Plan_Action__c apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.Start_Date__c = testData.theSA.Start_Date__c;
        apa.End_Date__c = testData.theSA.Start_Date__c.addDays(1);
        apa.Status__c = 'New';
        insert apa;
        
        return ap;
    }
    
    // test to check flags based on permission sets
    static testMethod void testCapabilities() {
        
        User cmTierI= TMN_Generic_Core_TestData.createUser('ESD General', 'cmtieri', 'cmtieri@tmn.com.testing', 'cm', 'tieri', 'Care Meridian');
        List<UserRole> roles = [ select id from userrole where developername = 'Care_Meridian' LIMIT 1];
        
        cmTierI.userroleid = roles[0].id;
        update cmTierI;
        TMN_Generic_Core_TestData.permsetAssign(new String[]{'ESD_Notes_Common','iServe_Tier_I'}, cmTierI.Id);
    	
    	system.runAs( cmTierI ) {
	    	PageReference pageRef = Page.Home;
	        Test.setCurrentPage(pageRef);
	        
	        HomePageController cntrlr = new HomePageController();
	        	
	    	system.assertEquals( true, cntrlr.cmTierI);
	    	system.assertEquals( false, cntrlr.cmTierII);
	    	system.assertEquals( false, cntrlr.cmDON);
    		system.assertEquals( true, cntrlr.canSeeCNAWorkbook );
    		system.assertEquals( false, cntrlr.canSeeShiftDoc);
    			
    	}
    	
    	TMN_Generic_Core_TestData.permsetAssign(new String[]{'iServe_Tier_III', 'iServe_DON'}, cmTierI.Id);
    	system.runAs( cmTierI ) {
	    	PageReference pageRef = Page.Home;
	        Test.setCurrentPage(pageRef);
	        
	        HomePageController cntrlr = new HomePageController();
	        	
	    	system.assertEquals( true, cntrlr.cmTierIII);
	    	system.assertEquals( true, cntrlr.cmDON);
    		system.assertEquals( true, cntrlr.canSeeCNAWorkbook );
    		system.assertEquals( true, cntrlr.canSeeShiftDoc);
    			
    	}
    	    	
 		User rwLevel3= TMN_Generic_Core_TestData.createUser('ESD General', 'rwlevel3', 'rwl3@tmn.com.testing', 'rw', 'level3', 'Redwood');
        roles = [ select id from userrole where developername = 'IA' LIMIT 1];
        
        rwlevel3.userroleid = roles[0].id;
        update rwlevel3;
        TMN_Generic_Core_TestData.permsetAssign(new String[]{'ESD_Notes_Common','ESD_Notes_RW_Level_3'}, rwlevel3.Id);
        system.runAs( rwlevel3 ) {
        	
	    	PageReference pageRef = Page.Home;
	        Test.setCurrentPage(pageRef);
	        
	        HomePageController cntrlr = new HomePageController();
	        	
	    	system.assertEquals( true, cntrlr.rwlevel3);
	    	system.assertEquals( true, cntrlr.isIARole);
    		system.assertEquals( false, cntrlr.canSeeCNAWorkbook );
    		system.assertEquals( false, cntrlr.canSeeShiftDoc);
    			
    	}
    	    	

    
    }
    
    // test IA-DAY functions
    static testMethod void IATest() {
		
		User rwLevel3= TMN_Generic_Core_TestData.createUser('ESD General', 'rwlevel3', 'rwl3@tmn.com.testing', 'rw', 'level3', 'Redwood');
        List<UserRole> roles = [ select id from userrole where developername = 'IA' LIMIT 1];
        
        rwlevel3.userroleid = roles[0].id;
        update rwlevel3;
        TMN_Generic_Core_TestData.permsetAssign(new String[]{'ESD_Notes_Common','ESD_Notes_RW_Level_3'}, rwlevel3.Id);
        system.runAs( rwlevel3 ) {
	    	
	    	createAction_Plan( 'IA');
	    	
	    	PageReference pageRef = Page.Home;
	        Test.setCurrentPage(pageRef);
	        
	        HomePageController cntrlr = new HomePageController();
			
			cntrlr.currSAID = testData.theSA.Id;
			system.assertNotEquals( null, cntrlr.newPlan());
			
			cntrlr.newResponse();
			system.assertEquals( null, cntrlr.saveResponse(), 'Cannot save without data');		        	
    			
    	}    	
    }
    
    
    static testMethod void unitTest() {
        Assessment_type__c asmt = New Assessment_Type__c();
        asmt.name = 'CANS';
        Insert asmt;
        
        Test.startTest();
        testData = new TMN_Generic_Core_TestData();
		insert new TMN_User__c(
				Salesforce_User_Account__c = UserInfo.getUserId(),
				Operating_Group__c = 'Corporate'
				);
		HomePageController controller = new HomePageController();


		controller.getListApprovals();
		controller.sortColumn = '1';
		controller.sortOrder = 'asc';
		controller.mineTasks();
        Test.stoptest();
        
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