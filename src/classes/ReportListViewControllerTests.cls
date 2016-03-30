@isTest
public with sharing class ReportListViewControllerTests {
	static testmethod void simpleTests() {
		insert new TMN_User__c(
				Salesforce_User_Account__c = UserInfo.getUserId(),
				Operating_Group__c = 'Care Meridian'
				);
		ReportListViewController controller = new ReportListViewController();
		controller.getReportList();
		System.assertNotEquals(null, controller.refrportlst.size());
		System.assertNotEquals(null, controller.VFReportlstPBS.size());
		System.assertNotEquals(null, controller.contractrportlst.size());
		System.assertNotEquals(null, controller.credrportlst.size());
		System.assertNotEquals(null, controller.docrportlst.size());
		System.debug(controller.showNeuroFeatures);
	}
}