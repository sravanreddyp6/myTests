@isTest
public with sharing class Incident_Form_CreateEdit_Test {
	public static testmethod void simpleTests() {
		Tmn_Generic_Core_TestData testData = new Tmn_Generic_Core_TestData();
		Map<String, Schema.RecordTypeInfo> recordTypeMap = Incident__c.SObjectType.getDescribe().getRecordTypeInfosByName();
		Incident__c incident = new Incident__c();

		System.currentPageReference().getParameters().put('RecordTypeId', recordTypeMap.get('PBS').getRecordTypeId());
		System.currentPageReference().getParameters().put('saId', testData.theSA.Id);
		Incident_Form_CreateEdit controller = new Incident_Form_CreateEdit(
			new ApexPages.StandardController(incident)
		);

		System.assertNotEquals('', controller.getProgDetail());

		controller.personListJson = '[]';
		controller.incident.First_Reported_By__c = 'Employee';
		controller.incident.Where_Incident_Occurred__c = 'Other Location';
		controller.incident.First_Response_Action_taken__c = 'Other';
		controller.saveIncident();  // validation errors here

		controller.incident.Unknown_Date_Occurred__c = true;
		controller.incident.First_Reported_By__c = 'Mentor';
		controller.incident.Where_Incident_Occurred__c = 'Community Location';
		controller.incident.First_Response_Action_Taken_Other__c = 'Other Action';
		controller.saveIncident();  // validation errors here

		controller.incident.First_Reported_By__c = 'External Party';
		controller.incident.Community_Location__c = 'Test Location';
		controller.saveIncident();  // validation errors here

		controller.incident.External_Party__c = 'Test External Party';
		controller.incident.Where_Incident_Occurred__c = 'Residence';
		controller.incident.Staff_Present__c = 'No';
		controller.incident.Others_Present_at_Time_of_Incident__c = 'No';
		controller.incident.Mentor_present__c = 'No';

		controller.saveIncident();  // validation errors here

		controller.incident.Network_Type__c = 'Test Network Type';
		controller.saveIncident();

		System.assertNotEquals(null, controller.incident.Id);

		System.assertNotEquals(null, controller.servAssign);
		System.assertNotEquals('', controller.getProgDetail());

		controller.incident.Unknown_Date_Occurred__c = false;
		controller.incident.Date_Occurred__c = null;
		controller.incident.First_Reported_By__c = null;
		controller.incident.Where_Incident_Occurred__c = null;
		controller.incident.First_Response_Action_Taken__c = null;
		controller.incident.Staff_Present__c = null;
		controller.incident.Mentor_Present__c = null;
		controller.validateIncidentSubmit(controller.incident);

		Incident_Person__c[] people = new Incident_Person__c[]{
			new Incident_Person__c()
		};
	}
}