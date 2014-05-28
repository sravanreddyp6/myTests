public with sharing class NursingEvaluationEditController {
	public Evaluation__c evaluation { get; set; }
	public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    
    public List<SelectOption>breatheSounds ;
    public List<string>selectedSounds {get ; set;}
    public List<selectoption>urinaryIssues;
    public List<string>selectedIssues {get; set;}
    public List<SelectOption>urineClarities ;
    public List<string>selectedClarities {get; set;}
    public List<selectOption>tongueValues ;
    public List<string>selectedTongues {get;set;}
    public List<selectOption>gumValues ;
    public List<string>selectedGums {get;set;}
    public List<selectOption>cheekValues ;
    public List<string>selectedCheeks {get;set;}
    public List<selectOption>lipValues ;
    public List<string>selectedLips {get;set;}
    public List<selectOption>salivaValues ;
    public List<string>selectedSaliva {get;set;}
    public List<selectOption>dentureValues ;
    public List<string>selectedDentures {get;set;}
    public List<selectOption>abdomenValues ;
    public List<string>selectedAbdomen {get;set;}
   
    
    public Related_Party__c[] relatedParties { set;
        get {
            return [
                SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                       Phone_2__c, Phone_2_Type__c, Comments__c
                FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.Id
            ];
        }
    }
    
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }
    public Related_Party__c currentRelatedParty { get; set; }
    public Id currentRelatedPartyId { get; set; }
   // public Contact pbs { get; set; }
    
    public NursingEvaluationEditController(ApexPages.StandardController stdcontroller) {
    	this.stdController = stdController;
    	evaluation = (Evaluation__c) stdController.getRecord();
    	currentRelatedParty = new Related_Party__c();
    	if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        }
		breatheSounds = new List<SelectOption>();
		selectedSounds = new List<String>();
		urinaryIssues = new List<Selectoption>();
		selectedIssues = new List<string>();
		urineClarities = new List<selectOption>();
		selectedClarities = new List<string>();
		tongueValues = new List<SelectOption>();
		selectedTongues = new List<String>();
		gumValues = new List<SelectOption>();
		selectedGums = new List<String>();
		cheekValues = new List<SelectOption>();
		selectedCheeks = new List<String>();
		lipValues = new List<SelectOption>();
		selectedLips = new List<String>();
		salivaValues = new List<SelectOption>();
		selectedSaliva = new List<String>();
		dentureValues = new List<SelectOption>();
		selectedDentures = new List<String>();
		abdomenValues = new List<SelectOption>();
		selectedAbdomen = new List<String>();
		
		if(!String.isBlank(this.evaluation.Breathe_sounds__c))
		selectedSounds = this.evaluation.Breathe_Sounds__c.split(';');
		
		if(!String.isBlank(this.evaluation.Urinary_Issues__c))
		selectedIssues = this.evaluation.Urinary_Issues__c.split(';');
		
		if(!String.isBlank(this.evaluation.Urine_Clarity__c))
		selectedClarities = this.evaluation.Urine_Clarity__c.split(';');
		
		if(!String.isBlank(this.evaluation.Tongue__c))
		selectedTongues = this.evaluation.Tongue__c.split(';');
		
		if(!String.isBlank(this.evaluation.Gums__c))
		selectedGums = this.evaluation.Gums__c.split(';');
		
		if(!String.isBlank(this.evaluation.Cheeks__c))
		selectedCheeks = this.evaluation.Cheeks__c.split(';');
		
		if(!String.isBlank(this.evaluation.Lips__c))
		selectedLips = this.evaluation.Lips__c.split(';');
		
		if(!String.isBlank(this.evaluation.Saliva__c))
		selectedSaliva = this.evaluation.Saliva__c.split(';');
		
		if(!String.isBlank(this.evaluation.Dentures_Type__c))
		selectedDentures = this.evaluation.Dentures_Type__c.split(';');
		
		if(!String.isBlank(this.evaluation.Abdomen__c))
		selectedAbdomen = this.evaluation.Abdomen__c.split(';');
    }
    
    public void showAddRelatedParty()  {
    	this.currentRelatedParty = new Related_Party__c();
    	this.currentRelatedParty.Person_Being_Served__c = this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c;
    	this.currentRelatedParty.RecordTypeId = '012U0000000Dj0Y';
    	 	
    }
    
    public void showEditRelatedParty() {
    	this.currentRelatedParty = [
    		SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                   Phone_2__c, Phone_2_Type__c, Comments__c
            FROM Related_Party__c WHERE ID=:currentRelatedPartyId 
    	];
    		
    }
    public void saveRelatedParty() {
        try {
            System.debug('currentRelatedParty: ' + currentRelatedParty);
            upsert currentRelatedParty;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }
    
      public PageReference save() {
        return this.save(false);
    }

    public PageReference submit() {
        return this.save(true);
    }

    public PageReference changeTab() {
        System.debug('nextTab: ' + nextTab);
        // When the user changes tab, we need to save his/her progress on the
        // previous tab as well. Therefore, if any validation error happens here,
        // we'll need to keep the user on the previous tab to fix their input
        // first.
        if (this.save(false) != null) {
            System.debug('Save successful!');
            selectedTab = nextTab;
        }
        return null;
    }

    /**
     * This method needs to know about whether the request is ready for submission,
     * and also the currently selected tab, because we need to group validation
     * on both the online form and the paper form in one place.
     */
    public PageReference save(Boolean submitted) {
        // All the validation goes here, partitioned by page. We can't do
        // object-level validation, because if there are 2 errors on 2 pages,
        // the user won't be able to save at all.
       
       
       //for breathe sounds multi-select
        String strtypes = '';
        for (String s : selectedSounds)
        	strtypes += s +';';
        	
        	if (strtypes != ''){
        		strtypes = strtypes.Substring(0, strtypes.length() -1);
        		this.evaluation.Breathe_Sounds__c = strtypes;
        	}
        	else
        	this.evaluation.Breathe_Sounds__c ='';
        	
      //for Urinary Issues mUlti-Picklist  	
        string uritypes ='';
        for(String u: selectedIssues)
        uritypes += u+';';
        
        	if(uritypes !=''){
        		uritypes = uritypes.Substring (0,uritypes.length() -1);
        		this.evaluation.Urinary_Issues__c = uritypes;
        		
        	}
        	else
        	this.evaluation.Urinary_Issues__c ='';
        	
     //for Urine Clarity Multi-picklist   	
        string clr ='';
        for(string c: selectedClarities)
        clr += c+';';
        	if(clr!=''){
        		clr =clr.Substring(0,clr.length()-1);
        		this.evaluation.Urine_Clarity__c = clr;
        	}
        	else
        	this.evaluation.Urine_Clarity__c ='';
        	
    // for Tongue Multi-Picklist
    	string tng = '';
    	for (string t: selectedTongues)
    	tng += t+';';
    		if(tng!=''){
    			tng = tng.Substring(0,tng.length()-1);
    			this.evaluation.Tongue__c = tng;
    		}
    		else
    		this.evaluation.Tongue__c = '';
    		
    		
   	// for Gums Multi-picklist
   		string gms ='';
   		for(string g : selectedGums)
   		gms += g+';';
   			if(gms!=''){
   				gms = gms.SubString(0,gms.length()-1);
   				this.evaluation.Gums__c = gms;
   			}
   			else
   			this.evaluation.Gums__c = '';
   			
   	// for Cheeks Multi-Picklist
   		string chk ='';
   		for(string c: selectedCheeks)
   		chk += c+';';
   			if(chk!=''){
   				chk= chk.Substring(0,chk.length()-1);
   				this.evaluation.Cheeks__c = chk;
   			}
        	else
        	this.evaluation.Cheeks__c ='';
        	
   // for lips Multi-picklist
   		string lps ='';
   		for(string l: selectedLips)
   		lps += l+';';
   			if(lps!=''){
   				lps= lps.Substring(0,lps.length()-1);
   				this.evaluation.Lips__c = lps;
   			}
   			else
   			this.evaluation.Lips__c = '';
   			
   			
   // for Saliva Multi-Picklist
   		string slv ='';
   		for (string sl: selectedSaliva)
   		slv += sl+';';
   			if(slv!=''){
   				slv = slv.Substring(0,slv.length()-1);
   				this.evaluation.Saliva__c = slv;
   			}
   			else
   			this.evaluation.Saliva__c = '';
   			
  // For Denture Types Multi-pIcklist
  		string dtp ='';
  		for(string d:selectedDentures)
  		dtp += d+';';
  			if(dtp!=''){
  				dtp= dtp.Substring(0,dtp.length()-1);
  				this.evaluation.Dentures_Type__c = dtp;
  			}
  			else
  			this.evaluation.Dentures_Type__c = '';
  			
  // For Abdomen Multi-Picklist
  		string abd ='';
  		for(string ab: selectedAbdomen)
  		abd += ab+';';
  			if(abd!=''){
  				abd= abd.Substring(0,abd.length()-1);
  				this.evaluation.Abdomen__C = abd;
  			}
  			else
  			this.evaluation.Abdomen__c = '';
   			     	
        if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {

        }
        update this.evaluation;
        //update this.pbs;
        //return stdController.view();
        return new PageReference('/apex/NursingEvaluationView?id=' + evaluation.Id + '&tab=' + selectedTab);
    }
    
   public List<SelectOption> getbreatheSounds(){
   		List<Selectoption> breatheSound = Utility.getPicklistValues(evaluation, 'Breathe_Sounds__c');
   		return breatheSound; 
   		
   }
   public List<SelectOption> geturinaryIssues(){
   		List<Selectoption> urinaryIssue = Utility.getPicklistValues(evaluation, 'Urinary_Issues__c');
   		return urinaryIssue; 
   			
   }
   public List<selectoption> geturineClarities(){
   		List<Selectoption> urineClarity = Utility.getPicklistValues(evaluation, 'Urine_Clarity__c');
   		return urineClarity; 
   }
   
   public List<selectoption> gettongueValues(){
   		List<Selectoption> tongueValue = Utility.getPicklistValues(evaluation, 'Tongue__c');
   		return tongueValue; 
   }
   
    public List<selectoption> getgumValues(){
   		List<Selectoption> gumValue = Utility.getPicklistValues(evaluation, 'Gums__c');
   		return gumValue; 
   }
   
    public List<selectoption> getcheekValues(){
   		List<Selectoption> cheekValue = Utility.getPicklistValues(evaluation, 'Cheeks__c');
   		return cheekValue; 
   }
   
   public List<selectoption> getlipValues(){
   		List<Selectoption> lipValue = Utility.getPicklistValues(evaluation, 'Lips__c');
   		return lipValue; 
   }
   
   public List<selectoption> getsalivaValues(){
   		List<Selectoption> salivaValue = Utility.getPicklistValues(evaluation, 'Saliva__c');
   		return salivaValue; 
   }
   
   public List<selectoption> getdentureValues(){
   		List<Selectoption> dentureValue = Utility.getPicklistValues(evaluation, 'Dentures_Type__c');
   		return dentureValue; 
   }
   
   public List<selectoption> getabdomenValues(){
   		List<Selectoption> abdomenValue = Utility.getPicklistValues(evaluation, 'Abdomen__c');
   		return abdomenValue; 
   }
   
   
}