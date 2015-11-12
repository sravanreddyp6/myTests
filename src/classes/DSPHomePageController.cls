public with sharing class DSPHomePageController {

	Public Transient List<Contact> PBSList {get; private set;}
	Public List<SelectOption> selPBSList { get; private set; }
	public boolean canSeePBS { get; set; }
	public string pbsID { get; set; }
	
	public String FrstName { get; set; }
	public String LstName { get; set; }

	public transient List<OneAppSearchController.SearchResult> searchResultList { get; set; }
	public Id searchResultPBS { get; set; }
	public Id searchResultSA { get; set; }
	public Boolean searchResultIsFav { get; set; }
	private List<String> currentSALIst;
	private List<String> currentPBSList;

	public String viewstsk{get;set;}
	public List<Task> populateTasks{get;set;}
	public Map<Id, String> taskToNameMap { get; set; }
	
	private Set<PBSWrapper> peopleToServe { get; set; }
	public List<PBSWrapper> mypbsList { get { return new List<PBSWrapper>(peopleToServe);} set; }	// because VF won't iterate over set of custom class


	public string requestType { get; set; }
	public string inputArgs { get; set; }

	// NEVAL-56
	public String sortColumn { get; set; }
	public String sortOrder { get; set; }
	
	public class PBSWrapper {
		public ID pbsID { get; set; }
		public ID saID { get; set; }
		public ID admID { get; set; }
		public ID apID { get; set; }
		public string pbsname { get; set; }
		public string program { get; set; }
		public string alias { get; set; }
		public date apEffDate { get; set; }
		public boolean isFavorite { get; set; }
		public boolean hasRisk { get; set; }
		public boolean hasISSA { get; set; }
		public boolean hasActionPlan { get; set; }
		public boolean needsAPAck { get; set; }
		public boolean needsRiskAck { get; set; }
		public boolean needsISSAAck { get; set; }
			
		
		public PBSWrapper ( ID pID, ID adID, ID sID, ID aID, string n, string p, string al, date ed, boolean f, boolean r, boolean i, boolean h) {
			pbsID = pID;
			saID = sID;
			admID = adID;
			apID = aID;
			pbsname = n;
			program = p;
			alias = al;
			apEffDate = ed;
			isFavorite = f;
			hasRisk = r;
			hasISSA = i;
			hasActionPlan = h;
			needsAPAck = false;
			needsRiskAck = false;
			needsISSAAck = false;
			
		}
		
		// for set equality checking
	    public Boolean equals(Object obj) {
        	if (obj instanceof PBSWrapper) {
        		system.debug('inside equals');
            	PBSWrapper p = (PBSWrapper)obj;
            	
            	// note that isfavorite is not included in compare as it is not significant test for equality
            	return ((pbsID == p.pbsID) && 
            			(saID == p.saID) &&
            			(apID == p.apID) &&
            			(pbsname == p.pbsname) &&
            			(alias == p.alias) &&
            			(apEffDate == p.apEffDate ) 
            			);
            		
	        }
    	    return false;
    	}

    	public Integer hashCode() {
        	return pbsname.length();
    	}
    	
	}
	
//Constructor
	public DSPHomePageController(){

		// make sure user is completely configured for system use
		checkTmnUserRecord();

		//PBS object
		Schema.DescribeSObjectResult oSchema = Account.sObjectType.getDescribe();
		canSeePBS = oSchema.isAccessible();

		peopletoServe = new Set<PBSWrapper>();
		
		//retrieve list of PBS given favorites string from front end
		Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + UserInfo.getUserId());
		system.debug( favoritePBSList);
		if (favoritePBSList != null ){
			List<String> favePBS = new List<String>();
			List<String> faveSA = new List<String>();
			
			String pbsJoin = favoritePBSList.getValue();
			if ( pbsJoin != null ) {
				List<String> tmplist = pbsJoin.Split(';');
				
				for (String tmp : tmplist) { 
					// format of cookie string is PBS|SA;PBS|SA;	
					system.debug('cookie string split: ' + tmp);			
					String[] moretmp = tmp.split('-');
					if (moretmp.size() == 2) {
						favePBS.add(moretmp[0]);
						faveSA.add(moretmp[1]);
					}
				}
				system.debug('fAVE PBS:' + favePBS + ', faveSA:' + faveSA);
				getPBSList( favePBS, faveSA); 
			}
			
			
			buildSearchExclusionList( faveSA, favePBS );
		}
		
		
		mineTasks();
		
		updatePBSListCookie('', true);
		
		
	}


	private void buildSearchExclusionList( List<String> sa, List<String> pbs) {
		currentSAList = new List<String>( sa );
		currentPBSList = new List<String>( pbs );
	}
	
		
	private void updatePBSListCookie( string newval, boolean resetexp ) {
		// update the cookie
		Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + UserInfo.getUserId());
		if ( favoritePBSlist != null ) {
			
			if ( resetexp) 	// just updating expiration date
				newval = favoritePBSlist.getValue();
		}
				
		ApexPages.currentPage().setCookies( 
				new Cookie[]{
					new Cookie(
						'favoritePBS-' + UserInfo.getUserId(),
						newval, null, 30*24*60*60, false
					)
				}
			); //  set the cookie max age to a month
	}
	
	
	
	// this is the initial list of "favorite" PBS that user has requested to save in cookie
	public void getPBSList( List<String> PIds, List<String> saIDs) {

		Service_Assignment__c[] listPBSbySA = [
			SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
					admission__c, Service_Location__r.program__c, 
			       Service_Location__r.Alias__c, admission__r.state__c, 
			       (select id, effective_date__c, Status__c from action_plans__r where status__c = 'Active Final')
			 FROM Service_Assignment__c
			 WHERE Person_Being_Served__c in :pIDs
			 AND	status__c = 'Active'
		
										];
			// pbsid, pbsname, said, apid, progstring,
		Action_Plan__c[] listPBS = [
			SELECT Id, service_assignment__r.Person_Being_Served__c, service_assignment__r.person_Being_served__r.name, 
					service_assignment__r.admission__c, service_assignment__c, service_assignment__r.Service_Location__r.program__c, 
			       service_assignment__r.Service_Location__r.Alias__c, service_assignment__r.admission__r.state__c,
			       effective_date__c,
			       Status__c
			  FROM Action_Plan__c
			 WHERE Service_Assignment__r.Person_Being_Served__c in :pIDs
			 and 	service_assignment__c in :saIDs
			 and	service_assignment__r.status__c = 'Active'
			 and	status__c = 'Active Final'
			];
			
		for ( Service_Assignment__c focusPBS : listPBSbySA  ) {
			
			boolean hasAP = ( focusPBS.action_plans__r.size() > 0);
			//ID pID, ID sID, ID aID, string n, string p, string al, date ed	
			PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c,
											 focusPBS.admission__c,  
											 focusPBS.id,
											 hasAP ? focusPBS.action_plans__r[0].id : null, 
											 focusPBS.person_being_served__r.name, 
											 focusPBS.service_location__r.program__c,
											 focusPBS.service_location__r.alias__c,
											 hasAP ? focusPBS.action_plans__r[0].effective_date__c : null,
											 true,
											 true,
											 ( focusPBS.admission__r.state__c == 'MN'),
											 hasAP);
			peopletoServe.add( thisPBS );
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
	
	public void getSearchResults() {
		if ((FrstName == null || FrstName == '') && (LstName ==null || LstName == '')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
				'You have to specify either a First Name or Last Name')
			);
			return;
		}
		OneAppSearchController searchController = new OneAppSearchController();
		searchController.firstName = FrstName + '*';
		searchController.lastName = LstName + '*';
		searchController.excludeSAList = currentSAList;
		searchController.excludePBSList = currentPBSList;
		searchResultList = searchController.getSearchResults(true, false, false, true);
	}

	public void setfocusPBS() {
		
		// pbsid, pbsname, said, apid, progstring, alias, plan eff, pln status
		Service_Assignment__c focusPBS = [
			SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
					admission__c, Service_Location__r.program__c, 
			       Service_Location__r.Alias__c, admission__r.state__c, 
			       (select id, effective_date__c, Status__c from action_plans__r where status__c = 'Active Final')
			 FROM Service_Assignment__c
			 WHERE Person_Being_Served__c = :searchResultPBS
			 AND ID = :searchResultSA
			 AND	status__c = 'Active'
			 LIMIT 1];
			 	
		string newcookie = '';
			
		if ( focusPBS != null ) {
			Boolean hasAP = ( focusPBS.Action_Plans__r.size() > 0 );
			//ID pID, ID sID, ID aID, string n, string p, string al, date ed	
			PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c, 
											 focusPBS.admission__c,
											 focusPBS.id,
											 hasAP ? focusPBS.Action_Plans__r[0].id : null, 
											 focusPBS.person_being_served__r.name, 
											 focusPBS.service_location__r.program__c,
											 focusPBS.service_location__r.alias__c,
											 hasAP? focusPBS.Action_Plans__r[0].effective_date__c : null,
											 searchResultIsFav,
											 true,
											 (focusPBS.admission__r.state__c == 'MN'),
											 hasAP
											 );


			// if already there, remove it to make sure the favorite setting is correct
			// while looping, construct the cookie string of favorites and search exclusions
			List<String> excludeSA = new List<String>();
			List<String> excludePBS = new List<String>();
			for ( PBSWrapper p : peopleToServe ) {
				if ( p.Equals( thisPBS ) ) {
					peopleToServe.Remove(p);
				} else {
					if ( p.isFavorite )  
						newcookie += p.pbsID + '-' + p.saID + ';';
						
					excludeSA.add( p.saID);
					excludePBS.add( p.pbsID);
				}
			}
			peopletoServe.add( thisPBS );
			if ( thisPBS.isfavorite )
				newcookie += thisPBS.pbsID + '-' + thisPBS.saID + ';';
				
			excludeSA.add( thisPBS.saID );
			excludePBS.add( thisPBS.pbsID );	
			
			system.debug( 'MASTER LIST:'  + peopletoServe + ', new cookie: ' + newcookie);
			system.debug( 'Exclude lists:' + excludeSA + ', ' + excludePBS);
			buildSearchExclusionList( excludeSA, excludePBS);
			
			// rebuild cookie - this will handle removal of favorites too
			updatePBSListCookie( newcookie, false );
		
			
		}

	}
	
	public void toggleFavorite ( ) {
		
		boolean newFavVal = searchResultIsFav;
		ID saToToggle = searchResultPBS;
		ID pbsToToggle = searchResultSA;
		
		// for things that aren't current favorite this will work
		setfocusPBS();
		
		
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
	
	
	// Suppport for OneApp - any action off the home page is fulfilled through TransactionQueue table
	// When adding new request, add to the map below, and make sure there is a supporting action in TransactionQueueTriggeredActions.cls
	private Map<String,String> requestToPage = new Map<String, String> { 'Action Plan' => '/apex/DSPActionPlan', 
																		 'Person Being Served' => '/apex/DSPPersonBeingServedView',
                                                                         'Seizures' => '/apex/DSP_PbsSeizureListing',
                                                                         'Risk' => '/apex/DSP_Assessment_RiskForm'
																	};
	public pageReference submitTxnRequest() {
		// submit a transaction queue request 
		// redirect to the correct page with the transaction queue id
		system.debug('inside submitrequest:' + requestType + ', ' + inputArgs);
		
		// get out if the action type is not understood
		if ( !requestToPage.keyset().contains( requestType )) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown action type.'));
			return null;
		}
		Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
		txn.request_type__c = requestType;
		txn.requested_date_time__c = DateTime.Now();
		txn.input_params__c = inputArgs;
		
		try { 
			insert txn;
			PageReference pr =  new PageReference( requestToPage.get( requestType ));
			pr.getParameters().put('txnID', txn.ID);
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		
	}
	
   
}