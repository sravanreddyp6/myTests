@isTest
private class GoalObjRepeaters_Test {


	private static Action_plan__c thePlan;

    static testMethod void simpleTest() {

		// create a plan with 1 objective of each type
		thePlan = createData();

		GoalObjRepeaters reps = new GoalObjRepeaters();
		reps.saID = thePlan.Service_Assignment__c;
		system.debug(thePlan);

		reps.shiftStart = Datetime.newInstance( thePlan.effective_date__c, Time.newInstance( 12, 0, 0, 0));
		reps.shiftEnd = reps.shiftStart.AddHours(6);

		Set<String> objTypes = reps.getObjTypes();
		System.AssertEquals( objTypes.size(), 4);

		Map<string, List<GoalObjRepeaters.objWrapper>> objsByType = reps.objsByType;

		for (string oType : objTypes ) {
		 	System.AssertEquals( objsByType.get(oType).size(), 1);
		}

    }

    private static Action_Plan__c createData(){
     	Action_plan_Goal__c apg;
    	Action_plan_Objective__c apoSkill;
    	Action_plan_Objective__c apoBehaviorCount;
    	Action_plan_Objective__c apoBehaviorDuration;
    	Action_plan_Objective__c apoNarrative;
    	Action_plan_Action__c apa1;
    	Action_plan_Action__c apa2;
    	Action_plan_Action__c apa3;
    	Action_plan_Action__c apa4;


        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();

        myData.theSA.SA_Start_DateTime__c = Datetime.newInstance( 2015, 1, 1, 0, 0, 0);
        system.debug('about to update SA');
        update(myDAta.theSA);
        system.debug( myData.theSA);

        system.debug( mydata.thesa.sa_start_datetime__c);
        system.debug( mydata.thesa.start_date__c);

        Action_plan__c ap = new Action_Plan__c(
            Service_Assignment__c = myData.theSA.id,
            Target_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1),
            Effective_Date__c = myData.theSA.SA_Start_DateTime__c.Date()
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
            Description__c = 'an Objective with a really long description so it has to be truncated by the class for display on the front end, unless they want to see it wrapping',
            Type__c = 'Skill',
            Target_End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1),
            Effective_Date__c = myData.theSA.SA_Start_DateTime__c.Date(),
            sort_order__c = 'o'
        );
        insert apoSkill;

        apa1 = new Action_Plan_Action__c ();
        apa1.Action_Plan_Objective__c = apoSkill.id;
        apa1.Description__c = 'skill action';
        apa1.sort_order__c = 'a';
        apa1.Start_Date__c = myData.theSA.SA_Start_DateTime__c.Date();
        apa1.End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1);
        apa1.Status__c = 'New';
        insert apa1;

        apoBehaviorCount = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'Behavior Count Objective',
            Type__c = 'Behavior - Count',
            Target_End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1),
            Effective_Date__c = myData.theSA.SA_Start_DateTime__c.Date(),
            sort_order__c = 'o1'
        );
        insert apoBehaviorCount;

        apa2 = new Action_Plan_Action__c ();
        apa2.Action_Plan_Objective__c = apoBehaviorCount.id;
        apa2.Description__c = 'Behavior Count action';
        apa2.sort_order__c = 'a2';
        apa2.Start_Date__c = myData.theSA.SA_Start_DateTime__c.Date();
        apa2.End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1);
        apa2.Status__c = 'New';
        insert apa2;

        apoBehaviorDuration = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'Behavior Duration Objective',
            Type__c = 'Behavior - Duration',
            Target_End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1),
            Effective_Date__c = myData.theSA.SA_Start_DateTime__c.Date(),
            sort_order__c = 'o2'
        );
        insert apoBehaviorDuration;


        apa3 = new Action_Plan_Action__c ();
        apa3.Action_Plan_Objective__c = apoBehaviorDuration.id;
        apa3.Description__c = 'Behavior Duration action';
        apa3.sort_order__c = 'a3';
        apa3.Start_Date__c = myData.theSA.SA_Start_DateTime__c.Date();
        apa3.End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1);
        apa3.Status__c = 'New';
        insert apa3;

        apoNarrative = new Action_Plan_Objective__c(
            Action_Plan_Goal__c = apg.id,
            Status__c = 'In Progress',
            Description__c = 'Narrative Objective',
            Type__c = 'Narrative',
            Target_End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1),
            Effective_Date__c = myData.theSA.SA_Start_DateTime__c.Date(),
            sort_order__c = 'o2'
        );
        insert apoNarrative;


        apa4 = new Action_Plan_Action__c ();
        apa4.Action_Plan_Objective__c = apoNarrative.id;
        apa4.Description__c = 'Narrative action';
        apa4.sort_order__c = 'a4';
        apa4.Start_Date__c = myData.theSA.SA_Start_DateTime__c.Date();
        apa4.End_Date__c = myData.theSA.SA_Start_DateTime__c.Date().addDays(1);
        apa4.Status__c = 'New';
        insert apa4;

        ap.status__c = 'Active Final';
        update ap;

        return ap;

    }

}