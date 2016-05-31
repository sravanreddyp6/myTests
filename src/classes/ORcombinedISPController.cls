public with sharing class ORcombinedISPController{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	public enum PageMode {VIEW, EDIT}
	public PageMode mode { get; set; }
	
	//multi-select checkboxes
	public List<string> selectedintEmployment {get; set;} //CDP_WA_Check_Apply_int_Employment__c
	public List<string> selectednonWorking {get; set;} //CDP_WA_Check_Apply_nonworking__c
	public List<string> selectednotToExplore {get; set;} //CDP_NE_Check_Apply_Decision_Not_Explore__c
	
	
	//Legal Relationships
	public transient List<SelectOption> healthCareRepsHelper;
	
	public list<SelectOption> pullhealthCareReps(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));
		for(Related_Party__c r: [SELECT Name 
									FROM Related_Party__c 
									WHERE Person_Being_Served__c = :this.isp.service_Assignment__r.Admission__r.Person_being_Served__c
									AND Status__c = 'Active'
		]){							
			options.add(new SelectOption(r.Name,r.Name));
			
		}
			return options;
	}
	public List<SelectOption> healthCareReps {
		get{
			if(healthCareRepsHelper == null){
				healthCareRepsHelper = pullhealthCareReps();
			}
			
			return healthCareRepsHelper;
		}
		private set;
	}
	 
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
				'Service_Assignment__r.Admission__r.Person_being_Served__r.Prime_Number__c',
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
		
		
		
		
		//Legal Relationships
		healthCareReps = new list<SelectOption>();
		
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
	
	
	public void addorRefreshLegal(){
		Case_Management_Plan__c cm = pullRelatedParties(this.isp.Service_Assignment__r.Admission__r.Person_being_Served__c, this.isp.Id, isEditMode);
		System.debug('isEdit mode in actionfunction'+isEditMode);
		System.debug('View mode in actionfunction'+isViewMode);
		
		this.isp.Leg_Parents__c = cm.Leg_Parents__c;
		this.isp.Leg_Guardians__c = cm.Leg_Guardians__c;
		this.isp.Leg_Designated_Representative_Planning__c = cm.Leg_Designated_Representative_Planning__c;
		this.isp.Leg_Designated_Representative_Employer__c = cm.Leg_Designated_Representative_Employer__c;
		this.isp.Leg_Representative_Payee__c = cm.Leg_Representative_Payee__c;
		this.isp.Leg_Conservators__c  = cm.Leg_Conservators__c;
		cm = new Case_Management_Plan__c();//Clear view State
	}
	
	
	
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
	
	
	public static Case_Management_Plan__c pullRelatedParties(Id PBSId, Id currentRecordId, Boolean isEditMode){
		
		Case_Management_Plan__c isp = new Case_Management_Plan__c(id=currentRecordId);//[SELECT Leg_Parents__c, Leg_Guardians__c, Leg_Designated_Representative_Planning__c, Leg_Designated_Representative_Employer__c, 
										//Leg_Health_Care_Representative__c, Leg_Representative_Payee__c, Leg_Conservators__c FROM Case_Management_Plan__c WHERE ID=:currentRecordId LIMIT 1];
										
		List<Related_Party__c> parties = [SELECT Name, Type__c FROM Related_Party__c WHERE Person_Being_Served__c = :PBSId];
	
		isp.Leg_Parents__c = '';
		isp.Leg_Guardians__c = '';
		isp.Leg_Designated_Representative_Planning__c ='';
		isp.Leg_Designated_Representative_Employer__c ='';
		isp.Leg_Representative_Payee__c = '';
		isp.Leg_Conservators__c = '';
		
		for(Related_Party__c rp: parties){
			if(rp.Type__c == 'Parent'){
				isp.Leg_Parents__c += rp.Name+', ';
			}else if(rp.Type__c == 'Guardian'){
				isp.Leg_Guardians__c += rp.Name+', ';
			}else if(rp.Type__c == 'Designated Representative'){
				isp.Leg_Designated_Representative_Planning__c += rp.Name+', ';
			}else if(rp.Type__c == 'Common Law Employer'){
				isp.Leg_Designated_Representative_Employer__c += rp.Name+', ';
			}else if(rp.Type__c == 'Representative Payee'){
				isp.Leg_Representative_Payee__c += rp.Name+', ';
			}else if(rp.Type__c == 'Conservator'){
				isp.Leg_Conservators__c += rp.Name+', ';
			}
			
		}
	
		if(string.isnotBlank(isp.Leg_Parents__c) && isp.Leg_Parents__c.Endswith(', ')){
			isp.Leg_Parents__c = isp.Leg_Parents__c.Substring(0,isp.Leg_Parents__c.length()-2);
		}
		if(string.isnotBlank(isp.Leg_Guardians__c) && isp.Leg_Guardians__c.Endswith(', ')){
			isp.Leg_Guardians__c = isp.Leg_Guardians__c.Substring(0,isp.Leg_Guardians__c.length()-2);
		}
		if(string.isnotBlank(isp.Leg_Designated_Representative_Planning__c) && isp.Leg_Designated_Representative_Planning__c.endsWith(', ')){
			isp.Leg_Designated_Representative_Planning__c = isp.Leg_Designated_Representative_Planning__c.Substring(0,isp.Leg_Designated_Representative_Planning__c.length()-2);
		}
		if(string.isnotBlank(isp.Leg_Designated_Representative_Employer__c) && isp.Leg_Designated_Representative_Employer__c.endsWith(', ')){
			isp.Leg_Designated_Representative_Employer__c = isp.Leg_Designated_Representative_Employer__c.Substring(0,isp.Leg_Designated_Representative_Employer__c .length()-2);
		}
		if(string.isnotBlank(isp.Leg_Representative_Payee__c) && isp.Leg_Representative_Payee__c.endsWith(', ')){
			isp.Leg_Representative_Payee__c = isp.Leg_Representative_Payee__c.Substring(0,isp.Leg_Representative_Payee__c.length()-2);
		}
		if(string.isnotBlank(isp.Leg_Conservators__c) && isp.Leg_Conservators__c.endsWith(', ')){
			isp.Leg_Conservators__c = isp.Leg_Conservators__c.Substring(0,isp.Leg_Conservators__c.length()-2);
		}
		
		if(!isEditMode){
			update isp; //Update the record when user clicks refresh in view Mode. Edit mode is handled by Save Button.
		}
		
		return isp;
	
	}
	
	
		
		
	
	
}