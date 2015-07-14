public with sharing class GoalObjReporting {

	public ID objID { get; set { init( value); } }
	public ID saID { get; set; }
	public string effdates { get; set; }
	public ID currRespID { get; set; }
	public string objType { get; set ; }
	public Integer numRows { get; set; }
	public Action_Plan_objective__c thisObj {get ;set;}
	public datetime shiftStart { get; set; }
	public datetime shiftEnd { get; set; }
	public boolean editable { get { return true; }} //!worksheet.Action_plan__r.Status__c.contains('Inactive');}}
	
	private Boolean hasError;
		
	public objResultWrapper currResult { get; set; }
	
	public transient list<SelectOption> promptList;
    public list<SelectOption> getPromptList() { 
		if (promptList == null) {
			promptList = new List<SelectOption>();
	        promptList.Add(new SelectOption('', '--None--'));   
	        promptList.Add(new SelectOption('I','Independent'));
	        promptList.Add(new SelectOption('V','Verbal'));
	        promptList.Add(new SelectOption('M','Model'));
	        promptList.Add(new SelectOption('PP','Partial Physical Assistance'));
	        promptList.Add(new SelectOption('FP','Full Physical ASsistance'));
	        promptList.Add(new SelectOption('D','Declined'));
	        promptList.Add(new SelectOption('L','Leave/Absent'));
	        promptList.Add(new SelectOption('S','Sick'));
	        promptList.Add(new SelectOption('H','Hospitalized'));
	        promptList.Add(new SelectOption('HL','Holiday')); 
		}
        return promptList;
	}

	
	public transient List<Action_Narrative_Result__c> narrativeResults;
	public transient List<Action_Skill_Result__c> skillResults; 
	
	public transient List<String> columnsToFetch { get; private set ;}
	
	private SObject newresp;
	
	
	public GoalObjReporting() {
		narrativeResults = new List<Action_Narrative_Result__c>();
		skillResults = new List<Action_Skill_Result__c>();
		currResult = new objResultWrapper();
	}
	
	
	public void init ( ID thisID ) {	//get the type of objective this is
		
		if ( thisObj == null ||  thisID != thisObj.id ) {
			List<Action_Plan_Objective__c> apo = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where id = :thisID];
			system.debug( 'APO is' + apo);
			if (apo.size() > 0) {
				thisObj = apo[0];
				objType = apo[0].type__c;	
				effdates = apo[0].effective_date__c.format() + ' to ' + apo[0].target_end_date__c.format();
				if (objType.startsWith('Behavior')) {
					privateTables = null;
					currResult = null;
				}
				else {
					currResult = new objResultWrapper( objType, thisObj.id);
				}
			}
		}
		
	}
	
	public List<Action_Narrative_Result__c> getnarrativeResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c);	
		narrativeResults = [ select id, description__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from action_narrative_result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
		columnsToFetch = new List<String>{'description__c','lastmodifiedbyid', 'lastmodifieddate'};
		return narrativeResults;
		
	}
	
	public List<Action_Skill_Result__c> getskillResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c );	
	
		skillResults = [ select id, attempts__c, day__c, initials__c, met_objective__c, status__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Skill_Result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
		columnsToFetch = new List<String>{'attempts__c','day__c','initials__c','met_objective__c','status__c', 'lastmodifiedbyid', 'lastmodifieddate'};
		return skillResults;
	}
	
	public pageReference showEditResponse() {
		
        String query = 'SELECT ID ';
        
        for ( string col : columnsToFetch ) {
        	
        	query += ',' + col;
        }
        system.debug( 'obj type is ' + objType );
        if ( objType == 'Narrative' )  {
        		query += ' from action_narrative_result__c where Id = :currRespId';
        		newresp  = Database.query(query);
        		system.debug( newresp);
        		currResult = new objResultWrapper ( thisobj.id, newresp.id, 'Narrative', newresp);
        		system.debug('retrieving current result of ' +  currResult); 
        }

        if ( objType == 'Skill' )  {
        		query += ' from action_skill_result__c where Id = :currRespId';
        		newresp  = Database.query(query);
        		system.debug( newresp);
        		currResult = new objResultWrapper (thisobj.id, newresp.id, 'Skill', newresp);
        		system.debug('retrieving current result of ' +  currResult); 
        }
       
        return null;
	}
	
	public void saveResult() {
		
		if ( thisObj.type__c.startsWith('Behavior')) {
			saveBehavior();
			return;
		}
		
        System.debug('saveresult called');
        system.debug('currresult is:' + currresult);
        String resultType = currResult.resulttype;
           
        try {
            hasError = false;
            
            if (resulttype == 'Narrative') {
            	upsert( currResult.currResultN );
            }
            
            if (resulttype.startswith('Skill') ) {
            	upsert( currResult.currResultS);
            }
		    currResult = new objResultWrapper( thisObj.type__c, thisobj.id);
		    system.debug( currResult);
        } catch (DMLException ex) {
            hasError = true;
            system.debug(ex);
        } catch (Exception e) {
        	hasError = true;
        	system.debug(e);
        }
    }


	public class objResultWrapper {
		public string resultType { get; set; } 
		public ID objId { get; set; }
		public ID respid { get; set; }
		public Action_Skill_Result__c currResultS { get; set; }
		public Action_Narrative_Result__c currResultN { get; set; }
	
		public objResultWrapper( ) {
			resultType = null;
			objID = null;			
			respId = null;
			currResultS = null;
			currResultN = null;
		}
		
		public objResultWrapper( string resType, ID oID ) {
	
			objID = oID;
			respid = null;
			resultType = resType;
			if ( resultType == 'Narrative') {
				currResultN = new Action_Narrative_Result__c ( action_plan_objective__c = objID );
				currResultS = null;
			}
			if ( resultType == 'Skill' ) {
				currResultS = new Action_Skill_Result__c (action_plan_objective__c = objID, 
														day__c = datetime.now().date());
				currResultN = null;
			}
		}
		
		
		public objResultWrapper( ID oid, ID id, string rt, SObject obj) {
			objID = oid;
			respid = id;
			resultType = rt;
			if ( rt == 'Narrative' ) 
				currResultN = (Action_Narrative_Result__c)obj;
			if ( rt == 'Skill')
				currResultS = (Action_Skill_Result__c)obj;
		}
	}
	
	// Behavior tracking elements
	// taken largely from BehaviorTracking.cls
	private List<Table> privateTables;
	public List<Table> Tables {
	get {
		if (privateTables == null) {
			privateTables = calcTables();
		}
		return privateTables;
	}}
	
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
	
	private List<Action_Plan_Objective__c > privateobjectives;
	private Action_Plan_Objective__c currentobjective; 
    @TestVisible private List<Table>  calcTables(){
		Date firstDay = shiftStart.Date();
		Date lastDay = getMinDateTime(shiftEnd, DateTime.Now()).date();
		privateobjectives = new List<Action_Plan_Objective__c>{ thisObj };
		
		List<Table> out = new List<Table>();
		currentobjective = thisObj; 
		
		if (currentObjective == null){
			if (privateObjectives.size() == 0){
				return out;
			}
			currentObjective = privateObjectives[0];
		}

		out.Add(GenerateObjectiveTable(currentObjective, firstDay, lastDay));
		return out;
	}

	private Table GenerateObjectiveTable(Action_Plan_Objective__c objective, Date firstDay, Date lastDay){
		Table t1 = new Table(getHoursOfDay(), getDaysToDisplay());
		system.debug( 'OBJECTIVE INSIDE GENERATE TABLE:' + objective);
		t1.ObjectiveDescription = objective.Description__c;
		t1.ObjectiveId = objective.Id;
		system.debug('this objective type is:' + objective.type__c);
		t1.IsTimeBased = IsTimeBased(objective);
		system.debug(logginglevel.warn, objective.Action_Behavior_Results__r.size());
		for(Action_Behavior_Result__c result: ResultsForObjective(objective, firstday)){
			system.debug( result);
			t1.Put(result.Day_time__c.Time().hour(),result.Day_time__c.Date(), result);
		}
		for( integer timeofday : t1.FirstKeys){
			for(Date day: getdaysofmonth()){
				if ((!t1.Active(timeofday, day)) && TimeValidForObjectiveAndPlanAndShift(day, timeofday, objective)){
					Action_Behavior_Result__c blankResult = new Action_Behavior_Result__c();
					blankResult.Action_Plan_Objective__c = objective.Id;
					blankresult.Day_time__c = DateTime.newinstance(day, Time.newInstance(timeofday,0,0,0));
//					system.debug( blankresult.Day_time__c);
					t1.Put(timeofday, day, blankResult);
				}
			}
		}
		return t1;
	}

	public boolean DateValidForObjectiveAndPlan(Date day, Action_Plan_Objective__c objective){
		return ((objective.Effective_Date__c == null) || (day >= objective.Effective_Date__c)) &&
				((objective.Target_End_Date__c == null) || (day <= objective.Target_End_Date__c));
	}
	
	public boolean TimeValidForObjectiveAndPlanAndShift (Date day, Integer tofd, Action_Plan_Objective__c objective){
		
		Datetime thisdt = DateTime.newinstance(day, Time.newInstance(tofd,0,0,0));
		Datetime startdt = DateTime.newinstance(shiftstart.date(), Time.newInstance(shiftstart.hour(), 0,0,0));
		
		// check if this element is available for editing during the shift
		return ( ((objective.Effective_Date__c == null) || ( day >= objective.Effective_date__c )) &&
				( thisdt >= startdt ) &&
				((objective.Target_End_Date__c == null) || (day <= objective.Target_End_Date__c)) &&
				( thisdt <= DateTime.now())
				);
	}
	
	private List<Action_Behavior_Result__c> ResultsForObjective(Action_Plan_Objective__c objective, Date firstDay){
		return [select Day_time__c, Occurrences__c, Occurred__c, LastModifiedById, LastModifiedDate
						from Action_Behavior_Result__c
						where Action_Plan_Objective__c = :thisobj.id
							and Day_time__c >= :shiftStart.Date()
						order by Day_time__c];
	}

	private Map<id, Action_Behavior_Result__c> ResultMap(Date firstDay){
		Map<id, Action_Behavior_Result__c> origData = new Map<id, Action_Behavior_Result__c>();
			for(Action_Behavior_Result__c result: ResultsForObjective(thisObj, firstDay)){
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
				system.debug( 'on end date this is time:' + endDateTime.time());
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

	private boolean IsTimeBased(Action_Plan_Objective__c objective){
		return objective.Type__c == 'Behavior - Duration';
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
	
	public PageReference saveBehavior(){
		List<Action_Behavior_Result__c> toUpDate = new List<Action_Behavior_Result__c>();
		Map<id, Action_Behavior_Result__c> origData = ResultMap(shiftStart.Date());
		for(Table table: Tables){
			for(integer hour:table.Firstkeys){
				for(Date day : table.AllSecondKeys){
					Action_Behavior_Result__c cellObj = table.get(hour,day);
					if (cellObj == null){
						continue;
					}
					if (origData.containsKey(cellObj.Id)){
						Action_Behavior_Result__c origObj = origData.get(cellObj.Id);
						if (cellObj.Occurrences__c != origObj.Occurrences__c ||
							cellObj.Occurred__c != origObj.Occurred__c){
							toUpDate.Add(cellObj);
						}
					} else {
						if (cellObj.Occurrences__c != null ||
							cellObj.Occurred__c != false){
							toUpDate.Add(cellobj);
						}
					}
				}
			}
		}
		system.debug( toUpdate);
		upsert toUpdate;
		
		for (Table table: Tables ) {
			for(Action_Behavior_Result__c result: ResultsForObjective(thisObj, shiftStart.Date())){
				table.Put(result.Day_time__c.Time().hour(),result.Day_time__c.Date(), result);
			}
		}

		return null;
	}
	
	

}