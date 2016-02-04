public with sharing class HealthWellnessChecklist {
	public Health_Wellness_Checklist__c checklist { get; set; }
	public PageMode mode { get; set; }

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
			return isViewMode && this.checklist.Status_of_Physical__c == 'Post Annual Physical' && this.checklist.Status__c != 'Active Final';
		}
	}

	public Boolean canRevise {
		get {
			return isViewMode && this.checklist.Status__c == 'Active Final';
		}
	}

	public Boolean isPostAnnualPhysical {
		get {
			return this.checklist.Status_of_Physical__c == 'Post Annual Physical';
		}
	}

	public String ageAtPhysicalStr { get; set; }
	public Boolean under18 { get; set; }

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

	public HealthWellnessChecklist(ApexPages.StandardController stdController) {
		this.controller = stdController;

		if(!test.isRunningTest()){
			controller.addFields(new List<String>{
				'Previous_Checklist__c',
				'Admission__c',
				'Admission__r.Person_Being_Served__c',
				'Admission__r.Person_Being_Served__r.Birthdate',
				'Admission__r.Person_Being_Served__r.FirstName',
				'Admission__r.Person_Being_Served__r.LastName',
				'Status__c'
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
			this.mode = PageMode.EDIT;
		}

		recalculateAge();
	}

	public void recalculateAge() {
		if (this.checklist.Date_of_Physical__c == null) {
			this.ageAtPhysicalStr = '';
			this.under18 = false;
			return;
		}
		Date birthday = this.checklist.Admission__r.Person_Being_Served__r.Birthdate;
		Integer[] dateDiff = Utility.calculateDateDifference(this.checklist.Date_of_Physical__c, birthday);
		this.ageAtPhysicalStr = Utility.getAge(String.valueOf(dateDiff[0]), String.valueOf(dateDiff[1]), String.valueOf(dateDiff[2]));
		this.under18 = dateDiff[0] < 18;
	}

	private static String getName(Health_Wellness_Checklist__c checklist) {
		return String.format('Annual Checklist - {0}. {1}',
			new String[] {
				checklist.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1),
				checklist.Admission__r.Person_Being_Served__r.LastName
			});
	}

	public PageReference save() {
		if (!validateFields(this.checklist, isPostAnnualPhysical)) {
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
	public static Boolean validateFields(Health_Wellness_Checklist__c checklist, Boolean isPostAnnualPhysical) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';

		if (checklist.Taking_Prescription_Medications__c == 'Yes' && checklist.Taking_Psychotropic_Medications__c == null) {
			checklist.Taking_Psychotropic_Medications__c.addError(fieldRequiredError);
			noError = false;
		}
		if (checklist.Taking_Psychotropic_Medications__c == 'Yes' && checklist.How_Many_Psychotropic_Medications__c == null) {
			checklist.How_Many_Psychotropic_Medications__c.addError(fieldRequiredError);
			noError = false;
		}
		if (checklist.Taking_Psychotropic_Medications__c == 'Yes' && checklist.Psychotropic_Medications_Prescribed_By__c == null) {
			checklist.Psychotropic_Medications_Prescribed_By__c.addError(fieldRequiredError);
			noError = false;
		}

		if (isPostAnnualPhysical) {
			if (checklist.Health_Care_Provider_Name__c == null) {
				checklist.Health_Care_Provider_Name__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.PBS_Accompanied_to_Physical_By__c == null) {
				checklist.PBS_Accompanied_to_Physical_By__c.addError(fieldRequiredError);
				noError = false;
			}

			if (checklist.Asthma__c && checklist.Asthma_Management_Discussed__c == null) {
				checklist.Asthma_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Arthritis__c && checklist.Arthritis_Management_Discussed__c == null) {
				checklist.Arthritis_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Chronic_Obstructive_Pulmonary_Disease__c && checklist.COPD_Management_Discussed__c == null) {
				checklist.COPD_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Diabetes__c && checklist.Diabetes_Management_Discussed__c == null) {
				checklist.Diabetes_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Heart_Disease__c && checklist.Heart_Disease_Management_Discussed__c == null) {
				checklist.Heart_Disease_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Mental_Health_Condition__c && checklist.Mental_Health_Condition_Discussed__c == null) {
				checklist.Mental_Health_Condition_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Seizure_Disorder__c && checklist.Seizure_Disorder_Management_Discussed__c == null) {
				checklist.Seizure_Disorder_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Other_Condition_1__c && checklist.Other_Condition_1_Management_Discussed__c == null) {
				checklist.Other_Condition_1_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Other_Condition_2__c && checklist.Other_Condition_2_Management_Discussed__c == null) {
				checklist.Other_Condition_2_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Other_Condition_3__c && checklist.Other_Condition_3_Management_Discussed__c == null) {
				checklist.Other_Condition_3_Management_Discussed__c.addError(fieldRequiredError);
				noError = false;
			}

			if (checklist.Taking_Prescription_Medications__c == 'Yes' && checklist.Medication_List_Reviewed__c == null) {
				checklist.Medication_List_Reviewed__c.addError(fieldRequiredError);
				noError = false;
			}
			if (checklist.Date_of_Last_Dental_Visit__c == null) {
				checklist.Date_of_Last_Dental_Visit__c.addError(fieldRequiredError);
				noError = false;
			}
		}

		return noError;
	}

	public PageReference finalize() {
		this.checklist.Status__c = 'Active Final';
		if (this.checklist.Previous_Checklist__c != null) {
			update new Health_Wellness_Checklist__c(
				Id = this.checklist.Previous_Checklist__c,
				Status__c = 'Inactive Final'
			);
		}
		return this.save();
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

}