public with sharing class HealthWellnessChecklist {
	public Health_Wellness_Checklist__c checklist { get; set; }
	public PageMode mode { get; set; }
	public List<SelectOption> yesno { get; set; }
	public boolean attachPDF { get; set; }
	
	public static boolean hasBPError { get; private set; }
	public static boolean hasWeightError { get; private set; }
	public static boolean hasHeightError { get; private set; }
	public static boolean hasVaccineError { get; private set; }
	
	private ApexPages.StandardController controller;

	public enum PageMode {VIEW, EDIT}

	public Boolean isViewMode {
		get {
			return this.mode == PageMode.VIEW;
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == PageMode.EDIT;
		}
	}

	public Boolean canEdit {
		get {
			return isViewMode && this.checklist.Status__c == 'Inactive Draft';
		}
	}

	public Boolean canFinalize {
		get {
			return isViewMode && this.checklist.Status_of_Physical__c == 'Post Annual Physical' && !this.checklist.Status__c.Contains('Final');
		}
	}

	public Boolean canRevise {
		get {
			return isViewMode && this.checklist.Status__c == 'Active Final';
		}
	}

	public Boolean firstTimeEdit {
		get {
			// For the Immunization modals, we want it to not show up when the checklist is first edited,
			// since the required fields on the page haven't been populated, which will lead to
			// pageMessages error on the modal.
			return this.checklist.CreatedDate == this.checklist.LastModifiedDate;
		}
	}

	public Boolean isPostAnnualPhysical {
		get {
			return this.checklist.Status_of_Physical__c == 'Post Annual Physical';
		}
	}

	public boolean rxPrimary {
		get {
			if (checklist.Psychotropic_Medications_Prescribed_By__c == null) {
				return false;
			}
			return checklist.Psychotropic_Medications_Prescribed_By__c.contains('Primary Care');
		}
		set;
	}
	public boolean rxPsych {
		get {
			if (checklist.Psychotropic_Medications_Prescribed_By__c == null) {
				return false;
			}
			return checklist.Psychotropic_Medications_Prescribed_By__c.contains('Psychiatrist');
		}
		set;
	}
	public boolean rxOther {
		get {
			if (checklist.Psychotropic_Medications_Prescribed_By__c == null) {
				return false;
			}
			return checklist.Psychotropic_Medications_Prescribed_By__c.contains('Other');
		}
		set;
	}

	public String ageAtPhysicalStr { get; set; }
	public Integer under18 { get; set; }	// using -1, 0, 1 as tri-state boolean, -1 representing null value

	public SelectOption[] healthCareProviders {
		get {
			if (healthCareProviders != null) {
				return healthCareProviders;
			}
			healthCareProviders = new List<SelectOption>();
			healthCareProviders.add(new SelectOption('', '--None--'));
			for (Related_Party__c rp: [
						SELECT Id, Name
						  FROM Related_Party__c
						 WHERE Person_Being_Served__c = :this.checklist.Admission__r.Person_Being_Served__c
						   AND Status__c = 'Active'
						   AND Type__c IN ('Medical', 'Physician - Primary', 'Physician - Alternate')
					]) {
				healthCareProviders.add(new SelectOption(rp.Name, rp.Name));
			}
			return healthCareProviders;
		}
		set;
	}

	// constructor for when controller is used as custom controller not extension.  do not remove this it's needed so the attach PDF can work!
	public HealthWellnessChecklist() {

		Map<String, String> params = ApexPages.currentPage().getParameters();

		ID checklistID = (ID) params.get('id');
		this.checklist = [
			SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, LastActivityDate, Admission__c, Status__c,
			       Arthritis_Management_Discussed__c, Arthritis__c, Asthma_Management_Discussed__c,
			       Asthma__c, COPD_Management_Discussed__c, Chronic_Obstructive_Pulmonary_Disease__c,
			       Date_of_Last_Dental_Visit__c, Date_of_Physical__c, Dental_Visit_Within_Last_Year__c,
			       Diabetes_Management_Discussed__c, Diabetes__c, Health_Care_Provider_Name__c,
			       Heart_Disease_Management_Discussed__c, Heart_Disease__c,
			       How_Many_Psychotropic_Medications__c, Medication_List_Reviewed__c,
			       Medications_Prescribed_By_Other__c, Mental_Health_Condition_Discussed__c,
			       Mental_Health_Condition__c, Other_Condition_1_Management_Discussed__c,
			       Other_Condition_1_Specify__c, Other_Condition_1__c,
			       Other_Condition_2_Management_Discussed__c, Other_Condition_2_Specify__c,
			       Other_Condition_2__c, Other_Condition_3_Management_Discussed__c,
			       Other_Condition_3_Specify__c, Other_Condition_3__c, PBS_Accompanied_to_Physical_By__c,
			       Preventive_Health_Screenings_Discussed__c, Previous_Checklist__c,
			       Psychotropic_Medications_Prescribed_By__c, Seizure_Disorder_Management_Discussed__c,
			       Seizure_Disorder__c, Status_of_Physical__c, Taking_Prescription_Medications__c,
			       Taking_Psychotropic_Medications__c, Was_developmental_screening_conducted__c,
			       Blood_Pressure_Diastolic__c, Blood_Pressure_Not_Collected__c,
			       Blood_Pressure_Systolic__c, Height_Cm__c, Height_Ft__c, Height_Inch__c,
			       Height_Not_Collected__c, PBS_Accompanied_By_Mentor__c, PBS_Accompanied_By_Other_Role__c,
			       PBS_Accompanied_By_Other__c, PBS_Accompanied_By_Staff__c, Weight_Kg__c, Weight_Lb__c,
			       Weight_Not_Collected__c, Weight_Oz__c,
			       admission__r.person_being_served__c, admission__r.person_Being_served__r.birthdate,
			       admission__r.person_being_Served__r.firstname,
			       admission__r.person_being_served__r.middle_name__c,
			       admission__r.person_being_served__r.lastname,
			       admission__r.person_being_served__r.name,
			       admission__r.person_being_served__r.gender__c
			  FROM Health_Wellness_Checklist__c
			 WHERE id=:checklistId LIMIT 1
			];

		this.mode = PageMode.VIEW;

		recalculateAge();

		yesno = new List<SelectOption> {
			new SelectOption('Yes','Yes'),
			new SelectOption('No','No')
		};
	}



	public HealthWellnessChecklist(ApexPages.StandardController stdController) {
		this.controller = stdController;

		if(!test.isRunningTest()){
			controller.addFields(new List<String>{
				'CreatedDate',
				'LastModifiedDate',
				'Previous_Checklist__c',
				'Name',
				'Admission__c',
				'Admission__r.Person_Being_Served__c',
				'Admission__r.Person_Being_Served__r.Birthdate',
				'Admission__r.Person_Being_Served__r.FirstName',
				'Admission__r.Person_Being_Served__r.Middle_Name__c',
				'Admission__r.Person_Being_Served__r.LastName',
				'Status__c',
				'Admission__r.Person_Being_Served__r.Name',
				'Admission__r.Person_Being_Served__r.Gender__c',
				'Height_not_collected__c',
				'Weight_not_Collected__c'
			});
		}
		this.checklist = (Health_Wellness_Checklist__c) this.controller.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();
		Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Health_Wellness_Checklist__c.getRecordTypeInfosByName();

		if (!params.containsKey('mode')) {
			this.mode = PageMode.VIEW;
		} else {
			this.mode = getModeEnum(params.get('mode'));
		}

		if (params.containsKey('admissionId')) {  // this means it's a new one
			this.checklist.Admission__c = params.get('admissionId');
			this.checklist.Admission__r = [
				SELECT Id, Person_Being_Served__c, Person_Being_Served__r.FirstName,
				       Person_Being_Served__r.LastName, Person_Being_Served__r.Birthdate
				  FROM Admission__c
				 WHERE Id = :this.checklist.Admission__c
			][0];
			this.checklist.RecordTypeId = recordTypeMap.get('Standard').getRecordTypeId();
			this.checklist.Name = getName(this.checklist);
			this.checklist.Status__c = 'Inactive Draft';
			this.checklist.Status_of_Physical__c = 'Preparation for Annual Physical';
			this.mode = PageMode.EDIT;
		}

		recalculateAge();

		yesno = new List<SelectOption> {
			new SelectOption('Yes','Yes'),
			new SelectOption('No','No')
		};
		
		hasBPError = false;
		hasHeightError = false;
		hasWeightError = false;
	}

	public void recalculateAge() {
		if (this.checklist.Date_of_Physical__c == null) {
			this.ageAtPhysicalStr = '';
			this.under18 = -1;
			return;
		}
		Date birthday = this.checklist.Admission__r.Person_Being_Served__r.Birthdate;
		Integer[] dateDiff = Utility.calculateDateDifference(this.checklist.Date_of_Physical__c, birthday);
		this.ageAtPhysicalStr = Utility.getAge(String.valueOf(dateDiff[0]), String.valueOf(dateDiff[1]), String.valueOf(dateDiff[2]));
		this.under18 = (dateDiff[0] < 18) ? 1 : 0 ;
	}

	private static String getName(Health_Wellness_Checklist__c checklist) {
		return String.format('Annual Checklist - {0}. {1}',
			new String[] {
				checklist.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1),
				checklist.Admission__r.Person_Being_Served__r.LastName
			});
	}

	public PageReference save() {
		if (!validateFields(this.checklist, isPostAnnualPhysical, under18)) {
			return null;
		}
		upsert this.checklist;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', this.checklist.Id);
		page.setRedirect(true);
		return page;
	}

	/**
	 * Return false if error found, true if otherwise
	 */
	public static Boolean validateFields(Health_Wellness_Checklist__c checklist, Boolean isPostAnnualPhysical, Integer under18) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		String postAnnualFieldRequiredError = 'Field is required for Post Annual Physical';
		String finalizeRequiredError = 'Field is required to finalize';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (checklist.Date_of_Physical__c == null) {
			checklist.Date_of_Physical__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Taking_Prescription_Medications__c == null) {
			checklist.Taking_Prescription_Medications__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Dental_Visit_Within_Last_Year__c == null) {
			checklist.Dental_Visit_Within_Last_Year__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Taking_Prescription_Medications__c == 'Yes' && checklist.Taking_Psychotropic_Medications__c == null) {
			checklist.Taking_Psychotropic_Medications__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Taking_Psychotropic_Medications__c == 'Yes' && checklist.How_Many_Psychotropic_Medications__c == null) {
			checklist.How_Many_Psychotropic_Medications__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Taking_Psychotropic_Medications__c == 'Yes' && checklist.Psychotropic_Medications_Prescribed_By__c == null) {
			checklist.Psychotropic_Medications_Prescribed_By__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Psychotropic_Medications_Prescribed_By__c != null && checklist.Psychotropic_Medications_Prescribed_By__c.indexOf('Other') != -1 && checklist.Medications_Prescribed_By_Other__c == null) {
			checklist.Medications_Prescribed_By_Other__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Other_Condition_1__c && checklist.Other_Condition_1_Specify__c == null) {
			checklist.Other_Condition_1_Specify__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Other_Condition_2__c && checklist.Other_Condition_2_Specify__c == null) {
			checklist.Other_Condition_2_Specify__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (checklist.Other_Condition_3__c && checklist.Other_Condition_3_Specify__c == null) {
			checklist.Other_Condition_3_Specify__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}

		if (isPostAnnualPhysical) {
			if (checklist.Health_Care_Provider_Name__c == null && checklist.Status__c == 'Active Final') {
				checklist.Health_Care_Provider_Name__c.addError(errorGenerator.generate(finalizeRequiredError));
				noError = false;
			}
			if (checklist.PBS_Accompanied_to_Physical_By__c == null) {
				checklist.PBS_Accompanied_to_Physical_By__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			} else if (checklist.PBS_Accompanied_to_Physical_By__c == 'Staff' && checklist.PBS_Accompanied_By_Staff__c == null) {
				checklist.PBS_Accompanied_By_Staff__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			} else if (checklist.PBS_Accompanied_to_Physical_By__c == 'Mentor' && checklist.PBS_Accompanied_By_Mentor__c == null) {
				checklist.PBS_Accompanied_By_Mentor__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			} else if (checklist.PBS_Accompanied_to_Physical_By__c == 'Other') {
				if (checklist.PBS_Accompanied_By_Other__c == null) {
					checklist.PBS_Accompanied_By_Other__c.addError(errorGenerator.generate(fieldRequiredError));
					noError = false;
				}
				if (checklist.PBS_Accompanied_By_Other_Role__c == null) {
					checklist.PBS_Accompanied_By_Other_Role__c.addError(errorGenerator.generate(fieldRequiredError));
					noError = false;
				}
			}
			
			// check vaccinations - requires a date of physical to have been entered
			if (checklist.Date_of_Physical__c != null) {
				Date fluDate = checklist.Date_of_physical__c.AddYears(-1);
				Date tetanusDate = checklist.Date_of_physical__c.AddYears(-10);			
	
				// At least 1 non-Disregarded entry with Vaccine Type = Influenza AND Influenza Vaccine Date < 1 year of Date of Physical required to Finalize
				List<Evaluation_Response__c> vaccines = [ select id, vaccination_status__c, vaccine_type__c, date__c from evaluation_response__c where disregard__c = false and vaccine_type__c = 'Influenza' and date_unknown__c != true and date__c > :fluDate and person_being_served__c = :checklist.admission__r.person_being_served__c ];
				if ( vaccines.size() < 1 && checklist.status__c == 'Active Final') {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Influenza Vaccine within a year of physical date is required to finalize' ));
					hasVaccineError = true;
					noError = false;
				}
				
				// At least 1 non-Disregarded entry with Vaccine Type = Diphtheria/Tetanus/Pertussis AND Diphtheria/Tetanus/Pertussis Vaccine Date < 10 years of Date of Physical required to Finalize
				vaccines = 	[ select id, vaccination_status__c, vaccine_type__c, date__c from evaluation_response__c where disregard__c = false and vaccine_type__c = 'Diphtheria/Tetanus/Pertussis' and date_unknown__c != true and date__c > :tetanusDate and person_being_served__c = :checklist.admission__r.person_being_served__c  ];
				if ( vaccines.size() < 1 && checklist.status__c == 'Active Final') {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Diphtheria/Tetanus/Pertussis Vaccine within 10 years of physical date is required to finalize' ));
					hasVaccineError = true;
					noError = false;
				}
			}			
			
			if (!checklist.Height_Not_Collected__c && (checklist.Height_Cm__c == null || checklist.Height_Cm__c == 0 )) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Height: ' + postAnnualFieldRequiredError ));
				hasHeightError = true;
				noError = false;
			}
			if (!checklist.Weight_Not_Collected__c && (checklist.Weight_Kg__c == null || checklist.Weight_Kg__c == 0 )) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Weight: ' + postAnnualFieldRequiredError ));
				hasWeightError = true;
				noError = false;
			}
			if (!checklist.Blood_Pressure_Not_Collected__c && (checklist.Blood_Pressure_Systolic__c == null)) {
				//checklist.Blood_Pressure_Systolic__c.addError(errorGenerator.generate(fieldRequiredError));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Blood Pressure: ' + postAnnualFieldRequiredError));
				hasBPError = true;
				noError = false;
			}
			if (!checklist.Blood_Pressure_Not_Collected__c && (checklist.Blood_Pressure_Diastolic__c == null) && !hasBPError ) {
				//checklist.Blood_Pressure_Diastolic__c.addError(errorGenerator.generate(fieldRequiredError));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Blood Pressure: ' + postAnnualFieldRequiredError));
				hasBPError = true;
				noError = false;
			}

			if (checklist.Asthma__c && checklist.Asthma_Management_Discussed__c == null) {
				checklist.Asthma_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Arthritis__c && checklist.Arthritis_Management_Discussed__c == null) {
				checklist.Arthritis_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Chronic_Obstructive_Pulmonary_Disease__c && checklist.COPD_Management_Discussed__c == null) {
				checklist.COPD_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Diabetes__c && checklist.Diabetes_Management_Discussed__c == null) {
				checklist.Diabetes_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Heart_Disease__c && checklist.Heart_Disease_Management_Discussed__c == null) {
				checklist.Heart_Disease_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Mental_Health_Condition__c && checklist.Mental_Health_Condition_Discussed__c == null) {
				checklist.Mental_Health_Condition_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Seizure_Disorder__c && checklist.Seizure_Disorder_Management_Discussed__c == null) {
				checklist.Seizure_Disorder_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Other_Condition_1__c && checklist.Other_Condition_1_Management_Discussed__c == null) {
				checklist.Other_Condition_1_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Other_Condition_2__c && checklist.Other_Condition_2_Management_Discussed__c == null) {
				checklist.Other_Condition_2_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Other_Condition_3__c && checklist.Other_Condition_3_Management_Discussed__c == null) {
				checklist.Other_Condition_3_Management_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}

			if (checklist.Taking_Prescription_Medications__c == 'Yes' && checklist.Medication_List_Reviewed__c == null) {
				checklist.Medication_List_Reviewed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if (checklist.Date_of_Last_Dental_Visit__c == null) {
				checklist.Date_of_Last_Dental_Visit__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if ( (under18 == 1) && checklist.Was_Developmental_Screening_Conducted__c == null) {
				checklist.Was_Developmental_Screening_Conducted__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
			if ( (under18 == 0) && checklist.Preventive_Health_Screenings_Discussed__c == null) {
				checklist.Preventive_Health_Screenings_Discussed__c.addError(errorGenerator.generate(postAnnualFieldRequiredError));
				noError = false;
			}
		}

		return noError;
	}

	public PageReference finalize() {
		String previousStatus = this.checklist.Status__c;
		this.checklist.Status__c = 'Active Final';
		// TODO handle immunization finalization here
		PageReference pageRef = this.save();
		if (pageRef == null) {
			this.checklist.Status__c = previousStatus;
			return null;
		}
		if (this.checklist.Previous_Checklist__c != null) {
			update new Health_Wellness_Checklist__c(
				Id = this.checklist.Previous_Checklist__c,
				Status__c = 'Inactive Final'
			);
		}
		return pageRef;
	}

	public PageReference cancel() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		PageReference pageToRedirect;
		if (params.containsKey('lastUrl')) {
			pageToRedirect = new PageReference(params.get('lastUrl'));
		} else if (this.checklist.Id != null) {
			pageToRedirect = ApexPages.currentPage();
			params.clear();
			params.put('mode', PageMode.VIEW.name());
			params.put('id', this.checklist.Id);
		} else {
			pageToRedirect = new PageReference('/' + this.checklist.Admission__c);
		}
		pageToRedirect.setRedirect(true);
		return pageToRedirect;
	}

	public PageReference revise() {
		Schema.FieldSetMember[] fields = SObjectType.Health_Wellness_Checklist__c.FieldSets.Revision_Carry_Over.getFields();
		string query = 'SELECT ';
		for (Schema.FieldSetMember f: fields) {
			query += f.getFieldPath() + ', ';
		}
		query += 'Id FROM Health_Wellness_Checklist__c WHERE Id=\'' + this.checklist.Id + '\'';
		Health_Wellness_Checklist__c currentChecklist = Database.query(query);

		Health_Wellness_Checklist__c revisedChecklist = new Health_Wellness_Checklist__c(
			Name = getName(this.checklist),
			Previous_Checklist__c = this.checklist.Id,
			Admission__c = this.checklist.Admission__c
		);
		for (Schema.FieldSetMember f: fields) {
			revisedChecklist.put(f.getFieldPath(), currentChecklist.get(f.getFieldPath()));
		}
		insert revisedChecklist;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', revisedChecklist.Id);
		page.setRedirect(true);
		return page;
	}

	private PageMode getModeEnum(String str) {
		PageMode modeEnum;
		for (PageMode mode: PageMode.values()) {
			if (mode.name() == str) {
				modeEnum = mode;
				break;
			}
		}
		return modeEnum;
	}


	public pageReference viewAttachPDF() {

		if (!attachPDF) {
			return null;
		}

		pageReference pdfPage = new PageReference('/apex/HealthWellnessPDF');
		pdfPage.getParameters().put('id', this.checklist.Id);
		pdfPage.getParameters().put('mode', 'VIEW');
		pdfPage.setRedirect(true);

		// get the content of the pdf and attach it to this checklist
		Attachment attachmentPDF = new Attachment();
		attachmentPDF.parentId = this.checklist.Admission__c;
		attachmentPDF.Name = 'HealthWellnessChecklist-' + Datetime.now().format('MM-dd-yyyy hh:mm:ss a z') + '.pdf';
		// attachemntPDF.contentType = '.pdf';
		if (Test.isrunningtest()==false) {
			attachmentPDF.body = pdfPage.getContent();
			system.debug('URL OF PAGE IS ' + pdfPage.getURL());
			system.debug('PARAMS OF PAGE ARE ' + pdfPage.getParameters());
		} else {
			Blob testBlob = Blob.valueOf('TEST 123');
			attachmentPDF.body = testBlob;
		}
		try {
			insert attachmentPDF;
			system.debug('attached PDF');
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			system.debug('did not attach PDF');
		}
		return null;
	}
}