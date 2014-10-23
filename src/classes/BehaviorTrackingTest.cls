@isTest
public with sharing class BehaviorTrackingTest{
    private static Contact person;
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    public static Action_Plan_Objective__c testObjective;
    public static Action_Plan_Objective__c testObjectived;
    public static Action_Plan_Worksheet__c testWorksheet;
    public static Action_Behavior_Result__c result1;
    public static Action_Behavior_Result__c result2;
    public static Id personId;
   
    public static testmethod void gethourstest(){
        BehaviorTracking_Form form = CreateTestController(null);
        
        List<integer> hours = form.gethoursofday();
        
        system.assertEquals(24, hours.size());
    }
 
    public static testmethod void getpersonData(){
        createobjects();
        
        BehaviorTracking_Form form = CreateTestController(testWorksheet);
        
        System.assertequals(person.firstname + ' ' + person.lastname, form.getPersonName());
        system.assertequals(person.id, form.getPersonId());
    }
    

    public static testmethod void getmodelData(){
        createobjects();
        BehaviorTracking_Form form = CreateTestController(testWorksheet);
        
        List<BehaviorTracking_Form.Table> tables = form.Tables;
        
        System.assert(0< tables.size());
        BehaviorTracking_Form.Row row = tables.get(0).getrows().get(0);
        BehaviorTracking_Form.Action_Behavior_Wrapper wrapper = row.getitems().get( date.parse('10/15/2013'));
        System.assertEquals('12AM', row.getHeader());
        System.assertEquals('Tue', wrapper.getDayOfWeek());

    }
    
    public static testmethod void getXmlDoc(){
        createobjects();
        BehaviorTracking_Form form = CreateTestController(testWorksheet);
        
        Dom.Document xml = form.anotoGenerateDocument(form.Tables[0]);
        
        System.assertnotequals(null, xml);
    }
    
    public static testmethod void saveData(){
        createobjects();
        BehaviorTracking_Form form = CreateTestController(testWorksheet);
        
        List<BehaviorTracking_Form.Table> tables = form.Tables;
        
        System.assert(0< tables.size());
        //system.assertequals(5.0, tables.get(0).get(1, date.parse('10/12/2013')).occurrences__c, 'data not preset');
        tables.get(0).get(0, date.parse('10/15/2013')).Occurrences__c = 1;
        form.mySave();
        
        Datetime restime = Datetime.newinstanceGMT(date.parse('10/15/2013'), Time.newInstance(0,0,0,0));
        Action_Behavior_Result__c res = [select Occurrences__c
                                           from Action_Behavior_Result__c
                                          where Day_time__c = :restime
                                            and Action_Plan_Objective__c = :tables.get(0).Objectiveid];
        system.assertEquals(1,res.occurrences__c);
    }

    public static testmethod void switchObjective(){
        createobjects();
        BehaviorTracking_Form form = CreateTestController(testWorksheet);
        List<BehaviorTracking_Form.Table> tables = form.Tables;
        
        string newobjectiveid = form.objectiveIdChosen =  testobjectived.id ;
        PageReference page = form.saveandswitchObjective();
        
        system.assertnotequals(null, page, 'Switch did not return pagereference');
        system.assertequals(newobjectiveid, page.getParameters().get('objectiveid'));
    }    
    
   private static Action_Plan__c createObjects(){
		person = new Contact();
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
       testplan.Effective_Date__c = Date.parse('10/1/2013');
       testplan.Target_Date__c = Date.parse('11/30/2013');
       insert testPlan;
       testGoal = new Action_Plan_Goal__c();
       testGoal.Action_Plan__c = testPlan.Id;
       testGoal.Description__c = 'Just a testobject';
       insert testGoal;
       testObjective = new Action_Plan_Objective__c();
       testObjective.Action_Plan_Goal__c = testGoal.Id;
       testObjective.Description__c = 'Just a testobject';
       testObjective.Status__c = 'In Progress';
       testObjective.Type__c = 'Behavior - Count';
       testObjective.Effective_Date__c = Date.parse('10/10/2013');
       testObjective.Target_End_Date__c = Date.parse('10/31/2013');
       
       insert testObjective;
       
       testObjectived = new Action_Plan_Objective__c();
       testObjectived.Action_Plan_Goal__c = testGoal.Id;
       testObjectived.Description__c = 'Just a duration testobject';
       testObjectived.Status__c = 'In Progress';
       testObjectived.Type__c = 'Behavior - Duration';
       testObjectived.Effective_Date__c = Date.parse('10/15/2013');
       testObjectived.Target_End_Date__c = Date.parse('11/30/2013');
       
       insert testObjectived;

		testWorksheet = new Action_Plan_Worksheet__c();
		testWorksheet.Start_Date__c = Date.parse('10/1/2013');
       	testWorksheet.Action_Plan__c = testplan.Id;
       
       insert testWorksheet;
       
       result1 = new Action_Behavior_Result__c();
       result1.Action_Plan_Objective__c = testobjective.id;
       result1.Day_time__c = datetime.newinstanceGMT(date.parse('10/12/2013'), time.newinstance(1,0,0,0));
       result1.Occurrences__c = 5;
       insert result1;
       
       result2 = new Action_Behavior_Result__c();
       result2.Action_Plan_Objective__c = testobjectived.id;
       result2.Day_time__c = datetime.newinstanceGMT(date.parse('10/17/2013'), time.newinstance(1,0,0,0));
       result2.Occurred__c = true;
       insert result2;
       
       return testplan;
   }
   
  	private static BehaviorTracking_Form CreateTestController(Action_Plan_Worksheet__c actsum){
        if (actsum == null) {
            actsum = new Action_Plan_Worksheet__c();
            actsum .Start_Date__c = Date.parse('10/1/2013');
        }
        return new BehaviorTracking_Form(new ApexPages.StandardController(actsum ));
    }
    

}