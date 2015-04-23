public with sharing class GoalObjRepeaters {
	public ID saID { get; set; }
	public datetime shiftStart { get; set; }
	public datetime shiftEnd { get; set; }
	public string selectedObj { get; set; }
	
	public GoalObjRepeaters () {
		fullObjectiveList = new List<SelectOption>();
		//objsByType = new Map<string, List<objWrapper>>();
	}

	public final List<String> objTypes;
	public map <String, List<objWrapper>> objsByType { get { return getObjsbyType();} set; }
	public List<SelectOption> fullObjectiveList;
	public List<Action_Plan_Objective__c> objs { get; set;}
	
	public Map<string, List<objWrapper>> getObjsByType() {
		Map<string, List<objWrapper>> ot = new Map<string, List<objWrapper>>();
		if ( shiftStart == null )
			shiftStart = datetime.now();
		objs = new List<Action_Plan_objective__c>();
		objWrapper objw;
		List<objWrapper> objs = new List<objWrapper>();
					
		SelectOption so;
		for ( Action_Plan_objective__c o : ReportableBehaviorCObjectives( shiftStart.Date())) {
		
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableBehaviorDObjectives( shiftStart.Date())) {
			
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableSkillObjectives( shiftStart.Date())) {
			
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
		
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableNarrativeObjectives( shiftStart.Date())) {
			
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
		
		system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
		ot.put( objw.objtype, objs);
		}
		
		system.debug( 'Objectives by type: ' + ot);
		return ot;
	}


	public List<String> getObjTypes() {
		
		Date firstday = shiftStart.Date();
		List<AggregateResult> ag = [ select type__c, count(id) from action_plan_objective__c 
									where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
									and ((effective_date__c < :firstDay) or (effective_date__c = null))
									and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
									and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
									and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
									group by type__c
									order by type__c];
		
		List<String> t = new List<String>();
		for (AggregateResult a : ag) {
			t.Add( (string)a.get('type__c'));
		}
		return t;
		
	}
	private boolean IsTimeBased(Action_Plan_Objective__c objective){
		return objective.Type__c == 'Behavior - Duration';
	}
	
	private List<Action_Plan_Objective__c> ReportableBehaviorCObjectives(Date firstDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and ((effective_date__c < :firstDay) or (effective_date__c = null))
					and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
					and Type__c = 'Behavior - Count'
					and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
					and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
	}
	
	private List<Action_Plan_Objective__c> ReportableBehaviorDObjectives(Date firstDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and ((effective_date__c < :firstDay) or (effective_date__c = null))
					and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
					and Type__c = 'Behavior - Duration'
					and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
					and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
	}

	private List<Action_Plan_Objective__c> ReportableSkillObjectives(Date firstDay){
        return [ select id, Description__c, effective_Date__c, Target_end_date__c, type__c, status__c,
                        (select Day__c, Attempts__c, Initials__c, Met_Objective__c, Status__c
                           from Action_Skill_Results__r
                          where Day__c >= :firstDay 
                            and Day__c < :firstDay + 7
                          order by Day__c)
                   from  Action_Plan_Objective__c
                  where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
                    and ((effective_date__c < :firstDay + 7) or (effective_date__c = null))
                    and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
                    and Type__c = 'Skill'
                    and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
                    and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
                  order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
    }
    

	private List<Action_Plan_Objective__c> ReportableNarrativeObjectives(Date firstDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and ((effective_date__c < :firstDay) or (effective_date__c = null))
					and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
					and (Type__c = 'Narrative' )
					and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
					and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
	}
	
	public class objWrapper  {
		public ID Id { get; private set; }
		public string shortDesc { get; private set; }
		public string fullDesc { get; private set; }
		public datetime dtstart { get; private set; }
		public datetime dtend { get; private set; }
		public string objType { get; private set; }
		public string status {get; private set; }
		
		
		public objWrapper( ID id, String description, datetime effdate, datetime targetdate, string otype, string status) {
			this.id = id;
			this.shortdesc = description.left(Math.min(description.length(), 47));
			if ( description.length() > 47)
				this.shortdesc += '...';
			this.fullDesc = description;
			this.dtstart = effdate;
			this.dtend = targetdate;
			this.objType = otype;
			this.status = status;
		}
	}
}