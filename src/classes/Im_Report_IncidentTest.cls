@isTest
private class Im_Report_IncidentTest {
	private static TMN_Generic_Core_TestData myData;

	static testMethod void myUnitTest() {
		User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
		TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];

		system.runas(redwoodUser){
			createData();
			myData.loadData('IA');
			Im_Incident__c incident = new Im_Incident__c(
				Reported_By__c = UserInfo.getUserId(),
				Status__c = 'Event-Draft',
				Date_Documented__c = system.now(),
				Notified_Staff__c = redwoodTmnUser.Id,
				Agencies_Notified__c = 'Agency 1, Agency 2'
			);
			incident.Service_Location__c = myData.theSA.Service_Location__c;
			incident.Supervisor__c = redwoodtmnUser.id;

			insert incident;

			Im_InvolvedParty__c invPrty = new Im_InvolvedParty__c(Im_Incident__c = incident.id, type__c = 'Other', Name = 'Test Inv Party');
			insert invPrty;

			Im_Report_Incident controller = new Im_Report_Incident(incident.Id);
			System.assertEquals(false, controller.editMode);
			System.assertEquals(false, controller.getIsLocked());
			System.assert(controller.getEventTitle().contains('Draft'));
			System.assertEquals(12, controller.getWhereDidItHappenOptions().size());
			System.assertNotEquals('', controller.getOptsForAgenciesNotified());

			System.assertEquals(1, controller.event.getNotifiedStaffJSON().size());
			System.assertNotEquals('', controller.event.getNotified_Staff_Names());
			System.assertNotEquals('', controller.event.getService_Location_Name());
			System.assertEquals(incident.Id, controller.event.incidentSObject().Id);

			System.assertNotEquals(null, controller.eventSubmit());
			Im_Report_Incident.lockIncident(new Id[] { incident.Id });


			controller.myEdit();
			System.assertEquals(true, controller.editMode);
			System.assert(controller.myCancel().getUrl().contains('reportevent'));

			controller = new Im_Report_Incident('randomText');
		}
	}

	private static void createData(){
		myData = new TMN_Generic_Core_TestData();
	}
}