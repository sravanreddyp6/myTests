@isTest
public with sharing class ProviderServiceAgreementTests {
	@testSetup
	public static void setUpData() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		generator.aliasBuilder
			.setState('OR')
			.setName('038025');  // Mid Valley
		generator.serviceLocationBuilder.setState('OR');
		generator.serviceLocationBuilder
			.setServiceType('CM - Case Management')
			.setProgramId('111111000')
			.setLocationNickname('Brokerage 1');
		TestUtils.CoreData coreData = generator.persistData();

		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{
			new Tmn_Provider__c(
				First_Name__c = 'First',
				Last_Name__c = 'Person',
				Status__c = 'Approved'
			)
		};
		insert providers;

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Provider__c = providers[0].Id,
				Effective_Date__c = Date.today().addMonths(-1),
				Expiration_Date__c = Date.today().addMonths(1),
				Status__c = 'Approved'
			)
		};
		insert applications;

		// Insert the Risk entries
		Eval_Type__c[] evalTypes = new Eval_Type__c[]{
			new Eval_Type__c(Name='Risk Identification Tool', Category__c='Oregon Combined ISP')
		};
		insert evalTypes;

		TestUtils.EvalBuilder evalBuilder = new TestUtils.EvalBuilder();
		evalBuilder.setEvalType('Risk Identification Tool');
		Eval__c[] evals = new Eval__c[]{};
		evals.addAll(evalBuilder
			.setCategory('Health and Medical')
			.setSubCategory('Aspiration')
			.getCommonInstances()
		);
		evals.addAll(new Eval__c[]{
			evalBuilder
				.setFieldType('Dropdown')
				.setHtmlId('aspiration')
				.setFieldName('Presents a risk?')
				.getInstance(),
			evalBuilder
				.setFieldType('Boolean')
				.setHtmlId('asphighRisk')
				.setFieldName('High Risk?')
				.getInstance()
		});
		insert evals;

		TestUtils.EvalDropdownBuilder dropdownBuilder = new TestUtils.EvalDropdownBuilder();
		Eval_Drop_Down__c[] dropdowns = new Eval_Drop_Down__c[]{
			dropdownBuilder
				.setEvalType('Risk Identification Tool')
				.setCategory('Health and Medical')
				.setSubCategory('Aspiration')
				.setHtmlId('aspiration')
				.setOptionName('Yes')
				.setOptionValue('Yes')
				.getInstance(),
			dropDownBuilder
				.setOptionName('No')
				.setOptionValue('No')
				.incrementSequence()
				.getInstance()
		};
		insert dropdowns;
	}

	public static testmethod void simpleTests() {
		PageReference pageRef = Page.ProviderServiceAgreement;
		Test.setCurrentPage(pageRef);
		Id saId = [SELECT Id FROM Service_Assignment__c LIMIT 1].Id;
		pageRef.getParameters().put('saId', saId);
		Service_Assignment_Provider_JO__c agreement = new Service_Assignment_Provider_JO__c();
		ProviderServiceAgreement controller = new ProviderServiceAgreement(new ApexPages.StandardController(agreement));
		System.assertEquals(false, controller.isViewMode);
		System.assertEquals(true, controller.isNewMode);
		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(false, controller.getIsLocked());
		System.assertEquals(true, controller.isMidValley);
		System.assertEquals(false, controller.isMetro);
		System.assertEquals(true, controller.canFinalize);
		System.assertEquals(0, controller.getServiceCodes().size());
		System.assertEquals(0, controller.getCheckedServiceCodes().size());
		System.assertEquals(null, controller.getAssociatedIsp());
		System.assertEquals(false, controller.getHasInactiveDraftIsp());
		System.assertEquals(0, controller.getCommonLawEmployerOptions().size());
		System.assertEquals('N/a', controller.getCommonLawEmployer());
		System.assertEquals(0, controller.getEmergencyContactOptions().size());
		System.assertEquals('N/a', controller.getEmergencyContact());
		System.assertEquals(0, controller.getRisks().size());
		System.assertEquals(0, controller.paList.size());
		System.assertEquals('Provider Service Agreement', controller.getTitle());

		System.assertEquals(null, controller.save()); // Validation error here
		Tmn_Provider__c provider = [SELECT Id, Name FROM Tmn_Provider__c];
		controller.chosenProvider = provider.Id;
		System.assertEquals(String.format('{0} - {1}', new String[]{Date.today().addMonths(-1).format(), Date.today().addMonths(1).format()}), controller.getProviderApplicationDates());
		controller.agreement.Start_Date__c = Date.today();
		controller.agreement.End_Date__c = Date.today().addDays(-1);

		// Validation errors since start date > end date
		System.assertEquals(null, controller.save());

		controller.agreement.End_Date__c = Date.today().addYears(2);

		// Validation errors since since end date > start date + 13 months
		System.assertEquals(null, controller.save());

		controller.agreement.Start_Date__c = Date.today().addMonths(-2);
		controller.agreement.End_Date__c = Date.today().addDays(15);

		// Validation errors since start date not within application range
		System.assertEquals(null, controller.save());

		controller.agreement.Start_Date__c = Date.today();

		// Should be good to save now
		System.assertNotEquals(null, controller.save());

		// Still should not be able to finalize
		System.assertEquals(null, controller.finalize());
		controller.agreement.Agreement_Type__c = 'Personal Support Worker (PSW)';
		controller.agreement.Health_and_Safety_Protocols_Received__c = 'Other';
		controller.agreement.Credentialed_through_OHCC_as__c = 'Enhanced PSW;Exceptional PSW';
		System.assertNotEquals(null, controller.save());
		// To make sure some code branches are hit
		System.assertEquals(null, controller.finalize());

		// Insert a combined ISP here in order to test out the remaining functionalities
		Case_Management_Plan__c isp = new Case_Management_Plan__c(
			Service_Assignment__c = saId,
			Status__c = 'Active Final'
		);
		insert isp;

		Evaluation_Response__c[] plans = new Evaluation_Response__c[]{
			new Evaluation_Response__c(
				RecordTypeId = Utility.getEvaluationResponseRecordType('K Plan Services'),
				ISP_Service_Element_Service_Code__c = '149-OR003-Service Related Comm Trans, Commercial',
				ISP_Units__c = 10,
				ISP_Unit_Type__c = 'Hour(s)',
				Isp_Per_Frequency__c = 'Day',
				Case_Management_Plan__c = isp.Id
			),
			new Evaluation_Response__c(
				RecordTypeId = Utility.getEvaluationResponseRecordType('K Plan Services'),
				ISP_Service_Element_Service_Code__c = '149-OR004-Service Related Comm Trans, Mil-WD-Wk',
				ISP_Units__c = 20,
				ISP_Unit_Type__c = 'Hour(s)',
				Isp_Per_Frequency__c = 'Day',
				Case_Management_Plan__c = isp.Id
			)
		};
		insert plans;

		controller = new ProviderServiceAgreement(new ApexPages.StandardController(controller.agreement));
		System.assertEquals(isp.Id, controller.getAssociatedIsp());
		System.assertEquals(2, controller.getServiceCodes().size());

		ProviderServiceAgreement.ServiceCode[] serviceCodes = controller.getServiceCodes();
		serviceCodes[0].checked = true;

		controller.setServiceCodes(serviceCodes);
		// Validation error since rates/units are empty
		System.assertEquals(null, controller.save());


		serviceCodes[0].units = 1000;
		serviceCodes[0].rate = '100';

		controller.setServiceCodes(serviceCodes);
		// Validation error since units are too big
		System.assertEquals(null, controller.save());

		serviceCodes[0].units = 5;
		controller.setServiceCodes(serviceCodes);
		// Should be good to save now
		System.assertNotEquals(null, controller.save());


		// insert some Risk entries here
		TestUtils.EvalValueBuilder valueBuilder = new TestUtils.EvalValueBuilder();
		valueBuilder = valueBuilder
			.setEvalType('Risk Identification Tool')
			.setWhatId(isp.Id)
			.setWhatIdObject('Case_Management_Plan__c');
		Eval_Value__c[] values = new Eval_Value__c[]{
			valueBuilder
				.setCategory('Health and Medical')
				.setSubCategory('Aspiration')
				.setHtmlId('IsValid')
				.setValue(true)
				.getInstance(),
			valueBuilder
				.setCategory('Health and Medical')
				.setSubCategory('Aspiration')
				.setHtmlId('aspiration')
				.setValue('Yes')
				.getInstance(),
			valueBuilder
				.setCategory('Health and Medical')
				.setSubCategory('Aspiration')
				.setHtmlId('asphighRisk')
				.setValue(true)
				.getInstance()
		};
		insert values;

		controller = new ProviderServiceAgreement(new ApexPages.StandardController(controller.agreement));
		ProviderServiceAgreement.ServiceCode[] checkedServiceCodes = controller.getCheckedServiceCodes();
		System.assertEquals(1, checkedServiceCodes.size());
		System.assertEquals(5, checkedServiceCodes[0].units);
		System.assertEquals('100', checkedServiceCodes[0].rate);

		// insert some Related Parties here
		Related_Party__c[] relatedParties = new Related_Party__c[]{
			new Related_Party__c(
				Person_Being_Served__c = controller.agreement.Service_Assignment__r.Admission__r.Person_Being_Served__c,
				Type__c = 'Common Law Employer',
				Name = 'Employer',
				Status__c = 'Active'
			),
			new Related_Party__c(
				Person_Being_Served__c = controller.agreement.Service_Assignment__r.Admission__r.Person_Being_Served__c,
				Type__c = 'Adjuster',
				Name = 'Adjuster',
				Status__c = 'Active',
				Phone__c = '1112223333',
				Phone_1_Type__c = 'Fax',
				Phone_2__c = '444556666',
				Phone_2_Type__c = 'Fax'
			),
			new Related_Party__c(
				Person_Being_Served__c = controller.agreement.Service_Assignment__r.Admission__r.Person_Being_Served__c,
				Type__c = 'Adjuster',
				Name = 'Adjuster 2',
				Status__c = 'Active',
				Phone__c = '1112223333',
				Phone_2__c = '444556666'
			)
		};
		insert relatedParties;

		System.assertEquals(3, controller.getEmergencyContactOptions().size());
		System.assertEquals(1, controller.getCommonLawEmployerOptions().size());

		controller.agreement.Common_Law_Employer__c = controller.getCommonLawEmployerOptions()[0].getValue();
		controller.agreement.Emergency_Contact_and_Phone__c = controller.getEmergencyContactOptions()[1].getValue();

		System.assertEquals(relatedParties[0].Name, controller.getCommonLawEmployer());
		System.assertEquals(
			relatedParties[1].Name + ' - ' + relatedParties[1].Phone_1_Type__c + ': ' + relatedParties[1].Phone__c + ', ' + relatedParties[1].Phone_2_Type__c + ': ' + relatedParties[1].Phone_2__c,
			controller.getEmergencyContact()
		);
		controller.agreement.Enhanced_Credential_Start_Date__c = Date.today().addDays(-1);
		controller.agreement.Enhanced_Credential_End_Date__c = Date.today().addDays(1);
		controller.agreement.Exceptional_Credential_Start_Date__c = Date.today().addDays(-1);
		controller.agreement.Exceptional_Credential_End_Date__c = Date.today().addDays(1);
		controller.agreement.Authorization_Number__c = '123456';
		controller.agreement.Other_Health_Safety_Protocols_Received__c = 'Other things';

		System.assertEquals(1, controller.getRisks().size());

		controller.save();

		System.assertNotEquals(null, controller.finalize());

		controller = new ProviderServiceAgreement(new ApexPages.StandardController(controller.agreement));
		// Validation error since no date & reason were filled in
		System.assertEquals('Active', controller.agreement.Status__c);
		System.assertEquals(null, controller.terminate());
		System.assertEquals('Active', controller.agreement.Status__c);

		controller.agreement.Termination_Date__c = Date.today();
		controller.agreement.Termination_Reason__c = 'Test Reason';
		System.assertNotEquals(null, controller.terminate());
		System.assertEquals('Terminated', controller.agreement.Status__c);

		controller.disregard();
		System.assertEquals(true, controller.agreement.Disregard__c);
	}
}