@isTest
public with sharing class EvaluationResponseTableControllerTest {
	public static testmethod void simpleTests() {
		Referral__c referral = new Referral__c();
		insert referral;
		Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id);
		insert evaluation;
		EvaluationResponseTableController controller = new EvaluationResponseTableController();
		controller.evaluationId = evaluation.Id;
		Component.Apex.PageBlockSection section = controller.getDialog();
		controller.responseType = 'Allergy';
		controller.showAddResponse();
		System.assertEquals(null, controller.currentResponse.Id);
		Evaluation_Response__c resp = new Evaluation_Response__c(
			Evaluation__c=evaluation.Id,
			RecordTypeId=Utility.getEvaluationResponseRecordType('Allergy')
		);
		insert resp;

		controller.evaluationId = evaluation.Id;  // just to kick off fetchResponses again
		controller.currentResponseId = resp.Id;
		controller.showEditResponse();
		System.assertEquals(resp.Id, controller.currentResponse.Id);
		controller.currentResponse.Allergy_Details__c = 'Test Detail';
		controller.saveResponse();

		System.assertEquals(true, controller.canCreate);
		System.assertEquals(true, controller.canEdit);
		System.assertNotEquals(null, controller.frmTitle);
		System.assertNotEquals(0, controller.numberOfResponses);
		System.assertNotEquals(null, controller.getDialog());
		controller.disregardResponse();

		Contact pbs = new Contact(LastName='Test');
		insert pbs;
		controller.pbsId = pbs.Id;
		controller.showAddResponse();
		System.assertEquals(null, controller.currentResponse.Id);
		System.assertNotEquals(null, controller.getPBSName());

		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		controller.saId = myData.theSA.Id;
		controller.esignable = true;
		controller.username = 'username';
		controller.password = 'password';
		controller.showAddResponse();
		System.assertNotEquals(null, controller.getAuthentication());
		controller.esignRecord();
	}

	public static testmethod void testIsolationEvent() {
		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		EvaluationResponseTableController controller = new EvaluationResponseTableController();
		controller.responseType = 'Isolation Event';
		controller.numRows = 100;
		controller.saId = myData.theSA.Id;
		Component.Apex.PageBlockSection section = controller.getDialog();
		controller.showAddResponse();
		controller.getDialog();

		controller.isolationEventStartDate = '12/15/3015 17:50';
		System.assertNotEquals(null, controller.isolationEventStartDate);
		controller.isolationEventEndDate = '12/15/3015 16:50';
		System.assertNotEquals(null, controller.isolationEventEndDate);

		controller.timeObserved = '12/15/2015 16:50';
		System.assertNotEquals(null, controller.timeObserved);
		controller.timeGiven = '12/15/2015 16:50';
		System.assertNotEquals(null, controller.timeGiven);

		controller.saveResponse();
		System.assertEquals(true, controller.hasError);
	}

	public static testmethod void testTimeLog() {
		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		User user = TMN_Generic_Core_TestData.createUser('ESD General' , 'alias', 'testUser@TMN.com', 'Test', 'User', 'Redwood');
		TMN_User__c tmnUser = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c=:user.Id ];
		EvaluationResponseTableController controller = new EvaluationResponseTableController();
		controller.responseType = 'Time Log';
		controller.numRows = 100;
		controller.saId = myData.theSA.Id;
		Component.Apex.PageBlockSection section = controller.getDialog();
		controller.showAddResponse();

		controller.startDateTime = '12/15/3000 16:50';
		System.assertNotEquals(null, controller.startDateTime);
		controller.endDateTime = '12/14/3000 16:50';
		System.assertNotEquals(null, controller.endDateTime);
		controller.saveResponse();
		System.assertEquals(true, controller.hasError);

		controller.endDateTime = '12/15/3000 16:50';
		controller.saveResponse();
		System.assertEquals(true, controller.hasError);

		controller.startDateTime = '12/10/2015 17:50';
		controller.endDateTime = '12/10/2015 18:50';
		controller.currentResponse.TMN_User__c = tmnUser.Id;
		controller.currentResponse.Location__c = 'Test Location';
		controller.currentResponse.Service_Type__c = 'Pre-Vocational';
		controller.saveResponse();
		System.assertEquals(false, controller.hasError);

		controller.showAddResponse();
		controller.startDateTime = '12/10/2015 17:55';
		controller.endDateTime = '12/10/2015 17:56';
		controller.saveResponse();
		System.assertEquals(true, controller.hasError);  // because of the overlapped response

		controller.startDateTime = '12/09/2015 17:50';
		controller.endDateTime = '12/09/2015 18:50';
		controller.currentResponse.TMN_User__c = tmnUser.Id;
		controller.currentResponse.Location__c = 'Test Location';
		controller.currentResponse.Service_Type__c = 'Pre-Vocational';
		controller.saveResponse();
		System.assertEquals(false, controller.hasError);
	}
}