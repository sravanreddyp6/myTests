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
	public string age{set;get;}
	public string openLocationPopup {get; set;}
	public Referral__c referralRecord { get; set; }
	public Person_Being_Referred__c personBeingRefRecord { get; set; }
	public Contact personBeingServedRecord { get; set; }
	public List<Person_Being_Referred__c> refResults { get; set; }
	public ID referralLocationId { get; set; }
	public String referralLocationName { get; set; }
	public String admissionLocationName {get; set;}
	public Map<Id, Boolean> editableTasks { get; set; }
	public Boolean isCambridge { get; set; }
	public Boolean isCareMeridian{get; set;}
    
    //Diagnosis changes
    public list<Diagnosis__c> diagnoses{get; set;}
    public Diagnosis__c diag {
        get {
            if (diag == null)
                diag = new Diagnosis__c();
            return diag;
        }
        set;
    }
    public static Boolean showdiagModal { get; set; }
    public Boolean newDiagnosis{ get; set;}
    public string diagEditId {get; set; }
    public void showAddDiagnosis() {
        newDiagnosis = true;
        showdiagModal = true;
        diag = new Diagnosis__c();
        System.Debug('showdiagModal='+ showdiagModal);
    }
    public void showEditDiagnosis() {
        showdiagModal = true;
        System.Debug('showdiagModal=' + showdiagModal);
    }
    
         
    public void saveDiagnosis() {
        newDiagnosis = true;
    	system.debug(this.diag);
		this.diagnoses.add(this.diag);
		this.diag = new Diagnosis__c();
    }  
    
    //end
	public String relPartiesJSON {get {
		List<RelatedParty> relPartiesData = new List<RelatedParty>();
		if (relParties.size() > 0) {
			for (Related_Party__c rp :relParties){
				relPartiesData.add( new RelatedParty(rp.id, rp.Type__c) );
			}
		}
		return JSON.serialize(relPartiesData);}
	}
	public Id nonClosedPrimaryLocationId {
		get {
			for (Referral_Location__c rl: locations) {
				if (rl.Rank__c == 'Primary' && rl.Status__c != 'Closed' && rl.Status__c != '') {
					return rl.Id;
				}
			}
			return null;
		}
	}

	public class RelatedParty{
		Id Id;
		String TypeC;
		RelatedParty(Id id, String typeC){
			this.Id = id;
			this.TypeC = typeC;
		}
	}

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
				activity.RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks');
			}
			return activity;
		}
		private set;
	}
	public List<Task> activities { get; set; }
	// For Neuro - the user Id to assign the admission steps (tasks) to
	public Id userIdToAssignTasks { get; set; }
	// We use a dummy task record in order to be able to use Salesforce's
	// standard user chooser widget.
	public Task dummyTask { get; set; }
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
	
	SystemSettings__c OS = SystemSettings__c.getOrgDefaults(); // Custom setting to control the visibility of convert button for CareMeridian group Sravan: 07/10/2014 1:42 PM.
	public boolean canConvert{ get {
	
        Set<string> RWStates = new Set<string>{'Minnesota', 'California', 'Indiana', 'Iowa'};
        system.debug( 'Ref record type: ' + referralrecordtype );
        system.debug(' is cambridge:' + iscambridge);
        system.debug(' operatinggroup:' + operatinggroup);
        return ((operatinggroup == 'Cambridge' && isCambridge )|| 
                (operatinggroup == 'Redwood' && RWStates.contains( referralrecordtype ) ) || 
                (operatinggroup == 'CareMeridian' && isCareMeridian && OS.Referral_ConvertCMEnabled__c ) ||
                (operatinggroup == 'Redwood' && referralrecordtype == 'Wisconsin' && showCANS ) ||
                (operatinggroup == 'NeuroRestorative' && referralRecord.State_for_Preferred_Service__c == 'Illinois' ) ||
                (referralrecordtype == 'CA FSS' && isCAFSS)
            );
            
    } set;}
    
    //EB-481
	public boolean gethasPrimaryFS(){
		boolean tmp = false;		
		for(Funding_Source__c fs : fundingSources){		
			if(fs.Type_of_Coverage__c == 'Primary' && fs.ID == fundingSource.id){tmp = false; break;}
			if(fs.Type_of_Coverage__c == 'Primary' && fs.ID != fundingSource.id){tmp = true;}		
		}		
		return tmp;
	}

	// shortcut used for WI CANS programs - need the ability to convert only some programs in order to do CANS.  This is the same code used on the Admission View page to show CANS button.
	public boolean showCANS { get; set; }
	private void setshowCANS() {
    	
    	showCANS = false;
    	
    	// look for this op grp in the custom setting
    	List<CANS_Settings__c> cansList = [ select name, state__c, programs__c from CANS_Settings__c where name = :operatingGroup];
    	// this op group isn't allowed 
    	if ( cansList.size() == 0 )
    		return;
    	
    	String refState = Utility.getStateCodeFromName(referralRecord.State_for_Preferred_Service__c);
    	
    	Set<string> states = new Set<string>();
    	set<string> programs = new Set<string>();
    	
    	for ( CANS_Settings__c c : cansList ) {
    		if ( !String.IsEmpty(c.state__c) )
    			states.add( c.state__c);
    		if ( !String.IsEmpty(c.programs__c))
    			programs.addAll( c.programs__c.split(','));
    	}
    	
    	
    	// if there's a state listed, check against admission state
    	// if no states are listed, then all states apply
    	if ( states.size() > 0 && !states.contains( refState )  )
    		return;
    		
    	// if there's a program listed, check against SA programs - check both alias and full program id
    	Boolean match = false;
    	if ( programs.size() > 0 ) {
			if ( !programs.contains ( referralRecord.service_location__r.alias__c ) && !programs.contains ( referralRecord.service_location__r.programid__c )) {
				return;
			}
		}
	
    	
    	// if we got past other tests, then set flag to true
    	showCANS = true;	
    	
    }

	public Boolean canUpdateReferral {
		get {
			return Schema.sObjectType.Referral__c.isUpdateable();
		}
	}
	public Boolean canUpdateEvaluation {
		get {
			return Schema.sObjectType.Evaluation__c.isUpdateable();
		}
	}
	public Boolean canCreateEvaluation {
		get {
			return Schema.sObjectType.Evaluation__c.isCreateable();
		}
	}

	// NEVAL-32
	public Boolean showNeuroFeatures {
		get {
			if (showNeuroFeatures == null) {
				showNeuroFeatures = OS.Referral_Neuro_Features_Enabled__c;
			}
			return showNeuroFeatures;
		}
		set;
	}

	public boolean isCAFSS{get; set;}
	public static final String REFERRAL_EDIT_URL = '/apex/referral';
	public static final String REFERRAL_CONVERT_URL = '/apex/referralConversion';

	public referral_Controller2(ApexPages.standardController ctl){
		system.debug('in constructor');
		if(!test.isRunningTest()){
			ctl.addFields(new list<string>{'Service_Location__r.Name', 'Service_Location__r.Alias__c', 'Service_Location__r.ProgramID__c'});
		}
		this.referralRecord = (Referral__c) ctl.getRecord();
		/* this.operatinggroup=([select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].isEmpty())?''
                :[select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1][0].operating_group__c;*/
                
        list<Tmn_User__c> tmnUser = [SELECT Id,operating_group__c,Business_Unit__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1]; //Using list to prevent system.query exception 
		this.isCAFSS = false;
		if(tmnUser.size() > 0){
			this.operatinggroup = tmnUser[0].operating_group__c;
			this.isCAFSS = (null != tmnUser[0].Business_Unit__c && tmnUser[0].Business_Unit__c.startsWith('BU 008')) ? true : false;
		}
		this.referralRecord = (Referral__c) ctl.getRecord();
		this.agencies = new List<Agency_Involved_With_Individual__c>();
		this.fundingSources = new List<Funding_Source__c>();
		this.relParties = new List<Related_Party__c>();
		this.activities = new List<Task>();
		this.editableTasks = new Map<Id, Boolean>();
		this.locations = new List<Referral_Location__c>();
		this.dummyTask = new Task();
		this.openLocationPopup = 'do not open';
		this.admissionLocationName = this.referralRecord.Service_Location__r.Name;

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
		setshowCANS();
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
		List<UserRecordAccess> acls = [
			SELECT RecordId, HasEditAccess
			FROM UserRecordAccess
			WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.referralRecord.Id
		];

		if (acls.size() > 0) {
			isEditor = acls[0].HasEditAccess;
		} else {
			isEditor = false;
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
		referralRecord.Has_Evaluation__c = true;
		update referralRecord;

		return new PageReference('/' + eval.Id + '/e');
	}

	private void populateRelParties() {
		if (this.personBeingRefRecord.Id == null && this.personBeingServedRecord.Id == null)
			return;

		try {
			if(this.personBeingRefRecord != null && this.personBeingRefRecord.Id != null){
				this.relParties = [
					select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c, Status__c, Person_Being_Referred__c, CreatedDate
					from Related_Party__c
					where Person_Being_Referred__c = :this.personBeingRefRecord.Id order by Type__c, Name
					limit 150
				];
			} else if (this.personBeingServedRecord != null && this.personBeingServedRecord.Id != null){
				this.relParties = [
					select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c, Status__c, Person_Being_Referred__c, Person_Being_Served__c, CreatedDate
					from Related_Party__c
					where Person_Being_Served__c = :this.personBeingServedRecord.Id order by Type__c, Name
					limit 150
				];
			}

		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				'An error occurred retrieving Related Parties. ' + e.getMessage()));
		}
	}

	private void populateLocations() {
		this.locations = [
			select Id, Name, Referral__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c, status__c,
			       service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c,service_location_program__c,
			       service_location_service_value__c, service_location_setting__c, service_location__c, rank__c, LastModifiedDate
			from Referral_Location__c
			where Referral__c = :this.referralRecord.Id
			limit 150
		];
	}
	private void populateAgencies() {
		if (this.personBeingServedRecord != null && this.personBeingServedRecord.Id != null) {
			this.agencies = [
				select Id, Name, Address__c, Phone__c, Reason_for_Involvement__c, Referral__c, CreatedDate
				from Agency_Involved_With_Individual__c
				where Referral__c = :this.referralRecord.Id OR Person_Being_Served__c = :personBeingServedRecord.Id
				limit 150
			];			
		}
		else{
			this.agencies = [
				select Id, Name, Address__c, Phone__c, Reason_for_Involvement__c, Referral__c, CreatedDate
				from Agency_Involved_With_Individual__c
				where Referral__c = :this.referralRecord.Id
				limit 150
			];		
		}

	}

	private void populateFundingSources() {
		this.fundingSources = [
			select id, Payor__c, Funding_Source__c, Payer_Type__c, Funding_Source_ID__c, Status__c, Service_Being_Funded__c, Comment__c, Referral__c,
			       type_of_coverage__c, payer_name__c, effective_date__c, termination_date__c, CreatedDate
			from Funding_Source__c
			where Referral__c = :this.referralRecord.Id
			order by Type_of_Coverage__c
			limit 150
		];
	}

	private void populateActivities() {
		this.activities = [
			select Id, Subject, Priority, Status, WhatId, OwnerId, ActivityDate, Comments__c , Description
			from Task
			where WhatId = :this.referralRecord.Id
			order by number__c, createddate
			limit 150
		];
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
				this.relatedReferrals = [
					select Id, Name, Referral_Status__c from Referral__c
					where Person_Being_Served__c = :this.personBeingServedRecord.Id and id != :this.referralRecord.Id
					order by Name
				];
			} else if (this.personBeingRefRecord != null && this.personBeingRefRecord.Id != null) {
				this.relatedReferrals = [
					select Id, Name, Referral_Status__c from Referral__c
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
			pBRRec = [
				select Age__c, City__c, Date_of_Birth__c, Email_Address__c,Age_month__c,Age_year__c,Age_days__c,
				       Race__c, Ethnicity__c, Fax__c, First_Name__c, Gender__c,
				       Home_County__c, Last_Name__c, Marital_Status__c,
				       Middle_Initial__c, Phone__c, Primary_Language__c, //SSN__c,
				       State__c, Street_1__c, Street_2__c, Zip_Code__c,
				       Additional_Information_Comments__c, Sign_Language__c,
				       Legal_Guardianship_Status__c, Non_Verbal__c, Full_Name__c,
				       Level_of_Education__c
				from Person_Being_Referred__c
				where Id = :pBRId
				limit 1
			];
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				'The Person Being Served record id specified is invalid. ' + e.getMessage()));
		}
		//PRI-166 ensure month is calculated the same way as PBS
		string monthAlias = pBRRec.Age_month__c;
		if(pBRRec.Age_days__c!=null && integer.valueof(pBRRec.Age_days__c) > 14){
			monthAlias = string.valueof(integer.valueof(monthAlias) + 1);
		}
		system.debug('age ' + String.valueOf(pBRRec.Age_year__c) + ' - ' + pBRRec.Age_month__c + ' - ' + pBRRec.Age_days__c);
			this.age = 	Utility.getAge(String.valueOf(pBRRec.Age_year__c),monthAlias,pBRRec.Age_days__c);
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
			pBSRec = [
				select Age__c, MailingCity, BirthDate, Email,  Race__c, Marital_Status__c,  Sign_Language__c, Non_Verbal__c,Mailing_Street_2__c,Mailing_County__c,
				       Fax, FirstName, Gender__c,Age_month__c,Age_year__c,Age_days__c,
				       LastName, Ethnicity_Picklist__c,
				       Middle_Name__c, Phone, Primary_Language__c, //SSN__c,
				       MailingState, MailingStreet, OtherStreet, MailingPostalCode,
				       Level_of_Education__c
				from Contact
				where Id = :pBSId
				limit 1
			];
			
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				'The Person Being Served record id specified is invalid. ' + e.getMessage()));
		}
	this.age = 	Utility.getAge(pBSRec.Age_year__c,pBSRec.Age_month__c,pBSRec.Age_days__c);
		return pBSRec;
	}
	
	
	public void showAddActivity() {
		activity = new Task();
		activity.Priority = 'Normal';
		activity.OwnerId = UserInfo.getUserId();
		activity.Status = 'Not Started';
		activity.RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks');
	}

	public void saveActivity() {
		populateActivities();
		activity = new Task();
		activity.Priority = 'Normal';
		activity.OwnerId = UserInfo.getUserId();
		activity.Status = 'Not Started';
		activity.RecordTypeId = Utility.getRecordTypeForTask('Referral Tasks');
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
			if ( fundingSource.RecordTypeId == CMID) {
				fundingSource.Authorization_type__c = 'Initial'; // set default value that is not being honored in late render on jquery dialog
			}
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
		relParty.Status__c = 'Active';
	}

	public void saveRelParty() {
		populateRelParties();
		this.relParty = new Related_Party__c();
		this.relParty.Status__c = 'Active';
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
	
	public pageReference saveAdmissionLocation(){
		update this.referralRecord;
		
		PageReference pg= new PageReference(REFERRAL_CONVERT_URL +'?id='+referralRecord.id);
		pg.setRedirect(true);
		return pg;
	}

	public PageReference redirectToEdit() {
		PageReference pg = new PageReference(REFERRAL_EDIT_URL +'?id='+referralRecord.id);
		pg.setRedirect(true);
		return pg;
	}
	public PageReference redirectToSearch() {
		PageReference pg = new PageReference('/apex/referralSearch?referralId='+referralRecord.id+'&pbrId='+personBeingRefRecord.id+'&pbsId=' +personBeingServedRecord.id+'&viewmode=yes');
		pg.setRedirect(true);
		return pg;
	}
	public PageReference redirectToConversion() {
		//EC-110 Sravan - 03/27/2015 
		if (checkRequiredFields() && referralRecordType == 'CareMeridian') {
			this.openLocationPopup = 'open';
			return null;
			
		}
		else if (checkRequiredFields() && referralRecordType != 'CareMeridian'){
			pageReference pg = new PageReference(REFERRAL_CONVERT_URL +'?id='+referralRecord.id);
			pg.setRedirect(true);
			return pg;
			
		}
	   else{
	 		this.openLocationPopup = 'do not open';
		 	return null;
			}
			
	}
	public boolean checkRequiredFields(){
		List<String> messages = new List<String>{};
		boolean hasReq = false;
		
	 //start CTEAE-137
        if(ReferralRecordType=='Cambridge North Carolina'){
            if(referralRecord.Payer_Medical_Record_Number__c == null ){
                messages.Add( 'Payer/Guarantor Medical Record Number' );
                hasReq = false;
            }
            if(referralRecord.Payer_Medical_Record_Number_Description__c == null){
                messages.Add( 'Payer/Guarantor Medical Number Description' );
                hasReq = false;
            }
        }
        //end CTEAE-137
        //eb-428
        if(referralRecordType == 'NeuroRestorative'){
            boolean PT = false;
            boolean CL = false;
            for(Funding_Source__c fs :fundingSources){
                if(fs.Type_of_Coverage__c == 'Primary'){
                    CL = true;   
                    if(fs.Payer_Type__c != null ){
                    	PT = true;
                	} 
                }

            }
            if(!CL || !PT){
                messages.Add('One Funding Source must have both "Coverage Level" = "Primary" and any "Payer Type" selected');
                hasReq = false;
            }                    
            if(referralRecord.Diagnosis_I__c == null){
                messages.Add('Primary Diagnosis');
                hasReq = false;             
            }   
            if(referralRecord.Date_of_Injury__c == null){
                messages.Add('Date of Injury');
                hasReq = false;             
            }
            if(referralRecord.Cause_of_Injury_pick__c == null){
                messages.Add('Cause of Injury');
                hasReq = false;             
            }   
            if(referralRecord.Current_Location_Type__c == null){
                messages.Add('Current Location Type');
                hasReq = false;             
            }                               
        }
        

		// requirements to create a new PBS
		if ( (string.valueOf(this.referralRecord.Person_Being_Served__c) == '' )) {
			//PRI-189
			if (personBeingRefRecord.First_Name__c == null) {
			hasReq = false;
			messages.Add( 'First Name');
			}
			// need last name, state of residence
			if ( this.personBeingRefRecord.Last_Name__c == null) {
				messages.Add( 'Last Name' );
				//this.personBeingRefRecord.Last_Name__c.AddError('Last Name' );
				hasReq = false;
			}
			//PRI-189
			if (personBeingRefRecord.Gender__c == null) {
			hasReq = false;
			messages.Add( 'Gender');
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
						messages.Add( 'The person being referred is younger than 18 years old. Please add a person with the Type of Guardian to the Related Parties Section below.');
					}
				}

			}
		}

		
		//start CTEAE-137
		if(ReferralRecordType=='Cambridge North Carolina'){
			if(referralRecord.Payer_Medical_Record_Number__c == null ){
				messages.Add( 'Payer/Guarantor Medical Record Number' );
				hasReq = false;
			}
			if(referralRecord.Payer_Medical_Record_Number_Description__c == null){
				messages.Add( 'Payer/Guarantor Medical Number Description' );
				hasReq = false;
			}
		}
		//end CTEAE-137

		//start EC-54
		if(referralRecordType == 'CareMeridian'){
			Boolean hasPrimaryLoc = false, hasPrimaryFund = false;
			if(referralRecord.Current_Location__c == null){
				messages.Add('Current Location');
				hasReq = false;
			}
			if(referralRecord.Agency_Name__c == null){
				messages.Add('Referral Source');
				hasReq = false;
			}
			if(referralRecord.Evaluated_By_Internal__c == null){
				messages.Add('Evaluated by');
				hasReq = false;
			}
			if(fundingSources.size() == 0){
				messages.Add('Primary Funding Source');
				hasReq = false;
			}
			if(locations.size() == 0){
				messages.Add('Primary Requested Location');
				hasReq = false;
			}
			for(Referral_Location__c rl :locations){
				if(rl.Rank__c == 'Primary'){
					hasPrimaryLoc = true;
					break;
				}
			}
			if(!hasPrimaryLoc){
				messages.Add('Primary Requested Location');
				hasReq = false;
			}
			for(Funding_Source__c fs :fundingSources){
				if(fs.Type_of_Coverage__c == 'Primary'){
					hasPrimaryFund = true;
					break;
				}
			}
			if(!hasPrimaryFund){
				messages.Add('Primary Funding Source');
				hasReq = false;
			}
		}
		//End EC-54

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
                        messages.Add( 'The person being referred is younger than 18 years old. Please add a person with the Type of Guardian to the Related Parties Section below.');
                    }
                }

            }
        }
		// requirements for admission and service assignment: anticipated admission date, anticipated location
		//Ec-110 Sravan 03/27/2014
		if ( this.referralRecord.Anticipated_Admission_DateTime__c == null && OperatingGroup != 'CareMeridian' && referralRecordType != 'CareMeridian') {
			messages.Add( 'Anticipated Admission Date Time' );
			hasReq = false;
		}

		System.Debug( ' anticipated service location = ' +this.referralRecord.Service_Location__c );
		//Added the And condtion to bypass the conversion error for CareMerdian Flavor - Sravan 5/15/2014.
		//EB214. Closing a referral with the reason 'admitted' mandates the admission location for all flavours. So be logic applies to all. - Neeraj 10/22/2014
		//Latest Update - EC-110 Service Location will be entered in the ontermediate screen by CM users. - Sravan 03/27/2014 10:45 AM
		if ( String.IsBlank(this.referralRecord.Service_Location_Program__c) && OperatingGroup != 'CareMeridian' && referralRecordType != 'CareMeridian') {
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

	public void addAdmissionSteps() {
		if (dummyTask.OwnerId == null) {
			dummyTask.OwnerId.addError('Field is required!');
			return;
		}
		Map<String, Admission_Step__c> allStepSubjects = Admission_Step__c.getAll();
		Map<String, Admission_Step__c> stepSubjects = new Map<String, Admission_Step__c>();
		for (String key: allStepSubjects.keySet()) {
			if (allStepSubjects.get(key).Record_Type__c == ReferralRecordType) {
				stepSubjects.put(key, allStepSubjects.get(key));
			}
		}
		Set<String> nameSet = stepSubjects.keySet();
		List<Integer> orderedNames = new List<Integer>();  // We use this list to sort the subjects by their names
		for (String name: nameSet) {
			orderedNames.add(Integer.valueOf(name));
		}
		orderedNames.sort();
		Id taskRecordType = Utility.getRecordTypeForTask('Referral Tasks');
		for (Integer orderedName: orderedNames) {
			// We do not batch insert the tasks here because it leads to inconsistent
			// sorting order.
			Task task = new Task(
				Subject = stepSubjects.get(String.valueOf(orderedName)).Subject__c,
				Priority = 'Normal',
				Status = 'Not Started',
				WhatId = referralRecord.Id,
				OwnerId = dummyTask.OwnerId,
				RecordTypeId = taskRecordType,
				ActivityDate = referralRecord.Referral_Date__c
			);
			if (task.Subject == 'Schedule Assessment')
                    task.ActivityDate = task.ActivityDate + 3;
                
            else if (task.Subject == 'Complete Assessment')
                    task.ActivityDate = task.ActivityDate + 7;
                
            else if (task.Subject == 'Assessment follow-up with Referral Source')
                    task.ActivityDate = task.ActivityDate + 8;
                
            else if (task.Subject == 'Upload CAT to iServe') 
                    task.ActivityDate = task.ActivityDate + 15;
                
            else if (task.Subject == 'Schedule a Red Flag call (if applicable)') 
                    task.ActivityDate = task.ActivityDate + 15;
            
            else
                	task.ActivityDate = null;
            insert task;
		}
		populateActivities();

		// We also want to make sure that the user can't do this action more than once
		referralRecord.Admission_Steps_Added__c = true;
		update new Referral__c(Id=referralRecord.Id, Admission_Steps_Added__c=true);
	}
	
}