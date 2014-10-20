public with sharing class NeuroEvaluationViewController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }

    public List<selectOption> hallValues {
        get {
            return Utility.getPicklistValues(evaluation, 'Hallucination_Types__c');
        }
        set;
    }
    public List<string> selectedHalls { get; set; }

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

    public NeuroEvaluationViewController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        // Put all the fields in context
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Evaluation__c.fields.getMap();
        evaluation = (Evaluation__c) stdController.getRecord();
        currentRelatedParty = new Related_Party__c();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
        serializedAnnotations = JSON.serialize(annotations);

        hallValues = new List<SelectOption>();
        selectedHalls = new List<String>();

        if(!String.isBlank(this.evaluation.Hallucination_Types__c)) {
            selectedHalls = this.evaluation.Hallucination_Types__c.split(';');
        }

        // Naming the PDF in case this controller is used for the PDF page
        String file = 'Person Being Referred- '+ this.evaluation.Referral__r.Person_Being_Referred__r.Full_Name__c+'.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        // Assigns the person being referred Name to the PDF dynamically
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+file);
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
}