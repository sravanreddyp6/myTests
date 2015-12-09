public without sharing class DSP_BehaviorTracking {
	
	public Date startdate { get; set; } 
	public Action_Plan_Worksheet__c result;
	private APOWrapper currentObjective;
	public ID APId { get; private set;}
	public id currentObjectiveid {get;set;}
	public List<APOWrapper> Objectives { get; set; }
	public ID wsID { get; set; }
	public Map<ID, ABRWrapper> originalData { get; set; }

	public DSP_BehaviorTracking( TxnQueueResponseController c ){

	}

	public DSP_BehaviorTracking( ID wsID, ID objID)
	{
		result = [select Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
                     Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
                     Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c 
                    from Action_Plan_Worksheet__c
                    where Id = :wsId];
                    
        if ( result != null ) {            
        	APId = result.action_plan__c;
        	startdate = result.start_date__c;
        	this.wsID = wsID;
        }
        
		currentObjectiveid = objID;
		system.debug( result.start_date__c );
		
		privateTables = calcTables();
		originalData = ResultMap( result.start_date__c);
		
	}

	public boolean editable { get { return !result.Action_plan__r.Status__c.contains('Inactive');}}

	private List<Table>  calcTables(){
		Date firstDay = result.Start_Date__c;
		objectives = ReportableBehaviorObjectives(firstDay);
		List<Table> out = new List<Table>();

		for(APOWrapper o: objectives){
			if (currentObjectiveId == o.Id){
				currentObjective = o;
				break;
			}
		}
		if (currentObjective == null){
			if (objectives.size() == 0){
				return out;
			}
			currentObjective = objectives[0];
			currentObjectiveID = currentObjective.id;
		}

		out.Add(GenerateObjectiveTable(currentObjective, firstDay));
		return out;
	}

	private Table GenerateObjectiveTable(APOWrapper objective, Date firstDay){
		Table t1 = new Table(getHoursOfDay(), getDaysToDisplay());
		t1.ObjectiveDescription = objective.Description;
		t1.ObjectiveId = objective.Id;
		t1.IsTimeBased = IsTimeBased(objective);
		
		for(Action_Behavior_Result__c result: ResultsForObjective(objective, firstday)){
			t1.Put(result.Day_time__c.TimeGMT().hour(), result.Day_time__c.DateGMT(), new ABRWrapper(result));
		}
		for( integer timeofday : t1.FirstKeys){
			for(Date day: getdaysofmonth()){
				if ((!t1.Active(timeofday, day)) && DateValidForObjectiveAndPlan(day, objective)){
					ABRWrapper blankResult = new ABRWrapper ();
					blankResult.oid = objective.Id;
					blankresult.daytime = DateTime.newinstanceGMT(day, Time.newInstance(timeofday,0,0,0));
					t1.Put(timeofday, day, blankresult);
				}
			}
		}
		return t1;
	}

	public List<Date> getDaysToDisplay() {
		List<Date> month = new List<Date>();
		Date startDate = (result.Start_Date__c - 1).toStartofWeek()+1; // we start on Monday
		Date endDate = StartDate.addDays(42);
		system.debug('START, END:' + startDate + ' ' + endDate + this.startdate);
		
		for(Date dateiter = StartDate; dateiter < endDate; dateiter = dateiter+1){
			month.Add(dateiter);
		}
		system.debug('DATES:' + month);
		return month;
	}

	public List<Date> getDaysOfMonth() {
		List<Date> month = new List<Date>();
		Date endDate = result.Start_Date__c.addmonths(1).toStartofMonth();
		system.debug(result.Start_Date__c.addmonths(1));
		system.debug(result.Start_Date__c.addmonths(1).toStartofMonth());
		for(Date dateiter = result.Start_Date__c.toStartofMonth(); dateiter < endDate; dateiter = dateiter+1){
			month.Add(dateiter);
		}
		return month;
	}

	public List<integer> getHoursOfDay() {
		List<integer> hours = new List<integer>();
		for(integer ii = 0; ii < 24 ; ii++){
			hours.Add(ii);
		}
		return hours;
	}

	private boolean IsTimeBased(APOWrapper objective){
		return objective.oType == 'Behavior - Duration';
	}

	private List<APOWrapper> ReportableBehaviorObjectives(Date firstDay){
		List<Action_Plan_objective__c> objs = [ select Description__c, effective_Date__c, Target_end_date__c, Type__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__c = :result.Action_Plan__c
					and ((effective_date__c < :firstDay.addMonths(1)) or (effective_date__c = null))
					and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
					and (Type__c = 'Behavior - Count' or Type__c = 'Behavior - Duration')
					and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
		
		List<APOWrapper> objwraplist = new List<APOWrapper>();
				
		for (Action_Plan_Objective__c o : objs ) {
			objwraplist.add(new APOWrapper(o));
		}
		return objwraplist;
	}

	private List<Action_Behavior_Result__c> ResultsForObjective(APOWrapper objective, Date firstDay){
		return [select Day_time__c, Occurrences__c, Occurred__c, action_plan_objective__c
						from Action_Behavior_Result__c
						where Action_Plan_Objective__c = :objective.id
							and Day_time__c >= :firstDay
							and Day_time__c < :firstDay.addmonths(1)
						order by Day_time__c];
	}

	private Map<id, ABRWrapper> ResultMap(Date firstDay){
		Map<id, ABRWrapper> origData = new Map<id, ABRWrapper>();
		for(APOWrapper objective: objectives){
			if (objective.id == currentObjectiveId){
				for(Action_Behavior_Result__c result: ResultsForObjective(objective, firstDay)){
					origData.Put(result.id, new ABRWrapper(result));
				}
			}
		}
		return origData;
	}
	public boolean DateValidForObjectiveAndPlan(Date day, APOWrapper objective){
		return ((objective.Effective_Date == null) || (day >= objective.Effective_Date)) &&
				((objective.Target_End_Date == null) || (day <= objective.Target_End_Date));
	}


	// transient - 1/2 the size of viewstate
	private transient List<Table> privateTables;
	public List<Table> Tables {
	get {
		if (privateTables == null) {
			privateTables = calcTables();
		}
		return privateTables;
	}}

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

		public void Put(integer tofd, Date day, ABRWrapper value){
			myRows.get(tofd).put(day, value);
		}

		public ABRWrapper Get(integer tofd, Date day){
			return myRows.get(tofd).get(day);
		}

		public boolean Active(integer tofd, Date  day) {
			system.debug('Table Access:' + day);
			return myRows.get(tofd).getItems().get(day).Active;
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
			myhour = DateTime.newInstanceGMT(Date.Today(), Time.newInstance(hour, 0,0,0)).formatGMT('ha');
			for(Date day: alldays){
				myItems.Put(day, new Action_Behavior_Wrapper(hour, day, (ABRWrapper) null));
			}
		}

		public string getHeader(){
			return myhour;
		}
		public void Put(Date day, ABRWrapper item){
			Action_Behavior_Wrapper wrap = myItems.get(day);
			wrap.DataObject = item;
		}

		public ABRWrapper Get(Date day){
			Action_Behavior_Wrapper wrap = myItems.get(day);
			return wrap.DataObject;
		}

	}

	public class Action_Behavior_Wrapper {
		public ABRWrapper myObject;
		public integer mytime;
		public Date myDate { get; set; }
		public boolean Active {get{ return myObject <> null;}}

		/*****
		** Needed if the timezone ever springs forward causing 2am to become 3am
		**        public boolean Active {get{ return myObject <> null && !missinghour;}}
		**        private boolean missinghour;
		******/
		public Action_Behavior_Wrapper(integer tofd, Date day, Action_Behavior_Result__c obj){
			if ( obj != null )
				myobject = new ABRWrapper(obj);
			mytime = tofd;
			myDate = day;
		}
		public Action_Behavior_Wrapper(integer tofd, Date day, ABRWrapper obj){
			if ( obj != null )
				myobject = obj;
			mytime = tofd;
			myDate = day;
		}
		
		public Action_Behavior_Wrapper(Action_Behavior_Result__c obj){
			if ( obj != null ) {
				myobject = new ABRWrapper(obj);
				mytime = obj.day_time__c.TimeGMT().hour();
				myDate = obj.day_time__c.DateGMT();
			}
		}


		public ABRWrapper DataObject{
			get { return myObject;}
			set { myObject = value;}
		}

		public string getDayOfWeek(){
			return DateTime.newInstanceGMT(myDate, Time.newInstance(0,0,0,0)).formatGMT('E');
		}
		
		
	}

    public class DSPObjectiveWrapper {
    	public APOWrapper objective { get; set; }
    	public Map<Date, ABRWrapper> ResultsMap { get; set; }
    	
    	public DSPObjectiveWrapper ( Action_Plan_Objective__c obj ) {
    		objective = new APOWrapper(obj);
    	}
    	
    }
    
    public Class APOWrapper  {
    	
    	public ID id { get; set; }
    	public string Description { get; set; }
    	public string otype { get; set; }
    	public date effective_date { get; set; }
    	public date target_end_date { get; set; }
    	
    	public APOWrapper ( Action_Plan_Objective__c apo ) {
    		id = apo.id;
    		description = apo.description__c;
    		otype = apo.type__c;
    		effective_date = apo.effective_Date__c;
    		target_end_date = apo.target_end_date__c;
    	}
    	
    }
    
    Public class ABRWrapper {
    	
    	public ID oid { get; set; }
    	public ID id { get; set; }
    	public Decimal occurrences { get; set;}
    	public String strnumoccurred;	// need this otherwise submit from front end defaults all values to 0
    	public Boolean occurred { get; set; }
    	public Datetime daytime { get; set; }
    	public ABRWrapper () {}	
    	
    	public void setstrnumoccurred (string value) {
    		 if ( !String.IsEmpty(value)) occurrences = decimal.valueof( value);
    	}
    	
    	public string getstrnumoccurred () {
    		 return (occurrences == null ) ? null : string.valueof( occurrences); 
    	}
    	public ABRWrapper ( Action_Behavior_Result__c abr ) {
    		oid = abr.action_plan_objective__c;
    		id = abr.id;
    		occurrences = abr.occurrences__c;
    		occurred = abr.occurred__c;
    		daytime = abr.day_time__c;
    	}
    	
    }

}