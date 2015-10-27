public without sharing class DSPPersonBeingServed_WithoutSharing {

public Contact contact { get; private set; }
public ID PBSId{get;set;}
public Agency_Involved_With_Individual__c agency { get; set; }
public string loadThisAgency {get; set;}

private TMN_User__c TMNUser_internal;
private boolean TMNUser_set = false;

public boolean isCAFSS{get; set;}

@TestVisible private TMN_User__c TMNUser {
    get {
        if (!TMNUser_set) {
            TMN_User__c[] users = [
                SELECT ID, Operating_Group__c, Business_Unit__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:contact.OwnerID LIMIT 1
            ];
            if (users.size() == 0) {
                TMNUser_internal = null;
            } else {
                TMNUser_internal = users[0];
            }
            TMNUser_set = true;
        }
        return TMNUser_internal;
    }}
  
  public List<Related_Party__c> relParties { get; set; }

  public class RelatedParty{
     Id Id;
     String TypeC;
     RelatedParty(Id id, String typeC){
        this.Id=id;
        this.TypeC = typeC;
     }
  }
  
  public List<Agency_Involved_With_Individual__c> relAgencies { get; set; }

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

  // In order to show field labels instead of API names for histo ry
  public Map<String, String> fieldMap { get; set; }
    //for EPRIQM-51
    private boolean setdisableAddAdm() {
        if(TMNUser!=null && (TMNUser.Operating_Group__c == 'Care Meridian'  || TMNUser.Operating_Group__c == 'Cambridge' || TMNUser.Operating_Group__c == 'NeuroRestorative'  || TMNUser.Operating_Group__c == 'Redwood' || isCAFSS)) {
        List<Admission__c>  admissionList=[select id,Name,Discharged_Date__c, Admission_Effective_DateTime__c, Effective_Date__c, Status__c  from Admission__c where  Discharged_Date__c  = null and Person_Being_Served__c =: PBSId];
        if(admissionList.size()>0){
          return false;
        } else {
             return true;
        }
    }
    return true;
    }
    
    public DSPPersonBeingServed_WithoutSharing(TMN_User__c TMNUser, Boolean showDiagnosis){
    	this.TMNUser = TMNUser;
    	this.showDiagnosis = showDiagnosis;
    }
    
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

        this.relAgencies = new List<Agency_Involved_With_Individual__c>();
        populateAgencies();
        
        Map<String, Schema.SObjectField> tempMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        fieldMap = new Map<String, String>();
        for (String fieldName: tempMap.keySet()) {
            fieldMap.put(fieldName, tempMap.get(fieldName).getDescribe().getLabel());
        }
        
        //check for CA FSS - CAFSS-8 Sravan Sep 9, 2015.
        isCAFSS = (null != TMNUser.Business_Unit__c && TMNUser.Business_Unit__c.startswith('BU 008')) ? true : false;
    }
   
//    public List<Task> taskOnCurrentPBSAccount{get{ return [select id,WhoId,Who.Name,Owner.Name,WhatID,Status,subject,OwnerId,LastModifiedDate from Task where WhatId=:contact.AccountId order by createddate desc limit 10];}set;}
//    public List<Event> eventOnCurrentPBSAccount{get{return [select id, WhoId,subject,LastModifiedDate ,Who.Name,whatId,ActivityDate,OwnerId,Owner.Name from Event where WhatId=:contact.AccountId order by createddate desc limit 10];}set;}
    public List<AccountHistory> personHistory{get{return [SELECT CreatedDate, Field, OldValue, NewValue, CreatedBy.Name FROM AccountHistory where Account.personContactId=:contact.AccountId ORDER BY CreatedDate DESC];} set;}
   
    public String currentUrl { get {
        return ApexPages.currentPage().getUrl();
    }}

//    public List<Admission__c> admissions{get{return [select id,Name, Admission_Effective_DateTime__c, Discharged_Date__c, Effective_Date__c, Status__c  from Admission__c where Person_Being_Served__c=:contact.Id ];}set;}
    public Boolean showDiagnosis { get {
        if (TMNUser == null) {
            return false;
        }
        return TMNUser.Operating_Group__c=='Redwood'
            || TMNUser.Operating_Group__c=='Cambridge'
            //added by Amruth for EB-430
            || TMNUser.Operating_Group__c=='NeuroRestorative'
            || isCAFSS;
    }}
    public list<Diagnosis__c> diagnosis{get{
        return [select id, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id')];
    } set;}
    public List<Evaluation_Response__c> getAssessments_ChildImmune (){

        return [select id, Name  from Evaluation_Response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType('Immunization - Child') AND Person_Being_Served__c = :contact.id ];
    }  
    public List<Evaluation_Response__c> getAssessments_AdultImmune (){

        return [select id, Name  from Evaluation_Response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType('Immunization - Adult') AND Person_Being_Served__c = :contact.id ];
   }
    public list<string> getImmuneReqFields(){
      list<string> tmp = new list<string>();
      tmp.add('Allergy_Details__c');
      tmp.add('Life_Threatening__c');
      tmp.add('Date__c');
      tmp.add('Dosage__c');
      tmp.add('Vaccine_Type__c');
      tmp.add('Dosage_Number__c');
      tmp.add('Location__c');
      tmp.add('Lot__c');
      tmp.add('Expiration_Date__c');
      tmp.add('Administered_By__c');
      return tmp;
    }    

     public List<Attachment> Attachments{
        get{
            
            if(Attachments==null){
                Attachments= [select Id, ParentId, Name, Description from Attachment where parentId=:PBSId];
            }
            return Attachments;
        }
        set;
    }
    
    private void populateRelParties() {
    try {
        this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Served__c, Status__c
                         from Related_Party__c
                         where Person_Being_Served__c = :pbsId order by Type__c, Name
                         ];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
   private void populateAgencies() {
    try {
      this.relAgencies = [select Name, Address__c, Person_Being_Served__c, Phone__c, Reason_for_Involvement__c, Referral__c
                         from Agency_Involved_with_Individual__c
                         where Person_Being_Served__c = :pbsId
                         ];      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }

  public PageReference loadAgency(){
    for(Agency_Involved_With_Individual__c agy : relAgencies){
      if(agy.id == loadThisAgency){
        agency = agy;
      }
    }
    return null;
  }

    public id getRelatedPartyReport(){
        id theId;
        theID = [select id, developername from report where developername = 'Related_Party_for_PBS' limit 1].id;
        return theId;
    }

}