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
    
    
    public string getprimaryPhysician(){
    	List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
    	if(rp.size()>0) return rp[0].Name;
    	else return null;
    }
    
	public CMShiftAssessmentEdit(Apexpages.StandardController controller){
		this.stdController = controller;
		evaluation = (Evaluation__c) stdController.getRecord();
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
        
        
        
        if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
               selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');
               
        if(!String.isBlank(this.evaluation.Orientation__c))
               selectedNeuroOrient = this.evaluation.Orientation__c.split(';');
       
        if(!String.isBlank(this.evaluation.Mood__c))
               selectedMoods = this.evaluation.Mood__c.split(';');
        
        if(!String.isBlank(this.evaluation.Breathe_sounds__c))
                selectedSounds = this.evaluation.Breathe_Sounds__c.split(';');
        
                
	}

   public PageReference handleIVfields(){
	   	if(evaluation.IV_Picklist__c != 'Yes'){
	   		evaluation.Picc__c = false;
	   		evaluation.Central__c = false;
	   		evaluation.Heplock__c = false;
	   		evaluation.IV_Site_Issues__c = '';
	   		evaluation.IV_Narrative_Note__c = '';
	   	}
   	
   		return null;	
   }
   
   public PageReference handleNarrativenote(){
    	if(evaluation.IV_Site_Issues__c != 'Yes'){
    		evaluation.IV_Narrative_Note__c = '';	
    	}
   		
   		return null;
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
                        if(!strtypes.Contains('Other'))
                        this.evaluation.Breathe_Sound_Other__c = '';
                }
                else{
	                this.evaluation.Breathe_Sounds__c ='';
	                this.evaluation.Breathe_Sound_Other__c ='';
                }
       			
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
}