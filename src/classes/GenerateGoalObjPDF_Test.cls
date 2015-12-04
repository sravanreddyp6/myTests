@isTest
private class GenerateGoalObjPDF_Test {


	private static Action_Plan__c thePlan;
	private static Evaluation__c theEval;
	

    static testMethod void simpleTest() {

		// create a plan with 1 objective of each type
		thePlan = createData();
		system.debug(thePlan);

		// create a result for each objective		
		createPlanResults( thePlan.id, thePlan.service_Assignment__c  );
		
		// create an evaluation to report against
		theEval = createEval(thePlan.service_assignment__c);
		system.debug(theEval);

		// test the generation of the goal reports
		GenerateGoalObjPDF getGoalPDF = new GenerateGoalObjPDF();
		getGoalPDF.evalId = theEval.Id;
		
		// just to get coverage - should exit without doing anything
		getGoalPDF.init(theEval.Id);
		
		
		System.Assert( getGoalPDF.objectives.size() > 0);
		for ( GenerateGoalObjPDF.objectivewrapper obj : getGoalPDF.objectives ) {
			system.assertequals( String.IsBlank(obj.objDesc), false );
			system.assertequals( String.IsBlank(obj.effdates), false );
		}
		
		
		
		

    }


	private static Evaluation__c createEval( Id theSAId) {
		
		ID rtID = [ select id from recordtype where sobjecttype= 'Evaluation__c' and developername like 'CNA%' LIMIT 1].Id;
		//Service_Assignment__c saID = 
		system.debug( rtID );
		
		Service_Assignment__c theSA = [ select id, SA_start_datetime__c from service_assignment__c where id = :theSAId];
		system.debug( 'The SA is: ' + theSA );
		// create a CNA eval
		Evaluation__c newEval = new Evaluation__c( ServiceAssignment__c = theSA.Id, shift_start_time__c = theSA.SA_Start_DateTime__c, shift_end_time__c = theSA.SA_Start_DateTime__c.addhours(6), recordtypeid = rtID );
		insert newEval;
		return newEval;
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
    
    private static void createPlanResults ( ID planID, ID saID ){
    	
    	List<Action_Plan_Objective__c> lstAPO = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
									and Status__c in ('In Progress', 'Revised', 'New')
									and action_plan_goal__r.action_plan__r.status__c = 'Active Final' ];
    	
    	
    	// create a result for each type
    	for ( Action_Plan_Objective__c apo : lstAPO ) {
    		if ( apo.type__c == 'Narrative') {
    			Action_Narrative_Result__c narr = new Action_Narrative_Result__c( action_plan_objective__c  = apo.Id, description__c = 'Narrative result');
    			insert narr;
    			
    			narr = new Action_Narrative_Result__c( action_plan_objective__c  = apo.Id, description__c = 'Narrative result 2');
    			insert narr;
    		}
    		if (apo.type__c == 'Behavior - Count') {
    			Action_Behavior_Result__c beh = new Action_Behavior_Result__c( action_plan_objective__c = apo.Id,  Day_time__c = DateTime.newInstance( apo.effective_Date__c, Time.newInstance(3,0,0,0)), Occurrences__c = 2 );
    			insert beh;
    			
    			beh = new Action_Behavior_Result__c( action_plan_objective__c = apo.Id,  Day_time__c = DateTime.newInstance( apo.effective_Date__c, Time.newInstance(4,0,0,0)), Occurrences__c = 1 );
    			insert beh;
    		}
    		if (apo.type__c == 'Behavior - Duration') {
    			Action_Behavior_Result__c beh2 = new Action_Behavior_Result__c( action_plan_objective__c = apo.Id,  Day_time__c = DateTime.newInstance( apo.effective_Date__c, Time.newInstance(3,0,0,0)), Occurred__c = true );
    			insert beh2;
    			
    			// insert another for better coverage
    			beh2 = new Action_Behavior_Result__c( action_plan_objective__c = apo.Id,  Day_time__c = DateTime.newInstance( apo.effective_Date__c, Time.newInstance(4,0,0,0)), Occurred__c = true );
    			insert beh2;
    			
    		}
    		if (apo.type__c == 'Skill') {
    			Action_Skill_Result__c skill = new Action_Skill_Result__c( action_plan_objective__c = apo.Id,  day__c = apo.Effective_Date__c, attempts__c = 2, initials__c = 'TEST', met_objective__c = 'Y', status__c = 'I');
    			insert skill;
    			
    			skill = new Action_Skill_Result__c( action_plan_objective__c = apo.Id,  day__c = apo.Effective_Date__c+1, attempts__c = 4, initials__c = 'TEST', met_objective__c = 'N', status__c = 'V');
    			insert skill;
    			
    		}
    		
    	}
    }

}