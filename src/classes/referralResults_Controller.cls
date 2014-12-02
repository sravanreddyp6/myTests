/*******************************************************************************
 Name           : referralResults_Controller
 Created By     : Doug Surfleet (Appirio)
 Created Date   : 4/15/13
 Description    : Extension Controller for Referral Search Resulting of existing users
*******************************************************************************/

public with sharing class referralResults_Controller {

  public String referralId {get;set;}
  
  public String pbrId {get;set;}
  
   //public List<Referral__c> refResults { get; set; }
  public List<ReferralSearchResults> refResults { get; set; }
  
  public String referralEditUrl { get { return REFERRAL_EDIT_URL; } }
  
  // Allow for pre-filled information
  public String referralNumber { get; set; }
  public String personFirstName { get; set;}
  public String personLastName { get; set;}
  public String personGender { get; set;}
  public Double personAge { get; set;}
  public Date personDOB { get; set; }
 
  public static final String REFERRAL_EDIT_URL = '/apex/referral';

  /*****************************************************************************
    Method Name : Constructor
    Description : To initialize all data members of Class.
  *****************************************************************************/ 
     public referralResults_Controller() {

        // Fill in the information from the GET request (for new referrals only)
        Boolean searchImmediately = false;
        if (ApexPages.currentPage().getParameters().get('referralNumber') != null) {
            referralNumber = ApexPages.currentPage().getParameters().get('referralNumber');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('firstName') != null) {
            personFirstName = ApexPages.currentPage().getParameters().get('firstName');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('lastName') != null) {
            personLastName = ApexPages.currentPage().getParameters().get('lastName');
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('dob') != null) {
            personDOB = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('age') != null) {
            personAge = Decimal.valueOf(ApexPages.currentPage().getParameters().get('age'));
            searchImmediately = true;
        }
        personGender = ApexPages.currentPage().getParameters().get('gender');

        referralId = ApexPages.currentPage().getParameters().get('referralId');
        pbrId = ApexPages.currentPage().getParameters().get('pbrId');
        system.debug('referralid: ' + referralId);
        if(referralId != null && referralId != 'null') {
                Referral__c ref = [select id,name,Person_Being_Referred__r.First_Name__c,Person_Being_Referred__r.Last_Name__c,Person_Being_Referred__r.Date_of_Birth__c,Person_Being_Referred__r.Age__c,Person_Being_Referred__r.Gender__c from Referral__c where id=:referralId];
                system.debug(ref);
                personFirstName = ref.Person_Being_Referred__r.First_Name__c;
                personLastName = ref.Person_Being_Referred__r.Last_Name__c;
                personAge = ref.Person_Being_Referred__r.Age__c;
                personGender = ref.Person_Being_Referred__r.Gender__c;
                personDOB = ref.Person_Being_Referred__r.Date_of_Birth__c;
                searchImmediately = true;
        }else if(pbrId != null && pbrId != 'null'){
            Person_Being_Referred__c pbr=[select First_Name__c,Last_Name__c,Date_of_Birth__c,Age__c,Gender__c from Person_Being_Referred__c where id=:pbrId];
            
            personFirstName = pbr.First_Name__c;
            personLastName = pbr.Last_Name__c;
            personAge = pbr.Age__c;
            personGender = pbr.Gender__c;
            personDOB = pbr.Date_of_Birth__c;
            referralId = null;  
            searchImmediately = true;
        }else{referralId = null; pbrId = null;}
        if (searchImmediately) {
            searchRefs();
        }
    }

    public PageReference searchRefs() {

        try
        {
        	refResults = SearchLogicOnPBSR.search(referralNumber,personLastName, personFirstName, personDOB, (Double)personAge, personGender);
            system.debug(refResults);
            return null;
        } catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        
    }
    
    
}