public with sharing class PBSedit_controller {

public static Id admissionId;
public boolean UnderAgePageMsg{get;set;}
public boolean pbsEditModeOn{get;set;}
public ApexPages.StandardController PBSController{get;set;}
public String PageMessage{get;set;}
public Contact currentContact{ get { return [ select id, accountid, ownerid from contact where id = :pbsId]; }
									set; }
public ID PBSId{get;set;}
public boolean isEditor{get; set;}
public boolean canEdit{get; set;}
public boolean canCreateAdm { get; set; }
public Boolean isUserLevel1or2 { get { return PBS_controller_helper.isUserLevel1or2();} set; }
 
  public Related_Party__c relParty {
    get {
      if (relParty == null)
        relParty = new Related_Party__c();
      return relParty;
    }
    set;
  }
  
  public List<Related_Party__c> relParties { get; set; }
  public List<Agency_Involved_With_Individual__c> relAgencies { get; set; }

// In order to show field labels instead of API names for history
public Map<String, String> fieldMap { get; set; }

    public void showEditMode(){
        system.debug('-----');
        pbsEditModeOn=true;
    }    


    private void setIsEditor() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.currentContact.Id ];

        if (acls.size() > 0) {
            isEditor = acls[0].HasEditAccess;
        } else { isEditor = false;}
    }
    
    private void setcanEdit() {
	   	Schema.DescribeSObjectResult oSchema = Contact.sObjectType.getDescribe();
		canEdit = oSchema.IsUpdateable();
    }
    
    private void setcanCreateAdm() {
    	Schema.DescribeSObjectResult admSchema = Admission__c.sObjectType.getDescribe();
		canCreateAdm = admSchema.IsCreateable();
    }
    
    public PBSedit_controller(ApexPages.StandardController controller) {

        this.currentContact=(Contact)controller.getRecord();
        pbsEditModeOn=false;
        PBSId=Apexpages.currentPage().getParameters().get('Id');
	    this.relParties = new List<Related_Party__c>();
	    populateRelParties();

		this.relAgencies = new List<Agency_Involved_With_Individual__c>();
	    populateAgencies();
	    
        Map<String, Schema.SObjectField> tempMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        fieldMap = new Map<String, String>();
        for (String fieldName: tempMap.keySet()) {
            fieldMap.put(fieldName, tempMap.get(fieldName).getDescribe().getLabel());
        }
        
        setIsEditor();
        setcanEdit();
        setcanCreateAdm();
        
        if (ApexPages.currentPage().getParameters().get('edit') == 'true' && IsEditor) {
        	showEditMode();
        }
        
        
    }
   
    public List<Task> taskOnCurrentPBSAccount{get{ return [select id,WhoId,Who.Name,Owner.Name,WhatID,Status,subject,OwnerId,LastModifiedDate from Task where WhatId=:currentContact.AccountId];}set;}
    public List<Event> eventOnCurrentPBSAccout{get{return [select id, WhoId,subject,LastModifiedDate ,Who.Name,whatId,ActivityDate,OwnerId,Owner.Name from Event where WhatId=:currentContact.AccountId];}set;}
    public List<AccountHistory> personHistory{get{return [SELECT CreatedDate, Field, OldValue, NewValue, CreatedBy.Name FROM AccountHistory where Account.personContactId=:Apexpages.currentPage().getParameters().get('Id') ORDER BY CreatedDate DESC];} set;}
   
   
    public String currentUrl { get {
        return ApexPages.currentPage().getUrl();
    }}

    public List<Admission__c> admissions{get{return [select id,Name,Discharged_Date__c, Effective_Date__c, Status__c  from Admission__c where Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id') ];}set;}
	public Boolean showDiagnosis { get {
        TMN_User__c[] tmnUsers = [
            SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:currentContact.OwnerID LIMIT 1
        ];
        if (tmnUsers.size() == 0) {
            return false;
        }
        return tmnUsers[0].Operating_Group__c=='Redwood';
    }}
	public list<Diagnosis__c> diagnosis{get{
        return [select id, Service_Assignment__r.Name, Service_Assignment__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id')];
    } set;}

	public pageReference deleteAdmission(){
	Admission__c  admission=[select id,Name,Discharged_Date__c, Effective_Date__c, Status__c  from Admission__c where id=:Apexpages.currentpage().getparameters().get('admissionId')];
	delete admission;
	return null;
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
                                Person_Being_Served__c
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
    
public void showAddRelParty() {
    relParty = new Related_Party__c();
  }

  public void saveRelParty() {
    populateRelParties();
    this.relParty = new Related_Party__c();
  }
    
 public void createRelParties() {
    if (relParties != null && currentContact.Id != null) {
      for (Related_Party__c rP : relParties) {
        rP.Person_Being_Served__c = currentContact.Id;
      }

      upsert relParties;
    }
  }
    

public pageReference cancelPBSController(){
	
	pbsEditModeOn=false;
	return null;

}

}