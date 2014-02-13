@isTest
public with sharing class ActionSummaryTest {
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    public static Action_Plan_Objective__c testObjective;
    public static Id personId;
    public static Service_Assignment__c sa;
    public static Action_Summary__c summary;
    public static Action_Summary__c summary2;
    
    static testmethod void testgetRecommendationOptions() {
        ActionSummaryReportForm testObj = CreateTestController(null);
        List<SelectOption> options = testObj.getRecommendationOptions();
        
        system.assertequals(6,options.size());
    }
    
    static testmethod void testgetpersonid(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
        
        id testID = testObj.getpersonid();
        
        system.assertequals(personid, testID);
    }    
    
    static testmethod void testcalcplans(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        List<ActionSummaryReportForm.ActionPlanWrapper> testmap =
            testobj.calcPlans();
            
        system.assertequals(testplan.id, testmap[0].ActionPlan.id);

        List<ActionSummaryReportForm.ActionPlanGoalWrapper> testmap2 = 
            testmap[0].ActionPlanGoals;
        system.assertequals(testgoal.id, testmap2[0].ActionPlanGoal.id);
        
        List<ActionSummaryReportForm.objective_results_wrapper> testlist =
            testmap2[0].ActionPlanObjectives;
        ActionSummaryReportForm.objective_skill_results_cls resultobj = (ActionSummaryReportForm.objective_skill_results_cls )testlist[0];
        system.assertequals(testobjective.id, resultobj.Plan_Objective.id);
        system.assertequals(1, resultobj.MetCount);
        system.assertequals(2, resultobj.TrialCount);
        
    }
    
    static testmethod void futureobjectivebug(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Redwood');
        System.runAs(tester){ 
                     
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        Action_plan_Objective__c futureObj = new Action_plan_Objective__c(); 
        futureObj.Action_Plan_Goal__c = testGoal.Id;
        futureObj.Description__c = 'a future test objective';
        futureObj.Status__c = 'In Progress';
        futureObj.Type__c = 'Skill';
        futureObj.Effective_date__c = date.Today().addmonths(1);
        futureObj.Target_end_date__c = date.today().addmonths(2);       
        insert futureObj;

        List<ActionSummaryReportForm.objective_results_wrapper> wrappers = testObj.getObjectiveResults();
        List<Action_plan_objective__c> testObjectives = new List<Action_plan_objective__c>();
        for(ActionSummaryReportForm.objective_results_wrapper wrapper: wrappers){
            testObjectives.Add(wrapper.Plan_Objective);
        }

        System.debug(Logginglevel.Error, 'Date Comparison: ' + futureobj.Effective_Date__c.format() + ' ' + futureObj.Target_End_Date__c.format() +
            ' ' + summary.Start_Date__c.format() + '-' + summary.End_Date__c.format());
        system.assertNotEquals(null,testobjectives);
        System.debug(Logginglevel.Error, 'objectivecount:' + testObjectives.size());
        system.assert(!ContainsObjectId(testObjectives, futureObj.id));        
        }
    }
    
    static testmethod void futureplanbug(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        Action_Plan__c futureplan = new Action_Plan__c();
        futureplan.Service_Assignment__c = sa.id;
        futureplan.effective_date__c = date.today().toStartOfMonth().addmonths(1);
        futureplan.target_date__c = futureplan.effective_date__c.addmonths(3);
        futureplan.Status__c = 'Active Final';
        insert futureplan;
       
        Action_Plan_Goal__c futuregoal = new Action_Plan_Goal__c();
        futuregoal.Action_Plan__c = futureplan.Id;
        futuregoal.Description__c = 'Just a testobject';
        insert futuregoal;
       
        Action_plan_Objective__c futureObj = new Action_plan_Objective__c(); 
        futureObj.Action_Plan_Goal__c = futuregoal.Id;
        futureObj.Description__c = 'a future test objective';
        futureObj.Status__c = 'In Progress';
        futureObj.Type__c = 'Skill';
        futureObj.Effective_date__c = date.today().toStartOfMonth().addmonths(1);
        futureObj.Target_end_date__c = date.today().toStartOfMonth().addmonths(2);       
        insert futureObj;

        List<ActionSummaryReportForm.objective_results_wrapper> wrappers = testObj.getObjectiveResults();
        List<Action_plan_objective__c> testObjectives = new List<Action_plan_objective__c>();
        for(ActionSummaryReportForm.objective_results_wrapper wrapper: wrappers){
            testObjectives.Add(wrapper.Plan_Objective);
        }

        System.debug(Logginglevel.Error, 'Date Comparison: ' + futureobj.Effective_Date__c.format() + ' ' + futureObj.Target_End_Date__c.format() +
            ' plan:' + futureplan.Effective_Date__c.format() + ' ' + futureplan.Target_Date__c.format() +
            ' ' + summary.Start_Date__c.format() + '-' + summary.End_Date__c.format());
        system.assertNotEquals(null,testobjectives);
        System.debug(Logginglevel.Error, 'objectivecount:' + testObjectives.size());
        system.assert(!ContainsObjectId(testObjectives, futureObj.id));        
    }
    
    public static boolean ContainsObjectId(List<Action_plan_objective__c> items, id id){
        for(Action_plan_objective__c item: items){
            if (item.id == id) {return true;}
        }
        return false;
    }
    
    static testmethod void testgetotherreports(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        Map<id, List<Objective_Summary_Comment__c>> testmap = 
            testobj.OtherReportsMap();
            
        system.assertequals(1, testmap.size());
        system.assert(testmap.ContainsKey(testobjective.id));
        system.assertequals(1, testmap.get(testobjective.id).size());
        system.assertequals(summary2.id, testmap.get(testobjective.id)[0].Action_summary__c);
    }
    
    static testmethod void testsaveall(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        List<ActionSummaryReportForm.ActionPlanWrapper> testmap =
            testobj.getPlans();
            
        List<ActionSummaryReportForm.ActionPlanGoalWrapper> testmap2 = 
            testmap[0].ActionPlanGoals;

        List<ActionSummaryReportForm.objective_results_wrapper> testlist =
            testmap2[0].ActionPlanObjectives;

        ActionSummaryReportForm.objective_results_wrapper firstResult = testList[0];
        firstResult.Objective_Comment.Recommendation__c =  'No change';
        firstResult.Objective_Comment.Comment__c =  'A test message';
        testObj.SaveAll();
        
        List<Objective_Summary_Comment__c> dbobjs = [select Comment__c, Recommendation__c
                                        from Objective_Summary_Comment__c 
                                       where Action_Plan_Objective__c = :testObjective.id
                                         and Action_Summary__c = :summary.id];
        
        system.assertequals(1,dbobjs.size());
        system.assertequals('A test message', dbobjs[0].Comment__c);
    }
    
    static testmethod void testFinalize(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
        List<ActionSummaryReportForm.ActionPlanWrapper> testmap =
            testobj.getPlans();
            
        List<ActionSummaryReportForm.ActionPlanGoalWrapper> testmap2 = 
            testmap[0].ActionPlanGoals;

        List<ActionSummaryReportForm.objective_results_wrapper> testList =
            testmap2[0].ActionPlanObjectives;

        ActionSummaryReportForm.objective_results_wrapper firstResult = testList[0];
        firstResult.Objective_Comment.Recommendation__c =  'No change';
        firstResult.Objective_Comment.Comment__c =  'A test message';
        testObj.Finalize();
        
        List<Objective_Summary_Comment__c> dbobjs = [select Comment__c, Recommendation__c, Met_Objective_Count__c, Trials_Count__c
                                        from Objective_Summary_Comment__c 
                                       where Action_Plan_Objective__c = :testObjective.id
                                         and Action_Summary__c = :summary.id];
        
        system.assertequals(1,dbobjs.size());
        system.assertequals('A test message', dbobjs[0].Comment__c);
        system.assertequals(1, dbobjs[0].Met_Objective_Count__c);
        system.assertequals(2, dbobjs[0].Trials_Count__c);
    }
    
    public static testmethod void testUserlevel(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
		boolean userlevel = testObj.canFinalize;    	
    }
    
    public static testmethod void testAllowedDurations(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
		List<SelectOption> durations = testObj.getAllowedDurations();
		
		system.AssertEquals(4, durations.size());
		    	
    }
    
    public static testmethod void testAllowedMonths(){
        createObjects();
        ActionSummaryReportForm testObj = CreateTestController(summary);
    
		List<SelectOption> durations = testObj.getMonthsInServiceAssignment();
		Date firstmonth = testObj.GetServiceAssignmentStartDate().toStartOfMonth();
		system.Assert(1 <= durations.size());
		system.assertequals(firstmonth.format(), durations.get(0).getValue());
		    	
    }
    
    private static ActionSummaryReportForm CreateTestController(Action_Summary__c actsum){
        if (actsum == null) {
            actsum = new Action_Summary__c();
            actsum .Start_Date__c = Date.today();
            actsum .End_Date__c = actsum .Start_Date__c.addmonths(1);
        }
        return new ActionSummaryReportForm(new ApexPages.StandardController(actsum ));
    }
    
    private static Action_Plan__c createObjects(){
        Contact person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;
        personId = person.Id;
        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
        insert adm;
        sa = new Service_Assignment__c();  
        sa.Person_Being_Served__c = person.id;
        sa.admission__c = adm.id;
        sa.Start_Date__c = Date.parse('10/10/2013');
        insert sa;  
       
        testplan = new Action_Plan__c();
        testplan.Service_Assignment__c = sa.id;
        testplan.effective_date__c = date.today();
        testplan.target_date__c = testplan.effective_date__c.addmonths(3);
        testplan.Status__c = 'Active Final';
        insert testPlan;
       
        testGoal = new Action_Plan_Goal__c();
        testGoal.Action_Plan__c = testPlan.Id;
        testGoal.Description__c = 'Just a testobject';
        insert testGoal;
       
        testObjective = new Action_Plan_Objective__c();
        testObjective.Action_Plan_Goal__c = testGoal.Id;
        testObjective.Description__c = 'Just a testobject';
        testObjective.Status__c = 'In Progress';
        testObjective.Type__c = 'Skill';
        testObjective.Effective_date__c = date.Today();
        testObjective.Target_end_date__c = date.today().addmonths(1);       
        insert testObjective;

        summary = new Action_Summary__c();
        summary.Start_Date__c = Date.today().toStartOfMonth();
        summary.End_Date__c = summary.Start_Date__c.addmonths(1);
        summary.Service_Assignment__c = sa.id;
        insert summary;

        summary2 = new Action_Summary__c();
        summary2.Start_Date__c = Date.today().toStartOfMonth();
        summary2.End_Date__c = summary.Start_Date__c.addmonths(1)-1;
        summary2.Service_Assignment__c = sa.id;
        insert summary2;

        Objective_Summary_Comment__c sumComment = new Objective_Summary_Comment__c();
        SumComment.action_plan_objective__c = testObjective.id;
        sumComment.Action_Summary__c = summary2.id;
        insert sumComment;

        Action_Skill_Result__c testresult = new Action_Skill_Result__c();
        testresult.Action_plan_objective__c = testObjective.id;
        testresult.Attempts__c = 5;
        testResult.Day__c = date.today();
        testResult.Status__c = 'V';
        testResult.Met_Objective__c = 'Y';
        insert testresult;
        
        Action_Skill_Result__c testresult2 = new Action_Skill_Result__c();
        testresult2.Action_plan_objective__c = testObjective.id;
        testresult2.Attempts__c = 1;
        testResult2.Day__c = date.today()+1;
        testResult2.Status__c = 'PP';
        testResult2.Met_Objective__c = 'N';
        insert testresult2;
        
        return testplan;
    }

}