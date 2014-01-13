@isTest
public class SkillTrackingInputTest{
    private static Id personId;
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    private static Action_Plan_Objective__c testObjective;
    private static Action_Skill_Result__c skillResult;
    
    static testmethod void TestInput(){
        GenerateObjects();
        new SkillTrackingInput().Process(GetTestString('4', 'I', 'Y', 'tjb'));
        
        //Test updates
        Action_Skill_Result__c result1 = [select attempts__c, status__c, met_objective__c, initials__c
                                            from Action_Skill_Result__c
                                           where Action_Plan_Objective__c = :testObjective.Id
                                             and Day__c = 2013-12-01];
        System.AssertEquals(4, result1.Attempts__c);
        System.AssertEquals('I', result1.Status__c);
        System.AssertEquals('Y', result1.Met_Objective__c);
        System.AssertEquals('tjb', result1.Initials__c);
        
    }
    
    static testmethod void TestInputNulls(){
        GenerateObjects();
        new SkillTrackingInput().Process(GetTestString('', '', '', ''));
        
        //Test updates
        Action_Skill_Result__c result1 = [select attempts__c, status__c, met_objective__c, initials__c
                                            from Action_Skill_Result__c
                                           where Action_Plan_Objective__c = :testObjective.Id
                                             and Day__c = 2013-12-01];
        System.AssertEquals(10, result1.Attempts__c);
        System.AssertEquals('PP', result1.Status__c);
        System.AssertEquals('Y', result1.Met_Objective__c);
        System.AssertEquals('test', result1.Initials__c);
        
    }

    static testmethod void TestInputWeekSpread(){// also new skillresult
        GenerateObjects();
        new SkillTrackingInput().Process(GetTestString2('3', 'PP', 'N', 'xyz'));
        
        //Test updates
        List<Action_Skill_Result__c> result = [select attempts__c, status__c, met_objective__c, initials__c, day__c
                                            from Action_Skill_Result__c
                                           where Action_Plan_Objective__c = :testObjective.Id
                                             and Day__c >= 2013-12-02
                                             and Day__c < 2013-12-09
                                           order by Day__c];
        System.assertEquals(2, result.size());
        System.assertEquals(Date.newInstance(2013, 12, 2),result[0].Day__c);
        System.AssertEquals(3, result[0].Attempts__c);
        System.AssertEquals('PP', result[0].Status__c);
        System.AssertEquals('N', result[0].Met_Objective__c);
        System.AssertEquals('xyz', result[0].Initials__c);
        
        System.assertEquals(Date.newInstance(2013, 12, 8),result[1].Day__c);
        System.AssertEquals(3, result[1].Attempts__c);
        System.AssertEquals('PP', result[1].Status__c);
        System.AssertEquals('N', result[1].Met_Objective__c);
        System.AssertEquals('xyz', result[1].Initials__c);
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
        
        testObjective = new Action_Plan_Objective__c();
        testObjective.Action_Plan_Goal__c = testGoal.Id;
        testObjective.Description__c = 'Just a testobject';
        testObjective.Status__c = 'In Progress';
        testObjective.Type__c = 'Skill';
        testObjective.Effective_Date__c = Date.newInstance(2013,12,1);
        testObjective.Target_End_Date__c = Date.newInstance(2013,12,31);
           
        insert testObjective;
        
        skillResult = new Action_Skill_Result__c();
        skillResult.Action_Plan_Objective__c = testObjective.Id;
        skillResult.Day__c = Date.newInstance(2013, 12, 1);
        skillResult.Attempts__c = 10;
        skillResult.Status__c = 'PP';
        skillResult.Met_Objective__c = 'Y';
        skillResult.Initials__c = 'test';
        insert skillResult;
        
    }
    
    private static string GetTestString(string attempts, string status, string met, string initials){
        return '<form>' +
            '<person' + personId + '>test contact</person' + personId + '>' +
            '<' + testObjective.Id + '></' + testObjective.Id + '>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-01"></field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-01_Attempts">' + attempts + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-01_Status">' + status + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-01_Met">' + met + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-01_Initials">' + initials + '</field>' +
            '</form>';
    }

    private static string GetTestString2(string attempts, string status, string met, string initials){
        return '<form>' +
            '<person' + personId + '>test contact</person' + personId + '>' +
            '<' + testObjective.Id + '></' + testObjective.Id + '>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-02_Date"></field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-02_Attempts">' + attempts + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-02_Status">' + status + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-02_Met">' + met + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-02_Initials">' + initials + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-08_Date"></field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-08_Attempts">' + attempts + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-08_Status">' + status + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-08_Met">' + met + '</field>' +
            '<field name="skill_' + testObjective.Id + '_2013-12-08_Initials">' + initials + '</field>' +
            '</form>';
    }
}