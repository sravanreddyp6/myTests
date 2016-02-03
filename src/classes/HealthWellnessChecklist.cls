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

	public HealthWellnessChecklist(ApexPages.StandardController stdController) {
		this.controller = stdController;
		if(!test.isRunningTest()){
			controller.addFields(new List<String>{
				'Admission__c',
				'Admission__r.Person_Being_Served__c'
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
			this.checklist.Admission__r = [
				SELECT Id, Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName
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