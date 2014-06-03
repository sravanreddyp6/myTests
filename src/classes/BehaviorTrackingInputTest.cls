@isTest
public class BehaviorTrackingInputTest{
    private static Id personId;
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    private static Action_Plan_Objective__c testObjective1;
    private static Action_Plan_Objective__c testObjective2;
    private static Action_Skill_Result__c skillResult;
    
    static testmethod void TestInputOccurrence(){
        GenerateObjects();
        new BehaviorTrackingInput().Process(GetTestString1(4));
        
        //Test updates
        Action_Behavior_Result__c result1 = [select occurrences__c, day_time__c
                                            from Action_Behavior_Result__c
                                           where Action_Plan_Objective__c = :testObjective1.Id
                                            // and Day_Time__c = 2013-12-01T00:00:00+05:00 
                                            ];
        system.assertEquals(Datetime.newinstanceGMT(2013,12,1,0,0,0), result1.day_time__c);
        System.AssertEquals(4, result1.Occurrences__c);
        
    }
    
    static testmethod void TestInputOccurred(){
        GenerateObjects();
        new BehaviorTrackingInput().Process(GetTestString2(true));
        
        //Test updates
        Action_Behavior_Result__c result1 = [select occurred__c, day_time__c
                                            from Action_Behavior_Result__c
                                           where Action_Plan_Objective__c = :testObjective2.Id
                                            // and Day_Time__c = 2013-12-01T00:00:00+05:00 
                                            ];
        system.assertEquals(Datetime.newinstanceGMT(2013,12,1,0,0,0), result1.day_time__c);
        System.AssertEquals(true, result1.Occurred__c);
        
    }
    
/*    static testmethod void TestInputNulls(){
        GenerateObjects();
        new BehaviorTrackingInput().Process(GetTestString('', '', '', ''));
        
        //Test updates
        Action_Skill_Result__c result1 = [select attempts__c, status__c, met_objective__c, initials__c
                                            from Action_Skill_Result__c
                                           where Action_Plan_Objective__c = :testObjective.Id
                                             and Day__c = 2013-12-01];
        System.AssertEquals(10, result1.Attempts__c);
        System.AssertEquals('PP', result1.Status__c);
        System.AssertEquals('Y', result1.Met_Objective__c);
        System.AssertEquals('test', result1.Initials__c);
        
    }*/

    static testmethod void TestInputMonthSpread(){// also new skillresult
        GenerateObjects();
        new BehaviorTrackingInput().Process(GetTestStringmultiple(9,8));
        
        //Test updates
        List<Action_behavior_Result__c> result = [select occurrences__c, day_time__c
                                            from Action_behavior_Result__c
                                           where Action_Plan_Objective__c = :testObjective1.Id
                                             
                                           order by Day_time__c];
        System.assertEquals(2, result.size());
        System.assertEquals(Datetime.newInstanceGMT(2013, 12, 2, 1,0,0),result[0].Day_time__c);
        System.AssertEquals(9, result[0].occurrences__c);
        
        System.assertEquals(DateTime.newInstanceGMT(2013, 12, 31,23,0,0),result[1].Day_time__c);
        System.AssertEquals(8, result[1].occurrences__c);
    }
    
    private static void GenerateObjects(){
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
        
        testObjective1 = new Action_Plan_Objective__c();
        testObjective1.Action_Plan_Goal__c = testGoal.Id;
        testObjective1.Description__c = 'Just a testobject count';
        testObjective1.Status__c = 'In Progress';
        testObjective1.Type__c = 'Behavior - Count';
        testObjective1.Effective_Date__c = Date.newInstance(2013,12,1);
        testObjective1.Target_End_Date__c = Date.newInstance(2013,12,31);
           
        insert testObjective1;
        
        testObjective2 = new Action_Plan_Objective__c();
        testObjective2.Action_Plan_Goal__c = testGoal.Id;
        testObjective2.Description__c = 'Just a testobject count';
        testObjective2.Status__c = 'In Progress';
        testObjective2.Type__c = 'Behavior - Duration';
        testObjective2.Effective_Date__c = Date.newInstance(2013,12,1);
        testObjective2.Target_End_Date__c = Date.newInstance(2013,12,31);
           
        insert testObjective2;
        
        skillResult = new Action_Skill_Result__c();
        skillResult.Action_Plan_Objective__c = testObjective1.Id;
        skillResult.Day__c = Date.newInstance(2013, 12, 1);
        skillResult.Attempts__c = 10;
        skillResult.Status__c = 'PP';
        skillResult.Met_Objective__c = 'Y';
        skillResult.Initials__c = 'test';
        insert skillResult;
        
    }
    
    private static string GetTestString1(integer occurrences){
        return '<form>' +
            '<person' + personId + '>test contact</person' + personId + '>' +
            '<' + testObjective1.Id + '></' + testObjective1.Id + '>' +
            '<field name="behavior_' + testObjective1.Id + '_2013-12-01-00-00-00_Occurrences">' + occurrences.format() + '</field>' +
            '</form>';
    }
    
    private static string GetTestString2(boolean occurred){
        return '<form>' +
            '<person' + personId + '>test contact</person' + personId + '>' +
            '<field name="behavior_' + testObjective2.Id + '_2013-12-01-00-00-00_Occurred">' + (occurred ? 'true' : 'false') + '</field>' +
            '</form>';
    }

    private static string GetTestStringmultiple(integer occurrences1, integer occurrences2){
        return '<form>' +
            '<person' + personId + '>test contact</person' + personId + '>' +
            '<' + testObjective1.Id + '></' + testObjective1.Id + '>' +
            '<field name="behavior_' + testObjective1.Id + '_2013-12-02-01-00-00_Date"></field>' +
            '<field name="behavior_' + testObjective1.Id + '_2013-12-02-01-00-00_Occurrences">' + occurrences1 + '</field>' +
            '<field name="behavior_' + testObjective1.Id + '_2013-12-31-23-00-00_Occurrences">' + occurrences2 + '</field>' +
            '</form>';
    } 
}