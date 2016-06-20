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
				'CDP_NE_Check_Apply_Decision_Not_Explore__c',
				'KPR_Included_Services__c',
				'KPR_Additional_Services__c',
				'CreatedBy.Name'
			});
		}
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (!params.containsKey('mode')) {
			this.mode = PageMode.VIEW;
		}else {
			this.mode = getModeEnum(params.get('mode'));
		}
		
		if(params.containsKey('section')){
			this.section = params.get('section');
		}else{
			this.section = 'Full View';
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
	
	
	
/*	public PageReference save() {
		
		List<String> errors = new List<string>();
		/*if(this.isp.PD_End__c == null ){
			this.isp.addError('Start Date is Mandatory');
			errors.add('Start Date is Mandatory');
		}
		
		if(this.isp.PD_End__c == null){
			this.isp.PD_End__c.addError('End Date is Mandatory');
			errors.add('End Date is Mandatory');
		}
		
		if(!errors.isEmpty()){
			for(string s: errors){
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,s));
			}
			return null;
		}else{
			upsert this.isp;
			PageReference page = ApexPages.currentPage();
			Map<String, String> params = page.getParameters();
			params.clear();
			params.put('mode', PageMode.VIEW.name());
			params.put('id', this.isp.Id);
			params.put('section', this.section);
			page.setRedirect(true);
			return page;
		}
		
		
	}*/
	
	public pageReference save(){
		processMultiSelects();
		if(section == 'planDates'){
			
		}else if(this.section == 'pageProfile'){
			system.debug('In here');
			if(!atleastOneEntryPresent('Desired_Outcomes', this.isp.Id)){
				this.isp.Profile_Errors__c = (this.isp.Profile_Errors__c == 'No Errors') ? '<li>Atleast one entry in Desired outcomes is required</li>' : this.isp.Profile_Errors__c +'<li>Atleast one entry in Desired outcomes is required</li>';
				this.isp.Profile_isValid__c = false;
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
			
			if(!atleastOneEntryPresent('Employment_Outcomes', this.isp.Id)){
				this.isp.cdp_Errors__c = (this.isp.cdp_Errors__c == 'No Errors') ? '<li>Atleast one entry in Desired outcomes is required</li>' : this.isp.cdp_Errors__c +'<li>Atleast one entry in Employment Outcomes is required</li>';
				this.isp.cdp_isValid__c = false;
			}
		
		}else if(section == 'risk'){
			
		}else if(section == 'ccms'){
			
		}else if(section == 'naturalSupports'){
			
		}else if(section == 'sppc'){
			
		}else if(section == 'kplan'){
			
		}else if(section == 'waiver'){
			
		}else if(section == 'kpr'){
			
		}else if(section == 'adlchosen'){
			
		}else if(section == 'differences'){
			
		}else if(section == 'legal'){
			
		}else if(section == 'acknowledgements'){
			
		}else if(section == 'agreement'){
			
		}else if(section == 'relparty'){
			
		}
		
		try{
			upsert this.isp;
			PageReference page = ApexPages.currentPage();
			Map<String, String> params = page.getParameters();
			params.clear();
			params.put('mode', PageMode.VIEW.name());
			params.put('id', this.isp.Id);
			params.put('section', this.section);
			page.setRedirect(true);
			return page;
		}catch (exception e){
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Unable to Update ISP due to '+e.getMessage()+' at '+e.getStacktraceString()));
		}
		
		
		
		return null;
	}
	
	public pageReference cancel(){
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', PageMode.VIEW.name());
		params.put('id', this.isp.Id);
		params.put('section', this.section);
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
		/*string sie = '';
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
		}*/
		
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
        this.contributors = [select ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate 
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
	
	@RemoteAction
    public static Evaluation_Response__c loadContributor(string contributorId) {
            Evaluation_Response__c contributor = 
                [select Case_Management_Plan__c, ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate
                         from Evaluation_Response__c WHERE Id=:contributorId];
            return contributor;
     }
     
    @RemoteAction
    public static Evaluation_Response__c saveContributor(string contributorId, string name, string title, boolean contributiontoRisk, Boolean signRequired, string presentatMeeting,
                                              string caseMgId) {
      Evaluation_Response__c contributor;                                        
      if (String.isEmpty(contributorId)) {
         contributor = new Evaluation_Response__c(ISP_Contributor_Name__c = name, ISP_Title_Relationship_Person__c = title, ISP_Contributor_Risk_Identification_Tool__c = contributiontoRisk,
         											ISP_Signature_Required__c = signRequired, ISP_Present_at_Meeting__c = presentatMeeting, Case_Management_Plan__c = caseMgId, ISP_Type_of_Contributor__c = 'TypeD');
      } else {
         contributor = new Evaluation_Response__c(ISP_Contributor_Name__c = name, ISP_Title_Relationship_Person__c = title, ISP_Contributor_Risk_Identification_Tool__c = contributiontoRisk,
         											ISP_Signature_Required__c = signRequired, ISP_Present_at_Meeting__c = presentatMeeting, Case_Management_Plan__c = caseMgId, ID=contributorId);
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