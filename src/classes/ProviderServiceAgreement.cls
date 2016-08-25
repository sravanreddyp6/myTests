public with sharing class ProviderServiceAgreement {
	public Service_Assignment_Provider_JO__c agreement { get; set; }
	private static transient Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Service_Assignment_Provider_JO__c.getRecordTypeInfosByName();

	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit' || isNewMode;
		}
	}

	public Boolean isNewMode {
		get {
			return this.mode == 'new';
		}
	}

	public Boolean getIsLocked() {
		return this.agreement.Disregard__c || this.agreement.Status__c != 'In Progress';
	}

	public Boolean isMetro {
		get {
			return this.agreement.Service_Assignment__r.Alias__c == '038020';
		}
	}

	public Boolean isMidValley {
		get {
			return this.agreement.Service_Assignment__r.Alias__c == '038025';
		}
	}

	public Boolean canFinalize {
		get {
			return this.agreement.Tmn_Provider__r.Status__c != 'Expired'
				&& this.agreement.Tmn_Provider__r.Status__c != 'Disqualified'
				&& !this.agreement.Disregard__c
				&& this.agreement.Status__c == 'In Progress'
				&& this.getAssociatedIsp() != null;
		}
	}

	public List<Service_Assignment_Personal_Agent__c> paList {
		get {
			if (paList == null) {
				paList = [
					SELECT Id, From_Date__c, To_Date__c, Personal_Agent__c, Personal_Agent__r.Name,
					       Personal_Agent__r.Email__c, Personal_Agent__r.Office_Phone__c,Personal_Agent__r.phone_ext__c,
					       Service_Assignment__c, Status__c
					  FROM Service_Assignment_Personal_Agent__c
					 WHERE Service_Assignment__c = :this.agreement.Service_Assignment__c
					   AND Status__c = 'Active'
					 ORDER BY Status__c ASC, From_Date__c DESC
				];
			}
			return paList;
		}
		set;
	}

	private ServiceCode[] serviceCodes;
	public ServiceCode[] getServiceCodes() {
		if (serviceCodes != null) {
			return serviceCodes;
		}
		Id associatedIsp = this.getAssociatedIsp();
		serviceCodes = new ServiceCode[]{};
		if (associatedIsp == null) {
			return serviceCodes;
		}
		Evaluation_Response__c[] allPlans = [
			SELECT Id, ISP_Units__c, ISP_Service_Element_Service_Code__c, RecordType.Name,
			       ISP_Unit_Type__c, ISP_Per_Frequency__c, ISP_List_Needs_Identified__c,
			       ISP_Identified_needs__c, ISP_Person_Preference_Service_Delivery__c
			  FROM Evaluation_Response__c
			 WHERE RecordType.Name IN ('K Plan Services', 'Waiver Services')
			   AND Case_Management_Plan__c = :associatedIsp
			 ORDER BY RecordType.Name
		];
		Evaluation_Response__c[] existing = [
			SELECT Id, ISP_Units__c, ISP_Plan__c, Service_Agreement_Rate__c
			  FROM Evaluation_Response__c
			 WHERE RecordType.Name = 'ISP Service Code'
			   AND Service_Agreement__c = :this.agreement.Id
		];
		Map<Id, Evaluation_Response__c> ispMap = new Map<Id, Evaluation_Response__c>();
		for (Evaluation_Response__c serviceCode: existing) {
			ispMap.put(serviceCode.Isp_Plan__c, serviceCode);
		}
		for (Evaluation_Response__c plan: allPlans) {
			ServiceCode serviceCode = new ServiceCode();
			serviceCode.ispPlan = plan;
			if (plan.RecordType.Name == 'K Plan Services') {
				serviceCode.listNeedsToBeAddressed = plan.ISP_List_Needs_Identified__c;
			} else {
				serviceCode.listNeedsToBeAddressed = plan.ISP_Identified_needs__c;
			}
			if (ispMap.containsKey(plan.Id)) {
				serviceCode.checked = true;
				serviceCode.units = ispMap.get(plan.Id).Isp_Units__c;
				serviceCode.serviceCodeId = ispMap.get(plan.Id).Id;
				serviceCode.rate = ispMap.get(plan.Id).Service_Agreement_Rate__c;
			}
			serviceCodes.add(serviceCode);
		}
		return serviceCodes;
	}

	public ServiceCode[] getCheckedServiceCodes() {
		ServiceCode[] serviceCodes = this.getServiceCodes();
		ServiceCode[] checkedServiceCodes = new ServiceCode[]{};
		for (ServiceCode serviceCode: serviceCodes) {
			if (serviceCode.checked == null || !serviceCode.checked) {
				continue;
			}
			checkedServiceCodes.add(serviceCode);
		}
		return checkedServiceCodes;
	}

	public void setServiceCodes(ServiceCode[] value) {
		this.serviceCodes = value;
	}

	private transient Id associatedIsp;
	private transient Boolean associatedIspSet;
	public Id getAssociatedIsp() {
		if (associatedIspSet != null && associatedIspSet) {
			return associatedISP;
		}
		if (this.agreement.Status__c != 'In Progress') {
			associatedIsp = this.agreement.Finalized_ISP__c;
			associatedIspSet = true;
		} else {
			Case_Management_Plan__c[] plans = [
				SELECT Id
				  FROM Case_Management_Plan__c
				 WHERE RecordType.Name = 'OR Combined ISP'
				   AND Status__c = 'Active Final'
				   AND Service_Assignment__c = :this.agreement.Service_Assignment__c
			];
			if (plans.size() == 0) {
				return null;
			}
			associatedIsp = plans[0].Id;
			associatedIspSet = true;
		}
		return associatedIsp;
	}

	private transient Boolean hasInactiveDraftIsp;
	public Boolean getHasInactiveDraftIsp() {
		if (hasInactiveDraftIsp != null) {
			return hasInactiveDraftIsp;
		}
		Case_Management_Plan__c[] plans = [
			SELECT Id
			  FROM Case_Management_Plan__c
			 WHERE RecordType.Name = 'OR Combined ISP'
			   AND Status__c = 'Inactive Draft'
			   AND Service_Assignment__c = :this.agreement.Service_Assignment__c
		];
		if (plans.size() == 0) {
			hasInactiveDraftIsp = false;
		} else {
			hasInactiveDraftIsp = true;
		}
		return hasInactiveDraftIsp;
	}

	private transient SelectOption[] commonLawEmployerOptions;
	public SelectOption[] getCommonLawEmployerOptions() {
		if (commonLawEmployerOptions != null) {
			return commonLawEmployerOptions;
		}
		commonLawEmployerOptions = new SelectOption[]{};
		Related_Party__c[] relatedParties = [
			SELECT Id, Name
			  FROM Related_Party__c
			 WHERE (Person_Being_Served__c = :this.agreement.Service_Assignment__r.Admission__r.Person_Being_Served__c
			   AND Type__c = 'Common Law Employer'
			   AND Status__c = 'Active')
			    OR Id = :this.agreement.Common_Law_Employer__c  // this line is here to make sure the code still functions in case our RP gets modified on the PBS side
		];
		for (Related_Party__c relatedParty: relatedParties) {
			commonLawEmployerOptions.add(new SelectOption(relatedParty.Id, relatedParty.Name));
		}
		return commonLawEmployerOptions;
	}

	private transient String commonLawEmployer;
	public String getCommonLawEmployer() {
		if (commonLawEmployer != null) {
			return commonLawEmployer;
		}
		if (this.agreement.Common_Law_Employer__c == null) {
			commonLawEmployer = 'N/a';
		} else {
			Related_Party__c relatedParty = [
				SELECT Id, Name
				  FROM Related_Party__c
				 WHERE Id = :this.agreement.Common_Law_Employer__c
			];
			commonLawEmployer = relatedParty.Name;
		}
		return commonLawEmployer;
	}

	private transient SelectOption[] emergencyContactOptions;
	public SelectOption[] getEmergencyContactOptions() {
		if (emergencyContactOptions != null) {
			return emergencyContactOptions;
		}
		emergencyContactOptions = new SelectOption[]{};
		Related_Party__c[] relatedParties = [
			SELECT Id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c
			  FROM Related_Party__c
			 WHERE (Person_Being_Served__c = :this.agreement.Service_Assignment__r.Admission__r.Person_Being_Served__c
			   AND Status__c = 'Active')
			    OR Id = :this.agreement.Emergency_Contact_and_Phone__c  // this line is here to make sure the code still functions in case our RP gets modified on the PBS side
		];
		for (Related_Party__c relatedParty: relatedParties) {
			emergencyContactOptions.add(new SelectOption(relatedParty.Id, formatEmergencyContactLabel(relatedParty)));
		}
		return emergencyContactOptions;
	}

	public String emergencyContactPhone {
		get {
			String[] splitContact = this.getEmergencyContact().split(' - ', 2);
			if (splitContact.size() == 2) {
				return splitContact[1];
			}
			return '';
		}
	}

	private transient String emergencyContact;
	public String getEmergencyContact() {
		if (emergencyContact != null) {
			return emergencyContact;
		}
		if (this.agreement.Emergency_Contact_and_Phone__c == null) {
			emergencyContact = 'N/a';
		} else {
			Related_Party__c relatedParty = [
				SELECT Id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c
				  FROM Related_Party__c
				 WHERE Id = :this.agreement.Emergency_Contact_and_Phone__c
			];
			emergencyContact = formatEmergencyContactLabel(relatedParty);
		}
		return emergencyContact;
	}

	public String[] protocolsReceived {
		get {
			protocolsReceived = new String[]{};
			if (this.agreement.Health_and_Safety_Protocols_Received__c != null) {
				String[] splitProtocols = this.agreement.Health_and_Safety_Protocols_Received__c.split(';');
				for (String protocol: splitProtocols) {
					if (protocol == 'Other') {
						protocolsReceived.add(
							String.format('{0}: {1}', new String[]{
								protocol,
								(this.agreement.Other_Health_Safety_Protocols_Received__c == null || this.agreement.Other_Health_Safety_Protocols_Received__c == '') ? '' :  this.agreement.Other_Health_Safety_Protocols_Received__c
							})
						);
					} else {
						protocolsReceived.add(protocol);
					}
				}
			}
			return protocolsReceived;
		}
		private set;
	}

	private static String formatEmergencyContactLabel(Related_Party__c party) {
		String label = party.Name + ' - ';
		if (party.Phone__c == null && party.Phone_2__c == null) {
			label += 'No Phone Numbers to Display';
		} else {
			String[] phones = new String[]{};
			if (party.Phone__c != null && party.Phone_1_Type__c != null) {
				phones.add(party.Phone_1_Type__c + ': ' + party.Phone__c);
			} else if (party.Phone__c != null && party.Phone_1_type__c == null) {
				phones.add('Phone 1: ' + party.Phone__c);
			}
			if (party.Phone_2__c != null && party.Phone_2_Type__c != null) {
				phones.add(party.Phone_2_Type__c + ': ' + party.Phone_2__c);
			} else if (party.Phone_2__c != null && party.Phone_2_type__c == null) {
				phones.add('Phone 2: ' + party.Phone_2__c);
			}
			label += String.join(phones, ', ');
		}
		return label;
	}

	private static string NO_INDENTIFIED_RISKS = 'No Identified Risks';

	private transient Risk[] risks;
	public Risk[] getRisks() {
		if (risks != null) {
			return risks;
		}
		risks = new Risk[]{};
		Risk noRiskOption = new Risk();
		noRiskOption.checked = this.agreement.No_Identified_Risks__c;
		noRiskOption.value = NO_INDENTIFIED_RISKS;
		risks.add(noRiskOption);

		Id associatedIsp = this.getAssociatedIsp();
		if (associatedIsp == null) {
			return risks;
		}
		Evaluation_Response__c[] existing = [
			SELECT Id, Isp_Risk__c
			  FROM Evaluation_Response__c
			 WHERE RecordType.Name = 'ISP Risk'
			   AND Service_Agreement__c = :this.agreement.Id
		];
		Map<String, Evaluation_Response__c> ispMap = new Map<String, Evaluation_Response__c>();
		for (Evaluation_Response__c risk: existing) {
			ispMap.put(risk.Isp_Risk__c, risk);
		}
		Eval_Value__c[] values = [
			SELECT Id, Eval__r.Category__c, Eval__r.Sub_Category__c, Eval__r.HtmlId__c,
			       Eval__r.Field_Name__c, Eval__r.Field_Type__c, Boolean__c, Text_Over_250__c,
			       Text_Under_250__c
			  FROM Eval_Value__c
			 WHERE Eval__r.Eval_Type__r.Name = 'Risk Identification Tool'
			   AND What_Id__c = :this.getAssociatedIsp()
			   AND Eval__r.Category__c IN ('Health and Medical', 'Safety', 'Financial', 'Mental Health', 'Behavior')
			   AND Eval__r.Visible__c = true
			   AND Eval__r.Field_Type__c != 'Hidden'
			 ORDER BY Eval__r.Category_Sequence__c, Eval__r.Sub_Category_Sequence__c,
			          Eval__r.Field_Sequence__c
		];
		Map<String, EvalValueRisk> sectionMap = new Map<String, EvalValueRisk>();
		String currentSubsection = '';
		// This assumes that the first question in every section is the Boolean question about whether
		// it's posing a risk. This assumption makes it so much easier to get that information, rather
		// than having to manually query using HtmlId__c or Field_Name__c
		for (Eval_Value__c value: values) {
			String subsection = String.format(
				'{0}~{1}',
				new String[] {
					value.Eval__r.Category__c,
					value.Eval__r.Sub_Category__c
				}
			);
			if (subsection != currentSubsection) {  // This is the 1st entry
				sectionMap.put(subsection, new EvalValueRisk());
				sectionMap.get(subsection).section = value.Eval__r.Sub_Category__c;
				if (value.Eval__r.Field_Type__c == 'Dropdown') {
					sectionMap.get(subsection).enabled = (value.Text_Under_250__c == 'Yes');
				}
			}
			if (value.Eval__r.Field_Name__c == 'High Risk?') {
				sectionMap.get(subsection).highRisk = value.Boolean__c;
			} else if (value.Eval__r.Field_Name__c == 'How is the risk addressed?') {
				sectionMap.get(subsection).address = value.Text_Over_250__c;
			}
			currentSubsection = subsection;
		}
		EvalValueRisk[] allRisks = sectionMap.values();
		for (EvalValueRisk evalValueRisk: allRisks) {
			if (evalValueRisk.enabled != null && evalValueRisk.enabled) {
				Risk risk = new Risk();
				risk.value = String.format(
					'{0} - {1} - {2}',
					new String[] {
						evalValueRisk.section,
						(evalValueRisk.highRisk != null && evalValueRisk.highRisk) ? 'High Risk' : 'Not High Risk',
						evalValueRisk.address
					}
				);
				if (ispMap.containsKey(risk.value)) {
					risk.checked = true;
					risk.evaluationResponseId = ispMap.get(risk.value).Id;
				}
				risks.add(risk);
			}
		}
		return risks;
	}

	public Risk[] getCheckedRisks() {
		Risk[] risks = this.getRisks();
		Risk[] checkedRisks = new Risk[]{};
		for (Risk risk: risks) {
			if (risk.checked == null || !risk.checked) {
				continue;
			}
			checkedRisks.add(risk);
		}
		return checkedRisks;
	}

	public void setRisks(Risk[] value) {
		this.risks = value;
	}

	class EvalValueRisk {
		public String section { get; set; }
		public Boolean enabled { get; set; }
		public Boolean highRisk { get; set; }
		public String address { get; set; }
	}

	public class Risk {
		public Boolean checked { get; set; }
		public Id evaluationResponseId { get; set; }
		public String value { get; set; }
	}

	public ProviderServiceAgreement(ApexPages.StandardController standardController) {
		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Disregard__c', 'Finalized_ISP__c', 'Tmn_Provider__r.Name', 'Tmn_Provider__r.Status__c',
				'Emergency_Contact_and_Phone__r.Name', 'Emergency_Contact_and_Phone__r.Phone__c',
				'Emergency_Contact_and_Phone__r.Phone_1_Type__c', 'Emergency_Contact_and_Phone__r.Phone_2__c',
				'Emergency_Contact_and_Phone__r.Phone_2_Type__c',
				'Health_and_Safety_Protocols_Received__c', 'Other_Health_Safety_Protocols_Received__c',
				'Service_Assignment__r.Alias__c', 'Status__c', 'Common_Law_Employer__c',
				'Service_Assignment__r.Admission__r.Person_Being_Served__c',
				'Service_Assignment__r.Person_Being_Served__r.FirstName',
				'Service_Assignment__r.Person_Being_Served__r.LastName',
				'Service_Assignment__r.Person_Being_Served__r.PRIME_Number__c',
				'Tmn_Provider__r.SPD_Number__c', 'No_Identified_Risks__c'
			});
		}
		this.agreement = (Service_Assignment_Provider_JO__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();

		if (this.agreement.Id != null) {
			this.mode = 'view';
			if (!this.getIsLocked() && params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
		} else {
			// This is a new Agreement
			this.mode = 'new';
			this.agreement.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
			this.agreement.Service_Assignment__c = params.get('saId');
			this.agreement.Service_Assignment__r = [
				SELECT Id, Service_Location__c, Admission__c, Admission__r.Person_Being_Served__c,
				       Alias__c
				  FROM Service_Assignment__c
				 WHERE Id = :this.agreement.Service_Assignment__c
			];
			this.agreement.Status__c = 'In Progress';
			SelectOption[] commonLawEmployers = this.getCommonLawEmployerOptions();
			if (commonLawEmployers.size() == 1) {
				this.agreement.Common_Law_Employer__c = commonLawEmployers[0].getValue();
			}
			SelectOption[] emergencyContacts = this.getEmergencyContactOptions();
			if (emergencyContacts.size() == 1) {
				this.agreement.Emergency_Contact_and_Phone__c = emergencyContacts[0].getValue();
			}
		}
	}

	public String getTitle() {
		return 'Provider Service Agreement';
	}

	public Id chosenProvider {
		get;
		set {
			this.agreement.Tmn_Provider__c = value;
			this.agreement.Tmn_Provider__r = [
				SELECT Id, Name
				  FROM Tmn_Provider__c
				 WHERE Id = :value
			];
		}
	}

	private transient String providerApplicationDates;
	public String getProviderApplicationDates() {
		if (providerApplicationDates != null) {
			return providerApplicationDates;
		}
		TMN_Provider_Application__c[] applications = [
			SELECT Id, Effective_Date__c, Expiration_Date__c
			  FROM TMN_Provider_Application__c
			 WHERE Status__c = 'Approved'
			   AND Provider__c = :agreement.Tmn_Provider__r.Id
			   AND Disqualified__c = false
		];
		String[] providers = new String[]{};
		for (Tmn_Provider_Application__c application: applications) {
			providers.add(application.Effective_Date__c.format() +' - '+ application.Expiration_Date__c.format());
		}
		providerApplicationDates = String.join(providers, ', ');
		return providerApplicationDates;
	}

	public PageReference disregard() {
		this.agreement.Disregard__c = true;
		return this.save(false);
	}

	public PageReference terminate() {
		if (this.agreement.Status__c != 'Active') {
			throw new Utility.CustomException('Only Active Provider Associations can be terminated');
		}
		String originalStatus = this.agreement.Status__c;
		this.agreement.Status__c = 'Terminated';
		PageReference pageRef = this.save(true);
		if (pageRef == null) {
			this.agreement.Status__c = originalStatus;
		}
		return pageRef;
	}

	public PageReference finalize() {
		if (this.agreement.Status__c != 'In Progress') {
			throw new Utility.CustomException('Only In Progress Provider Associations can be finalized');
		}
		String originalStatus = this.agreement.Status__c;
		if (this.agreement.Start_Date__c > Date.today()) {
			this.agreement.Status__c = 'Pending';
		} else if (this.agreement.End_Date__c < Date.today()) {
			this.agreement.Status__c = 'Expired';
		} else {
			this.agreement.Status__c = 'Active';
		}
		this.agreement.Finalized_ISP__c = this.getAssociatedIsp();
		PageReference pageRef = this.save(true);
		if (pageRef == null) {
			this.agreement.Status__c = originalStatus;
			this.agreement.Finalized_ISP__c = null;
		}
		return pageRef;
	}

	public PageReference save() {
		return this.save(true);
	}

	public PageReference save(Boolean validateNeeded) {
		if (validateNeeded && !validate(this.agreement, this.getCheckedRisks(), this.getCheckedServiceCodes(), this.isMidValley, this.isMetro)) {
			return null;
		}
		Evaluation_Response__c[] serviceCodesToUpsert = new Evaluation_Response__c[]{};
		Evaluation_Response__c[] serviceCodesToDelete = new Evaluation_Response__c[]{};
		String servicesProvided = '';
		for (ServiceCode serviceCode: this.getServiceCodes()) {
			if (serviceCode.checked == null || !serviceCode.checked) {
				if (serviceCode.serviceCodeId != null) {
					serviceCodesToDelete.add(new Evaluation_Response__c(Id = serviceCode.serviceCodeId));
				}
				continue;
			}
			servicesProvided += serviceCode.ispPlan.ISP_Service_Element_Service_Code__c + '\n';
			Evaluation_Response__c serviceCodeToUpsert = new Evaluation_Response__c(
				Id = serviceCode.serviceCodeId,
				ISP_Units__c = serviceCode.units,
				Service_Agreement__c = this.agreement.Id,
				Service_Agreement_Rate__c = serviceCode.rate,
				ISP_Plan__c = serviceCode.ispPlan.Id,
				RecordTypeId = Utility.getEvaluationResponseRecordType('ISP Service Code')
			);
			serviceCodesToUpsert.add(serviceCodeToUpsert);
		}

		if (serviceCodesToUpsert.size() > 0) {
			upsert serviceCodesToUpsert;
		}
		if (serviceCodesToDelete.size() > 0) {
			delete serviceCodesToDelete;
		}

		Evaluation_Response__c[] risksToUpsert = new Evaluation_Response__c[]{};
		Evaluation_Response__c[] risksToDelete = new Evaluation_Response__c[]{};
		this.agreement.No_Identified_Risks__c = false;
		for (Risk risk: this.getRisks()) {
			if (risk.checked == null || !risk.checked) {
				if (risk.evaluationResponseId != null) {
					risksToDelete.add(new Evaluation_Response__c(Id = risk.evaluationResponseId));
				}
				continue;
			}
			if (risk.value == NO_INDENTIFIED_RISKS) {
				this.agreement.No_Identified_Risks__c = true;
			} else {
				Evaluation_Response__c riskToUpsert = new Evaluation_Response__c(
					Id = risk.evaluationResponseId,
					ISP_Risk__c = risk.value,
					Service_Agreement__c = this.agreement.Id,
					RecordTypeId = Utility.getEvaluationResponseRecordType('ISP Risk')
				);
				risksToUpsert.add(riskToUpsert);
			}
		}
		if (risksToUpsert.size() > 0) {
			upsert risksToUpsert;
		}
		if (risksToDelete.size() > 0) {
			delete risksToDelete;
		}

		this.agreement.Services_Provided__c = servicesProvided;
		upsert this.agreement;

		if (isFinalized(this.agreement)) {
			// Attach the PDF to the finalized agreement
			PageReference pdfPage = Page.ProviderServiceAgreementPdf;
			pdfPage.getParameters().put('id', this.agreement.id);
			Attachment attachmentPDF = new Attachment(
				Name = String.format(
					'Provider Service Agreement Association {0}.pdf',
					new String[]{
						Date.today().format()
					}
				),
				Body = Test.isRunningTest() ? Blob.valueOf('Test Content') : pdfPage.getContent(),
				ParentId = this.agreement.Id
			);
			insert attachmentPDF;
		}
		PageReference resultPage = ApexPages.currentPage();
		Map<String, String> params = resultPage.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.agreement.Id);
		resultPage.setRedirect(true);
		return resultPage;
	}

	public static Boolean validate(Service_Assignment_Provider_JO__c agreement, Risk[] risks, ServiceCode[] serviceCodes, Boolean isMidValley, Boolean isMetro) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (agreement.Tmn_Provider__c == null) {
			agreement.Tmn_Provider__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Start_Date__c == null) {
			agreement.Start_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.End_Date__c == null) {
			agreement.End_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Start_Date__c != null && agreement.End_Date__c != null) {
			if (agreement.Start_Date__c >= agreement.End_Date__c) {
				agreement.End_Date__c.addError('Service Agreement Expiration Date must be later than Service Agreement Effective Date.');
				noError = false;
			} else if (agreement.End_Date__c > agreement.Start_Date__c.addMonths(13)) {
				agreement.End_Date__c.addError('Service Agreement Expiration Date cannot be more than 13 months later than Service Agreement Effective Date');
				noError = false;
			} else if (agreement.Tmn_Provider__c != null) {
				Tmn_Provider_Application__c[] relevantApplications = [
					SELECT Id
					  FROM TMN_Provider_Application__c
					 WHERE Status__c = 'Approved'
					   AND Disqualified__c = false
					   AND Provider__c = :agreement.Tmn_Provider__c
					   AND Effective_Date__c <= :agreement.Start_Date__c
					   AND Expiration_Date__c >= :agreement.Start_Date__c
					 LIMIT 1
				];
				if (relevantApplications.size() == 0) {
					agreement.Start_Date__c.addError('Service Agreement Effective Date must fall within the Approval Date range of an Approved Provider Application.');
					noError = false;
				}
			}
		}
		if (agreement.Description_of_Medicaid_Tasks_Authorized__c == null || agreement.Description_of_Medicaid_Tasks_Authorized__c == '') {
			agreement.Description_of_Medicaid_Tasks_Authorized__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Credentialed_through_OHCC_as__c != null && agreement.Credentialed_through_OHCC_as__c.contains('Enhanced PSW') && agreement.Enhanced_Credential_Start_Date__c == null) {
			agreement.Enhanced_Credential_Start_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Credentialed_through_OHCC_as__c != null && agreement.Credentialed_through_OHCC_as__c.contains('Enhanced PSW') && agreement.Enhanced_Credential_End_Date__c == null) {
			agreement.Enhanced_Credential_End_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Credentialed_through_OHCC_as__c != null && agreement.Credentialed_through_OHCC_as__c.contains('Exceptional PSW') && agreement.Exceptional_Credential_Start_Date__c == null) {
			agreement.Exceptional_Credential_Start_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Credentialed_through_OHCC_as__c != null && agreement.Credentialed_through_OHCC_as__c.contains('Exceptional PSW') && agreement.Exceptional_Credential_End_Date__c == null) {
			agreement.Exceptional_Credential_End_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}

		for (ServiceCode serviceCode: serviceCodes) {
			if (serviceCode.units == null) {
				ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.ERROR,
					String.format(
						'# Units for {0} cannot be blank',
						new String[]{
							serviceCode.ispPlan.ISP_Service_Element_Service_Code__c
						}
					))
				);
				noError = false;
			} else if (serviceCode.units > serviceCode.ispPlan.ISP_Units__c) {
				ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.ERROR,
					String.format(
						'# Units for {0} cannot be greater than {1}',
						new String[]{
							serviceCode.ispPlan.ISP_Service_Element_Service_Code__c,
							String.valueOf(serviceCode.ispPlan.ISP_Units__c)
						}
					))
				);
				noError = false;
			}
			if (serviceCode.rate == null || serviceCode.rate == '') {
				ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.ERROR,
					String.format(
						'Rate for {0} cannot be blank',
						new String[]{
							serviceCode.ispPlan.ISP_Service_Element_Service_Code__c
						}
					))
				);
				noError = false;
			}
		}
		if (isMidValley && agreement.Health_and_Safety_Protocols_Received__c != null &&
				agreement.Health_and_Safety_Protocols_Received__c.contains('Other') &&
				(agreement.Other_Health_Safety_Protocols_Received__c == null ||
				agreement.Other_Health_Safety_Protocols_Received__c == '')) {
			agreement.Other_Health_Safety_Protocols_Received__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (agreement.Status__c == 'Terminated') {
			if (agreement.Termination_Date__c == null) {
				agreement.Termination_Date__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (agreement.Termination_Reason__c == null || agreement.Termination_Reason__c == '') {
				agreement.Termination_Reason__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
		}
		if (isFinalized(agreement)) {
			// Finalization validation
			if (agreement.Agreement_Type__c == null || agreement.Agreement_Type__c == '') {
				agreement.Agreement_Type__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			} else if (agreement.Agreement_Type__c == 'Personal Support Worker (PSW)') {
				if (agreement.Common_Law_Employer__c == null) {
					agreement.Common_Law_Employer__c.addError(errorGenerator.generate(fieldRequiredError));
					noError = false;
				}
			}
			if (risks.size() == 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Identified Risks cannot be empty'));
				noError = false;
			}
			if (serviceCodes.size() == 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Service and Proc Codes cannot be empty'));
				noError = false;
			}
			if (agreement.Authorization_Number__c == null || agreement.Authorization_Number__c == '') {
				agreement.Authorization_Number__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (agreement.Emergency_Contact_and_Phone__c == null) {
				agreement.Emergency_Contact_and_Phone__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (isMetro && agreement.Units_Shared_With_Multiple_Providers__c == null) {
				agreement.Units_Shared_With_Multiple_Providers__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
		}
		return noError;
	}

	public static Boolean isFinalized(Service_Assignment_Provider_JO__c agreement) {
		return agreement.Status__c == 'Pending' || agreement.Status__c == 'Active' || agreement.Status__c == 'Expired';
	}

	public class ServiceCode {
		public Boolean checked { get; set; }
		public Decimal units { get; set; }
		public Evaluation_Response__c ispPlan { get; set; }
		public Id serviceCodeId { get; set; }
		public String rate { get; set; }
		public String listNeedsToBeAddressed { get; set; }
	}
}