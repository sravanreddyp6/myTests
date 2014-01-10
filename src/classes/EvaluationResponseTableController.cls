public with sharing class EvaluationResponseTableController {
    public Id evaluationId { get;
        set {
            evaluationId = value;
            if (responseType != null) {
                fetchResponses(evaluationId, responseType);
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
    public Boolean dialogShown { get; set; }
    public Boolean isEdit { get; set; }

    public Evaluation_Response__c[] responses { get; set; }
    public Evaluation_Response__c currentResponse { get; set; }
    public Id currentResponseId { get; set; }

    public EvaluationResponseTableController() {
        currentResponse = new Evaluation_Response__c();
        dialogShown = false;
        isEdit = false;
    }

    public PageReference showAddResponse() {
        currentResponse = new Evaluation_Response__c();
        currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType(responseType);
        currentResponse.Evaluation__c = evaluationId;
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
            upsert currentResponse;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }

    private void fetchResponses(Id evaluationId, String responseType) {
        String query = 'SELECT Id, ' + getNecessaryColumns(responseType) +
            ' FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId' +
            ' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
            '\' ORDER BY CreatedDate';
        responses = Database.query(query);
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
        for (Schema.FieldSetMember column: columns) {
            columnsToFetch.add(column.getFieldPath());
        }
        return String.join(columnsToFetch, ', ');
    }
}