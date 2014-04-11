@isTest
public with sharing class WeeklySkillTracking_FormTest {
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    public static Action_Plan_Objective__c testObjective;
    public static Id personId;
   
   static testmethod void getPersonIdtest(){
   		createObjects();
   		Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
   		testResult.Action_Plan__c = testplan.id;
   		testResult.Start_Date__c = Date.Parse('10/21/2013');
   		WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
   		insert testResult;
   		
   		System.assertEquals(personId, form.getPersonId());
   		
   } 
   
   static testmethod void getDaysOfWeektest() {
   		createObjects();
   		Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
   		testResult.Action_Plan__c = testplan.id;
   		testResult.Start_Date__c = Date.Parse('10/21/2013');
   		WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
   		
   		List<Date> result = form.GetDaysofweek();
   		
   		system.assertEquals(7, result.size());
   		system.assertEquals(Date.Parse('10/21/2013'), result[0]); 
   		system.assertEquals(Date.Parse('10/22/2013'), result[1]); 
   		system.assertEquals(Date.Parse('10/23/2013'), result[2]); 
   		system.assertEquals(Date.Parse('10/24/2013'), result[3]); 
   		system.assertEquals(Date.Parse('10/25/2013'), result[4]); 
   		system.assertEquals(Date.Parse('10/26/2013'), result[5]); 
   		system.assertEquals(Date.Parse('10/27/2013'), result[6]); 
   }

	static testmethod void OnlySelectActiveObjectives(){
   		createObjects();
   		
   		action_plan_objective__c testObjective1 = new Action_Plan_Objective__c();
       testObjective1.Action_Plan_Goal__c = testGoal.Id;
       testObjective1.Description__c = 'Just a testobject';
       testObjective1.Status__c = 'In Progress';
       testObjective1.Effective_Date__c = Date.Parse('10/28/2013');
       testObjective1.Target_End_Date__c = Date.Parse('11/28/2013');
       testObjective1.Type__c = 'Skill';
       
       insert testObjective1;
   		
   		Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
   		testResult.Action_Plan__c = testplan.id;
   		testResult.Start_Date__c = Date.Parse('10/21/2013');
   		WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
   		
   		List<WeeklySkillTracking_Form.ObjectiveWrapper> mapping = form.getObjectivesMap();
   		
   		Set<id> objIds = new set<id>();
   		for(WeeklySkillTracking_Form.ObjectiveWrapper wrapper: mapping){
   			Action_Plan_Objective__c obj = wrapper.Objective;
   			system.debug('Objective:' + obj.id + ' EffectiveDate:' + obj.Effective_Date__c);
   			objids.Add(obj.id);
   		}
		system.assert(objids.contains(testobjective.id));		
		system.assert(!( objids.contains(testobjective1.id)));		
	}   
   static testmethod void savetest() {
   		createObjects();
   		Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
   		testResult.Action_Plan__c = testplan.id;
   		testResult.Start_Date__c = Date.Parse('10/21/2013');
   		WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
   		
   		List<WeeklySkillTracking_Form.ObjectiveWrapper> mapping = form.getObjectivesMap();
   		
   		Action_Plan_Objective__c to2 = mapping[0].Objective;
   		system.assert(mapping.size() > 0);
   		Action_Skill_Result__c testdayresult = mapping[0].ResultsMap.get(Date.Parse('10/22/2013'));
   		
   		testdayresult.Attempts__c = 2;
   		testdayresult.Initials__c = 'test';
   		testdayresult.Met_Objective__c = 'Y';
   		testdayresult.Status__c = 'I';
   		
   		form.mySave();
   		
   		Action_Skill_Result__c fromDB = [select Attempts__c, initials__c, Met_Objective__c, status__c
   										   from Action_Skill_Result__c 
   										  where Id = :testdayresult.Id];
   										  
   		system.assertequals(2, fromDB.Attempts__c);
   		system.assertequals('test', fromDB.Initials__c);
   		system.assertequals('Y', fromDB.Met_Objective__c);
   		system.assertequals('I', fromDB.status__c);
   
   }
   
   static testmethod void generateAnotoDoc(){
   		createObjects();
   		Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
   		testResult.Action_Plan__c = testplan.id;
   		testResult.Start_Date__c = Date.Parse('10/21/2013');
   		insert testResult;
   		
   		WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
   		
   		Dom.Document doc = form.anotogenerateDocument();
   		
   		Dom.Xmlnode root = doc.getRootElement();
   		system.assertNotEquals(null, root);
   		system.assertEquals('root', root.getName());

   		Dom.Xmlnode settings = root.getChildElement('settings', 'http://www.penvision.se/printprocessor');
   		system.assertNotEquals(null, settings);
   		system.assertEquals('settings', settings.getName());

   		Dom.Xmlnode layout = settings.getChildElement('layout', null);
   		system.assertNotEquals(null, layout);
   		system.assertEquals('layout', layout.getName());

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
		Service_Assignment__c sa = new Service_Assignment__c();	
		sa.Person_Being_Served__c = person.id;
		sa.admission__c = adm.id;
		insert sa;	
      testplan = new Action_Plan__c();
       testplan.Service_Assignment__c = sa.id;
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
       testObjective.Effective_Date__c = Date.parse('10/10/2013');
       testObjective.Target_End_Date__c = Date.parse('10/31/2013');
       
       insert testObjective;
       
       Folder fold = new Folder();
       fold.Name = 'TestFold';
       
       Document bkg = new Document();
       bkg.Name = 'Skill_Tracking_Day_Background';
       bkg.Body = Blob.valueof('hi');
       bkg.FolderId = [select Name, Id from Folder][0].Id;
       
       insert bkg;
       
       return testplan;
   }
   
   private static void VerifyObjects(Action_Plan_Objective__c objective, Date monday){
       	List<Action_Skill_Result__c> existing =[ select Day__c
                        from Action_Skill_Result__c
                        where Action_Plan_Objective__r.Id = :objective.Id
                          and Day__c >= :monday 
                          and Day__c < :monday + 7
                        order by Day__c];
       
	    //Verify number of objects
	    System.assertEquals(7, existing.size());
	    //Verify Date of each
	    integer ii = 0;
	    for(Action_Skill_Result__c current: existing){
			System.assertEquals(monday + ii, current.Day__c);  
			ii++;     		
        }
   }

	static testmethod void ObjectMapTwoExisting() {
       	Action_plan__c  actionPlan = createObjects();
       	Action_Plan_Worksheet__c testResult = new Action_Plan_Worksheet__c();
       	Date firstDay = Date.Parse('10/12/2013');
       	testResult.Action_plan__c = actionPlan.Id;
       	testResult.Start_Date__c = firstDay;
       	WeeklySkillTracking_Form form = new WeeklySkillTracking_Form(testResult);
	   	Action_Skill_Result__c myNew= new Action_Skill_Result__c();
		myNew.Action_Plan_Objective__c = testObjective.Id;
		myNew.Day__c = firstDay ;
		myNew.Status__c = 'V';
		myNew.Attempts__c = 3;
		myNew.Met_Objective__c = 'y';
		
		insert myNew;
    	myNew= new Action_Skill_Result__c();
		myNew.Action_Plan_Objective__c = testObjective.Id;
		myNew.Day__c = firstDay + 6;
		myNew.Status__c = 'i';
		myNew.Attempts__c = 2;
		myNew.Met_Objective__c = 'y';
		insert myNew;
       
       List<WeeklySkillTracking_Form.ObjectiveWrapper> testmap = form.getObjectivesMap();
       
       for(WeeklySkillTracking_Form.ObjectiveWrapper wrapper : testmap){
       		Action_Plan_Objective__c objective = wrapper.Objective;
       	    //Verify number of objects
       	    Map<Date, Action_Skill_Result__c > weekResults = wrapper.ResultsMap;
		    System.assertEquals(7, weekResults.size());
		    //Verify Date of each
		    integer ii = 0;
		    for(Date key=firstDay; key< firstDay+7; key = key + 1){
		    	Action_skill_result__c dayresult = weekresults.get(key);
				System.assertEquals(key, dayresult.Day__c);  
	        }
       }

   }
   
}