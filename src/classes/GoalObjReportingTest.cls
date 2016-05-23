@isTest
private class GoalObjReportingTest {
    private static Action_Plan__c ap;
    private static Action_Plan_Goal__c apg;
    private static Action_Plan_Objective__c apoSkill;
    private static Action_Plan_Objective__c apoBehavior;
    private static Action_Plan_Objective__c apoNarrative;
    private static Action_Plan_Action__c apa;
    private static TMN_Generic_Core_TestData myData;
    private static Evaluation__c evaluation;
    private static Action_Skill_Result__c skillResult;
    private static Action_Behavior_Result__c behaviorResult;
    private static Action_Narrative_Result__c narrativeResult;

    static testMethod void skillObjTest() {
    	createData();
    	GoalObjReporting goalObjReporting = new GoalObjReporting();
    	goalObjReporting.saID = myData.theSA.Id;
        goalObjReporting.shiftStart = evaluation.Shift_Start_Time__c;
        goalObjReporting.shiftEnd = evaluation.Shift_End_Time__c;
    
    	goalObjReporting.init(apoSkill.id);
    	system.assertEquals(true, goalObjReporting.getskillResults().size() > 0);
    	system.assertEquals(true, goalObjReporting.calcTables().size() > 0);
    	
    	goalObjReporting.currRespId = skillResult.id;
    	goalObjReporting.showEditResponse();
    	goalObjReporting.saveResult();
    }
    static testMethod void behaviorObjTest() {
        createData();
        GoalObjReporting goalObjReporting = new GoalObjReporting();
        goalObjReporting.saID = myData.theSA.Id;
        goalObjReporting.shiftStart = evaluation.Shift_Start_Time__c;
        goalObjReporting.shiftEnd = evaluation.Shift_End_Time__c;

        goalObjReporting.init(apoBehavior.id);
        goalObjReporting.getskillResults();
        system.assertEquals(true, goalObjReporting.calcTables().size() > 0);
        
        goalObjReporting.currRespId = behaviorResult.id;
        goalObjReporting.showEditResponse();
        goalObjReporting.saveResult();
    }
    static testMethod void narrativeObjTest() {
        createData();
        GoalObjReporting goalObjReporting = new GoalObjReporting();
        goalObjReporting.saID = myData.theSA.Id;
        goalObjReporting.shiftStart = evaluation.Shift_Start_Time__c;
        goalObjReporting.shiftEnd = evaluation.Shift_End_Time__c;

        goalObjReporting.init(apoNarrative.id);
        system.assertEquals(true, goalObjReporting.getnarrativeResults().size() > 0);
        system.assertEquals(true, goalObjReporting.calcTables().size() > 0);
        
        goalObjReporting.currRespId = narrativeResult.id;
        goalObjReporting.showEditResponse();
        goalObjReporting.saveResult();
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
        evaluation = new Evaluation__c(Status__c = 'Draft', Shift_Start_Time__c = DateTime.now().addDays(-1), 
                                            Shift_End_Time__c = DateTime.now().addDays(1), Head_to_Toe_Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;
        
        ap = new Action_Plan__c(
            Service_Assignment__c = myData.theSA.id,
            Target_Date__c = myData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myData.theSA.start_Date__c
        );        
        insert ap; 
        
        apg = new Action_Plan_Goal__c(
            Description__c = 'a goal',
            Action_Plan__c = ap.id,
            sort_order__c = 'g'
        );
        insert apg;
        
        apoSkill = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'an Objective',
            Type__c = 'skill',
            Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myData.theSA.Start_Date__c,
            sort_order__c = 'o'
        );
        insert apoSkill;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apoSkill.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.Start_Date__c = myData.theSA.Start_Date__c;
        apa.End_Date__c = myData.theSA.Start_Date__c.addDays(1);
        apa.Status__c = 'New';
        insert apa;
        
        apoBehavior = new Action_Plan_Objective__c();
        apoBehavior.Action_Plan_Goal__c = apg.Id;
        apoBehavior.Description__c = 'Just a testobject';
        apoBehavior.Status__c = 'In Progress';
        apoBehavior.Type__c = 'Behavior - Count';
        apoBehavior.Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1);
        apoBehavior.Effective_Date__c = myData.theSA.Start_Date__c;
        insert apoBehavior;
       
        apoNarrative = new Action_Plan_Objective__c();
        apoNarrative.Action_Plan_Goal__c = apg.Id;
        apoNarrative.Description__c = 'Just a duration testobject';
        apoNarrative.Status__c = 'In Progress';
        apoNarrative.Type__c = 'Narrative';
        apoNarrative.Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1);
        apoNarrative.Effective_Date__c = myData.theSA.Start_Date__c;
        insert apoNarrative;
        
        skillResult = new Action_Skill_Result__c();
        skillResult.Action_plan_objective__c = apoSkill.id;
        skillResult.Attempts__c = 5;
        skillResult.Day__c = date.today();
        skillResult.Status__c = 'V';
        skillResult.Met_Objective__c = 'Y';
        insert skillResult;
                
        behaviorResult = new Action_Behavior_Result__c();
        behaviorResult.Action_Plan_Objective__c = apoBehavior.id;
        behaviorResult.Day_Time__c = apoBehavior.Effective_Date__c;
        behaviorResult.Occurrences__c = 5;
        behaviorResult.Occurred__c = true;
        insert behaviorResult;
        
        narrativeResult = new Action_Narrative_Result__c();
        narrativeResult.Action_Plan_Objective__c = apoNarrative.Id;
        narrativeResult.Description__c = 'Test Narrative';
        insert narrativeResult;
    }
    
}