@isTest
private class IowaDailyDataSummaryTest {
    static TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    
    static testMethod void myUnitTest() {
        myData.loadData('IA');
        
        PageReference pageRef = Page.IowaDailyDataSummary;
        Test.setCurrentPage(pageRef);
        
        Apexpages.currentPage().getParameters().put('saId', myData.theSA.id);
        Apexpages.currentPage().getParameters().put('serviceDate', date.newInstance(2013,1,1).format());
        Apexpages.currentPage().getParameters().put('Esign', 'ture');
        
        IowaDailyDataSummary extension =  new IowaDailyDataSummary();        

        System.assertequals(0, extension.timelogs.size());
        
        createAdditionalTestData();
        extension =  new IowaDailyDataSummary();
        System.assertequals(1, extension.notes.size());
    }
    
    
    
    static void createAdditionalTestData(){
        Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c='Redwood', Salesforce_User_Account__c=userInfo.getUserId());
        insert tmnUser;
        
    	// create evaluation response records for time-log
        insert new Evaluation_Response__c(
            RecordTypeID = Utility.getEvaluationResponseRecordType('Time Log'),
            Service_Assignment__c = myData.theSA.Id,
            Start_Date_Time__c = DateTime.newInstance(2013, 1, 1, 1, 1, 1),
            End_Date_Time__c = DateTime.newInstance(2013, 1, 1, 2, 2, 2),
            TMN_User__c = tmnUser.Id,
            Location__c = 'Test Location',
            Service_Type__c = 'Pre-Vocational',
            Narrative_Note__c = 'Narrative Notes',
            Is_Late_Entry__c = true
        );
    	
    	// create Action Plan, behavior and skill worksheet
	       Action_Plan__c testplan = new Action_Plan__c();
	       testplan.Service_Assignment__c = myData.theSA.Id;
	       testplan.Effective_Date__c = Date.parse('1/1/2013');
	       testplan.Target_Date__c = Date.parse('1/3/2013');
	       insert testPlan;
	       Action_Plan_Goal__c testGoal = new Action_Plan_Goal__c();
	       testGoal.Action_Plan__c = testPlan.Id;
	       testGoal.Description__c = 'Just a testobject';
	       insert testGoal;
	       Action_Plan_Objective__c testObjective = new Action_Plan_Objective__c();
	       testObjective.Action_Plan_Goal__c = testGoal.Id;
	       testObjective.Description__c = 'Just a testobject';
	       testObjective.Status__c = 'In Progress';
	       testObjective.Type__c = 'Behavior - Count';
	       testObjective.Effective_Date__c = Date.parse('1/1/2013');
	       testObjective.Target_End_Date__c = Date.parse('1/3/2013');
	       
	       insert testObjective;
	       
	       Action_Plan_Objective__c testObjectived = new Action_Plan_Objective__c();
	       testObjectived.Action_Plan_Goal__c = testGoal.Id;
	       testObjectived.Description__c = 'Just a duration testobject';
	       testObjectived.Status__c = 'In Progress';
	       testObjectived.Type__c = 'Behavior - Duration';
	       testObjectived.Effective_Date__c = Date.parse('1/1/2013');
	       testObjectived.Target_End_Date__c = Date.parse('1/3/2013');
	       
	       insert testObjectived;
	
	       Action_Plan_Worksheet__c testWorksheet = new Action_Plan_Worksheet__c();
	       testWorksheet.Start_Date__c = Date.parse('10/1/2013');
	       testWorksheet.Action_Plan__c = testplan.Id;
	       
	       insert testWorksheet;
	       
	       Action_Behavior_Result__c result1 = new Action_Behavior_Result__c();
	       result1.Action_Plan_Objective__c = testobjective.id;
	       result1.Day_time__c = datetime.newinstanceGMT(Date.parse('1/1/2013'), time.newinstance(9,0,0,0));
	       result1.Occurrences__c = 5;
	       insert result1;
	       
	       Action_Behavior_Result__c result2 = new Action_Behavior_Result__c();
	       result2.Action_Plan_Objective__c = testobjectived.id;
	       result2.Day_time__c = datetime.newinstanceGMT(Date.parse('1/1/2013'), time.newinstance(14,0,0,0));
	       result2.Occurred__c = true;
           insert result2;

	       Action_Skill_Result__c testresult = new Action_Skill_Result__c();
	       testresult.Action_plan_objective__c = testObjective.id;
	       testresult.Attempts__c = 5;
	       testResult.Day__c = Date.parse('1/1/2013');
	       testResult.Status__c = 'V';
	       testResult.Met_Objective__c = 'Y';
	       insert testresult;
        
    	// create shift note
        Progress_Note__c pn = TMN_Generic_Core_TestData.createProgressNote(myData.theSA,myData.theAdm,myData.theServiceCode,myData.contactID,datetime.newinstanceGMT(Date.parse('1/1/2013'), time.newinstance(9,0,0,0)),datetime.newinstanceGMT(Date.parse('1/1/2013'), time.newinstance(14,0,0,0)));
        pn.action_plan__c = testplan.Id;
        update pn;
    	
    }


}