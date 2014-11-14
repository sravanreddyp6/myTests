public with sharing class NeuroEvaluationEditController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }

    public List<String> dummyString{ get; set; }
    public List<string>selectedHalls {get;set;}
    public List<SelectOption> hallValues {
        get {
            return Utility.getPicklistValues(evaluation, 'Hallucination_Types__c');
        }
        set;
    }

    public Related_Party__c[] relatedParties { set;
        get {
            return [
                SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                       Phone_2__c, Phone_2_Type__c, Comments__c
                FROM Related_Party__c WHERE Person_Being_Referred__c=:evaluation.Referral__r.Person_Being_Referred__c
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
    public Person_Being_Referred__c pbr { get; set; }  // Here to save DOB
    public Referral__c ref { get; set; } //to update Primary and Secondary Diagnosis

    public List<SelectOption> painAlleviatorValues {
        get {
            painAlleviatorValues = Utility.getPicklistValues(evaluation, 'Neuro_Pain_Alleviating_Factors__c');
            return painAlleviatorValues;
        }
        set;
    }
    public List<String> selectedPainAlleviators { get; set; }


    public List<String> mobilitySliderOptions { set;
        get {
            if (mobilitySliderOptions == null) {
                mobilitySliderOptions = new String[] {
                    'Unknown', 'Total Assist', 'Max Assist', 'Moderate Assist',
                    'Minimum Assist', 'Setup', 'Modified', 'Independent'
                };
            }
            return mobilitySliderOptions;
        }
    }

    public List<String> selfCareSliderOptions { set;
        get {
            if (selfCareSliderOptions == null) {
                selfCareSliderOptions = new String[] {
                    'Unknown', 'Total Assist', 'Max Assist', 'Moderate Assist',
                    'Minimum Assist', 'Setup', 'Modified', 'Independent'
                };
            }
            return selfCareSliderOptions;
        }
    }

    public List<String> communicationSliderOptions { set;
        get {
            if (communicationSliderOptions == null) {
                communicationSliderOptions = new String[] {
                    'Unknown', 'Severe', 'Moderate', 'Mild', 'No Deficit'
                };
            }
            return communicationSliderOptions;
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
    public String serializedAnnotations { get; set; }

    public NeuroEvaluationEditController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        evaluation = (Evaluation__c) stdController.getRecord();
        serializedAnnotations = JSON.serialize(annotations);
        currentRelatedParty = new Related_Party__c();
        pbr = [
            SELECT ID, Date_of_Birth__c FROM Person_Being_Referred__c
            WHERE Id=:evaluation.Referral__r.Person_Being_Referred__c
        ];
        ref = [
            SELECT Id, Primary_Diagnosis__c,Secondary_Diagnosis__c,Date_of_Injury__c FROM Referral__c
            WHERE Id=:evaluation.Referral__c
        ];
        if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        }
        dummyString = new List<String>();
        selectedHalls = new List<String>();

        if(!String.isBlank(this.evaluation.Hallucination_Types__c)) {
            selectedHalls = this.evaluation.Hallucination_Types__c.split(';');
        }

        painAlleviatorValues = new List<selectOption>();
        selectedpainAlleviators = new List<String>();
        if(!String.isBlank(this.evaluation.Neuro_Pain_Alleviating_Factors__c)) {
            selectedPainAlleviators = this.evaluation.Neuro_Pain_Alleviating_Factors__c.split(';');
        }
    }

    public void showAddRelatedParty() {
        this.currentRelatedParty = new Related_Party__c();
        this.currentRelatedParty.Person_Being_Referred__c = this.evaluation.Referral__r.Person_Being_Referred__c;
        this.currentRelatedParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(new Referral__c(Id=this.evaluation.Referral__c));
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
        if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {

        }
        // Hallucination type multi-picklist
        string hal ='';
        for (string h: selectedHalls) {
            hal += h + ';';
        }
        if (hal!='' && this.evaluation.Hallucinations__c){
            hal = hal.Substring(0,hal.length()-1);
            this.evaluation.Hallucination_Types__c = hal;
        }
        else {
            this.evaluation.Hallucination_Types__c ='';
        }
        string npal='';
        for(string npl: selectedPainAlleviators) {
            npal += npl+';';
        }
        if(npal!='' && this.evaluation.Pain_Present__c == 'Yes') {
            npal = npal.Substring(0, npal.length() - 1);
            this.evaluation.Neuro_Pain_Alleviating_Factors__c = npal;
        } else {
            this.evaluation.Neuro_Pain_Alleviating_Factors__c ='';
        }
        update this.evaluation;
        update this.pbr;

        return new PageReference('/apex/NeuroEvaluationView?id=' + evaluation.Id + '&tab=' + selectedTab);
    }

}