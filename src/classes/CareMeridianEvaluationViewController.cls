public with sharing class CareMeridianEvaluationViewController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
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

    public List<String> sliderOptions { set;
        get {
            if (sliderOptions == null) {
                sliderOptions = new String[] {
                    '', 'Dependent', 'Max Assist', 'Moderate Assist',
                    'Minimum Assist', 'CGA', 'Supervised', 'Independent'
                };
            }
            return sliderOptions;
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

    public CareMeridianEvaluationViewController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        // Put all the fields in context
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Evaluation__c.fields.getMap();
        evaluation = (Evaluation__c) stdController.getRecord();
        serializedAnnotations = JSON.serialize(annotations);
        currentRelatedParty = new Related_Party__c();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
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