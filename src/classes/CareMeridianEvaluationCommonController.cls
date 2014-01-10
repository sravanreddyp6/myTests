public with sharing class CareMeridianEvaluationCommonController {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String pdfExistenceUrl { get; set; }
    public String bodyMapUrl { get {
        Attachment[] attachments = [
            SELECT Id FROM Attachment
            WHERE ParentId=:evaluation.Referral__c
              AND Name='BodyMarkup.png'
        ];
        if (attachments.size() > 0) {
            return System.URL.getSalesforceBaseURL().toExternalForm() + '/servlet/servlet.FileDownload?file=' + attachments[0].Id;
        }
        return null;
    } }
    public CareMeridianEvaluationCommonController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        evaluation = (Evaluation__c) stdController.getRecord();
    }

    public void clearPenUploadErrors() {
        this.evaluation.Pen_Upload_Error__c = null;
        update this.evaluation;
    }

    public void generatePaperForm() {
        try {
            this.pdfExistenceUrl = AnotoUtility.generatePdfByHandlerName('CareMeridian Evaluation',
                generatePrepopXml(evaluation.Id));
        } catch (AnotoUtility.PdfGenerationException e) {
            this.pdfExistenceUrl = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'There is an error generating the paper form. Please try again later.'));
        }
    }

    private String generatePrepopXml(Id evaluationId) {
        XmlStreamWriter writer = AnotoUtility.startXmlWriter();
        writer.writeStartElement(null, 'SalesforceId', null);
        writer.writeCharacters(evaluationId);
        writer.writeEndElement();
        // Using reflection, put all the fields in the record into the prepop
        // XML file following our naming convention.
        Set<String> fields = Schema.SObjectType.Evaluation__c.fields.getMap().keySet();
        String query = 'SELECT ';
        for (String field: fields) {
            query += field + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ', Referral__r.Person_Being_Referred__c FROM Evaluation__c WHERE Id=\'' + evaluationId + '\'';
        Evaluation__c eval = Database.query(query);
        for (String field: fields) {
            if (eval.get(field) == null || eval.get(field) == '') {
                continue;
            }
            Object f = (Object) eval.get(field);
            // Custom fields prepop
            if (field == 'rancho_level__c') {
                String abbr = abbreviateValue((String) f, new Map<String, String>{
                    '(1) No Response' => '1',
                    '(2) Generalized Response' => '2',
                    '(3) Localized Response' => '3',
                    '(4) Confused/Agitated' => '4',
                    '(5) Confused/Inappropriate' => '5',
                    '(6) Confused/Appropriate' => '6',
                    '(7) Automatic/Appropriate' => '7',
                    '(8) Purposeful/Appropriate' => '8'
                });
                if (abbr != null) {
                    writer.writeStartElement(null, 'custom-evaluation__c-' + field + '-' + abbr, null);
                    writer.writeCharacters('true');
                    writer.writeEndElement();
                }
            }
            if (field == 'discharge_to__c') {
                if (f == null || f == '') continue;
                // Multi picklist resolve
                String[] vals = ((String) f).split(';', 0);
                for (String val: vals) {
                    String abbr = abbreviateValue(val, new Map<String, String>{
                        'Acute Rehab' => 'acute_rehab',
                        'Board & Care' => 'board_care',
                        'LTC' => 'ltc',
                        'SNF' => 'snf',
                        'House/Condo/Apt' => 'house_condo_apt',
                        '1 Story' => '1_story',
                        '2 Story' => '2_story',
                        'Multi-Level' => 'multi_level',
                        'Mobile Home' => 'mobile_home',
                        'Motel/Hotel' => 'hotel_motel',
                        'Other' => 'other'
                    });
                    if (abbr != null) {
                        writer.writeStartElement(null, 'custom-evaluation__c-' + field + '-' + abbr, null);
                        writer.writeCharacters('true');
                        writer.writeEndElement();
                    }
                }
            }
            if (field == 'prior_living_situation__c') {
                if (f == null || f == '') continue;
                // Multi picklist resolve
                String[] vals = ((String) f).split(';', 0);
                for (String val: vals) {
                    String abbr = abbreviateValue(val, new Map<String, String>{
                        'House/Condo/Apt' => 'house_condo_apt',
                        '1 Story' => '1_story',
                        '2 Story' => '2_story',
                        'Multi-Level' => 'multi_level',
                        'Mobile Home' => 'mobile_home',
                        'Motel/Hotel' => 'hotel_motel',
                        'Other' => 'other'
                    });
                    if (abbr != null) {
                        writer.writeStartElement(null, 'custom-evaluation__c-' + field + '-' + abbr, null);
                        writer.writeCharacters('true');
                        writer.writeEndElement();
                    }
                }
            }
            Set<String> intactImpairedFields = new Set<String>{
                'awareness_of_deficits__c', 'safety_awareness__c',
                'receptive_language__c', 'verbal_expression__c',
                'initiation__c', 'speech_intelligibility__c',
                'r_upper_rom__c', 'r_lower_rom__c', 'l_upper_rom__c', 'l_lower_rom__c',
                'r_upper_tone__c', 'r_lower_tone__c', 'l_upper_tone__c', 'l_lower_tone__c',
                'r_upper_strength__c', 'r_lower_strength__c', 'l_upper_strength__c', 'l_lower_strength__c',
                'r_upper_sensation__c', 'r_lower_sensation__c', 'l_upper_sensation__c', 'l_lower_sensation__c'
            };
            if (intactImpairedFields.contains(field)) {
                String abbr = abbreviateValue((String) f, new Map<String, String>{
                    'Intact' => 'IN',
                    'Impaired' => 'IP'
                });
                if (abbr != null) {
                    writer.writeStartElement(null, 'custom-evaluation__c-' + field, null);
                    writer.writeCharacters(abbr);
                    writer.writeEndElement();
                }
            }
            Set<String> intactImpairedNotTestedFields = new Set<String>{
                'endurance__c', 'balance_sitting__c', 'balance_standing__c'
            };
            if (intactImpairedNotTestedFields.contains(field)) {
                String abbr = abbreviateValue((String) f, new Map<String, String>{
                    'Intact' => 'IN',
                    'Impaired' => 'IP',
                    'Not Tested' => 'NT'
                });
                if (abbr != null) {
                    writer.writeStartElement(null, 'custom-evaluation__c-' + field, null);
                    writer.writeCharacters(abbr);
                    writer.writeEndElement();
                }
            }
            Set<String> patientStatusFields = new Set<String>{
                'bed_mobility__c', 'feeding__c', 'transfers__c',
                'hygiene__c', 'wc_gait__c', 'dressing_ue__c', 'dressing_le__c'
            };
            if (patientStatusFields.contains(field)) {
                String abbr = abbreviateValue((String) f, new Map<String, String>{
                    'Minimum Assist' => 'MIN',
                    'Dependent' => 'DEP',
                    'CGA' => 'CGA',
                    'Max Assist' => 'MAX',
                    'Supervised' => 'SUP',
                    'Moderate Assist' => 'MOD',
                    'Independent' => 'IND'
                });
                if (abbr != null) {
                    writer.writeStartElement(null, 'custom-evaluation__c-' + field, null);
                    writer.writeCharacters(abbr);
                    writer.writeEndElement();
                }
            }
            // General prepop
            if (f instanceof Boolean) {
                writer.writeStartElement(null, 'checkbox-evaluation__c-' + field, null);
                writer.writeCharacters(String.valueOf(f));
                writer.writeEndElement();
            }
            if (f instanceof Date) {
                writer.writeStartElement(null, 'date-evaluation__c-' + field, null);
                writer.writeCharacters(((Date)eval.get(field)).format());
                writer.writeEndElement();
            }
            if (f instanceof String) {
                String stringField = (String) eval.get(field);
                // It could either be a text field or a picklist or a multi-picklist
                writer.writeStartElement(null, 'text-evaluation__c-' + field, null);
                writer.writeCharacters(stringField);
                writer.writeEndElement();
                if (stringField.indexOf(';')==-1) {
                    writer.writeStartElement(null, 'picklist-evaluation__c-' + field + '-' + stringField.replaceAll('[^a-zA-Z0-9]', '_'), null);
                    writer.writeCharacters(String.valueOf(true));
                    writer.writeEndElement();
                    writer.writeStartElement(null, 'multipicklist-evaluation__c-' + field + '-' + stringField.replaceAll('[^a-zA-Z0-9]', '_'), null);
                    writer.writeCharacters(String.valueOf(true));
                    writer.writeEndElement();
                } else {
                    String[] possibleMultiValues = stringField.split(';', 0);
                    for (String possibleMultiValue: possibleMultiValues) {
                        writer.writeStartElement(null, 'multipicklist-evaluation__c-' + field + '-' + possibleMultiValue.replaceAll('[^a-zA-Z0-9]', '_'), null);
                        writer.writeCharacters(String.valueOf(true));
                        writer.writeEndElement();
                    }
                }
            }
            if (f instanceof Double || f instanceof Integer) {
                writer.writeStartElement(null, 'number-evaluation__c-' + field, null);
                writer.writeCharacters(String.valueOf(f));
                writer.writeEndElement();
            }
        }
        // Prepop person being referred
        String[] pbrFields = new String[] {
            'first_name__c', 'middle_initial__c', 'last_name__c', 'age__c'
        };
        Person_Being_Referred__c pbr = [
            SELECT Id, first_name__c, middle_initial__c, last_name__c, age__c,
                   date_of_birth__c
            FROM Person_Being_Referred__c
            WHERE Id=:eval.Referral__r.Person_Being_Referred__c
        ];
        for (String pbrField: pbrFields) {
            if (pbr.get(pbrField) != null) {
                writer.writeStartElement(null, 'text-person_being_referred__c-' + pbrField, null);
                writer.writeCharacters(String.valueOf(pbr.get(pbrField)));
                writer.writeEndElement();
            }
        }
        if (pbr.get('date_of_birth__c') != null) {
            writer.writeStartElement(null, 'date-person_being_referred__c-date_of_birth__c', null);
            writer.writeCharacters(((Date)pbr.get('date_of_birth__c')).format());
            writer.writeEndElement();
        }
        // Prepop referral
        Referral__c referral = [
            SELECT Id, Agency_Name__c, Case_Manager_Name__c
            FROM Referral__c
            WHERE Id=:eval.Referral__c
        ];
        if (referral.Agency_Name__c != null) {
            writer.writeStartElement(null, 'text-referral__c-agency_name__c', null);
            writer.writeCharacters(referral.Agency_Name__c);
            writer.writeEndElement();
        }
        if (referral.Case_Manager_Name__c != null) {
            writer.writeStartElement(null, 'text-referral__c-case_manager_name__c', null);
            writer.writeCharacters(referral.Case_Manager_Name__c);
            writer.writeEndElement();
        }
        return AnotoUtility.endXmlWriter(writer);
    }

    private String abbreviateValue(String value, Map<String, String> dict) {
        if (value == '' || value == null || !dict.containsKey(value)) {
            return null;
        }
        return dict.get(value);
    }
}