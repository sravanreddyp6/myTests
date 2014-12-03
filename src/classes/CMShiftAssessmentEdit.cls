public with sharing class CMShiftAssessmentEdit {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }

    public Boolean showResidenthurt{ get; set; }

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
            'saliva__c' => new List<selectOption>(),
            'dentures_type__c' => new List<selectOption>(),
            'abdomen__c' => new List<selectOption>(),
            'elimination_bowel_status__c' => new List<selectOption>(),
            'urinary_issues__c' => new List<selectOption>(),
            'urine_clarity__c' => new List<selectOption>(),
            'dialysis_type__c' => new List<selectOption>()
        };
        if (!Test.isRunningTest()) {
            // Make sure the multi-checkbox fields are always in scope
            List<String> fieldsToAdd = new List<String>();
            fieldsToAdd.addAll(selectOptionWidgetsMap.keySet());
            controller.addFields(fieldsToAdd);
        }
        evaluation = (Evaluation__c) stdController.getRecord();

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
        verbalExpressionValues = new List<selectOption>();
        selectedVerbalExpression = new List<String>();


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
        this.evaluation.Psycho_Social_Section_Completed__c = checkPsycho();
		
        update this.evaluation;
        return new PageReference('/apex/CMShiftAssessmentView?id=' + evaluation.Id + '&tab=' + selectedTab);
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
    
    public Boolean checkPsycho() {
    	Boolean checkPsych = true;
    	if(this.evaluation.Resident_Coping_Well__c == 'No' && this.evaluation.Coping_Description__c == null) {
    		checkPsych = false;
    	}
    	
    	return checkPsych;
    }
    
    public Boolean checkCardio() {
    	Boolean cardio = true;
    	List<String>cardioErrors = errorMap.get('cardioTab');
    	cardioErrors.clear();
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
    	
    	return cardio;
    }
    
    public Boolean checkOrtho() {
    	Boolean ortho = true;
    	List<String> orthoErrors = errorMap.get('orthoTab');
    	
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
}