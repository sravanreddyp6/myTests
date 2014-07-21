public with sharing class CareMeridianAnotoFormHandler implements AnotoFormHandler {
    private Evaluation__c evaluation;
    private Evaluation__c oldEvaluation;
    private Referral__c referral;
    private Person_Being_Referred__c pbr;

    private Set<String> fieldError = new Set<String>();
    private Map<String, DescribeFieldResult> fieldDescribeMap = new Map<String, DescribeFieldResult>();
    private Map<String, Id> evaluationResponseRecordTypeMap = new Map<String, Id>();
    // The following map has the format: record type name => (Row # => (fieldName => field value))
    private Map<String, Map<String, Map<String, Object>>> evaluationResponseMap = new Map<String, Map<String, Map<String, Object>>>();
    // The following map has the format: Row # => (fieldName => field value)
    private Map<String, Map<String, Object>> relatedPartyMap = new Map<String, Map<String, Object>>();
    private Map<String, DescribeSObjectResult> objectDescribeMap = new Map<String, DescribeSObjectResult>();
    private String patternId;

    public CareMeridianAnotoFormHandler() {
        RecordType[] recordTypes = [
            SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Evaluation_Response__c'
        ];
        for (RecordType rt: recordTypes) {
            evaluationResponseRecordTypeMap.put(rt.DeveloperName.toLowerCase(), rt.Id);
        }
        System.debug('evaluationResponseRecordTypeMap: ' + evaluationResponseRecordTypeMap);
        objectDescribeMap.put('Evaluation__c', Evaluation__c.sObjectType.getDescribe());
        objectDescribeMap.put('Evaluation_Response__c', Evaluation_Response__c.sObjectType.getDescribe());
        objectDescribeMap.put('Related_Party__c', Related_Party__c.sObjectType.getDescribe());
    }

    public String handle(Id evaluationId, String fileType, Blob fileContent, RestRequest req, RestResponse response) {
        System.debug('CM Evaluation Form Handler, evaluationId: ' + evaluationId + ', fileType: ' + fileType);
        // Fetch all necessary fields on the Evaluation record:
        Set<String> fields = Schema.SObjectType.Evaluation__c.fields.getMap().keySet();
        String query = 'SELECT ';
        for (String field: fields) {
            query += field + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ', Referral__r.Person_Being_Referred__c FROM Evaluation__c WHERE Id=\'' + evaluationId + '\'';
        evaluation = Database.query(query);
        oldEvaluation = Database.query(query);
        // Fetch necessary fields on the PBR record
        pbr = [
            SELECT Id, Date_of_Birth__c
            FROM Person_Being_Referred__c
            WHERE Id=:evaluation.Referral__r.Person_Being_Referred__c
        ];
        if (fileType == 'png') {
            Attachment[] currentAttachments = [
                SELECT Id FROM Attachment
                WHERE ParentId=:evaluation.Referral__c AND Name='BodyMarkup.png'
            ];
            if (currentAttachments.size()>0) {
                currentAttachments[0].Name='BodyMarkup ' + DateTime.now().format() + '.png';
                update currentAttachments[0];
            }
            Attachment a = new Attachment();
            a.Body = fileContent;
            a.Name = 'BodyMarkup.png';
            a.ParentId = evaluation.Referral__c;
            insert a;
        } else if (fileType == 'pdf') {
            Attachment a = new Attachment();
            a.Body = fileContent;
            a.Name = 'EvalPaperForm ' + DateTime.now().format() + '.pdf';
            a.ParentId = evaluation.Referral__c;
            insert a;
        } else if (fileType == 'xml') {
            String xml = fileContent.toString();
            System.debug('In handler, xml content:' + xml);
            Dom.Document doc = new Dom.Document();
            doc.load(xml);
            Dom.XMLNode form = doc.getRootElement();
            if (form.getAttributeValue('first-page', null) != null) {
                patternId = form.getAttributeValue('first-page', null);
            }
            DOM.XMLNode[] children = form.getChildElements();
            for (Dom.XMLNode node: children) {
                if (node.getName()!='prepop') {
                    if (node.getAttributeValue('name', null) != null) {
                        System.debug('Inspecting node: ' + node);
                        fieldHandler(node.getAttributeValue('name', null), node.getText(), node);
                    }
                }
            }
            // Bypass the check in Josh's trigger
            evaluation.Is_Being_Signed__c = evaluation.Is_Signed__c;
            System.debug('Before saving evaluation, pen upload errors: ' + evaluation.Pen_Upload_Error__c);
            saveEvaluation();

            // Get a brand new sobject record here so we don't run into
            // any other issue.
            Evaluation__c anotherEval = [
                SELECT Id, Pen_Upload_Error__c, Is_Signed__c FROM Evaluation__c
                WHERE Id=:evaluation.Id
            ];
            // Manually put together the address for related parties
            System.debug('evaluationResponseMap: ' + evaluationResponseMap);
            Map<String, Map<String, Evaluation_Response__c>> respObjMap = new Map<String, Map<String, Evaluation_Response__c>>();
            Set<String> evaluationResponseFields = Schema.SObjectType.Evaluation_Response__c.fields.getMap().keySet();
            List<String> evalResponseFieldList = new List<String>();
            evalResponseFieldList.addAll(evaluationResponseFields);
            for (String rt: evaluationResponseMap.keySet()) {
                System.debug('record type: ' + rt);
                for (String rtRow: evaluationResponseMap.get(rt).keySet()) {
                    String externalId = patternId + '-' + rt + '-' + rtRow;
                    Evaluation_Response__c[] currentResp = Database.query(
                        'SELECT ' + String.join(evalResponseFieldList, ', ') + ' FROM Evaluation_Response__c WHERE Paper_Id__c=:externalId'
                    );
                    Boolean toInsertResp = false;
                    Evaluation_Response__c resp = new Evaluation_Response__c(
                        RecordTypeId = evaluationResponseRecordTypeMap.get(rt),
                        Evaluation__c = anotherEval.Id
                    );
                    for (String rtRowKey: evaluationResponseMap.get(rt).get(rtRow).keySet()) {
                        if (currentResp.size() > 0 && currentResp[0].get(rtRowKey) != null) {
                            continue;  // Never update a field with existing data in ESD
                        }
                        if (evaluationResponseMap.get(rt).get(rtRow).get(rtRowKey) != null && evaluationResponseMap.get(rt).get(rtRow).get(rtRowKey) != '') {
                            resp.put(rtRowKey, evaluationResponseMap.get(rt).get(rtRow).get(rtRowKey));
                            toInsertResp = true;
                        }
                    }
                    if (toInsertResp) {
                        try {
                            resp.Paper_Id__c = externalId;
                            System.debug('Evaluation Response to Insert: ' + resp);
                            upsert resp Paper_Id__c;
                        } catch (DMLException ex) {
                            addError(ex.getMessage(), anotherEval);
                        }
                    }
                }
            }
            Map<String, Related_Party__c> relatedPartyObjMap = new Map<String, Related_Party__c>();
            System.debug('relatedPartyMap: ' + relatedPartyMap);
            Set<String> relatedPartyFields = Schema.SObjectType.Related_Party__c.fields.getMap().keySet();
            List<String> relatedPartyFieldList = new List<String>();
            relatedPartyFieldList.addAll(relatedPartyFields);
            for (String rpRow: relatedPartyMap.keySet()) {
                String externalId = patternId + '-' + rpRow;
                Boolean toInsertRelParty = false;
                Related_Party__c relParty = new Related_Party__c(
                    Person_Being_Referred__c = evaluation.Referral__r.Person_Being_Referred__c
                );
                Related_Party__c[] currentRelParty = Database.query(
                    'SELECT ' + String.join(relatedPartyFieldList, ', ') + ' FROM Related_Party__c WHERE Paper_Id__c=:externalId'
                );
                String address;
                String address2;
                String city;
                String state;
                String zip;
                for (String rpRowKey: relatedPartyMap.get(rpRow).keySet()) {
                    if (rpRowKey == 'street_address' && relatedPartyMap.get(rpRow).get(rpRowKey) != null) {
                        address = (String) relatedPartyMap.get(rpRow).get(rpRowKey);
                        relatedPartyMap.get(rpRow).remove(rpRowKey);
                        continue;
                    }
                    if (rpRowKey == 'street_address_2' && relatedPartyMap.get(rpRow).get(rpRowKey) != null) {
                        address2 = (String) relatedPartyMap.get(rpRow).get(rpRowKey);
                        relatedPartyMap.get(rpRow).remove(rpRowKey);
                        continue;
                    }
                    if (rpRowKey == 'city' && relatedPartyMap.get(rpRow).get(rpRowKey) != null) {
                        city = (String) relatedPartyMap.get(rpRow).get(rpRowKey);
                        relatedPartyMap.get(rpRow).remove(rpRowKey);
                        continue;
                    }
                    if (rpRowKey == 'state' && relatedPartyMap.get(rpRow).get(rpRowKey) != null) {
                        state = (String) relatedPartyMap.get(rpRow).get(rpRowKey);
                        relatedPartyMap.get(rpRow).remove(rpRowKey);
                        continue;
                    }
                    if (rpRowKey == 'zip_code' && relatedPartyMap.get(rpRow).get(rpRowKey) != null) {
                        zip = (String) relatedPartyMap.get(rpRow).get(rpRowKey);
                        relatedPartyMap.get(rpRow).remove(rpRowKey);
                        continue;
                    }
                    if (relatedPartyFields.contains(rpRowKey) && currentRelParty.size() > 0 && currentRelParty[0].get(rpRowKey) != null) {
                        continue;  // Never update a field with existing data in ESD
                    }
                    if (relatedPartyMap.get(rpRow).get(rpRowKey) != null && relatedPartyMap.get(rpRow).get(rpRowKey) != '') {
                        relParty.put(rpRowKey, relatedPartyMap.get(rpRow).get(rpRowKey));
                        toInsertRelParty = true;
                    }
                }
                String fullAddress = '';
                if (address != '' && address != null) {
                    fullAddress += address + ', ';
                }
                if (address2 != '' && address2 != null) {
                    fullAddress += address2 + '. ';
                }
                if (city != '' && city != null) {
                    fullAddress += city + ', ';
                }
                if (state != '' && state != null) {
                    fullAddress += state + ' ';
                }
                if (zip != '' && zip != null) {
                    fullAddress += zip;
                }
                if (currentRelParty.size() > 0 && currentRelParty[0].get('address__c') != null) {
                } else if (fullAddress != '') {
                    relParty.put('address__c', fullAddress);
                    toInsertRelParty = true;
                }
                if (toInsertRelParty) {
                    try {
                        relParty.Paper_Id__c = externalId;
                        System.debug('relParty to insert: ' + relParty);
                        upsert relParty Paper_Id__c;
                    } catch (DMLException ex) {
                        addError(ex.getMessage(), anotherEval);
                    }
                }
            }
            // Bypass Josh's trigger again
            anotherEval.Is_Being_Signed__c = anotherEval.Is_Signed__c;
            update anotherEval;
        }

        return 'Successful';
    }

    private void fieldHandler(String name, String value, DOM.XMLNode node) {
        // Manually fix stuff here that are already printed out
        String[] parts = name.split('-');
        if (parts.size()<=1) {
            return;
        }
        if (value == '') {
            return;
        }
        if (parts[1] == 'evaluation__c') {
            // Hijack here for custom fields that act similarly to text fields
            Set<String> intactImpairedFields = new Set<String>{
                'awareness_of_deficits__c', 'safety_awareness__c',
                'receptive_language__c', 'verbal_expression__c',
                'initiation__c', 'speech_intelligibility__c',
                'r_upper_rom__c', 'r_lower_rom__c', 'l_upper_rom__c', 'l_lower_rom__c',
                'r_upper_tone__c', 'r_lower_tone__c', 'l_upper_tone__c', 'l_lower_tone__c',
                'r_upper_strength__c', 'r_lower_strength__c', 'l_upper_strength__c', 'l_lower_strength__c',
                'r_upper_sensation__c', 'r_lower_sensation__c', 'l_upper_sensation__c', 'l_lower_sensation__c'
            };
            if (intactImpairedFields.contains(parts[2])) {
                try {
                    value = expandAbbreviation(value,
                        new Map<String,String>{
                            'in' => 'Intact',
                            'ip' => 'Impaired'
                        }
                    );
                    parts[0] = 'text';
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for ' + getFieldLabel(parts[2], 'Evaluation__c') + ' field, which is not a correct type.');
                }
            }
            Set<String> intactImpairedNotTestedFields = new Set<String>{
                'endurance__c', 'balance_sitting__c', 'balance_standing__c'
            };
            if (intactImpairedNotTestedFields.contains(parts[2])) {
                try {
                    parts[0] = 'text';
                    value = expandAbbreviation(value,
                        new Map<String,String>{
                            'in' => 'Intact',
                            'ip' => 'Impaired',
                            'nt' => 'Not Tested'
                        }
                    );
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for ' + getFieldLabel(parts[2], 'Evaluation__c') + ' field, which is not a correct type.');
                }
            }
            Set<String> patientStatusFields = new Set<String>{
                'bed_mobility__c', 'feeding__c', 'transfers__c',
                'hygiene__c', 'wc_gait__c', 'dressing_ue__c', 'dressing_le__c'
            };
            if (patientStatusFields.contains(parts[2])) {
                try {
                    value = expandAbbreviation(value,
                        new Map<String,String>{
                            'min' => 'Minimum Assist',
                            'dep' => 'Dependent',
                            'cga' => 'CGA',
                            'max' => 'Max Assist',
                            'sup' => 'Supervised',
                            'mod' => 'Moderate Assist',
                            'ind' => 'Independent'
                        }
                    );
                    parts[0] = 'text';
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for ' + getFieldLabel(parts[2], 'Evaluation__c') + ' field, which is not a correct type.');
                }
            }
            if (parts[0] == 'text') {
                System.debug('Text field ' + parts[2] + ': ' + value);
                updateField(parts[2], value);
            }
            if (parts[0] == 'date') {
                try {
                    updateField(parts[2], (Object) Date.parse(value.replace('-', '/')));
                } catch (System.TypeException ex) {
                    addError('Cannot parse the date value for field ' + getFieldLabel(parts[2], 'Evaluation__c'));
                }
            }
            if (parts[0] == 'number') {
                try {
                    updateField(parts[2], (Object) Decimal.valueOf(value));
                } catch (System.TypeException ex) {
                    addError('Cannot parse the number value for field ' + getFieldLabel(parts[2], 'Evaluation__c'));
                }
            }
            if (parts[0] == 'checkbox') {
                System.debug('checkbox field, parts: ' + parts[2] + ', value: ' + Boolean.valueOf(value));
                updateField(parts[2], Boolean.valueOf(value));
            }
            // Hijack here for custom fields that could be dealt with like
            // picklist fields (but we can't code them in the XML because they
            // have non alphanumeric characters)
            if (parts[2] == 'rancho_level__c') {
                parts[0] = 'picklist';
                parts[3] = expandAbbreviation(parts[3],
                    new Map<String,String>{
                        '1' => '(1) No Response',
                        '2' => '(2) Generalized Response',
                        '3' => '(3) Localized Response',
                        '4' => '(4) Confused/Agitated',
                        '5' => '(5) Confused/Inappropriate',
                        '6' => '(6) Confused/Appropriate',
                        '7' => '(7) Automatic/Appropriate',
                        '8' => '(8) Purposeful/Appropriate'
                    }
                );
            }
            if (parts[2] == 'discharge_to__c') {
                parts[0] = 'multipicklist';
                parts[3] = expandAbbreviation(parts[3],
                    new Map<String,String>{
                        'acute_rehab' => 'Acute Rehab',
                        'board_care' => 'Board & Care',
                        'ltc' => 'LTC',
                        'snf' => 'SNF',
                        'house_condo_apt' => 'House/Condo/Apt',
                        '1_story' => '1 Story',
                        '2_story' => '2 Story',
                        'multi_level' => 'Multi-Level',
                        'mobile_home' => 'Mobile Home',
                        'hotel_motel' => 'Motel/Hotel',
                        'other' => 'Other'
                    }
                );
            }
            if (parts[2] == 'prior_living_situation__c') {
                parts[0] = 'multipicklist';
                parts[3] = expandAbbreviation(parts[3],
                    new Map<String,String>{
                        'house_condo_apt' => 'House/Condo/Apt',
                        '1_story' => '1 Story',
                        '2_story' => '2 Story',
                        'multi_level' => 'Multi-Level',
                        'mobile_home' => 'Mobile Home',
                        'hotel_motel' => 'Motel/Hotel',
                        'other' => 'Other'
                    }
                );
            }
            if (parts[0] == 'picklist') {
                if (fieldError.contains(parts[2])) {
                    // There's an error here before, skipping
                    return;
                }
                if (value != 'true') {
                    // Don't handle falsy values
                    return;
                }
                System.debug('Picklist parts: ' + parts);
                System.debug('Current picklist val: ' + evaluation.get(parts[2]));
                // In case they check more than 1 checkboxes for a single picklist
                if (evaluation.get(parts[2]) != null && evaluation.get(parts[2]) != String.valueOf(parts[3]).replace('_', ' ')) {
                    // Revert it back to the value before
                    evaluation.put(parts[2], oldEvaluation.get(parts[2]));
                    // And put the field name in the error Map
                    fieldError.add(parts[2]);
                    addError('You cannot check more than 1 box for the field ' + getFieldLabel(parts[2], 'Evaluation__c'));
                    return;
                }
                updateField(parts[2], String.valueOf(parts[3]).replace('_', ' '));
            }
            if (parts[0] == 'multipicklist' && value=='true') {
                System.debug('multipicklist: ' + parts[3]);
                String startString = evaluation.get(parts[2])==null ? '' : evaluation.get(parts[2]) + ';';
                updateField(parts[2], startString + String.valueOf(parts[3]).replace('_', ' '));
            }
        }
        if (parts[1] == 'evaluation_response__c') {
            if (evaluationResponseMap.get(parts[2]) == null) {
                evaluationResponseMap.put(parts[2], new Map<String, Map<String, Object>>());
            }
            String fieldApiName = parts[3].substringBeforeLast('__');
            String rowNum = parts[3].substringAfterLast('__');
            if (evaluationResponseMap.get(parts[2]).get(rowNum) == null) {
                evaluationResponseMap.get(parts[2]).put(rowNum, new Map<String, Object>());
            }
            Map<String, Object> fieldValueMap = evaluationResponseMap.get(parts[2]).get(rowNum);
            if (parts[0] == 'text') {
                fieldValueMap.put(fieldApiName, value);
            }
            if (parts[0] == 'date') {
                try {
                    fieldValueMap.put(fieldApiName, Date.parse(value.replace('-', '/')));
                } catch (System.TypeException ex) {
                    addError('Cannot parse the date value for field ' + getFieldLabel(fieldApiName, 'Evaluation_Response__c') + ' in entry #' + rowNum + ' of the ' + parts[2] + ' section.');
                }
            }
            if (parts[0] == 'number') {
                try {
                    fieldValueMap.put(fieldApiName, Decimal.valueOf(value));
                } catch (System.TypeException ex) {
                    addError('Cannot parse the number value for field ' + getFieldLabel(fieldApiName, 'Evaluation_Response__c') + ' in entry #' + rowNum + ' of the ' + parts[2] + ' section.');
                }
            }
            if (parts[0] == 'checkbox' && value=='true') {
                fieldValueMap.put(fieldApiName, Boolean.valueOf(value));
            }
            if (fieldApiName == 'allergy_type__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'f' => 'Food',
                            'd' => 'Drug',
                            'o' => 'Other'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Allergy Type field, which is not a correct type.');
                }
            }
            if (fieldApiName == 'category__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'x' => 'X-Ray',
                            'mri' => 'MRI',
                            'ct' => 'CT',
                            'dop' => 'Doppler',
                            'o' => 'Other'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Category field, which is not a correct type.');
                }
            }
            if (fieldApiName == 'test_type__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'mrsa' => 'MRSA',
                            'vre' => 'VRE',
                            'mdr' => 'MDR',
                            'tb' => 'TB',
                            'acin' => 'Acintobacter',
                            'cd' => 'C-diff'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Micro Details Test Type field, which is not a correct type.');
                }
            }
            if (fieldApiName == 'wound_type__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'a' => 'Abrasion',
                            'br' => 'Bruising',
                            'bu' => 'Burn',
                            's' => 'Surgical',
                            't' => 'Traumatic'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Wound Type field, which is not a correct type.');
                }
            }
        }
        if (parts[1] == 'person_being_referred__c' && parts[2] == 'date_of_birth__c' && pbr.Date_of_Birth__c == null) {
            try {
                pbr.Date_of_Birth__c = Date.parse(value);
                update pbr;
            } catch (System.TypeException ex) {
                addError('Cannot parse the date value for field Date of Birth.');
            } catch (DMLException ex) {
                addError('Cannot save the person being referred. Error: ' + ex.getMessage());
            }
        }
        if (parts[1] == 'related_party__c') {
            String fieldApiName = parts[2].substringBeforeLast('__');
            String rowNum = parts[2].substringAfterLast('__');
            if (relatedPartyMap.get(rowNum) == null) {
                relatedPartyMap.put(rowNum, new Map<String, Object>());
            }
            Map<String, Object> fieldValueMap = relatedPartyMap.get(rowNum);
            if (parts[0] == 'text') {
                fieldValueMap.put(fieldApiName, value);
            }
            if (parts[0] == 'custom' && fieldApiName != 'type__c' && fieldApiName != 'phone_1_type__c' && fieldApiName != 'phone_2_type__c') {
                fieldValueMap.put(fieldApiName, value);
            }
            if (fieldApiName == 'type__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'g' => 'Guardian',
                            'ff' => 'Family/Friends',
                            'fr' => 'Funder Resources',
                            'm' => 'Medical',
                            'e' => 'Employment',
                            'o' => 'Other',
                            'rf' => 'Referring Provider'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Relationship Type field in the Related Party section, which is not a correct type.');
                }
            }
            if (fieldApiName == 'phone_1_type__c' || fieldApiName == 'phone_2_type__c') {
                try {
                    fieldValueMap.put(fieldApiName, expandAbbreviation(value,
                        new Map<String,String>{
                            'h' => 'Home',
                            'w' => 'Work',
                            'c' => 'Cell',
                            'f' => 'Fax'
                        }
                    ));
                } catch (AbbreviationNotFoundException ex) {
                    addError('You wrote ' + value + ' for Phone Type field in the Related Party section, which is not a correct type.');
                }
            }
        }
    }

    private void updateField(String name, String value) {
        try {
            Object oldValue = oldEvaluation.get(name);
            if (oldValue == null || oldValue == '') {
                evaluation.put(name, value);
            }
        } catch (Exception ex) {
            addError(ex.getMessage());
        }
    }

    private void updateField(String name, Boolean value) {
        try {
            System.debug('update boolean field!');
            Boolean oldValue = (Boolean) oldEvaluation.get(name);
            System.debug('old value: ' + oldValue);
            if (!oldValue) {  // if the old eval has true as its value, that means it has been modified before, so we skip now
                evaluation.put(name, value);
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            addError(ex.getMessage());
        }
    }

    private void updateField(String name, Object value) {
        try {
            if (oldEvaluation.get(name) == null) {
                evaluation.put(name, value);
            }
        } catch (Exception ex) {
            addError(ex.getMessage());
        }
    }

    private void saveEvaluation() {
        System.debug('Saving Evaluation');
        Boolean errorFound = false;
        try {
            update evaluation;
            System.debug('Evaluation save succeeded. Eval after: ' + evaluation);
        } catch (DMLException ex) {
            System.debug('Error Found while saving evaluation!');
            errorFound = true;
            for (Integer i=0; i<ex.getNumDml(); i++) {
                String[] errorFields = ex.getDmlFieldNames(i);
                addError(ex.getDmlMessage(i));
                for (String errorField: errorFields) {
                    System.debug('Reverting field ' + errorField + ' back to original value: ' + oldEvaluation.get(errorField));
                    // Revert to old field value
                    evaluation.put(errorField, oldEvaluation.get(errorField));
                }
            }
        }
        update evaluation;
    }

    private void addError(String errorMsg) {
        addError(errorMsg, evaluation);
    }
    private void addError(String errorMsg, Evaluation__c eval) {
        if (eval.Pen_Upload_Error__c == null) {
            eval.Pen_Upload_Error__c = errorMsg + '\n';
        } else if (eval.Pen_Upload_Error__c.indexOf(errorMsg) == -1) { // Don't duplicate errors
            eval.Pen_Upload_Error__c += errorMsg + '\n';
        }
    }
    private String getFieldLabel(String fieldName, String objectName) {
        // Assuming that there's no duplicate field name across the objects we use here
        if (fieldDescribeMap.containsKey(fieldName)) {
            return fieldDescribeMap.get(fieldName).getLabel();
        }
        System.debug('getFieldLabel for ' + fieldName + ' in object ' + objectName + '. objectDescribeMap: ' + objectDescribeMap);
        Schema.DescribeFieldResult f = objectDescribeMap.get(objectName).fields.getMap().get(fieldName).getDescribe();
        fieldDescribeMap.put(fieldName, f);
        return getFieldLabel(fieldName, objectName);
    }
    private String expandAbbreviation(String abbr, Map<String, String> dict) {
        if (abbr == '' || abbr == null) return '';
        abbr = abbr.toLowerCase();
        if (!dict.containsKey(abbr)) {
            System.debug('abbreviation ' + abbr + ' not found in map ' + dict);
            throw new AbbreviationNotFoundException();
        }
        return dict.get(abbr);
    }

    public class AbbreviationNotFoundException extends Exception {}
}