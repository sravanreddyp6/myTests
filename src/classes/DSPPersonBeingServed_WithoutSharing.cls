public without sharing class DSPPersonBeingServed_WithoutSharing {

public Contact contact { get; private set; }
public ID PBSId{get;set;}
public Agency_Involved_With_Individual__c agency { get; set; }
public boolean isCAFSS{get; set;}
private TMN_User__c TMNUser {get; set;}
private list<Related_Party__c> relParties { get; set; }
public list<RelatedParty> relPartiesWrapper { get {
    list<RelatedParty> relPartyWarpper = new list<RelatedParty>();
    for (Related_Party__c rp : this.relParties){
    	relPartyWarpper.add(new RelatedParty(rp));
    }
    return relPartyWarpper;
} private set; }
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
public map<String, list<Evaluation_Response__c>> mapEvalResposes = new map<String, list<Evaluation_Response__c>>();
public map<String, list<Evaluation_Response__c>> getMapEvalResposes(){ return this.mapEvalResposes; }
public String evalResposesTypes { get; private set; }
public map<String, list<String>> mapEvalResposeFlds = new map<String, list<String>>();
public map<String, list<String>> getmapEvalResposeFlds(){ return this.mapEvalResposeFlds; }
public map<String, String> mapEvalResposeFldLbls = new map<String, String>();
public map<String, String> getmapEvalResposeFldLbls(){ return this.mapEvalResposeFldLbls; }
 
//  public List<Agency_Involved_With_Individual__c> relAgencies { get; set; }

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

//        this.relAgencies = new List<Agency_Involved_With_Individual__c>();
//        populateAgencies();

        populateMapEvalResposes();
        
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
    public list<Diagnosis__c> diagnosis{get{
        return [select id, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id')];
    } set;}
    
  private void populateRelParties() {
    try {
        this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Served__c, Status__c
                         from Related_Party__c
                         where Person_Being_Served__c = :pbsId order by Type__c, Name
                         ];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
  
  private void populateMapEvalResposes(){
        String fieldSetLbl='';
        String fieldName='';
        String fieldLbl='';
        List<Schema.FieldSet> allFieldSets = Schema.SObjectType.Evaluation_Response__c.FieldSets.getMap().values();
        for (Schema.FieldSet fieldSet: allFieldSets) {
            fieldSetLbl = fieldSet.getLabel();
            if (!mapEvalResposeFlds.containsKey(fieldSetLbl)) { 
                mapEvalResposeFlds.put(fieldSetLbl, new list<String>());
            }
            for (Schema.FieldSetMember column: fieldSet.getFields()) {
                fieldName = column.getFieldPath();
                fieldLbl = column.getLabel();
                mapEvalResposeFlds.get(fieldSetLbl).add(fieldName);
                mapEvalResposeFldLbls.put(column.getFieldPath(), column.getLabel());
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
            if(!mapEvalResposes.containsKey(evalRes.RecordType.Name)) mapEvalResposes.put(evalRes.RecordType.Name, new list<Evaluation_Response__c>());
            mapEvalResposes.get(evalRes.RecordType.Name).add(evalRes);
        }
        evalResposesTypes = String.join((new list<String>(this.mapEvalResposes.keyset())),',');
  }
   
//  private void populateAgencies() {
//    try {
//      this.relAgencies = [select Name, Address__c, Person_Being_Served__c, Phone__c, Reason_for_Involvement__c, Referral__c
//                         from Agency_Involved_with_Individual__c
//                         where Person_Being_Served__c = :pbsId
//                         ];      }
//    catch (Exception e) {
//      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
//        'An error occurred retrieving Related Parties. ' + e.getMessage()));
//    }
//  }
}