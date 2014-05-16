public with sharing class referralConversion_Controller {

  public Referral__c referralRecord { get; set; }
  public Person_Being_Referred__c personBeingRefRecord { get; set; }
  public Contact personBeingServedRecord { get; set; }

  public personRecord person {get; set;}
  public List<Referral_Location__c> refLocations { get; set; }
  public List<Related_Party__c> refRelParties { get; set;}
  public List<Agency_Involved_With_Individual__c> refAgencies { get; set;}
  public ID idPBR, idPBS, idAdm, idSA;
  public String NetworkOffering{ get; set; }
  private String[] programInfo;
  public String Program{ get; set;}
  public string Location{ get; set;}
  public string ServiceLine { get; set; }
  
  public referralConversion_Controller(ApexPages.standardController ctl){

    //this.referralRecord = (Referral__c) ctl.getRecord();
    this.refRelParties = new List<Related_Party__c>();
    this.refAgencies = new List<Agency_Involved_With_Individual__c>();
    this.refLocations = new List<Referral_Location__c>();

    this.referralRecord = getFullReferralRecord(((Referral__c) ctl.getRecord()).Id);
    
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
            'You have chosen to convert the referral ' + this.referralRecord.Name + '. Please confirm the information below and click Convert to Admission to continue the conversion process. If you would like to revise the referral, click Edit.' ));

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
    
    if  ( (tmp = this.referralRecord.Service_Location_Program__c) != null ) {
        
        programInfo = tmp.split('-');
        if (programInfo.size() > 3)
            Location = programInfo[3]; 
        //Program =  programInfo[1];
        Program = referralRecord.service_location__r.alias__c;
        //ServiceLine = programInfo[2];
        ServiceLine = referralRecord.service_location__r.service_value__c;
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
                        r.Service_Location_Zip__c, 
                        r.Service_Location_Street__c, 
                        r.Service_Location_State__c, 
                        r.Service_Location_Setting__c, 
                        r.Service_Location_Service_Value__c, 
                        r.Service_Location_Program__c, 
                        r.Service_Location_City__c, 
                        r.service_location__r.alias__c, 
                        service_location__r.service_value__c, 
                        r.Secondary_Diagnosis__c, 
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
                        r.Primary_Diagnosis__c, 
                        r.Phone__c, 
                        r.Person_Being_Served__c, 
                        r.Person_Being_Referred__c, 
                        r.OwnerId, 
                        r.OldPBR__c, 
                        r.Name_PBR__c, 
                        r.Name, 
                        r.Medicare_ID__c, 
                        r.Medicaid_ID__c, 
                        r.Level_of_Disability__c,
                        r.Legal_Guardian_Status__c, 
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
                        r.Axis_V__c, 
                        r.Axis_I__c, 
                        r.Axis_IV__c, 
                        r.Axis_II__c, 
                        r.Axis_III__c, 
                        r.Anticipated_Admission_Date__c, 
                        r.Agency_Name__c From Referral__c r
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
      pBRRec = [select Age__c, City__c, Date_of_Birth__c, Email_Address__c,
                       Ethnicity__c, Fax__c, First_Name__c, Gender__c,
                       Home_County__c, Last_Name__c, Marital_Status__c,
                       Middle_Initial__c, Phone__c, Primary_Language__c, Race__c, SSN__c,
                       State__c, Street_1__c, Street_2__c, Zip_Code__c,
                       Additional_Information_Comments__c, Sign_Language__c,
                       Legal_Guardianship_Status__c, Non_Verbal__c
                from Person_Being_Referred__c
                where Id = :idPBR
                limit 1];
      if ( String.IsBlank(pBRRec.Legal_Guardianship_Status__c))
        pBRRec.Legal_Guardianship_Status__c = referralRecord.Legal_Guardian_Status__c;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The Person Being Referred record id specified is invalid. ' + e.getMessage()));
    }
    System.Debug('currpbr =' + pBRRec.Legal_Guardianship_Status__c);
    return pBRRec;
  }
  
  
  private Contact getPBSRec() {
    Contact pBSRec;
    try {
      pBSRec = [select MailingCity, BirthDate, Email,
                       Ethnicity_Picklist__c, Fax, FirstName, Gender__c,
                       Mailing_County__c, LastName, 
                       Middle_Name__c, Phone, Primary_Language__c, Race__c, SSN__c,
                       MailingState, MailingStreet, MailingPostalCode, uci_id__c, medicaid_id__c, Marital_Status__c, non_verbal__c, sign_language__c, legal_guardianship_status__c
                       
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
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your referral has been converted!' ));
        
        PageReference pg = new PageReference('/' + idPBS);
        return pg;
        }
        catch (Exception e) {
            throw(e);
    
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
    
    // add case manager in as related party of type "case worker"
    if ( !String.IsBlank(referralRecord.Case_Manager_Name__c) ) {
        Related_Party__c rpnew = new Related_Party__c( Name = referralRecord.Case_Manager_Name__c, Type__c='Case Worker', Phone__c = referralRecord.Case_Manager_Phone__c, Person_Being_Served__c = idServ );
        insert rpnew;       
    }

    
  }
  
  private void linkAgencies( ID idServ) {
    for ( Agency_Involved_With_Individual__c r:  refAgencies ) {
        r.Person_Being_Served__c = idServ;
    }
    
    update refAgencies;
    
    
    // add case manager in as related party of type "case worker"
    
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
            throw new referralConversionException('Unable to create new Person Being Served - ' + e);
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
                                PersonMailingStreet = strFullSt, 
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
                                SSN__pc = pbrCurr.SSN__c,
                                Guardian1_Name__pc =  sGuardian1Name,
                                Guardian_1_Address__pc = sGuardian1Address,
                                Guardian_1_E_Mail__pc = sGuardian1Email,
                                Guardian_Phone_Number__pc = sGuardian1Phone,
                                UCI_ID__pc = string.valueOf(this.referralRecord.UCI_Number__c),
                                Marital_Status__pc = pbrCurr.Marital_Status__c,
                                Avatar_ID__pc = referralRecord.Billing_ID__c,
                                Avatar_Source_System__pc = strBillingSystem,
                                Legal_Guardianship_Status__pc = referralRecord.Legal_Guardian_Status__c,
                                Current_Medications__pc = referralRecord.Current_Medications__c
                                );
                                
    insert accNew;

    accNew = [ select id, personcontactid, firstname, lastname from account where id = :accNew.ID ];
    
    // link related parties to new Person Being Served
    linkRelParties( accNew.PersonContactId );
    
    // link agencies to new Person Being Served
    linkAgencies( accNew.PersonContactId );
    
    // return the contact id, not the account id
    return accNew.PersonContactId;
        
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
                Effective_date__c = refCurr.Anticipated_Admission_Date__c,
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
    
    ID idSAtype = [SELECT Id FROM RecordType WHERE SObjectType = 'Service_Assignment__c' AND DeveloperName ='Standard_Service_Assignment' limit 1].Id;
    
    string strLoc = getLocation();
    Service_Assignment__c newSA = new Service_Assignment__c(  
                                            RecordTypeId = idSAtype,
                                            Admission__c = idAdm,
                                            Person_Being_Served__c = idPBS,
                                            Start_Date__c = refCurr.Anticipated_Admission_Date__c,
                                            Status__c = 'Active',
                                            Program_Detail__c = refCurr.Service_Location_Program__c,
                                            Service_Location__c = refCurr.Service_Location__c,
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
                                            Referral__c = refCurr.Id
                                            
                                            );
    
    insert newSA;
    
    // if none of the diagnosis fields are blank or null, create new diagnosis record and link to SA 
    if ( !String.isEmpty(refCurr.Axis_I__c) || 
         !String.isEmpty(refCurr.Axis_II__c) || 
         !String.isEmpty(refCurr.Axis_III__c) ||
         !String.isEmpty(refCurr.Axis_IV__c) ||
         !String.isEmpty(refCurr.Axis_V__c) ||
         !String.isEmpty(refCurr.Primary_Diagnosis__c) ||
         !String.isEmpty(refCurr.Secondary_Diagnosis__c) ||
         !String.isEmpty(refCurr.Level_of_Disability__c) ||
         !String.isEmpty(refCurr.Comments__c)
    )
    {
        Diagnosis__c newDiag = new Diagnosis__c (
                                        Service_Assignment__c = newSA.Id,
                                        Axis_I__c = refCurr.Axis_I__c,
                                        Axis_II__c = refCurr.Axis_II__c,
                                        Axis_III__c = refCurr.Axis_III__c,
                                        Axis_IV__c = refCurr.Axis_IV__c,
                                        Axis_V__c = refCurr.Axis_V__c,
                                        Effective_Date__c = refCurr.Anticipated_Admission_Date__c,
                                        Primary_Diagnosis__c = refCurr.Primary_Diagnosis__c,
                                        Secondary_Diagnosis__c = refCurr.Secondary_Diagnosis__c,
                                        Level_of_Disability__c = refCurr.Level_of_Disability__c,
                                        Comments__c = refCurr.Comments__c
        );
        insert newDiag;
    }
    //Nurses Evaluation Creation - Sravan 5/15/2014
    if(refCurr.RecordTypeId=='012U0000000Dhni'){
   List <Evaluation__c> refEval = [SELECT ID, NAME FROM Evaluation__c WHERE Referral__c =:refCurr.Id LIMIT 1]; //using List to avoid System.Query Exception
    
    system.debug('SSSSSSSSSSSIIIIIIIIIIIIIZZZZZZEEEEEE'+refEval.size());
    	if(refEval.isEmpty()){
    		string pbslastName =  this.referralRecord.Name_PBR__c; //newSA.Admission__r.Person_Being_Served__r.LastName;
    		if(pbslastName == null) pbslastName = '';
                Evaluation__c nurseEval = new Evaluation__c(
    										ServiceAssignment__c = newSA.id,
    										Name= pbslastName +'NursesAssessment'+ DateTime.Now().format('MMddyy'),
    										RecordtypeId = '012J0000000DCMU'
    		
    		);
    		insert nurseEval;
    	}
    	else{
    		Evaluation__c nurEval = new Evaluation__c(
    										ServiceAssignment__c = newSA.id,
    										RecordtypeId = '012J0000000DCMU',
    										Name = refEval[0].Name
    										
    		);	
    		
    		insert nurEval;
    		
    		id evalID = refEval[0].id;
    	//	system.debug('IIIIIIIIIIIIIIDDDDDDDDDDD>>>>>>'+evalID);
    	//	Evaluation__c nursesAsses = new Evaluation__c();
    		String query = 'SELECT ';
    		FieldSet copyFields = SObjectType.Evaluation__c.FieldSets.NursingAssessment;
    		
    		for(Schema.FieldSetMember f : copyFields.getFields()) {
    			query += f.getFieldPath() + ', ';
    				
    		}
    		 query += 'Name FROM Evaluation__c WHERE ID =:evalID';
    		 //query += refCurr.Id;
    		// query +=
    		 
    		 nurEval = Database.query(query);
    		 
    		 update nurEval;
    		
    		
    	} 
    }
    
    // link the funding sources that were on the referral
    Contact pbsmed = [select id, medicaid_id__c from contact where id = :idPBS ];
    Boolean trytoupdatePBS = String.IsBlank( pbsmed.medicaid_id__c );
    Boolean updatePBS = false;
    List<Funding_Source__c> fundsrcList = [ select id, name, funding_source__c, Funding_Source_ID__c from funding_source__c where referral__c = :refCurr.Id];
    if ( fundsrcList.size() > 0 ) {
        for ( Funding_Source__c fs : fundsrcList ) {
            fs.Service_Assignment__c = newSA.Id;
            
            if ((fs.Funding_Source__c == 'Medicaid') && trytoupdatePBS ) {
                pbsmed.Medicaid_ID__c = fs.Funding_Source_ID__c;
                system.debug('Updating PBS ' + idPBS + ' with Medicaid ID ' + fs.Funding_Source_ID__c + ' from funding source ' + fs.Id);
                updatePBS = true; 
                trytoupdatePBS = false;
            }
        }
        update fundsrcList;
        if ( updatePBS )
            update pbsmed;
    }
    
    return newSA.Id;
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
    
    private String fn, ln, mi, em, f, p, s1, s2, ci, st, z, ct, eth, gen, lang, ss, marstat, medid, legalstat;
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
    public string SSN { get { return ss;} set; }
    public string MedicaidID { get { return medid;} set; }
    public string MaritalStatus { get { return marstat;} set; }
    public boolean NonVerbal { get { return nonverb;} set; }
    public boolean SignLanguage{ get { return signlang;} set; }
    public string LegalGuardianship { get {return legalstat;} set; }
    
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
        ss = pbr.SSN__c;
        marstat = pbr.Marital_Status__c;
        legalstat = pbr.Legal_Guardianship_Status__c;
        nonverb = pbr.Non_Verbal__c;
        signlang = pbr.Sign_Language__c;
        
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
        ss = pbs.SSN__c;
        marstat = pbs.Marital_Status__c;
        legalstat = pbs.Legal_Guardianship_Status__c;
        nonverb = pbs.Non_Verbal__c;
        signlang = pbs.Sign_Language__c;
        medid = pbs.Medicaid_Id__c; 
    }
    
    
}
class referralConversionException extends Exception {
    }
}