public with sharing class ORcombinedISPController{
	
	Apexpages.StandardController 				controller;
	public Case_Management_Plan__c isp 			{get; set;}
	public enum PageMode 						{VIEW, EDIT}
	public PageMode mode 						{get; set;}
	
	//multi-select checkboxes
	public List<string> selectedintEmployment 	{get; set;} //CDP_WA_Check_Apply_int_Employment__c
	public List<string> selectednonWorking 		{get; set;} //CDP_WA_Check_Apply_nonworking__c
	public List<string> selectednotToExplore 	{get; set;} //CDP_NE_Check_Apply_Decision_Not_Explore__c
	public List<string> selectedKPRServices		{get; set;} //KPR_Included_Services__c
	public List<string> selectedKPRAdditional	{get; set;} //KPR_Additional_Services__c
	
	public string section {get; set;} //Variable to identify the section of the page to be displayed
	//public Map<string, string> errorMap			{get; set;}
	//Legal Relationships
	public transient List<SelectOption> healthCareRepsHelper;
	public transient List<SelectOption> contributorNamesHelper;
	
	//**********Stub To be removed after July'16 release - Sravan************************************************
	public boolean canFinalize {get; set;} 
	public boolean canRevise {get; set;} 
	public pageReference finalize(){
		
		return null;
	}
	public pagereference Revise(){
		
		return null;
	}
	 @RemoteAction
     public static Evaluation_Response__c saveContributor(String x, String y, String a, Boolean b, Boolean c, String d, String e, Boolean p){
     	
     	return new Evaluation_Response__c();
     }
	//********************************************************************************************************************
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
	
	public list<SelectOption> pullContributorNames(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','--None--'));
		for(Related_Party__c r: [SELECT Name, Type__c 
									FROM Related_Party__c 
									WHERE Person_Being_Served__c = :this.isp.service_Assignment__r.Admission__r.Person_being_Served__c
									AND Status__c = 'Active'
		]){							
			options.add(new SelectOption(r.Name+' & '+r.Type__c, r.Name+' & '+r.Type__c));
			
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
	
	public List<SelectOption> contributorNames {
		get{
			if(contributorNamesHelper == null){
				contributorNamesHelper = pullContributorNames();
			}
			
			return contributorNamesHelper;
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
			return isViewMode && this.isp.Status__c == 'Inactive Draft' && section != 'attachments';
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
				'CDP_NE_Check_Apply_Decision_Not_Explore__c',
				'KPR_Included_Services__c',
				'KPR_Additional_Services__c',
				'CreatedBy.Name',
				'LastModifiedDate',
				'ACK_isValid__c',
				'Agreement_isValid__c',
				'CDP_IsValid__c',
				'CCMS_isValid__c',
				'Desired_Outcomes_IsValid__c',
				'Differences_Isvalid__c',
				'Kplan_isValid__c',
				'KPR_isValid__c',
				'Leg_isValid__c',
				'NaturalSupports_isValid__c',
				'Profile_isValid__c',
				'PD_Isvalid__c',
				'Risk_Isvalid__c',
				'SPPC_IsValid__c',
				'Waiver_isValid__c',
				'ACK_Errors__c',
				'Agreement_Errors__c',
				'CDP_Errors__c',
				'CCMS_Errors__c',
				'Desired_outcomes_Errors__c',
				'Differences_Errors__c',
				'Kplan_Errors__c',
				'KPR_Errors__c',
				'Leg_Errors__c',
				'NaturalSupports_Errors__c',
				'Profile_Errors__c',
				'PD_Errors__c',
				'Risk_Errors__c',
				'SPPC_Errors__c',
				'Waiver_Errors__c'
			});
		}
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (!params.containsKey('mode')) {
			this.mode = PageMode.EDIT;//Default is edit mode
		}else {
			this.mode = getModeEnum(params.get('mode'));
		}
		
		if(params.containsKey('section')){
			this.section = params.get('section');
		}else{
			this.section = '';
		}
		
		this.relParties = new List<Related_Party__c>();
		populateRelParties();
		this.contributors = new List<Evaluation_Response__c>();
		populatecontributors();
		
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
		
		selectedKPRServices = new list<string>();
		if(!String.isBlank(this.isp.KPR_Included_Services__c)){
			selectedKPRServices = this.isp.KPR_Included_Services__c.split(';');
		}
		
		selectedKPRAdditional = new list<string>();
		if(!String.isBlank(this.isp.KPR_Additional_Services__c)){
			selectedKPRAdditional = this.isp.KPR_Additional_Services__c.split(';');
		}
		
		//errorMap = new map<string,string>();
		//handlePanels();
		
	}
	
	//End Constructor
	
	public pageReference save(){
		List<String> errors = new List<string>();
		if(section == 'planDates'){
			if(this.isp.PD_Start__c == null ){
				errors.add('Start Date is Mandatory');
			}else{
				string pbsLastName = this.isp.Service_Assignment__r.Admission__r.Person_Being_Served__r.LastName != null ? this.isp.Service_Assignment__r.Admission__r.Person_Being_Served__r.LastName : '' ;
        		string pbsFirstinitial  = this.isp.Service_Assignment__r.Admission__r.Person_Being_Served__r.FirstName != null ? this.isp.Service_Assignment__r.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1) : '';
				this.isp.Name = pbsFirstinitial+'.'+pbsLastName +' - '+'ISP'+' - '+this.isp.PD_Start__c.format();
			}
			
			if(this.isp.PD_End__c == null){
				errors.add('End Date is Mandatory');
			}
			
			if((this.isp.PD_Start__c != null && this.isp.PD_End__c != null) && this.isp.PD_Start__c >= this.isp.PD_End__c){
				errors.add('End Date should be greater than Start Date');
			}
			
			if(errors.isEmpty()){
				this.isp.PD_Errors__c = 'No Errors';
				this.isp.PD_isValid__c = true;
			}
		}else if(this.section == 'pageProfile'){
			
		}else if(this.section == 'desiredOutcomes'){
			if(!atleastOneEntryPresent('Desired_Outcomes', this.isp.Id)){
				this.isp.Desired_Outcomes_Errors__c = '<li>Atleast one entry in Desired outcomes is required</li>';
				this.isp.Desired_Outcomes_IsValid__c = false;
			}else{
				this.isp.Desired_Outcomes_Errors__c = 'No Errors';
				this.isp.Desired_Outcomes_IsValid__c = true;
				
			}
		}else if(section == 'cdp'){
			//Multi-selects
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
			
			
			
			if(!atleastOneEntryPresent('Employment_Outcomes', this.isp.Id) && 
				(
					this.isp.CDP_WA_Check_Apply_int_Employment__c.contains('Retain current job') ||
					this.isp.CDP_WA_Check_Apply_int_Employment__c.contains('Advance in current job (more hours, raise, new skills, promotion, etc.)') ||
					this.isp.CDP_WA_Check_Apply_int_Employment__c.contains('Get a new job') ||
					this.isp.CDP_WA_Check_Apply_int_Employment__c.contains('Get an additional job') ||
					this.isp.CDP_WA_Check_Apply_nonworking__c.contains('Get integrated employment') ||
					this.isp.CDP_WA_Check_Apply_nonworking__c.contains('Explore interests in integrated employment through an Employment Path, Discovery, or other time-limited service')
				)
			
			){
				this.isp.cdp_Errors__c = (this.isp.cdp_Errors__c == 'No Errors') ? '<li>Atleast one entry in Employment outcomes is required</li>' : this.isp.cdp_Errors__c +'<li>Atleast one entry in Employment Outcomes is required</li>';
				this.isp.cdp_isValid__c = false;
			}
		
		}else if(section == 'risk'){
			//nothing to process here
		}else if(section == 'ccms'){
			
		}else if(section == 'naturalSupports'){
			//No processing necessary
		}else if(section == 'sppc'){
			//nothing to process here
		}else if(section == 'kplan'){
			if(this.isp.K_Plan_Section_Not_Applicable__c){
				this.isp.kplan_Errors__c = 'No Errors';
				this.isp.kplan_isValid__c = true;
			}else{
				if(!atleastOneEntryPresent('K_Plan_Services', this.isp.Id)){
					this.isp.kplan_Errors__c = '<li>Atleast one entry in K Plan Services is required</li>';
					this.isp.kplan_isValid__c = false;
				}else{
					this.isp.kplan_Errors__c = 'No Errors';
					this.isp.kplan_isValid__c = true;	
				}
			}
		}else if(section == 'waiver'){
			if(this.isp.Waiver_Section_Not_Applicable__c){
				this.isp.Waiver_Errors__c = 'No Errors';
				this.isp.Waiver_isValid__c = true;
			}else{
				if(!atleastOneEntryPresent('Waiver_Services', this.isp.Id)){
					this.isp.Waiver_Errors__c = '<li>Atleast one entry in Waiver Services is required</li>';
					this.isp.Waiver_isValid__c = false;
				}else{
					this.isp.Waiver_Errors__c = 'No Errors';
					this.isp.Waiver_isValid__c = true;	
				}
			}
			
		}else if(section == 'kpr'){
			//KPR_Included_Services__c
			string kis = '';
			for(string cp: selectedKPRServices){
				kis += cp+';';
			}
			
			if(kis != ''){
				kis = kis.Substring(0,kis.length()-1);
				this.isp.KPR_Included_Services__c = kis;
			}else{
				this.isp.KPR_Included_Services__c = '';
			}
			
			//KPR_Additional_Services__c
			string kas = '';
			for(string cp: selectedKPRAdditional){
				kas += cp+';';
			}
			
			if(kas != ''){
				kas = kas.Substring(0,kas.length()-1);
				this.isp.KPR_Additional_Services__c = kas;
			}else{
				this.isp.KPR_Additional_Services__c = '';
			}
			
		}else if(section == 'adlchosen'){
			
		}else if(section == 'differences'){
			//nothing to process here
		}else if(section == 'legal'){
			
		}else if(section == 'acknowledgements'){
			//nothing to process here
		}else if(section == 'agreement'){
			//Check if Present at ISP field is present or not for the pnes that are created during creation process. Adhoc Contributors are handled on the modal save button itself
			this.isp.Agreement_Errors__c = '';
			this.isp.Agreement_isValid__c = false;
			
			for(Evaluation_Response__c con: this.contributors){
				if(string.isBLANK(con.ISP_Present_at_Meeting__c) && con.ISP_Signature_Required__c){
					this.isp.Agreement_Errors__c +='<li>'+'Present at ISP meeting is mandatory for '+con.ISP_Contributor_Name__c+' -- '+con.ISP_Title_Relationship_Person__c+'</li>';
				}
			}
			if(this.isp.Agreement_Errors__c == ''){
				this.isp.Agreement_Errors__c = 'No Errors';
				this.isp.Agreement_isValid__c = true;
			}
			
		}else if(section == 'relparty'){
			//nothing to process here
			
		}
		
		if(!errors.isEmpty()){
			for(string s: errors){
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,s));
			}
			return null;
		}
		
		string sectionCat = ApexPages.CurrentPage().getParameters().get('targetSec');
		string isSection = ApexPages.CurrentPage().getParameters().get('isSection');
		
		system.debug('Section Cat'+sectionCat);
		system.debug('isSection'+isSection);
		
		
		
		try{
			upsert this.isp;
			if(isSection == ''){
				PageReference page = ApexPages.currentPage();
				Map<String, String> params = page.getParameters();
				params.clear();
				params.put('mode', PageMode.EDIT.name());
				params.put('id', this.isp.Id);
				params.put('section', '');
				page.setRedirect(true);
				return page;
			}else if(isSection == 'true'){
				PageReference page2 = new PageReference('/apex/ORcombinedISP');
				Map<String, String> params = page2.getParameters();
				params.clear();
				params.put('mode', 'EDIT');
				params.put('id', this.isp.Id);
				params.put('section', sectionCat);
				page2.setRedirect(true);
				return page2;
			}else if(isSection == 'false'){
				PageReference page3 =  new PageReference('/apex/ORriskTool');
				Map<String, String> params = page3.getParameters();
				params.clear();
				params.put('id', this.isp.Id);
				params.put('category', sectionCat);
				params.put('evalType', 'Risk Identification Tool');
				page3.setRedirect(true);
				return page3;
			}
			
		}catch (exception e){
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Unable to Update ISP due to '+e.getMessage()+' at '+e.getStacktraceString()));
		}
		return null;
	}
	
	public void addorRefreshLegal(){
		Case_Management_Plan__c cm = pullRelatedParties(this.isp.Service_Assignment__r.Admission__r.Person_being_Served__c, this.isp.Id, isEditMode);
		this.isp.Leg_Parents__c = cm.Leg_Parents__c;
		this.isp.Leg_Guardians__c = cm.Leg_Guardians__c;
		this.isp.Leg_Designated_Representative_Planning__c = cm.Leg_Designated_Representative_Planning__c;
		this.isp.Leg_Designated_Representative_Employer__c = cm.Leg_Designated_Representative_Employer__c;
		this.isp.Leg_Representative_Payee__c = cm.Leg_Representative_Payee__c;
		this.isp.Leg_Conservators__c  = cm.Leg_Conservators__c;
		cm = new Case_Management_Plan__c();//Clear view State
	}
	
	public void refreshContributors(){
		
		set<id> existingContributorIds = new set<id>();
		List<Evaluation_Response__c> contributorstoAdd = new list<Evaluation_Response__c>();
		for(Evaluation_Response__c er: this.contributors){
			if(er.ISP_Type_of_Contributor__c == 'TypeB' || er.ISP_Type_of_Contributor__c == 'TypeC'){
				existingContributorIds.add(er.ISP_Contributor_Origin_Id__c);
			}
		}
		
		//only add New Contrbutors. Do not edit existing ones. This is applicable only for Related Parties and Personal Agents as PBS does not change and TypeD are adhocs added by User
		Id ContributorRectypeId = Schema.SObjectType.Evaluation_Response__c.getRecordTypeInfosByName().get('Contributors & Signatures').getRecordTypeId();
		for(Service_Assignment_Personal_Agent__c pa: [SELECT Id,Personal_Agent__r.Name FROM Service_Assignment_Personal_Agent__c WHERE Service_Assignment__c = :this.isp.Service_Assignment__c AND ID NOT IN :existingContributorIds] ){
		   	Evaluation_Response__c typeB = new Evaluation_Response__c(ISP_Contributor_Name__c = pa.Personal_Agent__r.Name, ISP_Title_Relationship_Person__c='Personal Agent',ISP_Contributor_Origin_Id__c = pa.Id,
		   																					ISP_Contributor_Risk_Identification_Tool__c= false,PCI_Contributor_to_Person_Centered__c = false, ISP_Signature_Required__c = true, Case_management_Plan__c = this.isp.Id,RecordtypeId = ContributorRectypeId, ISP_Type_of_Contributor__c = 'TypeB');
		   	contributorstoAdd.add(typeB);
		}
 
   		//type C
   		for(Related_party__c rp: [SELECT Name FROM Related_Party__c WHERE Person_being_Served__c = :this.isp.Service_Assignment__r.Admission__r.Person_being_Served__c AND Type__c = 'Guardian' AND Status__c = 'Active' AND ID NOT IN: existingContributorIds]){
   			Evaluation_Response__c typeC = new Evaluation_Response__c(ISP_Contributor_Name__c = rp.Name, ISP_Title_Relationship_Person__c='Legal Guardian', ISP_Contributor_Origin_Id__c = rp.Id,
   																					ISP_Contributor_Risk_Identification_Tool__c= false,PCI_Contributor_to_Person_Centered__c = false, ISP_Signature_Required__c = true, Case_management_Plan__c = this.isp.Id, RecordtypeId = ContributorRectypeId, ISP_Type_of_Contributor__c = 'TypeC');
   			contributorstoAdd.add(typeC);
   		}
		
		if(!contributorstoAdd.isEMPTY()){
			try{
				insert contributorstoAdd;
				populatecontributors(); //reQuery to update the view
			}catch (exception e){
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Contributors cannot be refreshed due to '+e.getMessage()));
			}
		}
	}
	
	
	public pageReference cancel(){
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.EDIT.name());
		params.put('id', this.isp.Id);
		params.put('section', '');
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
	
	
	public static Case_Management_Plan__c pullRelatedParties(Id PBSId, Id currentRecordId, Boolean isEditMode){
		
		Case_Management_Plan__c isp = new Case_Management_Plan__c(id=currentRecordId);//[SELECT Leg_Parents__c, Leg_Guardians__c, Leg_Designated_Representative_Planning__c, Leg_Designated_Representative_Employer__c, 
										//Leg_Health_Care_Representative__c, Leg_Representative_Payee__c, Leg_Conservators__c FROM Case_Management_Plan__c WHERE ID=:currentRecordId LIMIT 1];
										
		List<Related_Party__c> parties = [SELECT Name, Type__c FROM Related_Party__c WHERE Person_Being_Served__c = :PBSId AND Status__c = 'Active'];
	
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
	
	//Related Party
	public Related_Party__c relParty {
	    get {
	      if (relParty == null)
	        relParty = new Related_Party__c();
	      return relParty;
	    }
	    set;
	}
	
  public List<Related_Party__c> relParties { get; set; }
  
  public String relPartiesJSON {get {
    List<RelatedParty> relPartiesData = new List<RelatedParty>();
    if (relParties.size() > 0) {
        for (Related_Party__c rp :relParties){
            relPartiesData.add( new RelatedParty(rp.id, rp.Type__c) );
        }
    }   
    return JSON.serialize(relPartiesData);}
  }

  public class RelatedParty{
     Id Id;
     String TypeC;
     RelatedParty(Id id, String typeC){
        this.Id=id;
        this.TypeC = typeC;
     }
  }
  
   private void populateRelParties() {
    try {
        this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Served__c, Status__c, CreatedDate
                         from Related_Party__c
                         where Person_Being_Served__c = :this.isp.Service_Assignment__r.Admission__r.Person_being_Served__c order by Type__c, Name
                         ];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
  
  
  public void showAddRelParty() {
    relParty = new Related_Party__c();
    relParty.Status__c = 'Active';
  }

  public void saveRelParty() {
    populateRelParties();
    this.relParty = new Related_Party__c();
    relParty.Status__c = 'Active';
  }
   
   
 
  //Contributors and Signatures Data
  
 	public Evaluation_Response__c contributor {
	    get {
	      if (contributor == null){
	        	contributor = new Evaluation_Response__c();
	        	contributor.ISP_Type_of_Contributor__c = 'TypeD';
	      }
	      return contributor;
	    }
	    set;
	}
	
	public List<Evaluation_Response__c> contributors { get; set; }
	
	private void populatecontributors() {
    try {
        this.contributors = [select ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c,	PCI_Contributor_to_Person_Centered__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate, ISP_Contributor_Origin_Id__c  
                         from Evaluation_Response__c
                         where Case_Management_Plan__c = :this.isp.Id AND RecordType.Name = 'Contributors & Signatures' order by CreatedDate asc
                         ];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Contributors and Signatures Data. ' + e.getMessage()));
    }
  }
  
  
  public void showAddcontributor() {
    contributor = new Evaluation_Response__c();
    contributor.ISP_Type_of_Contributor__c = 'TypeD';
  }

  public void savecontributor() {
    populatecontributors();
    contributor = new Evaluation_Response__c();
    contributor.ISP_Type_of_Contributor__c = 'TypeD';
  }
  
  public void showEditContributor(){
  	string contributorID = ApexPages.CurrentPage().getParameters().get('contributorID');
  	this.contributor =  [select Case_Management_Plan__c, ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c,PCI_Contributor_to_Person_Centered__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate
                         from Evaluation_Response__c WHERE Id=:contributorID];
    this.contributor.ISP_Contributor_Name__c = this.contributor.ISP_Contributor_Name__c + ' -- '+this.contributor.ISP_Title_Relationship_Person__c;
                         
  }
  
  public void deleteContributor(){
  	string contributorID = ApexPages.CurrentPage().getParameters().get('contributorDelID');
  	this.contributor = new Evaluation_Response__c(id=contributorID);
  	delete this.contributor;
  	populatecontributors(); //Repopulate the list after deletion
  	
  }
	
/*	@RemoteAction
    public static Evaluation_Response__c loadContributor(string contributorId) {
            Evaluation_Response__c contributor = 
                [select Case_Management_Plan__c, ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate
                         from Evaluation_Response__c WHERE Id=:contributorId];
            return contributor;
     }*/
     
     
    @RemoteAction
    public static Evaluation_Response__c saveContributor(string contributorId, string name, boolean contributiontoRisk, Boolean signRequired, string presentatMeeting,
                                              string caseMgId, boolean contributortoPCI) {
                                              	
      Id ContributorRectypeId = Schema.SObjectType.Evaluation_Response__c.getRecordTypeInfosByName().get('Contributors & Signatures').getRecordTypeId();
      Evaluation_Response__c contributor;                                        
      if (String.isEmpty(contributorId)) {
         contributor = new Evaluation_Response__c(RecordtypeId = ContributorRectypeId, ISP_Contributor_Name__c = name.substringBeforeLast(' -- '), ISP_Title_Relationship_Person__c = name.substringAfterLast(' -- '), ISP_Contributor_Risk_Identification_Tool__c = contributiontoRisk,
         											ISP_Signature_Required__c = signRequired, ISP_Present_at_Meeting__c = presentatMeeting, Case_Management_Plan__c = caseMgId, ISP_Type_of_Contributor__c = 'TypeD', PCI_Contributor_to_Person_Centered__c = contributortoPCI);
      } else {
         contributor = new Evaluation_Response__c(RecordtypeId = ContributorRectypeId, ISP_Contributor_Name__c = name.substringBeforeLast(' -- '), ISP_Title_Relationship_Person__c = name.substringAfterLast(' -- '), ISP_Contributor_Risk_Identification_Tool__c = contributiontoRisk,
         											ISP_Signature_Required__c = signRequired, ISP_Present_at_Meeting__c = presentatMeeting, Case_Management_Plan__c = caseMgId, ID=contributorId, PCI_Contributor_to_Person_Centered__c = contributortoPCI);
      }
      upsert contributor;                                  
      return contributor;
   }

	@RemoteAction
    public static Related_Party__c saveRelatedParty(string partyID, string Name, string PartyType, string Phone1, string Email, 
                                              string Address, string Phone2, string Phone1Type, string Phone2Type, string comments, string pStatus,
                                              string PBSId) {
      Related_Party__c party;                                        
      if (String.isEmpty(partyID)) {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Status__c = pStatus,
                                                    Person_Being_Served__c = PBSId);
      } else {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Status__c = pStatus,
                                                    Person_Being_Served__c = PBSId, ID = partyID);
      }
      upsert party;                                  
      return party;
   }
   
    @RemoteAction
    public static Related_Party__c loadRelatedParty(string relPartyId) {
            Related_Party__c party = 
                [select Id,Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c,Status__c, Person_Being_Served__c, createddate
                 from Related_Party__c where id = :relPartyId];
            return party;
     }
		
	public static Boolean atleastOneEntryPresent(string RecordTypeName, Id ispID){
		List<Evaluation_Response__c> entries = [SELECT Id FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :ispID AND Recordtype.DeveloperName = :RecordTypeName LIMIT 1];
		return !entries.IsEmpty();
	}
	
	
}