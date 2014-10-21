public with sharing class EvaluationResponseTableController {
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
            '\' ORDER BY Date__c ASC NULLS LAST, CreatedDate';
        responses = Database.query(query);
        numberOfResponses = responses.size();
    }

    private void fetchResponsesFromPBS(Id pbsId, String responseType) {
        String query = 'SELECT Id, ' + getNecessaryColumns(responseType) +
            ' FROM Evaluation_Response__c WHERE Person_Being_Served__c = :pbsId' +
            ' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
            '\' ORDER BY Date__c ASC NULLS LAST, CreatedDate';
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