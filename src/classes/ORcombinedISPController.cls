public with sharing class ORcombinedISPController{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	public enum PageMode {VIEW, EDIT}
	public PageMode mode { get; set; }
	
	//multi-select checkboxes
	public List<string> selectedintEmployment {get; set;} //CDP_WA_Check_Apply_int_Employment__c
	public List<string> selectednonWorking {get; set;} //CDP_WA_Check_Apply_nonworking__c
	public List<string> selectednotToExplore {get; set;} //CDP_NE_Check_Apply_Decision_Not_Explore__c
	 
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
	

	public Boolean canFinalize {
		get {
			return isViewMode && !this.isp.Status__c.Contains('Final');
		}
	}
	
	public Boolean canRevise {
		get {
			return isViewMode && this.isp.Status__c == 'Active Final';
		}
	}
	
	//Constructor
	public ORcombinedISPController(Apexpages.StandardController controller){
		this.controller = controller;
		if(!test.isRunningTest()){
			controller.addFields(new List<string>{
				'Service_Assignment__c',
				'Service_Assignment__r.Admission__c',
				'Service_Assignment__r.Admission__r.Person_being_Served__c',
				'Service_Assignment__r.Admission__r.Person_being_Served__r.FirstName',
				'Service_Assignment__r.Admission__r.Person_being_Served__r.LastName',
				'Status__c',
				'CDP_WA_Check_Apply_int_Employment__c',
				'CDP_WA_Check_Apply_nonworking__c',
				'CDP_NE_Check_Apply_Decision_Not_Explore__c'
			});
		}
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (!params.containsKey('mode')) {
			this.mode = PageMode.VIEW;
		}else {
			this.mode = getModeEnum(params.get('mode'));
		}
		
		
		
		//Multi-selects
		selectedintEmployment = new List<string>();
		if(!String.isBlank(this.isp.CDP_WA_Check_Apply_int_Employment__c)){
			selectedintEmployment = this.isp.CDP_WA_Check_Apply_int_Employment__c.split(';');
		}
		
		selectednonWorking = new List<string>();
		if(!String.isBlank(this.isp.CDP_WA_Check_Apply_nonworking__c)){
			selectednonWorking = this.isp.CDP_WA_Check_Apply_nonworking__c.split(';');
		}
		
		
		selectednotToExplore = new List<string>();
		if(!String.isBlank(this.isp.CDP_NE_Check_Apply_Decision_Not_Explore__c)){
			selectednotToExplore = this.isp.CDP_NE_Check_Apply_Decision_Not_Explore__c.split(';');
		}
		
		
		
		
		
		
		

		
	}
	
	//End Constructor
	
	
	
	
	
	
	public PageReference save() {
		processMultiSelects();
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
	
	public PageReference finalize() {
		this.isp.Status__c = 'Active Final';
		update this.isp;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', this.isp.Id);
		page.setRedirect(true);
		return page;
	}
	
	public void processMultiSelects(){
		//CDP_WA_Check_Apply_int_Employment__c
		string sie = '';
		for(string cp: selectedintEmployment){
			sie += cp+';';
		}
		
		if(sie != ''){
			sie = sie.Substring(0,sie.length()-1);
			this.isp.CDP_WA_Check_Apply_int_Employment__c = sie;
		}else{
			this.isp.CDP_WA_Check_Apply_int_Employment__c = '';
		}
		
		//CDP_WA_Check_Apply_nonworking__c
		string apn = '';
		for(string cp: selectednonWorking){
			apn += cp+';';
		}
		
		if(apn != ''){
			apn = apn.Substring(0,apn.length()-1);
			this.isp.CDP_WA_Check_Apply_nonworking__c = apn;
		}else{
			this.isp.CDP_WA_Check_Apply_nonworking__c = '';
		}
		
		
		//CDP_NE_Check_Apply_Decision_Not_Explore__c
		string dne = '';
		for(string cp: selectednotToExplore){
			dne += cp+';';
		}
		
		if(dne != ''){
			dne = dne.Substring(0,dne.length()-1);
			this.isp.CDP_NE_Check_Apply_Decision_Not_Explore__c = dne;
		}else{
			this.isp.CDP_NE_Check_Apply_Decision_Not_Explore__c = '';
		}
		
		
		
	}
	
	
		
		
	
	
}