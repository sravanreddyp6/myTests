public with sharing class ORcombinedISPController{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	public enum PageMode {VIEW, EDIT}
	public PageMode mode { get; set; }
	
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
			return isViewMode && this.isp.Status__c == 'Inactive Draft';
		}
	}
	
	
	public ORcombinedISPController(Apexpages.StandardController controller){
		this.controller = controller;
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		
		Map<String, String> params = ApexPages.currentPage().getParameters();
		
		if (!params.containsKey('mode')) {
			this.mode = PageMode.VIEW;
		} else {
			this.mode = getModeEnum(params.get('mode'));
		}
	}
	
	
	
	
	
	
	
	
	public PageReference save() {
		upsert this.isp;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', this.isp.Id);
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