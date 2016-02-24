public with sharing class GenerateGoalObjPDF {

	public ID evalID { get; set { init(value);}}
	public List<ObjectiveWrapper> objectives { get; private set;}	
	
	private ID eID = null;
	
	public GenerateGoalObjPDF() {
		objectives = new List<ObjectiveWrapper>();
	}
	
	
	public void init ( ID evalID ) {	
		
		// only run this function once for this eval
		if (eID == evalID)
		{
			system.debug( 'already been here: eID and evalID:' + eID + ', ' + evalID);
			return;
		}
		else {
			system.debug( 'eID and evalID:' + eID + ', ' + evalID);
			eID = evalID;
		}
			
		Evaluation__c eval = [ select id, recordtype.name, name, shift_start_time__c, shift_end_time__c, serviceassignment__c from evaluation__c where id = :evalID limit 1];
		if ( eval == null)
			return;
		
		if (eval.recordType.name.equals('NursesAssessment') || eval.recordType.name.equals('RestraintEvent'))
			return;
		
		
		DateTime shiftStart = eval.shift_start_time__c;
		DateTime shiftEnd = eval.shift_end_time__c;
		ID saID = eval.serviceassignment__c;
			 
		if ( objectives.size() > 0 ) {
			// don't reload
			return;
		}
		
		// find all reportable objectives during the time period
		List<Action_Plan_Objective__c> lstAPO = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
									and (
										 (effective_date__c > :shiftStart.Date()  and effective_date__c <= :shiftEnd.Date())
										  or
										 (effective_date__c <= :shiftStart.Date() and target_end_date__c >= :shiftStart.Date()) 
									)
									and Status__c in ('In Progress', 'Revised', 'New')
									and action_plan_goal__r.action_plan__r.status__c = 'Active Final' ];

		List<Action_Narrative_Result__c> narrativeResults = [ select action_plan_objective__c, id, description__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from action_narrative_result__c where action_plan_objective__c in :lstAPO and lastmodifieddate >= :shiftStart order by action_plan_objective__c, lastmodifieddate desc];
		List<Action_Skill_Result__c> skillResults = [ select action_plan_objective__c, id, attempts__c, day__c, initials__c, met_objective__c, status__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Skill_Result__c where action_plan_objective__c in :lstAPO and lastmodifieddate >= :shiftStart order by action_plan_objective__c, lastmodifieddate desc ];
		List<Action_Behavior_Result__c> behaviorResults = [select action_plan_objective__c, id, Day_time__c, Occurrences__c, Occurred__c, LastModifiedById, LastModifiedDate from Action_Behavior_Result__c where Action_Plan_Objective__c in :lstAPO and Day_time__c >= :shiftStart order by action_plan_objective__c, Day_time__c ];
		
		Map<ID, List<Action_Narrative_Result__c>> anrmap = new Map<ID, List<Action_Narrative_Result__c>>();
		for (Action_Narrative_Result__c res : narrativeResults ) {
			if ( anrmap.containsKey( res.action_plan_objective__c))
				anrmap.get(res.action_plan_objective__c).add(res);
			else
				anrmap.put(res.action_plan_objective__c, new List<Action_Narrative_Result__c> { res });
		}

		Map<ID, List<Action_Skill_Result__c>> srmap = new Map<ID, List<Action_Skill_Result__c>>();
		for (Action_Skill_Result__c res : skillResults ) {
			if ( srmap.containsKey( res.action_plan_objective__c))
				srmap.get(res.action_plan_objective__c).add(res);
			else
				srmap.put(res.action_plan_objective__c, new List<Action_Skill_Result__c> { res });
		}

		Map<ID, List<Action_Behavior_Result__c>> brmap = new Map<ID, List<Action_Behavior_Result__c>>();
		for (Action_Behavior_Result__c res: behaviorResults) {
			if ( brmap.containsKey(res.action_plan_objective__c))
				brmap.get(res.action_plan_objective__c).add(res);
			else
				brmap.put(res.action_plan_objective__c, new List<Action_Behavior_Result__c>());
		}

		for (Action_Plan_Objective__c apo : lstAPO) {
			ObjectiveWrapper obj = new ObjectiveWrapper( apo.id, apo.type__c, shiftStart, shiftEnd, apo.effective_Date__c, apo.target_end_date__c, apo.description__c );
			if ( apo.type__c == 'Skill' && srmap.get( apo.id) != null )
				obj.skillResults = srmap.get( apo.id);
			else if ( apo.type__c == 'Narrative' && anrmap.get(apo.id) != null)
				obj.narrativeResults = anrmap.get(apo.id);
			else if ( apo.type__c.startsWith( 'Behavior')) {
				obj.behaviorList = brmap.get( apo.id);
				obj.calcTables();
			}
			
			objectives.add( obj);
				
		} 
		
		
	}
	

	public class ObjectiveWrapper {
		 
		public ID objId { get; set; }
		public string objType { get; set; }
		public DateTime shiftStart { get; set; }
		public DateTime shiftEnd { get; set; }
		private Date effdate { get; set; }
		private Date enddate { get; set; }
		public string effdates {get; set; }
		public String objDesc { get; set; }
		public transient List<Action_Narrative_Result__c> narrativeResults {get; private set;}
		public transient List<Action_Skill_Result__c> skillResults {get; private set;} 
		public transient List<String> columnsToFetch { get; private set ;}
		public List<Action_Behavior_Result__c> behaviorList { get; set;}
		public transient List<Table> behaviorResults { get; private set; }
		
		public ObjectiveWrapper( ) {
			objID = null;			
			objType = null;
			objDesc = null;
			shiftStart = null;
			shiftEnd = null;
			effdate = null;
			enddate = null;
			narrativeResults = new List<Action_Narrative_Result__c>();
			skillResults = new List<Action_Skill_Result__c>();
			behaviorList = null;
			behaviorResults = new List<table>();
		}
		
		public ObjectiveWrapper( ID oID, String oType, DateTime shStart, DateTime shEnd, Date sdate, Date edate, String odesc  ) {
	
			objID = oID;
			objType  = oType;
			objDesc = odesc;
			shiftStart = shStart;
			shiftEnd = shEnd;
			effdate = sdate;
			enddate = edate;
			effdates = sdate.format() + ' to ' + edate.format();
			if ( oType == 'Narrative')
				columnsToFetch = new List<String>{'description__c','lastmodifiedbyid', 'lastmodifieddate'};
			else if (oType == 'Skill')
				columnsToFetch = new List<String>{'attempts__c','day__c','initials__c','met_objective__c','status__c', 'lastmodifiedbyid', 'lastmodifieddate'};
			
		}
		
		// supporting code for behavior table calculation
	private DateTime getMinDateTime( datetime dt1, datetime dt2) {
		
		DateTime mindt;
		
		if ( dt1 == null ) {
			return ( dt2 == null ? DateTime.now() : dt2);
		}
		else {
			if (dt2 == null )
				return dt1;
				
			Long ms1 = dt1.getTime();
			Long ms2 = dt2.getTime();
		
			mindt = DateTime.valueOf( Math.Min( ms1, ms2));
		
			return mindt;
		}		
	}
	
    @TestVisible private void calcTables( ){
    	
    	if ( behaviorList == null )
    		return;
    		
		Date firstDay = shiftStart.Date();
		Date lastDay = getMinDateTime(shiftEnd, DateTime.Now()).date();
		List<Table> out = new List<Table>();
		out.Add(GenerateObjectiveTable(firstDay, lastDay));
		behaviorResults = out;
	}

	private Table GenerateObjectiveTable(Date firstDay, Date lastDay){
		Table t1 = new Table(getHoursOfDay(), getDaysToDisplay());
		//system.debug( 'OBJECTIVE INSIDE GENERATE TABLE:' + objective);
		t1.ObjectiveDescription = this.objDesc;
		t1.ObjectiveId = this.objID;
		system.debug('this objective type is:' + this.objType);
		t1.IsTimeBased = IsTimeBased( this.objType );

		for(Action_Behavior_Result__c result: behaviorList ){
			system.debug( result);
			t1.Put(result.Day_time__c.Time().hour(),result.Day_time__c.Date(), result);
		}

		for( integer timeofday : t1.FirstKeys){
			for(Date day: getdaysofmonth()){
				if ((!t1.Active(timeofday, day)) && TimeValidForObjectiveAndPlanAndShift(day, timeofday, this.effdate, this.enddate )){
					Action_Behavior_Result__c blankResult = new Action_Behavior_Result__c();
					blankResult.Action_Plan_Objective__c = this.objId;
					blankresult.Day_time__c = DateTime.newinstance(day, Time.newInstance(timeofday,0,0,0));
//					system.debug( blankresult.Day_time__c);
					t1.Put(timeofday, day, blankResult);
				}
			}
		}
		return t1;
	}

	public boolean DateValidForObjectiveAndPlan(Date day, Date objEff, Date objEnd){
		return ((objEff == null) || (day >= objEff)) &&
				((objEnd == null) || (day <= objEnd));
	}
	
	public boolean TimeValidForObjectiveAndPlanAndShift (Date day, Integer tofd, Date objEff, Date ObjEnd){
		
		Datetime thisdt = DateTime.newinstance(day, Time.newInstance(tofd,0,0,0));
		Datetime startdt = DateTime.newinstance(shiftstart.date(), Time.newInstance(shiftstart.hour(), 0,0,0));
		
		// check if this element is available for editing during the shift
		return ( ((objEff == null) || ( day >= objEff )) &&
				( thisdt >= startdt ) &&
				((objEnd == null) || (day <= objEnd)) &&
				( thisdt <= DateTime.now())
				);
	}
	
	private Map<id, Action_Behavior_Result__c> ResultMap(Date firstDay){
		Map<id, Action_Behavior_Result__c> origData = new Map<id, Action_Behavior_Result__c>();
			for(Action_Behavior_Result__c result: behaviorList ){
				origData.Put(result.id, result);
			}
		return origData;
	}
	
	public List<Date> getDaysToDisplay() {
		List<Date> month = new List<Date>();
		Date startDate = shiftStart.Date();
		DateTime endDateTime = getMinDateTime(shiftEnd, DateTime.now());
		Date endDate = getMinDateTime(shiftEnd, DateTime.now()).Date();
		
		for(Date dateiter = StartDate; dateiter <= endDate; dateiter = dateiter+1){
			// don't include last day if shift ends on midnight
			if ( dateiter == endDate ) {
					system.debug( 'on end date this is time:' + endDateTime.time());
				// check end hour 
				if (endDateTime.time() == Time.newInstance(0,0,0,0))
					continue;	
			}
			month.Add(dateiter);
		}
		return month;
	}

	public List<Date> getDaysOfMonth() {
		List<Date> month = new List<Date>();
		Date endDate = getMinDateTime(shiftEnd, Datetime.now()).date();
		DateTime endDateTime = getMinDateTime(shiftEnd, DateTime.now());
		system.debug(shiftStart.Date().addmonths(1));
		system.debug(shiftStart.Date().addmonths(1).toStartofMonth());
		for(Date dateiter = shiftStart.Date(); dateiter <= endDate; dateiter = dateiter+1){
			
			// don't include last day if shift ends on midnight
			if ( dateiter == endDate ) {
				//system.debug( 'on end date this is time:' + endDateTime.time());
				// check end hour 
				if (endDateTime.time() == Time.newInstance(0,0,0,0))
					continue;	
			}
			month.Add(dateiter);
					
				
		}
		return month;
	}

	public List<integer> getHoursOfDay() {
		List<integer> hours = new List<integer>();
		integer maxhours = 0;
		integer istart=0; 
		integer iend=23;
		Datetime dtnow = datetime.now();
		Datetime dtEnd = getminDateTime( shiftEnd, dtNow );
		integer starthr = shiftStart.hour();
		integer endhr = dtEnd.hour();
		
		// if we're in the same day as the shift, start on shift start hour, end on current hour
		if ( shiftStart.isSameDay(dtEnd)) {
			istart = starthr;
			iend = endhr;
		} else {
			// we've crossed over midnight - need to output hours from earliest hour through midnight
			istart = 0;
			iend = 23;
		}
				
		for(integer ii = istart; ii <= iend; ii++){
				hours.Add(ii);
			}		
		
		return hours;
	}

	private boolean IsTimeBased( String strType ) {
		return (strType == 'Behavior - Duration');
	}

}
	public class Table {
		public List<integer> FirstKeys {get;set;}
		public List<Date> PartOneSecondKeys {get;set;}
		public List<Date> PartTwoSecondKeys {get;set;}
		public List<Date> AllSecondKeys {get;set;}
		private Map<integer, Row> myRows;
		public string ObjectiveDescription {get;set;}
		public string ObjectiveId {get;set;}
		public boolean IsTimeBased {get;set;}

		public Map<integer, Row> getRows(){
			return myRows;
		}

		public Table(List<integer> keys1, List<Date> keys2) {
			myRows = new Map<integer, Row>();
			FirstKeys = keys1;
			PartOneSecondKeys = new List<Date>();
			PartTwoSecondKeys = new List<Date>();
			AllSecondKeys = keys2;
			integer jj = 0;
			for(Date day: keys2){
				system.debug('Table Key:' + day);
				if (jj < 21){
					PartOneSecondKeys.Add(day);
				} else {
					PartTwoSecondKeys.Add(day);
				}
				jj++;
			}
			for(integer ii: keys1){
				Row newRow = new Row(ii, keys2);
				myRows.put(ii, newRow);
			}
		}

		public void Put(integer tofd, Date day, Action_Behavior_Result__c value){
			if ( myRows.get(tofd) != null)
				myRows.get(tofd).put(day, value);
		}

		public Action_Behavior_Result__c Get(integer tofd, Date day){
			try {
				return myRows.get(tofd).get(day);
			} catch (Exception e) {
				return null;
			}
		}

		public boolean Active(integer tofd, Date day) {
			system.debug('Table Access:' + day);
			try {
				return myRows.get(tofd).getItems().get(day).Active;
			} catch( Exception e ) {
				return false;
			}
		}
	}

	public class Row {
		private Map<Date, Action_Behavior_Wrapper> myItems {get;set;}
		private string myhour;

		public Map<Date, Action_Behavior_Wrapper> getItems(){
			return myItems;
		}

		public Row(integer hour, List<Date> alldays){
			myItems = new Map<Date, Action_Behavior_Wrapper>();
			myhour = DateTime.newInstance(Date.Today(), Time.newInstance(hour, 0,0,0)).format('HH:mm');
			for(Date day: alldays){
				myItems.Put(day, new Action_Behavior_Wrapper(hour, day, null));
			}
		}

		public string getHeader(){
			return myhour;
		}
		public void Put(Date day, Action_Behavior_Result__c item){
			Action_Behavior_Wrapper wrap = myItems.get(day);
			if ( wrap != null )
				wrap.DataObject = item;
		
		}

		public Action_Behavior_Result__c Get(Date day){
			Action_Behavior_Wrapper wrap = myItems.get(day);
			if ( wrap != null)
				return wrap.DataObject;
			else
				return null;
		}

	}


	public class Action_Behavior_Wrapper {
		public Action_Behavior_Result__c myObject;
		public integer mytime;
		public Date myDate;
		public boolean Active {get{ return myObject <> null;}}

		/*****
		** Needed if the timezone ever springs forward causing 2am to become 3am
		**        public boolean Active {get{ return myObject <> null && !missinghour;}}
		**        private boolean missinghour;
		******/
		
		public Action_Behavior_Wrapper(integer tofd, Date day, Action_Behavior_Result__c obj){
			myobject = obj;
			mytime = tofd;
			myDate = day;
		}

		public Action_Behavior_Result__c DataObject{
			get { return myObject;}
			set { myObject = value;}
		}

		public string getDayOfWeek(){
			return DateTime.newInstanceGMT(myDate, Time.newInstance(0,0,0,0)).formatGMT('E');
		}
	}
	
		
	
		
		

	
	

}