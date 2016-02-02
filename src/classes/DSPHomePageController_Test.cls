@isTest
private class DSPHomePageController_Test {
    private static TMN_Generic_Core_TestData testData;
    
    static testMethod void myUnitNoTmnUser() {
        try{
            DSPHomePageController cntrlr = new DSPHomePageController();
        } catch (DSPHomePageController.TMN_User_Exception e){
            system.assert(true);
        } catch (Exception e2){
            throw new DSPHomePageController.TMN_User_Exception('We should have never come here, thats because the tmn record isnt created yet and this class doesnt see all the org data.');
        }
    }
    
    static testMethod void myUnitTestForTasks() {
        createData();
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            
            PageReference pageRef = Page.DSPHome;
            Test.setCurrentPage(pageRef);
            
            //create ActionPlan, Assessment and Tasks for this user to ACK
            Action_Plan__c ap = createAction_Plan();
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
            
            DSPHomePageController cntrlr = new DSPHomePageController();
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
        }
    }
    
    static testMethod void myUnitTestForPbsFavToggle() {
        createData();
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            PageReference pageRef = Page.DSPHome;
            Test.setCurrentPage(pageRef);
            
            //create ActionPlan, Assessment and Tasks for this user to ACK
            Action_Plan__c ap = createAction_Plan();
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
            
            DSPHomePageController cntrlr = new DSPHomePageController();
            cntrlr.setPBSList();
            cntrlr.FrstName = 'FName';
            cntrlr.LstName = '';
            cntrlr.getSearchResults();
            system.assert(cntrlr.searchResultList.size() == 1);
            
            cntrlr.searchResultPBS = cntrlr.searchResultList.get(0).recordId;
            cntrlr.searchResultSA = cntrlr.searchResultList.get(0).saID;
            cntrlr.searchResultIsFav = true;
            cntrlr.setfocusPBS();
            String userCookie = [ select favorite_pbs__c from user where id = :UserInfo.getUserId() LIMIT 1].favorite_pbs__c;
            system.assert( userCookie == cntrlr.searchResultPBS + '-' + cntrlr.searchResultSA + ';');
            
            cntrlr.searchResultIsFav = false;
            cntrlr.toggleFavorite();
            
            userCookie = [ select favorite_pbs__c from user where id = :UserInfo.getUserId() LIMIT 1].favorite_pbs__c;
            system.debug('whats fav: ' + userCookie );
            system.assert(String.IsBlank(userCookie));
        }
    }
    
    static testMethod void myUnitTestSearchFavPbsAgain() {
        createData();
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            PageReference pageRef = Page.DSPHome;
            Test.setCurrentPage(pageRef);
            
            //create ActionPlan, Assessment and Tasks for this user to ACK
            Action_Plan__c ap = createAction_Plan();
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
            
            // set the cookie manually before the controller instantiation
            String newval = String.valueOf(testData.ContactId) + '-' + String.valueOf(testData.theSA.Id) + ';';
            User u = [ select id, favorite_pbs__c from user where id=:UserInfo.getUserId() LIMIT 1];
            u.favorite_pbs__c = newval;
            update u;
            
            DSPHomePageController cntrlr = new DSPHomePageController();
            cntrlr.setPBSList();	// pick up favorite from user setting
            cntrlr.FrstName = 'FName';
            cntrlr.LstName = '';
            cntrlr.getSearchResults();
            system.assert(cntrlr.searchResultList.size() == 0);
            
            pageRef = cntrlr.dspShiftNoteSummary();
            system.assert(pageRef.getRedirect());
            system.assert(pageRef.getUrl().containsIgnoreCase('DSP_shiftnote_summary_rpt'));
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
    
    private static Action_Plan__c createAction_Plan(){
        createData();
        
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
}