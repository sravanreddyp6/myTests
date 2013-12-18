/*******************************************************************************
 Name           : referrals_Controller
 Created By     : Mark Klinski (Appirio)
 Created Date   : 4/23/13
 Description    : Extension Controller for Referrals
*******************************************************************************/

public with sharing class referral_Controller2 {

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
  public List<Person_Being_Referred__c> refResults { get; set; }
  public ID referralLocationId { get; set; }
  public String referralLocationName { get; set; }
  public Map<Id, Boolean> editableTasks { get; set; }
  public Boolean isCambridge { get; set; }
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
    public boolean isEditor{get; set;}

  public static final String REFERRAL_EDIT_URL = '/apex/referral';

  public referral_Controller2(ApexPages.standardController ctl){
    system.debug('in constructor');
    this.operatinggroup=([select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].isEmpty())?''
                            :[select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1][0].operating_group__c;
    this.referralRecord = (Referral__c) ctl.getRecord();
    this.agencies = new List<Agency_Involved_With_Individual__c>();
    this.fundingSources = new List<Funding_Source__c>();
    this.relParties = new List<Related_Party__c>();
    this.activities = new List<Task>();
    this.editableTasks = new Map<Id, Boolean>();
    this.locations = new List<Referral_Location__c>();
    this.isCambridge = false;

    getPBRId();
    if (pBRId != null) {
      this.personBeingRefRecord = getPBRRec();
      populateRelParties();
    } else {
      this.personBeingRefRecord = new Person_Being_Referred__c();
    }

    if (this.referralRecord.Person_Being_Referred__c == null) {
      this.referralRecord.Person_Being_Referred__c = pBRId;
    }

    if (this.referralRecord.Id != null) {
      populateRefRelLists();
    }

    setIsEditor();
    referralRecordType= (this.ReferralRecord.RecordTypeId != null)?Utility.getRecordTypeForReferral(Id.valueOf(this.ReferralRecord.RecordTypeId)):'';//(this.ReferralRecord.RecordType.Name!=null)?this.ReferralRecord.RecordType.Name:[select name from recordtype where id=:this.referralRecord.recordTypeId limit 1].name;
    if(referralRecordType.startsWith('Cambridge')) {
        isCambridge = true;
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
            Name = pbrLastName + 'Eval' + DateTime.Now().format('MMddyy')
        );
        insert eval;
        return new PageReference('/' + eval.Id + '/e');
    }

  private void populateRelParties() {
    if (this.personBeingRefRecord.Id == null) {
      return;
    }

    try {
      this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c,
                                Person_Being_Referred__c
                         from Related_Party__c
                         where Person_Being_Referred__c = :this.personBeingRefRecord.Id order by Type__c, Name
                         limit 150];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }

    private void populateLocations() {
        this.locations =
        [select Id, Name, Referral__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c, status__c,
            service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c,service_location_program__c,
            service_location_service_value__c, service_location_setting__c, service_location__c, LastModifiedDate
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
      this.relatedReferrals = [select Id, Name, Referral_Status__c from Referral__c
                               where Person_Being_Referred__c = :this.personBeingRefRecord.Id and id != :this.referralRecord.Id
                               order by Name];
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
                       Ethnicity__c, Fax__c, First_Name__c, Gender__c,
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
    fundingSource.Referral__c = this.referralRecord.Id;
  }

  public void showEditFundingSource() {
    fundingSource = [
        SELECT ID, Funding_Source__c, Status__c, Comment__c, Funding_Source_ID__c,
               Service_Being_Funded__c, Type_of_Coverage__c, Payer_Verification_Date__c,
               Verified_With__c, Representing__c, Call_Reference_Number__c,
               Payer_Name__c, TPA__c, Primary_Med_Ind_Phys_Group__c,
               Policy_Holder__c, Group_Name__c, Relationship_To_Patient__c,
               Group_Number__c, Policy_Number__c, Benefit_Cycle__c, Effective_Date__c,
               Benefit_Year_Start_Date__c, Termination_Date__c, Benefit_Year_End_Date__c,
               Additional_Coverage__c, Additional_Coverage_Comments__c,
               Deductible__c, Copay__c, Deductible_Met__c, SNF_Day_Total__c,
               Rate_of_Reimbursement__c, SNF_Days_Used__c, OOP_Expense__c,
               Qualifying_Stay_Criteria__c, OOP_Expense_Met__c, Precert_Required__c,
               Deductible_Applicable_to_OOP__c, Precert_Company__c,
               RoR_to_100_after_met_OOP_Max__c, SNF_Phone__c, Lifetime_Max__c,
               SNF_Fax__c, Lifetime_Max_Met__c, DME_Benefits__c,
               Transportation_Benefits__c, DME_Maximum__c, Transportation_Maximum__c,
               Claims_Submission_Company__c, Claims_Submission_Street_1__c,
               Claims_Submission_Phone__c, Claims_Submission_Street_2__c,
               Claims_Submission_Email__c, Claims_Submission_City__c,
               Claims_Submission_Fax__c, Claims_Submission_State__c,
               Claims_Submission_Zip__c, Month_to_Month__c, Basis__c,
               Medicare_is_Secondary_Coverage__c, Cobra__c, Can_Patient_Return_to_Work__c,
               Payment_Detail__c, Patient_Has_Policy__c, Individual_Plan__c,
               Continued_Payment__c, More_than_1_5_Yrs_of_Disability__c,
               Under_Pre_Existing_Period__c, Dx_Pre_Existing__c,
               Self_Inflicted__c,  Covered__c,
               Readmission__c, Prior_Pmt_Received__c, Swing_Bed_Billing_at_SNF_Rate__c,
               Number_of_Days__c, Requested_By__c, Given_By__c, Request_Date__c,
               Received_Date_Time__c, Reference_Number__c, Authorization_Number__c,
               Request_Contact_Name__c, Review_Nurse__c,
               Contract_Used__c, Request_Phone__c, Level__c, Request_Fax__c,
               Justification__c, Rate__c, Internal_Contact__c, Internal_Phone__c,
               Internal_Fax__c, Internal_Email__c, Referral__c, Verified_By__c,
               Referral__r.Person_Being_Referred__r.Age__c, Payer_Phone__c,
               TPA_Phone__c, Primary_Med_Ind_Phys_Group_Phone__c, Network__c,
               Policy_Type__c, Network_Phone__c, DME_Precert_Required__c,
               Transportation_Precert_Required__c, Is_Patient_Policy_Holder__c,
               Patient_Over_26_and_On_Parent_s_Policy__c, Coverage_Details__c,
               Representing_Request__c, Representing_Received__c,
               Days_Authorized_From__c, Days_Authorized_To__c, Did_CM_Confirm_Level__c,
               Authorization_Comments__c, Does_PH_Plan_to_Continue_Working__c,
               ALS_ESRD_Black_Lung_Disease__c, Patient_Over_64_Years_of_Age__c
        FROM Funding_Source__c WHERE Id=:fundingSource.Id
        ORDER BY Type_of_Coverage__c LIMIT 1
    ];
  }

  public void saveFundingSource() {
    System.debug('Before upsert, fundingSource: ' + this.fundingSource);
    // When we use Id fields in conjunction with Visualforce's assignTo, it
    // becomes a blank string - which will trigger a system error (because it's
    // not a valid ID)
    if (String.valueOf(this.fundingSource.Id) == '') {
        this.fundingSource.Id = null;
    }
    upsert this.fundingSource;
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
      PageReference pg = new PageReference('/apex/referralSearch?referralId='+referralRecord.id+'&pbrId='+personBeingRefRecord.id);
      pg.setRedirect(true);
      return pg;
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
}