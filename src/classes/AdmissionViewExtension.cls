public with sharing class AdmissionViewExtension {
        public String[] availableAssessmentTypes { get {
           return new String[] {'Risk', 'CANS', 'ISSA'};
        }}
    public Admission__c admission { get; set; }
    public Assessment__c[] riskAssessments { get; set; }
    public Assessment__c[] cansAssessments { get; set; }
    public Assessment__c[] issaAssessments { get; set; }
    public Map<String, Boolean> assessmentTypes { get; set; }
    public boolean isEditor { get; set;}
    public Map<Id, Boolean> editableSerAsmts { get; set; }
    public boolean canCreateAsmt{ get; set;}
    public boolean canCreateSvc{ get; set;}
    public boolean canCreateAdm{ get; set;}
    public boolean canCreatePlan{ get; set;}
    public boolean showCANS { get; private set; }
	public boolean hasResidentialSA { get; private set; }

    public TMN_User__c curUser{get;set;}
    public list<Service_Assignment__c> allSAforAdmint{get; set;}
    //pri-206
    public String getStartDateValue() {
    	DateTime dateTimeValue = admission.Admission_Effective_DateTime__c;
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
            return localeFormatDT;
        }
        return null;
    }
    //PRI-218 219
    public boolean reqAdmittedFrom {get{return AdmissionEditViewCommon.setReqAdmittedFrom(curUser,allSAforAdmint);} set;}
    public boolean reqDcTo { get{ return AdmissionEditViewCommon.setReqDcTo(curUser,allSAforAdmint);} set;}
    public boolean shwDcTo { get{ return ( reqDcTo || curUser.Operating_Group__c.StartsWith('Neuro')
                                         || curUser.Operating_Group__c == 'Adult Day Health' );} set;}

    // EC-185 - capturing service discharge info - only applicable for CM to start
    public boolean useDischargeSection { get; set; }

    private void setisEditor() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.admission.Id];

        if (acls.size() > 0) {
            isEditor = acls[0].HasEditAccess;
        } else { isEditor = false;}


    }
    
    private void setcanEditSA() {
        
        Id[] saIds = new Id[]{};
        
    	// PRI-270 - determine if user has an active Residential SA for the annual health and wellness
    	hasResidentialSA = false;
        for (Service_Assignment__c sa: allSAforAdmint) {
            saIds.add(sa.ID);
            
            if ( sa.service_location__r.tmn_scope__c == 'Residential' && sa.status__c == 'Active')
            	hasResidentialSA = true;
            
        }
        UserRecordAccess[] recordAccess = [
            SELECT RecordId, HasEditAccess FROM UserRecordAccess
            WHERE UserId=:UserInfo.getUserId()
            AND RecordId IN :saIds
        ];
        
        for (UserRecordAccess ra: recordAccess) {
            editableSerAsmts.put(ra.RecordId, ra.HasEditAccess);
        }
    }

    private void setcanCreateAsmt() {
        Schema.DescribeSObjectResult oSchema = Assessment__c.sObjectType.getDescribe();
        canCreateAsmt = oSchema.IsCreateable();
    }


    private void setshowCANS() {

    	showCANS = false;
    	// look for this op grp in the custom setting
    	List<CANS_Settings__c> cansList = [ select name, state__c, programs__c from CANS_Settings__c where name = :getOperatingGroup()];
    	// this op group isn't allowed
    	if ( cansList.size() == 0 )
    		return;

    	String admState = admission.state__c;

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
    	if ( states.size() > 0 && !states.contains( admState ) )
    		return;

    	// if there's a program listed, check against SA programs - check both alias and full program id
    	Boolean match = false;
    	if ( programs.size() > 0 ) {
    		IgnoreSharing noSharing = new IgnoreSharing();
    		List<service_assignment__c> saPrograms = noSharing.getallSA(admission.Id);

    		for (service_assignment__c p: saPrograms) {
    			if ( programs.contains ( p.service_location__r.alias__c ) || programs.contains ( p.service_location__r.programid__c )) {
    				match = true;
    				break;
    			}
    		}
    		if (!match)
    			return;
    	}

    	// if we got past other tests, then set flag to true
    	showCANS = true;

    }

    private string getOperatingGroup() {
    	// what is this user's operating group
    	try {
    		TMN_User__c thisTMN = [ select id, operating_group__c from TMN_user__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];
    		//Added and using the query below to Support 'CA FSS' or 'BU 008' business unit - Sravan -Sep 9,2015 - CAFSS-5
    		List<TMN_User__c> pbsOwnerTMN = [SELECT Id, Business_Unit__c, operating_group__c FROM TMN_User__c WHERE salesforce_user_account__c =:this.admission.Person_Being_Served__r.OwnerId LIMIT 1];
    		if(pbsOwnerTMN.size() > 0 && null != pbsOwnerTMN[0].Business_Unit__c &&  pbsOwnerTMN[0].Business_Unit__c.startswith('BU 008')){
    			return 'CA FSS';
    		}
    		else{
    			return thisTMN.operating_group__c;
    		}
    	} catch (Exception e) {
    		return '';
    	}
    }

    private void setcanCreateAdm() {
        Schema.DescribeSObjectResult oSchema  = Admission__c.sObjectType.getDescribe();
        canCreateAdm = oSchema.IsCreateable();
        	if(canCreateAdm ){
           List<Admission__c>  admissionList=[select id,Name,Discharged_Date__c, Admission_Effective_DateTime__c, Effective_Date__c, Status__c
        		        from Admission__c where  Discharged_Date__c  = null and Person_Being_Served__c =: admission.Person_Being_Served__c AND Status__c != 'Created in Error'];
        		if(admissionList.size()>0) {
        			canCreateAdm = false;
        		}
        	}
    }

    private void setcanCreateSvc() {
        Schema.DescribeSObjectResult oSchema = Service_Assignment__c.sObjectType.getDescribe();
        canCreateSvc = oSchema.IsCreateable();
    }

    private void setcanCreatePlan() {
        Schema.DescribeSObjectResult oSchema = Plan__c.sObjectType.getDescribe();
        canCreatePlan = oSchema.IsCreateable();
    }

    public AdmissionViewExtension(ApexPages.StandardController stdController) {
        // set current user
        curUser = new TMN_User__c();
        // EC-185 get operating group for whether to show new discharge section
        useDischargeSection = false;
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
         	curUser = TU;
         	if (TU.Operating_Group__c == 'Care Meridian' && this.admission.Person_Being_Served__r.Flavor__c !='Ludlow') {
         		useDischargeSection = true;
         	}

        }
        this.admission = [
                SELECT ID, Name, CreatedBy.Name, CreatedDate, LastModifiedBy.Name,
                           LastModifiedDate, Effective_Date__c, Admission_Effective_DateTime__c, Status__c,
                           Discharged_Date__c, Discharged_date_time__c, Person_Being_Served__c, Person_Being_Served__r.AccountID, person_being_served__r.Name,Person_Being_Served__r.OwnerId, person_being_served__r.LastName,person_being_served__r.Flavor__c,
                           Network_Offering__c, Discharged_Status__c, Reason_for_Discharge__c, State__c,
                           Referred_Out_Date__c, Referred_Out_Agency_Name__c, Reason_Other__c,Referred_Out_Reason__c, Discharged_Reason__c,
                           Planned_Discharge__c, Discharged_to_category__c, Discharged_to_subcategory__c, Discharged_to_additional__c, Discharged_to_other__c,
                           Discharged_Reason_subcategory__c, Discharged_reason_additional__c, Additional_Discharge_Info__c,
                           Discharged_to_desc__c, Specify_Error__c,
                           (SELECT Name, Authorization_Status__c, Payer_Authorization_Date__c, Payer_Effective_Date__c, Payer_End_Date__c, Payer_Authorization_ID__c, Payer_Name__c, Number_Of_Authorized_Units__c, Remaining_Units__c FROM Authorized_Services__r),
                           (SELECT Name, Assessment_Date__c, Score__c, Owner.FirstName, Owner.LastName, Status__c FROM Assessments__r),
                           (SELECT Name, Person_Being_Served__r.Name, Status__c, Start_Date__c, SA_Start_DateTime__c, End_Date__c FROM Service_Agreements__r ORDER BY Status__c, Start_Date__c),
                           (SELECT Name, Status__c, Effective_Date__c, Plan_Expiration_Date__c, Long_term_Goal_1__c FROM Plans__r),
                           (SELECT Name, Plan__r.Name, First_Name__c, Last_Name__c, Start_Time__c, End_Time__c, Type_of_Contact__c, Purpose_Nature_of_Service__c FROM Progress_Notes__r),
                           (SELECT Name, Status__c FROM Health_Wellness_Checklists__r)
                FROM Admission__c WHERE ID=:ApexPages.currentPage().getParameters().get('id')
        ];
        
		this.editableSerAsmts = new Map<Id, Boolean>();
        allSAforAdmint = new list<Service_Assignment__c>();
        allSAforAdmint = [select id, name, Service_Location__r.Program__c, Service_Location__r.Setting__c, Service_Location__r.Network_Offering__c,Service_Location__r.TMN_Scope__c, status__c from Service_Assignment__c where Admission__c = :this.admission.id];
        // We decide to show/hide the New Assessment button based on Role and
        // Permission instead of hardcoding them.
        Assessment_Type__c[] types = [
            SELECT Name FROM Assessment_Type__c
        ];
        assessmentTypes = new Map<String, Boolean>();
        for (String t: availableAssessmentTypes) {
            assessmentTypes.put(t, false);
        }

        for (Assessment_Type__c t: types) {
                assessmentTypes.put(t.Name, true);
        }
        this.riskAssessments = fetchAssessments('Risk', this.admission.ID);
        IgnoreSharing noSharing = new IgnoreSharing();
        this.cansAssessments = noSharing.getAllCans(this.admission.ID);
        this.issaAssessments = fetchAssessments('ISSA', this.admission.ID);

        setcanCreateAsmt();
        setshowCANS();
        setcanCreateAdm();
        setcanCreateSvc();
        setcanCreatePlan();
        setIsEditor();
        setcanEditSA();	// includes setting of hasResidentialSA
        
		//----Execute below code only if Flavor is Oregon----
		if(this.admission.person_being_served__r.Flavor__c == 'Oregon'){
			this.dummyTask = new Task();
			this.intakeTask = new Task(OwnerId = UserInfo.getUserId());
			this.intakeSteps = new list<Task>();
			this.showIntakeSteps = true;
			populateIntakeSteps();
		}
		//---------------End Oregon flavor--------------
		
    }

    private Assessment__c[] fetchAssessments(String name, String admissionId) {
        if(name=='ISSA') {
	        return [
	           SELECT Name, Assessment_Date__c, Finalized_Date__c, Score__c,
	                  Owner.FirstName, Owner.LastName, Owner.Name, Status__c
	           FROM Assessment__c
	           WHERE Type__c=:name AND Admission__c=:admissionId Order By CreatedDate DESC
	        ];
        }
        else {
	        return [
	           SELECT Name, Assessment_Date__c, Finalized_Date__c, Score__c,
	                  Owner.FirstName, Owner.LastName, Owner.Name, Status__c, disregard__c
	           FROM Assessment__c
	           WHERE Assessment_Type__r.Name=:name AND Admission__c=:admissionId Order By CreatedDate DESC
	        ];
        }
    }
    public PageReference createRiskAssess(){
        Assessment__c assess = new Assessment__c ();
        Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'risk' limit 1];
        assess.Assessment_Type__c = Type.id;
        assess.Admission__c = admission.id;
        assess.Status__c = 'Inactive Draft';
        insert assess;
        PageReference ref =  new PageReference('/'+assess.id + '?new=1');

        return ref;
    }
    public PageReference createIssaAssess(){
        Assessment__c assess = new Assessment__c ();
        assess.Type__c = 'ISSA';
        assess.Admission__c = admission.id;
        assess.Status__c = 'Inactive Draft';
        insert assess;
        PageReference ref =  new PageReference('/'+assess.id + '?new=1');

        return ref;
    }
    public id getCANsID(){
        Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'CANS' limit 1];
        return type.id;

    }

    public id getRisk_Overview(){
        id theId;
        theID = [select id, developername from report where developername = 'Risk_Assessment_Acknowledgment_Overview' limit 1].id;

        return theId;


    }

    public without sharing class IgnoreSharing{
        public list<Assessment__c> getAllCans(ID admissionId){
            return [
               SELECT Name, Assessment_Date__c, Finalized_Date__c, Score__c,
                      Owner.FirstName, Owner.LastName, Owner.Name, Status__c, disregard__c
               FROM Assessment__c
               WHERE Assessment_Type__r.Name='CANS' AND Admission__c=:admissionId Order By CreatedDate DESC
            ];
        }

        public list<Service_Assignment__c>getallSA(ID admissionId) {
        	return [ select service_location__r.alias__c, service_location__r.programid__c from service_assignment__c where admission__c = :admissionId ];

        }
        public IgnoreSharing(){

        }
    }

    //Sravan:---- Start ----------- EIFB-12 -------------------------------------------------------------->
    public set<string> subjectLines = new set<string>{
    	'Open CPA (Client Prior Authorization) in eXPRS','Perform Plan Activities',
    	'Perform LOC Activities','Identify Medicaid Type','Enter PBS Data in iServe','Send Welcome Letter','File Referral Documents in Master file',
    	'Identify Personal Agent with PA name'
    };

    public Task dummyTask{get; set;}//dummy task to bind the Assigned to field
    public Task intakeTask {get {
		if (intakeTask == null) {
			intakeTask = new Task();
			intakeTask.Priority = 'Normal';
			intakeTask.OwnerId = UserInfo.getUserId();
			intakeTask.Status = 'Not Started';
			intakeTask.RecordTypeId = intakeRectype;
			intakeTask.WhatID = admission.Id;
    		intakeTask.WhoId = admission.Person_Being_Served__c;
		}
		return intakeTask;
	}
		private set;
    }

    public string editintakeTaskId{get;set;}
    public List<Task> intakeSteps {get; set;}
    public Boolean showIntakeSteps {get; set;}
    
    id intakeRectype = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Intake Steps').getRecordTypeId();
    public void populateIntakeSteps(){
    	this.intakeSteps =  [SELECT Id, Subject, Description, ActivityDate, OwnerId, Owner.Name, Priority, Status,
    				whatId FROM Task WHERE WHATID != null AND WhatID =:admission.Id order by Number__c desc, CreatedDate desc];
    	if(this.intakeSteps.size() == 0){
    		showIntakeSteps = true; //Show if No tasks are available already
    	}else{ //Check if the tasks available are regular tasks or Intake steps based on subject line
    		for(Task t: intakeSteps){
    			if(subjectLines.contains(t.Subject)){
    				showIntakeSteps = false;
    				break;
    			}
    		}
    	}
    	
    }

    public pageReference createIntakeSteps(){
    	if(string.ISBLANK(dummyTask.OwnerId)){
    		dummyTask.OwnerId.addError('Field is required!');
			return null;
    	}
    	List<Task> tempIntakeSteps = new List<Task>();

    	for(string s: subjectLines){ // With latest salesforce release we can now rely on the order of elements in a set
    		Task t = new Task();
    		t.RecordtypeId = intakeRectype; //Assigning intake steps recordtype
    		t.Subject = s;
    		t.OwnerId = dummyTask.OwnerId;
    		t.Priority = 'Normal';
    		t.Status = 'Not Started';
    		t.WhatId  = admission.id;

    		tempIntakeSteps.add(t);
    	}
    	 if(tempIntakeSteps.size() > 0){
    	 	try{
    	 		insert tempIntakeSteps;
    	 		populateIntakeSteps();
    	 		return null;
    	 	}catch (exception e){
    	 		Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    	 		return null;
    	 	}

    	 }
    	return null;
    }

    public void showAddIntakeTask(){
    	this.intakeTask = new Task();
    	this.intakeTask.Priority = 'Normal';
		this.intakeTask.OwnerId = UserInfo.getUserId();
		this.intakeTask.Status = 'Not Started';
		this.intakeTask.RecordTypeId = intakeRectype;
		this.intakeTask.WhatID = admission.Id;
    	this.intakeTask.WhoId = admission.Person_Being_Served__c;
    }

    public void saveIntakeTask(){
    	try{
    		upsert this.intakeTask;
    		populateintakeSteps();
    		showAddIntakeTask();
    	}catch(exception e){
    		Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    	}
    }

    public void closeIntakeTask(){
    	showAddIntakeTask();
    }

    public void showEditIntakeTask(){
    	string taskId = apexpages.currentpage().getparameters().get('editintakeTaskId');
    	this.intakeTask = [SELECT Id, Subject, Description, ActivityDate, OwnerId, Owner.Name, Priority, Status,
    				whatId FROM Task WHERE Id = :taskId];

    }


    //---------------------------End: EIFB-12--------------------------------------------------------------------------



}