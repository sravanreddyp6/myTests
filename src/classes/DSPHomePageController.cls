// RPII-5 and RPII-6 - home page for OneApp users
//comment added to create diff by AV
public with sharing class DSPHomePageController {
    
    public boolean canSeePBS { get; set; }
    public string pbsID { get; set; }
    
    public String FrstName { get; set; }
    public String LstName { get; set; }
	public String Prgm { get;set;}
	    
    public transient List<OneAppSearchController.SearchResult> searchResultList { get; set; }
    public String searchResultPBS { get; set; }
    public String searchResultSA { get; set; }
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
    private Map<ID,ID> planISPAttach = new Map<ID, ID>(); 	// OH-11 - map of planid to ISP attachment id
    
    public List<PBSWrapper> mypbsList { get { return new List<PBSWrapper>(peopleToServe);} set; }   // because VF won't iterate over set of custom class
    
    // NEVAL-56
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }
    
    public class PBSWrapper {
        public ID pbsID { get; set; }   
        public ID saID { get; set; }
        public ID admID { get; set; }
        public ID apID { get; set; }    // plan
        public string pbsname { get; set; }
        public string preferredFirstName { get; set; }
        public string preferredLastName { get; set; }
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
        public boolean needsISPAck { get; set; }	// OH-11
        public boolean needsISSAAck { get; set; }
        public ID bwID { get; set; }    // current behavior worksheet id 
        public ID swID { get; set; }    // current skills worksheet id
        public ID srvcwID { get; set; }    // current service worksheet id
        public boolean hasBW { get; set; }  // if behavior worksheet is applicable (plan end date after today)
        public boolean hasSW { get; set; }  // if skills worksheet is applicable (plan end date after today)
        public boolean hasSrvcW { get; set; }  // if service worksheet is applicable (plan end date after today)
        public string admState { get; set; }
        public string servState { get; set; }
        public string networkOffering { get; set; }
        
        public List<SelectOption> actionList { get; set; }
        public List<SelectOption> navList { get; set; }
        
        
        // wrap the details for the PBS table listing
        public PBSWrapper ( ID pID, ID adID, ID sID, ID aID, string n, string pfn, string pln, string p, string al, date ed, boolean f, boolean r, boolean i, boolean h, date apd, string admst, string slst, string netwrkOffr) {
            pbsID = pID;
            saID = sID;
            admID = adID;
            apID = aID;
            pbsname = n;
            preferredFirstName = pfn;
            preferredLastName = pln;
            program = p;
            alias = al;
            apEffDate = ed;
            isFavorite = f;
            hasRisk = r;
            hasISSA = i;
            hasActionPlan = h;
            apTargetDate = apd;
            needsAPAck = false;
            needsISPAck = false;
            needsRiskAck = false;
            needsISSAAck = false;
            bwID = null;
            swID = null;
            srvcwID = null;
            hasBW = false;
            hasSW = false;
            hasSrvcW = false;
            admState = admst;
            servstate = slst;
            networkOffering = netwrkOffr;
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
                        if ( needsISPAck )
	                        actionList.add( new SelectOption('submitTxnRequest(\'Action Plan\',\'' + apID + '\');', 'Acknowledge ISP'));
    	                
                        navList.add( new SelectOption('submitTxnRequest(\'Action Plan\',\'' + apID + '\');', 'Action Plan'));
                        navList.add( new SelectOption('dspShiftNoteSummary(\'' + pbsID + '\');', 'Shift Note Summary'));		
                        actionList.add( new SelectOption('submitTxnRequest(\'BehaviorList\',\'' + apID + '\');', 'View Behavior Data'));        			
                        actionList.add( new SelectOption('submitTxnRequest(\'SkillList\',\'' + apID + '\');', 'View Skill Data'));
                        
                        if (servstate == 'OH' && networkOffering == 'IDD') {
                            actionList.add( new SelectOption('submitTxnRequest(\'ServiceList\',\'' + apID + '\');', 'View Service Data'));
                            actionList.add( new SelectOption('openModalDialogR(\'OhioDailyDataSummaryDialog\', \'div\', \'Generate Daily Data Summary and Progress Note\', null, 700, \'mainForm\',\'false\'); assignValue(\'saIdforOhioDailyDataSummary\',\'' + saID + '\');', 'Daily Data Summary'));
                        }
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
          
            if ( servState == 'IA'){
            	actionList.add( new SelectOption('openModalDialogR(\'IowaDailyDataSummaryDialog\', \'div\', \'Generate Daily Data Summary and Progress Note\', null, 700, \'mainForm\',\'false\'); assignValue(\'saIdforDailyDataSummary\',\'' + saID + '\');', 'Daily Data Summary'));
            	actionList.add( new SelectOption('submitTxnRequest(\'TimeLog\',\'' + saID + '\');', 'Record Time Log'));
            }
            
            if ( servstate == 'OH' && networkOffering == 'IDD' )
            	actionList.add( new SelectOption('submitTxnRequest(\'TimeLog\',\'' + saID + '\');', 'Record Time Log'));
        
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
        currentSAList = new List<String>();
       	currentPBSList = new List<String>();
        
        // retrieve list of user's tasks
        mineTasks();
        
    }


	public void setPBSList() {
		
        ID uid = UserInfo.getUserid();
 
 
        //RPII-56 2016-02-01 changes storage of favorites cookie to user object in cloud.  for seamless transition, check standard cookie if user setting is blank, but only once
        User u = [ select id, favorite_PBS__c from User where id = :uid LIMIT 1];
        String pbsJoin = u.favorite_PBS__c;
         
         if ( string.isBlank( pbsJoin )) {
	        //retrieve list of PBS given favorites string from browser cookie
	        Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + uid);
	        if (favoritePBSList != null ){
	            pbsJoin = favoritePBSList.getValue();
	        }
	        
	        // save the machine value into the cloud
        	updatePBSListCookie(pbsJoin );
        	
        	// clear the machine cookie so it won't overwrite cloud again
        	ApexPages.currentPage().setCookies( 
            new Cookie[]{
                new Cookie(
                    'favoritePBS-' + UserInfo.getUserId(),
                    null, null, -1, false
                )
            });
         }
        
        List<String> favePBS = new List<String>();
        List<String> faveSA = new List<String>();
        
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
    
    // exclude currently displayed PBSs and SAs from search
    private void buildSearchExclusionList( List<String> sa, List<String> pbs) {
    	// this needs to be addititve...
    	
        currentSAList.addAll( sa );
        currentPBSList.addAll( pbs );
    }
    
    
    // this is the initial list of "favorite" PBS that user has requested to save in cookie
    public void getPBSList( List<String> PIds, List<String> saIDs) {
        
        // get people with active SA only since all actions require an active SA
        Service_Assignment__c[] listPBSbySA = [
            SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
            Person_Being_Served__r.Preferred_First_Name__c, Person_Being_Served__r.Preferred_Last_Name__c,
            admission__c, Service_Location__r.location_nickname__c, service_location__r.state__c,
            Service_Location__r.Alias__c, admission__r.state__c, service_location__r.network_offering__c,
            (select id, effective_date__c, Status__c, target_date__c from action_plans__r where status__c = 'Active Final' order by finalized_date__c desc LIMIT 1)
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
                                                focusPBS.Person_Being_Served__r.Preferred_First_Name__c != null ? focusPBS.Person_Being_Served__r.Preferred_First_Name__c : focusPBS.Person_Being_Served__r.FirstName ,
                                                focusPBS.Person_Being_Served__r.Preferred_Last_Name__c != null ? focusPBS.Person_Being_Served__r.Preferred_Last_Name__c : focusPBS.Person_Being_Served__r.LastName ,
                                                focusPBS.service_location__r.alias__c + + (( focusPBS.service_location__r.location_nickname__c != null ) ? ' - ' + focusPBS.service_location__r.location_nickname__c : ''),
                                                focusPBS.service_location__r.alias__c,
                                                hasAP ? focusPBS.action_plans__r[0].effective_date__c : null,
                                                true,  // is favorite
                                                false, //has risk
                                                false, // has issa
                                                hasAP, // has action
                                                hasAP ? focusPBS.action_plans__r[0].target_date__c : null, // ap end date
                                                focusPBS.admission__r.state__c,
                                                focusPBS.service_location__r.state__c,
                                                focusPBS.service_location__r.network_offering__c
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
 
         // OH-11 - get list of ISP attachments for finalized plans
        planISPAttach.clear();
        List<String> attids = new List<String>();
        Attachment[] atts = [ select id, parentID from attachment where parentid in :plans and name like 'ISP%' order by createddate desc];
        for (Attachment a: atts ) {
        	if ( planISPAttach.get( a.parentID ) == null) { 	// only add the most recent ISP
        		planISPAttach.put( a.parentID, a.id );
	        	attids.add(a.id);
        	}
        } 
        
        system.debug('PLAN ISP ATTACHMENTS---' + planispattach);
        
        // get list of any acknowledgments by this user on things on this admission 
        // action plans are on SA level, and assessments are on the admission level
        Acknowledgment__c[] acks = [ select id, action_plan__c, assessment__c, attachment__c from acknowledgment__c 
                                    where (action_plan__r.service_assignment__r.admission__c in :admissions or assessment__r.admission__c in :admissions or attachment__c in :attids) // or attachment = latest ISP    
                                    and user__c = :userInfo.getUserId()];
 
         // acknowledgment has either the action plan or assessment field filled in - check based on the type                            
        for ( Acknowledgment__c a : acks ) {
            if ( a.action_plan__c != null ) {		// OH-11 ISP ack has both Action plan and attachment set
            	if ( a.attachment__c != null)  { 
            		setAcks.add( a.attachment__c);
            	}
                setAcks.add( a.action_plan__c );
            }
            else if ( a.assessment__c != null)
                setAcks.add( a.assessment__c );
        }
        
        // go through the PBS List to update the settings for Risk and ISSA existence and need to acknowledge
        for ( PBSWrapper p : peopletoServe ) {
            
            if ( p.hasActionPlan ) {
                p.needsAPAck = !setAcks.contains( p.APId );
                if ( planISPAttach.get(p.APId) != null)
                	p.needsISPAck = !setAcks.contains( planISPAttach.get(p.APId));
                else
                	p.needsISPAck = false; // don't show ack button when there is no ISP
            }
 
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
        
        
        //system.debug('LIST OF PLANS IS: ' + plans);
        
        // date to check for checksheets
        Date checkDate = Date.Today().toStartOfWeek();

        // if today is sunday, it's the beginning of a new week in salesforce, but our worksheets run Mon-Sun, 
        // so we need to back up a week
        if ( Date.Today() == checkDate )
        	checkDate = checkDate.addDays(-7);
        
        // now go to Monday of the check week
        checkDate = checkDate.addDays(1);
        
        // system.debug('Today is ' + Date.Today() + ', and checkdate is ' + checkDate );
        	
        // get the list of worksheets behavior/skills for this calendar month and year if behavior
        Map<ID, Action_Plan_Worksheet__c> wmap = new Map<ID, Action_Plan_Worksheet__c>([select id, recordtype.developername, start_date__c, action_plan__c from action_plan_worksheet__c 
                                                                                        where action_plan__c in :plans 
                                                                                        and (( start_date__c = THIS_MONTH and recordtype.developername = 'Monthly_Behavior_Result')
                                                                                             or ( start_date__c = :checkDate and recordtype.developername = 'Weekly_Skill_Result' )
                                                                                             or ( start_date__c = THIS_MONTH and recordtype.developername = 'Monthly_Service_Result'))]);
        
        
        // put into map - key is actionplanid + worksheet type
        String wtype = '';
        for ( Action_Plan_Worksheet__c w : wmap.values() ) {
            if ( w.recordtype.developername.contains('Skill') )
                wtype = 'Skill';
            else if ( w.recordtype.developername.contains('Behavior'))
                wtype = 'Behavior';
            else if ( w.recordtype.developername.contains('Service'))
                wtype = 'Service';
            
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

                // SERVICE - monthly           
                // if there is a service worksheet for the current month, grab ID 
                if ( apWksht.keyset().contains( p.apId + 'Service')) {
                    wID = apWksht.get( p.apID + 'Service'); 
                    aw = wmap.get( wID);
                    p.hasSrvcW = true;
                    p.srvcwID = aw.Id;
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
                    if ( !p.hasSrvcW ) p.hasSrvcW = true;                    
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
        map<Id,Id> whatIdMapForEvents = new map<Id,Id>(); 	 // using this to query the tasks for Event (im_incident__c)  
        for (Task task: populateTasks) {
            system.debug( 'WHO: ' + task.whoid + ', WHAT: ' + task.whatid );
            if (task.WhoId != null) {
                taskToNameMap.put(task.Id, new list<String>{'<a href="#" onclick="submitTxnRequest(\'Person Being Served\',\'' + task.WhoId + '\');">' + task.Who.Name + '</a>'});
                if ( task.whatID != null) {
                    if (task.WhatId.getSObjectType().getDescribe().getName() == 'Action_Plan__c')
                        taskToNameMap.get(task.Id).add('<a href="#" onclick="submitTxnRequest(\'Action Plan\',\'' + task.WhatId + '\'); return false;">' + task.What.Name + '</a>');
                    else if (task.WhatId.getSObjectType().getDescribe().getName() == 'Assessment__c') 
                        taskToNameMap.get(task.Id).add('<a href="#" onclick="submitTxnRequest(\'' + (task.What.Name.containsIgnoreCase('ISSA') ? 'ISSA': 'Risk') + '\',\'' + task.WhatId + '\');">' + task.What.Name + '</a>');
                    else taskToNameMap.get(task.Id).add(''); //anything other than AP, Risk, ISSA, Incident - we didnt built a DSP user capability to navigate to that yet.
                } else {
                    taskToNameMap.get(task.Id).add( '');
                }
            } else {
                	taskToNameMap.put(task.Id, new list<String>{'',''});
                    whatIdMapForEvents.put(task.WhatId, task.Id);
            }
        }
        for (Im_Incident__c event : [select id, Name from Im_Incident__c where id IN : whatIdMapForEvents.keySet()]){
			taskToNameMap.put((Id)whatIdMapForEvents.get(event.id), new list<String>{'<a href="#" onclick="submitTxnRequest(\'Incident\',\'' + event.id + '\'); return false;">' + event.Name + '</a>', '<a href="#" onclick="submitTxnRequest(\'Incident\',\'' + event.Id + '\'); return false;">' + event.Name + '</a>'});
        }
    }
    
    
    
    
    // search results for PBS lookup
    public void getSearchResults() {

		if (String.IsBlank(frstName ) && String.IsBlank(LstName) && String.IsBlank(Prgm)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
				'You have to specify either a First Name or Last Name or Program')
			);
			return;
		}
		OneAppSearchController searchController = new OneAppSearchController( frstName, LstName, Prgm );
		searchController.excludeSAList = currentSAList;
        searchController.excludePBSList = currentPBSList;

        searchResultList = searchController.getSearchResults(true, false, false, true);
    }
    
    // this sets the list of favorites on the home page
    public void setfocusPBS() {
        
        List<String> searchPBS = searchResultPBS.split(',');
        List<String> searchSA = searchResultSA.split(',');
        
        // pbsid, pbsname, said, apid, progstring, alias, plan eff, pln status
        List<Service_Assignment__c> focusPBSList = [
            SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
            Person_Being_Served__r.Preferred_First_Name__c, Person_Being_Served__r.Preferred_Last_Name__c,
            admission__c, Service_Location__r.location_nickname__c,  service_location__r.state__c, service_location__r.network_offering__c,
            Service_Location__r.Alias__c, admission__r.state__c, 
            (select id, effective_date__c, target_date__c, Status__c from action_plans__r where status__c = 'Active Final' order by finalized_date__c  desc LIMIT 1)
            FROM Service_Assignment__c
            WHERE Person_Being_Served__c in :searchPBS
            AND ID in :searchSA
            AND    status__c = 'Active'
           ];
        
        string newcookie = '';
        
	    // while looping, construct the cookie string of favorites and search exclusions
        List<String> excludeSA = new List<String>();
        List<String> excludePBS = new List<String>();

        for ( Service_Assignment__c focusPBS : focusPBSList ) {
	        // make sure the PBS/SA still is active 
            Boolean hasAP = ( focusPBS.Action_Plans__r.size() > 0 );
            //ID pID, ID sID, ID aID, string n, string p, string al, date ed    
            PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c, 
                                                focusPBS.admission__c,
                                                focusPBS.id,
                                                hasAP ? focusPBS.Action_Plans__r[0].id : null, 
                                                focusPBS.person_being_served__r.name, 
                                                focusPBS.Person_Being_Served__r.Preferred_First_Name__c != null ? focusPBS.Person_Being_Served__r.Preferred_First_Name__c : focusPBS.Person_Being_Served__r.FirstName ,
                                                focusPBS.Person_Being_Served__r.Preferred_Last_Name__c != null ? focusPBS.Person_Being_Served__r.Preferred_Last_Name__c : focusPBS.Person_Being_Served__r.LastName ,
                                                focusPBS.service_location__r.alias__c + (( focusPBS.service_location__r.location_nickname__c != null ) ? ' - ' + focusPBS.service_location__r.location_nickname__c : ''),
                                                focusPBS.service_location__r.alias__c,
                                                hasAP? focusPBS.Action_Plans__r[0].effective_date__c : null,
                                                searchResultIsFav, // is fav
                                                false, // has risk
                                                false, // has ISSA
                                                hasAP,
                                                hasAP ? focusPBS.Action_Plans__r[0].target_date__c : null,
                                                focusPBS.admission__r.state__c,
                                                focusPBS.service_location__r.state__c,
                                                focusPBS.service_location__r.network_offering__c
                                               );
            
            // if already there, remove it to make sure the favorite setting is correct
            for ( PBSWrapper p : peopleToServe ) {
                if ( p.Equals( thisPBS ) ) {
                    peopleToServe.Remove(p);
                    
                    // remove from list of admissions too
                    admissions.remove(p.admId);
                    
                } else {
                    if ( p.isFavorite )  
                        newcookie += p.pbsID + '-' + p.saID + ';';
                    
                    excludeSA.add(p.saID);
                    excludePBS.add(p.pbsID);
                }
            }
        
            // add the PBS to the list
            peopletoServe.add( thisPBS );
            admissions.add( thisPBS.admId);
            if ( hasAP )
                plans.add( thisPBS.apID);
            
            excludeSA.add(thisPBS.saID);
            excludePBS.add(thisPBS.pbsID);
                    
            // setup favorites
            if ( thisPBS.isfavorite ) {
                newcookie += thisPBS.pbsID + '-' + thisPBS.saID + ';';
            }
       }       
         
        // get the list of assessments for these people's admissions and acknowledgments
        setAdmissionAssessments();
        
        // get worksheets
        setPlanWorksheets();
        			            
        system.debug( 'MASTER LIST:'  + peopletoServe + ', new cookie: ' + newcookie);
        system.debug( 'Exclude lists:' + excludeSA + ', ' + excludePBS);
        buildSearchExclusionList( excludeSA, excludePBS);
        
        // rebuild cookie - this will handle removal of favorites too
        updatePBSListCookie( newcookie );
}
 
 
    // update/renew the list of favorites   
    // RPII-56 - 2016-02-01: changing from storing cookie to storing in the cloud on User object
    public void updatePBSListCookie( string newval) {
    	
		User u = [ select id, favorite_PBS__c from user where id = :UserInfo.getUserId() LIMIT 1];
		u.favorite_PBS__c = newval;
		try {
			update u;
		} catch (Exception e ) { }
    	
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
    	try{
        PageReference pageRef = new PageReference('/apex/DSP_shiftnote_summary_rpt');
        String selectedPBS =  this.pbsID == null || this.pbsID == '' ?  String.join(this.currentPBSList, ',') : this.pbsID;
        pageRef.getParameters().put('selectedPBS', selectedPBS );
        pageRef.getParameters().put('currentPBSList', json.serialize(this.currentPBSList));
        pageRef.setRedirect(true);
        return pageRef;
    	} catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No person being served found! Please search and add one or more person being served to your favorite list to run the shift note summary report.'));
            return null;
    	}
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