public with sharing class CNANote_form {

    private ApexPages.StandardController controller;
    //private Action_Plan_Worksheet__c result;
    //private List<ObjectiveWrapper> objectivesMap;
    public Evaluation__c eval { get; set;}
    public ID admID { get; set;}
    public ID saID { get; set; }
    public ID pbsID { get; set;}
    private Contact pbs;
    public boolean hasError = false;
    
    // Usual constructor
    public CNANote_form() {
    	
    	ID evalID = ApexPages.currentPage().getParameters().get('evalID');
    
        this.controller = controller;
        eval = [select id, Name, evaluation_Date__c, status__c, serviceassignment__r.person_being_served__c, serviceassignment__c, serviceassignment__r.admission__c 
                    from evaluation__c
                    where Id = :evalID];
        
        admID = eval.serviceassignment__r.admission__c;
        saID = eval.serviceassignment__c;
                    
        pbs = [ select Id, Name, Birthdate, pbs_identifier__c, guardian1_name__c, Guardian_Phone_Number__c, advanced_directives__c, code_status__c
        		from contact
        		where id = :eval.serviceassignment__r.person_being_served__c ];
        		
        pbsID = pbs.Id;
    }
    
    /*
    // test constructor
    public CNANote_form(Action_Plan_Worksheet__c result) {
        this.controller = null;
        this.result = result;
    }
    */

    //public Attachment anotoXml {get;set;}
    public String pdfExistenceUrl {get;set;}
    
    
    public PageReference generatePaperForm() {
        try {
            this.pdfExistenceUrl = AnotoUtility.generatePdfByHandlerName('CNANotePage1',
                generatePrepopXml(eval.Id));
        } catch (AnotoUtility.PdfGenerationException e) {
            this.pdfExistenceUrl = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'There is an error generating the paper form. Please try again later.'));
        }
        return null;
    }
    
    
    
    private String generatePrepopXml(Id evaluationId) {
        XmlStreamWriter writer = AnotoUtility.startXmlWriter();
        writer.writeStartElement(null, 'SalesforceId', null);
        writer.writeCharacters(evaluationId);
        writer.writeEndElement();
        
        writer.writeStartElement(null, 'PBSName', null);
        writer.writeCharacters(pbs.Name);
        writer.writeEndElement();
        
        writer.writeStartElement(null, 'PBSNumber', null);
        writer.writeCharacters(pbs.pbs_identifier__c);
        writer.writeEndElement();
        
		writer.writeStartElement(null, 'DOB', null);
        writer.writeCharacters(pbs.Birthdate.format());
        writer.writeEndElement();
        
        writer.writeStartElement(null, 'Guardian', null);
        writer.writeCharacters(!String.IsBlank(pbs.Guardian1_name__c) ? pbs.Guardian1_name__c : '' );
        writer.writeEndElement();

        writer.writeStartElement(null, 'GuardianPhone', null);
        writer.writeCharacters(!String.IsBlank(pbs.Guardian_phone_number__c ) ? pbs.Guardian_phone_number__c  : '');
        writer.writeEndElement();
        
        writer.writeStartElement(null, 'ADField', null);
        writer.writeCharacters(pbs.advanced_directives__c ? 'Yes' : 'No');
        writer.writeEndElement();        
        
        writer.writeStartElement(null, 'CodeStatus', null);
        writer.writeCharacters(!String.IsBlank(pbs.code_status__c) ? pbs.code_status__c : '' );
        writer.writeEndElement();        

        // Using reflection, put all the fields in the record into the prepop
        // XML file following our naming convention.
        /*
        
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
        */
        return AnotoUtility.endXmlWriter(writer);
    }
    
    /*
    public PageReference anotoGenerate(){
        string txt = anotoGenerateDocument().toXmlString();
        // send to the print processor
        pdfExistenceUrl = AnotoUtility.generatePdfByHandlerName('CNANote', txt);
        
        // Allow preview of xml
        Blob txtBlob = Blob.valueOf(txt); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name ='text.xml';  
        attach.Body = txtBlob;
        attach.ContentType= 'application/xml'; //Signal what the file's MIME type is
        attach.ParentID = result.id;
        insert attach;
        anotoXml = attach;
        System.Debug('Xml Generated '+ anotoXml.Id + ' name: ' + anotoXml.Name);
        return null;
    }
    
    public Dom.Document anotoGenerateDocument() {
        AnotoXmlGeneration anoto = new AnotoXmlGeneration();
        system.debug('recordid:' + result.id);
        anoto.RecordId = result.Id;
        
        Decimal headerheight = 28;
        Decimal top = headerheight;
        integer page = 1;
        boolean pageinitialized = false;
        */
   /*     
        string background = EncodingUtil.base64Encode([select body from document where name = 'Skill_Tracking_Day_Background'].Body);
        for(ObjectiveWrapper wrapper: getObjectivesMap()){
            if (!pageinitialized)   {
                AnotoXmlGeneration.OutputPage headerPage = new AnotoXmlGeneration.OutputPage('c:\\FormBackground\\SkillWorksheet_05Dec13_Background1_flat.pdf', page); // use background in app definition
                anoto.Pages.add(headerPage);
                
                AnotoXmlGeneration.Widget personw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'person' + page.format() + getPersonId() );
                personw.WriteEnabled = false;
                personw.Layout(page, 6.0, 35.2, 20.0, 100.0); 
                personw.DefaultValue = getPersonName();
                anoto.Widgets.Add(personw);
        
                AnotoXmlGeneration.Widget formdatew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'day' + page.format() + result.Id );
                formdatew.WriteEnabled = false;
                formdatew.Layout(page, 6.0, 214.2, 20.0, 60.0); 
                formdatew.DefaultValue = DateTime.newInstance(result.start_date__c, Time.newInstance(0,0,0,0)).format('MMM dd yyyy');
                anoto.Widgets.Add(formdatew);
                
                AnotoXmlGeneration.Widget hiddenw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.hidepattern, 'hidden' + page.format() + result.Id );
                hiddenw.WriteEnabled = false;
                hiddenw.Layout(page, 0.0, 0.0, headerheight, 300.0); 
                anoto.Widgets.Add(hiddenw);
                
                pageinitialized = true;
            }
            Decimal left = 5.0;
            
            AnotoXmlGeneration.Widget objectivew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, wrapper.Objective.Id );
                    objectivew.WriteEnabled = false;
                    objectivew.Layout(page, top, left, 10.0, 300.0); 
                    objectivew.DefaultValue = 'Objective: ' + wrapper.Objective.Description__c;
                    anoto.Widgets.Add(objectivew);
            for(Date day:getDaysOfWeek()){
                
                // this represents 1 day of output
                // boxes start on x coordinates: 7.5, 18.3, 28.2, 37.4
                // first row starts on y coordinate 55
                // box size should be about 11.3x7.1 (wxh)
                if (wrapper.ResultsMap.get(day).Day__c == day){
                    AnotoXmlGeneration.Widget datew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                    new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,null).NodeName);
                    datew.WriteEnabled = false;
                    datew.Layout(page, top + 3.5, left, 10.0, 35.0); 
                    datew.FontSize = 6;
                    datew.DefaultValue = DateTime.newInstance(day, Time.newInstance(0,0,0,0)).format('MMM dd - E');
                    anoto.Widgets.Add(datew);

                    AnotoXmlGeneration.Widget bkg = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.image, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Bkg').NodeName);
                    bkg.DefaultValue = background;
                    bkg.Layout(page, top - 1 , left, 23.0, 39.0); 
                    anoto.Widgets.Add(bkg);

                    AnotoXmlGeneration.Widget attempts = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Attempts').NodeName);
                    attempts.Layout(page, top + 15, left, 8.0, 9.5); 
                    attempts.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.numeric;
                    anoto.Widgets.Add(attempts);
                    AnotoXmlGeneration.Widget status = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 
                                                                                     new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Status').NodeName); 
                    status.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.upper;
                    status.CharCount = 2;
                    status.Layout(page, top + 15, left + 9.5, 8.0, 9.5);
                    anoto.Widgets.Add(status);
                    AnotoXmlGeneration.Widget met = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 
                                                                                  new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Met').NodeName);
                    met.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.upper;
                    met.CharCount = 1;
                    met.Layout(page, top + 15, left + 19.5, 8.0, 6.0); 
                    anoto.Widgets.Add(met);
                    AnotoXmlGeneration.Widget initials = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Initials').NodeName);
                    initials.Layout(page, top + 15, left + 26, 8.0, 12.0);
                    initials.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.free;
                    anoto.Widgets.Add(initials);
                    if (wrapper.ResultsMap.ContainsKey(day)){
                        Action_Skill_Result__c result = wrapper.ResultsMap.get(day);
                        if (result.Attempts__c != null) {
                            attempts.DefaultValue = result.Attempts__c.format();
                        }
                        if (result.Status__c != null) {
                            status.DefaultValue = result.Status__c;
                        }
                        if (result.Met_Objective__c != null) {
                            met.DefaultValue = result.Met_Objective__c;
                        }
                        if (result.Initials__c != null) {
                            initials.DefaultValue = result.Initials__c;
                        }
                    }
                }
                // next set of boxes start on x coordinate: 46.9, then 84.3, then 123.5, then 161.6, then 198.6, then 234.9
                left += 39.0;
            }
            
            // next week starts on 78.3, same x coordinates
            top += 23;
            if (top > 200){
                page += 1;
                top = headerheight;
                pageinitialized = false;
            }
        }
        return anoto.GenerateDocument();
    }
}
*/
}