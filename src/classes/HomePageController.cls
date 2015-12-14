public with sharing class HomePageController{
	SystemSettings__c OS = SystemSettings__c.getOrgDefaults();

	public final String OperatingGroup = [select operating_group__c from user where id=:UserInfo.getUserId() limit 1].operating_group__c;
	public static Map<String,Schema.SObjectType> gSchema;
	public Map<String,String> sObjNamesMap{get;set;}
	public List<String> objname{get;set;}
	public List<wrapper> AppWrapper = new List<wrapper>();
	public String viewstsk{get;set;}
	public String FrstName{get;set;}
	public String LstName{get;set;}
	public String objectName{get;set;}

	// Used for daily actions
	public string evalType { get; set; }
	public string subCat { get; set; }
	public string cat { get; set; }
	public string evalSecId { get; set; }
	public string evalSecType { get; set; }
	public Id evaluationId { get; set; }

	// List of permission sets that the user is assigned to
	public String permissionSetString { get; set; }

	private static Set<String> sObjNamesSet;
	//declaration of variables

	public List<Task> populateTasks{get;set;}
	public Map<Id, String> taskToNameMap { get; set; }

	public boolean Refresh=false;

	// NEVAL-56
	public String sortColumn { get; set; }
	public String sortOrder { get; set; }

	public String TypObj;

	public String selectedAlias { get; set; }
	public List<SelectOption> programslist { get; set; }
	public transient Service_Assignment__c[] serviceAssignments { get; set; }

	// We use this variable to keep track of which service assignment we want
	// to run an action on
	public Id serviceAssignmentIdForAction { get; set; }

	// Given the id of a service assignment, here's a map of the actions
	// (excluding Create New Shift Doc) for the latest shift doc of that service
	// asignment (providing that the shift doc is active)
	public Map<Id, List<SelectOption>> serviceAssignmentToSelectOptionMap { get; set; }
	// List of repeatable section/subsection/subsubsection for CM Shift Doc && CNA Workbook
	public List<String> cmShiftDocRepeatable;
	public List<String> cnaWorkbookRepeatable;

	// Whether to show people with inactive service assignments
	public Boolean pbsOnlyShowActiveServiceAssignment { get; set; }

	public transient List<HomePageSearchController.SearchResult> searchResultList { get; set; }
	public Id searchResultPBS { get; set; }
	public Id highlightedServiceAssignmentId { get; set; }

	public Boolean canSeeCNAWorkbook { get; set; }
	public Boolean canSeeShiftDoc { get; set; }
	public Boolean canCreateProgressNotes { get; set; }

	// EC-196 - Shift notes
	public Boolean canCreateNote { get; private set; }
	//PBS object
	public Boolean canSeePBS { get; private set; }
    public Boolean canAccessSA { get; private set; }
	public Map<Id, Evaluation__c> shiftDocMap { get; set; }
	public Map<Id, Evaluation__c> cnaWorkbookMap { get; set; }
	public Map<Id, Boolean> hasShiftDocMap { get; set; }
	public Map<Id, Boolean> hasCnaWorkbookMap { get; set; }


	// IADAY-10 - support creation of Time Log entry from home page
	public String responseType { get; set; }
	public Boolean hasError { get; set; }
	public Evaluation_Response__c currResponse { get; set; }

	//Incidents
	//public List<Incident__c> myIncidents {get; set;}
	//public string selectedIncident {get; set;}
	public boolean canCreateIncidents {get; set;}
	public string userChosenIncident {get; set;}
	public string SAfirstName {get; set;}
	public string SAlastName {get; set;}
	public List<Service_Assignment__c> ServAssigns {get; private set;}

	public Map<Id, Boolean> saactionMap {get;set;}
    public Map<Id, Id> saActiveactionMap {get;set;}

    public boolean isIARole { get; set; }
    public boolean isCAFSS{get; set;}
    public string businessUnit {get; set;}
    public boolean cancreateCANS{ get; set;}
    public boolean rwLevel1{ get; set;}
    public boolean rwLevel3{ get; set;}

    //key-Admission : Value-Open CANS Assessment Id
    public Map<Id, Assessment__c> admissionCANSMap {get; set;}
    public Map<Id, Boolean> hasadmissionCANSMap {get;set;}

    //Active Final Risk/ISSA
    public Map<Id, Assessment__c> admissionActFinMap {get; set;}
    public Map<Id, Boolean> hasadmissionActFinMap {get;set;}
    public Map<Id, Assessment__c> admissionActFinISSAMap {get; set;}
    public Map<Id, Boolean> hasadmissionActFinISSAMap {get;set;}
    Set<String> dupeCheck = new Set<String>();

	//Constructor
	public HomePageController(){

        //PRI-327, for CAFSS
        list<Tmn_User__c> tmnUser = [SELECT Id,operating_group__c,Business_Unit__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1]; //Using list to prevent system.query exception
        this.isCAFSS = false;
        if(tmnUser.size() > 0){
            this.businessUnit =  tmnUser[0].Business_Unit__c;
            this.isCAFSS = (tmnUser[0].Business_Unit__c != null && tmnUser[0].Business_Unit__c.startsWith('BU 008')) ? true : false;
        }
		//PBS object
		Schema.DescribeSObjectResult oSchema = Account.sObjectType.getDescribe();
		canSeePBS = oSchema.isAccessible();

		//Service Assignment
		Schema.DescribeSObjectResult oSchema1 = Service_Assignment__c.sObjectType.getDescribe();
		canAccessSA = oSchema1.isAccessible();


		pbsOnlyShowActiveServiceAssignment = true;
		searchResultList = new List<HomePageSearchController.SearchResult>();
		programsList = new list<SelectOption>();
		serviceAssignmentToSelectOptionMap = new Map<Id, List<SelectOption>>();
		List<AggregateResult> slPrgms = [
			SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
			  FROM service_assignment__c
			GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c,
			         service_location__r.programid__c
			HAVING COUNT(service_location__r.id) > 0
			ORDER BY service_location__r.programid__c, service_location__r.program__c
		];
		Set<String> allAliasSet = new Set<String>();
		for (AggregateResult slPrgm : slPrgms) {
			String alias = (String) slPrgm.get('alias');
			if (!allAliasSet.contains(alias)) {
				programslist.add(new SelectOption(alias, alias + '-' + parseProgram(String.valueOf(slPrgm.get('prgm')))));
			}
			allAliasSet.add(alias);
		}
		Cookie initialAliasCookie = ApexPages.currentPage().getCookies().get('homePageInitialAlias-' + UserInfo.getUserId());
		if (initialAliasCookie == null) {
			if (programsList.size() > 0) {
				selectedAlias = programslist[0].getValue();
			}
		} else {
			String tmpId = initialAliasCookie.getValue();
			if (tmpId != null && tmpId != '' && allAliasSet.contains(tmpId)) {
				selectedAlias = tmpId;  // Because you can't assign null to an ID variable
			} else if (programsList.size() > 0) {
				selectedAlias = programslist[0].getValue();
			}
		}
		// get list of repeatables
		List<AggregateResult> evalRepeats = [
			SELECT category__c, sub_category__c, sub_sub_category__c,
			       eval_type__r.name type
			  FROM eval__c
			 WHERE (eval_type__r.name = 'Head To Toe'
			    OR eval_type__r.name = 'CNA Workbook')
			   AND eval_type__r.Category__c = 'Care Meridian'
			   AND eval__c.field_name__c = 'isRepeatable'
			   AND eval__c.visible__c = false
			GROUP BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c,
			         category__c, sub_category__c, sub_sub_category__c,
			         eval_type__r.name
			ORDER BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c
		];
		cmShiftDocRepeatable = new List<String>();
		cnaWorkbookRepeatable = new List<String>();
		for (AggregateResult ag : evalRepeats){
			if (ag.get('type') == 'Head To Toe') {
				cmShiftDocRepeatable.add((string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c')));
			} else {
				cnaWorkbookRepeatable.add((string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c')));
			}
		}

		PermissionSetAssignment[] assignments = [
			SELECT Id, PermissionSet.Label
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId()
		];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Label);
		}
		permissionSetString = String.join(new List<String>(permissionSets), '~');
		if (permissionSets.contains('iServe - Tier I') || permissionSets.contains('iServe - Tier II') || permissionSets.contains('iServe - Tier III')) {
			canSeeCNAWorkbook = true;
		} else {
			canSeeCNAWorkbook = false;
		}
		if (permissionSets.contains('iServe - Tier II') || permissionSets.contains('iServe - Tier III')) {
			canSeeShiftDoc = true;
		} else {
			canSeeShiftDoc = false;
		}
		if (permissionSets.contains('ESD - Assessments Only')){
			cancreateCANS = true;
		} else {
			cancreateCANS = false;
		}
		if (permissionSets.contains('ESD - Notes - RW - Level 1')){
			rwLevel1 = true;
		} else {
			rwLevel1 = false;
		}
		if (permissionSets.contains('ESD - Notes - RW - Level 3')){
			rwLevel3 = true;
		} else {
			rwLevel3 = false;
		}

		Map<id,UserRole> rolemap =new Map<id,UserRole>([SELECT DeveloperName,Id FROM UserRole]);
        if((rolemap.get(UserInfo.getUserRoleId()).DeveloperName=='AZ_Phoenix_Clinical_Users'||rolemap.get(UserInfo.getUserRoleId()).DeveloperName=='AZ_Phoenix')&& OperatingGroup == 'Redwood' && os.AZ_OPT_Enabler__c==true){
          canCreateProgressNotes = true;
          canSeeShiftDoc = false;
          canSeeCNAWorkbook = false;
        }
        else
          canCreateProgressNotes =false;

        if (rolemap.get(UserInfo.getUserRoleID()).DeveloperName == 'IA')
        	isIARole = true;
        else
        	isIARole = false;


		oSchema = Progress_Note__c.sObjectType.getDescribe();
		canCreateNote = oSchema.isCreateable();

		Schema.DescribeSObjectResult sc = Incident__c.sObjectType.getDescribe();
		canCreateIncidents = sc.isCreateable();

		ServAssigns = new list<Service_Assignment__c>();
		updateProgramSelection();
		checkTmnUserRecord();
		mineTasks();
		//displayIncidents();
	}

	private String parseProgram(String program) {
		// EC-184
		String[] parts = program.split('-', -1);
		if (parts.size() == 5) {
			// It should always get here as program strings follow Mentor CBF,
			// but if it doesn't we should be careful and just return the string.
			parts.remove(2);
		}
		return String.join(parts, '-');
	}

	public void updateProgramSelection() {
		String query = '' +
			'SELECT Id,Name, Person_Being_Served__r.Id, Person_Being_Served__r.Name, ' +
			'       Admission__r.Id, Admission__r.State__c, ' +
			'       (SELECT Id, status__C FROM Action_Plans__r where status__c = \'Active Final\') , ' +
			'       (SELECT Id, Name, Status__c, RecordType.Name, OwnerId FROM Evaluations__r WHERE RecordType.Name = \'CMShiftAssessment\' OR RecordType.Name = \'CNA Workbook\' ORDER BY CreatedDate DESC) ' +
			'FROM Service_Assignment__c ' +
			'WHERE Service_Location__r.Alias__c = :selectedAlias ' +
			(pbsOnlyShowActiveServiceAssignment ? 'AND Status__c=\'Active\' ': '') +
			'ORDER BY Person_Being_Served__r.Name';
		serviceAssignments = Database.query(query);
		Map<Id, Id> evaluationToServiceAssignmentMap = new Map<Id, Id>();
		shiftDocMap = new Map<Id, Evaluation__c>();
		cnaWorkbookMap = new Map<Id, Evaluation__c>();
		hasShiftDocMap = new Map<Id, Boolean>();
		hasCnaWorkbookMap = new Map<Id, Boolean>();
        saactionMap = new Map<Id, Boolean>();
        saActiveactionMap = new Map<Id,Id>();
        set<id> admissions = new set<id>();
        admissionCANSMap = new Map<id, assessment__C>();
        hasadmissionCANSMap = new Map<Id, Boolean>();
        admissionActFinMap = new Map<id, assessment__C>();
        admissionActFinISSAMap = new Map<id, assessment__C>();
        hasadmissionActFinMap = new Map<Id, Boolean>();
        hasadmissionActFinISSAMap = new Map<Id, Boolean>();
        for (Service_Assignment__c serviceAssignment: serviceAssignments) {
            saactionMap.put(serviceAssignment.id,false);
            saActiveactionMap.put(serviceAssignment.id,serviceAssignment.id);
            admissions.add(serviceAssignment.Admission__r.Id);
            hasadmissionCANSMap.put(serviceAssignment.Admission__r.Id, false);
            hasadmissionActFinMap.put(serviceAssignment.Admission__r.Id, false);
            hasadmissionActFinISSAMap.put(serviceAssignment.Admission__r.Id, false);
            for(Action_Plan__c ap:serviceAssignment.Action_Plans__r){
                if(ap.Status__c == 'Active Final'){
                    saactionMap.put(serviceAssignment.id,True);
                    saActiveactionMap.put(serviceAssignment.id,ap.Id);
                }
            }

        }

        for(Assessment__c asmt: [SELECT Id, Name,status__c, Admission__c FROM Assessment__c WHERE Assessment_type__c = :getCANsID() AND Admission__c IN:admissions ORDER BY CreatedDate,Admission__c ASC]){
            if(asmt.Status__c == 'Open'){
                hasadmissionCANSMap.put(asmt.Admission__c, true);
                admissionCANSMap.put(asmt.Admission__c, asmt);
            }
        }
        for(Assessment__c asmt: [SELECT Id, Name,status__c, Admission__c FROM Assessment__c WHERE Admission__c IN:admissions Or (Admission__c IN:admissions And Name like 'ISSA') ORDER BY CreatedDate,Admission__c ASC]){
            if(asmt.Status__c == 'Active Final' && !asmt.name.contains('ISS')){
                hasadmissionActFinMap.put(asmt.Admission__c, true);
                admissionActFinMap.put(asmt.Admission__c, asmt);
            }
            if(asmt.Status__c == 'Active Final' && asmt.name.contains('ISSA')){
                hasadmissionActFinISSAMap.put(asmt.Admission__c, true);
                admissionActFinISSAMap.put(asmt.Admission__c, asmt);
            }
        }

		for (Service_Assignment__c serviceAssignment: serviceAssignments) {
			// Get the latest shift doc/CNA Workbook
			shiftDocMap.put(serviceAssignment.Id, null);
			cnaWorkbookMap.put(serviceAssignment.Id, null);
			hasShiftDocMap.put(serviceAssignment.Id, false);
			hasCnaWorkbookMap.put(serviceAssignment.Id, false);
			for (Evaluation__c eval: serviceAssignment.Evaluations__r) {
				if (shiftDocMap.get(serviceAssignment.Id) == null && eval.RecordType.Name == 'CMShiftAssessment' && eval.Status__c == 'Draft') {
					shiftDocMap.put(serviceAssignment.Id, eval);
					evaluationToServiceAssignmentMap.put(eval.Id, serviceAssignment.Id);
					hasShiftDocMap.put(serviceAssignment.Id, true);
				}
				if (cnaWorkbookMap.get(serviceAssignment.Id) == null && eval.RecordType.Name == 'CNA Workbook' && eval.Status__c == 'Draft') {
					cnaWorkbookMap.put(serviceAssignment.Id, eval);
					evaluationToServiceAssignmentMap.put(eval.Id, serviceAssignment.Id);
					hasCnaWorkbookMap.put(serviceAssignment.Id, true);
				}
			}

			SelectOption[] optionList = new SelectOption[]{};
			optionList.add(new SelectOption('', '-------Select------'));
			//adding a wrapping clause here PRI-237, this may be requested for removal
			//if(operatingGroup.StartsWith( 'Care') ){
			if (canSeeShiftDoc) {
				optionList.add(new SelectOption('createShiftDoc', 'Create New Shift Doc'));
				if (hasShiftDocMap.get(serviceAssignment.Id) && shiftDocMap.get(serviceAssignment.Id).OwnerId != UserInfo.getUserId()) {
					for (String compositeKey: cmShiftDocRepeatable) {
						String readableCompositeKey = compositeKey.replace('~', '/');
						if (readableCompositeKey.endsWith('/')) {  // if a category has no sub sub category
							readableCompositeKey = readableCompositeKey.substringBeforeLast('/');
						}
						optionList.add(new SelectOption(
							'shiftDocAction-' + compositeKey,
							'Add Activity Log Entry for ' + readableCompositeKey
						));
					}
				}
				optionList.add(new SelectOption('', '-------------'));
			}
			if (canCreateProgressNotes) {
                optionList.add(new SelectOption('ViewSANoteLog', 'View SA Note Log'));
            }
			if (canSeeCNAWorkbook) {
				optionList.add(new SelectOption('createCNAWorkbook', 'Create New CNA Workbook'));
				if (hasCNAWorkbookMap.get(serviceAssignment.Id) && cnaWorkbookMap.get(serviceAssignment.Id).OwnerId == UserInfo.getUserId()) {
					for (String compositeKey: cnaWorkbookRepeatable) {
						String readableCompositeKey = compositeKey.replace('~', '/');
						if (readableCompositeKey.endsWith('/')) {  // if a category has no sub sub category
							readableCompositeKey = readableCompositeKey.substringBeforeLast('/');
						}
						optionList.add(new SelectOption(
							'cnaWorkbookAction-' + compositeKey,
							'Add Activity Log Entry for ' + readableCompositeKey
						));
					}
				}
			}
			//}
			// For incident Creation - Add Security if condition later since We don't have requirements now - Sravan 07/21/2015
			//removing this option for the moment 10/21/2015 pperisic
			if(canCreateIncidents){
				//optionList.add(new selectOption('createPBSIncident', 'Create Incident'));
			}
            //PRI-327 Hastings and CAFSS homepage dialy actions, Confirmed with kristen and deleted from dialy actions column.
            /*if (isCAFSS || operatingGroup == 'Cambridge') {
                optionList.add( new SelectOption('createNewCansAssesment', 'Create new CANS Assessment'));
                if (  serviceAssignment.Action_Plans__r.size() == 0 ) {
					optionList.add( new SelectOption(serviceAssignment.Id, 'Create New Action Plan'));
				}
                if (  serviceAssignment.Action_Plans__r.size() > 0 ) {
                    optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id, 'Acknowledge Action Plan'));
                }

            } */


			// Redwood HomePage Daily Actions
			if ( operatingGroup == 'Redwood' && !isCAFSS){

				if(rwLevel3){
					if(serviceAssignment.Admission__r.State__c=='MN' || isIARole){
						optionList.add( new SelectOption('/' + serviceAssignment.Id + '#Seizure_Tracking', 'Record Seizure'));
						dupeCheck.add('Record Seizure');
					}
					if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA'|| isIArole)){
						optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Behavior Data'));
						dupeCheck.add('View Behavior Data');
					}
					if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA'|| isIArole)){
						optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Skill Data'));
						dupeCheck.add('View Skill Data');
					}
					if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA'|| isIArole)){
						optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id, 'Acknowledge Action Plan'));
						dupeCheck.add('Acknowledge Action Plan');
					}
					if(serviceAssignment.Admission__r.State__c=='MN'){
						if ( hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c) == True) {
				    		if(hasadmissionActFinISSAMap != Null && hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id != Null ){
                        		optionList.add( new SelectOption('/' + admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge ISSA Assessment'));
                        		dupeCheck.add('Acknowledge ISSA Assessment');
				    		}
						}
					}
					if(serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA'|| isIArole){
						if ( hasadmissionActFinMap != Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c)!= Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c) == True) {
				    		if(admissionActFinMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinMap.get(serviceAssignment.Admission__c).Id != Null ){
					    		optionList.add( new SelectOption('/' + admissionActFinMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge Risk Assessment'));
					    		dupeCheck.add('Acknowledge Risk Assessment');
				    		}
						}
					}
					if(isIARole){
						optionList.add( new SelectOption('createTimeLog', 'Create Time Log Entry'));
						dupeCheck.add('Create Time Log Entry');
						optionList.add( new SelectOption('IowaDailyDataSummary', 'Create Daily Data Summary'));
						dupeCheck.add('Create Daily Data Summary');

					}
				}

				if(rwLevel1){

						if(isIARole){
							if(!dupeCheck.Contains('Record Seizure')){
							optionList.add( new SelectOption('/' + serviceAssignment.Id + '#Seizure_Tracking', 'Record Seizure'));
							}
						}
						if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA' || isIARole)){
							if(!dupeCheck.Contains('View Behavior Data')){
								optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Behavior Data'));

							}
						}
						if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA' || isIARole)){
							if(!dupeCheck.Contains('View Skill Data')){
								optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Skill Data'));

							}
						}
						if((serviceAssignment.Action_Plans__r.size() > 0) && (serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA' || isIARole)){
							if(!dupeCheck.Contains('Acknowledge Action Plan')){
								optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id, 'Acknowledge Action Plan'));

							}
						}
						if(serviceAssignment.Admission__r.State__c=='MN'){
							if(!dupeCheck.Contains('Acknowledge ISSA Assessment')){
								if ( hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c) == True) {
				    				if(hasadmissionActFinISSAMap != Null && hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id != Null ){
                        				optionList.add( new SelectOption('/' + admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge ISSA Assessment'));
				    				}
								}
							}
						}
						if(serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA'|| isIArole){
							if(!dupeCheck.Contains('Acknowledge ISSA Assessment')){
								if ( hasadmissionActFinMap != Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c)!= Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c) == True) {
				    				if(admissionActFinMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinMap.get(serviceAssignment.Admission__c).Id != Null ){
					    				optionList.add( new SelectOption('/' + admissionActFinMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge Risk Assessment'));
				    				}
								}
							}
						}
						if(isIARole){
							if(!dupeCheck.Contains('Acknowledge ISSA Assessment')){
								optionList.add( new SelectOption('createTimeLog', 'Create Time Log Entry'));
							}
						}

				}
				if(cancreateCANS && serviceAssignment.Admission__r.State__c=='WI'){
					optionList.add( new SelectOption('createNewCansAssesment', 'Create new CANS Assessment'));
				}

			}

			/* // IADAY-9 - add capability for Redwood users in IA to add plan-related data
			if ( operatingGroup == 'Redwood' && isIARole && !isCAFSS) {

					optionList.add( new SelectOption('/' + serviceAssignment.Id + '#Seizure_Tracking', 'Record Seizure'));
					dupeCheck.add('Record Seizure');
				if (  serviceAssignment.Action_Plans__r.size() > 0 ) {
					optionList.add(new SelectOption(
										Page.Notes_ProgressNote_Create.getUrl() +
										'?service_assignment=' + serviceAssignment.ID +
										'&plan=' + serviceAssignment.Action_Plans__r[0].Id +
										'&admission=' + serviceAssignment.Admission__r.Id +
										'&person=' + serviceAssignment.Person_Being_Served__r.Id +
										'&state=' + serviceAssignment.Admission__r.State__c +
										'&retURL=' + Apexpages.CurrentPage().getURL(), 'Create Shift Note'));
					if(!dupeCheck.Contains('View Behavior Date')){

					}
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Behavior Data'));
					dupeCheck.add('View Behavior Data');
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Skill Data'));
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id, 'Acknowledge Action Plan'));

				}
				if ( hasadmissionActFinMap != Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c)!= Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c) == True) {
				    if(admissionActFinMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinMap.get(serviceAssignment.Admission__c).Id != Null )
					optionList.add( new SelectOption('/' + admissionActFinMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge Risk Assessment'));
				}
				if ( hasadmissionActFinISSAMap != Null && hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c) == True) {
				    if(admissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id != Null )
					optionList.add( new SelectOption('/' + admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge ISSA Assessment'));
				}
				if (  serviceAssignment.Action_Plans__r.size() == 0 ) {
					optionList.add( new SelectOption(serviceAssignment.Id, 'Create New Action Plan'));
				}
				optionList.add( new SelectOption('createTimeLog', 'Create Time Log Entry'));
                optionList.add( new SelectOption('IowaDailyDataSummary', 'Create Daily Data Summary'));

			}
			//PRI-326 Redwood MN, IN, CA homepage values.
			if ( operatingGroup == 'Redwood' && (serviceAssignment.Admission__r.State__c=='MN' || serviceAssignment.Admission__r.State__c=='IN' || serviceAssignment.Admission__r.State__c== 'CA') && !isCAFSS && !isIARole) {
				if (serviceAssignment.Admission__r.State__c=='MN') {
					optionList.add( new SelectOption('/' + serviceAssignment.Id + '#Seizure_Tracking', 'Record Seizure'));
				}
				if (  serviceAssignment.Action_Plans__r.size() > 0 ) {
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Behavior Data'));
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id + '#worksheets', 'View Skill Data'));
					optionList.add( new SelectOption('/' + serviceAssignment.Action_Plans__r[0].Id, 'Acknowledge Action Plan'));
				}
				if (  serviceAssignment.Action_Plans__r.size() == 0 ) {
					optionList.add( new SelectOption(serviceAssignment.Id, 'Create New Action Plan'));
				}
				if ( hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c) == True) {
				    if(hasadmissionActFinISSAMap != Null && hasadmissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id != Null )
                        optionList.add( new SelectOption('/' + admissionActFinISSAMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge ISSA Assessment'));
				}
				if ( hasadmissionActFinMap != Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c)!= Null && hasadmissionActFinMap.get(serviceAssignment.Admission__c) == True) {
				    if(admissionActFinMap.get(serviceAssignment.Admission__c)!= Null && admissionActFinMap.get(serviceAssignment.Admission__c).Id != Null )
					    optionList.add( new SelectOption('/' + admissionActFinMap.get(serviceAssignment.Admission__c).Id, 'Acknowledge Risk Assessment'));
				}

			}*/
			serviceAssignmentToSelectOptionMap.put(serviceAssignment.Id, optionList);
		}
		List<AggregateResult> responses = [
			SELECT What_Id__c, Eval__r.Category__c cat, Eval__r.Sub_Category__c subCat,
			       Eval__r.Sub_Sub_Category__c subSubCat, Eval__r.Eval_Type__r.Name type
			  FROM Eval_Value__c
			 WHERE What_Id__c IN :evaluationToServiceAssignmentMap.keySet()
			   AND Eval_Section_Type__c != 'Activity Log'
			GROUP BY Eval__r.cat_seq_text__c, Eval__r.subcat_seq_text__c,
			         Eval__r.subsubcat_seq_text__c, Eval__r.category__c,
			         Eval__r.sub_category__c, Eval__r.Sub_Sub_Category__c,
			         What_Id__c, Eval__r.Eval_Type__r.Name
			ORDER BY Eval__r.Eval_Type__r.Name DESC, Eval__r.cat_seq_text__c,
			         Eval__r.subcat_seq_text__c, Eval__r.subsubcat_seq_text__c
		];
		Boolean shiftDocHeaderAdded = false;
		Map<Id, Integer> indexMap = new Map<Id, Integer>();
		for (AggregateResult response: responses) {
			String compositeKey = response.get('cat') + '~' + response.get('subCat') + '~' + (String.isBlank((string) response.get('subSubCat')) ? '' : (string) response.get('subSubCat'));
			if (response.get('type') == 'Head To Toe' && !new Set<String>(cmShiftDocRepeatable).contains(compositeKey)) {  // Only add Activity Log Entry for repeatable sections/subsections/subsubsections
				continue;
			}
			Id serviceAssignmentId = evaluationToServiceAssignmentMap.get((Id) response.get('What_Id__c'));
			Boolean isShiftDocOwner = hasShiftDocMap.get(serviceAssignmentId) && shiftDocMap.get(serviceAssignmentId).OwnerId == UserInfo.getUserId();
			SelectOption[] optionList = serviceAssignmentToSelectOptionMap.get(serviceAssignmentId);
			if (!indexMap.containsKey(serviceAssignmentId)) {
				indexMap.put(serviceAssignmentId, 1);
			}
			if (response.get('type') == 'Head To Toe' && canSeeShiftDoc && isShiftDocOwner) {
				optionList.add(indexMap.get(serviceAssignmentId),  // Add before the cna workbook stuff
					new SelectOption('shiftDocAction-' + compositeKey,
						'Add Activity Log Entry for ' + response.get('cat') + '/' + response.get('subCat') + (String.isBlank((string) response.get('subSubCat')) ? '' : '/ ' + (string) response.get('subSubCat'))
					)
				);
				indexMap.put(serviceAssignmentId, indexMap.get(serviceAssignmentId) + 1);
			}
		}
		highlightedServiceAssignmentId = null;
		ApexPages.currentPage().setCookies(
			new Cookie[]{
				new Cookie(
					'homePageInitialAlias-' + UserInfo.getUserId(),
					selectedAlias, null, 30*24*60*60, false
				)
			}
		); //  set the cookie max age to a month
	}

	public String getOperatingGroup() {
		return operatingGroup;
	}


	//Wrapper class for Approvals
	public List<wrapper> getListApprovals(){
		if(Refresh==false){
			gSchema = Schema.getGlobalDescribe();
			sObjNamesMap = new Map<String,String>{};
			sObjNamesSet = gSchema.keyset();
			for(String sobj:sObjNamesSet){
				Schema.DescribeSObjectResult oSchema = gSchema.get(sobj).getDescribe();
				String tempName = oSchema.getLabel();
				String tempPrefix = oSchema.getKeyPrefix();
				sObjNamesMap.put(tempPrefix, tempName);
			}

			for(ProcessInstanceWorkitem app:[select Id,ProcessInstanceId,CreatedDate,ActorId,CreatedById,CreatedBy.Name,ProcessInstance.LastModifiedBy.Name,ProcessInstance.TargetObject.Name,ProcessInstance.LastModifiedById,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() order by CreatedDate desc limit 1000]){
				String sub = app.ProcessInstance.TargetObjectId;
				String IdType = sub.substring(0,3);
				String Type = sObjNamesMap.get(IdType);

				AppWrapper.add(new wrapper(app.Id,app.ProcessInstance.TargetObjectId,app.ProcessInstance.LastModifiedById,app.ProcessInstance.LastModifiedBy.Name,app.CreatedDate,app.ProcessInstance.TargetObject.Name,Type));
			}
			Refresh = true;
		}
		return AppWrapper;
	}

	//Wrapper class
	public class wrapper{
		public Id TAction{get;set;}
		public Id TRelated{get;set;}
		public String TobjName{get;set;}
		public String TType{get;set;}
		public Id MostRecent{get;set;}
		public String LMName{get;set;}
		public Datetime cDate{get;set;}

		public wrapper(Id Id,Id TId,Id LId,String LName,Datetime cdate,String TName,String Type){
			this.Taction = Id;
			this.TRelated = TId;
			this.TobjName = TName;
			this.MostRecent = LId;
			this.LMName = LName;
			this.cDate = cdate;
			this.TType = Type;
		}
	}

/*	public List<selectOption> getIncidentTypes() {
		List<SelectOption> Options = new List<SelectOption>();
		Options.add(new SelectOption('All Incidents','All Incidents'));
		Options.add(new SelectOption('PBS','PBS'));
		Options.add(new SelectOption('Employee','Employee'));
		Options.add(new SelectOption('Location','Location'));
		Options.add(new SelectOption('Mentor','Mentor'));

		return options;
	}

	public void displayIncidents() {
		Id userId = UserInfo.getUserId();
		string SOQL = 'SELECT Id, NAME, Status__c, Recordtype.Name FROM Incident__c WHERE OwnerId=: userId';
		if(selectedIncident != null && selectedIncident != 'All Incidents'){
			//rectype = Utility.getIncidentRecordType(selectedIncident);
			SOQL = SOQL + ' AND Recordtype.Name= :selectedIncident';


		}
		//String orderStatement = '';
		myIncidents = Database.query(SOQL);
	}*/

	public pageReference createIncident(){
		PageReference pr = new pagereference('/apex/Incident_Form_CreateEdit');
		pr.getParameters().put('RecordTypeId', Utility.getIncidentRecordType(userChosenIncident));
		return pr;

	}

	public pageReference createPBStypeIncident(){
		PageReference pr = new pagereference('/apex/Incident_Form_CreateEdit');
		pr.getParameters().put('RecordTypeId', Utility.getIncidentRecordType('PBS'));
		pr.getParameters().put('SAid', serviceAssignmentIdForAction);
		return pr;
	}

	public pageReference cancelIncident(){
		PageReference pg = page.Home;
		pg.SetRedirect(true);
		return pg;

	}

	public string getpbsincidentRecType(){
		return  Utility.getIncidentRecordType('PBS');
	}

	public pagereference servAssigns(){
		ServAssigns = new List<Service_Assignment__c>();
		string criteria = HomePageSearchController.buildCriteria(SAlastName, SAfirstName, 'lastname', 'firstname');
		String conQuery = 'select Id from Contact where ';
		conQuery = conQuery+criteria;
		system.debug('Query+++++++++++++'+conQuery);
		List<Contact> pbsList = Database.Query(conQuery);
		if(pbsList.size() > 0){
			ServAssigns =  [SELECT Id, Name, Person_being_served__r.Name,Person_being_served__r.Age_year__c, Person_being_served__r.Age_month__c, Person_being_served__r.Age_days__c, Program_Detail__c FROM Service_Assignment__c WHERE Person_being_Served__c IN: pbslist AND Status__c = 'Active'];
		}

		return null;
	}

	public void singleInsert() {
		evalSecId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
	}

	public List<SelectOption> getviewvalues() {
		List<SelectOption> Options = new List<SelectOption>();
		Options.add(new SelectOption('All Open','All Open'));
		Options.add(new SelectOption('Overdue','Overdue'));
		Options.add(new SelectOption('Today','Today'));
		Options.add(new SelectOption('Today+Overdue','Today+Overdue'));
		Options.add(new SelectOption('Tomorrow','Tomorrow'));
		Options.add(new SelectOption('Next 7 Days','Next 7 Days'));
		Options.add(new SelectOption('Next 7 Days+Overdue','Next 7 Days+Overdue'));
		Options.add(new SelectOption('This Month','This Month'));

		return Options;
	}
	public void mineTasks(){
		Id userId = UserInfo.getUserId();
		String query ='select id, subject,WhatId,What.Name,WhoId,Who.Name,status,RecordTypeId, ActivityDate, Priority, CreatedDate from Task where OwnerId=:userId and status!=\'Completed\'';
		String orderStatement = '';
		// NEVAL-56
		Map<String, String> colNumToFieldMap = new Map<String, String>{
			'0' => '',
			'1' => 'CreatedDate',
			'2' => 'Subject',
			'3' => 'Priority',
			'4' => 'Status',
			'5' => 'ActivityDate',
			'6' => 'Id',
			'7' => 'What.Name'
		};
		if (sortColumn != '' && sortColumn != null && sortOrder != '' && sortOrder != null) {
			orderStatement = ' order by ' + colNumToFieldMap.get(sortColumn) + ' ' + sortOrder;
			if (sortOrder.toLowerCase() == 'asc') {  // Make sure null values are sorted differently for different sort order (by default, it's nulls first)
				orderStatement += ' nulls last';
			}
		} else {
			orderStatement = ' order by ActivityDate desc, Priority';
		}
		if(viewstsk==null || viewstsk=='All Open'){
			query+= orderStatement + ' limit 25';
		}
		else if (viewstsk=='Overdue'){
			query+='and ActivityDate<TODAY' + orderStatement + ' limit 25';
		}else if (viewstsk=='Today'){
			query+='and ActivityDate=TODAY' + orderStatement + ' limit 25';
		}else if (viewstsk=='Today+Overdue'){
			query+='and ActivityDate<=TODAY' + orderStatement + ' limit 25';
		}else if (viewstsk=='Tomorrow'){
			query+='and ActivityDate=TOMORROW' + orderStatement + ' limit 25';
		}else if (viewstsk=='Next 7 Days'){
			query+='and ActivityDate=NEXT_WEEK' + orderStatement + ' limit 25';
		}else if (viewstsk=='Next 7 Days+Overdue'){
			query+='and ActivityDate<=NEXT_WEEK' + orderStatement + ' limit 25';
		}else if (viewstsk=='This Month'){
			query+='and ActivityDate=THIS_MONTH' + orderStatement + ' limit 25';
		}else {
			query+= orderStatement + ' limit 25';
		}

		populateTasks = database.query(query);

		// We use the following map to display the name of tasks, because tasks
		// associated with Referrals cannot have their WhoId set to the Person
		// Being Referred record, so we need to construct the names manually
		// here
		taskToNameMap = new Map<Id, String>();
		Set<Id> whatIdSet = new Set<Id>();
		for (Task task: populateTasks) {
			if (task.WhoId != null) {
				taskToNameMap.put(task.Id, '<a href="/' + task.WhoId + '">' + task.Who.Name + '</a>');
			} else {
				whatIdSet.add(task.WhatId);
			}
		}
		Map<Id, Referral__c> referrals = new Map<Id, Referral__c>([
			SELECT Id, Person_Being_Referred__r.Full_Name__c
			FROM Referral__c
			WHERE Id IN :whatIdSet
		]);
		Set<Id> referralIdSet = referrals.keySet();
		for (Task task: populateTasks) {
			if (referralIdSet.contains(task.WhatId)) {
				taskToNameMap.put(task.Id, '<a href="/' + task.WhatId + '">' + referrals.get(task.WhatId).Person_Being_Referred__r.Full_Name__c + '</a>');
			} else if (task.WhoId == null) {  // Do not override the entry from above if WhoId != null
				taskToNameMap.put(task.Id, '');
			}
		}
	}

	public PageReference getsearchNames() {
		try {
			if ((FrstName!=null && FrstName!='') || (LstName!=null && LstName!='')){
				PageReference newocp= new PageReference('/apex/HomePage_Search?FirstNM='+FrstName+'&&LastNM='+LstName);
				newocp.setRedirect(true);
				return newocp;
			}
			return null;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
				'Error opening the Search Results.')
			);
			return null;
		}
		return null;
	}

	public void getSearchResults() {
		if ((FrstName == null || FrstName == '') && (LstName ==null || LstName == '')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
				'You have to specify either a First Name or Last Name')
			);
			return;
		}
		HomePageSearchController searchController = new HomePageSearchController();
		searchController.firstName = FrstName;
		searchController.lastName = LstName;
		searchResultList = searchController.getSearchResults(true, true, false);
	}

	public void highlightSearchResultPBS() {
		Service_Assignment__c[] serviceAssignments = [
			SELECT Id, Person_Being_Served__r.Id, Service_Location__r.Id, Status__c,
			       Service_Location__r.Alias__c
			  FROM Service_Assignment__c
			 WHERE Person_Being_Served__c = :searchResultPBS
			ORDER BY Person_Being_Served__r.Name
		];
		// We can only choose one row to highlight, so let's focus on ones with
		// active service assignment (if none exists then we'll highlight the
		// inactive ones)
		Service_Assignment__c highlightedSA;
		for (Service_Assignment__c serviceAssignment: serviceAssignments) {
			if (serviceAssignment.Status__c == 'Active') {
				highlightedSA = serviceAssignment;
			}
			if (highlightedSA == null && serviceAssignment.Status__c != 'Active') {
				highlightedSA = serviceAssignment;
			}
		}
		if (highlightedSA != null) {
			selectedAlias = highlightedSA.Service_Location__r.Alias__c;
			if (pbsOnlyShowActiveServiceAssignment && highlightedSA.Status__c != 'Active') {
				pbsOnlyShowActiveServiceAssignment = false;
			}
			updateProgramSelection();
			highlightedServiceAssignmentId = highlightedSA.Id;
		} else {
			highlightedServiceAssignmentId = null;
		}
	}


	// START: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.
	public class TMN_User_Exception extends Exception {}

	public void checkTmnUserRecord() {
		String usersId = UserInfo.getUserId();
		List<TMN_User__c> tmnUserRecords = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :usersId LIMIT 1 ];

		Integer countTmnUserRecords = 0;
		for(TMN_User__c tmnu : tmnUserRecords) {
			countTmnUserRecords++;
		}

		if(countTmnUserRecords==0) {
			throw new TMN_User_Exception('ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.');
		}
	}
	// END: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.

	// IADAY-9 - to support creation of new plan from home page
	public String currsaID { get; set; }
	public pagereference NewPlan( ){

		// we only come into this function if there is no active final plan
		// find out if there's an inactive draft we can view
		List<Action_Plan__c> aplist = [ select id, status__c from Action_Plan__c where status__c = 'Inactive Draft' and service_assignment__c = :currsaID order by status__c, lastmodifieddate desc  LIMIT 1];


		Action_plan__c AP;

		// if an inactive plan exists, take them to that page to view
		if ( aplist.size() == 1 ) {
			AP = aplist[0];
		} else {

			AP = new Action_plan__c();
			AP.Service_Assignment__c = currsaID;
			insert AP;
		}

		PageReference ref =  new ApexPages.StandardController(AP).view() ;
		ref.getparameters().put('retURL', Apexpages.CurrentPage().getURL());
		return ref;

	}

	public void newResponse() {
		responseType = 'Time Log';
		currResponse = new Evaluation_Response__c( recordtypeID = Utility.getEvaluationResponseRecordType(responseType), service_assignment__c = serviceAssignmentIDforAction);
	}

	public pageReference saveResponse() {


		hasError = false;

		// check for required fields
		Map<string, string> columnsToHeadersMap = new Map<String, String>();
		columnsToHeadersMap.put('start_date_time__c','Start Date/Time');
		columnsToHeadersMap.put('end_date_time__c','End Date/Time');
		columnsToHeadersMap.put('tmn_user__c','Accompanied By');
		columnsToHeadersMap.put('location__c','Location');
		columnsToHeadersMap.put('service_type__c','Service Type');

		for(string rCol : new List<String>{'start_date_time__c', 'tmn_user__c', 'location__c', 'service_type__c'}){
			if(currResponse.get(rCol) == null){
				currResponse.addError( columnsToHeadersMap.get(rcol) + ' is required' );
				hasError = true;
			}
		}


		//system.debug('CURR:' + currResponse);


		// IADAY-10 - date rules
		if ( responseType == 'Time Log') {
			// compare start and end dates
			if ( currResponse.End_Date_Time__c != null ) {
				// end date after start
				if((currResponse.Start_Date_Time__c > currResponse.End_Date_Time__c) ){
					currResponse.addError( 'End date must be after the start date.' );
					hasError = true;
				}
				// must be same day
				if (currResponse.Start_date_Time__c.Date() != currResponse.End_Date_Time__c.Date()) {
					currResponse.addError('Start and End times must occur on the same day.');
					hasError = true;
				}
				// must be different
				if (currResponse.Start_Date_Time__c == currResponse.End_Date_Time__c ) {
					currResponse.addError('Start and End times must be different.');
					hasError = true;
				}
			}
			// can't be in the future
			if(currResponse.Start_Date_Time__c > DateTime.now() || currResponse.End_Date_Time__c > DateTime.now()  ){
					currResponse.addError( 'Date and time cannot be in future.' );
					hasError = true;
			}

			if (! hasError ) {
				// check for date overlap with another event
				List<Evaluation_Response__c> otherTimeLogs = [ select id, start_date_time__c, end_date_time__c from evaluation_response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType(responseType) and id != :currResponse.Id and service_assignment__c = :currResponse.service_assignment__c and disregard__c = false];
				for ( Evaluation_Response__c tl : otherTimeLogs ) {
					if ( checkOverlap( tl.start_date_time__c, tl.end_date_time__c, currResponse.start_date_time__c, currResponse.end_date_time__c) ) {
						currResponse.addError('A time log entry already exists for that time.  Please correct your entry.');
						hasError = true;
						break;
					}
				}
			}

		} // end IADAY-10
		try {
			if(!hasError){
				//system.debug('CURR:' + currResponse);
				upsert currResponse;
				newResponse();
			}
		} catch (DMLException ex) {
		 	hasError = true;
			system.debug(ex);
			// SF will automatically create a PageMessage Error here, so we don't
			// have to do anything
		}
		return null;
	}

    public id getCANsID(){
       Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'CANS' limit 1];
       return type.id;

    }

	@TestVisible private boolean checkOverlap ( DateTime s1, DateTime e1, DateTime s2, DateTime e2) {

		Boolean overlaps = false;
		system.debug( 'Times:' + s1 + e1 + s2 + e2);
		if ( e1 == null ) // first set is not a range - can't compare
			return overlaps;

		if ( s2 >= s1 && s2 <= e1 ) // starts within first timeframe
			overlaps = true;
		else {
			if ( e2 != null ) {
				if ( e2 > s1 && e2 < e1 ) // ends within first timeframe
					overlaps = true;
				else if ( s2 < s1 && e2 > e1) // covers first time span
					overlaps = true;
			}
		}

		return overlaps;
	}
}