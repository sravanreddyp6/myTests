@isTest
public with sharing class behavior_summary_rpt_tests {
	public static testmethod void simpleTests() {
		TMN_Generic_Core_TestData data = new TMN_Generic_Core_TestData();
		data.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
		upsert data.theSA;

		Action_Plan__c testplan = new Action_Plan__c();
		testplan.Service_Assignment__c = data.theSA.id;
		testPlan.Effective_Date__c = Date.newInstance(2014, 10, 10);
		testPlan.Target_Date__c = Date.newInstance(2014, 10, 31);
		insert testPlan;

		Action_Plan_Goal__c testGoal = new Action_Plan_Goal__c();
		testGoal.Action_Plan__c = testPlan.Id;
		testGoal.Description__c = 'Just a testobject';
		insert testGoal;

		Action_Plan_Objective__c testObjective = new Action_Plan_Objective__c();
		testObjective.Action_Plan_Goal__c = testGoal.Id;
		testObjective.Description__c = 'Just a testobject';
		testObjective.Status__c = 'In Progress';
		testObjective.Type__c = 'Skill';
		testObjective.Effective_Date__c = Date.newInstance(2014, 10, 10);
		testObjective.Target_End_Date__c = Date.newInstance(2014, 10, 31);

		insert testObjective;

		behavior_summary_rpt controller = new behavior_summary_rpt();
		controller.selectedPrograms = new List<Id>();
		controller.select2PrmIds = new List<Id>();
		controller.runReport();  // No start date and end date error

		controller.startDate = Date.newInstance(2014, 11, 1);
		controller.enddate = Date.newInstance(2014, 10, 1);

		List<SelectOption> programList = controller.getProgramsList();
		for (SelectOption p: programList){
			controller.selectedprograms.add(p.getValue());
		}
		controller.addPrograms();
		controller.runReport();  // Start Date > End Date error

		List<SelectOption> pbsList = controller.getPBSList();
		for (SelectOption p: pbsList){
			controller.selectedPBS.add(p.getValue());
		}
		controller.startDate = Date.newInstance(2014, 10, 1);
		controller.enddate = Date.newInstance(2014, 11, 1);
		controller.runReport();  // This time it should run fine
		System.assertEquals(1, controller.pbsPlanMap.size());

		programList = controller.getSelect2List();
		for (SelectOption p: programList) {
			controller.select2PrmIds.add(p.getValue());
		}
		System.debug('controller.select2PrmIds: ' + controller.select2PrmIds);
		controller.removePrograms();
		controller.runPdf();
		controller.cancelToNewRun();
		System.assertEquals(7, controller.dayCounter.size());

		behavior_summary_rpt.myDate testDate = new behavior_summary_rpt.myDate(Date.newInstance(2014, 10, 10));
		System.assertNotEquals(null, testDate.intDate);
		System.assertNotEquals(null, testDate.userDate);
		System.assertNotEquals(null, testDate.parsableDate);
	}
}