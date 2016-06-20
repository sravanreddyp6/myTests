// comment added to create diff by AV
public with sharing class referralConversion_Controller {

  public Referral__c referralRecord { get; set; }
  public Person_Being_Referred__c personBeingRefRecord { get; set; }
  public Contact personBeingServedRecord { get; set; }

  public personRecord person {get; set;}
  public List<Referral_Location__c> refLocations { get; set; }
  public List<Related_Party__c> refRelParties { get; set;}
  public list<Diagnosis__c> refDiagnoses {get; set;}
  public List<Agency_Involved_With_Individual__c> refAgencies { get; set;}
  public ID idPBR, idPBS, idAdm, idSA;
  public String NetworkOffering{ get; set; }
  private String[] programInfo;
  public String Program{ get; set;}
  public string Location{ get; set;}
  public string ServiceLine { get; set; }

 public String ReferralRecordType{
      get{
          if(this.referralRecord.RecordTypeId!=null){
              referralRecordtype = Utility.getRecordTypeForReferral(Id.valueOf(this.referralRecord.RecordTypeId));
          }
          return referralRecordType;
      }
      set;
  }


  public referralConversion_Controller(ApexPages.standardController ctl){

    this.refRelParties = new List<Related_Party__c>();
    this.refAgencies = new List<Agency_Involved_With_Individual__c>();
    this.refLocations = new List<Referral_Location__c>();
    this.refDiagnoses = new List<Diagnosis__c>();

    this.referralRecord = getFullReferralRecord(((Referral__c) ctl.getRecord()).Id);

    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
            'You have chosen to convert the referral ' + this.referralRecord.Name + '. Please confirm the information below and click Confirm Conversion to continue the conversion process. If you would like to revise the referral, click Edit. Once the conversion is complete, the referral and any applicable Assessments are closed as Admitted and locked to further editing.' ));

    // get the referral location information
    parseLocationInfo();
    NetworkOffering = getNetworkOffering();

    // get the person being referred id
    getPBRId();
    System.Debug('get PBRID=' + idPBR);
    getPBSId();
    System.Debug('get PBSID=' + idPBS);

    // get the person being referred object and fill in its related lists
    if (idPBR != null) {
        this.personBeingRefRecord = getPBRRec();
        person = new personRecord( this.personBeingRefRecord);
        if (this.personBeingRefRecord != null ) {

            getRelParties ();
            getLocations ();
            getAgencies ();
            getDiagnoses();
        }
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to retrieve Person Being Referred'));
    } else {
        // this is a PBS
        this.personBeingServedRecord = getPBSRec();
        person = new personRecord( this.personBeingServedRecord );
    }
     System.Debug( person );
  }

  private void parseLocationInfo( ) {

    string tmp;

    // updated to mirror how the SA derives its program info
    if (referralRecord.Service_location__c != null ) {

        Service_location__c sl = [select id, alias__c, service_value__c from service_location__c where id = :referralRecord.Service_Location__c LIMIT 1];

        program = sl.Alias__c;

        location  = '';
        if (sl.service_value__c != '') {
            integer dashpos = sl.Service_Value__c.indexOf('-');
            if (dashpos > -1 )
                ServiceLine = (sl.Service_Value__c).substring(dashpos+1);
            else
                ServiceLine = sl.Service_Value__c;
        }
    }
  }

  public string getLocation() {
    return Location;
  }

  public string getProgram() {
    return Program;
  }
  public string getServiceLine() {
    return ServiceLine;
  }

  private Referral__c getFullReferralRecord( ID idgetref )
  {

    Referral__c refFull;
    try {
      refFull = [Select r.Zip_Code__c,
                        r.Waiver_Funding_Source__c,
                        r.UCI_Number__c,
                        r.SystemModstamp,
                        r.Street_2__c,
                        r.Street_1__c,
                        r.State_for_Preferred_Service__c,
                        r.State__c, r.State_Specific_ID__c,
                        r.State_Specific_ID_Name__c,
                        r.Services_Requested__c,
                        r.Service_Location__c,
                        r.Service_Location__r.ProgramID__c,
                        r.Service_Location_Zip__c,
                        r.Service_Location_Street__c,
                        r.Service_Location_State__c,
                        r.Service_Location_Setting__c,
                        r.Service_Location_Service_Value__c,
                        r.Service_Location_Program__c,
                        r.Service_Location_City__c,
                        r.service_location__r.alias__c,
                        service_location__r.service_value__c,
                        //r.Secondary_Diagnosis__c, Sravan - 10/19/2015
                        r.Referring_Physician__c,
                        r.Referral_Status__c, r.Referral_Source_Type__c,
                        r.Referral_Phone_Number__c,
                        r.Referral_Name__c,
                        r.Referral_Date__c,
                        r.Refer_to_Provider__c,
                        r.RecordTypeId,
                        r.RecordCount__c,
                        r.Reason_for_Referral__c,
                        r.Program_Alias__c,
                        r.Prior_Program_Information__c,
                       // r.Primary_Diagnosis__c, Sravan - 10/19/2015
                        r.Phone__c,
                        r.Person_Being_Served__c,
                        r.Person_Being_Referred__c,
                        r.Person_Being_Referred__r.Level_of_Education__c,
                        r.OwnerId,
                        r.OldPBR__c,
                        r.Name_PBR__c,
                        r.Name,
                        r.Medicare_ID__c,
                        r.Medicaid_ID__c,
                        r.Prime_number__c, //EIFB-2
                        r.Level_of_Disability__c,
                        r.Legal_Guardian_Status__c,
                        r.Guardianship_Type__c,
                        r.Partial_Guardianship_Conservatorship__c,
                        r.LastModifiedDate,
                        r.LastModifiedById,
                        r.LastActivityDate,
                        r.IsDeleted,
                        r.Id,
                        r.Financial_Resources__c,
                        r.Fax__c,
                        r.Estimated_Discharge_Date__c,
                        r.Email_Address__c,
                        r.Days_To_Convert_Referral__c,
                        r.Date_of_Injury__c,
                        r.Current_Medical_Conditions__c,
                        r.Current_Medications__c,
                        r.Current_Location__c,
                        r.CreatedDate,
                        r.CreatedById,
                        r.Comments__c,
                        r.Close_Reason__c,
                        r.Close_Date__c,
                        r.City__c,
                        r.Cause_of_Injury__c,
                        r.Case_Manager_Name__c,
                        r.Case_Manager_Phone__c,
                        r.Billing_ID__c,
                        r.Level_Of_Education__c,
                        r.Anticipated_Admission_Date__c,
                        r.Anticipated_Admission_DateTime__c,
                        r.Agency_Name__c,
                        r.Payer_Medical_Record_Number__c ,
                        r.Payer_Medical_Record_Number_Description__c,
                 		r.Standard_Service_Assignment__c 

                        From Referral__c r

      where id = :idgetref]; 
    }
    catch (Exception e ){

    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving referral record. ' + e.getMessage()));
    }
    return refFull;
  }

   private Person_Being_Referred__c getPBRRec() {
    Person_Being_Referred__c pBRRec;
    try {
      pBRRec = [select Age__c, City__c, Date_of_Birth__c, Email_Address__c, Age_year__c,Age_month__c,Age_days__c,Age_text__c,
                       Ethnicity__c, Fax__c, First_Name__c, Gender__c,
                       Home_County__c, Last_Name__c, Marital_Status__c,
                       Middle_Initial__c, Phone__c, Primary_Language__c, Race__c, //SSN__c,
                       State__c, Street_1__c, Street_2__c, Zip_Code__c,
                       Additional_Information_Comments__c, Sign_Language__c,
                       Legal_Guardianship_Status__c, Non_Verbal__c  //, Level_of_Education__c
                from Person_Being_Referred__c
                where Id = :idPBR
                limit 1];
      if ( String.IsBlank(pBRRec.Legal_Guardianship_Status__c))
        pBRRec.Legal_Guardianship_Status__c = referralRecord.Legal_Guardian_Status__c;
        
        //if(referralRecordType.startsWith('Neuro') && pBRRec.Level_of_Education__c == null ){ pBRRec.Level_of_Education__c = 'Unknown';}
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Referred record id specified is invalid. ' + e.getMessage()));
    }
    System.Debug('currpbr =' + pBRRec.Legal_Guardianship_Status__c);
    return pBRRec;
  }


  @testvisible private Contact getPBSRec() {
    Contact pBSRec;
    try {
      pBSRec = [select MailingCity, BirthDate, Email, Age__c,Age_year__c,Age_month__c,Age_days__c,
                       Ethnicity_Picklist__c, Fax, FirstName, Gender__c,
                       Mailing_County__c, LastName,
                       Middle_Name__c, Phone, Primary_Language__c, Race__c, //SSN__c,
                       MailingState, MailingStreet, MailingPostalCode, uci_id__c, medicaid_id__c, Marital_Status__c, non_verbal__c, sign_language__c, legal_guardianship_status__c
                       //Level_of_Education__c

                from Contact
                where Id = :idPBS
                limit 1];

    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Served record id specified is invalid. ' + e.getMessage()));
    }
    return pBSRec;
  }


  private void getPBRId() {

    idPBR = this.referralRecord.Person_Being_Referred__c;
  }

  private void getPBSId() {
    idPBS = this.referralRecord.Person_Being_Served__c;
  }

 public PageReference convertReferral( ) {

    try {
        idPBS = getPBS( referralRecord );
        idAdm = getAdmission ( idPBS, referralRecord );
        closeReferral( idPBS, referralRecord ); // need to do this first otherwise it won't have an admission location
        idSA = createServiceAssignment( idPBS, idAdm, referralRecord );
		linkAssistiveDevices(idPBS);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your referral has been converted!' ));

        PageReference pg = new PageReference('/' + idPBS);
        return pg;
        }
        catch (Exception e) {
            //throw(e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Could not convert the referral - '+ e.getMessage() + e.getLineNumber() ));
            return null;

        }


  }

  private void getRelParties() {
    if (this.personBeingRefRecord.Id == null) {
      return;
    }

    try {
      this.refRelParties = [select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c,
                                Person_Being_Referred__c
                         from Related_Party__c
                         where Person_Being_Referred__c = :this.personBeingRefRecord.Id order by Type__c, Name
                         ];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Related Parties. ' + e.getMessage()));
    }
  }
  
  private void getDiagnoses(){
    if (this.personBeingRefRecord.Id == null) {
      return;
    }

    try {
      this.refDiagnoses = [select Id, Name, Status__c, Effective_Date__c, Type__c, ICD__c, PBR__c
                         from Diagnosis__c
                         where PBR__c = :this.personBeingRefRecord.Id AND Status__c = 'Active' order by Status__c, Effective_Date__c
                         ];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Diagnoses. ' + e.getMessage()));
    }
    
  }

  private void getAgencies() {
    if (this.personBeingRefRecord.Id == null) {
      return;
    }

    try {
      this.refAgencies = [select Name, Address__c, Person_Being_Served__c, Phone__c, Reason_for_Involvement__c, Referral__c
                         from Agency_Involved_with_Individual__c
                         where referral__c = :this.referralRecord.Id
                         ];
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving agencies related to this individual. ' + e.getMessage()));
    }
  }


  private void linkRelParties( ID idServ) {
    for ( Related_Party__c r:  refRelParties ) {
        r.Person_Being_Served__c = idServ;
    }

    update refRelParties;

    // add case manager in as related party of type "case manager"
    if ( !String.IsBlank(referralRecord.Case_Manager_Name__c) ) {
        Related_Party__c rpnew = new Related_Party__c( Name = referralRecord.Case_Manager_Name__c, Type__c='Case Manager', Phone__c = referralRecord.Case_Manager_Phone__c, Person_Being_Served__c = idServ );
        insert rpnew;
    }


  }

  private void linkAgencies( ID idServ) {
    for ( Agency_Involved_With_Individual__c r:  refAgencies ) {
        r.Person_Being_Served__c = idServ;
    }

    update refAgencies;


    // add case manager in as related party of type "case manager"

  }

  private void getLocations() {
        this.refLocations =
        [select Id, Name, Referral__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c, status__c,
            service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c,service_location_program__c,
            service_location_service_value__c, service_location_setting__c, service_location__c, LastModifiedDate
         from Referral_Location__c
         where Referral__c = :this.referralRecord.Id
        ];
  }
  
  
  private void linkDiagnoses(ID idServ){
    List<Diagnosis__c> diagtoInsert = new List<Diagnosis__c>();
    for(Diagnosis__c dg: this.refDiagnoses){
        Diagnosis__c d = new Diagnosis__c();
        d.Effective_Date__c = dg.Effective_Date__c;
        d.Status__c = dg.Status__c;
        d.Type__c = dg.Type__c;
        d.ICD__c = dg.ICD__c;
        d.PBS__c = idServ;
        
        diagtoInsert.add(d);
        
    }
    
    if(diagtoInsert.size() > 0){
        insert diagtoInsert;
        
    }
    
  }



 public ID getPBS( Referral__c currRef) {

    // if referral.PBSid then return it.
    // if referral.pbsid is null, use pbrid to get person being referred and create a new PBS
    // if new, set PBRid on PBS from ref
    ID person = null;
    if ( currRef.Person_Being_Served__c != null ) {
        // existing PBS
        person =  currRef.Person_Being_Served__c;
    }
    else {
        try {
            person = createNewPBS( currRef.Person_Being_Referred__c );
            this.personBeingRefRecord.Person_Being_Served__c = person;
            update this.personBeingRefRecord;

        } catch ( Exception e ) {
            //throw new referralConversionException('Unable to create new Person Being Served - ' + e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to create new Person Being Served - '+ e.getMessage()));
            return null;
        }
    }
    return person;

 }

 // Create a new person being served record.  return the contact id from the new person account.
 private ID createNewPBS( ID pbrID)
 {
    ID idPBStype = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName ='Person_Being_Served' and IsPersonType=true limit 1].Id;

    Person_Being_Referred__c pbrCurr = this.personBeingRefRecord;

    string sGuardian1Name= '', sGuardian1Address='', sGuardian1Email='', sGuardian1Phone='';

    for ( Related_Party__c rp : this.refRelParties ) {
        if ( rp.Type__c == 'Guardian') {
            // get the info and put it into fields on account
            sGuardian1Name = rp.Name;
            sGuardian1Address = rp.Address__c;
            sGuardian1Email = rp.Email__c;
            sGuardian1Phone = rp.Phone__c;
            break;
        }

    }

    string strFullSt = pbrCurr.Street_1__c;
    if ( pbrCurr.Street_2__c != null)
        strFullSt += ', ' + pbrCurr.Street_2__c;

    // EB-145 - default Billing System to AVATAR if it is filled in on conversion
    String strBillingSystem = '';
    if ( !String.IsBlank(referralRecord.Billing_ID__c) && referralRecord.Billing_ID__c.length() == 6)
        strBillingSystem = 'AVATAR';

    Account accNew = new Account( RecordTypeID = idPBStype,
                                FirstName = pbrCurr.First_Name__c,
                                Middle_Name__pc = pbrCurr.Middle_Initial__c,
                                LastName = pbrCurr.Last_Name__c,
                                ownerID = UserInfo.GetUserID(),
                                PersonBirthDate = pbrCurr.Date_of_Birth__c,
                                PersonEmail = pbrCurr.Email_Address__c,
                                Fax = pbrCurr.Fax__c,
                                Phone = pbrCurr.Phone__c,
                                PersonMailingStreet = pbrCurr.Street_1__c,
                                Mailing_Street_2__pc = pbrCurr.Street_2__c,
                                PersonMailingCity = pbrCurr.City__c,
                                PersonMailingPostalCode = pbrCurr.Zip_Code__c,
                                PersonMailingCountryCode= 'US',
                                PersonMailingStateCode = Utility.getStateCodeFromName( pbrCurr.State__c),
                                Ethnicity_Picklist__pc = pbrCurr.Ethnicity__c,
                                Gender__pc = pbrCurr.Gender__c,
                                Mailing_County__pc = pbrCurr.Home_County__c,
                                Person_Being_Referred__pc = pbrCurr.Id,
                                Primary_Language__pc = pbrCurr.Primary_Language__c,
                                Non_Verbal__pc = pbrCurr.Non_Verbal__c,
                                Race__pc = pbrCurr.Race__c,
                                Sign_Language__pc = pbrCurr.Sign_Language__c,
                               // SSN__pc = pbrCurr.SSN__c,
                                Guardian1_Name__pc =  sGuardian1Name,
                                Guardian_1_Address__pc = sGuardian1Address,
                                Guardian_1_E_Mail__pc = sGuardian1Email,
                                Guardian_Phone_Number__pc = sGuardian1Phone,
                                UCI_ID__pc = string.valueOf(this.referralRecord.UCI_Number__c),
                                Prime_number__pc = referralRecord.Prime_number__c,
                                Marital_Status__pc = pbrCurr.Marital_Status__c,
                                Avatar_ID__pc = referralRecord.Billing_ID__c,
                                Avatar_Source_System__pc = strBillingSystem,
                                Legal_Guardianship_Status__pc = referralRecord.Legal_Guardian_Status__c,
                                Guardianship_Type__pc = referralRecord.Guardianship_Type__c,
                                Partial_Guardianship_Conservatorship__pc = referralRecord.Partial_Guardianship_Conservatorship__c,
                                Current_Medications__pc = referralRecord.Current_Medications__c,
                                Other_id__pc = referralRecord.Payer_Medical_Record_Number__c ,
                                //Level_of_Education__pc = pbrCurr.Level_of_Education__c - Sravan Aug 20, 2015
                                Other_ID_Description__pc = referralRecord.Payer_Medical_Record_Number_Description__c,
                               // Level_of_Education__pc = pbrCurr.Level_of_Education__c,
                               	Flavor__pc = (referralRecord.Service_Location__r.Alias__c=='114165')?'Ludlow':Utility.getRecordTypeForReferral(this.referralRecord.RecordtypeId)
                                );

    insert accNew;

    accNew = [ select id, personcontactid, firstname, lastname from account where id = :accNew.ID ];

    // link related parties to new Person Being Served
    linkRelParties( accNew.PersonContactId );
    
    // link Allerigies to new Person Being Served. pull them from referral eval Allergies
    if(idPBR != null){ //Do not do this when converting a referral with PBS 
    	linkAllergies(accNew.PersonContactId );
    }
    // link agencies to new Person Being Served
    linkAgencies( accNew.PersonContactId );

    // link assistive devices from the referral eval to the person being served.
    linkAssistiveDevices(accNew.PersonContactId);
    
    //copy Diagnosis records from Personbeing referred on to PBS
    linkDiagnoses(accNew.PersonContactId);
     
    // return the contact id, not the account id
    return accNew.PersonContactId;

 }

  private void linkAssistiveDevices(ID pbsID){
   if(referralRecordType.startsWith('CareMeridian')){        
        map<string, string> evalFieldMap = new map<string, string>();
        evalFieldMap.put('Glasses_For_Reading__c', 'Glasses');
        evalFieldMap.put('Glasses_For_Distance__c', 'Glasses');
        evalFieldMap.put('Glasses_For_Multi_Focal_Use__c', 'Glasses');
        evalFieldMap.put('Rehab_Cane__c', 'Cane');
        evalFieldMap.put('Front_Wheeled_Walker__c', 'Front-Wheeled Walker');
        evalFieldMap.put('Wheel_Chair__c', 'Wheelchair');
        evalFieldMap.put('Bed_Alarm__c', 'Bed Alarm');
        String evalRespQuery = 'Select ' + String.join((new list<String>(evalFieldMap.keySet())), ', ') + ' From Evaluation__c Where Referral__c = \'' + String.valueOf(referralRecord.id) + '\'';
        list<Evaluation__c> refEvals = database.query(evalRespQuery);
        if (!refEvals.isEmpty() ) {
        	Id rcdTypId = Utility.getEvaluationResponseRecordType('Assistive Device');
        	set<string> existingDev = new set<String>();
        	List<Evaluation_Response__c> existingDevices = [SELECT Id, Assistive_Device_Type__c FROM Evaluation_Response__c
        		where Person_being_Served__c = :pbsID AND RecordtypeId=: rcdTypId AND Assistive_Device_Type__c IN: evalFieldMap.Values()];
            for(Evaluation_Response__c ev: [SELECT Id, Assistive_Device_Type__c FROM Evaluation_Response__c where Person_being_Served__c = :pbsID AND RecordtypeId=: rcdTypId AND Assistive_Device_Type__c IN: evalFieldMap.Values()]){
            	existingDev.add(ev.Assistive_Device_Type__c);
            }
            
            Evaluation__c refEval = refEvals.get(0);  
            list<Evaluation_Response__c> evalRspns = new List<Evaluation_Response__c>();
            for (String s : evalFieldMap.keySet()) {
                if (s == 'Glasses_For_Reading__c' && !existingDev.Contains(evalFieldMap.get(s))){
                    String[] vals = new list<String>();
                    if (refEval.Glasses_For_Reading__c) vals.add('For Reading');
                    if (refEval.Glasses_For_Distance__c) vals.add('For Distance');
                    if (refEval.Glasses_For_Multi_Focal_Use__c) vals.add('Multifocal');
                    if (!vals.isEmpty()) {
                        Evaluation_Response__c rsp = new Evaluation_Response__c();
                        rsp.RecordTypeID = rcdTypId;
                        rsp.person_being_served__c = pbsID;
                        rsp.Assistive_Device_Type__c = 'Glasses';
                        rsp.Assistive_Device_Start_Date__c = referralRecord.Anticipated_Admission_Date__c;
                        rsp.Glasses_Contacts_Purpose__c = String.join(vals, ';');
                        evalRspns.add(rsp);
                    }
                } else if (s == 'Rehab_Cane__c' || s == 'Front_Wheeled_Walker__c' || s == 'Wheel_Chair__c' || s == 'Bed_Alarm__c'){
                	system.debug('existingDev>>>>>>>>> '+existingDev);
                    if (Boolean.valueOf(refEval.get(s)) && !existingDev.Contains(evalFieldMap.get(s))){
                        Evaluation_Response__c rsp = new Evaluation_Response__c();
                        rsp.RecordTypeID = rcdTypId;
                        rsp.person_being_served__c = pbsID;
                        rsp.Assistive_Device_Type__c = evalFieldMap.get(s);
                        rsp.Assistive_Device_Start_Date__c = referralRecord.Anticipated_Admission_Date__c;
                        evalRspns.add(rsp);
                    }
                } 
            }
            insert evalRspns;
        }
    }
  }
  
  private void linkAllergies(ID pbsID){
    
    if( referralRecordType.startsWith('CareMeridian') || referralRecordType.startsWith('Neuro') ){
         List <Evaluation__c> refEval = [SELECT ID FROM Evaluation__c WHERE Referral__c =:referralRecord.id LIMIT 1]; //using List to avoid System.Query Exception when no records are returned
         
         if(refEval.size() > 0){
            List<Evaluation_Response__c> tobeClonedResponses = [SELECT Id, Allergy_Type__c, Allergy_Details__c, Life_Threatening__c FROM Evaluation_Response__c WHERE RecordType.Name = 'Allergy' AND Evaluation__c = :refEval[0].Id];
            if(tobeClonedResponses.size() > 0){
                List<Evaluation_Response__c> clonedResponses = new List<Evaluation_Response__c>();
                for(Evaluation_Response__c resp: tobeClonedResponses){
                    Evaluation_Response__c er = resp.clone(false);
                    er.Person_Being_Served__c = pbsID;
                    clonedResponses.add(er);
                }
                
                insert clonedResponses;
            }
         }
        
    }
    
    
  }
 // get the contact id from an existing person account object
 private ID getPBSContactId ( ID pbsID )
 {

    Account acctCurr = [ select id, personcontactid from account where id = :pbsID limit 1];
    System.Debug('returning person id of ' + acctCurr.PersonContactId + ' for Account id ' + pbsID);
    return acctCurr.PersonContactId;

 }

 public ID getAdmission( ID idPBS, Referral__c refCurr)
 {

    // use the PBS ID to get the single active admission
    // if no admission, create a new one using the info on the referral
    Admission__c currAdm;

    try {
        currAdm = [ select id, name from Admission__c where Person_Being_served__c = :idPBS and status__c = 'Active' limit 1];
    } catch ( Exception e) {

        if ( currAdm == null )
        {
            // no current admission - create one
            currAdm = new Admission__c(
                Person_Being_Served__c = idPBS,
                Admission_Effective_DateTime__c = refCurr.Anticipated_Admission_DateTime__c,
                Network_Offering__c = NetworkOffering,
                Program__c = refCurr.Service_Location_Program__c,
                Referral_Date__c = refCurr.Referral_Date__c,
                State__c = refCurr.Service_Location_State__c,
                Status__c = 'Active'
                );

             insert currAdm;
        }
    }
    if ( currAdm != null )
        return currAdm.Id;
    else
        return null;


 }

 public String getNetworkOffering() {

        // pull network code off service value field
        String strNetwork = '';

        if ( this.referralRecord.Service_Location_Service_Value__c != null)
            if ( (this.referralRecord.Service_Location_Service_Value__c).length() >=3 )
                strNetwork = this.referralRecord.Service_Location_Service_Value__c.substring(0, 3);

        return strNetwork;
 }

 public ID createServiceAssignment( ID idPBS, ID idAdm, Referral__c refCurr )
 {
    // use the PBS id and the admission id to create a new service assignment using the info on the referral
    ID idSAtype;
     if( referralRecordType.startsWith('Neuro') ){
         if(refCurr.Standard_Service_Assignment__c){
             idSAtype = [SELECT Id FROM RecordType WHERE SObjectType = 'Service_Assignment__c' AND DeveloperName ='Standard_Service_Assignment' limit 1].Id;
         }else{
             idSAtype = [SELECT Id FROM RecordType WHERE SObjectType = 'Service_Assignment__c' AND DeveloperName ='Assessment_Only' limit 1].Id;
         }
     }
    else{
        idSAtype = [SELECT Id FROM RecordType WHERE SObjectType = 'Service_Assignment__c' AND DeveloperName ='Standard_Service_Assignment' limit 1].Id;
    }

    string strLoc = getLocation();
    Service_Assignment__c newSA = new Service_Assignment__c(
                                            RecordTypeId = idSAtype,
                                            Admission__c = idAdm,
                                            Person_Being_Served__c = idPBS,
                                            SA_Start_DateTime__c = refCurr.Anticipated_Admission_DateTime__c,
                                            Status__c = 'Active',
                                            Program_Detail__c = refCurr.Service_Location_Program__c,
                                            Service_Location__c = refCurr.Service_Location__c,
                                            service_line__c = getServiceLine(),
                                            Location_Region__c = getLocation(),
                                            Program_Code__c = getProgram(),
                                            Program__c = getProgram(),
                                            Date_of_Injury__c = refCurr.Date_of_Injury__c,
                                            Cause_of_Injury__c = refCurr.Cause_of_Injury__c,
                                            Ref_Referring_Physician__c = refCurr.Referring_Physician__c,
                                            Referral_Est_Discharge_Date__c = refCurr.Estimated_Discharge_Date__c,
                                            Prior_Location_Street_1__c = refCurr.Street_1__c,
                                            Prior_Location_Street_2__c = refCurr.Street_2__c,
                                            Prior_Location_City__c = refCurr.City__c,
                                            Prior_Location_State__c = refCurr.State__c,
                                            Prior_Location_Zip__c = refCurr.Zip_Code__c,
                                            Prior_Location_Phone__c = refCurr.Phone__c,
                                            Prior_Location_Email__c = refCurr.Email_Address__c,
                                            Highest_Level_of_Education_at_Start__c = refCurr.Level_of_Education__c,
                                            //Highest_Level_of_Education_at_Start__c = this.personBeingRefRecord.Level_of_Education__c,
                                            Referral__c = refCurr.Id,
                                            Flavor__c = (referralRecord.Service_Location__r.Alias__c=='114165')?'Ludlow':Utility.getRecordTypeForReferral(refCurr.RecordtypeId),
        									Model__C = (referralRecordType.startsWith('Cambridge') ||  referralRecordType == 'CA FSS') ? 'MENTOR' : null
                                            );

    insert newSA;
    //EB-462
    if( referralRecordType.startsWith('Neuro') ){
                list<Service_Code__c> Codes = [ SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c, Program__c 
                                                        FROM Service_Code__c 
                                                        WHERE Program_Code__c = :refCurr.Service_Location__r.ProgramID__c
                                                            AND ( end_date__c > :date.valueof(newSA.SA_Start_DateTime__c) or end_date__c = null ) ];
                list<ServiceAssignment_ServiceCode_JO__c> servCodeXrefsToSave = new list<ServiceAssignment_ServiceCode_JO__c>();    
                for(Service_Code__c item: Codes){
                    ServiceAssignment_ServiceCode_JO__c servCodeXrefToSave = new ServiceAssignment_ServiceCode_JO__c(
                            Service_Code__c = item.Id,
                            Service_Assignment__c = newSA.Id
                            );
                    servCodeXrefsToSave.add(servCodeXrefToSave);
                }
    
        if (servCodeXrefsToSave != null) {insert servCodeXrefsToSave;}
    }
    // if none of the diagnosis fields are blank or null, create new diagnosis record and link to SA
    //Sravan - 10/19/2015 no need to create Diagnosis record at SA Level - PRI-22 

    Contact pbsmed = [select id, medicaid_id__c from contact where id = :idPBS ];
    Boolean trytoupdatePBS = String.IsBlank( pbsmed.medicaid_id__c );
    Boolean updatePBS = false;

    // EC-13 - do not link the funding sources. instead copy them so they can be edited on the SA record.
    string strSQL = Utility.getCreatableFieldsSOQL('funding_source__c','referral__c = \'' + refCurr.Id + '\'' );
    system.debug( strSQL );

    List<Funding_Source__c> fundsrcList = (List<Funding_Source__c>)Database.query(strSQL);

    if ( fundsrcList.size() > 0 ) {

        List<Funding_Source__c> newfunds = fundsrcList.deepClone();

        for ( Funding_Source__c fs : newfunds ) {

            fs.Service_Assignment__c = newSA.Id;    // set SA for new funding source
            fs.referral__c = null;                  // clear our referral id

            if ((fs.Funding_Source__c == 'Medicaid') && trytoupdatePBS ) {
                pbsmed.Medicaid_ID__c = fs.Funding_Source_ID__c;
                system.debug('Updating PBS ' + idPBS + ' with Medicaid ID ' + fs.Funding_Source_ID__c + ' from funding source ' + fs.Id);
                updatePBS = true;
                trytoupdatePBS = false;
            }

        }

        try {
            insert newfunds;

            // reselect to get ids populated
            strSQL = Utility.getCreatableFieldsSOQL('funding_source__c','service_assignment__c = \'' + newSA.Id + '\'' );
            // add the name field
            strSQL = strSQL.Replace('SELECT ', 'SELECT name, ');
            system.debug( strsql);
            newfunds = (List<Funding_Source__c>)Database.query(strSQL);

            List<Authorization__c> newauths = new List<Authorization__c>();

            // get the new recordtype for funding source related auths
            RecordType recType = new RecordType();
            if( referralRecordType.startsWith('Neuro') ){
                recType = [ select id from recordtype where sobjecttype='Authorization__c' and developername ='Funding_Source_Auth_NR' LIMIT 1 ];
            }
            else if(referralRecordType.startsWith('Adult')){
            	recType = [ select id from recordtype where sobjecttype='Authorization__c' and developername ='Funding_Source_Auth_ADH' LIMIT 1 ];
            }
            else{         
                recType = [ select id from recordtype where sobjecttype='Authorization__c' and developername ='Funding_Source_Auth_CM' LIMIT 1 ];
            }
            // now create auths for funding sources that have them
            for ( Funding_Source__c fs : newfunds ) {

                // CMAUTH-2 - check for populated fields before transferring over
                // hack to pass by reference - need list back, first element will be # of fields populated, second will be whether or not it can go over as final status 
                List<integer> numFields = getNumAuthPopulatedFields( fs );
                
                system.debug( 'RETURN FROM CHECK FIELDS:' + numFields);
                    
                // for now this will be for CM only.  working on other flavors.
                if (  numFields[0] > 0 ) {
                    string authstatus = 'Draft';
                    
                    if ( numfields[1] == 1)
                        authstatus = 'Final';
                            
                    Authorization__c auth = new Authorization__c ( RecordTypeID = recType.ID,
                                                                    authorization_status__c         = authstatus,
                                                                    funding_source__c               = fs.Id,
                                                                    type__c                         = fs.authorization_type__c,
                                                                    admission__c                    = newSA.Admission__c,
                                                                    service_assignment__c           = newSA.id,
                                                                    payer_effective_date__c         = fs.days_authorized_from__c,
                                                                    payer_end_date__c               = fs.days_authorized_to__c,
                                                                    person_being_served__c          = newSA.Person_being_served__c,
                                                                    requested_by__c                 = fs.requested_by__c,
                                                                    request_date__c                 = fs.request_date__c,
                                                                    request_contact_name__c         = fs.request_contact_name__c,
                                                                    representing_request__c         = fs.representing_request__c,
                                                                    reference_number__c             = fs.reference_number__c,
                                                                    reviewed_by__c                  = fs.review_nurse__c,
                                                                    request_phone__c                = fs.request_phone__c,
                                                                    request_fax__c                  = fs.request_fax__c,
                                                                    received_from__c                = fs.given_by__c,
                                                                    representing_received__c        = fs.representing_received__c,
                                                                    auth_given_method__c            = fs.auth_given_method__c,
                                                                    comments__c                     = fs.authorization_comments__c,
                                                                    level__c                        = fs.level__c,
                                                                    rate__c                         = ( referralRecordType.startsWith('Neuro') || referralRecordType.startsWith('Adult') )? fs.Received_Rate__c :fs.rate__c,
                                                                    justification__c                = fs.justification__c,
                                                                    service_being_funded_string__c  = fs.service_being_funded_string__c,
                                                                    rate_unit__c                    = fs.rate_unit__c,
                                                                    payer_authorization_id__c       = fs.authorization_number__c,
                                                                    received_date_time__c           = fs.received_date_time__c,
                                                                    taken_by__c                     = fs.taken_by__c,
                                                                    reason_for_new_authorization__c = 'New Authorization',
                                                                    other_authorization_type__c     = fs.Other_Authorization_Type__c,
                                                                    
                                                                    
                                                                    Days_Authorized__c              = (!string.isBlank(fs.Days_Authorized__c) && !referralRecordType.startsWith('Adult') ) ? integer.valueof(fs.Days_Authorized__c) : null  ,
                                                                    Days_Authorized_InWeek__c		= fs.Days_Authorized__c,
                                                                    Days_Authorized_Per_Week__c		= fs.Days_Authorized_Per_Week__c,
                                                                    Authorization_Number__c         = fs.Authorization_Number__c,
                                                                    Days_Authorized_from__c         = fs.Days_Authorized_from__c ,
                                                                    Days_Authorized_To__c           = fs.Days_Authorized_To__c,
                                                                    Negotiated_Rate__c              = (!string.isBlank(fs.Negotiated_Rate__c) ) ? integer.valueof(fs.Negotiated_Rate__c) : null,
                                                                    payer_cm_name__c                = fs.internal_contact__c,
                                                                    payer_cm_phone__c               = fs.internal_phone__c,
                                                                    payer_cm_email__c               = fs.internal_email__c,
                                                                    payer_cm_fax__c                 = fs.internal_fax__c,
                                                                    NR_CM_Name__c                   = fs.NR_CM_Name__c ,
                                                                    NR_CM_Phone__c                  = fs.NR_CM_Phone__c ,
                                                                    NR_CM_Fax__c                    = fs.NR_CM_Fax__c,
                                                                    NR_CM_Email__c                  = fs.NR_CM_Email__c ,
                                                                    Adjuster_Name__c                = fs.Adjuster_Name__c ,
                                                                    Adjuster_Company__c             = fs.Adjuster_Company__c ,
                                                                    Adjuster_Phone__c               = fs.Adjuster_Phone__c ,
                                                                    Adjuster_Email__c               = fs.Adjuster_Email__c ,
                                                                    Adjuster_Fax__c                 = fs.Adjuster_Fax__c  
                                                                    );
                                                                    
                    newauths.Add( auth);

                }
            }

            if ( newauths.size() > 0)
                insert newauths;

        } catch (DMLException e ){
            system.debug('Could not copy over funding sources!');
        }
        if ( updatePBS )
            update pbsmed;
    }

    return newSA.Id;
 }

    public pageReference StandardSA(){
        this.referralRecord.Standard_Service_Assignment__c = true;
        update this.referralRecord;
        PageReference pg= new PageReference('/apex/referralConversion' +'?id='+referralRecord.id);
        pg.setRedirect(true);
        return pg;
    }
    public pageReference AsmtOnlySA(){
        this.referralRecord.Standard_Service_Assignment__c = false;
        update this.referralRecord;
        PageReference pg= new PageReference('/apex/referralConversion' +'?id='+referralRecord.id);
        pg.setRedirect(true);
        return pg;
    }
    
 public ID closeReferral( ID idPBS, Referral__c ref)
 {
    // find referral location in list of locations, close with reason of admitted
    List<Referral_Location__c> lstRefLoc = [ select id, status__c from referral_location__c where referral__c = :ref.ID ];

    // no referral locations - need to add the anticipated location as a referral location for completeness
    if ( lstRefLoc.Size() == 0 ) {
        Referral_Location__c rlNew = new Referral_Location__c ( Service_Location__c = ref.Service_Location__c,
                                                                Referral__c = ref.ID,
                                                                User_Assigned__c = UserInfo.getUserId(),
                                                                Status__c = 'Closed' );
        insert rlNew;
    } else {
        // loop through the referral locations and update the status to Closed
        for ( Referral_Location__c rlCurr : lstRefLoc ) {

            rlCurr.Status__c = 'Closed';
            if  ( rlCurr.Id == ref.Service_Location__c )
            {
                // set close reason to 'Admitted' - no field available yet
            }

        }
        // update the list of locations in bulk
        update lstRefLoc;
    }


    // set PBSID on referral to new PBS
    ref.Person_Being_Served__c = idPBS;

    // set referral status to closed with reason of Admitted
    ref.Referral_Status__c = 'Closed';
    ref.Close_Reason__c = 'Admitted';
    ref.Close_Date__c = system.today();
    update ref;

    return ref.Id;

 }

public class personRecord {

    private String fn, ln, mi, em, f, p, s1, s2, ci, st, z, ct, eth, gen, lang, ss, marstat, medid, legalstat, educ;
    private Boolean nonverb, signlang;
    private String dob;
    public String FirstName { get {return fn; } set; }
    public string MiddleInitial { get {return mi;} set; }
    public string LastName { get { return ln; } set; }
    public String DateOfBirth { get { return dob; } set; }
    public string Email { get {return em;} set; }
    public string Fax { get { return f;} set; }
    public string Phone { get { return p; } set; }
    public string Street1 { get { return s1; } set; }
    public string Street2 { get {return s2;} set; }
    public string City { get { return ci ;} set; }
    public string State { get { return st; } set; }
    public string ZipCode { get { return z;} set; }
    public string County { get { return ct; } set; }
    public string Ethnicity { get { return eth;} set; }
    public string Gender { get { return gen; } set; }
    public string PrimaryLanguage { get { return lang;} set; }
   // public string SSN { get { return ss;} set; }
    public string MedicaidID { get { return medid;} set; }
    public string MaritalStatus { get { return marstat;} set; }
    public boolean NonVerbal { get { return nonverb;} set; }
    public boolean SignLanguage{ get { return signlang;} set; }
    public string LegalGuardianship { get {return legalstat;} set; }
    //public string Education { get {return educ;} set; }
    public String race { get {return race;} set; }
    public String year { get {return year;} set; }
    public String month { get {return month;} set; }
    public String days { get {return days;} set; }
    public String age { get {return age;} set; }
    
    public personRecord( Person_Being_Referred__c pbr ) {
        System.Debug('calling person record with referred: ' + pbr);
        fn = pbr.First_Name__c;
        mi = pbr.Middle_Initial__c;
        ln = pbr.Last_Name__c;
        dob = pbr.Date_of_Birth__c.format();
        em = pbr.Email_Address__c;
        f = pbr.Fax__c;
        p = pbr.Phone__c;
        s1 = pbr.Street_1__c;
        s2 = pbr.Street_2__c;
        ci = pbr.City__c;
        st = pbr.State__c;
        z = pbr.Zip_Code__c;
        ct = pbr.Home_County__c;
        eth = pbr.Ethnicity__c;
        gen = pbr.Gender__c;
        lang = pbr.Primary_Language__c;
       // ss = pbr.SSN__c;
        marstat = pbr.Marital_Status__c;
        legalstat = pbr.Legal_Guardianship_Status__c;
        nonverb = pbr.Non_Verbal__c;
        signlang = pbr.Sign_Language__c;
       // educ = pbr.Level_of_Education__c;
        race =  pbr.Race__c;
        year =  String.valueOf(pbr.Age_year__c);
        month =  String.valueOf(pbr.Age_month__c);
        days =  String.valueOf(pbr.Age_days__c);
        age = pbr.Age_text__c;
    }


    public personRecord( Contact pbs ) {
        System.Debug('calling person record with served');
        fn = pbs.FirstName;
        ln = pbs.LastName;
        dob = pbs.BirthDate.format();
        em = pbs.Email;
        f= pbs.Fax;
        p = pbs.Phone;
        s1 = pbs.MailingStreet;
        ci = pbs.MailingCity;
        st = pbs.MailingState;
        z = pbs.MailingPostalCode;
        eth = pbs.Ethnicity_Picklist__c;
        gen = pbs.Gender__c;
        ct = pbs.Mailing_County__c;
        lang = pbs.Primary_Language__c;
       // ss = pbs.SSN__c;
        marstat = pbs.Marital_Status__c;
        legalstat = pbs.Legal_Guardianship_Status__c;
        nonverb = pbs.Non_Verbal__c;
        signlang = pbs.Sign_Language__c;
        medid = pbs.Medicaid_Id__c;
      //  educ = pbs.Level_of_Education__c;
        race =  pbs.Race__c;
        year =  pbs.Age_year__c;
        month =  pbs.Age_month__c;
        days =  pbs.Age_days__c;
        age = Utility.getAge(year,month,days);
    }
    
}


    
class referralConversionException extends Exception {
    }
    @testvisible
    private List<integer> getNumAuthPopulatedFields ( Funding_Source__c fs ) {
        integer numFields = 0;
        integer canbefinal = 0;
        
        if (! String.IsBlank( fs.authorization_type__c ) && !string.isblank(fs.Authorization_Number__c) && fs.received_date_time__c != null) {
                canbefinal = 1;
    
                // check for required fields by type
                if ( fs.authorization_type__c == 'Open Ended Stay' || fs.authorization_type__c == 'Defined Stay') {
                        if (string.isblank(fs.rate__c)  || string.isblank(fs.rate_unit__c) || 
                            string.isblank(fs.level__c) || string.isblank(fs.justification__c)) {
                            canbefinal=0;
                        }
                } else if (fs.authorization_type__c == 'Open Ended Charge' || fs.authorization_type__c  == 'Other' || fs.authorization_type__c  == 'Single Charge') {
                        if (string.isblank(fs.service_Being_Funded_string__c) || string.isblank(fs.rate__c) || string.isblank(fs.rate_unit__c)) {
                            canbefinal = 0;
                        }
                } else if ( fs.authorization_type__c  == 'Bed Hold') {
                            canbefinal = 0;
                } else if (fs.authorization_type__c  == 'Single Charge' ) {
                        if (String.IsBlank(fs.authorization_comments__c)) {
                            canbefinal=0;
                        }
                }
                
                
                // more field checks
                if ( fs.authorization_type__c != 'Single Charge') {
                        if (fs.days_authorized_from__c == null || fs.days_authorized_to__c == null || String.IsBlank(fs.auth_given_method__c)) {
                            canbefinal=0;
                        }
                        if ( fs.authorization_type__c  != 'Bed Hold') {
                            if (String.IsBlank(fs.given_by__c)) {
                                canbefinal = 0;
                            }
                        }
                        
                        if (String.IsBlank(fs.representing_received__c)) {
                            canbefinal=0;
                        }
                        if ( fs.authorization_type__c  != 'Open Ended Charge' && fs.authorization_type__c  != 'Other')
                            if (String.IsBlank(fs.taken_by__c)) {
                                canbefinal=0;
                        }
                }
            }   
                    
            // this just counts how many fields are filled in - any field constitutes an attempt to create an auth so we know to save in draft  
            numFields += (String.IsBlank( fs.authorization_type__c )) ? 0 : 1;
            numFields += ( fs.received_date_time__c  == null ) ? 0 : 1;
            numFields += ( fs.days_authorized_from__c  == null ) ? 0 : 1;
            numFields += ( fs.days_authorized_to__c == null ) ? 0 : 1;
            numFields += (String.IsBlank( fs.requested_by__c )) ? 0 : 1;
            numFields += ( fs.request_date__c == null ) ? 0 : 1;
            numFields += (String.IsBlank( fs.request_contact_name__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.representing_request__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.reference_number__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.review_nurse__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.request_phone__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.request_fax__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.given_by__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.representing_received__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.auth_given_method__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.authorization_comments__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.level__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.rate__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.justification__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.service_being_funded_string__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.rate_unit__c )) ? 0 : 1;
            numFields += (String.IsBlank( fs.authorization_number__c )) ? 0 : 1;
            numFields += ( fs.received_date_time__c == null) ? 0 : 1;
            numFields += (String.IsBlank( fs.taken_by__c )) ? 0 : 1;
        
            
            List<integer> numflds = new List<integer>{ numfields, canbeFinal };
            return numflds;
    }
    
 
}