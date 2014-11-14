public with sharing class CMShiftAssessmentEdit {
	public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    
    public Boolean showResidenthurt{get; set; }
    
    public List<selectOption>copingValues ;
    public List<string>selectedCoping {get;set;}
    public List<selectOption>neuroOrientValues ;
    public List<string>selectedNeuroOrient{get;set;}
    public List<selectOption>moodValues ;
    public List<string>selectedMoods {get;set;}
    public List<SelectOption>breatheSounds ;
    public List<string>selectedSounds {get ; set;}
    public List<SelectOption>DysreflexiaValues;
    public List<string>selectedDysreflexia {get ; set;}
    
     public Evaluation_Response__c[] vitals { set;
        get {
            return [
                SELECT ID,Name,Date__c,Heart_Rate__c,Blood_Pressure__c,R__c,O2_Saturation__c,Temperature__c,O2_Intervention_Needed__c,O2_Narrative_Note__c,
                HR_Intervention_Needed__c, HR_Narrative_Note__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                 AND RecordType.Name='Vitals Details Shift Assessment'
            ];
        }
    }
    
    public Evaluation_Response__c currentVitalsDetail {get; set; }
    public Id currentVitalsDetailId { get; set; }
    
    public string getprimaryPhysician(){
    	List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
    	if(rp.size()>0) return rp[0].Name;
    	else return null;
    }
    
	public CMShiftAssessmentEdit(Apexpages.StandardController controller){
		this.stdController = controller;
		evaluation = (Evaluation__c) stdController.getRecord();
		currentVitalsDetail = new Evaluation_Response__c();
		if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        	}
        
        showResidenthurt = false;
        	
        copingValues = new List<selectOption>();
        selectedCoping = new List<String>();
        neuroOrientValues = new List<selectOption>();
        selectedNeuroOrient = new List<string>();
        moodValues = new List<selectOption>();
        selectedMoods = new List<String>();
        breatheSounds = new List<SelectOption>();
        selectedSounds = new List<String>();
        DysreflexiaValues = new List<SelectOption>();
        selectedDysreflexia = new List<String>();
        
        
        if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
               selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');
               
        if(!String.isBlank(this.evaluation.Orientation__c))
               selectedNeuroOrient = this.evaluation.Orientation__c.split(';');
       
        if(!String.isBlank(this.evaluation.Mood__c))
               selectedMoods = this.evaluation.Mood__c.split(';');
        
        if(!String.isBlank(this.evaluation.Breathe_sounds__c))
                selectedSounds = this.evaluation.Breathe_Sounds__c.split(';');
                
        if(!String.isBlank(this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c))
                selectedDysreflexia = this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c.split(';');
        
                
	}
	
	 public void showAddVitalsDetail()  {
        this.currentVitalsDetail = new Evaluation_Response__c();
        this.currentVitalsDetail.Evaluation__c = this.evaluation.Id;
        this.currentVitalsDetail.RecordTypeId = Utility.getEvaluationResponseRecordType('Vitals Details Shift Assessment');
                
    }
    
    public void showEditVitalsDetail() {
        this.currentVitalsDetail = [
                SELECT ID, Name, Date__c, Temperature__c, R__c, O2_Saturation__c, Blood_Pressure__c,
                   Heart_Rate__c
            FROM Evaluation_Response__c WHERE ID=:currentVitalsDetailId
        ];
                
    }
    public void saveVitalsDetail() {
        try {
           
            upsert currentVitalsDetail;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }

	  public PageReference handleResidentdescribe(){
	   		if(evaluation.Resident_Coping_Well__c != 'No'){
	   			evaluation.Coping_Description__c = '';
	   		}
	   		
	   		return null;
	  }
	  
	 public pageReference handleRanchoresponse(){
	 	evaluation.Verbal_Stim__c = false;
	 	evaluation.Auditory_Stim__c = false;
	 	evaluation.Tactile_Stim__c = false;
	 	evaluation.Responds_To_Pain__c = false;
	 	evaluation.Visual__c = false;
	 	evaluation.Level_of_Conciousness__c ='';
	 	evaluation.Cooperative__c = false;
	 	evaluation.Impulsive__c = false;
	 	evaluation.Inappropriate__c = false;
	 	evaluation.Agitated__c = false;
	 	evaluation.Combative__c = false;
	 	evaluation.Confused__c = false;
	 	evaluation.Unresponsive__c = false;
	 	selectedNeuroOrient = new List<String>();
	 	
	 	
	 	return null;
	 	
	 }
	 
	 public void handleMood(){
	 	set<string> moods = new set<string>(); // Using set as we do not have a List.contains method. Using set helps us avoid using a for loop. Sravan: 11/5/2014 11:30 AM.
	 	moods.addAll(selectedMoods);
	 	if(moods.Contains('Unable to Determine')){
	 		selectedMoods = new List<string>{'Unable to Determine'};
	 		showResidenthurt = false;
	 		this.evaluation.Desire_to_hurt_themselves__c = '';				
	 	}
	 	if((moods.Contains('Sad') || moods.Contains('Flat')) && !moods.Contains('Unable to Determine')){
	 		showResidenthurt = true;	
	 	}
	 	else{
	 		 showResidenthurt = false;
	 		 this.evaluation.Desire_to_hurt_themselves__c = '';
	 	}
	 }
	   
	 
	 public void handleResidenthurt(){
	 	this.evaluation.Plan_to_Harm_themselves__c = '';
	 		
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
	 	
	 	public PageReference save(Boolean submitted) {
	 		if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {
	
	        }
	        // For Resident Coping Well Multi-Picklist
	                string cpg ='';
	                for(string cp: selectedCoping)
	                cpg += cp+';';
	                
	                if(cpg!=''){
	                        cpg = cpg.Substring(0,cpg.length()-1);
	                        this.evaluation.Resident_Demonstrating_Issues__c = cpg;
	                } 
	                else
	                this.evaluation.Resident_Demonstrating_Issues__c ='';
	                        
	       // For Orientation Multi-picklist
	       			string orn = '';
	       			for(string rn: selectedNeuroOrient)
	       				orn += rn+';';
	       				
	   				if(orn!= ''){
	   					orn = orn.Substring(0,orn.length()-1);
	   					this.evaluation.Orientation__c = orn;
	   					}
	   				else
	                this.evaluation.Orientation__c ='';
	                        
	     
			// For Mood Multi-picklist
	                string mod='';
	                for(string md: selectedMoods)
	                	mod += md+';';
	                
	                if(mod!=''){
	                     mod = mod.Substring(0,mod.length()-1);
	                     this.evaluation.Mood__c = mod;
	                }
	                else
	                	this.evaluation.Mood__c ='';
	                
	         //for breathe sounds multi-select
			        String strtypes = '';
			        for (String s : selectedSounds)
			                strtypes += s +';';
	                
	                if (strtypes != ''){
	                        strtypes = strtypes.Substring(0, strtypes.length() -1);
	                        this.evaluation.Breathe_Sounds__c = strtypes;
	                        
	                }
	                else{
		                this.evaluation.Breathe_Sounds__c ='';
		               
	                }
	                
	          // For Autonomic Dysreflexia Areas Assessed
	                string Dys='';
	                for(string ds: selectedDysreflexia)
	                	Dys += ds+';';
	                
	                if(Dys!=''){
	                     Dys = Dys.Substring(0,Dys.length()-1);
	                     this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c = Dys;
	                }
	                else
	                	this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c ='';
	       			
	        update this.evaluation;
	        return new PageReference('/apex/CMShiftAssessmentView?id=' + evaluation.Id + '&tab=' + selectedTab);
	 	}
	 	
	   public List<selectoption> getcopingValues(){
	                List<Selectoption> copingValue = Utility.getPicklistValues(evaluation, 'Resident_Demonstrating_Issues__c');
	                return copingValue; 
	   }
	   
	   public List<selectoption> getneuroOrientValues(){
	                List<Selectoption> orientValue = Utility.getPicklistValues(evaluation, 'Orientation__c');
	                return orientValue; 
	   }
	   
	   public List<selectoption> getmoodValues(){
	                List<Selectoption> moodValue = Utility.getPicklistValues(evaluation, 'Mood__c');
	                return moodValue; 
	   }
	   
	   public List<SelectOption> getbreatheSounds(){
	                List<Selectoption> breatheSound = Utility.getPicklistValues(evaluation, 'Breathe_Sounds__c');
	                return breatheSound; 
	                
	   }
	   
	   public List<SelectOption> getDysreflexiaValues(){
	                List<Selectoption> DysreflexiaValue = Utility.getPicklistValues(evaluation, 'Autonomic_Dysreflexia_Areas_Assessed__c');
	                return DysreflexiaValue; 
	                
	   }
	}