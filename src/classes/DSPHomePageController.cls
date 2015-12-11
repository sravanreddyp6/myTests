// RPII-5 and RPII-6 - home page for OneApp users
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
    public Map<Id, String[]> taskToNameMap { get; set; }
    
    private Set<PBSWrapper> peopleToServe { get; set; } // list of PBS on this page (includes favorites and single-transaction PBS)
    private Set<ID> admissions = new Set<ID>(); // list of admissions in focus
    private Set<ID> setAcks = new Set<ID>();    // list of things this user has acknowledged for the focus admissions
    private Set<ID> plans = new Set<ID>();      // list of plans in focus
    private Map<String, ID> admAssess = new Map<String, ID>();  // map of admissionid+assessmenttype to assessment id
    private Map<String, ID> apWksht = new Map<String, ID>();    // map of planid+worksheettype to worksheet id
    
    public List<PBSWrapper> mypbsList { get { return new List<PBSWrapper>(peopleToServe);} set; }   // because VF won't iterate over set of custom class

    public string requestType { get; set; }
    public string inputArgs { get; set; }

    // NEVAL-56
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }
    
    public class PBSWrapper {
        public ID pbsID { get; set; }   
        public ID saID { get; set; }
        public ID admID { get; set; }
        public ID apID { get; set; }    // plan
        public string pbsname { get; set; }
        public string program { get; set; }
        public string alias { get; set; }
        public date apEffDate { get; set; } // plan eff date
        public boolean isFavorite { get; set; } 
        public boolean hasRisk { get; set; }
        public boolean hasISSA { get; set; }
        public Date APTargetDate { get; set; }
        public boolean hasActionPlan { get; set; }
        public boolean needsAPAck { get; set; }
        public boolean needsRiskAck { get; set; }
        public boolean needsISSAAck { get; set; }
        public ID bwID { get; set; }    // current behavior worksheet id 
        public ID swID { get; set; }    // current skills worksheet id
        public boolean hasBW { get; set; }  // if behavior worksheet is applicable (plan end date after today)
        public boolean hasSW { get; set; }  // if skills worksheet is applicable (plan end date after today)
        
        public List<SelectOption> actionList { get; set; }
        public List<SelectOption> navList { get; set; }
        
            
        // wrap the details for the PBS table listing
        public PBSWrapper ( ID pID, ID adID, ID sID, ID aID, string n, string p, string al, date ed, boolean f, boolean r, boolean i, boolean h, date apd) {
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
            apTargetDate = apd;
            needsAPAck = false;
            needsRiskAck = false;
            needsISSAAck = false;
            bwID = null;
            swID = null;
            hasBW = false;
            hasSW = false;
            
            actionList = new List<SelectOption>();
            navList = new List<SelectOption>();
        }
        
        public void buildSelectLists() {
        	
        	// actionList will be grouped by like features, navlist will be alphabetical
        	actionList = new List<SelectOption> { new SelectOption('','--- Select ---')};
            navList = new List<SelectOption> { new SelectOption('','--- Select ---')};
        	if ( hasActionPlan ) {
        		if ( needsAPAck)
        			actionList.add( new SelectOption('submitTxnRequest(\'Action Plan\',\'' + apID + '\');', 'Acknowledge Action Plan'));
        		
        		navList.add( new SelectOption('submitTxnRequest(\'Action Plan\',\'' + apID + '\');', 'Action Plan'));
	            navList.add( new SelectOption('dspShiftNoteSummary(\'' + pbsID + '\');', 'Shift Note Summary'));		
				actionList.add( new SelectOption('submitTxnRequest(\'BehaviorList\',\'' + apID + '\');', 'View Behavior Data'));        			
				actionList.add( new SelectOption('submitTxnRequest(\'SkillList\',\'' + apID + '\');', 'View Skill Data'));
            	actionList.add( new SelectOption('submitTxnRequest(\'Shift Note List\',\'' + pbsID + '\');', 'View Shift Notes'));			
        	}
        	
        	if ( hasISSA ) {
        		if ( needsISSAAck)
        			actionList.add( new SelectOption('submitTxnRequest(\'ISSA\',\'' + admID + '\');', 'Acknowledge ISSA Assessment'));
        		
        		navList.add( new SelectOption('submitTxnRequest(\'ISSA\',\'' + admID + '\');', 'ISSA Assessment'));
        	}

        	if ( hasRisk ) {
        		if ( needsRiskAck)
        			actionList.add( new SelectOption('submitTxnRequest(\'Risk\',\'' + admID + '\');', 'Acknowledge Risk Assessment'));
        		
        		navList.add( new SelectOption('submitTxnRequest(\'Risk\',\'' + admID + '\');', 'Risk Assessment'));
        	}
        		
			actionList.add( new SelectOption('submitTxnRequest(\'Seizures\',\'' + pbsID + '\');', 'Record Seizure'));        			
			//navList.add( new SelectOption('submitTxnRequest(\'Seizures\',\'' + pbsID + '\');', 'Seizures')); // not for MN - they can get list from action menu
			navList = SortOptionList(navList, true);
        	system.debug( this);
        	
        }
        
        // for equality checking within a set
        public Boolean equals(Object obj) {
            if (obj instanceof PBSWrapper) {
              //  system.debug('inside equals');
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

        // PBS object
        Schema.DescribeSObjectResult oSchema = Account.sObjectType.getDescribe();
        canSeePBS = oSchema.isAccessible();

        peopletoServe = new Set<PBSWrapper>();
        
        //retrieve list of PBS given favorites string from browser cookie
        Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + UserInfo.getUserId());
        //system.debug( favoritePBSList);
        
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
        
        // retrieve list of user's tasks
        mineTasks();
        
        // renew the favorite PBS list cookie
        updatePBSListCookie('', true);
        
        system.debug( myPBSList);
    }

    // exclude currently displayed PBSs and SAs from search
    private void buildSearchExclusionList( List<String> sa, List<String> pbs) {
        currentSAList = new List<String>( sa );
        currentPBSList = new List<String>( pbs );
    }
    
    
    // update/renew the list of favorites   
    private void updatePBSListCookie( string newval, boolean resetexp ) {
        // update the cookie
        Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + UserInfo.getUserId());
        if ( favoritePBSlist != null ) {
            
            if ( resetexp)  // just updating expiration date
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

        // get people with active SA only since all actions require an active SA
        Service_Assignment__c[] listPBSbySA = [
            SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
                    admission__c, Service_Location__r.location_nickname__c, 
                   Service_Location__r.Alias__c, admission__r.state__c, 
                   (select id, effective_date__c, Status__c, target_date__c from action_plans__r where status__c = 'Active Final' order by finalized_date__c LIMIT 1)
             FROM Service_Assignment__c
             WHERE Person_Being_Served__c in :pIDs
             and id in :saIDs
             AND    status__c = 'Active'];
        
        for ( Service_Assignment__c focusPBS : listPBSbySA  ) {
            
            boolean hasAP = ( focusPBS.action_plans__r.size() > 0);
            
            //ID pID, ID sID, ID aID, string n, string p, string al, date ed    
            PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c,
                                             focusPBS.admission__c,  
                                             focusPBS.id,
                                             hasAP ? focusPBS.action_plans__r[0].id : null, 
                                             focusPBS.person_being_served__r.name, 
                                             focusPBS.service_location__r.alias__c + + (( focusPBS.service_location__r.location_nickname__c != null ) ? ' - ' + focusPBS.service_location__r.location_nickname__c : ''),
                                             focusPBS.service_location__r.alias__c,
                                             hasAP ? focusPBS.action_plans__r[0].effective_date__c : null,
                                             true,  // is favorite
                                             false, //has risk
                                             false, // has issa
                                             hasAP, // has action
                                             hasAP ? focusPBS.action_plans__r[0].target_date__c : null // ap end date
                                             );  
            peopletoServe.add( thisPBS );
            admissions.add( focusPBS.admission__c);
            if ( hasAP )
                plans.add( thisPBS.apID);
            
        }
        
        // get the list of assessments for these people's admissions and acknowledgments
        setAdmissionAssessments();
        
        // get list of current worksheets for these people's plans
        setPlanWorksheets();
        
    }
    

    // sets lists of assessments and acknowledgments based on admissions in scope on the page   
    private void setAdmissionAssessments() {
        
        // get the list of assessments (Risk, ISSA) for the admissions
        Assessment__c[] assmts = [select id, type__c, assessment_type__r.name, admission__c from assessment__c where admission__c in :admissions
        and ( type__c = 'ISSA' or assessment_type__r.name = 'Risk') and status__c = 'Active Final'];
    
        // put into map - key is admission + assessment type
        for ( assessment__c a : assmts ) {
            string typestr = (String.isBlank(a.type__c) ? a.assessment_type__r.name  : a.type__c );
            String idtype = a.admission__c + typestr; 
            admAssess.put ( idtype, a.id );
        }   
        system.debug('ASSESSMENTS:' + admAssess);

        // get list of any acknowledgments by this user on things on this admission
        // action plans are on SA level, and assessments are on the admission level
        Acknowledgment__c[] acks = [ select id, action_plan__c, assessment__c from acknowledgment__c 
                                    where (action_plan__r.service_assignment__r.admission__c in :admissions or assessment__r.admission__c in :admissions)    
                                    and user__c = :userInfo.getUserId()];
                                    
        // acknowledgment has either the action plan or assessment field filled in - check based on the type                            
        for ( Acknowledgment__c a : acks ) {
            if ( a.action_plan__c != null )
                setAcks.add( a.action_plan__c );
            else if ( a.assessment__c != null)
                setAcks.add( a.assessment__c );
                
        }
        
        // go through the PBS List to update the settings for Risk and ISSA existence and need to acknowledge
        for ( PBSWrapper p : peopletoServe ) {
            
            if ( p.hasActionPlan )
            	p.needsAPAck = !setAcks.contains( p.APId );
            	
            if ( admAssess.keyset().contains( p.admID + 'Risk')) { 
                p.hasRisk = true;
                p.needsRiskAck = !setAcks.contains( admAssess.get(p.admID + 'Risk'));
            }

            
            if ( admAssess.keyset().contains( p.admID + 'ISSA')) {
                p.hasISSA = true;
                p.needsISSAAck = !setAcks.contains( admAssess.get(p.admID + 'ISSA'));
            }

           
        }
        
    }
    
    // sets lists of skills and behavior worksheets based on plans in scope on the page 
    private void setPlanWorksheets() {
        
        // get the list of worksheets behavior/skills for this calendar month and year if behavior
        Map<ID, Action_Plan_Worksheet__c> wmap = new Map<ID, Action_Plan_Worksheet__c>([select id, recordtype.developername, start_date__c, action_plan__c from action_plan_worksheet__c 
                                                where action_plan__c in :plans 
                                                and (( start_date__c = THIS_MONTH and recordtype.developername = 'Monthly_Behavior_Result')
                                                or ( start_date__c = THIS_WEEK and recordtype.developername = 'Weekly_Skill_Result' ))]);
                                                
        // put into map - key is actionplanid + worksheet type
        String wtype = '';
        for ( Action_Plan_Worksheet__c w : wmap.values() ) {
            if ( w.recordtype.developername.contains('Skill') )
                wtype = 'Skill';
            else if ( w.recordtype.developername.contains('Behavior'))
                wtype = 'Behavior';         
            
            String idtype = w.action_plan__c + wtype; 
            apWksht.put ( idtype, w.id );
        }   
        system.debug('worksheets' + apWksht);
        // go through the PBS List to update the settings for Risk and ISSA existence and need to acknowledge
        Date wksheetEnd;
        Action_Plan_Worksheet__c aw; 
        ID wID;
        for ( PBSWrapper p : peopletoServe ) {
            
            // only if current action plan on this PBS row
            if ( p.hasActionPlan) { 
                
                
	            // BEHAVIOR - monthly           
	            // if there is a behavior worksheet for the current month, grab ID 
	            if ( apWksht.keyset().contains( p.apId + 'Behavior')) {
	                wID = apWksht.get( p.apID + 'Behavior'); 
	                aw = wmap.get( wID);
	                p.hasBW = true;
	                p.bwID = aw.Id;
	            }
	
	            // SKILLS - weekly
	            // if there is a skills worksheet for this play, check what week            
	            if ( apWksht.keyset().contains( p.apID + 'Skill')) {
	                wID = apWksht.get(p.apId + 'Skill');
	                aw = wmap.get( wID );
	                p.hasSW = true;
	                p.swID = aw.Id;
	                
	            } 
	
	            // allow creation of worksheets if there is not one and today is before the Action Plan target date
	            if ( Date.today() <= p.apTargetDate ) {  
	                if ( !p.hasSW ) p.hasSW = true;
	                if ( !p.hasBW ) p.hasBW = true;
	                
	            }
            }            
            // last thing to do = build the list of daily actions and navigation for each PBS
            p.buildSelectLists();           
        }
        
    }
    
    
    // task list views
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
    
    
    // get list of tasks for this user
    public void mineTasks(){
        Id userId = UserInfo.getUserId();
        String query ='select id, subject,Description,WhatId,What.Name,WhoId,Who.Name,status,RecordTypeId, ActivityDate, Priority, CreatedDate from Task where OwnerId=:userId and status!=\'Completed\'';
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
        taskToNameMap = new Map<Id, String[]>();
        Set<Id> whatIdSet = new Set<Id>();
        for (Task task: populateTasks) {
            system.debug( 'WHO: ' + task.whoid + ', WHAT: ' + task.whatid );
            if (task.WhoId != null) {
                taskToNameMap.put(task.Id, new list<String>{'<a href="#" onclick="submitTxnRequest(\'Person Being Served\',\'' + task.WhoId + '\');">' + task.Who.Name + '</a>'});
                if ( task.whatID != null) {
                    if (task.WhatId.getSObjectType().getDescribe().getName() == 'Action_Plan__c')
                        taskToNameMap.get(task.Id).add('<a href="#" onclick="submitTxnRequest(\'Action Plan\',\'' + task.WhatId + '\'); return false;">' + task.What.Name + '</a>');
                    else if (task.WhatId.getSObjectType().getDescribe().getName() == 'Assessment__c') 
                           taskToNameMap.get(task.Id).add('<a href="#" onclick="submitTxnRequest(\'' + (task.What.Name.containsIgnoreCase('ISSA') ? 'ISSA': 'Risk') + '\',\'' + task.WhatId + '\');">' + task.What.Name + '</a>');
                } else {
                    taskToNameMap.get(task.Id).add( '');
                }
            } else {
            taskToNameMap.put(task.Id, new list<String>{'',''});
          //      whatIdSet.add(task.WhatId);
            }

        }

    }
            
    
    
    
    // search results for PBS lookup
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

    // this sets the list of favorites on the home page
    public void setfocusPBS() {
        
        // pbsid, pbsname, said, apid, progstring, alias, plan eff, pln status
        Service_Assignment__c focusPBS = [
            SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
                    admission__c, Service_Location__r.location_nickname__c, 
                   Service_Location__r.Alias__c, admission__r.state__c, 
                   (select id, effective_date__c, target_date__c, Status__c from action_plans__r where status__c = 'Active Final' order by finalized_date__c LIMIT 1)
             FROM Service_Assignment__c
             WHERE Person_Being_Served__c = :searchResultPBS
             AND ID = :searchResultSA
             AND    status__c = 'Active'
             LIMIT 1];
                
        string newcookie = '';
        
        // make sure the PBS/SA still is active 
        if ( focusPBS != null ) {
            Boolean hasAP = ( focusPBS.Action_Plans__r.size() > 0 );
            //ID pID, ID sID, ID aID, string n, string p, string al, date ed    
            PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c, 
                                             focusPBS.admission__c,
                                             focusPBS.id,
                                             hasAP ? focusPBS.Action_Plans__r[0].id : null, 
                                             focusPBS.person_being_served__r.name, 
                                             focusPBS.service_location__r.alias__c + (( focusPBS.service_location__r.location_nickname__c != null ) ? ' - ' + focusPBS.service_location__r.location_nickname__c : ''),
                                             focusPBS.service_location__r.alias__c,
                                             hasAP? focusPBS.Action_Plans__r[0].effective_date__c : null,
                                             searchResultIsFav, // is fav
                                             false, // has risk
                                             false, // has ISSA
                                             hasAP,
                                             hasAP ? focusPBS.Action_Plans__r[0].target_date__c : null
                                             );

            // if already there, remove it to make sure the favorite setting is correct
            // while looping, construct the cookie string of favorites and search exclusions
            List<String> excludeSA = new List<String>();
            List<String> excludePBS = new List<String>();
            for ( PBSWrapper p : peopleToServe ) {
                if ( p.Equals( thisPBS ) ) {
                    peopleToServe.Remove(p);
                    
                    // remove from list of admissions too
                    admissions.remove(p.admId);
                    
                } else {
                    if ( p.isFavorite )  
                        newcookie += p.pbsID + '-' + p.saID + ';';
                        
                    excludeSA.add( p.saID);
                    excludePBS.add( p.pbsID);
                }
            }
            
            // add the PBS to the list
            peopletoServe.add( thisPBS );
            admissions.add( thisPBS.admId);
            
            // get the list of assessments for these people's admissions and acknowledgments
            setAdmissionAssessments();
            
            // get worksheets
            setPlanWorksheets();
            
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
    
    // turns favorite status on/off for selected row
    public void toggleFavorite ( ) {
        
        boolean newFavVal = searchResultIsFav;
        ID saToToggle = searchResultPBS;
        ID pbsToToggle = searchResultSA;
        
        
        system.debug('FAV: ' + newFavVal + 'SA:' + satotoggle + ', PBS:' + pbsToToggle);
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
    
    
    
    public pageReference dspShiftNoteSummary() {
        PageReference pageRef = new PageReference('/apex/DSP_shiftnote_summary_rpt');
        String selectedPBS =  this.pbsID == null || this.pbsID == '' ?  String.join(this.currentPBSList, ',') : this.pbsID;
        pageRef.getParameters().put('selectedPBS', selectedPBS );
        pageRef.getParameters().put('currentPBSList', json.serialize(this.currentPBSList));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //  This is a simple quicksort algorithm to sort a SelectOption list (dropdown) 
    // by label alphabetically.
    private static List<SelectOption> SortOptionList(List<SelectOption> ListToSort, Boolean selectatTop)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
        {
        	if ( selectatTop && (x.getLabel() == '--- Select ---') )
        		continue; // skip it
        		
            if(x.getLabel() <= pivotValue.getLabel() )
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        if ( selectatTop)
        	returnList.add( new SelectOption('','--- Select ---'));

        returnList.addAll(SortOptionList(Less, false));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater, false));
        	
        return returnList; 
    }     
}