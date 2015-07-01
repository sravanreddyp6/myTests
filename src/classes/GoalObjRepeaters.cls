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
	public map <String, List<objWrapper>> objsByType { get { if ( objsByType == null ) objsByType = getObjsByType(); return objsByType;} set; }
	public List<SelectOption> fullObjectiveList;
	public List<Action_Plan_Objective__c> objs { get; set;}
	
	private Map<string, List<objWrapper>> getObjsByType() {
		Map<string, List<objWrapper>> ot = new Map<string, List<objWrapper>>();
		if ( shiftStart == null )
			shiftStart = datetime.now();
		objs = new List<Action_Plan_objective__c>();
		objWrapper objw;
		List<objWrapper> objs = new List<objWrapper>();
					
		SelectOption so;
		for ( Action_Plan_objective__c o : ReportableBehaviorCObjectives( shiftStart.Date(), shiftEnd.Date())) {
			
			// EC-197 do not show a link for blank descriptions
			if ( string.isblank( o.description__c ))
				continue;
			
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		// reset temp objects
		objw = null;	
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableBehaviorDObjectives( shiftStart.Date(), shiftEnd.Date())) {
			// EC-197 do not show a link for blank descriptions
			if ( string.isblank( o.description__c ))
				continue;
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		
		// reset temp objects
		objw = null;	
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableSkillObjectives( shiftStart.Date(), shiftEnd.Date())) {
			// EC-197 do not show a link for blank descriptions
			if ( string.isblank( o.description__c ))
				continue;
			objw = new objWrapper( o.id, o.description__c, o.effective_date__c, o.target_end_date__c, o.type__c, o.status__c);	
			objs.Add( objw );
		}
		// store all the items for this type
		if ( objw != null ) {
		
			system.debug( 'storing in type: ' + objw.objtype + ':' + objs);
			ot.put( objw.objtype, objs);
		}
		// reset temp objects
		objw = null;	
		objs = new List<objWrapper>();
		
		for ( Action_Plan_objective__c o : ReportableNarrativeObjectives( shiftStart.Date(), shiftEnd.Date())) {
			// EC-197 do not show a link for blank descriptions
			if ( string.isblank( o.description__c ))
				continue;
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


	public set<String> getObjTypes() {
		
		if ( objsByType == null ) {
			objsByType = getObjsByType();
		}
		
		return objsByType.keyset();
		
	}
	private boolean IsTimeBased(Action_Plan_Objective__c objective){
		return objective.Type__c == 'Behavior - Duration';
	}
	
	private List<Action_Plan_Objective__c> ReportableBehaviorCObjectives(Date firstDay, Date lastDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
				and (
					(effective_date__c > :firstDay  and effective_date__c <= :lastDay)
										  or
					(effective_date__c <= :firstDay and target_end_date__c >= :firstday ) 
				)					
				and Type__c = 'Behavior - Count'
				and Status__c in ('In Progress', 'Revised', 'New')
				and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
	}
	
	private List<Action_Plan_Objective__c> ReportableBehaviorDObjectives(Date firstDay, Date lastDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and (
					 (effective_date__c > :firstDay  and effective_date__c <= :lastDay)
					 or
					(effective_date__c <= :firstDay and target_end_date__c >= :firstday ) 
					)	
					and Type__c = 'Behavior - Duration'
					and Status__c in ('In Progress', 'Revised', 'New')
					and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
				order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
	}

	private List<Action_Plan_Objective__c> ReportableSkillObjectives(Date firstDay, Date lastDay){
        return [ select id, Description__c, effective_Date__c, Target_end_date__c, type__c, status__c
                   from  Action_Plan_Objective__c
                  where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and (
					 (effective_date__c > :firstDay  and effective_date__c <= :lastDay)
					  or
					(effective_date__c <= :firstDay and target_end_date__c >= :firstday ) 
					)	                    
					and Type__c = 'Skill'
                    and Status__c in ('In Progress', 'Revised', 'New')
                    and action_plan_goal__r.action_plan__r.status__c = 'Active Final'
                  order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
    }
    

	private List<Action_Plan_Objective__c> ReportableNarrativeObjectives(Date firstDay, Date lastDay){
		return [ select id, Description__c, effective_Date__c, Target_end_date__c, Type__c, status__c
				from  Action_Plan_Objective__c
				where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
					and (
					 (effective_date__c > :firstDay  and effective_date__c <= :lastDay)
					or
					(effective_date__c <= :firstDay and target_end_date__c >= :firstday ) 
					)						
					and (Type__c = 'Narrative' )
					and Status__c in ('In Progress', 'Revised', 'New')
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
			
			// EC-197 - this should never happen but if it does, protect against exception
			if ( String.isBlank( description))
				description='No description provided';
				
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