@isTest
public with sharing class Report_CANS_ActionableByCluster_Test {
	static testmethod void simpleTests() {
		Report_CANS_ActionableByCluster controller = new Report_CANS_ActionableByCluster();
		System.assertEquals(4, controller.optClusters.size());
		System.assertEquals(3, controller.optInterval.size());
		System.assertEquals(3, controller.optDD.size());
		System.assert(controller.optSL.size() > 0);
		System.assertEquals(0, controller.CANSStates.size());
		controller.startDate = Date.Today();
		controller.endDate = Date.Today().addDays(1);
		controller.selectedCluster = 'WellBeing';
		controller.selectedInterval = 'Intake';
		controller.selectedDD = 'All';
		controller.selectedSL = new List<String>{controller.optSL[0].getValue()};
		controller.runReport();
		//System.assert( controller.questionsList.size() > 0);	// number of questions
		System.assertEquals(1, controller.srd.size());
		System.assertEquals(0, controller.srd.get('TOTAL').pbsCount);
		
		controller.selectedCluster = 'Education';
		controller.selectedInterval = 'Q1';
		controller.selectedDD = 'With';
		controller.selectedSL = new List<String>{controller.optSL[0].getValue()};
		controller.runReport();
		
		controller.selectedCluster = 'Behavior_and_Risk';
		controller.selectedInterval = 'Discharge';
		controller.selectedDD = 'Without';
		controller.selectedSL = new List<String>{controller.optSL[0].getValue()};
		controller.runReport();
		
	}
}