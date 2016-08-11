@isTest
public with sharing class Report_CANS_DDatQ1_Test {
	static testmethod void simpleTests() {
		Report_CANS_DDatIntake controller = new Report_CANS_DDatIntake();
		System.assert(controller.optSL.size() > 0);
		System.assertEquals(0, controller.CANSStates.size());
		controller.startDate = Date.Today();
		// run the report - it will fail
		controller.runReport();
		
		controller.endDate = Date.Today().addDays(-1);
		controller.runReport();
		controller.endDate = Date.Today().addDays(1);
		
		controller.selectedSL = new List<String>{controller.optSL[0].getValue()};
		System.AssertEquals(false, controller.totalExists );
		controller.runReport();
//		System.assert( controller.questionsList.size() > 0);	// number of questions
		System.assertEquals(1, controller.srd.size());
		System.assertEquals(0, controller.srd.get('TOTAL').pbsCount);
		System.assertEquals(true, controller.totalExists);
		
		
	}
}