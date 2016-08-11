@isTest
public without sharing class Im_ResponsePlan_Test {
	
	@testSetup
	public static void setUpData() {
		TestUtils.userBuilder userBuilder = new TestUtils.UserBuilder();
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		User reviewerUser = userBuilder
				.setFirstName('Reviewer')
				.setLastName('Person')
				.setUserAlias('reviewer')
				.setEmail('reviewer@tmn.com')
				.getInstance();
		insert reviewerUser;

		PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'iServe_Incident_Reviewer'];
		insert new PermissionSetAssignment[] {
				new PermissionSetAssignment(
						AssigneeId = reviewerUser.Id,
						PermissionSetId = ps.Id
				)
		};

		// This is necessary since we can't mix setup and non-setup DML operations
		// in the same context. The User and PermissionSet creations above are
		// counted as setup objects, while the objects below are non-setup ones.
		System.runAs(reviewerUser) {
			TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

			TMN_User__c reviewerTmnUser = tmnUserBuilder
					.setUserId(reviewerUser.Id)
					.setAlias(testData.alias)
					.setApprovalLevel(10)
					.getInstance();
			insert reviewerTmnUser;

			Im_Incident__c incident = new Im_Incident__c(
					Name = 'I-0000000001',
					Status__c = 'Incident-Draft',
					Service_Location__c = testData.serviceLocation.Id,
					What_Happened__c = 'Random Stuff',
					When_Did_It_Happen__c = DateTime.now().addDays(-2),
					When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
					);
			insert incident;
		
		}
	}
	
	public static testmethod void testResponsePlan() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User reviewer = [SELECT Id FROM User WHERE Email='reviewer@tmn.com'];
		
		System.runAs(reviewer) {
		
			TMN_User__c tmnu = [ select id from tmn_user__c where salesforce_user_Account__c = :UserInfo.getUserId()];	
			Im_ResponsePlan controller;
			
			Test.setCurrentPage(Page.Im_ResponsePlan);
			
			try { 
				controller = new Im_ResponsePlan();
			} catch (Exception e) {
				System.assert( e.getMessage().equals('Missing Incident or Invalid Incident ID.' ));
			}
			
			Im_Incident__c incident = [ select name, status__c, service_location__c from im_incident__c LIMIT 1];
			System.currentPageReference().getParameters().put('ID', incident.Id);
			
			controller = new Im_ResponsePlan();
			system.assert( controller.responsePlan != null);
			system.assertEquals( 0, controller.respPlanActivities.size());
			system.assertEquals( true, controller.editMode);
			
			controller.responsePlan.end_date_time__c =controller.responsePlan.end_date_time__c.addDays(7);
			  
			
			controller.saveRespPlan();
			
			
			controller = new Im_ResponsePlan();
			
			system.assertEquals( false, controller.editMode);
			controller.editRespPlan();
			system.assertEquals( true, controller.editMode);
			
			controller.createFirstActivity();
			system.assertEquals( 1, controller.respPlanActivities.size());
			controller.saveRespPlan();	// error 1 thrown - category required
			
			Evaluation_Response__c theActivity = controller.respPlanActivities[0];
			theActivity.Im_Rp_ActivityCategory__c = 'Staff';
			controller.saveRespPlan();	// error 2 thrown - needed required
			theActivity.Im_Rp_ActivityActionNeeded__c = 'Additional Training';
			controller.saveRespPlan();	// error 3 thrown - has to be assigned
			theActivity.Im_Rp_ActivityAssigned_To__c = tmnu.Id;
			controller.saveRespPlan();
			theActivity.Narrative_Note__c = 'Go to training';
			theActivity.Im_Rp_ActivityRequiresAck__c = true;
			controller.saveRespPlan();
			List<ApexPages.Message> msgList = ApexPages.getMessages();
			for(ApexPages.Message msg :  ApexPages.getMessages()) {
				System.assert(msg.getSummary().contains('Activity #1'));
			}
			
			controller.ackActivityId = theActivity.Id;
			controller.ackRespPlanActivity();
			
			controller.responsePlan.disregard__c = true;
			controller.saveRespPlan();	// error 4 thrown - can't disregard with open activities

			msgList = ApexPages.getMessages();
			system.assertEquals(4, msgLIst.size() );
			
			theActivity.status__c = 'Completed';
			controller.saveRespPlan();	// disregarded
			
			system.assertEquals( true, controller.responsePlan.disregard__c );
			
		}
	}
}