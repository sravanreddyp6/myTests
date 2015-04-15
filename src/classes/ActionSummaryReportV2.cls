public with sharing class ActionSummaryReportV2 {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController controller { get; set; }
	public String action { get; set; }

	// This map contains the link between the type of the objective, the parent
	// objective and all of its revised descendents (no matter how many degree
	// of separations). The list also contains the parent objective itself
	public Map<String, Map<Id, List<Objective>>> objectiveMap { get; set; }

	public Map<Id, RecommendationSummaryResult> recommendationSummaryResultMap { get; set; }
	public List<String> systemSummaryResultDomain { get; set; }
	public Map<String, SystemSummaryResult> systemSummaryResultMap { get; set; }

	public List<Seizure> seizures { get; set; }
	public List<IsolationEvent> isolationEvents { get; set; }
	public List<RestraintEvent> restraintEvents { get; set; }
	public List<VitalsDetail> vitalsDetails { get; set; }

	// Some constants for config purpose
	public Integer LIST_LIMIT { get { return 1; } }
	public String TABLE_WIDTH { get { return '80%'; } }

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

	public List<SelectOption> systemStatusOptions {
		get {
			return new List<SelectOption> {
				new SelectOption('No Notable Changes', 'No Notable Changes'),
				new SelectOption('Improved', 'Improved'),
				new SelectOption('Declined', 'Declined')
			};
		}
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
				       (SELECT Description__c, CreatedDate
				          FROM Action_Narrative_results__r
				         WHERE CreatedDate <= :summary.End_Date__c
				           AND CreatedDate >= :summary.Start_Date__c
				        ORDER BY CreatedDate),
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
			seizures = getSeizures(summary);
			isolationEvents = getIsolationEvents(summary);
			restraintEvents = getRestraintEvents(summary);
			vitalsDetails = getVitalsDetails(summary);
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
		recommendationSummaryResultMap = new Map<Id, RecommendationSummaryResult>();
		systemSummaryResultMap = new Map<String, SystemSummaryResult>();
		// Initialize system summary results
		systemSummaryResultDomain = new List<String> {
			'Diagnostics', 'Cardiopulmonary', 'GU/GI/Nutrition',
			'Skin/Body', 'Neurological', 'Muscle-Skeletal',
			'Psychosocial', 'Therapy/Rehab', 'Discharge Planning'
		};

		Action_Plan_Summary_Result__c[] results = [
			SELECT Id, Type__c, Data__c, Action_Plan_Summary__c
			  FROM Action_Plan_Summary_Result__c
			 WHERE Action_Plan_Summary__c = :summary.Id
		];
		for (Action_Plan_Summary_Result__c result: results) {
			if (result.Type__c == 'Recommendation') {
				RecommendationSummaryResult r = new RecommendationSummaryResult(result);
				recommendationSummaryResultMap.put(r.objectiveId, r);
			} else if (result.Type__c == 'System') {
				SystemSummaryResult r = new SystemSummaryResult(result);
				systemSummaryResultMap.put(r.domain, r);
			}
		}
		for (Id topLevelObjective: allTopLevelObjectives) {
			if (!recommendationSummaryResultMap.containsKey(topLevelObjective)) {
				recommendationSummaryResultMap.put(topLevelObjective,
					new RecommendationSummaryResult(summary.Id, topLevelObjective));
			}
		}

		for (String domain: systemSummaryResultDomain) {
			if (!systemSummaryResultMap.containsKey(domain)) {
				systemSummaryResultMap.put(domain, new SystemSummaryResult(summary.Id, domain));
			}
		}
		System.debug('systemSummaryResultMap: ' + systemSummaryResultMap);
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
		for (Id topLevelObjectiveId: recommendationSummaryResultMap.keySet()) {
			RecommendationSummaryResult result = recommendationSummaryResultMap.get(topLevelObjectiveId);
			if ((result.recommendation != null && result.recommendation != '') || (result.comment != null && result.comment != '')) {
				result.updateData();
				resultsToUpdate.add(result.resultSObject);
			}
		}
		for (String domain: systemSummaryResultMap.keySet()) {
			SystemSummaryResult result = systemSummaryResultMap.get(domain);
			if ((result.status != null && result.status != '') || (result.comment != null && result.comment != '')) {
				result.updateData();
				resultsToUpdate.add(result.resultSObject);
			}
		}
		upsert resultsToUpdate;
		update summary;
		return null;
	}
	/////////////////////////
	// Private helper methods
	/////////////////////////
	private List<Seizure> getSeizures(Action_Summary__c summary) {
		List<Seizure> tmpSeizures = new List<Seizure>();
		Id saId = summary.Service_Assignment__r.Id;
		String query =
			'SELECT Id, Start_DateTime__c, End_DateTime__c, Observed_By__c, ' +
			        'Observed_By__r.Name ' +
			'  FROM Seizure__c ' +
			' WHERE Service_Assignment__c = :saId ' +
			'ORDER BY CreatedDate ASC ';
		for (Seizure__c seizure: Database.query(query)) {
			tmpSeizures.add(new Seizure(seizure));
		}
		return tmpSeizures;
	}

	private List<IsolationEvent> getIsolationEvents(Action_Summary__c summary) {
		List<IsolationEvent> tmpIsolationEvents = new List<IsolationEvent>();
		Id saId = summary.Service_Assignment__r.Id;
		String query =
			'SELECT Id, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' +
			'       Isolation_Status__c, Isolation_Type__c ' +
			'  FROM Evaluation_Response__c ' +
			' WHERE RecordType.Name = \'Isolation Event\' ' +
			'   AND Service_Assignment__c = :saId ' +
			'ORDER BY CreatedDate ASC ';
		for (Evaluation_Response__c event: Database.query(query)) {
			tmpIsolationEvents.add(new IsolationEvent(event));
		}
		return tmpIsolationEvents;
	}

	private List<RestraintEvent> getRestraintEvents(Action_Summary__c summary) {
		List<RestraintEvent> restraintEvents = new List<RestraintEvent>();
		Id saId = summary.Service_Assignment__r.Id;
		String query =
			'SELECT Id, Shift_Start_Time__c, Shift_End_Time__c, Status__c, ' +
			'       (SELECT Id FROM Assessments__r ' +
			'         WHERE Status__c != \'Disregard\' ' +
			'         ORDER BY CreatedDate DESC) ' +
			'  FROM Evaluation__c ' +
			' WHERE ServiceAssignment__c = :saId' +
			'   AND RecordType.Name = \'RestraintEvent\' ' +
			'   AND (Shift_Start_Time__c != null OR Shift_End_Time__c != null) ' +
			'ORDER BY CreatedDate ASC ';
		Evaluation__c[] tmpRestraintEvents = Database.query(query);
		Map<Id, Id> assessmentEvaluationMap = new Map<Id, Id>();
		Map<Id, Decimal> evaluationScoreMap = new Map<Id, Decimal>();
		Set<Id> assessmentIds = new Set<Id>();
		for (Evaluation__c event: tmpRestraintEvents) {
			evaluationScoreMap.put(event.Id, null);
			if (event.Assessments__r.size() == 0) {
				continue;
			}
			assessmentIds.add(event.Assessments__r[0].Id);
			assessmentEvaluationMap.put(event.Assessments__r[0].Id, event.Id);
		}
		for (Assessment_Domain_Result__c result: [
				SELECT ID, Score__c, Assessment__c
				  FROM Assessment_Domain_Result__c
				 WHERE Assessment__c IN :assessmentIds
				   AND Assessment_Domain__r.Name = 'Restraint Questions'
			]) {
			evaluationScoreMap.put(assessmentEvaluationMap.get(result.Assessment__c), result.Score__c);
		}
		for (Evaluation__c event: tmpRestraintEvents) {
			restraintEvents.add(new RestraintEvent(event, evaluationScoreMap.get(event.Id)));
		}
		return restraintEvents;
	}

	private List<VitalsDetail> getVitalsDetails(Action_Summary__c summary) {
		Map<String, List<Eval_Value__c>> entryValuesMap = new Map<String, List<Eval_Value__c>>();

		// Because Eval_Value__c is not directly related to Evaluation__c (it
		// has a field called What_Id__c but it's not a look up field), we can't
		// use that relationship directly in a SOQL query. So this is a
		// workaround for that
		// Get all the Evaluation__c records for this service assignment
		Map<Id, Evaluation__c> evaluations = new Map<Id, Evaluation__c>([
			SELECT Id FROM Evaluation__c
			 WHERE ServiceAssignment__c = :summary.Service_Assignment__c
		]);
		for (Eval_Value__c value: [
				SELECT Id, Text_Under_250__c, Number_No_Decimal__c, Date_Time__c,
				       Eval_Section_Id__c, Eval__r.Field_Name__c
				  FROM Eval_Value__c
				 WHERE What_Id__c IN :evaluations.keySet()
				   AND Eval__r.Category__c = 'Diagnostics'
				   AND Eval__r.Sub_Category__c = 'Vitals Signs'
			]) {
			if (!entryValuesMap.containsKey(value.Eval_Section_Id__c)) {
				entryValuesMap.put(value.Eval_Section_Id__c, new List<Eval_Value__c>());
			}
			entryValuesMap.get(value.Eval_Section_Id__c).add(value);
		}
		List<VitalsDetail> vitalsDetails = new List<VitalsDetail>();
		for (String evalSectionId: entryValuesMap.keySet()) {
			vitalsDetails.add(new VitalsDetail(entryValuesMap.get(evalSectionId)));
		}
		vitalsDetails.sort();
		return vitalsDetails;
	}

	//////////////////////
	// The wrapper classes
	//////////////////////
	public abstract class ObjectiveResult {
		public Action_plan_objective__c objective { get; set; }

		public ObjectiveResult(Action_plan_objective__c objective) {
			this.objective = objective;
		}
	}

	public class ObjectiveSkillResults {
		public Action_plan_objective__c objective { get; set; }

		public transient List<Date> startDates { get; set; }
		public transient Map<Date, Integer> metObjectiveMap { get; set; }
		public transient Map<Date, Integer> notMetObjectiveMap { get; set; }
		public transient Map<Date, Integer> percentMetObjectiveMap { get; set; }


		public ObjectiveSkillResults(Action_plan_objective__c objective) {
			this.objective = objective;
			metObjectiveMap = new Map<Date, Integer>();
			notMetObjectiveMap = new Map<Date, Integer>();
			percentMetObjectiveMap = new Map<Date, Integer>();
			startDates = new List<Date>();
			Set<Date> startDateSet = new Set<Date>();

			for(Action_skill_result__c result: objective.Action_skill_results__r) {
				Date startMonth = Date.newInstance(result.Day__c.year(), result.Day__c.month(), 1);
				if (!startDateSet.contains(startMonth)) {
					startDateSet.add(startMonth);
				}
				if (!metObjectiveMap.containsKey(startMonth)) {
					metObjectiveMap.put(startMonth, 0);
				}
				if (!notMetObjectiveMap.containsKey(startMonth)) {
					notMetObjectiveMap.put(startMonth, 0);
				}
				if (!percentMetObjectiveMap.containsKey(startMonth)) {
					percentMetObjectiveMap.put(startMonth, 0);
				}
				if (result.Met_Objective__c == 'y') {
					metObjectiveMap.put(startMonth, metObjectiveMap.get(startMonth) + 1);
				}
				if (result.Met_Objective__c == 'n') {
					notMetObjectiveMap.put(startMonth, notMetObjectiveMap.get(startMonth) + 1);
				}
				percentMetObjectiveMap.put(startMonth,
					(metObjectiveMap.get(startMonth) * 100)/(metObjectiveMap.get(startMonth) + notMetObjectiveMap.get(startMonth))
				);
			}
			startDates.addAll(startDateSet);
			startDates.sort();
		}
	}

	public class ObjectiveBehaviorCountResults {
		public Action_Plan_Objective__c objective { get; set; }

		public transient List<Date> startDates { get; set; }
		public transient Map<Date, Integer> occurrenceMap { get; set; }

		public ObjectiveBehaviorCountResults(Action_plan_objective__c objective) {
			this.objective = objective;

			occurrenceMap = new Map<Date, Integer>();
			startDates = new List<Date>();
			Set<Date> startDateSet = new Set<Date>();

			for(Action_behavior_result__c result: objective.Action_Behavior_results__r) {
				Date startMonth = Date.newInstance(result.Day_time__c.yearGmt(), result.Day_time__c.monthGmt(), 1);
				if (!startDateSet.contains(startMonth)) {
					startDateSet.add(startMonth);
				}
				if (!occurrenceMap.containsKey(startMonth)) {
					occurrenceMap.put(startMonth, 0);
				}
				occurrenceMap.put(startMonth,
					occurrenceMap.get(startMonth) + (result.Occurrences__c == null ? 0 : result.Occurrences__c.intValue())
				);
			}
			startDates.addAll(startDateSet);
			startDates.sort();
		}
	}

	public class Objective implements Comparable {
		public Action_Plan_Objective__c objectiveSObject { get; set; }
		public Boolean highlight { get; set; }
		public ObjectiveSkillResults skillResults { get; set; }
		public ObjectiveBehaviorCountResults countResults { get; set; }

		public Objective(Action_Plan_Objective__c objectiveSObject) {
			this.objectiveSObject = objectiveSObject;
			this.highlight = false;
			this.skillResults = new ObjectiveSkillResults(objectiveSObject);
			this.countResults = new ObjectiveBehaviorCountResults(objectiveSObject);
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

	public class RecommendationSummaryResult {
		public Action_Plan_Summary_Result__c resultSObject { get; set; }
		public String recommendation { get; set; }
		public String comment { get; set; }
		public Id objectiveId { get; set; }

		public RecommendationSummaryResult(String recommendation, String comment, Id objectiveId) {
			// This constructor is only used for JSON (de-)serializing. Don't
			// use it for any other purpose
			this.recommendation = recommendation;
			this.comment = comment;
			this.objectiveId = objectiveId;
		}

		public RecommendationSummaryResult(Id summaryId, Id objectiveId) {
			this.resultSObject = new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = summaryId,
				Type__c = 'Recommendation'
			);
			this.objectiveId = objectiveId;
		}
		public RecommendationSummaryResult(Action_Plan_Summary_Result__c resultSObject) {
			this.resultSObject = resultSObject;
			RecommendationSummaryResult r = (RecommendationSummaryResult) JSON.deserialize(
				resultSObject.Data__c, RecommendationSummaryResult.class
			);
			this.recommendation = r.recommendation;
			this.comment = r.comment;
			this.objectiveId = r.objectiveId;
		}
		public void updateData() {
			// Update the data field for the underlying Summary Result object
			this.resultSObject.Data__c = JSON.serialize(new RecommendationSummaryResult(
				this.recommendation, this.comment, this.objectiveId
			));
		}
	}

	public class SystemSummaryResult {
		public Action_Plan_Summary_Result__c resultSObject { get; set; }
		public String domain { get; set; }
		public String status { get; set; }
		public String comment { get; set; }

		public SystemSummaryResult(String domain, String status, String comment) {
			// This constructor is only used for JSON (de-)serializing. Don't
			// use it for any other purpose
			this.domain = domain;
			this.status = status;
			this.comment = comment;
		}

		public SystemSummaryResult(Id summaryId, String domain) {
			this.resultSObject = new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = summaryId,
				Type__c = 'System'
			);
			this.domain = domain;
		}
		public SystemSummaryResult(Action_Plan_Summary_Result__c resultSObject) {
			this.resultSObject = resultSObject;
			SystemSummaryResult r = (SystemSummaryResult) JSON.deserialize(
				resultSObject.Data__c, SystemSummaryResult.class
			);
			this.domain = r.domain;
			this.status = r.status;
			this.comment = r.comment;
		}
		public void updateData() {
			// Update the data field for the underlying Summary Result object
			this.resultSObject.Data__c = JSON.serialize(new SystemSummaryResult(
				this.domain, this.status, this.comment
			));
		}
	}

	public class Seizure {
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public Long duration { get; set; }
		public Id observedById { get; set; }
		public String observedByName { get; set; }

		public Seizure(Seizure__c seizure) {
			this.startTime = seizure.Start_DateTime__c;
			this.endTime = seizure.End_DateTime__c;
			this.duration = (seizure.End_DateTime__c.getTime() - seizure.Start_DateTime__c.getTime()) / 1000;
			this.observedById = seizure.Observed_By__c;
			this.observedByName = seizure.Observed_By__r.Name;
		}
	}

	public class IsolationEvent {
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public String status { get; set; }
		public String type { get; set; }

		public IsolationEvent(Evaluation_Response__c event) {
			this.startTime = event.Isolation_Event_Start_Date__c;
			this.endTime = event.Isolation_Event_End_Date__c;
			this.status = event.Isolation_Status__c;
			this.type = event.Isolation_Type__c;
		}
	}

	public class RestraintEvent {
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public String status { get; set; }
		public Decimal score { get; set; }

		public RestraintEvent(Evaluation__c event, Decimal score) {
			this.startTime = event.Shift_Start_Time__c;
			this.endTime = event.Shift_End_Time__c;
			this.status = event.Status__c;
			this.score = score;
		}
	}

	public class VitalsDetail implements Comparable {
		public DateTime dateTaken { get; set; }
		public Decimal heartRate { get; set; }
		public String bloodPressure { get; set; }
		public Decimal o2 { get; set; }
		public String temperature { get; set; }

		public VitalsDetail(Eval_Value__c[] results) {
			// This constructor takes in a list of Eval_Value__c with the
			// assumption that they all have the same Eval_Section_Id__c
			for (Eval_Value__c result: results) {
				if (result.Eval__r.Field_Name__c == 'Blood Pressure') {
					this.bloodPressure = result.Text_Under_250__c;
				} else if (result.Eval__r.Field_Name__c == 'Heart Rate') {
					this.heartRate = result.Number_No_Decimal__c;
				} else if (result.Eval__r.Field_Name__c == 'O2 Saturation' || result.Eval__r.Field_Name__c == 'O2 Sat') {
					this.o2 = result.Number_No_Decimal__c;
				} else if (result.Eval__r.Field_Name__c == 'Temperature') {
					this.temperature = result.Text_Under_250__c;
				} else if (result.Eval__r.Field_Name__c == 'Date' || result.Eval__r.Field_Name__c == 'Date/Time') {
					this.dateTaken = result.Date_Time__c;
				}
			}
		}

		public Integer compareTo(Object anotherDetailObject) {
			VitalsDetail anotherDetail = (VitalsDetail) anotherDetailObject;
			if (this.dateTaken < anotherDetail.dateTaken) {
				return -1;
			} else if (this.dateTaken == anotherDetail.dateTaken) {
				return 0;
			} else {
				return 1;
			}
		}
	}
}