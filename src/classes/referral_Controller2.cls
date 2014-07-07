/*******************************************************************************
 Name           : referrals_Controller
 Created By     : Mark Klinski (Appirio)
 Created Date   : 4/23/13
 Description    : Extension Controller for Referrals
*******************************************************************************/


public with sharing class referral_Controller2 {

  public class FundingSourceDecimalException extends Exception {}

  public String OperatingGroup{
      get{
          if(operatinggroup!=null && operatinggroup!='' && operatingGroup.equalsIgnoreCase('Care Meridian')){
              operatinggroup = 'CareMeridian';
          }
          return operatinggroup;
      }
      set;
  }
  public String ReferralRecordType{
      get{
          if(this.ReferralRecord.RecordTypeId != null){
              referralRecordType = Utility.getRecordTypeForReferral(Id.valueOf(this.ReferralRecord.RecordTypeId));
          }
          return referralRecordType;
      }
      set;
  }
  public Referral__c referralRecord { get; set; }
  public Person_Being_Referred__c personBeingRefRecord { get; set; }
  public Contact personBeingServedRecord { get; set; }
  public List<Person_Being_Referred__c> refResults { get; set; }
  public ID referralLocationId { get; set; }
  public String referralLocationName { get; set; }
  public Map<Id, Boolean> editableTasks { get; set; }
  public Boolean isCambridge { get; set; }
  public Boolean isCareMeridian{get; set;}
  
     
    public List<Attachment> Attachments{
        get{

            if(Attachments==null){
                Attachments= [select Id, ParentId, Name, Description from Attachment where parentId=:this.referralRecord.Id];
            }
            return Attachments;
        }
        set;
    }

   /****************************************************/
  public Task activity {
      get {
          if (activity == null) {
              activity = new Task();
              activity.Priority = 'Normal';
              activity.OwnerId = UserInfo.getUserId();
              activity.Status = 'Not Started';
          }
          return activity;
      }
      private set; }
  public List<Task> activities { get; set; }
  public Agency_Involved_With_Individual__c agency { get; set; }
  public List<Agency_Involved_With_Individual__c> agencies { get; set; }
  public Funding_Source__c fundingSource {
      get{
          if (fundingSource == null) {
            fundingSource = new Funding_Source__c();
            fundingSource.RecordTypeId = Utility.getFundingSourceRecordTypeFromReferral(this.ReferralRecord);
          }
          return fundingSource;
      }
      private set; }
  public List<Funding_Source__c> fundingSources { get; set; }
  public Related_Party__c relParty { get; set; }
  public List<Related_Party__c> relParties { get; set; }
  public Referral_Location__c location { get; set; }
  public List<Referral_Location__c> locations { get; set; }
    public List<Referral__c> relatedReferrals {get;set;}
  public Id currentRefId {
    get {
      return (currentRefId == null) ? null :
        apexpages.currentpage().getparameters().get('id');
    }
    set;
  }
  private Id personBeingRefId {get; set;}
  public Id pBRId { get; set; }
  private Id personBeingServedId {get; set;}
  public Id pBSId { get; set; }
  public boolean isEditor{get; set;}
  public boolean canConvert{ get { 
    
        Set<string> RWStates = new Set<string>{'Minnesota', 'California', 'Indiana'};
        system.debug( 'Ref record type: ' + referralrecordtype );
        system.debug(' is cambridge:' + iscambridge);
        system.debug(' operatinggroup:' + operatinggroup);
        return ((operatinggroup == 'Cambridge' && isCambridge )|| (operatinggroup == 'Redwood' && RWStates.contains( referralrecordtype ) ) ); // Add this line to make the convert button available for CareMeridian group || (operatinggroup == 'CareMeridian') && isCareMeridian  
    } set;}
    

  public static final String REFERRAL_EDIT_URL = '/apex/referral';
  public static final String REFERRAL_CONVERT_URL = '/apex/referralConversion';

  public referral_Controller2(ApexPages.standardController ctl){
    system.debug('in constructor');
    this.referralRecord = (Referral__c) ctl.getRecord();
    this.operatinggroup=([select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].isEmpty())?''
                            :[select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1][0].operating_group__c;
    this.referralRecord = (Referral__c) ctl.getRecord();
    this.agencies = new List<Agency_Involved_With_Individual__c>();
    this.fundingSources = new List<Funding_Source__c>();
    this.relParties = new List<Related_Party__c>();
    this.activities = new List<Task>();
    this.editableTasks = new Map<Id, Boolean>();
    this.locations = new List<Referral_Location__c>();

    system.debug( this.referralRecord);

     getPBRId();
     system.debug( 'PBR= '+ pBRid);
    getPBSId();

    if (pBRId != null) {
      this.personBeingRefRecord = getPBRRec();
      populateRelParties();
    } else {
      this.personBeingRefRecord = new Person_Being_Referred__c();
    }

    if (this.referralRecord.Person_Being_Referred__c == null) {
      this.referralRecord.Person_Being_Referred__c = pBRId;
    }

    if (pBSId != null) {
      this.personBeingServedRecord = getPBSRec();
      populateRelParties();
    } else {
      this.personBeingServedRecord = new Contact();
    }

    if (this.referralRecord.Person_Being_Served__c == null) {
      this.referralRecord.Person_Being_Served__c = pBSId;
    }
    if (this.referralRecord.Id != null) {
      populateRefRelLists();
    }

    setIsEditor();
    isCambridge = false;
    isCareMeridian = false;
    referralRecordType= (this.ReferralRecord.RecordTypeId != null)?Utility.getRecordTypeForReferral(Id.valueOf(this.ReferralRecord.RecordTypeId)):'';//(this.ReferralRecord.RecordType.Name!=null)?this.ReferralRecord.RecordType.Name:[select name from recordtype where id=:this.referralRecord.recordTypeId limit 1].name;
    if(referralRecordType.startsWith('Cambridge')) {
        isCambridge = true;
    }
    if(referralRecordType.startsWith('CareMeridian')){
        isCareMeridian = true;
    }
  }

    private void setIsEditor() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.referralRecord.Id ];

        if (acls.size() > 0) {
            isEditor = acls[0].HasEditAccess;
        } else { isEditor = false;}
    }

    public PageReference addEvaluation() {
        String pbrLastName = [
            SELECT Person_Being_Referred__r.Last_Name__c FROM Referral__c
            WHERE Id=:referralRecord.Id
        ].Person_Being_Referred__r.Last_Name__c;
        if (pbrLastName == null) pbrLastName = '';
        Evaluation__c eval = new Evaluation__c(
            Referral__c = referralRecord.Id,
            RecordtypeId = Utility.getEValuationRecordType('CareMeridian'),
            Name = pbrLastName + 'Eval' + DateTime.Now().format('MMddyy')
        );
        insert eval;
        
        // ERC-93 - fill evaluated by field on Referral with current user
        TMN_User__c curruser = [ select id from tmn_user__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
        referralRecord.evaluated_by_internal__c = curruser.id;
        referralRecord.Has_Evaluation__c = true;
        update referralRecord;
        
        return new PageReference('/' + eval.Id + '/e');
    }

  private void populateRelParties() {
      if (this.personBeingRefRecord.Id == null && this.personBeingServedRecord.Id == null)
          return;

    try {
      if(this.personBeingRefRecord != null && this.personBeingRefRecord.Id != null){
      this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c,
                                Person_Being_Referred__c
                         from Related_Party__c
                         where Person_Being_Referred__c = :this.personBeingRefRecord.Id order by Type__c, Name
                         limit 150];
        }else if(this.personBeingServedRecord != null && this.personBeingServedRecord.Id != null){
        this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Referred__c, Person_Being_Served__c
                         from Related_Party__c
                         where Person_Being_Served__c = :this.personBeingServedRecord.Id order by Type__c, Name
                         limit 150];
      }

    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }

    private void populateLocations() {
        this.locations =
        [select Id, Name, Referral__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c, status__c,
            service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c,service_location_program__c,
            service_location_service_value__c, service_location_setting__c, service_location__c, rank__c, LastModifiedDate
         from Referral_Location__c
         where Referral__c = :this.referralRecord.Id
         limit 150];
  }
    private void populateAgencies() {
        this.agencies =
        [select Id,Name,
                Address__c,
                Phone__c,
                Reason_for_Involvement__c,
                        Referral__c
         from Agency_Involved_With_Individual__c
         where Referral__c = :this.referralRecord.Id
         limit 150];
    }

    private void populateFundingSources() {
        this.fundingSources =
        [select id, Payor__c, Funding_Source__c, Funding_Source_ID__c, Status__c, Service_Being_Funded__c, Comment__c, Referral__c,
         type_of_coverage__c, payer_name__c, effective_date__c, termination_date__c
         from Funding_Source__c
         where Referral__c = :this.referralRecord.Id
         order by Type_of_Coverage__c
         limit 150];
    }

    private void populateActivities() {
        this.activities = [select Id, Subject, Priority, Status, WhatId, OwnerId,
                                ActivityDate, Comments__c , Description
                         from Task
                         where WhatId = :this.referralRecord.Id
                         limit 150];
        // We also have to make only users with correct permissions can see the
        // Edit button
        Id[] taskIds = new Id[]{};
        for (Task task: activities) {
            taskIds.add(task.ID);
        }
        UserRecordAccess[] recordAccess = [
            SELECT RecordId, HasEditAccess FROM UserRecordAccess
            WHERE UserId=:UserInfo.getUserId()
              AND RecordId IN :taskIds
        ];
        for (UserRecordAccess ra: recordAccess) {
            editableTasks.put(ra.RecordId, ra.HasEditAccess);
        }
    }


  private void populateRefRelLists() {
    if (this.referralRecord.Id == null) {
      return;
    }

    try {
      populateAgencies();
      populateFundingSources();
      populateLocations();
          populateActivities();
      if (this.personBeingServedRecord != null && this.personBeingServedRecord.Id != null) {
          this.relatedReferrals = [select Id, Name, Referral_Status__c from Referral__c
                               where Person_Being_Served__c = :this.personBeingServedRecord.Id and id != :this.referralRecord.Id
                               order by Name];
      } else if (this.personBeingRefRecord != null && this.personBeingRefRecord.Id != null) {
      this.relatedReferrals = [select Id, Name, Referral_Status__c from Referral__c
                               where Person_Being_Referred__c = :this.personBeingRefRecord.Id and id != :this.referralRecord.Id
                               order by Name];
      }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }

  private void getPBRId() {
    Id pBRIdParam;

    try {
      pBRIdParam = ApexPages.currentPage().getParameters().get('pBRId');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. ' + e.getMessage()));
    }

    pBRId = (this.referralRecord.Person_Being_Referred__c != null) ? this.referralRecord.Person_Being_Referred__c : pBRIdParam;
  }

  private Person_Being_Referred__c getPBRRec() {
    Person_Being_Referred__c pBRRec;
    try {
      pBRRec = [select Age__c, City__c, Date_of_Birth__c, Email_Address__c,
                       Race__c, Ethnicity__c, Fax__c, First_Name__c, Gender__c,
                       Home_County__c, Last_Name__c, Marital_Status__c,
                       Middle_Initial__c, Phone__c, Primary_Language__c, SSN__c,
                       State__c, Street_1__c, Street_2__c, Zip_Code__c,
                       Additional_Information_Comments__c, Sign_Language__c,
                       Legal_Guardianship_Status__c, Non_Verbal__c, Full_Name__c
                from Person_Being_Referred__c
                where Id = :pBRId
                limit 1];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. ' + e.getMessage()));
    }
    return pBRRec;
  }
  private void getPBSId() {
    Id pBSIdParam;

    try {
      pBSIdParam = ApexPages.currentPage().getParameters().get('pBSId');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. ' + e.getMessage()));
    }

    pBSId = (this.referralRecord.Person_Being_Served__c != null) ? this.referralRecord.Person_Being_Served__c : pBSIdParam;
  }

  private Contact getPBSRec() {
    Contact pBSRec;
    try {
        pBSRec = [select Age__c, MailingCity, BirthDate, Email,
                       Fax, FirstName, Gender__c,
                       LastName, Ethnicity_Picklist__c,
                       Middle_Name__c, Phone, Primary_Language__c, SSN__c,
                       MailingState, MailingStreet, OtherStreet, MailingPostalCode
                from Contact
                where Id = :pBSId
                limit 1];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. ' + e.getMessage()));
    }
    return pBSRec;
  }
  public void showAddActivity() {
    activity = new Task();
      activity.Priority = 'Normal';
      activity.OwnerId = UserInfo.getUserId();
      activity.Status = 'Not Started';
  }

  public void saveActivity() {
    populateActivities();
    activity = new Task();
    activity.Priority = 'Normal';
    activity.OwnerId = UserInfo.getUserId();
    activity.Status = 'Not Started';
  }

  public void showAddAgency() {
    this.agency = new Agency_Involved_With_Individual__c();
  }

  public void saveAgency() {
    populateAgencies();
    this.agency = new Agency_Involved_With_Individual__c();
  }

  public void showAddFundingSource() {
    fundingSource = new Funding_Source__c();
    fundingSource.RecordTypeId = Utility.getFundingSourceRecordTypeFromReferral(this.ReferralRecord);
    
    List<RecordType> cmrt = [ select id from recordtype where sobjecttype='Funding_Source__c' and developername = 'CareMeridian_FS'];
    if (cmrt.size() > 0) {
        ID CMID = cmrt[0].Id;
        if ( fundingSource.RecordTypeId == CMID)
            fundingSource.Authorization_type__c = 'Initial'; // set default value that is not being honored in late render on jquery dialog
    }
    
    fundingSource.Referral__c = this.referralRecord.Id;
  }

  public void showEditFundingSource() {
    String query = 'SELECT ';
    Set<String> fields = Schema.SObjectType.Funding_Source__c.fields.getMap().keySet();
    for (String field: fields) {
        query += field + ', ';
    }
    query = query.substring(0, query.length() - 2);
    query += ' FROM Funding_Source__c WHERE Id=\'' + fundingSource.Id + '\' ORDER BY Type_of_Coverage__c LIMIT 1';
    fundingSource = Database.query(query);       
  }

  public void saveFundingSource() {
    System.debug('Before upsert, fundingSource: ' + this.fundingSource);
    // When we use Id fields in conjunction with Visualforce's assignTo, it
    // becomes a blank string - which will trigger a system error (because it's
    // not a valid ID)
    if (String.valueOf(this.fundingSource.Id) == '') {
        this.fundingSource.Id = null;
    }
    
    try {
        upsert this.fundingSource;
    }
    catch (Exception e) {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'Please enter zip code in the format: XXXXX or XXXXX-XXXX'));
    }
    
    populateFundingSources();
    this.fundingSource = new Funding_Source__c();
    this.fundingSource.RecordTypeId = Utility.getFundingSourceRecordTypeFromReferral(this.ReferralRecord);
    fundingSource.Referral__c = this.referralRecord.Id;
  }

  public void showAddRelParty() {
    relParty = new Related_Party__c();
    relParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(this.ReferralRecord);
  }

  public void saveRelParty() {
    populateRelParties();
    this.relParty = new Related_Party__c();
    relParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(this.ReferralRecord);
  }

  public void showAddLocation() {
    this.location = new Referral_Location__c(service_location__c = null);
  }

  public void saveLocation() {
    System.debug('%%%%%%% Kossi saveLocation'+location);
    populateLocations();
    this.location = new Referral_Location__c(service_location__c = null);
  }

  public PageReference redirectToEdit() {
      PageReference pg = new PageReference(REFERRAL_EDIT_URL +'?id='+referralRecord.id);
      pg.setRedirect(true);
      return pg;
  }
  public PageReference redirectToSearch() {
      PageReference pg = new PageReference('/apex/referralSearch?referralId='+referralRecord.id+'&pbrId='+personBeingRefRecord.id+'&pbsId=' +personBeingServedRecord.id);
      pg.setRedirect(true);
      return pg;
  }
    public PageReference redirectToConversion() {


    if (checkRequiredFields() ) {
          PageReference pg = new PageReference(REFERRAL_CONVERT_URL +'?id='+referralRecord.id);
          pg.setRedirect(true);
          return pg;

    } else
        return null;
    }
   public boolean checkRequiredFields()
 {
    List<String> messages = new List<String>{};
    boolean hasReq = false;

    //start CTEAE-137
    if(ReferralRecordType=='Cambridge North Carolina'){
        if(referralRecord.Payer_Medical_Record_Number__c == null ){
        messages.Add( 'Payer/Guarantor Medical Record Number' );
        hasReq = true;
        }
        if(referralRecord.Payer_Medical_Record_Number_Description__c == null){
        messages.Add( 'Payer/Guarantor Medical Description' );
        hasReq = true;
        }        
        
    }
    
    //end CTEAE-137
    // requirements to create a new PBS
    if ( (string.valueOf(this.referralRecord.Person_Being_Served__c) == '' )) {

        // need last name, state of residence
        if ( this.personBeingRefRecord.Last_Name__c == null) {
                messages.Add( 'Last Name' );
                this.personBeingRefRecord.Last_Name__c.AddError('Last Name' );
                hasReq = false;
        }
        if ( this.personBeingRefRecord.State__c == null ) {
            messages.Add( ' Person Being Referred State' );
            hasReq = false;
        }

        // dob and then if < 18 need a guardian
        if ( this.personBeingRefRecord.Date_of_Birth__c == null ) {
            messages.Add( 'Date of Birth' );
            hasReq = false;
        } else {

            // get age, if < 18, need a guardian
            if ( this.personBeingRefRecord.Age__c < 18 ) {
                boolean hasGuardian = false;

                for ( Related_Party__c rp : this.relParties ) {
                    if ( rp.Type__c == 'Guardian') {
                        hasGuardian = true;
                        break;
                    }
                }

                if ( !hasGuardian ) {
                    hasReq = false;
                    messages.Add( 'Person Being Referred is under 18 and requires a related party of type Guardian');
                }
            }

        }
    }

    // requirements for admission and service assignment: anticipated admission date, anticipated location
    if ( this.referralRecord.Anticipated_Admission_Date__c == null ) {
        messages.Add( 'Anticipated Admission Date' );
        hasReq = false;
    }

    System.Debug( ' anticipated service location = ' +this.referralRecord.Service_Location__c );
    //Added the And condtion to bypass the conversion error for CareMerdian Flavor - Sravan 5/15/2014.
    if ( String.IsBlank(this.referralRecord.Service_Location_Program__c) && !isCareMeridian ) {
        messages.Add( 'Anticipated Service Location' );
        hasReq = false;
    }

    if ( messages.size() > 0 && !hasReq ) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            'Please fill in the following fields to convert to an admission.'));
        for ( string s : messages ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, s));
        }
    } else
        hasReq = true;

    return hasReq;
 }
  public void unlinkPBR()
  {
      if (this.referralRecord.oldPBR__c != null) {
          this.referralRecord.Person_Being_Referred__c = this.referralRecord.oldPBR__c;
          this.pbrID = this.referralRecord.oldPBR__c;
          this.referralRecord.oldPBR__c = null;
          update this.referralRecord;

          this.personBeingRefRecord = getPBRRec();
          populateRelParties();
      }
  }
  public void unlinkPBS()
  {
      if (this.referralRecord.oldPBS__c != null) {
          this.referralRecord.Person_Being_Served__c = this.referralRecord.oldPBS__c;
          this.pbsID = this.referralRecord.oldPBS__c;
          this.referralRecord.oldPBS__c = null;
          update this.referralRecord;

          this.personBeingServedRecord = getPBSRec();
          populateRelParties();
      }
  }
}