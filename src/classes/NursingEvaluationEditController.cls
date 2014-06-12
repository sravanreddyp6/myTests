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
    public List<selectOption>hallValues ;
    public List<string>selectedHalls {get;set;}
    public List<selectOption>beliefValues ;
    public List<string>selectedBeliefs {get;set;}
    public List<selectOption>learningValues ;
    public List<string>selectedLearning {get;set;}
    public List<selectOption>copingValues ;
    public List<string>selectedCoping {get;set;}
    public List<selectOption>communicationValues ;
    public List<string>selectedCommunications {get;set;}
    public List<selectOption>barrierValues ;
    public List<string>selectedBarriers {get;set;}
    public List<selectOption>needValues ;
    public List<string>selectedNeeds {get;set;}
    public List<selectOption>orientValues ;
    public List<string>selectedOrients {get;set;}
    public List<selectOption>orientationValues ;
    public List<string>selectedOrientations {get;set;}
    public List<selectOption>fambarrierValues ;
    public List<string>selectedFambarriers {get;set;}
    public List<selectOption>famcommunicationValues ;
    public List<string>selectedFamcommunications {get;set;}
    public List<selectOption>famlearningValues ;
    public List<string>selectedFamlearnings {get;set;}
    public List<selectOption>experienceValues ;
    public List<string>selectedExperiences {get;set;}
    public List<selectOption>diagnosisValues ;
    public List<string>selectedDiagnosis {get;set;}
    public List<selectOption>medicationValues ;
    public List<string>selectedMedications {get;set;}
    public List<selectOption>prostheticValues ;
    public List<string>selectedProsthetics {get;set;}
    public List<selectOption>orthodicsValues ;
    public List<string>selectedOrthodics {get;set;}
    public List<selectOption>moodValues ;
    public List<string>selectedMoods {get;set;}
    public List<selectOption>alleviatorValues ;
    public List<string>selectedAlleviators {get;set;}
    public List<selectOption>adlValues ;
    public List<string>selectedAdls {get;set;}
    public List<selectOption>expressionValues ;
    public List<string>selectedExpressions {get;set;}
    public List<selectOption>paintypeValues ;
    public List<string>selectedPaintypes {get;set;}
    public List<selectOption>painalleviatorValues ;
    public List<string>selectedpainAlleviators {get;set;}
    public List<selectOption>painadlValues ;
    public List<string>selectedpainAdls {get;set;}
    public List<selectOption>painexpressionValues ;
    public List<string>selectedpainExpressions {get;set;}
    public List<selectOption>paindescriptorValues ;
    public List<string>selectedpainDescriptors {get;set;}
    
    
    
    public List<String> sliderOptions { set;
        get {
            if (sliderOptions == null) {
                sliderOptions = new String[] {
                    '', 'Impaired', 'WFLs', 'Therapist to Determine',
                    'N/A'
                };
            }
            return sliderOptions;
        }
    }
    
    public List<String> painsliderOptions { set;
        get {
            if (painsliderOptions == null) {
                painsliderOptions = new String[] {
                    '0', '1', '2', '3','4','5','6','7','8','9',
                    '10'
                };
            }
            return painsliderOptions;
        }
    }
    
    public Evaluation_Response__c[] annotations { set;
        get {
            return [
                SELECT ID, Annotation_Height__c, Annotation_Width__c,
                       Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                       Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                 AND RecordType.Name='Annotation'
            ];
        }
    }
    
    public Evaluation_Response__c[] neuroAnnotations { set;
        get {
            return [
                SELECT ID, Annotation_Height__c, Annotation_Width__c,
                       Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                       Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                 AND RecordType.Name='NeuroAnnotation'
            ];
        }
    }
    
   /* public String bodyMapUrl { get {
        Attachment[] attachments = [
            SELECT Id FROM Attachment
            WHERE ParentId=:evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c
              AND Name='BodyMarkup.png'
        ];
        if (attachments.size() > 0) {
            return '/servlet/servlet.FileDownload?file=' + attachments[0].Id;
        }
        return null;
    } } */
    
   public String serializedAnnotations { get; set; }
   public String neuroserializedAnnotations { get; set; }
    
    public List<Attachment> immuneAttachments{
        get{
            
            if(immuneAttachments==null){
                immuneAttachments= [select Id, ParentId, Name, Description from Attachment where parentId=:ApexPages.CurrentPage().getparameters().get('id')];
            }
            return immuneAttachments;
        }
        set;
    }
    
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
    	serializedAnnotations = JSON.serialize(annotations);
    	neuroserializedAnnotations = JSON.serialize(neuroAnnotations);
    	
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
		hallValues = new List<selectOption>();
		selectedHalls = new List<String>();
		beliefValues = new List<selectOption>();
		selectedBeliefs = new List<String>();
		learningValues = new List<selectOption>();
		selectedLearning = new List<String>();
		copingValues = new List<selectOption>();
		selectedCoping = new List<String>();
		communicationValues = new List<selectOption>();
		selectedCommunications = new List<String>();
		barrierValues = new List<selectOption>();
		selectedBarriers = new List<String>();
		needValues = new List<selectOption>();
		selectedNeeds = new List<String>();
		orientValues = new List<selectOption>();
		selectedOrients = new List<String>();
		orientationValues = new List<selectOption>();
		selectedOrientations = new List<String>();
		fambarrierValues = new List<selectOption>();
		selectedFambarriers = new List<String>();
		famcommunicationValues = new List<selectOption>();
		selectedFamcommunications = new List<String>();
		famlearningValues = new List<selectOption>();
		selectedFamlearnings = new List<String>();
		experienceValues = new List<selectOption>();
		selectedExperiences = new List<String>();
		diagnosisValues = new List<selectOption>();
		selectedDiagnosis = new List<String>();
		medicationValues = new List<selectOption>();
		selectedMedications = new List<String>();
		prostheticValues = new List<selectOption>();
		selectedProsthetics = new List<String>();
		orthodicsValues = new List<selectOption>();
		selectedOrthodics = new List<String>();
		moodValues = new List<selectOption>();
		selectedMoods = new List<String>();
		alleviatorValues = new List<selectOption>();
		selectedAlleviators = new List<String>();
		adlValues = new List<selectOption>();
		selectedAdls = new List<String>();
		expressionValues = new List<selectOption>();
		selectedExpressions = new List<String>();
		paintypeValues = new List<selectOption>();
		selectedPaintypes = new List<String>();
		painalleviatorValues = new List<selectOption>();
		selectedpainAlleviators = new List<String>();
		painadlValues = new List<selectOption>();
		selectedpainAdls = new List<String>();
		painexpressionValues = new List<selectOption>();
		selectedpainExpressions = new List<String>();
		paindescriptorValues = new List<selectOption>();
		selectedpainDescriptors = new List<String>();
		
	
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
		
		if(!String.isBlank(this.evaluation.Hallucination_Types__c))
		selectedHalls = this.evaluation.Hallucination_Types__c.split(';');
		
		if(!String.isBlank(this.evaluation.Typeof_Spiritual_belief_Effects__c))
		selectedBeliefs = this.evaluation.Typeof_Spiritual_belief_Effects__c.split(';');
		
		if(!String.isBlank(this.evaluation.Preferred_Method_of_Learning__c))
		selectedLearning = this.evaluation.Preferred_Method_of_Learning__c.split(';');
		
		if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
		selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');
		
		if(!String.isBlank(this.evaluation.Resident_s_Communication_Status__c))
		selectedCommunications = this.evaluation.Resident_s_Communication_Status__c.split(';');
		
		if(!String.isBlank(this.evaluation.Resident_s_Emotional_Barriers__c))
		selectedBarriers = this.evaluation.Resident_s_Emotional_Barriers__c.split(';');
		
		if(!String.isBlank(this.evaluation.Resident_s_Learning_needs_related_to__c))
		selectedNeeds = this.evaluation.Resident_s_Learning_needs_related_to__c.split(';');
		
		if(!String.isBlank(this.evaluation.Oriented_to_the_Following__c))
		selectedOrients = this.evaluation.Oriented_to_the_Following__c.split(';');
		
		if(!String.isBlank(this.evaluation.Rancho_level_Resident_Orientation__c))
		selectedOrientations = this.evaluation.Rancho_level_Resident_Orientation__c.split(';');
		
		if(!String.isBlank(this.evaluation.Family_Member_s_Emotional_Barriers__c))
		selectedfambarriers = this.evaluation.Family_Member_s_Emotional_Barriers__c.split(';');
		
		if(!String.isBlank(this.evaluation.Family_Communication_Status__c))
		selectedFamcommunications = this.evaluation.Family_Communication_Status__c.split(';');
		
		if(!String.isBlank(this.evaluation.Family_Member_s_Learning_related_to__c))
		selectedFamlearnings = this.evaluation.Family_Member_s_Learning_related_to__c.split(';');
		
		if(!String.isBlank(this.evaluation.Diagnostics_GYN_Experiences__c))
		selectedExperiences = this.evaluation.Diagnostics_GYN_Experiences__c.split(';');
		
		if(!String.isBlank(this.evaluation.Orthopedic_diagnostic_types__c))
		selectedDiagnosis = this.evaluation.Orthopedic_diagnostic_types__c.split(';');
		
		if(!String.isBlank(this.evaluation.Orthopedic_Medications__c))
		selectedMedications = this.evaluation.Orthopedic_Medications__c.split(';');
		
		if(!String.isBlank(this.evaluation.Prosthetic_Types__c))
		selectedProsthetics = this.evaluation.Prosthetic_Types__c.split(';');
		
		if(!String.isBlank(this.evaluation.Orthodics_Types__c))
		selectedOrthodics = this.evaluation.Orthodics_Types__c.split(';');
		
		if(!String.isBlank(this.evaluation.Mood__c))
		selectedMoods = this.evaluation.Mood__c.split(';');
		
		if(!String.isBlank(this.evaluation.Alleviating_Factors__c))
		selectedAlleviators = this.evaluation.Alleviating_Factors__c.split(';');
		
		if(!String.isBlank(this.evaluation.Negative_Impact_on_ADLs__c))
		selectedAdls = this.evaluation.Negative_Impact_on_ADLs__c.split(';');
		
		if(!String.isBlank(this.evaluation.Manner_of_Expressing_Pain__c))
		selectedExpressions = this.evaluation.Manner_of_Expressing_Pain__c.split(';');
		
		if(!String.isBlank(this.evaluation.Neuro_Pain_Types__c))
		selectedPaintypes = this.evaluation.Neuro_Pain_Types__c.split(';');
		
		if(!String.isBlank(this.evaluation.Neuro_Pain_Alleviating_Factors__c))
		selectedpainAlleviators = this.evaluation.Neuro_Pain_Alleviating_Factors__c.split(';');
		
		if(!String.isBlank(this.evaluation.Neuro_Pain_neg_Impact_on_ADLs__c))
		selectedpainAdls = this.evaluation.Neuro_Pain_neg_Impact_on_ADLs__c.split(';');
		
		if(!String.isBlank(this.evaluation.Neuro_Pain_Manner_of_Exp__c))
		selectedpainExpressions = this.evaluation.Neuro_Pain_Manner_of_Exp__c.split(';');
		
		if(!String.isBlank(this.evaluation.Neuro_pain_Descriptors__c))
		selectedpainDescriptors = this.evaluation.Neuro_pain_Descriptors__c.split(';');
		
		
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
  			
  // For Hallucination Multi-Picklist
  		string hal ='';
  		for(string h: selectedHalls)
  		hal += h+';';
  			if(hal!=''){
  				hal = hal.Substring(0,hal.length()-1);
  				this.evaluation.Hallucination_Types__c = hal;
  			}
  			else
  			this.evaluation.Hallucination_Types__c ='';
  			
   // For Spiritual Belief Effects Multi-picklist
   		string blf = '';
   		for(string bf: selectedBeliefs)
   		blf += bf+';';
   			if(blf!=''){
   				blf= blf.Substring(0,blf.length()-1);
   				this.evaluation.Typeof_Spiritual_belief_Effects__c = blf;
   			}
   			else
   			this.evaluation.Typeof_Spiritual_belief_Effects__c ='';
   			
   // For Preferred Method of Learning Multi-Picklist
   		string pml ='';
   		for(string lm: selectedLearning)
   		pml += lm+';';
   			if(pml!=''){
   				pml= pml.Substring(0,pml.length()-1);
   				this.evaluation.Preferred_Method_of_Learning__c = pml;
   			}
   			else
   			this.evaluation.Preferred_Method_of_Learning__c ='';
   			
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
   			
  // For Resident's Communication Status Multi-Picklist
  		string cmc = '';
  		for(string cm: selectedCommunications)
  		cmc += cm+';';
  			if(cmc!=''){
  				cmc = cmc.Substring(0,cmc.length()-1);
  				this.evaluation.Resident_s_Communication_Status__c = cmc;
  			}
  			else
  			this.evaluation.Resident_s_Communication_Status__c = '';
  			
 // For Resident's Emotional Barriers Multi-picklist
 		string emb = '';
 		for(string eb: selectedBarriers)
 		emb += eb+';';
 			if(emb!=''){
 				emb = emb.Substring(0,emb.length()-1);
 				this.evaluation.Resident_s_Emotional_Barriers__c = emb;
 			}
 			else
 			this.evaluation.Resident_s_Emotional_Barriers__c ='';
 		
 // For Resident's Learning Needs multi-picklist
 		string lrn ='';
 		for(string ln: selectedNeeds)
 		lrn += ln+';';
 			if(lrn!=''){
 				lrn = lrn.Substring(0,lrn.length()-1);
 				this.evaluation.Resident_s_Learning_needs_related_to__c = lrn;
 			}
 			else
 			this.evaluation.Resident_s_Learning_needs_related_to__c ='';

// For Oriented to te following Multi-Picklist
		string ori ='';
		for(string ri: selectedOrients)
		ori += ri+';';
			if(ori!=''){
				ori = ori.Substring(0,ori.length()-1);
				this.evaluation.Oriented_to_the_Following__c = ori;
			}
			else
			this.evaluation.Oriented_to_the_Following__c ='';
 			
 // For Rancho level Orientation Multi-picklist
 		string rlo ='';
 		for(string lo: selectedOrientations)
 		rlo += lo+';';
 			if(rlo!=''){
 				rlo = rlo.Substring(0,rlo.length()-1);
 				this.evaluation.Rancho_level_Resident_Orientation__c = rlo;
 			}		
 			else
 			this.evaluation.Rancho_level_Resident_Orientation__c = '';
 			
 			
// For Family Member's emotional Barriers Multi-Picklist
		string fmb = '';
		for(string mb: selectedFambarriers)
		fmb += mb+';';
			if(fmb!=''){
				fmb = fmb.Substring(0,fmb.length()-1);
				this.evaluation.Family_Member_s_Emotional_Barriers__c = fmb;
			}
 			else
 			this.evaluation.Family_Member_s_Emotional_Barriers__c ='';
 			
 			
// For Family Communication Status Multi-Picklist
		string fmc ='';
		for(string mc: selectedFamcommunications)
		fmc += mc+';';
			if(fmc!=''){
				fmc = fmc.Substring(0,fmc.length()-1);
				this.evaluation.Family_Communication_Status__c = fmc;
			}
			else
			this.evaluation.Family_Communication_Status__c ='';
			
// For FamilyMember's learning related to Multi-Picklist
		string fsr = '';
		for(string fr: selectedFamlearnings)
		fsr += fr+';';
			if(fsr!=''){
				fsr = fsr.Substring(0,fsr.length()-1);
				this.evaluation.Family_Member_s_Learning_related_to__c = fsr;
			}
			else
			this.evaluation.Family_Member_s_Learning_related_to__c ='';
			
// For Diagnostics GYN Experiences Multi-Picklist
		string exp = '';
		for(string ex: selectedExperiences)
		exp += ex+';';
			if(exp!=''){
				exp = exp.Substring(0,exp.length()-1);
				this.evaluation.Diagnostics_GYN_Experiences__c = exp;
			}
			else
			this.evaluation.Diagnostics_GYN_Experiences__c ='';
			
			
// For Orthopedic Diagnosis Multi-Picklist
		string diag ='';
		for(string dg: selectedDiagnosis)
		diag += dg+';';
			if(diag!=''){
				diag = diag.Substring(0,diag.length()-1);
				this.evaluation.Orthopedic_diagnostic_types__c = diag;
				
			}
			else
			this.evaluation.Orthopedic_diagnostic_types__c = '';
			
// For Orthopedic Medications Multi-picklist
		string medic ='';
		for(string mdc: selectedMedications)
		medic += mdc+';';
			if(medic!=''){
				medic = medic.Substring(0,medic.length()-1);
				this.evaluation.Orthopedic_Medications__c = medic;
			}
			else
			this.evaluation.Orthopedic_Medications__c = '';
			
// For Prosthetic Type Multi-picklist
		string pros ='';
		for(string ps: selectedProsthetics)
		pros += ps+';';
			if(pros!=''){
				pros = pros.Substring(0,pros.length()-1);
				this.evaluation.Prosthetic_Types__c = pros;
			}
			else
			this.evaluation.Prosthetic_Types__c='';
			
// For Orthodics Types Multi-picklist
		string orth='';
		for(string ot: selectedOrthodics)
		orth += ot+';';
			if(orth!=''){
				orth = orth.Substring(0,orth.length()-1);
				this.evaluation.Orthodics_Types__c = orth;
			}
			else
			this.evaluation.Orthodics_Types__c ='';
			
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
			
// For Alleviating Factors Multi-picklist
		string alv='';
		for(string av: selectedAlleviators)
		alv += av+';';
			if(alv!=''){
				alv = alv.Substring(0,alv.length()-1);
				this.evaluation.Alleviating_Factors__c = alv;
			}
			else
			this.evaluation.Alleviating_Factors__c ='';
			
// For Negative Impact on ADLs Multi-picklist
		string adl='';
		for(string ad: selectedAlleviators)
		adl += ad+';';
			if(adl!=''){
				adl = adl.Substring(0,adl.length()-1);
				this.evaluation.Negative_Impact_on_ADLs__c = adl;
			}
			else
			this.evaluation.Negative_Impact_on_ADLs__c ='';
			
// For Manner of Expressing Pain Multi-picklist
		string exr='';
		for(string er: selectedExpressions)
		exr += er+';';
			if(exr!=''){
				exr = exr.Substring(0,exr.length()-1);
				this.evaluation.Manner_of_Expressing_Pain__c = exr;
			}
			else
			this.evaluation.Manner_of_Expressing_Pain__c ='';	
			
// For Nuero Pain type Multi-Picklist
		string npt='';
		for(string nt: selectedExpressions)
		npt += nt+';';
			if(npt!=''){
				npt = npt.Substring(0,npt.length()-1);
				this.evaluation.Neuro_Pain_Types__c = npt;
			}
			else
			this.evaluation.Neuro_Pain_Types__c ='';	
			
// For Neuro Pain Alleviating Factors Multi-picklist
		string npal='';
		for(string npl: selectedAlleviators)
		npal += npl+';';
			if(npal!=''){
				npal = npal.Substring(0,npal.length()-1);
				this.evaluation.Neuro_Pain_Alleviating_Factors__c = npal;
			}
			else
			this.evaluation.Neuro_Pain_Alleviating_Factors__c ='';
			
// For neuro pain Negative Impact on ADLs Multi-picklist
		string nadl='';
		for(string nad: selectedAlleviators)
		nadl += nad+';';
			if(nadl!=''){
				nadl = nadl.Substring(0,nadl.length()-1);
				this.evaluation.Neuro_Pain_neg_Impact_on_ADLs__c = nadl;
			}
			else
			this.evaluation.Neuro_Pain_neg_Impact_on_ADLs__c ='';
			
// For neuro pain Manner of Expressing Pain Multi-picklist
		string nexr='';
		for(string ner: selectedExpressions)
		nexr += ner+';';
			if(nexr!=''){
				nexr = nexr.Substring(0,nexr.length()-1);
				this.evaluation.Neuro_Pain_Manner_of_Exp__c = nexr;
			}
			else
			this.evaluation.Neuro_Pain_Manner_of_Exp__c ='';	
			
// For pain Descriptor Multi-picklist
		string decr='';
		for(string der: selectedExpressions)
		decr += der+';';
			if(decr!=''){
				decr = decr.Substring(0,decr.length()-1);
				this.evaluation.Neuro_pain_Descriptors__c = decr;
			}
			else
			this.evaluation.Neuro_pain_Descriptors__c ='';	
							
   					     	
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
   
   public List<selectoption> gethallValues(){
   		List<Selectoption> hallValue = Utility.getPicklistValues(evaluation, 'Hallucination_Types__c');
   		return hallValue; 
   }
   
   public List<selectoption> getbeliefValues(){
   		List<Selectoption> beliefValue = Utility.getPicklistValues(evaluation, 'Typeof_Spiritual_belief_Effects__c');
   		return beliefValue; 
   }
   
   public List<selectoption> getlearningValues(){
   		List<Selectoption> learningValue = Utility.getPicklistValues(evaluation, 'Preferred_Method_of_Learning__c');
   		return learningValue; 
   }
   
   public List<selectoption> getcopingValues(){
   		List<Selectoption> copingValue = Utility.getPicklistValues(evaluation, 'Resident_Demonstrating_Issues__c');
   		return copingValue; 
   }
   
   public List<selectoption> getcommunicationValues(){
   		List<Selectoption> communicationValue = Utility.getPicklistValues(evaluation, 'Resident_s_Communication_Status__c');
   		return communicationValue; 
   }
   
   public List<selectoption> getbarrierValues(){
   		List<Selectoption> barrierValue = Utility.getPicklistValues(evaluation, 'Resident_s_Emotional_Barriers__c');
   		return barrierValue; 
   }
   
   public List<selectoption> getneedValues(){
   		List<Selectoption> needValue = Utility.getPicklistValues(evaluation, 'Resident_s_Learning_needs_related_to__c');
   		return needValue; 
   }
   
   public List<selectoption> getorientValues(){
   		List<Selectoption> orientValue = Utility.getPicklistValues(evaluation, 'Oriented_to_the_Following__c');
   		return orientValue; 
   }
   
   public List<selectoption> getorientationValues(){
   		List<Selectoption> orientationValue = Utility.getPicklistValues(evaluation, 'Rancho_level_Resident_Orientation__c');
   		return orientationValue; 
   }
   
   public List<selectoption> getfambarrierValues(){
   		List<Selectoption> fambarrierValue = Utility.getPicklistValues(evaluation, 'Family_Member_s_Emotional_Barriers__c');
   		return fambarrierValue; 
   }
   
   public List<selectoption> getfamcommunicationValues(){
   		List<Selectoption> famcommunicationValue = Utility.getPicklistValues(evaluation, 'Family_Communication_Status__c');
   		return famcommunicationValue; 
   } 
   
   public List<selectoption> getfamlearningValues(){
   		List<Selectoption> famlearningValue = Utility.getPicklistValues(evaluation, 'Family_Member_s_Learning_related_to__c');
   		return famlearningValue; 
   } 
   
   public List<selectoption> getexperienceValues(){
   		List<Selectoption> experienceValue = Utility.getPicklistValues(evaluation, 'Diagnostics_GYN_Experiences__c');
   		return experienceValue; 
   } 
   
   public List<selectoption> getdiagnosisValues(){
   		List<Selectoption> diagnosisValue = Utility.getPicklistValues(evaluation, 'Orthopedic_diagnostic_types__c');
   		return diagnosisValue; 
   } 
   
   public List<selectoption> getmedicationValues(){
   		List<Selectoption> medicationValue = Utility.getPicklistValues(evaluation, 'Orthopedic_Medications__c');
   		return medicationValue; 
   } 
   
   public List<selectoption> getprostheticValues(){
   		List<Selectoption> prostheticValue = Utility.getPicklistValues(evaluation, 'Prosthetic_Types__c');
   		return prostheticValue; 
   } 
   
   public List<selectoption> getorthodicsValues(){
   		List<Selectoption> orthodicsValue = Utility.getPicklistValues(evaluation, 'Orthodics_Types__c');
   		return orthodicsValue; 
   }
   
   public List<selectoption> getmoodValues(){
   		List<Selectoption> moodValue = Utility.getPicklistValues(evaluation, 'Mood__c');
   		return moodValue; 
   }
   
   public List<selectoption> getalleviatorValues(){
   		List<Selectoption> alleviatorValue = Utility.getPicklistValues(evaluation, 'Alleviating_Factors__c');
   		return alleviatorValue; 
   }
   
   public List<selectoption> getadlValues(){
   		List<Selectoption> adlValue = Utility.getPicklistValues(evaluation, 'Negative_Impact_on_ADLs__c');
   		return adlValue; 
   }
   
   public List<selectoption> getexpressionValues(){
   		List<Selectoption> expressionValue = Utility.getPicklistValues(evaluation, 'Manner_of_Expressing_Pain__c');
   		return expressionValue; 
   }
   
   public List<selectoption> getpaintypeValues(){
   		List<Selectoption> paintypeValue = Utility.getPicklistValues(evaluation, 'Neuro_Pain_Types__c');
   		return paintypeValue; 
   }
   
   public List<selectoption> getpainalleviatorValues(){
   		List<Selectoption> painalleviatorValue = Utility.getPicklistValues(evaluation, 'Neuro_Pain_Alleviating_Factors__c');
   		return painalleviatorValue; 
   }
   
   public List<selectoption> getpainadlValues(){
   		List<Selectoption> painadlValue = Utility.getPicklistValues(evaluation, 'Neuro_Pain_neg_Impact_on_ADLs__c');
   		return painadlValue; 
   }
   
   public List<selectoption> getpainexpressionValues(){
   		List<Selectoption> painexpressionValue = Utility.getPicklistValues(evaluation, 'Neuro_Pain_Manner_of_Exp__c');
   		return painexpressionValue; 
   }
   
   public List<selectoption> getpaindescriptorValues(){
   		List<Selectoption> paindescriptorValue = Utility.getPicklistValues(evaluation, 'Neuro_Pain_Manner_of_Exp__c');
   		return paindescriptorValue; 
   }
   
   
   
   @RemoteAction
    public static Evaluation_Response__c addOrModifyAnnotation(ID annotationId, String source, Decimal x, Decimal y, Decimal Width, Decimal Height, String Shape, String Text, String evaluationId) {
        Evaluation_Response__c annotation;
        if (annotationId!=null) {
            annotation = [
                SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
            ];
        } else {
            annotation = new Evaluation_Response__c();
            annotation.Evaluation__c = evaluationId;
            annotation.RecordTypeId = source.contains('Neurotab') ? Utility.getEvaluationResponseRecordType('NeuroAnnotation'): Utility.getEvaluationResponseRecordType('Annotation');
        }
        annotation.Annotation_Height__c = Height;
        annotation.Annotation_Width__c = Width;
        annotation.Annotation_X__c = x;
        annotation.Annotation_Y__c = y;
        annotation.Annotation_Source__c = Source;
        annotation.Annotation_Shape__c = Shape;
        annotation.Annotation_Text__c = Text;
        System.debug('Annotation to upsert: ' + annotation);
        upsert annotation;
        return annotation;
    }
    
     
    @RemoteAction
    public static void deleteAnnotation(ID annotationId) {
        delete [
            SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
        ];
    }
    
     

}