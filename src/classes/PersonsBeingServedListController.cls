public with sharing class PersonsBeingServedListController {
    private final String PBS_REC_TYPE_ID = [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
    private final String ASSESSMENT_ONLY_REC_TYPE_ID = [select Id from RecordType where (DeveloperName='Assessment_Only') and (SobjectType='Service_Assignment__c') Limit 1].Id;

	private ID argID;
	public boolean defaultToActive { get; set; }
	private List<Account> accountlist = new List<Account>();
	
    public String letterToStart { get; set; }
    public Admission__c[] admissions { get; set; }
    // A list of contact IDs that are available in this View.
    transient public List<String> contactIds;
    transient public List<String> accountIds { get; set; }
    transient public Map<String, Account> accountIdMap { get; set; }
    transient public Map<String, List<Action_Plan__c>> accountIdToJO { get; set; }
    // Because VF doesn't allow us to check the size of a list in a map
    transient public Map<String, Integer> accountIdToJOSize { get; set; }
    transient public Map<String, List<Admission__c>> accountIdToAdmission { get; set; }
    // The following three only contain admissions without plans
    transient public Map<String, Integer> accountIdToAdmissionSize { get; set; }
    transient public Map<String, List<Service_Assignment__c>> admissionIdToServiceAssignment { get; set; }
    transient public Map<String, Integer> admissionIdToServiceAssignmentSize { get; set; }
    private string pfilterID;
    public boolean canCreateNew { get; set; }
    public boolean seeWorksheets { get {
        boolean isRedwood = false;
        
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
            if (TU.Operating_Group__c == 'Redwood'){isRedwood = true;} 
        }
        return isRedwood;
    } set; }

    private void getcanCreateNew() {
        
        Schema.DescribeSObjectResult acctSchema = Account.sObjectType.getDescribe();
        canCreateNew = acctSchema.IsCreateable();
        
    }
    public String filterId {
        get {
        	system.debug('GETTING - FILTER ID IS: ' + pFilterId);
            //return con.getFilterId();
            return pfilterID;
        }
        set {
        	system.debug('SETTING - FILTER ID IS: ' + value );
        	con.setFilterId(value);
        	pfilterID = value;
            this.updateCon();
        }
    }
    public List<System.SelectOption> listviewoptions {
        get {
            return con.getListViewOptions();
        }
    }
    Map<ID, String> filtermap = new map<ID, String>();
    
    public ApexPages.StandardSetController con { get; set; }
    public PersonsBeingServedListController() {
    	
        //System.debug('Inside constructor');
        
        // if an account ID is passed in on the url, change the basic query
        argID = ApexPages.CurrentPage().getParameters().get('id');
        if ( argID != null) {
        	// get just this 1 account 
        	accountlist= [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and ID=:argID];	
			System.Debug( 'Incoming account id: ' + argID );
			defaultToActive  = false;
        	
    	} else {
    		// get the default view - recently viewed
    		accountlist = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and lastvieweddate != null order by lastvieweddate desc LIMIT 200];
    		defaultToActive  = true;
        }
		
        // We call this here simply to get the filterId of the View
        this.con = new ApexPages.StandardSetController( accountlist );
        
        String inputFilterId = ApexPages.CurrentPage().getParameters().get('filterId');
        List<Account> filteredList;
        for ( selectoption so : listviewoptions ) {
        	filtermap.put( so.getValue(), so.getLabel());
        }
        
        
        // Kick off updateCon here
        String recentlyViewedId = '';
        
        // Set the default View
        for (SelectOption so: listviewoptions) {
            if (so.getLabel().indexOf('Recently Viewed')!=-1) {
                recentlyViewedId = so.getValue();
            }
        }
        
        if (inputFilterId != '' && inputFilterId != null) {
            System.debug('Setting filterId to inputFilterId ' + inputFilterId);
            this.con.setFilterId( inputFilterId );
            pfilterID = inputFilterId;
            filteredList = getListFromFilter( this.filterId);
        } else if (recentlyViewedId != '') {
            System.debug('Setting filterId to recently viewed');
            this.con.setfilterId (recentlyViewedId);
            pfilterID = recentlyViewedId;
            filteredList = getListFromFilter ( this.filterId);
        } else {  // theoretically this should not happen
            System.debug('Setting filterId to controller\'s default');
            // leave the query at all
            filteredList = this.con.getRecords();
        }
        
        system.debug( 'filtered size: ' + filteredList.size());
        this.con = new ApexPages.StandardSetController( filteredList );
        updateCon();
        getcanCreateNew();
    }


	List<Account> getListFromFilter(ID fID) {
		
		string filterlabel = '';
		List<Account> filteredAcct = new List<Account>();
		
		filterlabel = filterMap.get(fID);
		system.debug('asking for: ' + filterlabel);
		if ( filterlabel.indexOf('Recently Viewed') == 0)
			filteredAcct = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and lastvieweddate != null order by lastvieweddate desc LIMIT 200];
		else if ( filterlabel.indexOf( 'My') == 0 ) 
			filteredAcct = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and ( createdbyid = :UserInfo.getUserId() or ownerid = :UserInfo.getUserId()) ];
		else if ( filterlabel.indexOf('All') == 0 ) 
			filteredAcct = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID];
		else if ( filterlabel.indexOf('New This Week') == 0) 
			filteredAcct = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and createddate = THIS_WEEK];
		
		return filteredAcct;
		
	}
    public String getPBSRecTypeId() {
        return PBS_REC_TYPE_ID;
    }
    
    public String getAssessmentOnlyRecTypeId() {
        return ASSESSMENT_ONLY_REC_TYPE_ID;
    }

    public void updateCon() {
        // This method is so bloated because SF doesn't allow nested SOQL queries
        // for more than 1 level, so we have to do that stuff manually
        System.debug('Inside updateCon');
        String oldFilterId = null;
        contactIds = new List<String>();
        accountIds = new List<String>();
        accountIdMap = new Map<String, Account>();
        accountIdToJO = new Map<String, List<Action_Plan__c>>();
        accountIdToJOSize = new Map<String, Integer>();
        // Because we need to display Admission/Service Assignment without any
        // associated plan as well.
        accountIdToAdmission = new Map<String, List<Admission__c>>();
        accountIdToAdmissionSize = new Map<String, Integer>();
        admissionIdToServiceAssignment = new Map<String, List<Service_Assignment__c>>();
        admissionIdToServiceAssignmentSize = new Map<String, Integer>();


		List<Account> filteredList;
		
		if ( argID != null) {
        	// get just this 1 account 
        	filteredList = [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID and ID=:argID];	
			System.Debug( 'Incoming account id: ' + argID );
        	
    	} else {
	        system.debug('current filter is:' +  pFilterId );
    	    if (this.con!=null) {
            	//oldFilterId = this.con.getFilterId();
            	oldFilterId = pfilterID;
	        }
    		filteredList = getListFromFilter( oldfilterId);
    		
    	}


        
    	this.con = new ApexPages.StandardSetController( filteredList );
    	system.debug( 'num accts: ' + filteredList.size());	
    	
        // Make sure setPageSize is called BEFORE setFilterId, otherwise it won't work!
        // 06/19/14 - filter does not affect list of accounts in setcontroller because it was constructed using list, not querylocator
        // however, still need to call setfilterid to store the value of the filter
        if ( argID == null ) {
        
        	this.con.setPageSize(2000);
        	if (filterId!=null) {
	            this.con.setFilterId(oldfilterId);
        	}
        } else {
        	this.con.setPageSize(1);
        	this.con.setFilterId(null);
        	pfilterID= '';
        }
        	
	    // We have to make sure that all the records are fetched, regardless of pagination
        Account[] accts = new Account[] {};
        accts.addAll((Account[]) this.con.getRecords());
        while (this.con.getHasNext()) {
            this.con.next();
            accts.addAll((Account[]) this.con.getRecords());
        }
        System.debug('Total number of records: ' + accts.size());

        for (Account acct: accts) {
            accountIdMap.put(acct.ID, acct);
            accountIds.add(acct.ID);
            if (acct.PersonContactId!=null) {
                contactIds.add(acct.PersonContactId);
            }
        }

        for (String ID: accountIds) {
            accountIdToJO.put(ID, new List<Action_Plan__c>());
            accountIdToJOSize.put(ID, 0);
            accountIdToAdmission.put(ID, new List<Admission__c>());            
            accountIdToAdmissionSize.put(ID, 0);
        }        

        // This is a many-to-many model, so in order to uniquely identify
        // 1 pair of records we'll concatenate their IDs together
        Set<String> distinctPlansAndSAs = new Set<String>();
        // Because we don't want duplicate Service Assignment/Admission
        Set<String> admissionsWithPlans = new Set<String>();
        Set<String> saWithPlans = new Set<String>();
        for (Action_Plan__c jo: [
                SELECT ID, Service_Assignment__r.Person_Being_Served__r.Account.ID,
                    Service_Assignment__r.Person_Being_Served__c,
                    Service_Assignment__r.Person_Being_Served__r.Name,
                    Service_Assignment__r.Admission__c,
                    Service_Assignment__r.Admission__r.Effective_date__c,
                    Service_Assignment__r.Name, Service_Assignment__r.RecordType.ID,
                    Service_Assignment__r.Person_Being_Served__r.Account.Owner.Name,
                    Effective_Date__c, Target_Date__c, Status__c,
                    Service_Assignment__c,
                    Service_Assignment__r.Person_Being_Served__r.Account.OwnerID,
                    Service_Assignment__r.Admission__r.State__c,
                    Service_Assignment__r.Admission__r.Status__c,
                    Service_assignment__r.service_location__r.programid__c
                FROM action_plan__c
                WHERE Service_Assignment__r.Person_Being_Served__r.ID in :contactIds
                and     status__c = 'Active Final'
            ]
        ) {
            if (!distinctPlansAndSAs.contains(String.valueOf(jo.ID) + String.valueOf(jo.Service_Assignment__r.ID))) {
                accountIdToJO.get(jo.Service_Assignment__r.Person_Being_Served__r.Account.ID).add(jo);
                accountIdToJOSize.put(jo.Service_Assignment__r.Person_Being_Served__r.Account.ID,
                    accountIdToJOSize.get(jo.Service_Assignment__r.Person_Being_Served__r.Account.ID) + 1);
                distinctPlansAndSAs.add(String.valueOf(jo.ID) + String.valueOf(jo.Service_Assignment__c));
                admissionsWithPlans.add(jo.Service_Assignment__r.Admission__c);
                saWithPlans.add(jo.Service_Assignment__c);
            }
        }
        // EB-116: add status to service assignment subquery for later exclusion 
        for (Admission__c admission : [
                SELECT ID, Effective_Date__c, Person_Being_Served__r.Account.Name,
                       Person_Being_Served__r.Account.ID, State__c, Status__c,
                       Person_Being_Served__r.Account.Owner.ID,
                       Person_Being_Served__r.Account.Owner.Name,
                       (SELECT ID, Name, RecordType.ID, Status__c FROM Service_Agreements__r)
                FROM Admission__c
                WHERE Person_Being_Served__c IN :contactIds
            ]
        ) {        	                 	               	        	     	             	         
            if (!admissionIdToServiceAssignmentSize.containsKey(admission.ID)) {
                admissionIdToServiceAssignmentSize.put(admission.ID, 0);
                admissionIdToServiceAssignment.put(admission.ID, new List<Service_Assignment__c>());
            }            
            
            admissionIdToServiceAssignment.put(admission.ID, new List<Service_Assignment__c>());
            if (admission.Service_Agreements__r.size()==0) {
                accountIdToAdmission.get(admission.Person_Being_Served__r.Account.ID).add(admission);
                accountIdToAdmissionSize.put(admission.Person_Being_Served__r.Account.ID,
                    accountIdToAdmissionSize.get(admission.Person_Being_Served__r.Account.ID) + 1);
            }
            Integer index = 1;
            for (Service_Assignment__c sa: admission.Service_Agreements__r) {
                
                // EB-116: do not show inactive assessment only
                if ( (sa.RecordType.Id == ASSESSMENT_ONLY_REC_TYPE_ID) &&  (sa.Status__c != 'Active') )
                    continue;                   
                
                if (!saWithPlans.contains(sa.ID)) { // don't display duplicated stuff
                    if (index == 1) {
                        accountIdToAdmission.get(admission.Person_Being_Served__r.Account.ID).add(admission);
                        accountIdToAdmissionSize.put(admission.Person_Being_Served__r.Account.ID,
                            accountIdToAdmissionSize.get(admission.Person_Being_Served__r.Account.ID) + 1);
                    }
                    admissionIdToServiceAssignment.get(admission.ID).add(sa);
                    admissionIdToServiceAssignmentSize.put(admission.ID,
                        admissionIdToServiceAssignmentSize.get(admission.ID) + 1);
                    index++;
                }
                 
            }                                                       	
                                                           
        }                
            
    }
    
    @RemoteAction
    public static Contact getPersonBeingServed(String ID) {
        return [
            SELECT Name, Birthdate, Age__c, Ethnicity_Picklist__c, Phone,
                   Guardian1_Name__c, Guardian_Phone_Number__c, Family_Member_Other__c, ID 
            FROM Contact WHERE AccountID=:ID
        ];
    }

    @RemoteAction
    public static Admission__c getAdmission(String ID) {
        return [
            SELECT Name, Effective_Date__c, Network_Offering__c, State__c, Status__c
                   FROM Admission__c WHERE ID=:ID
        ];
    }
    
    @RemoteAction
    public static Service_Assignment__c getServiceAssignment(String ID) {
        return [
            SELECT Name, Admission__r.Name, Start_Date__c, Status__c
                   FROM Service_Assignment__c WHERE ID=:ID
        ];
    }
    
    @RemoteAction
    public static Action_Plan__c getPlan(String ID) {
        return [
            SELECT Name, Service_Assignment__r.Admission__r.Name, Service_Assignment__r.Name, Effective_Date__c,  Target_Date__c, Status__c
                   FROM Action_Plan__c WHERE ID=:ID
        ];
    }
}