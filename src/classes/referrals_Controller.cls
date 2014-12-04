public with sharing class referrals_Controller{
/*******************************************************************************
 Name           : referrals_Controller
 Created By     : Mark Klinski (Appirio)
 Created Date   : 4/23/13
 Description    : Extension Controller for Referrals
 Modification   : 05/09/2014
 Mod By         : Shaun Wood
 Mod Reason     : Adding this comment only so this class can get deployed again in the May release.
                : This will allow the code that was commented out for the release to be commented back in.
                : Please see ticket SHAUN-21 for reference.
*******************************************************************************/

//public with sharing class referrals_Controller {

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
  public Boolean isCambridge { get; set; }  // Makes it easier to implement common stuffs for Cambridge
  public Referral__c referralRecord { get; set; }
  // For Neuro - the user Id to assign the admission steps (tasks) to
  public Id userIdToAssignTasks { get; set; }
  // We use a dummy task record in order to be able to use Salesforce's
  // standard user chooser widget.
  public Task dummyTask { get; set; }
  // NEVAL-32
  SystemSettings__c OS = SystemSettings__c.getOrgDefaults();
  public Boolean showNeuroFeatures {
    get {
      if (showNeuroFeatures == null) {
        showNeuroFeatures = OS.Referral_Neuro_Features_Enabled__c;
      }
      return showNeuroFeatures;
    }
    set;
  }

  public Person_Being_Referred__c personBeingRefRecord { get; set; }
  public List<Person_Being_Referred__c> refResults { get; set; }
  public Contact personBeingServedRecord { get; set; }
  public Task activity { get; set; }
  public List<Task> activities { get; set; }
  public Agency_Involved_With_Individual__c agency { get; set; }
  public List<Agency_Involved_With_Individual__c> agencies { get; set; }
  public Funding_Source__c fundingSource { get; set; }
  public List<Funding_Source__c> fundingSources { get; set; }
  public Boolean redFlagged { get; set; }
  public Related_Party__c relParty {
    get {
      if (relParty == null) {
        relParty = new Related_Party__c();
        if (this.ReferralRecord != null) {
            relParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(this.ReferralRecord);
        }
      }
      return relParty;
    }
    set;
  }

  public List<Related_Party__c> relParties { get; set; }
  public String relPartiesJSON {get {
       List<RelatedParty> relPartiesData = new List<RelatedParty>();
    if (relParties.size() > 0) {
        for (Related_Party__c rp :relParties){
            relPartiesData.add( new RelatedParty(rp.id, rp.Type__c) );
        }
    }
    return JSON.serialize(relPartiesData);}
  }

  public class RelatedParty{
     Id Id;
     String TypeC;
     RelatedParty(Id id, String typeC){
         this.Id=id;
         this.TypeC = typeC;
     }
  }

  public Attachment relPartyFile {
    get {
      if (relPartyFile == null)
        relPartyFile = new Attachment();
      return relPartyFile;
    }
    set;
  }
  public Referral_Location__c location { get; set; }
  public List<Referral_Location__c> locations { get; set; }
  public string locationsJSON {get {
      List<ReferralLocation> refLocData = new List<ReferralLocation>();
      if(locations.size() > 0){
          for(Referral_Location__c rl : locations){
              refLocData.add(new ReferralLocation(rl.Id,rl.Status__c) );
           }

         }

        return JSON.serialize(refLocData);}
  }
  public class ReferralLocation{
      Id id;
      String status;
      ReferralLocation(Id id, String status){
          this.Id = id;
          this.status = status;
      }
  }
  public Id currentRefId {
    get {
      return (currentRefId == null) ? null :
        apexpages.currentpage().getparameters().get('id');
    }
    set;
  }
  private Id personBeingRefId {get; set;}
  public Id pBRId { get; set; }


  public Boolean isErrorDisplayed { get; set; }

  private Id personBeingServedId {get; set;}
  public Id pBSId { get; set; }

  public boolean isLinkedPersonBeingServed {
        get { return pBSId != null; }
  }

  public static final String REFERRAL_EDIT_URL = '/apex/referral';
  private static final String REFERRAL_RESULTS_URL = '/apex/referralResults';
  private static final Map<String,String> STATE_MAP = new Map<String,String> {
'Alabama' => 'AL',
'Alaska' => 'AK',
'Arizona' => 'AZ',
'Arkansas' => 'AR',
'California' => 'CA',
'Colorado' => 'CO',
'Connecticut' => 'CT',
'Delaware' => 'DE',
'Florida' => 'FL',
'Georgia' => 'GA',
'Hawaii' => 'HI',
'Idaho' => 'ID',
'Illinois' => 'IL',
'Indiana' => 'IN',
'Iowa' => 'IA',
'Kansas' => 'KS',
'Kentucky' => 'KY',
'Louisiana' => 'LA',
'Maine' => 'ME',
'Maryland' => 'MD',
'Massachusetts' => 'MA',
'Michigan' => 'MI',
'Minnesota' => 'MN',
'Mississippi' => 'MS',
'Missouri' => 'MO',
'Montana' => 'MT',
'Nebraska' => 'NE',
'Nevada' => 'NV',
'New Hampshire' => 'NH',
'New Jersey' => 'NJ',
'New Mexico' => 'NM',
'New York' => 'NY',
'North Carolina' => 'NC',
'North Dakota' => 'ND',
'Ohio' => 'OH',
'Oklahoma' => 'OK',
'Oregon' => 'OR',
'Pennsylvania' => 'PA',
'Rhode Island' => 'RI',
'South Carolina' => 'SC',
'South Dakota' => 'SD',
'Tennessee' => 'TN',
'Texas' => 'TX',
'Utah' => 'UT',
'Vermont' => 'VT',
'Virginia' => 'VA',
'Washington' => 'WA',
'West Virginia' => 'WV',
'Wisconsin' => 'WI',
'Wyoming' => 'WY'
  };

  /*********************************************************/
  public PageReference redirectToSearch() {
      String url = '/apex/referralSearch?referralId='+referralRecord.id+'&pbrId='+personBeingRefRecord.id;
      if (personBeingRefRecord.First_Name__c != null) {
          url += '&firstName=' + personBeingRefRecord.First_Name__c;
      }
      if (personBeingRefRecord.Last_Name__c != null) {
          url += '&lastName=' + personBeingRefRecord.Last_Name__c;
      }
      if (personBeingRefRecord.Date_of_Birth__c != null) {
          url += '&dob=' + personBeingRefRecord.Date_of_Birth__c.format();
      }
      if (personBeingRefRecord.Age__c != null) {
          url += '&age=' + personBeingRefRecord.Age__c;
      }
      if (personBeingRefRecord.Gender__c != null) {
          url += '&gender=' + personBeingRefRecord.Gender__c;
      }
      PageReference pg = new PageReference(url);
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

  /*******************************************************************************/
  /**********************Added by Kossi 06/05/13 2:00 AM**************************/
    public string searchedServiceLocationName{get;set;}
    public string searchedServiceLocationId{get;set;}
    public Integer OffsetSize = 0;
    private Integer QueryLimit = 25;
    public Integer CountTotalRecords{get;set;}
    public List<Service_Location__c> tmpResults{get;set;}
    public List<Service_Location__c> searchedServiceLocationResults{
        get{
            return (tmpResults!=null) ? [select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where id in :tmpResults order by name limit :QueryLimit offset :OffsetSize] : null;
        }
        set;
    }

    public Integer getOffsetSize(){
        return OffsetSize;
    }
    public Integer searchedServiceLocationResultSize{
        get{
            return (searchedServiceLocationResults!=null) ? searchedServiceLocationResults.size():0;
        }
        set;
    }
    public void resetSearchItems(){
        tmpResults=null;
        searchedServiceLocationResults=null;
        nameFilter=null;
        stateFilter=null;
        cityFilter=null;
        searchedServiceLocationName=null;
        searchedServiceLocationId=null;
        OffsetSize = 0;
        QueryLimit = 25;
        CountTotalRecords = 0;
    }
    public void search(){
        tmpResults=null;
        searchedServiceLocationResults=null;
        String qs1='select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where ';
        string qs = '';

        if(!((nameFilter=='' || nameFilter==null)&&(cityFilter=='' || cityFilter==null)&&(stateFilter=='' || stateFilter==null))){
            if(!(nameFilter=='' || nameFilter==null)){
                if(nameFilter.contains('*')){
                    qs+=' name like \''+String.escapeSingleQuotes(nameFilter.replace('*','%'))+'\' ';
                }else{
                    qs+=' name = :nameFilter ';
                }
            }
            if(!(cityFilter=='' || cityFilter==null)){
                if(!(nameFilter=='' || nameFilter==null)){
                    if(cityFilter.contains('*')){
                        qs+=' and city__c like \''+String.escapeSingleQuotes(cityFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and city__c = :cityFilter ';
                    }
                }else{
                    if(cityFilter.contains('*')){
                        qs+=' city__c like \''+String.escapeSingleQuotes(cityFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' city__c = :cityFilter ';
                    }
                }
            }
            if(!(stateFilter=='' || stateFilter==null)){
                if(!((nameFilter=='' || nameFilter==null) && (cityFilter=='' || cityFilter==null))){
                    if(stateFilter.contains('*')){
                        qs+=' and state__c like \''+String.escapeSingleQuotes(stateFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and state__c = :stateFilter ';
                    }
                }else{
                    if(stateFilter.contains('*')){
                        qs+=' state__c like \''+String.escapeSingleQuotes(stateFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' state__c = :stateFilter ';
                    }
                }

            }
            if ( qs != '') qs += ' and ';
            if (this.operatinggroup == 'NeuroRestorative') {
                qs += 'FacilityId__c = 20';
            }
            else if (this.operatinggroup == 'CareMeridian'){
                qs += 'FacilityId__c = 13';
            }
            else {
                qs += 'FacilityId__c Not In (20, 13)';
            }

            tmpResults=Database.query(qs1 + qs);
            countTotalRecords=tmpResults.size();
        }else{
            tmpResults=null;
            countTotalRecords=0;
        }
    }

    public String nameFilter{
        get;
        set;
    }
    public String stateFilter{
        get;
        set;
    }

    public String cityFilter{
        get;
        set;
    }

    public Boolean getDisablePrevious(){
        if(OffsetSize>0){
            return false;
        }
        else return true;
    }

    public Boolean getDisableNext() {
        if (OffsetSize + QueryLimit < countTotalRecords){
            return false;
        }
        else return true;
    }
    public void First() {
        OffsetSize =0;
        //return null;
    }
    public void Last() {
        Integer tmp=(counttotalrecords/QueryLimit);
        if(Math.mod(counttotalrecords,QueryLimit)==0){
            OffsetSize = (tmp-1)*QueryLimit;
        }else{
            OffsetSize = (tmp)*QueryLimit;
        }
        //return null;
    }
    public void Next() {
        OffsetSize += QueryLimit;
        //return null;
    }

    public void Previous() {
        OffsetSize -= QueryLimit;
        //return null;
    }
  /**********************************************************/

  public string searchedServiceLocationName2{get;set;}
    public string searchedServiceLocationId2{get;set;}
    public Integer OffsetSize2 = 0;
    private Integer QueryLimit2 = 25;
    public Integer CountTotalRecords2{get;set;}
    public List<Service_Location__c> tmpResults2{get;set;}
    public List<Service_Location__c> searchedServiceLocationResults2{
        get{
            return (tmpResults2!=null) ? [select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where id in :tmpResults2 order by name limit :QueryLimit2 offset :OffsetSize2] : null;
        }
        set;
    }

    public Integer getOffsetSize2(){
        return OffsetSize2;
    }
    public Integer searchedServiceLocationResultSize2{
        get{
            return (searchedServiceLocationResults2!=null) ? searchedServiceLocationResults2.size():0;
        }
        set;
    }
    public void resetSearchItems2(){
        tmpResults2=null;
        searchedServiceLocationResults2=null;
        nameFilter2=null;
        stateFilter2=null;
        cityFilter2=null;
        searchedServiceLocationName2=null;
        searchedServiceLocationId2=null;
        OffsetSize2 = 0;
        QueryLimit2 = 25;
        CountTotalRecords2 = 0;
    }
    public void search2(){
        tmpResults2=null;
        searchedServiceLocationResults2=null;
        String qs1='select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where ';
        String qs = '';

        if(!((nameFilter2=='' || nameFilter2==null)&&(cityFilter2=='' || cityFilter2==null)&&(stateFilter2=='' || stateFilter2==null))){
            if(!(nameFilter2=='' || nameFilter2==null)){
                if(nameFilter2.contains('*')){
                    qs+=' name like \''+String.escapeSingleQuotes(nameFilter2.replace('*','%'))+'\' ';
                }else{
                    qs+=' name = :nameFilter2 ';
                }
            }
            if(!(cityFilter2=='' || cityFilter2==null)){
                if(!(nameFilter2=='' || nameFilter2==null)){
                    if(cityFilter2.contains('*')){
                        qs+=' and city__c like \''+String.escapeSingleQuotes(cityFilter2.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and city__c = :cityFilter2 ';
                    }
                }else{
                    if(cityFilter2.contains('*')){
                        qs+=' city__c like \''+String.escapeSingleQuotes(cityFilter2.replace('*','%'))+'\' ';
                    }else{
                        qs+=' city__c = :cityFilter2 ';
                    }
                }
            }
            if(!(stateFilter2=='' || stateFilter2==null)){
                if(!((nameFilter2=='' || nameFilter2==null) && (cityFilter2=='' || cityFilter2==null))){
                    if(stateFilter2.contains('*')){
                        qs+=' and state__c like \''+String.escapeSingleQuotes(stateFilter2.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and state__c = :stateFilter2 ';
                    }
                }else{
                    if(stateFilter2.contains('*')){
                        qs+=' state__c like \''+String.escapeSingleQuotes(stateFilter2.replace('*','%'))+'\' ';
                    }else{
                        qs+=' state__c = :stateFilter2 ';
                    }
                }

            }

            if ( qs != '') qs += ' and ';

            if (this.operatinggroup == 'NeuroRestorative') {
                qs += 'FacilityId__c = 20';
            }
            else if (this.operatinggroup == 'CareMeridian'){
                qs += 'FacilityId__c = 13';
            }
            else {
                qs += 'FacilityId__c Not In (20, 13)';
            }

            System.debug('!@#$ '+qs);
            tmpResults2=Database.query(qs1 + qs);
            countTotalRecords2=tmpResults2.size();
        }else{
            tmpResults2=null;
            countTotalRecords2=0;
        }
    }

    public PageReference addEvaluation() {
        String pbrLastName = [
            SELECT Person_Being_Referred__r.Last_Name__c FROM Referral__c
            WHERE Id=:referralRecord.Id
        ].Person_Being_Referred__r.Last_Name__c;
        if (pbrLastName == null) pbrLastName = '';
        Evaluation__c eval = new Evaluation__c(
            Referral__c = referralRecord.Id,
            RecordtypeId = (ReferralRecordType=='CareMeridian' ? Utility.getEvaluationRecordType('CareMeridian') : Utility.getEvaluationRecordType('NeuroRestorative')),
            Name = pbrLastName + 'Eval' + DateTime.Now().format('MMddyy')
        );
        insert eval;

        // ERC-93 - fill evaluated by field on Referral with current user
        TMN_User__c curruser = [ select id from tmn_user__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
        referralRecord.evaluated_by_internal__c = curruser.id;
        referralRecord.Has_evaluation__c = true;
        update referralRecord;

        return new PageReference('/' + eval.Id + '/e');
    }

    public String nameFilter2{
        get;
        set;
    }
    public String stateFilter2{
        get;
        set;
    }

    public String cityFilter2{
        get;
        set;
    }

    public Boolean getDisablePrevious2(){
        if(OffsetSize2>0){
            return false;
        }
        else return true;
    }

    public Boolean getDisableNext2() {
        if (OffsetSize2 + QueryLimit2 < countTotalRecords2){
            return false;
        }
        else return true;
    }
    public void First2() {
        OffsetSize2 =0;
        //return null;
    }
    public void Last2() {
        Integer tmp=(counttotalrecords2/QueryLimit2);
        if(Math.mod(counttotalrecords2,QueryLimit2)==0){
            OffsetSize2 = (tmp-1)*QueryLimit2;
        }else{
            OffsetSize2 = (tmp)*QueryLimit2;
        }
        //return null;
    }
    public void Next2() {
        OffsetSize2 += QueryLimit2;
        //return null;
    }

    public void Previous2() {
        OffsetSize2 -= QueryLimit2;
        //return null;
    }
  /**********************************************************/
  public void unsetStatusHelperFiels(){

      if(referralrecord.referral_status__c != 'Closed'){
          referralrecord.close_date__c=null;
          referralrecord.close_reason__c='';
          referralrecord.close_comment__c='';
      }
      if(referralrecord.referral_status__c != 'On Hold'){
          referralrecord.hold_date__c=null;
          referralrecord.hold_reason__c='';
          referralrecord.review_on__c=null;
      }
  }
  /**********************************************************/
  public referrals_Controller(ApexPages.standardController ctl){
      system.debug('in constructor');
    this.operatinggroup=([select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].isEmpty())?''
                            :[select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1][0].operating_group__c;
    if (!Test.isRunningTest()) {
        ctl.addFields(new String[]{'Service_Location__r.Alias__c'});
    }
    this.isErrorDisplayed = false;
    this.isCambridge = false;
    this.referralRecord = (Referral__c) ctl.getRecord();
    this.dummyTask = new Task();
    this.agencies = new List<Agency_Involved_With_Individual__c>();
    this.fundingSources = new List<Funding_Source__c>();
    this.relParties = new List<Related_Party__c>();
    this.activities = new List<Task>();
    this.locations = new List<Referral_Location__c>();
    this.searchedServiceLocationName2 = this.referralRecord.Service_Location__r.Alias__c;
this.activity = new Task(Status = 'Not Started', Priority = 'Normal', OwnerId = UserInfo.getUserId(), RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks'));

    getPBRId();
    getPBSId();
    if (pBRId != null) {
      this.personBeingRefRecord = getPBRRec();
      if(this.referralRecord.id ==null && this.referralRecord.state_for_preferred_service__c == null){
          this.referralRecord.state_for_preferred_service__c = this.personBeingRefRecord.State__c;
      }
      populateRelParties();
    } else {
      this.personBeingRefRecord = new Person_Being_Referred__c();
    }

    if (pBSId != null) {
      this.personBeingServedRecord = getPBSRec();
      populateRelParties();
    } else {
      this.personBeingServedRecord = new Contact();
    }

    if (this.referralRecord.Person_Being_Referred__c == null) {
      this.referralRecord.Person_Being_Referred__c = pBRId;
    }
    if (this.referralRecord.Person_Being_Served__c == null) {
      this.referralRecord.Person_Being_Served__c = pBSId;
    }

    if (this.referralRecord.Id != null) {
      populateRefRelLists();
    }

    //set referral record type based on PBR data
        initReferralRecordType();

        referralRecordType= (this.ReferralRecord.RecordTypeId != null)?Utility.getRecordTypeForReferral(Id.valueOf(this.ReferralRecord.RecordTypeId)):''; //(this.ReferralRecord.RecordType.Name!=null)?this.ReferralRecord.RecordType.Name:[select name from recordtype where id=:this.referralRecord.recordTypeId limit 1].name;

  }

   private void populateRelParties() {
    if (this.personBeingRefRecord.Id == null && this.personBeingServedRecord.Id == null) {
      return;
    }

    try {
      if(this.personBeingRefRecord.Id != null){
      this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Referred__c, Person_Being_Served__c
                         from Related_Party__c
                         where Person_Being_Referred__c = :this.personBeingRefRecord.Id order by Type__c, Name
                         limit 150];
      }else if(this.personBeingServedRecord.Id != null){
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

  private void populateRefRelLists() {
    if (this.referralRecord.Id == null) {
      return;
    }

    try {
       this.agencies =
        [select Name,
                Address__c,
                Phone__c,
                Reason_for_Involvement__c,
                Referral__c
         from Agency_Involved_With_Individual__c
         where Referral__c = :this.referralRecord.Id
         limit 150];
      this.fundingSources = [
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
               ALS_ESRD_Black_Lung_Disease__c, Patient_Over_64_Years_of_Age__c,
               Payer_Type__c
        FROM Funding_Source__c
        WHERE Referral__c = :this.referralRecord.Id
        ORDER BY Type_of_Coverage__c LIMIT 150
      ];

      this.locations =
        [select Name, Referral__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c,status__c
            , service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c, service_location_service_value__c,
            service_location_setting__c, service_location__c, LastModifiedDate, Service_Location_Program__c, Service_Location__r.Setting__c, rank__c
         from Referral_Location__c
         where Referral__c = :this.referralRecord.Id
         limit 150];

      this.activities =
          [select Subject, Priority, Status, WhatId, OwnerId, ActivityDate,
                  Description
           from Task
           where WhatId = :this.referralRecord.Id
           order by number__c, createddate
           limit 150];

    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Lists. ' + e.getMessage()));
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

      if (this.referralRecord.Person_Being_Referred__c != null && pBRIdParam!=null && pBRIdParam != this.referralRecord.Person_Being_Referred__c) {
          this.referralRecord.oldPBR__c = this.referralRecord.Person_Being_Referred__c;
          this.referralRecord.Person_Being_Referred__c = pBRIdParam;
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
                       Legal_Guardianship_Status__c, Non_Verbal__c, Full_Name__c,
                       Level_of_Education__c
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
        'The Person Being Served record id specified is invalid. getPBSId()' + e.getMessage()));
    }

      if (this.referralRecord.Person_Being_Served__c != null && pBSIdParam!=null && pBSIdParam != this.referralRecord.Person_Being_Served__c) {
          this.referralRecord.oldPBS__c = this.referralRecord.Person_Being_Served__c;
          this.referralRecord.Person_Being_Served__c = pBSIdParam;
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
                       MailingState, MailingStreet, OtherStreet, MailingPostalCode, Legal_Guardianship_Status__c, Sign_Language__c, Non_Verbal__c,
                       Current_Medications__c, Level_of_Education__c
                from Contact
                where Id = :pBSId
                limit 1];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. getpbsrec()' + e.getMessage()));
    }
    return pBSRec;
  }

  public void showAddActivity() {
   System.debug('showAddActivity activity: ' + this.activity);
    this.activity = new Task(Priority = 'Normal', Status='Not Started', OwnerId = UserInfo.getUserId(), RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks'));
  }

  public void saveActivity() {
    System.debug('saveActivity activity: ' + this.activity);
    this.activities.add(this.activity);
    activity = new Task(Priority = 'Normal', Status='Not Started', OwnerId = UserInfo.getUserId(), RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks'));
  }

  public void showAddAgency() {
    agency = new Agency_Involved_With_Individual__c();
  }

  public void saveAgency() {
    this.agencies.add(this.agency);
    agency = new Agency_Involved_With_Individual__c();
  }

  public void showAddFundingSource() {
    fundingSource = new Funding_Source__c();
    fundingSource.RecordTypeId = Utility.getFundingSourceRecordTypeFromReferral(this.ReferralRecord);
    defaultAuthTypePicklist( fundingSource );
  }

  public void saveFundingSource() {
    // Commented out is the original code that Appirio made. I'm not really sure
    // why they went for such a complicated method, so I'll still keep this here
    // in case we need to revert this.
    //this.fundingSource.Service_Being_Funded__c = this.fundingSource.Service_Being_Funded_String__c;
    //this.fundingSource.Status__c = this.fundingSource.Status_String__c;
    this.fundingSources.add(this.fundingSource);
    this.fundingSource = new Funding_Source__c();
    fundingSource.RecordTypeId = Utility.getFundingSourceRecordTypeFromReferral(this.ReferralRecord);
    defaultAuthTypePicklist( fundingSource );
 }

 private void defaultAuthTypePicklist ( Funding_Source__c fs ) {
     List<RecordType> cmrt = [ select id from recordtype where sobjecttype='Funding_Source__c' and developername = 'CareMeridian_FS'];
    if (cmrt.size() > 0) {
        ID CMID = cmrt[0].Id;
        if ( fs.RecordTypeId == CMID)
            fs.Authorization_type__c = 'Initial'; // set default value that is not being honored in late render on jquery dialog
    }
 }

  public void showAddRelParty() {
    relParty = new Related_Party__c();
    relParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(this.ReferralRecord);
  }

  public void saveRelParty() {
    // CTEAE-22: J. Gilliam commented this line by Appirio that seems to be unnecessary for the save fo Related Party records, and in particular
    // was causing new Related Party records to save without a Type after we fixed the order of operations issue that was triggering
    // the required field validation.  1-31-14
    //
    // this.relParty.Type__c = this.relParty.Type_String__c;
    this.relParties.add(this.relParty);
    this.relParty = new Related_Party__c();
    relParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(this.ReferralRecord);
  }

  public void showAddLocation() {
    location = new Referral_Location__c();
  }

  public void saveLocation() {
      system.debug(this.location);
    //this.location.State__c = this.location.State_String__c;
    // this.location.Status__c = this.location.Status_String__c;
    this.locations.add(this.location);
    //system.debug('Loc Status:'+ this.location.status__c);
    location = new Referral_Location__c();
  }

  public PageReference saveRef() {
  // start CTEAE -34
    if(referralRecord.Adjudicated_offense_status__c){
        if(!referralRecord.Misdemeanor_s__c   & !referralRecord.Felony_ies__c){
            referralRecord.Adjudicated_offense_status__c.addError('Please Select at least one - Misdemeanor/s or Felony/ies');
            return null;

        }

    }
    // end CTEAE - 34

    // start EB-214 - Scenario 2
    if (referralRecord.referral_status__c == 'Closed'
        && referralRecord.close_reason__c != 'Admitted' && !string.IsBlank(referralRecord.close_reason__c)
        && string.IsBlank(string.valueof(referralRecord.Service_Location__c))
        && locations.size() == 0 ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least 1 location Alias working the Referral. A location Alias is required for accurate reporting.'));
            this.isErrorDisplayed = true;
            return null;
    }
    // end EB-214

    // ERNS-8 - when trying to close/admit Neuro referral, check for required fields
    if ( referralRecordType == 'NeuroRestorative') {


        if (referralRecord.Diagnosis_I__c != 'Encephalopathy') //Added by Sravan for ERNS-21 ticket.07/02/2014 1:02 PM
            referralRecord.Type_of_Encephalopathy__c = '';

        if ( referralRecord.referral_status__c == 'Closed' && referralRecord.close_reason__c =='Admitted') {

            if (!checkNRRequiredCloseAdmitFields())
                return null;
        }

        if ( referralRecord.referral_status__c == 'Closed' && referralRecord.close_reason__c !='Admitted') {

            if (!checkNRRequiredCloseNonAdmitFields())
                return null;
        }
    }

    //Start EC-54 CM Save and Close Validations
    if (referralRecordType == 'CareMeridian') {
        Boolean hasFundError = false, hasLocError = false, hasCloseError = false, hasNoFundError = false, hasNoLocError = false;
        if(referralRecord.Close_Reason__c != 'Error' && referralRecord.Referral_Status__c == 'Closed'){
          hasCloseError = checkForBlankFields(referralRecord,'Referral__c',new list<string>{'Current_Location__c','Close_Reason__c','Agency_Name__c','Evaluated_By_Internal__c'}, 'A value for {0} is required to close');
        }
        if(fundingSources.size() == 0 && referralRecord.Close_Reason__c != 'Error' && referralRecord.Referral_Status__c == 'Closed'){
             hasNoFundError = true;
        }
        if(locations.size() == 0 && referralRecord.Close_Reason__c != 'Error' && referralRecord.Referral_Status__c == 'Closed'){
             hasNoLocError = true;
        }
        for(Funding_Source__c fs :fundingSources){
          if (fs.Type_of_Coverage__c != 'Primary' && referralRecord.Close_Reason__c != 'Error' && referralRecord.Referral_Status__c == 'Closed'){
             hasFundError = true;
          } else if(fs.Type_of_Coverage__c == 'Primary'){
             hasFundError = false;
             break;
          }
        }
        for(Referral_Location__c rl :locations){
          if (rl.Rank__c != 'Primary' && referralRecord.Close_Reason__c != 'Error' && referralRecord.Referral_Status__c == 'Closed'){
             hasLocError = true;
          } else if(rl.Rank__c == 'Primary'){
             hasLocError = false;
             break;
          }
        }
        if (hasFundError){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A primary funding source must be selected to close the referral'));
        }
        if (hasLocError){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A primary location must be selected to close the referral'));
        }
        if (hasNoFundError){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A primary funding source must be created to close the referral'));
        }
        if (hasNoLocError){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A primary location must be created to close the referral'));
        }
        if (hasFundError==true || hasLocError==true || hasCloseError==true || hasNoFundError==true || hasNoLocError==true){
            return null;
        }
    }
    //End EC-54

    system.debug('in saveREF');
    Id refId;

    // Start NEVAL-26 - Don't let NR user close the referral if one of the funding sources
    // has blank Payer Type
    System.debug('Checking funding source payer type');
    if (referralRecordType == 'NeuroRestorative' && referralRecord.Referral_Status__c == 'Closed') {
        System.debug('Inside if loop');
        for (Funding_Source__c fs: fundingSources) {
            System.debug('For this funding source, the payer type is ' + fs.Payer_Type__c);
            if (fs.Payer_Type__c == '' || fs.Payer_Type__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One or more of the Funding Sources\' Payer Type is blank.'));
                return null;
            }
        }
    }

    // End NEVAL-26

    try {
      if (this.personBeingRefRecord != null && this.personBeingRefRecord.Id != null) {
        update this.personBeingRefRecord;
      }

        if (this.referralRecord.id == null) {
            this.referralRecord.Name = (this.referralRecordType == 'caremeridian') ?'CM':(this.referralRecordType == 'neurorestorative') ?'NR':Referrals_Controller.STATE_MAP.get(this.referralRecord.State_for_Preferred_Service__c);
        }

      createRelParties();

      upsert this.referralRecord;

      refId = this.referralRecord.Id;

      if (agencies != null) {
        for (Agency_Involved_With_Individual__c ag: agencies) {
          if (ag.Referral__c == null) {
            ag.Referral__c = refId;
          }
        }

        upsert agencies;
      }

      if (fundingSources != null) {

        for (Funding_Source__c fndSrc : fundingSources) {
          if (fndSrc.Referral__c == null) {
              System.debug('refId: ' + refId);
              System.debug('fndSrc: ' + fndSrc);
            fndSrc.Referral__c = refId;
            System.debug('After setting referral');
          }
        }
        System.debug('fundingSources: ' + fundingSources);
        upsert fundingSources;
      }

      if (locations != null) {
        for (Referral_Location__c loc: locations) {
          if (loc.Referral__c == null) {
            loc.Referral__c = refId;
          }
        }

        upsert locations;
      }

        Task[] tasksToInsert = new Task[] {};
        if (activities !=null) {
            for (Task act : activities) {
                if (act.WhatId == null) act.WhatId = refId;
                if (act.Id == null) tasksToInsert.add(act);
            }
            // Because the user has the option to assign a task to a different
            // user, permission becomes an issue here. If the task is new,
            // then upserting would be fine; but if the task exists before
            // hand and has been assigned to a different user, the upserting
            // would fail. The workaround now is to only insert newly created
            // tasks
            insert tasksToInsert;
        }


   } catch (Exception e) {
        system.debug('DOUGDOUG ' + e);
      String msg = e.getMessage();
      if(!msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))  {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
         System.debug(e.getStackTraceString());
      }
        ApexPages.addMessages(e);
        return null;
    }

    return ApexPages.hasMessages() ? null : getRefresh();
  }

  //ERNS-8 - check for required fields upon attempt to close/admit
  private Boolean checkNRRequiredCloseAdmitFields() {

    Boolean hasError = false, hasError2 = false,  hasError3 = false;
    hasError = checkForBlankFields( personBeingRefRecord, 'Person_Being_Referred__c', new list<string>{'first_name__c','last_name__c','date_of_birth__c','gender__c','race__c'}, 'A value for {0} is required to close/admit');
    hasError2 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'referral_status__c', 'referral_source_type__c','agency_name__c','referral_name__c','referral_date__c','evaluated_by_source__c','referral_provided_by_source__c','how_did_they_learn__c', 'date_of_injury__c','cause_of_injury_pick__c','current_location_type__c'}, 'A value for {0} is required to close/admit');

   // if ( referralRecord.evaluated_by_source__c == 'Internal')
       // hasError3 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'evaluated_by_internal__c'}, 'A value for {0} is required to close/admit');
     if (referralRecord.evaluated_by_source__c == 'External')
        hasError3 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'evaluated_by_external__c'}, 'A value for {0} is required to close/admit');

    if ( referralRecord.referral_provided_by_source__c == 'Internal')
        hasError3 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'referral_provided_by__c'}, 'A value for {0} is required to close/admit');
    else if  (referralRecord.referral_provided_by_source__c == 'External')
        hasError3 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'referral_provided_by_external__c'}, 'A value for {0} is required to close/admit');
    //EB-199 for some reason == null didn't work here so i used string.valueof()
    if(string.IsBlank(string.valueof(this.referralRecord.Service_Location__c))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'A value for Alias is required to close/admit');
            ApexPages.addMessage(myMsg);
            hasError3 = true;
            }
    //end eb-199
    //EB-205 Sravan 09/03/2014 1:44 PM
    if(referralRecord.Evaluated_By_Source__c =='Internal' && referralRecord.Evaluated_By_Internal__c == null && referralRecord.Evaluated_By_Internal_Other__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'When Evaluated by Source is Internal either Evaluated By(Internal) or Evaluated By (Internal-Other) have to be filled'));
                hasError3 = true;
            }
    //end of EB-205
    system.debug('checkNRRequiredCloseAdmitFields result: ' + (!hasError && !hasError2 && !hasError3));
    return ( !hasError && !hasError2 && !hasError3);

  }

  //EB-206 Sravan - Check for Required fields upon Close and Close reason other than Admit 09/03/2014 3:15 PM
  private Boolean checkNRRequiredCloseNonAdmitFields(){
       Boolean hasError4 = false, hasError5 = false;
       hasError4 = checkForBlankFields(referralRecord,'Referral__c',new list<string>{'Evaluated_By_Source__c','Close_Date__c','Close_Reason__c'},'A value for {0} is Required to close');
        if(referralRecord.Evaluated_By_Source__c =='Internal' && referralRecord.Evaluated_By_Internal__c == null && referralRecord.Evaluated_By_Internal_Other__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'When Evaluated by Source is Internal either Evaluated By(Internal) or Evaluated By (Internal-Other) have to be filled'));
                hasError4 = true;
        }
      else if(referralRecord.evaluated_by_source__c == 'External'){
              hasError5 = checkForBlankFields( referralRecord, 'Referral__c', new list<string>{'evaluated_by_external__c'}, 'A value for {0} is required to close');
      }
       return (!hasError4 && !hasError5);

  }

  //End of EB-206

  private Boolean checkforBlankFields ( sobject obj, string classname, List<string> fieldlist, string errMsgFmtString ) {

    Boolean blankfield = false;
    List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects(new List<string>{classname});

    if (describelist.size() == 0){
        return false;
    }

    Schema.DescribeSObjectResult info = describelist[0];

    Map<string,Schema.SObjectField> fmap = info.fields.getmap();

    for ( string f : fieldlist ) {

        if ( String.IsBlank ( String.valueOf( obj.get(f)))) {

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.Format( errMsgFmtString, new string[] {fmap.get(f).getDescribe().getlabel()}));
            ApexPages.addMessage(myMsg);

            //thisPage.addError( String.Format( errMsgFmtString, new string[] {fmap.get(f).getDescribe().getlabel()}));
            blankfield = true;

        }

    }
    system.debug('checkforBlankFields result: ' + blankfield);
    return blankfield;
  }


  public void createRelParties() {
    if (relParties != null && this.personBeingRefRecord.Id != null) {
      for (Related_Party__c rP : relParties) {
        rP.Person_Being_Referred__c = this.personBeingRefRecord.Id;
      }

      upsert relParties;
    }
  }

  public void createPBR() {
    if (this.personBeingRefRecord != null) {
      try {
        insert this.personBeingRefRecord;
      } catch (Exception e) {
        return;
      }
    }

    createRelParties();

    this.referralRecord.Person_Being_Referred__c = this.personBeingRefRecord.Id;
    if (  this.referralRecord.State_for_Preferred_Service__c ==null && referralRecord.id == null) {
        this.referralRecord.State_for_Preferred_Service__c = this.personBeingRefRecord.State__c;
    }
      if (  this.referralRecord.State_for_Preferred_Service__c == null) {
          //check public groups to default state
          Map<String,String> reversedStateMap= new Map<String,String>{
          'AL'=>'Alabama',
'AK'=>'Alaska',
'AZ'=>'Arizona',
'AR'=>'Arkansas',
'CA'=>'California',
'CO'=>'Colorado',
'CT'=>'Connecticut',
'DE'=>'Delaware',
'FL'=>'Florida',
'GA'=>'Georgia',
'HI'=>'Hawaii',
'ID'=>'Idaho',
'IL'=>'Illinois',
'IN'=>'Indiana',
'IA'=>'Iowa',
'KS'=>'Kansas',
'KY'=>'Kentucky',
'LA'=>'Louisiana',
'ME'=>'Maine',
'MD'=>'Maryland',
'MA'=>'Massachusetts',
'MI'=>'Michigan',
'MN'=>'Minnesota',
'MS'=>'Mississippi',
'MO'=>'Missouri',
'MT'=>'Montana',
'NE'=>'Nebraska',
'NV'=>'Nevada',
'NH'=>'New Hampshire',
'NJ'=>'New Jersey',
'NM'=>'New Mexico',
'NY'=>'New York',
'NC'=>'North Carolina',
'ND'=>'North Dakota',
'OH'=>'Ohio',
'OK'=>'Oklahoma',
'OR'=>'Oregon',
'PA'=>'Pennsylvania',
'RI'=>'Rhode Island',
'SC'=>'South Carolina',
'SD'=>'South Dakota',
'TN'=>'Tennessee',
'TX'=>'Texas',
'UT'=>'Utah',
'VT'=>'Vermont',
'VA'=>'Virginia',
'WA'=>'Washington',
'WV'=>'West Virginia',
'WI'=>'Wisconsin',
'WY'=>'Wyoming'
                                      };

          List<GroupMember> groups=[select group.name from groupmember where userorgroupid = :UserInfo.getUserId()];

          for(GroupMember gm : groups) {
            string state = gm.group.name.right(2);
              if (reversedStateMap.containsKey(state)) {
               this.referralRecord.State_for_Preferred_Service__c = reversedStateMap.get(gm.group.name.right(2));
              }
          }
      }
    this.referralRecord.Referral_Date__c = Date.Today();
    this.referralRecord.Referral_Status__c = 'New';
    this.referralRecord.How_did_referral_come_in__c = (referralrecordtype == 'CareMeridian')?'Phone':'';
    //set referral record type based on PBR data
    initReferralRecordType();
  }

  private PageReference getRefresh() {
    PageReference current = new PageReference('/' + this.referralRecord.Id);
    current.setRedirect(true);
    return current;
  }
  public void checkRedFlags() {

    redFlagged = false;
    String fieldSetName = 'Red_Flag_' + ReferralRecordType.replace(' ', '_');
    Set<String> allFieldSets = Schema.SObjectType.Referral__c.fieldSets.getMap().keySet();
    System.debug('Fieldsetname: ' + fieldSetName);
    if (!allFieldSets.contains(fieldSetName.toLowercase())) {
        redFlagged = false;
        return;
    }
    Schema.FieldSetMember[] fields = SObjectType.Referral__c.FieldSets.getMap().get(fieldSetName.toLowercase()).getFields();
    Map<String, Schema.sObjectField> allFields = SObjectType.Referral__c.fields.getMap();
    // Check if any of the fields is checked/has information in them
    for (Schema.FieldSetMember field: fields) {
        if (allFields.get(field.getFieldPath()).getDescribe().getType() == Schema.DisplayType.Boolean && this.referralRecord.get(field.getFieldPath())!= null && (Boolean)this.referralRecord.get(field.getFieldPath())) {
            redFlagged = true;
        } else if (allFields.get(field.getFieldPath()).getDescribe().getType() != Schema.DisplayType.Boolean && this.referralRecord.get(field.getFieldPath()) != null) {
            redFlagged = true;
        }
    }
  }

  public void initReferralRecordType() {
    // This should be separate from setReferralRecordType because we don't want
    // the Record Type to be changed when the user first opens up a referral
    // record.
    //if (this.referralRecord == null || this.referralRecord.RecordTypeId == null) {



        setReferralRecordType();


    //}
    if (Utility.getRecordTypeNameForReferralObject(this.referralRecord).startsWith('Cambridge')) {
        isCambridge = true;
    }

  }
  public void setReferralRecordType() {
     if (this.referralRecord != null) {
        if(referralRecord.RecordTypeId != Utility.getRecordTypeForReferral('CareMeridian') &&
           referralRecord.RecordTypeId != Utility.getRecordTypeForReferral('NeuroRestorative') &&
           (operatinggroup==null || operatinggroup=='' || operatinggroup.equalsIgnoreCase('Redwood') || operatinggroup.equalsIgnoreCase('Cambridge'))){
            if (this.referralRecord.State_for_Preferred_Service__c !=null) {
                try{
                    if (operatinggroup == 'Cambridge') {
                        isCambridge = true;
                        referralRecord.RecordTypeId = Utility.getRecordTypeForReferral(this.referralRecord.State_for_Preferred_Service__c, 'Cambridge');
                    } else {
                        referralRecord.RecordTypeId = Utility.getRecordTypeForReferral(this.referralRecord.State_for_Preferred_Service__c);
                    }
                }catch(Exception e){

                }finally{
                    if (referralRecord.RecordTypeId == null)  referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('Generic');
                }
            } else {
                referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('Generic');
            }
        } else if(this.referralRecord.Id == null && operatinggroup!=null && operatinggroup.equalsIgnoreCase('CareMeridian')){
            referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('CareMeridian');
        } else if(this.referralRecord.Id == null && operatinggroup!=null && operatinggroup.equalsIgnoreCase('NeuroRestorative')){
            referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('NeuroRestorative');
        } else if(this.referralRecord.Id == null && operatinggroup!=null && operatinggroup.equalsIgnoreCase('Cambridge')){
            isCambridge = true;
            if (this.referralRecord.State_for_Preferred_Service__c !=null) {
                try{
                    referralRecord.RecordTypeId = Utility.getRecordTypeForReferral(this.referralRecord.State_for_Preferred_Service__c, 'Cambridge');
                } catch(Exception e) {

                } finally {
                    if (referralRecord.RecordTypeId == null) referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('Cambridge Generic');
                }
            } else {
                referralRecord.RecordTypeId = Utility.getRecordTypeForReferral('Cambridge Generic');
            }
        }
        if (this.referralRecord.Id != null && Utility.getRecordTypeNameForReferralObject(this.referralRecord).startsWith('Cambridge')) {
            this.isCambridge = true;
        }
      }
      System.debug('Referral Record Type: ' + referralRecordType);
      System.debug('isCambridge: ' + isCambridge);
  }

  public void addNeuroAdmissionSteps() {
    if (dummyTask.OwnerId == null) {
      dummyTask.OwnerId.addError('Field is required!');
      return;
    }
    Map<String, Neuro_Admission_Steps__c> stepSubjects = Neuro_Admission_Steps__c.getAll();
    Set<String> nameSet = stepSubjects.keySet();
    List<Integer> orderedNames = new List<Integer>();  // We use this list to sort the subjects by their names
    for (String name: nameSet) {
      orderedNames.add(Integer.valueOf(name));
    }
    System.debug('orderedName: ' + orderedNames);
    orderedNames.sort();
    Id taskRecordType = Utility.getRecordTypeForTask('Referral Tasks');
    for (Integer orderedName: orderedNames) {
      Task task = new Task(
        Subject = stepSubjects.get(String.valueOf(orderedName)).Subject__c,
        Priority = 'Normal',
        Status = 'Not Started',
        WhatId = referralRecord.Id,
        OwnerId = dummyTask.OwnerId,
        RecordTypeId = taskRecordType
      );
      // We do not batch insert the tasks here because it leads to inconsistent
      // sorting order.
      if (referralRecord.Id != null) {
        insert task;
      }
      this.activities.add(task);
    }
    System.debug('After insert, activities: ' + this.activities);

    // We also want to make sure that the user can't do this action more than once
    referralRecord.Admission_Steps_Added__c = true;
    if (referralRecord.Id != null) {
      update new Referral__c(Id=referralRecord.Id, Admission_Steps_Added__c=true);
    }
  }
}