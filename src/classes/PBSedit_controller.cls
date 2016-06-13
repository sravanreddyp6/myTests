public with sharing class PBSedit_controller {

public static Id admissionId;
public boolean UnderAgePageMsg{get;set;}
public boolean pbsEditModeOn{get;set;}
public ApexPages.StandardController PBSController{get;set;}
public String PageMessage{get;set;}
public Contact currentContact{ get { return [ select id, Birthdate, accountid, ownerid ,Age_year__c,Age_month__c,Age_days__c from contact where id = :pbsId]; }
                                    set; }
public ID PBSId{get;set;}
public String age {set;get{	return Utility.getAge(this.currentContact.Age_year__c,this.currentContact.Age_month__c,this.currentContact.Age_days__c);	}}
public boolean isEditor{get; set;}
public boolean canEdit{get; set;}
public boolean canCreateAdm { get{return false;} set; } // Stub code should be commented after release
public boolean disableAddAdm { get{return false;} set; } // Stub code should be commented after release
public boolean hasResidentialSA {get; set; }
public Agency_Involved_With_Individual__c agency { get; set; }
public string loadThisAgency {get; set;}
public boolean activeDiagExist{get;set;}
public Contact personbeingserved {get; set;}
public boolean canViewFamilyInfo { 
    get {
        return TMNUser == null ? false : (TMNUser.Operating_Group__c == 'Cambridge' || isCAFSS);
    }}

public Boolean isUserLevel1or2 { get { return PBS_controller_helper.isUserLevel1or2();} set; }
 
private TMN_User__c TMNUser_internal;
private boolean TMNUser_set = false;

public boolean isCAFSS{get; set;}

@TestVisible private TMN_User__c TMNUser {
    get {
        if (!TMNUser_set) {
            TMN_User__c[] users = [
                SELECT ID, Operating_Group__c, Business_Unit__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:currentContact.OwnerID LIMIT 1
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

  public Related_Party__c relParty {
    get {
      if (relParty == null)
        relParty = new Related_Party__c();
      return relParty;
    }
    set;
  }
  
  //For Edit mode- Guardian
   public Related_Party__c guardian { get; set; }
   public boolean showGuardian {get; set;}
    
    //Diagnosis changes
    
    public list<Diagnosis__c> diagnoses {get; set;}
    public Diagnosis__c diag {
        get {
            if (diag == null)
                diag = new Diagnosis__c();
            return diag;
        }
        set;
    }
    
    public void showAddDiagnosis(){
        diag = new Diagnosis__c();
        diag.Status__c = 'Active';
        diag.Effective_Date__c = null;
    }
    
    public void showEditDiagnosis(){
    	string diagnosisId = ApexPages.CurrentPage().getParameters().get('diagnosisId');
  		this.diag = [select Name, Type__c,Status__c, PBR__c, ICD__c,ICD__r.name,ICD__r.Code_Type__c,ICD__r.Icd_Description__c, Effective_Date__c, CreatedDate
					from Diagnosis__c where id = :diagnosisId]; 
    	
    }
          
    public void saveDiagnosis(){
    	populateDiagnoses();
		this.diag = new Diagnosis__c();
		diag.Status__c = 'Active';
        diag.Effective_Date__c = null;
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
  

  public List<Agency_Involved_With_Individual__c> relAgencies { get; set; }


// Filter some of the Additional Info Fields
public string dontShowFields {
    get {
        system.debug('OpGroup:' + TMNUser.Operating_Group__c);
        List<string> dontshow = new List<string>();
        if (TMNUser == null || (TMNUser.Operating_Group__c != 'Cambridge' && !isCAFSS)){
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
//save



// In order to show field labels instead of API names for history
public Map<String, String> fieldMap { get; set; }

    public PageReference showEditMode(){
        system.debug('-----');
        pbsEditModeOn=true;
        this.guardian.Type__c = 'Guardian';
        PageReference PBSEditP = new PageReference('/apex/PersonBeingServedEdit?id=' + PBSid);
        PBSEditP.setRedirect(true);
        return PBSEditP;
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
    
   /* private void setcanCreateAdm() {
        Schema.DescribeSObjectResult admSchema = Admission__c.sObjectType.getDescribe();
        canCreateAdm = admSchema.IsCreateable();
    } */
    
    //for EPRIQM-51
   /* private boolean setdisableAddAdm() {
        if(TMNUser!=null && (TMNUser.Operating_Group__c == 'Care Meridian'  || TMNUser.Operating_Group__c == 'Cambridge' || TMNUser.Operating_Group__c == 'NeuroRestorative'  || TMNUser.Operating_Group__c == 'Adult Day Health'  || TMNUser.Operating_Group__c == 'Redwood' || isCAFSS)) {
        List<Admission__c>  admissionList=[select id,Name,Discharged_Date__c, Admission_Effective_DateTime__c, Effective_Date__c, Status__c  from Admission__c where  Discharged_Date__c  = null and Person_Being_Served__c =: PBSId AND Status__c != 'Created in Error'];
        if(admissionList.size()>0){
          return false;
        } else {
             return true;
        }
    }
    return true;
    } */
    
    public PBSedit_controller(ApexPages.StandardController controller) {

        PBSController = controller;
        if(!test.isRunningTest()){
        	controller.addFields(new List<String>{'Guardian1_Name__c','Flavor__c', 'Age__c'});//So the field is in scope and Validation happens correctly
        }
        this.personbeingserved = (Contact) controller.getRecord();
        pbsEditModeOn=false;
        PBSId=Apexpages.currentPage().getParameters().get('Id');
        this.guardian = new Related_Party__c( type__c='Guardian');
        if(string.ISBLANK(this.personbeingserved.guardian1_name__c) && this.personbeingserved.Age__c < 18.0){
        	showGuardian = true;
        }else{
        	showGuardian = false;
        }
        this.relParties = new List<Related_Party__c>();
        this.diagnoses = new List<Diagnosis__c>();
        activeDiagExist = false;
        populateRelParties();
        populateDiagnoses();

        this.relAgencies = new List<Agency_Involved_With_Individual__c>();
        populateAgencies();
        
        Map<String, Schema.SObjectField> tempMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        fieldMap = new Map<String, String>();
        for (String fieldName: tempMap.keySet()) {
            fieldMap.put(fieldName, tempMap.get(fieldName).getDescribe().getLabel());
        }
        
        setIsEditor();
        setcanEdit();
        //setcanCreateAdm();
      	//disableAddAdm =  setdisableAddAdm();
      	
      	RWL1 = isRWL1();
      	
      	//check for CA FSS - CAFSS-8 Sravan Sep 9, 2015.
      	isCAFSS = (null != TMNUser.Business_Unit__c && TMNUser.Business_Unit__c.startswith('BU 008')) ? true : false;
        if (ApexPages.currentPage().getParameters().get('edit') == 'true' && IsEditor) {
            showEditMode();
        }
		hasResidentialSA = false;
        for (Service_Assignment__c sa: [select id, name,Service_Location__r.TMN_Scope__c,status__c from Service_Assignment__c where Admission__r.Person_Being_served__c =:PBSId]) {
        	if ( sa.service_location__r.tmn_scope__c == 'Residential'){
        		hasResidentialSA = true;
        		break;
        	}
        }
    }
   
    public List<Task> taskOnCurrentPBSAccount{get{ return [select id,WhoId,Who.Name,Owner.Name,WhatID,Status,subject,OwnerId,LastModifiedDate from Task where WhatId=:currentContact.AccountId order by createddate desc limit 10];}set;}
    public List<Event> eventOnCurrentPBSAccount{get{return [select id, WhoId,subject,LastModifiedDate ,Who.Name,whatId,ActivityDate,OwnerId,Owner.Name from Event where WhatId=:currentContact.AccountId order by createddate desc limit 10];}set;}
    public List<AccountHistory> personHistory{get{return [SELECT CreatedDate, Field, OldValue, NewValue, CreatedBy.Name FROM AccountHistory where Account.personContactId=:Apexpages.currentPage().getParameters().get('Id') ORDER BY CreatedDate DESC];} set;}
   
   
    public String currentUrl { get {
        return ApexPages.currentPage().getUrl();
    }}

    public List<Admission__c> admissions{get{return [select id,Name, Admission_Effective_DateTime__c, Discharged_Date__c, Effective_Date__c, Status__c  from Admission__c where Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id') ];}set;}
    public Boolean showDiagnosis { get {
        if (TMNUser == null) {
            return false;
        }

        return TMNUser.Operating_Group__c=='Redwood'
            || TMNUser.Operating_Group__c=='Cambridge'
            //added by Amruth for EB-430
            || TMNUser.Operating_Group__c=='NeuroRestorative'
            || TMNUser.Operating_Group__c=='Adult Day Health'
            || isCAFSS
            || this.personbeingserved.Flavor__c == 'Ludlow';
    }}
    

    public List<Evaluation_Response__c> getAssessments_ChildImmune (){

        return [select id, Name  from Evaluation_Response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType('Immunization - Child') AND Person_Being_Served__c = :currentContact.id ];
    }  
    public List<Evaluation_Response__c> getAssessments_AdultImmune (){

        return [select id, Name  from Evaluation_Response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType('Immunization - Adult') AND Person_Being_Served__c = :currentContact.id ];
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
    
    
    public List<Incident__c> incidents{ 	
    	get{
    		if(incidents == null){
    			incidents = [SELECT ID, NAME, Recordtype.Name, Service_Assignment__c, CreatedDate FROM Incident__c WHERE Service_Assignment__r.Person_being_served__c = :pbsId];	
    		}
    		return incidents;
    	}
    	set;
    }
    
    private void populateRelParties() {
    try {
        this.relParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c,
                                Person_Being_Served__c, Status__c, CreatedDate
                         from Related_Party__c
                         where Person_Being_Served__c = :pbsId order by Type__c, Name
                         ];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
  
  private void populateDiagnoses() {
    try {
        this.Diagnoses = [select Id, Name, ICD__c, ICD__r.name, ICD__r.Code_Type__c, ICD__r.Icd_Description__c, PBS__c, Type__c, Status__c, Effective_Date__c 
                         from Diagnosis__c
                         where PBS__c = :pbsId order by Status__c, Type__c
                         ];
       for(Diagnosis__c dg: Diagnoses){
       		if(dg.Status__c == 'Active'){
       			activediagExist = true;
       			break;
       		}
       		else
       		activediagExist = false;
       	
       }
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Diagnosis. ' + e.getMessage()));
    }
  }
  
   private void populateAgencies() {
    try {
      this.relAgencies = [select Name, Address__c, Email__c, Person_Being_Served__c, Phone__c, Reason_for_Involvement__c, Referral__c, CreatedDate
                         from Agency_Involved_with_Individual__c
                         where Person_Being_Served__c = :pbsId
                         ];      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
  public void showAddAgency() {
    agency = new Agency_Involved_With_Individual__c();
    
  }  
  public void saveAgency() {
    agency.Person_Being_Served__c = currentContact.id;
    for(Referral__c r : [select id from referral__c where Person_Being_Served__c = :currentContact.id]){
        agency.Referral__c = r.id;
    }    
    upsert agency;
    //this.relAgencies.add(this.agency);
    populateAgencies();
    agency = new Agency_Involved_With_Individual__c();
  }   
  public PageReference loadAgency(){
    for(Agency_Involved_With_Individual__c agy : relAgencies){
      if(agy.id == loadThisAgency){
        agency = agy;
      }
    }
    return null;
  }
public void showAddRelParty() {
    relParty = new Related_Party__c();
    relParty.Status__c = 'Active';
  }

  public void saveRelParty() {
    populateRelParties();
    this.relParty = new Related_Party__c();
    relParty.Status__c = 'Active';
  }
    
 public void createRelParties() {
    if (relParties != null && currentContact.Id != null) {
      for (Related_Party__c rP : relParties) {
        rP.Person_Being_Served__c = currentContact.Id;
      }

      upsert relParties;
    }
  }

    public id getRelatedPartyReport(){
        id theId;
        theID = [select id, developername from report where developername = 'Related_Party_for_PBS' limit 1].id;

        return theId;
    }

    // START: CTEAE-39
    public void showAddSibling() {
        
    }
    // END: CTEAE-39

  public pageReference cancelPBSController(){
      PageReference pageRef =  new PageReference('/apex/PersonBeingServedView?id=' + PBSid);
      pageRef.setRedirect(true);
      return pageRef;
//      pbsEditModeOn=false;
//      return null;

  }
   public PageReference redirect() {
		PageReference page;
			page = new PageReference('/apex/PersonBeingServedView?id=' + PBSid);
			page.setRedirect(true);
		return page;
	}
    public String getBDayDateValue() {
    	if (currentContact.id != null){
	    	DateTime dateTimeValue = currentContact.Birthdate;
	        if( dateTimeValue != null ) {
	            String localeFormatDT = dateTimeValue.format('MM/dd/yyyy', UserInfo.getTimeZone().toString() );
	            return localeFormatDT;
	        }
    	}
        return null;
    }
     
    public pageReference savePBS(){
    	
    	// if a guardian is entered, cheat an add it to the guardian1 fields	
    	if ( !String.isEmpty( this.guardian.Name)) {
			this.personbeingserved.guardian1_name__c = this.guardian.Name;
			this.personbeingserved.guardian_phone_number__c = this.guardian.Phone__c;
			this.personbeingserved.guardian_1_e_mail__c = this.guardian.email__c;
		}  
		
		decimal age = math.FLOOR(this.personbeingserved.BirthDate.daysBetween(system.today())/365.2425);
    	if ( (age < 18.0 ) && ( this.personbeingserved.guardian1_name__c == '' || this.personbeingserved.guardian1_name__c == null)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
	        'The person being served is younger than 18 years old. Please add Guardian\'s information in the Guardian information section below.' ));
	        showGuardian = true;
	        return null;
		}
		try{
			update this.personbeingserved;
			if(!string.isEmpty( guardian.Name)){
				this.guardian.Person_being_Served__c = this.personbeingserved.Id;
				insert guardian;
			}
			return new PageReference('/'+this.personbeingserved.id);
		}catch (exception e){
			if (e.getMessage().Contains('Gender Identity')) {
  			     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
	        	    'Gender Identity is required when the person identifies with a gender other than the legal gender')); 
	        	return null; 			 
  			}else{
  				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
	        	return null;
  			}
			
		}
    	
    }
     
    public boolean RWL1 {get; set;}
    private Boolean isRWL1() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];        
        for ( PermissionSetAssignment p : userperms ) {
            if ( p.PermissionSet.Name.Equals('ESD_Notes_RW_Level_1') ) {
                return true;    
            }
        }
        return false;
    }    

    public decimal itemsCompleted;
    public decimal getItemsCompleted(){
       List<Progress_Meter__c> compItems = [select Items_Complete__c from Progress_Meter__c where WhatId__c = :PBSId LIMIT 1];
       if(compItems != null && compItems.size() > 0) {
            itemsCompleted = compItems[0].Items_Complete__c;
       } else {     
           itemsCompleted = 0;
       }
       return itemsCompleted;
     }

}