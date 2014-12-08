public with sharing class CMShiftAssessmentView {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }

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

    public string getprimaryPhysician(){
        List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
        if(rp.size()>0) return rp[0].Name;
        else return null;
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

    public CMShiftAssessmentView(Apexpages.StandardController controller){
        this.stdController = controller;
        evaluation = (Evaluation__c) stdController.getRecord();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
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

    public Evaluation_Response__c currentVitalsDetail {get; set; }
    public Id currentVitalsDetailId { get; set; }

    public pageReference finalizeEval() {
        this.evaluation.Status__c = 'Final';
        update this.evaluation;
        pageReference backtoView = new pageReference('/apex/CMShiftAssessmentView?id='+this.evaluation.Id);
        backtoview.setRedirect(true);
        return backtoView;
    }

    public pageReference disregardEval() {
        this.evaluation.status__c = 'Disregard';
        update this.evaluation;
        pageReference backtoView = new pageReference('/apex/CMShiftAssessmentView?id='+this.evaluation.Id);
        backtoview.setRedirect(true);
        return backtoView;
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