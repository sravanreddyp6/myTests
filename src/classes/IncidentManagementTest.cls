@isTest
public with sharing class IncidentManagementTest {
	public static testmethod void simpleTests() {
		Alias__c alias = (new TestUtils.AliasBuilder())
			.setName('000000')
			.setState('MA')
			.getResult();
		insert alias;
		Service_Location__c serviceLocation = (new TestUtils.ServiceLocationBuilder())
			.setAliasId(alias.Id)
			.getResult();
		insert serviceLocation;

		TestUtils.userBuilder userBuilder = new TestUtils.UserBuilder();
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		User qualifierUser = userBuilder
			.setFirstName('Qualifier')
			.setLastName('Person')
			.setUserAlias('qualif')
			.setEmail('qualifier@tmn.com')
			.getResult();
		User reviewerUser = userBuilder
			.setFirstName('Reviewer')
			.setLastName('Person')
			.setUserAlias('reviewer')
			.setEmail('reviewer@tmn.com')
			.getResult();

		insert qualifierUser;
		insert reviewerUser;

		TMN_User__c reportTmnUser = tmnUserBuilder
			.setAlias(alias)
			.setManagerEmail('qualifier@tmn.com')
			.getResult();
		TMN_User__c qualifierTmnUser = tmnUserBuilder
			.setUserId(qualifierUser.Id)
			.setApprovalLevel(3)
			.getResult();
		TMN_User__c reviewerTmnUser = tmnUserBuilder
			.setUserId(reviewerUser.Id)
			.setApprovalLevel(10)
			.getResult();

		insert reportTmnUser;
		insert qualifierTmnUser;
		insert reviewerTmnUser;

		Im_Incident__c incident = new Im_Incident__c();
		IncidentManagement controller = new IncidentManagement(
				new ApexPages.standardController(incident)
		);
		System.assertEquals(false, controller.getIsLocked());
		System.assertEquals(false, controller.isViewMode);
		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(true, controller.isQualifyingStage);
		System.assertEquals(false, controller.isIncidentStage);
		System.assertEquals('Create Qualifier', controller.name);
		System.assertEquals(serviceLocation.Id, controller.incident.Service_Location__c);
		List<MyRemoteMethods.SelOption> staffOptions = IncidentManagement.getStaffForProgram(
			String.format(
				'\'{\' "programLocation": "{0}", "q": "" \'}\'',
				new String[] { serviceLocation.Id }
			)
		);
		System.assertEquals(3, staffOptions.size(), 'Staff Notified should contain the reporter, qualifier and reviewer');
		System.assertEquals(2, controller.serviceLocations.size(), 'Service Locations should contain a None option and the actual Location');
		System.assertNotEquals('', controller.agenciesNotifiedOptions);

		insert incident;
		controller = new IncidentManagement(
				new ApexPages.standardController(incident)
		);
		controller.qualifyEvent();
		List<MyRemoteMethods.SelOption> reviewers = IncidentManagement.getIncidentReviewers(
			String.format(
				'\'{\' "programLocation": "{0}", "q": "" \'}\'',
				new String[] { serviceLocation.Id }
			)
		);
		System.assertEquals(1, reviewers.size());
		System.assertEquals(reviewerTmnUser.Id, reviewers[0].Id);
		controller.incident.Incident_Reviewer__c = reviewerTmnUser.Id;
		controller.readyForReview();
	}
}