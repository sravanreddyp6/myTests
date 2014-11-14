public with sharing class NeuroEvaluationViewController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }
    public transient Map<String, Component.Apex.OutputPanel> ctlMap { get; set; }
    public String bodyMapUrl {
        get {
            Attachment[] attachments = [
                SELECT Id FROM Attachment
                WHERE ParentId=:evaluation.Referral__c
                  AND Name='BodyMarkup.png'
            ];
            if (attachments.size() > 0) {
                return '/servlet/servlet.FileDownload?file=' + attachments[0].Id;
            }
            return null;
        }
    }

    public List<String> painsliderOptions {
        get {
            if (painsliderOptions == null) {
                painsliderOptions = new String[] {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'
                };
            }
            return painsliderOptions;
        }
        set;
    }

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
    public Boolean canUpdateEvaluation {
        get {
            return Schema.sObjectType.Evaluation__c.isUpdateable();
        }
    }

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
        if (!Test.isRunningTest()) {
            List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects(new List<String>{ 'Evaluation__c' });
            Schema.DescribeSObjectResult info = describelist[0];
            Map<string,Schema.SObjectField> fmap = info.fields.getmap();
            stdController.addFields(new List<String>(fmap.keySet()));
        }
        evaluation = (Evaluation__c) stdController.getRecord();
        currentRelatedParty = new Related_Party__c();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
        serializedAnnotations = JSON.serialize(annotations);

        hallValues = new List<SelectOption>();
        selectedHalls = new List<String>();

        if(!String.isBlank(this.evaluation.Hallucination_Types__c)) {
            selectedHalls = this.evaluation.Hallucination_Types__c.split(';');
        }
        ctlMap = CreateFieldControls( stdController.getRecord().getSObjectType().getDescribe().getName(), stdController );

        // Naming the PDF in case this controller is used for the PDF page
        String file = 'Person Being Referred - '+ this.evaluation.Referral__r.Person_Being_Referred__r.Full_Name__c+'.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        // Assigns the person being referred Name to the PDF dynamically
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');
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

    public Map<String, Component.Apex.OutputPanel> CreateFieldControls ( string classname, ApexPages.StandardController controller ) {
        System.Debug('loading map for:' + classname);
        Map<String, Component.Apex.OutputPanel> cmap = new Map<String, Component.Apex.OutputPanel>();

        List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects( new List<String>{classname});
        if (describelist.size() == 0){
            return null;
        }

        // need to get value for all fields - they are not in scope from VF page being dynamic
        Schema.DescribeSObjectResult info = describelist[0];
        Map<string,Schema.SObjectField> fmap = info.fields.getmap();

        Schema.DescribeFieldResult fielddescribe;
        ID theID = controller.getID();
        String query = 'SELECT ' +  String.Join(New List<String>(fmap.keyset()), ', ') + ' FROM ' + className + ' Where ID = :theID';
        system.debug( query );
        SObject fullobj  = Database.query(query);

        for(string fieldname:fmap.keyset()){
            Component.Apex.OutputPanel op = new Component.Apex.OutputPanel();

            fielddescribe = fmap.get(fieldname).getdescribe();

            try {
                Component.Apex.OutputLabel outLbl = new Component.Apex.OutputLabel( value=fielddescribe.getLabel(), styleClass='label');
                op.childComponents.Add( outLbl);
                Component.Apex.OutputField outFld = new Component.Apex.OutputField();
                outFld.expressions.value = '{!' + classname + '.' + fieldname +'}';
                op.childComponents.Add( outFld);
                cmap.put( fieldname, op);
            }
            catch( Exception e) {
                System.Debug( e );
            }
        }
        return cmap;
    }
}