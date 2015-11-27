public with sharing class CMShiftAssessmentEdit {
	public Evaluation__c evaluation { get; set; }
	public ApexPages.standardController stdController;
	public String selectedTab { get; set; }
	public String nextTab { get; set; }

	// The following 2 properties are used to deal with situations where we
	// want to use selectOptions for multi-checklist instead of the standard
	// Salesforce widget.
	public Map<String, List<selectOption>> selectOptionWidgetsMap { get; set; }
	public Map<String, List<String>> selectedOptionsMap { get; set; }

	//The following property is used to handle Tab Specific error Messages
	public Map<String,List<String>> errorMap { get; set; }

	public List<selectOption>copingValues;
	public List<string>selectedCoping { get; set; }
	public List<selectOption>neuroOrientValues;
	public List<string>selectedNeuroOrient{ get; set; }
	public List<selectOption>moodValues;
	public List<string>selectedMoods { get; set; }
	public List<SelectOption>breatheSounds;
	public List<string>selectedSounds { get ; set; }
	public List<SelectOption>DysreflexiaValues;
	public List<string>selectedDysreflexia { get ; set; }
	public List<selectOption>verbalExpressionValues;
	public List<string>selectedVerbalExpression { get; set; }
	public List<SelectOption>bowelValues ;
    public List<string>selectedBowel {get; set;}
	public List<SelectOption>bladderValues ;
    public List<string>selectedBladder {get; set;}

	public Evaluation_Response__c[] pains {
		get {
			if (pains == null) {
				pains = [
					SELECT ID, Initial_Pain_Level__c, Narrative_Note__c,
						Follow_up_Pain_Level__c, Follow_up_Effectiveness__c,
						Time_Observed__c
					FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
					AND RecordType.Name='Pain'
				];
				if (pains.size() == 0) {
					pains.add(new Evaluation_Response__c(
						RecordTypeId = Utility.getEvaluationResponseRecordType('Pain'),
						Initial_Pain_Level__c = 0,
						Follow_up_Pain_Level__c = 0,
						Evaluation__c = this.evaluation.Id
					));
				}
			}
			return pains;
		}
		set;
	}
	public List<String> painSliderOptions {
		get {
			if (painSliderOptions == null) {
				painSliderOptions = new String[] {
					'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'
				};
			}
			return painSliderOptions;
		}
		set;
	}

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

	public Evaluation_Response__c currentVitalsDetail { get; set; }
	public Id currentVitalsDetailId { get; set; }

	public Evaluation_Response__c[] pUlcers { set;
		get {
			return [
				SELECT ID,Decubity_Stage__c,Location__c, Decubity_Measurement__c,Treatment__c,Date__c
				FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
				AND RecordType.Name='Pressure Ulcer Detail'
			];
		}
	}

	public Evaluation_Response__c currentpUlcerDetail {get ; set;}
	public Id currentpUlcerDetailId {get; set; }

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

	public String serializedAnnotations { get; set; }

	public String baseUrl {
		get {
			return System.URL.getSalesforceBaseURL().toExternalForm();
		}
	}

	public string getprimaryPhysician(){
		List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
		if(rp.size()>0) return rp[0].Name;
		else return null;
	}

	public CMShiftAssessmentEdit(Apexpages.StandardController controller){
		this.stdController = controller;
		selectOptionWidgetsMap = new Map<String, List<selectOption>>{
			'nutrition_route__c' => new List<selectOption>(),
			'tongue__c' => new List<selectOption>(),
			'gums__c' => new List<selectOption>(),
			'cheeks__c' => new List<selectOption>(),
			'lips__c' => new List<selectOption>(),
			'breath__c' => new List<selectOption>(),
			'saliva__c' => new List<selectOption>(),
			'abdomen__c' => new List<selectOption>(),
			'elimination_bowel_status__c' => new List<selectOption>(),
			'urinary_issues__c' => new List<selectOption>(),
			'urine_clarity__c' => new List<selectOption>(),
			'dialysis_type__c' => new List<selectOption>(),
			'bowel_issue_type__c' => new List<selectOption>()
		};
		if (!Test.isRunningTest()) {
			// Make sure the multi-checkbox fields are always in scope
			List<String> fieldsToAdd = new List<String>();
			fieldsToAdd.addAll(selectOptionWidgetsMap.keySet());
			controller.addFields(fieldsToAdd);
		}
		evaluation = (Evaluation__c) stdController.getRecord();
		serializedAnnotations = JSON.serialize(annotations);

		selectedOptionsMap = new Map<String, List<String>>();
		for (String field: selectOptionWidgetsMap.keySet()) {
			selectOptionWidgetsMap.put(field, Utility.getPicklistValues(evaluation, field));
			if (!String.isBlank(String.valueOf(this.evaluation.get(field)))) {
				selectedOptionsMap.put(field, String.valueOf(this.evaluation.get(field)).split(';'));
			} else {
				selectedOptionsMap.put(field, new List<String>{''});
			}
		}

		// Exception: For Nutrition_Route__c, the picklist values are dependent
		// on the record type of the evaluation record, which Utility.getPicklistValues
		// does not account for. So we have to manually add them here
		selectOptionWidgetsMap.put('nutrition_route__c', new List<SelectOption>{
			new SelectOption('Oral', 'Oral'),
			new SelectOption('G-Tube', 'G-Tube'),
			new SelectOption('J-Tube', 'J-Tube'),
			new SelectOption('PEG', 'PEG'),
			new SelectOption('NG Tube', 'NG Tube'),
			new SelectOption('PPN', 'PPN'),
			new SelectOption('TPN', 'TPN'),
			new SelectOption('Bottle', 'Bottle')
		});

		errorMap = new Map<string, List<string>>();
		errorMap.put('demographicsTab', new List<string>{''});
		errorMap.put('diagnosticTab', new List<string>{''});
		errorMap.put('cardioTab', new List<string>{''});
		errorMap.put('nutritionTab', new List<string>{''});
		errorMap.put('skinBodyTab', new List<string>{''});
		errorMap.put('neuroTab', new List<string>{''});
		errorMap.put('orthoTab', new List<string>{''});
		errorMap.put('psychoSocialTab', new List<string>{''});

		currentVitalsDetail = new Evaluation_Response__c();
		currentpUlcerDetail = new Evaluation_Response__c();

		if (ApexPages.currentPage().getParameters().get('tab') != null) {
			selectedTab = ApexPages.currentPage().getParameters().get('tab');
		}
		
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
		verbalExpressionValues = new List<selectOption>();
		selectedVerbalExpression = new List<String>();
		bowelValues = new List<selectOption>();
        selectedBowel = new List<String>();
		bladderValues = new List<selectOption>();
        selectedBladder = new List<String>();


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

		if(!String.isBlank(this.evaluation.Expression_Other__c))
			selectedVerbalExpression = this.evaluation.Expression_Other__c.split(';');
			
		 if(!String.isBlank(this.evaluation.Elimination_Bowel_No_Continent_Appliance__c))
            selectedBowel = this.evaluation.Elimination_Bowel_No_Continent_Appliance__c.split(';');
			
		if(!String.isBlank(this.evaluation.Elimination_Bladder_No_Continent_Details__c))
            selectedBladder = this.evaluation.Elimination_Bladder_No_Continent_Details__c.split(';');
            	
		if(ApexPages.currentPage().getParameters().get('showErrors') == '1'){
			checkErrors();
		}
	}

	public void showAddVitalsDetail()  {
		this.currentVitalsDetail = new Evaluation_Response__c();
		this.currentVitalsDetail.Evaluation__c = this.evaluation.Id;
		this.currentVitalsDetail.RecordTypeId = Utility.getEvaluationResponseRecordType('Vitals Details Shift Assessment');

	}

	public void showEditVitalsDetail() {
		this.currentVitalsDetail = [
			SELECT ID, Name, Date__c, Temperature__c, R__c, O2_Saturation__c, Blood_Pressure__c,
                   Heart_Rate__c, HR_Intervention_Needed__c, HR_Narrative_Note__c, O2_Intervention_Needed__c, O2_Narrative_Note__c
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

	public void showAddpUlcerDetail()  {
		this.currentpUlcerDetail = new Evaluation_Response__c();
		this.currentpUlcerDetail.Evaluation__c = this.evaluation.Id;
		this.currentpUlcerDetail.RecordTypeId = Utility.getEvaluationResponseRecordType('Pressure Ulcer Detail');

	}

	public void showEditpUlcerDetail() {
		this.currentpUlcerDetail = [
			SELECT ID,Decubity_Stage__c,Location__c, Decubity_Measurement__c,Treatment__c,Date__c
			FROM Evaluation_Response__c WHERE ID=:currentpUlcerDetailId
		];
	}

	public void savepUlcerDetail() {
		try {
			upsert currentpUlcerDetail;
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
			this.evaluation.Mood__c = '';

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

		// For Other Verbal Expression Multi-picklist
		string exr='';
		for(string er: selectedVerbalExpression)
			exr += er+';';
		if(exr!=''){
			exr = exr.Substring(0,exr.length()-1);
			this.evaluation.Expression_Other__c = exr;
		}
		else
			this.evaluation.Expression_Other__c ='';
		
		//for Bowel incont Multi-picklist 
		string blr ='';       
        for(string c: selectedBowel){
        	blr += c+';';
        }	
        if(blr!=''){
            blr = blr.Substring(0,blr.length()-1);
            this.evaluation.Elimination_Bowel_No_Continent_Appliance__c= blr;
            
        }
        else
        this.evaluation.Elimination_Bowel_No_Continent_Appliance__c =''; 
		
		//for Bladder incont Multi-picklist
		string clr = '';         
       	for(string c: selectedBladder){
       		clr += c+';';	
       	}     
        if(clr!=''){
            clr = clr.Substring(0,clr.length()-1);
            this.evaluation.Elimination_Bladder_No_Continent_Details__c= clr;      
        }
        else
        this.evaluation.Elimination_Bladder_No_Continent_Details__c ='';
                

		// Saving the selected options for multi-checkbox fields
		for (String field: selectOptionWidgetsMap.keySet()) {
			String fieldValue = '';
			for (String selectOptionValue: selectedOptionsMap.get(field)) {
				fieldvalue += selectOptionValue + ';';
			}
			if (fieldValue != '') {
				fieldValue = fieldValue.substring(0, fieldValue.length() - 1);
			}
			this.evaluation.put(field, fieldValue);
		}

		this.evaluation.Diagnostics_Section_Completed__c = checkDiagnosis();
		this.evaluation.Cardio_Section_Completed__c = checkCardio();
		this.evaluation.Ortho_Section_Completed__c = checkOrtho();
		this.evaluation.Neuro_Section_Completed__c = checkNeuro();
		this.evaluation.Psycho_Social_Section_Completed__c = checkPsycho();
		this.evaluation.Nutrition_Section_Completed__c = checkNutrition();
		this.evaluation.Skin_Section_Completed__c = checkSkinBody();
		upsert this.pains;
		update this.evaluation;
		system.debug('whats in demo tab'+errorMap.get('demographicsTab'));
		return new PageReference('/apex/CMShiftAssessmentView?id=' + evaluation.Id + '&tab=' + selectedTab);
		
	}
	
	public void checkErrors(){
		checkDiagnosis();
		checkCardio();
		checkOrtho();
		checkNeuro();
		checkPsycho();
		checkNutrition();
		checkSkinBody();
	}

	public Boolean checkDiagnosis() {
		Boolean checkDiag = true;
		List<string> diagErrors = errorMap.get('diagnosticTab');
		diagErrors.clear();
		if(this.evaluation.Requires_Isolation_Picklist__c == null ) {
				checkDiag = false;
				diagErrors.add('Requires isolation is Mandatory');
		}
		else if(this.evaluation.Requires_Isolation_Picklist__c == 'Yes' && this.evaluation.DiagnosisIsolation_Type__c == null) {
			checkDiag = false;
			diagErrors.add('Isolation Type is Mandatory when Isolation is Required');

		}

		if(this.evaluation.IV_Site_Issues__c =='Yes' && this.evaluation.IV_Narrative_Note__c == '') {
			checkDiag = false;
			diagErrors.add('Narrative Note is required for IV Site issues');

		}
			return checkDiag;
	}

	public Boolean checkCardio() {
		Boolean cardio = true;
		List<String>cardioErrors = errorMap.get('cardioTab');
		cardioErrors.clear();

		// Cardio Section
		if(this.evaluation.Heart_Sounds__c == null) {
			cardio = false;
			cardioErrors.add('Heart Rate is Mandatory');
		}

		if(this.evaluation.Heart_Sounds__c == 'irregular' && this.evaluation.Heart_Intervention_Need_Picklist__c == null ) {
			cardio = false;
			cardioErrors.add('When Heart Rate is Irregular, Intervention needed is Mandatory');
		}

		if(this.evaluation.Heart_Intervention_Need_Picklist__c == 'Yes' && this.evaluation.Heart_Rate_Intervention_Describe__c == '' ) {
			cardio = false;
			cardioErrors.add('Heart Rate narrative note is required, when Intervention is needed');
		}

		if(this.evaluation.Peripheral_Pulses_Present__c == null) {
			cardio = false;
			cardioErrors.add('Peripheral pulses field is Mandatory');
		}

		if(this.evaluation.Peripheral_Pulses_Present__c == 'No' && this.evaluation.Peripheral_Pulses_Describe__c == null){
			cardio = false;
			cardioErrors.add('Description is mandatory for peripheral pulses.');
		}

		if(this.evaluation.Autonomic_Dysreflexia__c == null) {
			cardio = false;
			cardioErrors.add('Autonomic Dysrefelxia is Mandatory');

		}

		if(this.evaluation.Autonomic_Dysreflexia__c == 'Yes' && this.evaluation.Dysreflexia_issue_resolved__c == null) {
			cardio = false;
			cardioErrors.add('Autonomic Dysreflexia issue resolved field is Mandatory');
		}

		if(this.evaluation.Dysreflexia_issue_resolved__c == 'No' && this.evaluation.Dysreflexia_Issue_Describe__c == null){
			cardio = false;
			cardioErrors.add('Description is mandatory for Autonomic Dysreflexia issue.');
		}

		if(this.evaluation.Autonomic_Dysreflexia__c == 'Yes' && this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c == '') {
			cardio = false;
			cardioErrors.add('Please choose atleast one area that is assessed for Autonomic Dysreflexia');
		}

		//Suctioning Section
		if(this.evaluation.Suctioning_Picklist__c == null) {
			cardio = false;
			cardioErrors.add('Suctioning field is mandatory');
		}

		//Trach Section
		if(this.evaluation.Trach_Picklist__c == null) {
			cardio= false;
			cardioErrors.add('Trach field is mandatory');
		}

		if(this.evaluation.Trach_Picklist__c == 'Yes') {

			if(this.evaluation.Trach_Type__c == null) {
				cardio= false;
				cardioErrors.add('Trach type is mandatory');
			}

			if(this.evaluation.Trach_Type__c == 'Other' && this.evaluation.Trach_Type_Other__c == null) {
				cardio= false;
				cardioErrors.add('Please mention the other trach type');
			}

			if(this.evaluation.Trach_Size__c == null) {
				cardio= false;
				cardioErrors.add('Trach size is mandatory');
			}

			if(this.evaluation.Trach_Size__c == 'Other' && this.evaluation.Trach_Size_Other__c == null) {
				cardio= false;
				cardioErrors.add('Please mention the other trach size');
			}

			if(this.evaluation.PMV_Picklist__c == null) {
				cardio= false;
				cardioErrors.add('PMV field is mandatory');

			}
		}

		//O2 Section
		if(this.evaluation.O2_Picklist__c == null ){
			cardio = false;
			cardioErrors.add('O2 field is mandatory');
		}

		if(this.evaluation.O2_Picklist__c == 'Yes'){
			if(this.evaluation.O2_Intervention_Needed__c == null) {
				cardio = false;
				cardioErrors.add('O2 Intervention needed field is mandatory');

			}

			if(this.evaluation.O2_Documentation_Required__c == null){
				cardio= false;
				cardioErrors.add('O2 Documentation required field is mandatory');
			}
		}

		//Ventilator Section
		if(this.evaluation.Ventilator_Picklist__c == null) {
			cardio = false;
			cardioErrors.add('Ventilator field is mandatory');
		}

		if(this.evaluation.Ventilator_Picklist__c == 'Yes'){
			if(this.evaluation.Ventilator_Type__c == null){
				cardio = false;
				cardioErrors.add('Ventilator type is mandatory');
			}

			if(this.evaluation.Ventilator_Type__c == 'Intermittent' && this.evaluation.If_Intermittent_Schedule__c == null) {
				cardio = false;
				cardioErrors.add('Ventilator schedule is mandatory when the type is intermittent');
			}
		}
		return cardio;
	}

	public Boolean checkNutrition() {
		Boolean nutrition = true;
		List<string> nutritionErrors = errorMap.get('nutritionTab');
		nutritionErrors.clear();
		
		if(this.evaluation.nutrition_route__c == null || this.evaluation.nutrition_route__c == ''){
			nutrition = false;
			nutritionErrors.add('Please Choose atleast one Feeding type');
		}

		if(this.evaluation.Oral_Health_Check__c == null){
			nutrition = false;
			nutritionErrors.add('Oral health check is mandatory');
		}

		if(this.evaluation.Oral_Health_Check__c == 'Yes' && this.evaluation.Issues_Noted__c == null){
			nutrition = false;
			nutritionErrors.add('Oral issues noted field is mandatory');
		}

		if(this.evaluation.Issues_Noted__c == 'Yes') {
			if(this.evaluation.tongue__c == '') {
				nutrition = false;
				nutritionErrors.add('Please Choose atleast one check box for tongue');
			}

			if(this.evaluation.Gums__c == '') {
				nutrition = false;
				nutritionErrors.add('Please Choose atleast one check box for Gums');
			}

			if(this.evaluation.Cheeks__c == '') {
				nutrition = false;
				nutritionErrors.add('Please Choose atleast one check box for Cheeks');
			}

			if(this.evaluation.Lips__c == '') {
				nutrition = false;
				nutritionErrors.add('Please Choose atleast one check box for Lips');
			}

			if(this.evaluation.Saliva__c == '') {
				nutrition = false;
				nutritionErrors.add('Please Choose atleast one check box for Saliva');
			}
			
			if(this.evaluation.Teeth_Problems__c == null){
				nutrition = false;
				nutritionErrors.add('Teeth Problems field is mandatory');
			}
			
			if(this.evaluation.breath__c == ''){
				nutrition = false;
				nutritionErrors.add('Please choose atleast one checkbox for Breath');
			}

			if(this.evaluation.Narrative_Note__c == '') {
				nutrition = false;
				nutritionErrors.add('Narrative note is mandatory');
			}
		}

		if(this.evaluation.PEDS_History_of_Tonsils__c == 'Yes' && this.evaluation.PEDS_Tonsil_History_Describe__c == null) {
			nutrition = false;
			nutritionErrors.add('Tonsils history is Mandatory');

		}

		if(this.evaluation.RUQ__c == 'Abnormal' && this.evaluation.RUQ_Describe__c == null) {
			nutrition = false;
			nutritionErrors.add('RUQ Description is Mandatory');

		}

		if(this.evaluation.LUQ__c == 'Abnormal' && this.evaluation.LUQ_Describe__c == null) {
			nutrition = false;
			nutritionErrors.add('LUQ Descritption is Mandatory');

		}

		if(this.evaluation.RLQ__c == 'Abnormal' && this.evaluation.RLQ_Describe__c == null) {
			nutrition = false;
			nutritionErrors.add('RLQ Description is Mandatory');

		}

		if(this.evaluation.LLQ__c == 'Abnormal' && this.evaluation.LLQ_Describe__c == null) {
			nutrition = false;
			nutritionErrors.add('LLQ Description is Mandatory');

		}
		
		if(this.evaluation.Weight_picklist__c == 'Yes' && this.evaluation.WeightKg__c == null) {
			nutrition = false;
			nutritionErrors.add('Please enter Weight information');
		}
		
		if(this.evaluation.Bowel_Continence__c == null) {
			nutrition = false;
			nutritionErrors.add('Bowel Continence field is Mandatory');
		}
		
		if(this.evaluation.Bowel_Continence__c == 'Incontinent' && this.evaluation.Elimination_Bowel_No_Continent_Appliance__c == ''){
			nutrition = false;
			nutritionErrors.add('Please choose atleast one device for Bowel Continence');
		}

		if(this.evaluation.Bowel_Issues__c == null) {
			nutrition = false;
			nutritionErrors.add('Bowel issues field is Mandatory');
		}
		
		if(this.evaluation.Bowel_Issues__c == 'Yes') {
			if(this.evaluation.bowel_issue_type__c == '') {
				nutrition = false;
				nutritionErrors.add('Please choose atleast one Bowel issue type');

			}

			if(this.evaluation.Bowel_Issues_Additional_Information__c == null) {
				nutrition = false;
				nutritionErrors.add('Bowel issues additional information is Mandatory');
			}

		}
		
		if(this.evaluation.Bladder_Continence__c == null){
			nutrition = false;
			nutritionErrors.add('Bladder Continence field is mandatory');
		}
		
		if(this.evaluation.Bladder_Continence__c == 'Incontinent' && this.evaluation.Elimination_Bladder_No_Continent_Details__c == '') {
			nutrition = false;
			nutritionErrors.add('Please choose atleast one device for Bladder Continence');
		}
		
		if(this.evaluation.Urinary_Issues_Checkbox__c == null){
			nutrition = false;
			nutritionErrors.add('Urinary issues field is mandatory');	
		}
		
		if(this.evaluation.Urinary_Issues_Checkbox__c == 'Yes') {
			if(this.evaluation.urinary_issues__c == '') {
				nutrition = false;
				nutritionErrors.add('Urinary Issue type is mandatory');
			}
			
			if(this.evaluation.Urine_Color__c == null ) {
				nutrition = false;
				nutritionErrors.add('Urine Color is mandatory');
			}
			
			if(this.evaluation.urine_clarity__c == null ) {
				nutrition = false;
				nutritionErrors.add('Urinary Clarity is mandatory');
			}
			
			if(this.evaluation.Urine_Odor__c == null ) {
				nutrition = false;
				nutritionErrors.add('Urinary odor is mandatory');
			}
			
		}
		
		if(this.evaluation.Dialysis_Picklist__c == null) {
			nutrition = false;
			nutritionErrors.add('Dialysis field is mandatory');
		}
		
		if(this.evaluation.Dialysis_Picklist__c == 'Yes' && this.evaluation.dialysis_type__c == '') {
			nutrition = false;
			nutritionErrors.add('Dialysis type is mandatory');
		}

		return nutrition;
	}
	public Boolean checkSkinBody() {
		Boolean skin = true;
		List<string> skinbodyErrors = errorMap.get('skinBodyTab');
		skinbodyErrors.clear();

		if(this.evaluation.Skin_Color__c == null) {
			skin = false;
			skinbodyErrors.add('Color is Mandatory');
		}
		if(this.evaluation.Skin_Temperature__c == null) {
			skin = false;
			skinbodyErrors.add('Temperature is Mandatory');
		}
		if(this.evaluation.Skin_Moisture__c == null) {
			skin = false;
			skinbodyErrors.add('Moisture is Mandatory');
		}
		if(this.evaluation.Skin_Turgor__c == null) {
			skin = false;
			skinbodyErrors.add('Turgor is Mandatory');
		}
		if(this.evaluation.Skin_Behavior__c == null) {
			skin = false;
			skinbodyErrors.add('Behavior is Mandatory');
		}
		if(this.evaluation.Skin_Edema__c == null) {
			skin = false;
			skinbodyErrors.add('Edema is Mandatory');
		}
		if(this.evaluation.Skin_Edema__c == 'Yes') {
			if(this.evaluation.Skin_Edema_Location__c == null) {
				skin = false;
				skinbodyErrors.add('Edema Location is Mandatory');
			}
			if(this.evaluation.Skin_Edema_Pitting__c == null) {
				skin = false;
				skinbodyErrors.add('Edema Pitiing is Mandatory');
			}
		}

		if(this.evaluation.Skin_Intact_Picklist__c == null){
			skin = false;
			skinbodyErrors.add('Skin Intact field is mandatory');
		}
		return skin;
	}

	public Boolean checkNeuro() {
		Boolean neuro = true;
		List<string> neuroErrors = errorMap.get('neuroTab');
		neuroErrors.clear();
		
		if(this.evaluation.Cognition_Intact__c == null) {
			neuro = false;
			neuroErrors.add('Cognition Intact field is Mandatory');
			
		}
		
		if(this.evaluation.Cognition_Intact__c == 'No') {
			
			if(this.evaluation.Rancho_Level__c == null) {
				neuro = false;
				neuroErrors.add('Rancho level is Mandatory');
			}
			
			if(this.evaluation.Level_of_Conciousness__c == null){
				neuro = false;
				neuroErrors.add('Level of Conciousness is Mandatory');
			}
			
		}
		
		if((this.evaluation.Cognition_Intact__c == 'Yes' || (this.evaluation.Rancho_Level__c != null && this.evaluation.Rancho_Level__c != '(1) No Response'))&& !(this.evaluation.Cooperative__c || this.evaluation.Impulsive__c || this.evaluation.Inappropriate__c || this.evaluation.Agitated__c || this.evaluation.Combative__c || this.evaluation.Confused__c || this.evaluation.Unresponsive__c)){
				neuro = false;
				neuroErrors.add('Please atleast one checkbox for Behavior');
		}

		if(this.evaluation.Rancho_Level__c != null && this.evaluation.Rancho_Level__c != '(1) No Response' ) {
			
			if(this.evaluation.Orientation__c == '') {
				neuro = false;
				neuroErrors.add('Please atleast one checkbox for Orientation');
				
			}
			
			if(!(this.evaluation.Verbal_Stim__c || this.evaluation.Auditory_Stim__c || this.evaluation.Tactile_Stim__c || this.evaluation.Responds_To_Pain__c || this.evaluation.Visual__c)) {
				neuro = false;
				neuroErrors.add('Please atleast one checkbox for Responds to');
				
			}
			
		}
			
		if(this.evaluation.Mood__c == '') {
			neuro = false;
			neuroErrors.add('Please choose atleast one checkbox for Mood');
		}

		if( this.evaluation.Mood__c != null) {
				
			if((this.evaluation.Mood__c.Contains('Sad') || this.evaluation.Mood__c.Contains('Flat')) && evaluation.Desire_to_hurt_themselves__c == null ) {
				neuro = false;
				neuroErrors.add('Has Resident Expressed Desire to Hurt Him/Herself? field is mandatory when mood is flat or sad');
			}

			if(this.evaluation.Desire_to_hurt_themselves__c =='Yes' && this.evaluation.Plan_to_Harm_themselves__c == null) {
				neuro = false;
				neuroErrors.add('Does Resident Have a Plan to Harm Him/Herself? is mandatory');
			}

		}

		if( this.evaluation.Able_to_make_Needs_Known__c == null) {
			neuro = false;
			neuroErrors.add('Ability to make needs known field is mandatory');
		}

		if(this.evaluation.Able_to_make_Needs_Known__c == 'No' && this.evaluation.Expression__c == null) {
			neuro = false;
			neuroErrors.add('Expression field is mandatory');
		}

		if(this.evaluation.Expression__c == 'Non-Verbal' && this.evaluation.Expression_Other__c == '') {
			neuro = false;
			neuroErrors.add('Please choose other expression when expression is non-verbal');
		}

		if(this.evaluation.Safety_Awareness__c == null){
			neuro = false;
			neuroErrors.add('Safety awareness is mandatory');

		}
		
		if(this.evaluation.Pain_Present__c == null){
			neuro = false;
			neuroErrors.add('Pain Present field is mandatory');
			
		}
		return neuro;
	}

	public Boolean checkOrtho() {
		Boolean ortho = true;
		List<String> orthoErrors = errorMap.get('orthoTab');
		orthoErrors.clear();

		if(this.evaluation.Cast_Picklist__c == null) {
			ortho = false;
			orthoErrors.add('Cast field is Mandatory');
		}

		if(this.evaluation.Cast_Picklist__c == 'Yes' && this.evaluation.Ortho_Cast_Location__c == null) {
			ortho = false;
			orthoErrors.add('Cast location field is mandatory');
		}

		if(this.evaluation.Ortho_Cast_Location__c == 'Other' && this.evaluation.Cast_Location__c == null) {
			ortho = false;
			orthoErrors.add('Please mention the other value for Cast location');
		}

		if(this.evaluation.External_Device_Picklist__c == null) {
			ortho = false;
			orthoErrors.add('External devices field is mandatory');
		}

		if(this.evaluation.External_Device_Picklist__c == 'Yes' && this.evaluation.External_Devices_Location__c == null) {
			ortho = false;
			orthoErrors.add('External devices location is mandatory');
		}

		if(this.evaluation.External_Device_Picklist__c == 'Yes' && this.evaluation.External_Devices_Type__c == null) {
			ortho = false;
			orthoErrors.add('External devices type is mandatory');
		}

		if(this.evaluation.Traction_Picklist__c == null) {
			ortho = false;
			orthoErrors.add('Traction field is mandatory');
		}

		if(this.evaluation.Traction_Picklist__c == 'Yes') {

			if(this.evaluation.Traction_Location__c == null) {
				ortho = false;
				orthoErrors.add('Traction Location is mandatory');

			}

			if(this.evaluation.Traction_Type__c == null) {
				ortho = false;
				orthoErrors.add('Traction type is mandatory');

			}

			if(this.evaluation.Traction_Weight__c == null) {
				ortho = false;
				orthoErrors.add('Traction weight is mandatory');

			}
		}

		return ortho;

	}

	public Boolean checkPsycho() {
		Boolean checkPsych = true;
		List<String>psychErrors = errorMap.get('psychoSocialTab');
		psychErrors.clear();
		if(this.evaluation.Resident_Coping_Well__c == null) {
			checkPsych = false;
			psychErrors.add('Resident coping well is mandatory');

		}
		if(this.evaluation.Resident_Coping_Well__c == 'No' && this.evaluation.Coping_Description__c == null) {
			checkPsych = false;
			psychErrors.add('Description is Mandatory when resident is not coping well');
		}

		return checkPsych;
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

	public List<SelectOption> getbreatheSounds() {
		List<Selectoption> breatheSound = Utility.getPicklistValues(evaluation, 'Breathe_Sounds__c');
		return breatheSound;

	}

	public List<SelectOption> getDysreflexiaValues(){
		List<Selectoption> DysreflexiaValue = Utility.getPicklistValues(evaluation, 'Autonomic_Dysreflexia_Areas_Assessed__c');
		return DysreflexiaValue;

	}

	public List<selectoption> getverbalExpressionValues() {
		List<Selectoption> expressionValue = Utility.getPicklistValues(evaluation, 'Expression_Other__c');
		return expressionValue;
	}
	
   public List<selectoption> getbowelValues(){
            List<Selectoption> bowelValue = Utility.getPicklistValues(evaluation, 'Elimination_Bowel_No_Continent_Appliance__c');
            return bowelValue; 
   }
	
   public List<selectoption> getbladderValues(){
            List<Selectoption> bladderValue = Utility.getPicklistValues(evaluation, 'Elimination_Bladder_No_Continent_Details__c');
            return bladderValue; 
   }

	public PageReference addPainResponse() {
		pains.add(new Evaluation_Response__c(
			RecordTypeId = Utility.getEvaluationResponseRecordType('Pain'),
			Initial_Pain_Level__c = 0,
			Follow_up_Pain_Level__c = 0,
			Evaluation__c = this.evaluation.Id
		));
		return null;
	}

	public PageReference updatePainResponses() {
		if (evaluation.Pain_Present__c == null || evaluation.Pain_Present__c == '' || evaluation.Pain_Present__c == 'No') {
			List<Evaluation_Response__c> entriesToDelete = new List<Evaluation_Response__c>();
			for (Evaluation_Response__c pain: pains) {
				// We have to exclude some records because they can't be
				// deleted (as they're not on the server yet). They'll be
				// garbage collected afterwards anyway.
				if (pain.Id != null) {
					entriesToDelete.add(pain);
				}
			}
			delete entriesToDelete;
			pains = null;
		}
		return null;
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
			annotation.RecordTypeId = Utility.getEvaluationResponseRecordType('Annotation');
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
	
	@RemoteAction
	public static void clearAnnotations(Id evalId) {
		delete [SELECT Id FROM Evaluation_Response__c WHERE Evaluation__c =:evalId AND RecordType.Name = 'Annotation' 
		];
		
	}
}