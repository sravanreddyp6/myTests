/*******************************************************************************
 Name           : referralResults_Controller
 Created By     : Doug Surfleet (Appirio)
 Created Date   : 4/15/13
 Description    : Extension Controller for Referral Search Resulting of existing users
*******************************************************************************/

public with sharing class referralResults_Controller {

  public String referralId {get;set;}
  
  public String pbrId {get;set;}
  
  //public Referral__c referralRecord { get; set; }
  public Person_Being_Referred__c referralRecord { get; set; }

  //public List<Referral__c> refResults { get; set; }
  public List<ReferralSearchResults> refResults { get; set; }
  
  public String referralEditUrl { get { return REFERRAL_EDIT_URL; } }
  
  // Allow for pre-filled information
  public String referralNumber { get; set; }
 
  public static final String REFERRAL_EDIT_URL = '/apex/referral';

  /*****************************************************************************
    Method Name : Constructor
    Description : To initialize all data members of Class.
  *****************************************************************************/ 
     public referralResults_Controller() {
        this.referralRecord = new Person_Being_Referred__c();
        // Fill in the information from the GET request (for new referrals only)
        Boolean searchImmediately = false;
        if (ApexPages.currentPage().getParameters().get('referralNumber') != null) {
            this.referralNumber = ApexPages.currentPage().getParameters().get('referralNumber');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('firstName') != null) {
            this.referralRecord.First_Name__c = ApexPages.currentPage().getParameters().get('firstName');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('lastName') != null) {
            this.referralRecord.Last_Name__c = ApexPages.currentPage().getParameters().get('lastName');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('dob') != null) {
            this.referralRecord.Date_of_Birth__c = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('age') != null) {
            this.referralRecord.Age__c = Decimal.valueOf(ApexPages.currentPage().getParameters().get('age'));
            searchImmediately = true;
        }
        this.referralRecord.Gender__c = ApexPages.currentPage().getParameters().get('gender');

        referralId = ApexPages.currentPage().getParameters().get('referralId');
        pbrId = ApexPages.currentPage().getParameters().get('pbrId');
        system.debug('referralid: ' + referralId);
        if(referralId != null && referralId != 'null') {
                Referral__c ref = [select id,name,Person_Being_Referred__r.First_Name__c,Person_Being_Referred__r.Last_Name__c,Person_Being_Referred__r.Date_of_Birth__c,Person_Being_Referred__r.Age__c,Person_Being_Referred__r.Gender__c from Referral__c where id=:referralId];
                system.debug(ref);
                this.referralRecord.First_Name__c = ref.Person_Being_Referred__r.First_Name__c;
                this.referralRecord.Last_Name__c = ref.Person_Being_Referred__r.Last_Name__c;
                this.referralRecord.Age__c = ref.Person_Being_Referred__r.Age__c;
                this.referralRecord.Gender__c = ref.Person_Being_Referred__r.Gender__c;
                this.referralRecord.Date_of_Birth__c = ref.Person_Being_Referred__r.Date_of_Birth__c;
                searchImmediately = true;
        }else if(pbrId != null && pbrId != 'null'){
            Person_Being_Referred__c pbr=[select First_Name__c,Last_Name__c,Date_of_Birth__c,Age__c,Gender__c from Person_Being_Referred__c where id=:pbrId];
            
            this.referralRecord.First_Name__c = pbr.First_Name__c;
            this.referralRecord.Last_Name__c = pbr.Last_Name__c;
            this.referralRecord.Age__c = pbr.Age__c;
            this.referralRecord.Gender__c = pbr.Gender__c;
            this.referralRecord.Date_of_Birth__c = pbr.Date_of_Birth__c;
            referralId = null;  
            searchImmediately = true;
        }else{referralId = null; pbrId = null;}
        if (searchImmediately) {
            searchRefs();
        }
    }

    public void searchRefs() {

        try
        {
                refResults = SearchLogicOnPBSR.search(referralNumber,referralRecord.Last_Name__c, referralRecord.First_Name__c, referralRecord.Date_of_Birth__c, (Double)referralRecord.Age__c, referralRecord.Gender__c);
                system.debug(refResults);
        }catch(exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    
}