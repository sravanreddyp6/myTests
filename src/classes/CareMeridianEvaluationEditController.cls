public with sharing class CareMeridianEvaluationEditController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
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
    public Referral__c ref {get; set; } //to update Primary and Secondary Diagnosis

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

    public CareMeridianEvaluationEditController(ApexPages.standardController stdController) {
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
    
    public pageReference reDirect() {
        PageReference returnURL;
        if(this.evaluation.RecordTypeId == Utility.getEValuationRecordType('NursesAssessment')) {
	        returnURL = new PageReference ('/apex/NursingEvaluationEdit?id='+evaluation.id);
	      	system.debug('UUUUUUUUUUUUUURRRRRRRRRRRRRRRRRRRRLLLLLLLLLLLLLLLLLLL'+returnURL);
	        return returnURL;
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
        update this.evaluation;
        update this.pbr;
        
        if(ref.Primary_Diagnosis__c != evaluation.Primary_Diagnosis__c || ref.Secondary_Diagnosis__c != evaluation.Secondary_Diagnosis__c || ref.Date_of_Injury__c != evaluation.Date_of_Injury_Onset__c ){
        	ref.Primary_Diagnosis__c = evaluation.Primary_Diagnosis__c;
	        ref.Secondary_Diagnosis__c = evaluation.Secondary_Diagnosis__c;
	        ref.Date_of_Injury__c = evaluation.Date_of_Injury_Onset__c;
	        
	        update this.ref;
	        
        }
        //return stdController.view();
        return new PageReference('/apex/CareMeridianEvaluationView?id=' + evaluation.Id + '&tab=' + selectedTab);
    }

}