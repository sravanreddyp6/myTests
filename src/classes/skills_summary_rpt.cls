public with sharing class skills_summary_rpt {
	
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<id> selectedPBS {get; set;}
    public list<SelectOption> PBSList = new list<SelectOption>();
    public list<SelectOption> getPBSList(){ return PBSList ;}

    public boolean hasRunOnce {get; set;}
    public transient Map<ID, List<Action_Plan__c>> pbsPlanMap { get; set; }
    public transient Map<ID, List<Action_Plan_Objective__c>> planObjMap { get; set; }
    public transient Map<ID, List<mydate>> objWeekMap { get; set; }
    public List<Integer> dayCounter {get { return new List<Integer>{0,1,2,3,4,5,6};}}
    public transient Map<ID, Contact> pbsPeople{ get; set;}
    public transient string strPlanContacts { get; set;}
    public integer numContacts { get; set; }
    public transient string strPlanObjList {get; set;}

    // START: ERD-11 - Add property to hold PDF run datetime as string in report runner's time zone.  J. Gilliam, 11/5/14
    public string pdfRunDateTimeString { get; set; }
    // END: ERD-11 - Add property to hold PDF run datetime as string in report runner's time zone.  J. Gilliam, 11/5/14

    public transient list<SelectOption> programslist = new list<SelectOption>();
    public list<SelectOption> getProgramslist(){ return programslist; }
	public List<Id> selectedPrograms {get; set;}
	
    public transient list<SelectOption> select2list = new list<SelectOption>();
    public list<SelectOption> getSelect2list(){ return select2list; }	
    public List<id> select2PrmIds {get; set;}
    

    public skills_summary_rpt() {   	
		List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
										   FROM service_assignment__c 
										  GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
										 HAVING COUNT(service_location__r.id) > 0
										  ORDER BY service_location__r.program__c];
		for (AggregateResult slPrgm : slPrgms) {
			programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        selectedPBS = new List<id>();
        pbsPeople = new Map<ID, Contact>();
        hasRunOnce =false;
        strPlanContacts = '';
        numcontacts = 0;
        
    }


	public pagereference AddPrograms(){
		for (Id p :selectedPrograms){
			for(Integer i=0; i < programslist.size(); i++){
				if (programslist.get(i).getValue() == p) {
	    			select2list.add(new SelectOption(programslist.get(i).getValue(), programslist.get(i).getLabel()));
	    			programslist.remove(i);
					break;
	    		}
			}
		}
		UpdateProgramSelections();
        return null;
    }

	public pagereference RemovePrograms(){
		for (Id p :select2PrmIds){
			for(Integer i=0; i < select2list.size(); i++){
				if (select2list.get(i).getValue() == p) {
	    			programslist.add(new SelectOption(select2list.get(i).getValue(), select2list.get(i).getLabel()));
	    			select2list.remove(i);
					break;
	    		}
			}
		}
		UpdateProgramSelections();
        return null;
    }

	public void UpdateProgramSelections(){
		List<id> selectedPrmIds = new List<id>();
		for (selectOption so : select2list){
			selectedPrmIds.add(so.getValue());
		}
		
	// get the list of people for whom service assignments exist.  this is so we can check for missing worksheets	
	List<AggregateResult> aggrePbs = [
				SELECT Person_Being_Served__c pbsID, Person_Being_Served__r.Lastname pbsLastName, Person_Being_Served__r.Firstname pbsFirstName 
				  FROM service_assignment__c 
				 where service_location__c In :selectedPrmIds 
				 GROUP BY Person_Being_Served__c, Person_Being_Served__r.Lastname, Person_Being_Served__r.Firstname
				 ORDER BY Person_Being_Served__r.Lastname, Person_Being_Served__r.Firstname];
		PBSList.clear();
		for (AggregateResult pbs : aggrePbs) {
			PBSList.add(new SelectOption((Id) pbs.get('pbsID'), String.valueOf(pbs.get('pbsLastName')) + ', ' + String.valueOf(pbs.get('pbsFirstName'))));
        }		
    }

    public pagereference runReport(){
    	
       boolean inputErr = false;
       ApexPages.getMessages().clear();
       
       system.debug( 'sd=' + startDate + ', ed=' + endDate + ', prog=' + select2PrmIds.size() + ', pbs=' + selectedPBS.size());
       
       if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } else if ( startDate > endDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       if(selectedPBS.Size()==0    ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select at least one Person Being Served');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       
       if ( inputErr ) {
			return null;
       }
			
			       
       hasRunOnce = true;
       TimeZone zone = UserInfo.getTimeZone();
       datetime startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
       datetime endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }

		system.debug( startDate + ', ' + endDate);
		List<myDate> mondays = getcoveredWeeks( startDate, endDate, startDate, endDate);
	
		system.debug( selectedPBS);
		
		List<Contact> people = [ select id, firstname, lastname from contact where id in :selectedPBS];
		pbsPeople = new Map<ID, Contact>(people);
		numContacts = people.size();
		
		// for each PBS, get active action plan, put into a map of PBSID, PlanID
		List<Action_Plan__c> apList = [select id, name, service_assignment__r.person_being_served__c from action_plan__c where service_assignment__r.person_being_served__c in :selectedPBS and 
			 ((effective_date__c >= :startDate and effective_date__c <= :endDate ) or
				(target_date__c >= :startDate and target_date__c <= :endDate ) or
				( effective_date__c < :startDate and target_date__c > :endDate)
				)
			];
		
		pbsPlanMap = new Map<ID, List<Action_Plan__c>>();
		for ( Action_Plan__c ap : apList ) {
			if ( pbsPlanMap.containsKey( ap.service_assignment__r.person_being_served__c)) {
				// add to the list
				(pbsPlanMap.get( ap.service_assignment__r.person_being_served__c)).add(ap );
			} 			
			else { 
				pbsPlanMap.put( ap.service_assignment__r.person_being_served__c, new List<Action_Plan__c>{ ap });			
				}
		}
		
		// add empty list of action plans for people who were selected but don't have plans - this is for front-end repeat support
		for ( ID p : selectedPBS ) {
			if (! pbsPlanMap.containsKey( p ))
				pbsPlanMap.put ( p, new List<Action_Plan__c>());
		}
		
		// get a list of objectives by plan - no need to check for effective dates because we did on the plan list and objectives can't be outside that
		List<Action_Plan_Objective__c> apoList = [ select id, description__c, effective_date__c, target_end_date__c, action_plan_goal__r.action_plan__c, action_plan_goal__r.action_plan__r.name, action_plan_goal__r.action_plan__r.service_assignment__r.person_being_served__c,
													(select Day__c, Attempts__c, Initials__c, Met_Objective__c, Status__c
                           								from Action_Skill_Results__r
                           								where Day__c >= :startDate 
                            							and Day__c < :endDate
                          								order by Day__c) 
										from action_plan_objective__c 
										where action_plan_goal__r.action_plan__c in :apList
										and type__c = 'Skill' 
										order by action_plan_goal__r.action_plan__c, action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c
										];
										
		planObjMap = new map<ID, List<Action_Plan_Objective__c>>();
		objWeekMap = new map<ID, List<mydate>>();
		ID planID; 
		
		// put the objectives list into the plan map.
		for ( Action_Plan_Objective__c apo : apoList ) {
			planID = apo.action_plan_goal__r.action_plan__c;
			if ( planObjMap.containsKey( planID)) {
				// add to the list
				(planObjMap.get( planID )).add(apo );
			} 			
			else { 
				planObjMap.put( planID, new List<Action_Plan_Objective__c>{ apo });
				strplanobjlist += planID+ ',';
			}
			
			objWeekMap.put( apo.id, getCoveredWeeks( apo.effective_date__c, apo.target_end_date__c, startDate, endDate));
			
			
		}
		system.Debug( 'pbs plans:' + pbsPlanMap);
		system.Debug( 'plan objs:' + planObjMap);		
		
        return null;
    }
    


 	public List<myDate> getcoveredWeeks( Date sd, Date ed, Date earliest, Date latest){
 		
 		sd =  sd < earliest ? earliest : sd;
 		ed = ed > latest ? latest : ed;
 		
 		system.debug( sd );
 		system.debug( ed );
        Date firstMonday = sd.toStartOfWeek() +1;
        Date lastMonday = ed.toStartOfWeek() +1;
        List<myDate> dates = new List<myDate>();

        for(Date monday=firstMonday;monday <= lastMonday; monday = monday + 7){
        	dates.Add(new myDate(monday));
        }
        return dates;
    }    
    
    public class myDate{
        private Date internaldate;
        
        public myDate(Date initdate){
            internaldate = initdate;
        }
        
        public date IntDate {
         	get { return internaldate; }
        }
        public string UserDate{
            get { return internaldate.format();}
        }
        public string ParsableDate{
            get { return internaldate.month() + '/' + internaldate.day() + '/' + internaldate.year();}
        }
    }
    
    
// START: ERD-11; add PDF functionality.  J. Gilliam, 10/30/14    
    public PageReference runPdf() {	
    	Datetime pdfRunDateTime = System.now();
    	pdfRunDateTimeString = pdfRunDateTime.format('MM/dd/yyyy, h:mm:ss a');
    	PageReference toPdfPage = new PageReference('/apex/skills_summary_rpt_PDF');
    	toPdfPage.setRedirect(false);
    	return toPdfPage;
    }
    
    public PageReference cancelToNewRun() {
    	PageReference pageRef = new PageReference('/apex/skills_summary_rpt');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
// END: ERD-11; add PDF functionality.  J. Gilliam, 10/30/14       


 	
}