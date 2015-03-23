public with sharing class EvaluationResponseTableController {
    public Integer numCols {get; set;}
    public Integer numRows {get; set;}
    public Boolean hasError {get; set;}
    public list<string> reqFields {get; set;}
    public Id evaluationId { get;
        set {
            evaluationId = value;
            if (responseType != null) {
                fetchResponses(evaluationId, responseType);
            }
        }
    }
    public Id pbsId { get;
        set {
            pbsId = value;
            if (responseType != null) {
                fetchResponsesFromPBS(pbsId, responseType);
            }
        }
    }
    public String responseType {
        get;
        set {
            responseType = value;
            if (evaluationId != null) {
                fetchResponses(evaluationId, responseType);
            }
        }
    }
    public String[] columnsToFetch { get; set; }
    public Map<String, String> columnsToHeadersMap { get; set; }
    public Boolean dialogShown { get; set; }
    public Boolean isEdit { get; set; }

    public Evaluation_Response__c[] responses { get; set; }
    public Integer numberOfResponses {
        get {
            if (numberOfResponses == null) {
                return 0;
            }
            return numberOfResponses;
        }
        set;
    }
    public Evaluation_Response__c currentResponse { get; set; }
    public Id currentResponseId { get; set; }

    public EvaluationResponseTableController() {
        currentResponse = new Evaluation_Response__c();
        dialogShown = false;
        isEdit = false;
        reqFields = new list<string>();
        hasError = false;
    }

    public PageReference showAddResponse() {
        currentResponse = new Evaluation_Response__c();
        currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType(responseType);
        currentResponse.Evaluation__c = evaluationId;
        currentResponse.Person_Being_Served__c = pbsId;
        dialogShown = true;
        isEdit = false;
        return null;
    }

    public PageReference showEditResponse() {
        String query = 'SELECT ID, ' + getNecessaryColumns(responseType) +
                ' FROM Evaluation_Response__c WHERE Id = :currentResponseId';
        currentResponse = Database.query(query);
        dialogShown = true;
        isEdit = true;
        return null;
    }

    public void saveResponse() {
        System.debug('saveResponse called, currentResponse: ' + currentResponse);
        try {
            hasError = false;
            upsert currentResponse;
        } catch (DMLException ex) {
            hasError = true;
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }

    public Component.Apex.PageBlockSection getDialog() {
        // We use a dynamic component here in order to assign dynamic ids to
        // the form inputs (Visualforce doesn't let us do that using static
        // components)
        // a simple 2x check that we in fact have a value for the number of cols 
        if(numCols == null){numCols = 2;}
        
        Component.Apex.PageBlockSection dialog = new Component.Apex.PageBlockSection(columns=numCols);
        if (columnsToFetch == null) {
            return dialog;
        }
        for (String column: columnsToFetch) {
            Component.Apex.InputField dialogInput = new Component.Apex.Inputfield(id=column);
            System.debug('col - '+ column);
            dialogInput.expressions.value = '{!currentResponse[\'' + column + '\']}';
            if(reqFields != null){
                for(string rCol : reqFields){
                    if(column == rCol){dialogInput.required = true;}
                }
            }
            
            dialog.childComponents.add(dialogInput);
        }
        return dialog;
    }

    private void fetchResponses(Id evaluationId, String responseType) {
        if(numRows == null){numRows = 1000;}
        String query = 'SELECT Id, ' + getNecessaryColumns(responseType) +
            ' FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId' +
            ' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
            '\' ORDER BY Date__c ASC NULLS LAST, CreatedDate' ;
        responses = Database.query(query);
        numberOfResponses = responses.size();
    }

    private void fetchResponsesFromPBS(Id pbsId, String responseType) {
        String query = 'SELECT Id, ' + getNecessaryColumns(responseType) +
            ' FROM Evaluation_Response__c WHERE Person_Being_Served__c = :pbsId' +
            ' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
            '\' ORDER BY Date__c ASC NULLS LAST, CreatedDate Limit ' + numRows;
        responses = Database.query(query);
        numberOfResponses = responses.size();
    }

    private String getNecessaryColumns(String recordType) {
        // Convention: Record Type and Fieldset have the exact same label
        List<Schema.FieldSet> allFieldSets = Schema.SObjectType.Evaluation_Response__c.FieldSets.getMap().values();
        Schema.FieldSet fieldSetToUse;

        for (Schema.FieldSet fieldSet: allFieldSets) {
            if (fieldSet.getLabel() == recordType) {
                fieldSetToUse = fieldSet;
            }
        }
        Schema.FieldSetMember[] columns = fieldSetToUse.getFields();
        columnsToFetch = new String[] {};
        columnsToHeadersMap = new Map<String, String>();
        for (Schema.FieldSetMember column: columns) {
            columnsToFetch.add(column.getFieldPath());
            columnsToHeadersMap.put(column.getFieldPath(), column.getLabel());
        }
        return String.join(columnsToFetch, ', ');
    }
}