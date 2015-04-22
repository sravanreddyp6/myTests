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

	public Id selectedProgram { get; set; }
	public List<SelectOption> programslist { get; set; }
	public Service_Assignment__c[] serviceAssignments { get; set; }

	// We use this variable to keep track of which service assignment we want
	// to run an action on
	public Id serviceAssignmentIdForAction { get; set; }

	// Given the id of a service assignment, here's a map of the actions
	// (excluding Create New Shift Doc) for the latest shift doc of that service
	// asignment (providing that the shift doc is active)
	public Map<Id, List<SelectOption>> serviceAssignmentToSelectOptionMap { get; set; }
	// List of repeatable section/subsection/subsubsection for CM Shift Doc
	public Set<String> cmShiftDocRepeatable;

	// Whether to show people with inactive service assignments
	public Boolean pbsOnlyShowActiveServiceAssignment { get; set; }

	public transient List<HomePageSearchController.SearchResult> searchResultList { get; set; }
	public Id searchResultPBS { get; set; }
	public Id highlightedServiceAssignmentId { get; set; }

	//Constructor
	public HomePageController(){
		pbsOnlyShowActiveServiceAssignment = true;
		searchResultList = new List<HomePageSearchController.SearchResult>();
		programsList = new list<SelectOption>();
		serviceAssignmentToSelectOptionMap = new Map<Id, List<SelectOption>>();
		List<AggregateResult> slPrgms = [
			SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
			  FROM service_assignment__c
			GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c
			HAVING COUNT(service_location__r.id) > 0
			ORDER BY service_location__r.program__c
		];
		for (AggregateResult slPrgm : slPrgms) {
			programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
		}
		Cookie initialProgramCookie = ApexPages.currentPage().getCookies().get('homePageInitialProgram');
		if (initialProgramCookie == null) {
			if (programsList.size() > 0) {
				selectedProgram = programslist[0].getValue();
			}
		} else {
			String tmpId = initialProgramCookie.getValue();
			if (tmpId != null && tmpId != '') {
				selectedProgram = tmpId;  // Because you can't assign null to an ID variable
			}
		}
		// get list of repeatables
		List<AggregateResult> evalRepeats = [
			SELECT category__c, sub_category__c, sub_sub_category__c
			  FROM eval__c
			 WHERE eval_type__r.name = 'Head To Toe'
			   AND eval_type__r.Category__c = 'Care Meridian'
			   AND eval__c.field_name__c = 'isRepeatable'
			   AND eval__c.visible__c = false
			GROUP BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c, category__c, sub_category__c, sub_sub_category__c
			ORDER BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c
		];
		cmShiftDocRepeatable = new set<String>();
		for (AggregateResult ag : evalRepeats){
			cmShiftDocRepeatable.add((string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c')));
		}
		updateProgramSelection();

		PermissionSetAssignment[] assignments = [
			SELECT Id, PermissionSet.Label
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId()
		];
		List<String> permissionSets = new List<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Label);
		}
		permissionSetString = String.join(permissionSets, '~');
		System.debug('permissionSets: ' + permissionSets);
		System.debug('permissionSetString: ' + permissionSetString);

		checkTmnUserRecord();
		mineTasks();
	}

	public void updateProgramSelection() {
		String query = '' +
			'SELECT Id, Person_Being_Served__r.Id, Person_Being_Served__r.Name, ' +
			'       Admission__r.Id, ' +
			'       (SELECT Id FROM Action_Plans__r ORDER BY CreatedDate DESC), ' +
			'       (SELECT Id, Name, Status__c FROM Evaluations__r WHERE RecordType.Name = \'CMShiftAssessment\' ORDER BY CreatedDate DESC LIMIT 1) ' +
			'FROM Service_Assignment__c ' +
			'WHERE Service_Location__c = :selectedProgram ' +
			(pbsOnlyShowActiveServiceAssignment ? 'AND Status__c=\'Active\'': '') +
			'ORDER BY Person_Being_Served__r.Name';
		serviceAssignments = Database.query(query);
		Map<Id, Id> evaluationToServiceAssignmentMap = new Map<Id, Id>();
		for (Service_Assignment__c serviceAssignment: serviceAssignments) {
			if (serviceAssignment.Evaluations__r.size() > 0 && serviceAssignment.Evaluations__r[0].Status__c == 'Draft') {
				evaluationToServiceAssignmentMap.put(serviceAssignment.Evaluations__r[0].Id, serviceAssignment.Id);
			}
			serviceAssignmentToSelectOptionMap.put(serviceAssignment.Id, new List<SelectOption>());
		}
		List<AggregateResult> responses = [
			SELECT What_Id__c, Eval__r.Category__c cat, Eval__r.Sub_Category__c subCat,
			       Eval__r.Sub_Sub_Category__c subSubCat
			  FROM Eval_Value__c
			 WHERE What_Id__c IN :evaluationToServiceAssignmentMap.keySet()
			   AND Eval_Section_Type__c != 'Activity Log'
			GROUP BY Eval__r.cat_seq_text__c, Eval__r.subcat_seq_text__c,
			         Eval__r.subsubcat_seq_text__c, Eval__r.category__c,
			         Eval__r.sub_category__c, Eval__r.Sub_Sub_Category__c,
			         What_Id__c
			ORDER BY Eval__r.cat_seq_text__c, Eval__r.subcat_seq_text__c,
			         Eval__r.subsubcat_seq_text__c
		];
		for (AggregateResult response: responses) {
			String compositeKey = response.get('cat') + '~' + response.get('subCat') + '~' + (String.isBlank((string) response.get('subSubCat')) ? '' : (string) response.get('subSubCat'));
			if (!cmShiftDocRepeatable.contains(compositeKey)) {  // Only add Activity Log Entry for repeatable sections/subsections/subsubsections
				continue;
			}
			serviceAssignmentToSelectOptionMap.get(evaluationToServiceAssignmentMap.get((Id) response.get('What_Id__c'))).add(
				new SelectOption('shiftDocAction-' + compositeKey,
					'Add Activity Log Entry for ' + response.get('cat') + '/' + response.get('subCat') + (String.isBlank((string) response.get('subSubCat')) ? '' : '/ ' + (string) response.get('subSubCat'))
				)
			);
		}
		highlightedServiceAssignmentId = null;
		ApexPages.currentPage().setCookies(new Cookie[]{ new Cookie('homePageInitialProgram', selectedProgram, null, 30*24*60*60, false) }); //  set the cookie max age to a month
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
		system.debug('came here');
		Id userId = UserInfo.getUserId();
		String query ='select id, subject,WhatId,What.Name,WhoId,Who.Name,status,RecordTypeId, ActivityDate, Priority, CreatedDate from Task where OwnerId=:userId and status!=\'Completed\'';
		system.debug('*********viewstsk'+viewstsk);
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
			orderStatement = ' order by ActivityDate desc, Priority, CreatedDate';
		}
		System.debug('Order statement: ' + orderStatement);
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
				system.debug('coming here');
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
			SELECT Id, Person_Being_Served__r.Id, Service_Location__r.Id, Status__c
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
			selectedProgram = highlightedSA.Service_Location__r.Id;
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
}