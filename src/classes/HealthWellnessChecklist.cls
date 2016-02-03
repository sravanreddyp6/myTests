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

	public HealthWellnessChecklist(ApexPages.StandardController stdController) {
		this.controller = stdController;
		if(!test.isRunningTest()){
			controller.addFields(new List<String>{
				'Admission__c',
				'Admission__r.Person_Being_Served__c',
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

		if (this.mode == PageMode.VIEW) {

		}

		if (params.containsKey('admissionId')) {  // this means it's a new one
			this.checklist.Admission__c = params.get('admissionId');
			this.checklist.Admission__r = [
				SELECT Id, Person_Being_Served__c, Person_Being_Served__r.FirstName,
				       Person_Being_Served__r.LastName
				  FROM Admission__c
				 WHERE Id = :this.checklist.Admission__c
			][0];
			this.checklist.RecordTypeId = recordTypeMap.get('Standard').getRecordTypeId();
			this.checklist.Name = String.format('Annual Checklist - {0}. {1}',
				new String[] {
					this.checklist.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1),
					this.checklist.Admission__r.Person_Being_Served__r.LastName
				});
			this.mode = PageMode.EDIT;
		}
	}

	public PageReference save() {
		upsert this.checklist;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', this.checklist.Id);
		page.setRedirect(true);
		return page;
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