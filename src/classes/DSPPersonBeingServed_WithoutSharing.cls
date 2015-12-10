public without sharing class DSPPersonBeingServed_WithoutSharing {
    
    public Contact contact { get; private set; }
    public ID PBSId{get;set;}
    public boolean isCAFSS{get; set;}
    private TMN_User__c TMNUser {get; set;}
    private list<Related_Party__c> relParties { get; set; }
    public list<RelatedParty> relPartiesWrapper { get; set; } 
    public class RelatedParty{
        public Id Id{get; set;}
        public String typeC{get; set;}
        public String name{get; set;}
        public String address{get; set;}
        public String email{get; set;}
        public String phone{get; set;}
        public String phone_1_Type{get; set;}
        public String phone_2{get; set;}
        public String phone_2_Type{get; set;}
        public String status{get; set;}
        public String comments{get; set;}
        RelatedParty(Related_Party__c rp) {
            this.Id = rp.Id;
            this.typeC = rp.type__c;
            this.name = rp.name;
            this.address = rp.address__c;
            this.email = rp.email__c;
            this.phone = rp.phone__c;
            this.phone_1_Type = rp.phone_1_Type__c;
            this.phone_2 = rp.phone_2__c;
            this.phone_2_Type = rp.phone_2_type__c;
            this.status = rp.status__c;
            this.comments = rp.comments__c;
        }
    }
    
    public map<String, list<Evaluation_Response__c>> mapEvalResponses = new map<String, list<Evaluation_Response__c>>();
    public map<String, list<Evaluation_Response__c>> getMapEvalResponses(){ return this.mapEvalResponses; }
    public String evalResponsesTypes { get; private set; }
    public map<String, list<String>> mapEvalResponseFlds = new map<String, list<String>>();
    public map<String, list<String>> getmapEvalResponseFlds(){ return this.mapEvalResponseFlds; }
    public map<String, String> mapEvalResponseFldLbls = new map<String, String>();
    public map<String, String> getmapEvalResponseFldLbls(){ return this.mapEvalResponseFldLbls; }
    public map<String, map<string, string>> mapCustomLabels = new map<string, map<string, string>>();
    public map<String, map<string, string>> getmapCustomLabels() { return this.mapCustomLabels; }
    public map<string, string> customlabelslist { get; set; }
    
    // Filter some of the Additional Info Fields
    public string dontShowFields {
        get {
            system.debug('OpGroup:' + TMNUser.Operating_Group__c);
            List<string> dontshow = new List<string>();
            if (TMNUser == null || TMNUser.Operating_Group__c != 'Cambridge' || !isCAFSS){
                dontshow.Add('Current_Medications__c');
            }        
            if ( (TMNUser.Operating_Group__c.indexOf('Care') < 0) && (TMNUser.Operating_Group__c.indexOf('Meridian') < 0) ) {
                dontshow.Add('Advanced_Directives__c');
                dontshow.Add('Code_Status__c');
                dontshow.Add('Code_Status_Other__c');
                dontshow.Add('Advanced_Directives_Attached__c');
            }
            return ' ' + String.Join(dontshow, ',');
        }
    }
    // In order to show field labels instead of API names for history
    public Map<String, String> fieldMap { get; set; }
    
    public DSPPersonBeingServed_WithoutSharing(Id pbsId) {
        this.PBSId=pbsId;
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Contact').getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
        }
        if (!selectFields.isEmpty()) {
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        String strSQL =  'SELECT ' + selects + ' FROM Contact WHERE Id = \'' + pbsId + '\'';
        //strSQL = strSQL.Replace('SELECT ', 'SELECT Service_Assignment__r.Admission__r.Name,Service_Assignment__r.Name, Service_Assignment__r.Service_Location__r.Service_Value__c, Service_Assignment__r.Service_location__r.ProgramID__c, Service_Assignment__r.Flavor__c, ');
        contact = ((List<Contact>)Database.query(strSQL))[0];
        
        this.relParties = new List<Related_Party__c>();
        populateRelParties();
        
        populateMapEvalResponses();
        
        getDiagnosisList();
        
        Map<String, Schema.SObjectField> tempMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        fieldMap = new Map<String, String>();
        for (String fieldName: tempMap.keySet()) {
            fieldMap.put(fieldName, tempMap.get(fieldName).getDescribe().getLabel());
        }
        
        this.TMNUser = [SELECT ID, Operating_Group__c, Business_Unit__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:contact.OwnerID LIMIT 1];        
        isCAFSS = (null != TMNUser.Business_Unit__c && TMNUser.Business_Unit__c.startswith('BU 008')) ? true : false;
    }
    
    //    public List<Task> taskOnCurrentPBSAccount{get{ return [select id,WhoId,Who.Name,Owner.Name,WhatID,Status,subject,OwnerId,LastModifiedDate from Task where WhatId=:contact.AccountId order by createddate desc limit 10];}set;}
    //    public List<Event> eventOnCurrentPBSAccount{get{return [select id, WhoId,subject,LastModifiedDate ,Who.Name,whatId,ActivityDate,OwnerId,Owner.Name from Event where WhatId=:contact.AccountId order by createddate desc limit 10];}set;}
    //    public List<AccountHistory> personHistory{get{return [SELECT CreatedDate, Field, OldValue, NewValue, CreatedBy.Name FROM AccountHistory where Account.personContactId=:contact.AccountId ORDER BY CreatedDate DESC];} set;}
    //    public List<Admission__c> admissions{get{return [select id,Name, Admission_Effective_DateTime__c, Discharged_Date__c, Effective_Date__c, Status__c  from Admission__c where Person_Being_Served__c=:contact.Id ];}set;}
    public Boolean showDiagnosis { get {
        if (TMNUser == null) {
            return false;
        }
        return TMNUser.Operating_Group__c=='Redwood' || TMNUser.Operating_Group__c=='Cambridge' || TMNUser.Operating_Group__c=='NeuroRestorative' || isCAFSS;
    }}
    
    public list<DiagnosisWrapper> diaglist { get; set; }
    public class DiagnosisWrapper {
        public ID id { get;set; }
        public String name { get; set; }
        public ID icd { get; set; }
        public string icdname { get; set; }
        public string codetype { get; set; }
        public string icddesc { get; set; }
        public string diagtype { get; set; }
        public string status { get; set; } 
        public datetime effdate { get; set; }
        
        public DiagnosisWrapper( ID i, string n, string icdn, string ct, string cd, string t, string s, datetime e ) {
            id = i;
            name = n;
            icdname = icdn;
            codetype = ct;
            icddesc = cd;
            diagtype = t;
            status = s;
            effdate = e;
        }
    }
    
    private void getDiagnosisList () {
        list<Diagnosis__c> diagnosis = [select Id, Name, ICD__c, ICD__r.name, ICD__r.Code_Type__c, ICD__r.Icd_Description__c, PBS__c, Type__c, Status__c, Effective_Date__c 
                                        from Diagnosis__c
                                        where PBS__c = :contact.Id order by Status__c, Type__c];
        
        diaglist = new List<DiagnosisWrapper>();
        for (Diagnosis__c d: diagnosis) {
            diaglist.add( new DiagnosisWrapper( d.id, d.name, d.icd__r.name, d.icd__r.code_type__c, d.icd__r.icd_description__c, d.type__c, d.status__c, d.effective_date__c));
        }
    }    
    private void populateRelParties() {
        try {
            this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                               Person_Being_Served__c, Status__c
                               from Related_Party__c
                               where Person_Being_Served__c = :pbsId order by Type__c, Name
                              ];
            
            relPartiesWrapper = new List<RelatedParty>();                 
            for (Related_Party__c rp : this.relParties){
                relPartiesWrapper.add(new RelatedParty(rp));
            }
            
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred retrieving Related Parties. ' + e.getMessage()));
        }
    }
    
    private void populateMapEvalResponses(){
        String fieldSetLbl='';
        String fieldName='';
        String fieldLbl='';
        List<Schema.FieldSet> allFieldSets = Schema.SObjectType.Evaluation_Response__c.FieldSets.getMap().values();
        for (Schema.FieldSet fieldSet: allFieldSets) {
            fieldSetLbl = fieldSet.getLabel();
            if (!mapEvalResponseFlds.containsKey(fieldSetLbl)) { 
                mapEvalResponseFlds.put(fieldSetLbl, new list<String>());
            }
            for (Schema.FieldSetMember column: fieldSet.getFields()) {
                fieldName = column.getFieldPath();
                fieldLbl = column.getLabel();
                mapEvalResponseFlds.get(fieldSetLbl).add(fieldName);
                mapEvalResponseFldLbls.put(column.getFieldPath(), column.getLabel());
            }            
        }
        
        String selects = '';
        list<string> selectFields = new list<string>();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Evaluation_Response__c').getDescribe().fields.getMap();
        for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            selectFields.add(fd.getName());
        }
        selectFields.add('RecordType.Name');
        if (!selectFields.isEmpty()) {
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        String strSQL =  'SELECT ' + selects + ' FROM Evaluation_Response__c WHERE Person_Being_Served__c = \'' + this.pbsId + '\'';
        list<Evaluation_Response__c> evalResponses = (list<Evaluation_Response__c>) Database.query(strSQL);          	
        for(Evaluation_Response__c evalRes : evalResponses){
            if(!mapEvalResponses.containsKey(evalRes.RecordType.Name)) mapEvalResponses.put(evalRes.RecordType.Name, new list<Evaluation_Response__c>());
            mapEvalResponses.get(evalRes.RecordType.Name).add(evalRes);
        }
        evalResponsesTypes = String.join((new list<String>(this.mapEvalResponses.keyset())),',');
        
        // get custom labels to override the map headers
        customlabelslist = new Map<String, String>();
        mapCustomLabels.put('PPD Skin Test',  new Map<string, string>{'Time_Given__c'=>'Date Administered','Time_Observed__c' =>'Date Read'});
        List<string> tmp = new List<string>(mapcustomlabels.get('PPD Skin Test').keyset());
        
        customlabelslist.put( 'PPD Skin Test', string.join(tmp, ','));
    }
    
}