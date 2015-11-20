/*******************************************************************************
 Name           : referralResults_Controller
 Created By     : Doug Surfleet (Appirio)
 Created Date   : 4/15/13
 Description    : Extension Controller for Referral Search Resulting of existing users
*******************************************************************************/

public with sharing class referralResults_Controller {

  public integer submitCount{ get; set; }
	
  public String referralId {get;set;}
  
  public String pbrId {get;set;}
  public String retURL {get;set;}
  public String viewmode {get;set;}
   //public List<Referral__c> refResults { get; set; }
  public List<ReferralSearchResults> refResults { get; set; }
  
  public String referralEditUrl { get { return REFERRAL_EDIT_URL; } }
  
  // Allow for pre-filled information
  public String referralNumber { get; set; }
  public String personFirstName { get; set;}
  public String personLastName { get; set;}
  public String personGender { get; set;}
  public String personAge { get; set;}
  public Date personDOB { get; set; }
  public List<SelectOption> genderList { get; set;}
  private Boolean searchImmediately;
 
  public static final String REFERRAL_EDIT_URL = '/apex/referral';

  /*****************************************************************************
    Method Name : Constructor
    Description : To initialize all data members of Class.
  *****************************************************************************/ 
     public referralResults_Controller() {
		submitCount = -1;
		populateGenderList();
		
        // Fill in the information from the GET request (for new referrals only)
       searchImmediately = false;
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
        if (ApexPages.currentPage().getParameters().get('retURL') != null) {
            retURL = ApexPages.currentPage().getParameters().get('retURL');
            searchImmediately = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('dob') != null) {
            personDOB = Date.parse(ApexPages.currentPage().getParameters().get('dob'));
            searchImmediately = true;
        }
        if (ApexPages.currentPage().getParameters().get('age') != null) {
            personAge = ApexPages.currentPage().getParameters().get('age');
            searchImmediately = true;
        }
        personGender = ApexPages.currentPage().getParameters().get('gender');
        if (ApexPages.currentPage().getParameters().get('viewmode') != null) {
            viewmode = ApexPages.currentPage().getParameters().get('viewmode');
        }
        referralId = ApexPages.currentPage().getParameters().get('referralId');
        pbrId = ApexPages.currentPage().getParameters().get('pbrId');
        system.debug('referralid: ' + referralId);
        if(referralId != null && referralId != 'null') {
                Referral__c ref = [select id,name,Person_Being_Referred__r.First_Name__c,Person_Being_Referred__r.Last_Name__c,Person_Being_Referred__r.Date_of_Birth__c,Person_Being_Referred__r.Age__c,Person_Being_Referred__r.Gender__c,Person_Being_Referred__r.Age_year__c, Person_Being_Referred__r.Age_text__c, Person_Being_Referred__r.Age_days__c, Person_Being_Referred__r.Age_month__c from Referral__c where id=:referralId];
                system.debug(ref);
                personFirstName = ref.Person_Being_Referred__r.First_Name__c;
                personLastName = ref.Person_Being_Referred__r.Last_Name__c;
                personAge = String.valueOf(ref.Person_Being_Referred__r.Age_text__c);
                personGender = ref.Person_Being_Referred__r.Gender__c;
                personDOB = ref.Person_Being_Referred__r.Date_of_Birth__c;
                searchImmediately = true;
        }else if(pbrId != null && pbrId != 'null'){
            Person_Being_Referred__c pbr=[select First_Name__c,Last_Name__c,Date_of_Birth__c,Age__c,Gender__c,Age_year__c,Age_text__c,Age_days__c,Age_month__c from Person_Being_Referred__c where id=:pbrId];
            
            personFirstName = pbr.First_Name__c;
            personLastName = pbr.Last_Name__c;
            personAge = String.valueOf(pbr.Age_text__c);
            personGender = pbr.Gender__c;
            personDOB = pbr.Date_of_Birth__c;
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
        	double age2 = null;
        	if ( !string.IsBlank(personAge))
        		age2 = double.valueOf(personAge);
        	
        		
        	refResults = SearchLogicOnPBSR.search(referralNumber,personLastName, personFirstName, Date.valueOf(personDOB), age2, personGender);
            system.debug(refResults);
            
            // for the browser back count
            if (!searchImmediately) 
				submitCount -= 1;
            else	// reset the immediate flag
            	searchImmediately = false;
		
           // return null;
        } catch(exception e) {
            ApexPages.addMessages(e);
            //return null;
        }
        
        
    }
    
    private void populateGenderList() {
    	
    	genderList = new list<SelectOption>();
      
      	// Get the object type of the SObject.
      	Schema.sObjectType objType = Person_Being_Referred__c.getSObjectType(); 
      	
      	// Describe the SObject using its object type.
      	Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      	
      	// Get a map of fields for the SObject
      	map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
      	 
      	// Get the list of picklist values for this field.
      	list<Schema.PicklistEntry> values = fieldMap.get('Gender__c').getDescribe().getPickListValues();
      	
      	genderList.Add( new SelectOption('',''));
      	
      	// Add these values to the selectoption list.
      	for (Schema.PicklistEntry a : values)
      	{ 
        	genderList.add(new SelectOption(a.getLabel(), a.getValue())); 
      	}
      	
      	

    }
    public Boolean canCreateReferral {
    get {
      return Schema.sObjectType.Referral__c.isCreateable();
    }
    }
    
    public Boolean canUpdateReferral {
    get {
      return Schema.sObjectType.Referral__c.isUpdateable();
    }
  }
  
}