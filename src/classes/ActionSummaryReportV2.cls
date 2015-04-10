public with sharing class ActionSummaryReportV2 {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController controller { get; set; }
	public String action { get; set; }

	// This map contains the link between the type of the objective, the parent
	// objective and all of its revised descendents (no matter how many degree
	// of separations). The list also contains the parent objective itself
	public Map<String, Map<Id, List<Objective>>> objectiveMap { get; set; }

	public Map<Id, OtherSummaryResult> otherSummaryResultMap { get; set; }

	public List<SelectOption> recommendationOptions {
		get {
			if (recommendationOptions != null) {
				return recommendationOptions;
			}
			Schema.sObjectType sobject_type = action_summary__c.getSObjectType();
			Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
			Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
			List<Schema.PicklistEntry> pick_list_values = field_map.get('recommendation__c').getDescribe().getPickListValues();
			recommendationOptions = new List<selectOption>();
			for (Schema.PicklistEntry a : pick_list_values) {
				recommendationOptions.add(new selectOption(a.getLabel(), a.getValue()));
			}
			return recommendationOptions;
		}
		set;
	}

	public ActionSummaryReportV2(ApexPages.standardController controller) {
		this.controller = controller;
		summary = (Action_Summary__c) controller.getRecord();

		objectiveMap = new Map<String, Map<Id, List<Objective>>>();

		action = ApexPages.currentPage().getParameters().get('action');
		if (action == '' || action == null) {
			action = 'edit';
		}
		Map<Id, Action_Plan_Objective__c> objectives;
		if (summary.Status__c != 'Final') {
			objectives = new Map<Id, Action_Plan_Objective__c>([
				SELECT Id, Former_Id__c, Type__c, Status__c, Description__c,
				       CreatedDate, Effective_Date__c, Target_End_Date__c,
				       (SELECT met_objective__c , Day__c, attempts__c
				          FROM Action_skill_results__r
				         WHERE Day__c <= :summary.End_Date__c
				           AND Day__c >= :summary.Start_Date__c),
				       (SELECT Day_time__c , Occurrences__c, Occurred__c
				          FROM Action_Behavior_results__r
				         WHERE Day_time__c <= :summary.End_Date__c
				           AND Day_time__c >= :summary.Start_Date__c),
				       (SELECT comment__c, recommendation__c, met_objective_count__c, not_met_count__c, occurrences__c
				          FROM Objective_Summary_Comments__r
				         WHERE Action_Summary__c = :summary.Id)
				  FROM Action_Plan_Objective__c
				 WHERE Effective_Date__c <= :summary.End_Date__c
				   AND Target_End_Date__c >= :summary.Start_Date__c
				   AND action_plan_goal__r.action_plan__r.Service_Assignment__c = :summary.Service_Assignment__c
				   AND (action_plan_goal__r.action_plan__r.Status__c = 'Inactive Final'
				    OR action_plan_goal__r.action_plan__r.Status__c = 'Active Final')
				   AND action_plan_goal__r.action_plan__r.Effective_Date__c < :summary.End_Date__c
				   AND action_plan_goal__r.action_plan__r.Target_Date__c >= :summary.Start_Date__c
				ORDER BY action_plan_goal__r.action_plan__c,
				         action_plan_goal__r.sort_order__c, action_plan_goal__c,
				         sort_order__c
			]);
		}
		Set<Id> allTopLevelObjectives = new Set<Id>();
		for (Id objectiveId: objectives.keySet()) {
			if (!objectiveMap.containsKey(objectives.get(objectiveId).Type__c)) {
				objectiveMap.put(objectives.get(objectiveId).Type__c, new Map<Id, List<Objective>>());
			}
			Map<Id, List<Objective>> objectiveParentToChildrenMap = objectiveMap.get(objectives.get(objectiveId).Type__c);
			Id parentObjectiveId = findParentObjective(objectives.get(objectiveId), objectives);
			allTopLevelObjectives.add(parentObjectiveId);
			if (!objectiveParentToChildrenMap.containsKey(parentObjectiveId)) {
				objectiveParentToChildrenMap.put(parentObjectiveId, new List<Objective>());
			}
			objectiveParentToChildrenMap.get(parentObjectiveId).add(new Objective(objectives.get(objectiveId)));
		}
		// Sort all the objectives
		for (String type: objectiveMap.keySet()) {
			for (Id topLevelObjectiveId: objectiveMap.get(type).keySet()) {
				List<Objective> objs = objectiveMap.get(type).get(topLevelObjectiveId);
				objs.sort();
				// Determine whether to highlight a row or not
				if (objs.size() > 1 && objs[objs.size() - 1].isDifferentFrom(objs[objs.size() - 2])) {
					objs[objs.size() - 1].highlight = true;
				}
			}
		}
		otherSummaryResultMap = new Map<Id, OtherSummaryResult>();
		Action_Plan_Summary_Result__c[] results = [
			SELECT Id, Type__c, Data__c, Action_Plan_Objective__c
			  FROM Action_Plan_Summary_Result__c
			 WHERE Action_Plan_Objective__c IN :allTopLevelObjectives
		];
		for (Action_Plan_Summary_Result__c result: results) {
			if (result.Type__c == 'Recommendation') {
				otherSummaryResultMap.put(result.Action_Plan_Objective__c,
					new OtherSummaryResult(result));
			}
		}
		for (Id topLevelObjective: allTopLevelObjectives) {
			if (!otherSummaryResultMap.containsKey(topLevelObjective)) {
				otherSummaryResultMap.put(topLevelObjective,
					new OtherSummaryResult(topLevelObjective));
			}
		}
	}

	private Id findParentObjective(Action_Plan_Objective__c objective, Map<Id, Action_Plan_Objective__c> objectives) {
		String parentObjectiveId = objectives.get(objective.Id).Former_ID__c;
		// Apparently when this field is set, it'll be set to a valid SF Id
		// if it's a revised objective, and take the form zo*** if it's not a
		// revised objective
		Boolean isValidId = (parentObjectiveId instanceOf ID) ? true : false;
		if (parentObjectiveId != null && isValidId && objectives.get(parentObjectiveId).Type__c == objective.Type__c) {
			return findParentObjective(objectives.get(parentObjectiveId), objectives);
		}
		// Return own id if this is not a revised objective
		return objective.Id;
	}

	public PageReference save() {
		if (summary.Status__c == 'Final') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot update a final summary.'));
			return null;
		}
		List<Action_Plan_Summary_Result__c> resultsToUpdate = new List<Action_Plan_Summary_Result__c>();
		for (Id topLevelObjectiveId: otherSummaryResultMap.keySet()) {
			OtherSummaryResult result = otherSummaryResultMap.get(topLevelObjectiveId);
			if ((result.recommendation != null && result.recommendation != '') || (result.comment != null && result.comment != '')) {
				result.updateData();
				resultsToUpdate.add(result.resultSObject);
			}
		}
		upsert resultsToUpdate;
		update summary;
		return null;
	}

	//////////////////////
	// The wrapper classes
	//////////////////////
	public abstract class ObjectiveResult {
		public Action_plan_objective__c objective { get; set; }
		public Objective_Summary_Comment__c Objective_Comment { get; set; }
		public List<Objective_Summary_Comment__c> OtherSummaryComments { get; set; }
		public ObjectiveSkillResult AsSkillResult {
			get {
				return (ObjectiveSkillResult) this;
			}
		}
		public ObjectiveBehaviorResult AsBehaviorResult {
			get {
				return (ObjectiveBehaviorResult) this;
			}
		}

		public boolean OtherSummaryCommentsExist {
			get {
				return OtherSummaryComments != null && !(OtherSummaryComments.isEmpty());
			}
		}

		public ObjectiveResult(Action_plan_objective__c objective, Action_Summary__c summary) {
			this.objective = objective;
			if (!objective.Objective_Summary_Comments__r.isEmpty()) {
				Objective_Comment = objective.Objective_Summary_Comments__r[0];
			} else {
				Objective_Comment = new Objective_Summary_Comment__c();
				Objective_Comment.Action_Plan_Objective__c = objective.Id;
				Objective_Comment.Action_summary__c = summary.Id;

			}
		}
		public virtual boolean getIsSkill() {
			return objective.Type__c == 'Skill';
		}
		public virtual boolean getIsOccurrenceBehavior() {
			return objective.Type__c == 'Behavior - Count';
		}
		public virtual boolean getIsTimeBehavior() {
			return objective.Type__c == 'Behavior - Duration';
		}

		public virtual void Finalize() {
		}
	}

	public class ObjectiveSkillResult extends ObjectiveResult{
		public integer MetCount { get; private set; }
		public integer NotMetCount { get; private set; }
		public integer TrialCount {
			get {
				return MetCount + NotMetCount;
			}
		}
		public integer PercentMet {
			get {
				return (MetCount * 100)/TrialCount;
			}
		}

		public ObjectiveSkillResult(Action_plan_objective__c objective, Action_Summary__c summary) {
			super(objective, summary);
			MetCount = 0;
			NotMetCount = 0;
			for(Action_skill_result__c result: objective.Action_skill_results__r) {
				if (result.Met_Objective__c == 'y') {
					MetCount++;
				}
				if (result.Met_Objective__c == 'n') {
					NotMetCount++;
				}
			}
		}

		public override void Finalize() {
			Objective_Comment.Met_Objective_count__c = Metcount;
			Objective_Comment.Not_Met_count__c = NotMetCount;
		}
	}

	public class ObjectiveBehaviorResult extends ObjectiveResult {
		public ObjectiveBehaviorResult(Action_plan_objective__c objective, Action_Summary__c summary) {
			super(objective, summary);
			Occurrences = 0;
			for(Action_behavior_result__c result: objective.Action_Behavior_results__r) {
				system.debug(result.Occurrences__c);
				Occurrences += result.Occurrences__c == null ? 0 : result.Occurrences__c.intValue();
			}
		}

		public integer Occurrences {get;set;}

		public override void Finalize() {
			Objective_Comment.Occurrences__c = Occurrences;
		}
	}

	public class ActionPlan {
		public Action_Plan__c ActionPlan { get; set; }
		public List<ActionPlanGoal> ActionPlanGoals { get; set; }

		public string FormattedEffectiveDate {
			get {
				return DateTime.newInstance(ActionPlan.Effective_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
			}
		}

		public string FormattedTargetDate {
			get {
				return DateTime.newInstance(ActionPlan.Target_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
			}
		}

		public ActionPlan(Action_Plan__c plan) {
			ActionPlan = plan;
			ActionPlanGoals = new List<ActionPlanGoal>();
		}
	}

	public class ActionPlanGoal {
		public Action_Plan_Goal__c ActionPlanGoal {get;set;}
		public List<ObjectiveResult> ActionPlanObjectives {get;set;}

		public ActionPlanGoal(Action_Plan_Goal__c goal) {
			ActionPlanGoal = goal;
			ActionPlanObjectives = new List<ObjectiveResult>();
		}
	}

	public class Objective implements Comparable {
		public Action_Plan_Objective__c objectiveSObject { get; set; }
		public Boolean highlight { get; set; }

		public Objective(Action_Plan_Objective__c objectiveSObject) {
			this.objectiveSObject = objectiveSObject;
			this.highlight = false;
		}

		public Integer compareTo(Object anotherObjective) {
			Objective obj2 = (Objective) anotherObjective;
			if (this.objectiveSObject.CreatedDate > obj2.objectiveSObject.CreatedDate) {
				return 1;
			} else {
				return -1;
			}
		}

		public Boolean isDifferentFrom(Objective anotherObjective) {
			// Determine whether this objective is different from another
			// objective (meaning that the text/status/etc) is different, not
			// merely that it has been revised
			if (this.objectiveSObject.Description__c != anotherObjective.objectiveSObject.Description__c ||
			    this.objectiveSObject.Status__c != anotherObjective.objectiveSObject.Status__c) {
				return true;
			}
			return false;
		}
	}

	public class OtherSummaryResult {
		public Action_Plan_Summary_Result__c resultSObject { get; set; }
		public String recommendation { get; set; }
		public String comment { get; set; }

		public OtherSummaryResult(String recommendation, String comment) {
			// This constructor is only used for JSON (de-)serializing. Don't
			// use it for any other purpose
			this.recommendation = recommendation;
			this.comment = comment;
		}

		public OtherSummaryResult(Id objectiveId) {
			this.resultSObject = new Action_Plan_Summary_Result__c(
				Action_Plan_Objective__c = objectiveId,
				Type__c = 'Recommendation'
			);
		}
		public OtherSummaryResult(Action_Plan_Summary_Result__c resultSObject) {
			this.resultSObject = resultSObject;
			OtherSummaryResult r = (OtherSummaryResult) JSON.deserialize(
				resultSObject.Data__c, OtherSummaryResult.class
			);
			this.recommendation = r.recommendation;
			this.comment = r.comment;
		}
		public void updateData() {
			// Update the data field for the underlying Summary Result object
			this.resultSObject.Data__c = JSON.serialize(new OtherSummaryResult(
				this.recommendation, this.comment
			));
		}
	}
}