public with sharing class ActionSummaryReportV2 implements AuthenticatedAction {
	public Action_Summary__c summary { get; set; }
	public ApexPages.standardController controller { get; set; }
	public String mode { get; set; }

	// This map contains the link between the type of the objective, the parent
	// objective and all of its revised descendents (no matter how many degree
	// of separations). The list also contains the parent objective itself
	public Map<String, Map<Id, List<Objective>>> objectiveMap { get; set; }
	private transient Map<Id, List<Action_Skill_Result__c>> objectiveToSkillResultMap;
	private transient Map<Id, List<Action_Behavior_Result__c>> objectiveToBehaviorResultMap;
	private transient Map<Id, List<Action_Narrative_Result__c>> objectiveToNarrativeResultMap;
	public Map<String, List<Objective>> sortedTopLevelObjectivesByType { get; set; }
	// Sometimes, if a top level objectives have all their child objectives hidden (e.g, when
	// none of the child objectives have calculable records within the report timeframe), it's best
	// to hide the top level objective as well
	public Map<String, Boolean> topLevelObjectiveShown { get; set; }

	public Map<Id, RecommendationSummaryResult> recommendationSummaryResultMap { get; set; }
	public List<String> systemSummaryResultDomain { get; set; }
	public Map<String, SystemSummaryResult> systemSummaryResultMap { get; set; }

	public List<Seizure> seizures { get; set; }
	public List<IsolationEvent> isolationEvents { get; set; }
	public List<RestraintEvent> restraintEvents { get; set; }
	public List<VitalsDetail> vitalsDetails { get; set; }

	public map<string, totalInfo> SkillBehaviorTotals {get; set;}

	public DiagnosticsIvEvaluation diagnosticsIvEvaluation { get; set; }
	public List<SelectOption> yesNoOptions {
		get {
			return new List<SelectOption> {
				new SelectOption('Yes', 'Yes'),
				new SelectOption('No', 'No')
			};
		}
	}
	public String diagnosticsIvTypes { get; set; }

	public List<Action_Summary__c> summaries { get; set; }

	// Some constants for config purpose
	public Integer LIST_LIMIT { get { return 10; } }
	public String TABLE_WIDTH { get { return '80%'; } }

	public Boolean editable { get; set; }

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

	/*
	 * Do not let the user edit finalized summaries
	 */
	public PageReference checkFinalizedEdit() {
		if (this.summary.Status__c == 'Final' && mode == 'edit') {
			return new PageReference('/' + this.summary.Id);
		}
		return null;
	}
	public ActionSummaryReportV2() {
		// This is only used for esigning purpose. Don't use it otherwise!
	}
	public ActionSummaryReportV2(ApexPages.standardController controller) {
		this.controller = controller;

		summary = (Action_Summary__c) controller.getRecord();

		objectiveMap = new Map<String, Map<Id, List<Objective>>>();
		objectiveToSkillResultMap = new Map<Id, List<Action_Skill_Result__c>>();
		objectiveToBehaviorResultMap = new Map<Id, List<Action_Behavior_Result__c>>();
		objectiveToNarrativeResultMap = new Map<Id, List<Action_Narrative_Result__c>>();
		sortedTopLevelObjectivesByType = new Map<String, List<Objective>>();	//RPII-60 - different sort
		topLevelObjectiveShown = new Map<String, Boolean>();


		mode = ApexPages.currentPage().getParameters().get('mode');
		if (mode == '' || mode == null) {
			mode = 'view';
		}

		List<UserRecordAccess> acls = [
			SELECT RecordId, HasEditAccess
			  FROM UserRecordAccess
			 WHERE UserId = :UserInfo.getUserId()
			   AND RecordId = :summary.Id
		];
		if (acls.size() > 0) {
			editable = acls[0].HasEditAccess;
		} else {
			editable = false;
		}

		recommendationSummaryResultMap = new Map<Id, RecommendationSummaryResult>();
		systemSummaryResultMap = new Map<String, SystemSummaryResult>();
		Map<Id, List<ObjectiveSkillResult>> finalizedSkillResultMap = new Map<Id, List<ObjectiveSkillResult>>();
		Map<Id, List<ObjectiveBehaviorCountResult>> finalizedCountResultMap = new Map<Id, List<ObjectiveBehaviorCountResult>>();
		Map<Id, List<ObjectiveNarrativeResult>> finalizedNarrativeResultMap = new Map<Id, List<ObjectiveNarrativeResult>>();

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
			} else if (result.Type__c == 'Seizure') {
				if (seizures == null) {
					seizures = new List<Seizure>();
				}
				seizures.add(new Seizure(result.Data__c));
			} else if (result.Type__c == 'Isolation') {
				if (isolationEvents == null) {
					isolationEvents = new List<IsolationEvent>();
				}
				isolationEvents.add(new IsolationEvent(result.Data__c));
			} else if (result.Type__c == 'Restraint') {
				if (restraintEvents == null) {
					restraintEvents = new List<RestraintEvent>();
				}
				restraintEvents.add(new RestraintEvent(result.Data__c));
			} else if (result.Type__c == 'Vitals') {
				if (vitalsDetails == null) {
					vitalsDetails = new List<VitalsDetail>();
				}
				vitalsDetails.add(new VitalsDetail(result.Data__c));
			} else if (result.Type__c == 'Skill') {
				ObjectiveSkillResult skillResult = (ObjectiveSkillResult) JSON.deserialize(
					result.Data__c, ObjectiveSkillResult.class
				);
				if (!finalizedSkillResultMap.containsKey(skillResult.objectiveId)) {
					finalizedSkillResultMap.put(skillResult.objectiveId, new List<ObjectiveSkillResult>());
				}
				finalizedSkillResultMap.get(skillResult.objectiveId).add(skillResult);
			} else if (result.Type__c == 'Behavior - Count') {
				ObjectiveBehaviorCountResult countResult = (ObjectiveBehaviorCountResult) JSON.deserialize(
					result.Data__c, ObjectiveBehaviorCountResult.class
				);
				if (!finalizedCountResultMap.containsKey(countResult.objectiveId)) {
					finalizedCountResultMap.put(countResult.objectiveId, new List<ObjectiveBehaviorCountResult>());
				}
				finalizedCountResultMap.get(countResult.objectiveId).add(countResult);
			} else if (result.Type__c == 'Narrative') {
				ObjectiveNarrativeResult narrativeResult = (ObjectiveNarrativeResult) JSON.deserialize(
					result.Data__c, ObjectiveNarrativeResult.class
				);
				if (!finalizedNarrativeResultMap.containsKey(narrativeResult.objectiveId)) {
					finalizedNarrativeResultMap.put(narrativeResult.objectiveId, new List<ObjectiveNarrativeResult>());
				}
				finalizedNarrativeResultMap.get(narrativeResult.objectiveId).add(narrativeResult);
			} else if (result.Type__c == 'DiagnosticsIvEvaluation') {
				diagnosticsIvEvaluation = new DiagnosticsIvEvaluation(result);
			}
		}

		Map<Id, Action_Plan_Objective__c> objectives;
		if (summary.Status__c != 'Final' && summary.Status__c != 'Disregard') {
			objectives = new Map<Id, Action_Plan_Objective__c>([
				SELECT Id, Former_Id__c, Type__c, Status__c, Description__c,
				       CreatedDate, Effective_Date__c, Target_End_Date__c, sort_order__c, action_plan_goal__r.sort_order__c
				  FROM Action_Plan_Objective__c
				 WHERE Effective_Date__c <= :summary.End_Date__c
				   AND Target_End_Date__c >= :summary.Start_Date__c
				   AND action_plan_goal__r.action_plan__r.Service_Assignment__c = :summary.Service_Assignment__c
				   AND (action_plan_goal__r.action_plan__r.Status__c = 'Inactive Final'
				    OR action_plan_goal__r.action_plan__r.Status__c = 'Active Final')
				   AND action_plan_goal__r.action_plan__r.Effective_Date__c < :summary.End_Date__c
				   AND action_plan_goal__r.action_plan__r.Target_Date__c >= :summary.Start_Date__c
				ORDER BY type__c, action_plan_goal__c, action_plan_goal__r.sort_order__c, sort_order__c
			]);
			// We have to query the results here separately instead of using nested queries because
			// nested queries are prone to Invalid query locator error when the returned children
			// dataset is big, which it is in this case.
			for (Action_Skill_Result__c skillResult: [
				SELECT Met_Objective__c , Day__c, Attempts__c, Action_Plan_Objective__c
				  FROM Action_Skill_Result__c
				 WHERE Day__c <= :summary.End_Date__c
				   AND Day__c >= :summary.Start_Date__c
				   AND Action_Plan_Objective__c IN :objectives.keySet()
			]) {
				if (!objectiveToSkillResultMap.containsKey(skillResult.Action_Plan_Objective__c)) {
					objectiveToSkillResultMap.put(skillResult.Action_Plan_Objective__c,
						new List<Action_Skill_Result__c>());
				}
				objectiveToSkillResultMap.get(skillResult.Action_Plan_Objective__c).add(skillResult);
			}
			for (Action_Behavior_Result__c behaviorResult: [
				SELECT Day_time__c, Occurrences__c, Occurred__c, Action_Plan_Objective__c
				  FROM Action_Behavior_Result__c
				 WHERE Day_time__c <= :summary.End_Date__c.addDays(1)
				   AND Day_time__c >= :summary.Start_Date__c
				   AND Action_Plan_Objective__c IN :objectives.keySet()
			]) {
				if (!objectiveToBehaviorResultMap.containsKey(behaviorResult.Action_Plan_Objective__c)) {
					objectiveToBehaviorResultMap.put(behaviorResult.Action_Plan_Objective__c,
						new List<Action_Behavior_Result__c>());
				}
				objectiveToBehaviorResultMap.get(behaviorResult.Action_Plan_Objective__c).add(behaviorResult);
			}
			for (Action_Narrative_Result__c narrativeResult: [
				SELECT Description__c, CreatedDate, Action_Plan_Objective__c
				  FROM Action_Narrative_Result__c
				 WHERE CreatedDate <= :summary.End_Date__c.addDays(1)
				   AND CreatedDate >= :summary.Start_Date__c
				   AND Action_Plan_Objective__c IN :objectives.keySet()
				ORDER BY CreatedDate
			]) {
				if (!objectiveToNarrativeResultMap.containsKey(narrativeResult.Action_Plan_Objective__c)) {
					objectiveToNarrativeResultMap.put(narrativeResult.Action_Plan_Objective__c,
						new List<Action_Narrative_Result__c>());
				}
				objectiveToNarrativeResultMap.get(narrativeResult.Action_Plan_Objective__c).add(narrativeResult);
			}
			seizures = getSeizures(summary);
			isolationEvents = getIsolationEvents(summary);
			restraintEvents = getRestraintEvents(summary);
			vitalsDetails = getVitalsDetails(summary);
		} else {
			objectives = new Map<Id, Action_Plan_Objective__c>([
				SELECT Id, Former_Id__c, Type__c, Status__c, Description__c,
				       CreatedDate, Effective_Date__c, Target_End_Date__c, sort_order__c, action_plan_goal__r.sort_order__c
				  FROM Action_Plan_Objective__c
				 WHERE Effective_Date__c <= :summary.End_Date__c
				   AND CreatedDate < :summary.Finalized_Date__c
				   AND Target_End_Date__c >= :summary.Start_Date__c
				   AND action_plan_goal__r.action_plan__r.Service_Assignment__c = :summary.Service_Assignment__c
				   AND (action_plan_goal__r.action_plan__r.Status__c = 'Inactive Final'
				    OR action_plan_goal__r.action_plan__r.Status__c = 'Active Final')
				   AND action_plan_goal__r.action_plan__r.Effective_Date__c < :summary.End_Date__c
				   AND action_plan_goal__r.action_plan__r.Target_Date__c >= :summary.Start_Date__c
				ORDER BY type__c, action_plan_goal__c, action_plan_goal__r.sort_order__c,
				         sort_order__c
			]);
		}
		if (seizures == null) {
			seizures = new List<Seizure>();
		}
		seizures.sort();
		if (isolationEvents == null) {
			isolationEvents = new List<IsolationEvent>();
		}
		isolationEvents.sort();
		if (restraintEvents == null) {
			restraintEvents = new List<RestraintEvent>();
		}
		restraintEvents.sort();
		if (vitalsDetails == null) {
			vitalsDetails = new List<VitalsDetail>();
		}
		vitalsDetails.sort();

		Set<Id> allTopLevelObjectives = new Set<Id>();

		for (Id objectiveId: objectives.keySet()) {
			if (!objectiveMap.containsKey(objectives.get(objectiveId).Type__c)) {
				objectiveMap.put(objectives.get(objectiveId).Type__c, new Map<Id, List<Objective>>());
				sortedTopLevelObjectivesByType.put(objectives.get(objectiveId).Type__c, new List<Objective>());
			}
			Map<Id, List<Objective>> objectiveParentToChildrenMap = objectiveMap.get(objectives.get(objectiveId).Type__c);
			Id parentObjectiveId = findParentObjective(objectives.get(objectiveId), objectives);
			allTopLevelObjectives.add(parentObjectiveId);

			// RPII-60 - keeping the top level objectives sorted with each objective type
			List<Objective> typeobjs = sortedTopLevelObjectivesByType.get(objectives.get(objectiveId).Type__c);

			if (!objectiveParentToChildrenMap.containsKey(parentObjectiveId)) {
				objectiveParentToChildrenMap.put(parentObjectiveId, new List<Objective>());
				typeobjs.add( new objective(objectives.get(parentObjectiveId)));
			}

			Objective obj = new Objective(objectives.get(objectiveId));
			objectiveParentToChildrenMap.get(parentObjectiveId).add(obj);
			if (this.summary.Status__c == 'Draft') {
				obj.populateSkillResults(objectiveToSkillResultMap.containsKey(objectiveId) ? objectiveToSkillResultMap.get(objectiveId) : null);
				obj.populateBehaviorCountResults(objectiveToBehaviorResultMap.containsKey(objectiveId) ? objectiveToBehaviorResultMap.get(objectiveId) : null);
				obj.populateNarrativeResults(objectiveToNarrativeResultMap.containsKey(objectiveId) ? objectiveToNarrativeResultMap.get(objectiveId) : null);
			} else {
				if (finalizedSkillResultMap.containsKey(objectiveId)) {
					obj.skillResults = finalizedSkillResultMap.get(objectiveId);
				}
				if (finalizedCountResultMap.containsKey(objectiveId)) {
					obj.countResults = finalizedCountResultMap.get(objectiveId);
				}
				if (finalizedNarrativeResultMap.containsKey(objectiveId)) {
					obj.narrativeResults = finalizedNarrativeResultMap.get(objectiveId);
				}
			}
			obj.showResults = this.calculateObjectiveResultVisibility(obj);
		}
		// Sort all the objectives
		for (String type: objectiveMap.keySet()) {
			//system.debug( ' sorting ' + type);
			for (Id topLevelObjectiveId: objectiveMap.get(type).keySet()) {
				//system.debug(' keyset is ' + objectiveMap.get(type).keySet());
				List<Objective> objs = objectiveMap.get(type).get(topLevelObjectiveId);
				objs.sort();
				// Determine whether to highlight a row or not
				if (objs.size() > 1 && objs[objs.size() - 1].isDifferentFrom(objs[objs.size() - 2])) {
					objs[objs.size() - 1].highlight = true;
				}
			}
			sortedTopLevelObjectivesByType.get(type).sort();

			for (Objective topLevelObjective: sortedTopLevelObjectivesByType.get(type)) {
				Boolean childObjectivesShown = false;
				for (Objective childObjective: objectiveMap.get(type).get(topLevelObjective.objectiveSObject.Id)) {
					if (childObjective.showResults.get(type)) {
						childObjectivesShown = true;
					}
				}
				topLevelObjectiveShown.put(topLevelObjective.objectiveSObject.Id, childObjectivesShown);
			}
		}

		// Initialize system summary results
		systemSummaryResultDomain = new List<String> {
			'Diagnostics', 'Cardiopulmonary', 'GU/GI/Nutrition',
			'Skin/Body', 'Neurological', 'Muscle-Skeletal',
			'Psychosocial', 'Therapy/Rehab', 'Discharge Planning'
		};

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
		diagnosticsIvTypes = getDiagnosticsIVs(summary);
		if (diagnosticsIvEvaluation == null && (diagnosticsIvTypes.contains('PICC') || diagnosticsIvTypes.contains('CENTRAL')) ) {
			diagnosticsIvEvaluation = new DiagnosticsIvEvaluation(summary.Id);
		}

		summaries = [
			SELECT Id, Name, Start_Date__c, End_Date__c, Status__c
			  FROM Action_Summary__c
			 WHERE Service_Assignment__c = :summary.Service_Assignment__c
			   AND Id != :summary.Id
			ORDER BY CreatedDate ASC
		];
	}

	private Map<String, Boolean> calculateObjectiveResultVisibility(Objective obj) {
		// Sometimes we don't want to show a result row for an objective because it
		// clutters up the page. We use this variable to control that
		Map<String, Boolean> typesShown = new Map<String, Boolean>();
		typesShown.put('Skill', true);
		typesShown.put('Behavior - Count', true);
		typesShown.put('Behavior - Duration', true);
		typesShown.put('Narrative', true);
		if (obj.objectiveSObject.CreatedDate >= summary.Start_Date__c) {
			// if the revised date/created date is within this summary range, it will
			// always be displayed
			return typesShown;
		}
		// Otherwise, we'll have to figure out whether there is data recorded for that period
		// or not
		if (obj.skillResults.size() == 0) {
			typesShown.put('Skill', false);
		}
		if (obj.countResults.size() == 0) {
			typesShown.put('Behavior - Count', false);
		}
		if (obj.narrativeResults.size() == 0) {
			typesShown.put('Narrative', false);
		}
		return typesShown;
	}

	private Id findParentObjective(Action_Plan_Objective__c objective, Map<Id, Action_Plan_Objective__c> objectives) {
		String parentObjectiveId = objectives.get(objective.Id).Former_ID__c;
		// Apparently when this field is set, it'll be set to a valid SF Id
		// if it's a revised objective, and take the form zo*** if it's not a
		// revised objective
		Boolean isValidId = (parentObjectiveId instanceOf ID) ? true : false;
		if (parentObjectiveId != null && isValidId && objectives.containsKey(parentObjectiveId) && objectives.get(parentObjectiveId).Type__c == objective.Type__c) {
			return findParentObjective(objectives.get(parentObjectiveId), objectives);
		}
		// Return own id if this is not a revised objective
		return objective.Id;
	}

	public PageReference disregard() {
		summary.Status__c = 'Disregard';
		upsert summary;
		return new PageReference('/' + summary.Id);
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

		if (diagnosticsIvEvaluation != null) resultsToUpdate.add(diagnosticsIvEvaluation.updateData().resultSObject);

		upsert resultsToUpdate;
		update summary;
		return new PageReference('/' + summary.Id);
	}

	public PageReference handle(Id recordId, Id userId) {
		Action_Summary__c summary = [
			SELECT Id, Status__c, Start_Date__c, End_Date__c, Finalized_Date__c,
			       Service_Assignment__c
			  FROM Action_Summary__c WHERE Id=:recordId
		];
		ActionSummaryReportV2 controller = new ActionSummaryReportV2(
				new ApexPages.standardController(summary)
				);
		return controller.finalize();
	}

	public PageReference finalize() {
		summary.Status__c = 'Final';
		summary.Finalized_Date__c = DateTime.now();
		summary.Finalized_By__c = UserInfo.getUserId();

		if ( (diagnosticsIvTypes.contains('PICC') || diagnosticsIvTypes.contains('CENTRAL')) &&
	         (this.diagnosticsIvEvaluation.dressingChange == '' || this.diagnosticsIvEvaluation.externalCatheterLength == 0 || this.diagnosticsIvEvaluation.totalCatheterLength == 0 ) ){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
				'One of the field for Weekly IV Evaluation is empty OR zero. Please fill in appropriate values to Finalize the weekly documentation.'));
			return null;
		}

		if (diagnosticsIvTypes.contains('PICC') && this.diagnosticsIvEvaluation.armCircumference == 0 ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'One of the field for Weekly IV Evaluation is empty OR zero. Please fill in appropriate values to Finalize the weekly documentation.'));
            return null;
        }


		List<Action_Plan_Summary_Result__c> toInsert = new List<Action_Plan_Summary_Result__c>();
		for (Seizure seizure: this.seizures) {
			toInsert.add(new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = this.summary.Id,
				Type__c = 'Seizure',
				Data__c = seizure.serialize()
			));
		}
		for (IsolationEvent event: this.isolationEvents) {
			toInsert.add(new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = this.summary.Id,
				Type__c = 'Isolation',
				Data__c = event.serialize()
			));
		}
		for (RestraintEvent event: this.restraintEvents) {
			toInsert.add(new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = this.summary.Id,
				Type__c = 'Restraint',
				Data__c = event.serialize()
			));
		}
		for (VitalsDetail vital: this.vitalsDetails) {
			toInsert.add(new Action_Plan_Summary_Result__c(
				Action_Plan_Summary__c = this.summary.Id,
				Type__c = 'Vitals',
				Data__c = vital.serialize()
			));
		}
		if (objectiveMap.containsKey('Skill')) {
			for (Id topObjective: objectiveMap.get('Skill').keySet()) {
				for (Objective obj: objectiveMap.get('Skill').get(topObjective)) {
					for (ObjectiveSkillResult result: obj.skillResults) {
						toInsert.add(new Action_Plan_Summary_Result__c(
							Action_Plan_Summary__c = this.summary.Id,
							Type__c = 'Skill',
							Data__c = result.serialize()
						));
					}
				}
			}
		}
		if (objectiveMap.containsKey('Behavior - Count')) {
			for (Id topObjective: objectiveMap.get('Behavior - Count').keySet()) {
				for (Objective obj: objectiveMap.get('Behavior - Count').get(topObjective)) {
					for (ObjectiveBehaviorCountResult result: obj.countResults) {
						toInsert.add(new Action_Plan_Summary_Result__c(
							Action_Plan_Summary__c = this.summary.Id,
							Type__c = 'Behavior - Count',
							Data__c = result.serialize()
						));
					}
				}
			}
		}
		if (objectiveMap.containsKey('Narrative')) {
			for (Id topObjective: objectiveMap.get('Narrative').keySet()) {
				for (Objective obj: objectiveMap.get('Narrative').get(topObjective)) {
					for (ObjectiveNarrativeResult result: obj.narrativeResults) {
						toInsert.add(new Action_Plan_Summary_Result__c(
							Action_Plan_Summary__c = this.summary.Id,
							Type__c = 'Narrative',
							Data__c = result.serialize()
						));
					}
				}
			}
		}
		insert toInsert;
		update summary;
		return new PageReference('/' + summary.Id);
	}
	/////////////////////////
	// Private helper methods
	/////////////////////////
	private List<Seizure> getSeizures(Action_Summary__c summary) {
		List<Seizure> tmpSeizures = new List<Seizure>();
		Id saId = summary.Service_Assignment__c;
		Date endDate = summary.End_Date__c.addDays(1);  // Because we want to include the record on the end date as well
		Date startDate = summary.Start_Date__c;
		String query =
			'SELECT Id, Start_DateTime__c, End_DateTime__c, Observed_By__c, CreatedDate, ' +
			        'Observed_By__r.Name ' +
			'  FROM Seizure__c ' +
			' WHERE Service_Assignment__c = :saId ' +
			'   AND Start_DateTime__c <= :endDate AND (End_DateTime__c = null OR Start_DateTime__c >= :startDate) ' +
			'ORDER BY CreatedDate ASC ';
		for (Seizure__c seizure: Database.query(query)) {
			tmpSeizures.add(new Seizure(seizure));
		}
		return tmpSeizures;
	}

	private List<IsolationEvent> getIsolationEvents(Action_Summary__c summary) {
		List<IsolationEvent> tmpIsolationEvents = new List<IsolationEvent>();
		Id saId = summary.Service_Assignment__c;
		Date endDate = summary.End_Date__c.addDays(1);  // Because we want to include the record on the end date as well
		Date startDate = summary.Start_Date__c;
		String query =
			'SELECT Id, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, CreatedDate, ' +
			'       Isolation_Status__c, Isolation_Type__c ' +
			'  FROM Evaluation_Response__c ' +
			' WHERE RecordType.Name = \'Isolation Event\' ' +
			'   AND Service_Assignment__c = :saId ' +
			'   AND Isolation_Event_Start_Date__c <= :endDate AND (Isolation_Event_End_Date__c = null OR Isolation_Event_Start_Date__c >= :startDate) ' +
			'ORDER BY CreatedDate ASC ';
		for (Evaluation_Response__c event: Database.query(query)) {
			tmpIsolationEvents.add(new IsolationEvent(event));
		}
		return tmpIsolationEvents;
	}

	private List<RestraintEvent> getRestraintEvents(Action_Summary__c summary) {
		List<RestraintEvent> restraintEvents = new List<RestraintEvent>();
		Id saId = summary.Service_Assignment__c;
		Date endDate = summary.End_Date__c.addDays(1);  // Because we want to include the record on the end date as well
		Date startDate = summary.Start_Date__c;
		String query =
			'SELECT Id, Shift_Start_Time__c, Shift_End_Time__c, Status__c, CreatedDate, ' +
			'       (SELECT Id FROM Assessments__r ' +
			'         WHERE Status__c != \'Disregard\' ' +
			'         ORDER BY CreatedDate DESC) ' +
			'  FROM Evaluation__c ' +
			' WHERE ServiceAssignment__c = :saId' +
			'   AND RecordType.Name = \'RestraintEvent\' ' +
			'   AND (Shift_Start_Time__c != null AND Shift_Start_Time__c <= :endDate AND Shift_Start_Time__c >= :startDate) ' +
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
				       Eval_Section_Id__c, Eval__r.Field_Name__c, CreatedDate
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
			VitalsDetail detail = new VitalsDetail(entryValuesMap.get(evalSectionId));
			if (detail.dateTaken >= summary.Start_Date__c && detail.dateTaken <= summary.End_Date__c.addDays(1)) {
				vitalsDetails.add(new VitalsDetail(entryValuesMap.get(evalSectionId)));
			}
		}
		vitalsDetails.sort();
		return vitalsDetails;
	}

	//////////////////////
	// The wrapper classes
	//////////////////////
	public abstract class ObjectiveResult implements Comparable {
		public Date resultDate { get; set; }
		public Id objectiveId { get; set; }

		public Integer compareTo(Object anotherResultObject) {
			ObjectiveResult anotherResult = (ObjectiveResult) anotherResultObject;
			if (this.resultDate < anotherResult.resultDate) {
				return -1;
			} else if (this.resultDate == anotherResult.resultDate) {
				return 0;
			} else {
				return 1;
			}
		}

		public String serialize() {
			return JSON.serialize(this);
		}
	}
	public class ObjectiveSkillResult extends ObjectiveResult {
		public Integer met { get; set; }
		public Integer notMet { get; set; }
		public Integer percentMet { get; set; }
		public ObjectiveSkillResult(Id objectiveId, Date startMonth, Integer met, Integer notMet, Integer percentMet) {
			this.objectiveId = objectiveId;
			this.resultDate = startMonth;
			this.met = met;
			this.notMet = notMet;
			this.percentMet = percentMet;
		}
	}

	public class ObjectiveBehaviorCountResult extends ObjectiveResult {
		public Integer occurrences { get; set; }

		public ObjectiveBehaviorCountResult(Id objectiveId, Date startMonth, Integer occurrences) {
			this.objectiveId = objectiveId;
			this.resultDate = startMonth;
			this.occurrences = occurrences;
		}
	}

	public class ObjectiveNarrativeResult extends ObjectiveResult {
		public String description { get; set; }

		public ObjectiveNarrativeResult(Id objectiveId, DateTime resultDate, String description) {
			this.objectiveId = objectiveId;
			this.resultDate = Date.newInstance(resultDate.year(), resultDate.month(), resultDate.day());
			this.description = description;
		}
	}

	public class Objective implements Comparable {
		public Action_Plan_Objective__c objectiveSObject { get; set; }
		public Boolean highlight { get; set; }
		public transient Map<String, Boolean> showResults { get; set; }

		public List<ObjectiveSkillResult> skillResults { get; set; }
		public List<ObjectiveBehaviorCountResult> countResults { get; set; }
		public List<ObjectiveNarrativeResult> narrativeResults { get; set; }
		public integer TotalOccurrences {get{
			integer t=0;
			for(ObjectiveBehaviorCountResult item: countResults){
				t=t+ item.occurrences ;
			}
			return t;
		}  set;}
		public integer metObj {get{
			integer t=0;
			for(ObjectiveSkillResult item: skillResults){
				t=t+ item.met;
			}
			return t;
		} set;}
		public integer notMetObj {get{
			integer t=0;
			for(ObjectiveSkillResult item: skillResults){
				t=t+ item.notMet;
			}
			return t;
		} set;}
		public integer percMetObj {get{
			double t = 0;
			t = (metObj + notMetObj);
			if (t == 0) {
				return 0;
			}
			t = (metObj) / t;
			t = t * 100;
			return integer.valueof(math.roundToLong(t));
		} set;}

		public Objective(Action_Plan_Objective__c objectiveSObject) {
			this.objectiveSObject = objectiveSObject;
			this.highlight = false;
			this.skillResults = new List<ObjectiveSkillResult>();
			this.countResults = new List<ObjectiveBehaviorCountResult>();
			this.narrativeResults = new List<ObjectiveNarrativeResult>();
		}

		public void populateSkillResults(List<Action_Skill_Result__c> results) {
			Map<Date, Integer> metObjectiveMap = new Map<Date, Integer>();
			Map<Date, Integer> notMetObjectiveMap = new Map<Date, Integer>();
			Map<Date, Integer> percentMetObjectiveMap = new Map<Date, Integer>();
			Set<Date> startDateSet = new Set<Date>();

			if (results == null) {
				return;
			}
			for(Action_Skill_Result__c result: results) {
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
				if (metObjectiveMap.get(startMonth) != 0 || notMetObjectiveMap.get(startMonth) != 0) {
					double percentage = metObjectiveMap.get(startMonth) + notMetObjectiveMap.get(startMonth);
					percentage = metObjectiveMap.get(startMonth) / percentage;
					percentage = percentage * 100;
					percentMetObjectiveMap.put(startMonth, integer.valueOf(math.roundToLong(percentage)));
				}
			}
			for (Date startMonth: startDateSet) {
				skillResults.add(
					new ObjectiveSkillResult(
						objectiveSObject.Id,
						startMonth,
						metObjectiveMap.get(startMonth),
						notMetObjectiveMap.get(startMonth),
						percentMetObjectiveMap.get(startMonth)
					)
				);
			}
			//SkillBehaviorTotals.put(objectiveSObject.Id, new totalInfo(objectiveSObject.Id));
			skillResults.sort();
		}

		public void populateBehaviorCountResults(List<Action_Behavior_Result__c> results) {
			Map<Date, Integer> occurrenceMap = new Map<Date, Integer>();
			Set<Date> startDateSet = new Set<Date>();

			if (results == null) {
				return;
			}

			for(Action_Behavior_Result__c result: results) {
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
			for (Date startMonth: startDateSet) {
				countResults.add(
					new ObjectiveBehaviorCountResult(
						objectiveSObject.Id,
						startMonth,
						occurrenceMap.get(startMonth)
					)
				);
			}
			countResults.sort();
		}

		public void populateNarrativeResults(List<Action_Narrative_Result__c> results) {
			if (results == null) {
				return;
			}
			for(Action_Narrative_Result__c result: results) {
				narrativeResults.add(
					new ObjectiveNarrativeResult(
						objectiveSObject.Id,
						result.CreatedDate,
						result.Description__c
					)
				);
			}
			narrativeResults.sort();
		}

		public Integer compareTo(Object anotherObjective) {
			Objective obj2 = (Objective) anotherObjective;

			//system.debug('inside obj sort with: ' + this.objectiveSObject.description__c +  ', and: ' + obj2.objectiveSObject.description__c);

			// RBO-60 - change sort to be by goal sort then by objective sort otherwise objectives added to goals later show up below new goal/obj combinations
			// first sort on goal sort
			if (this.objectiveSObject.action_plan_goal__r.sort_order__c > obj2.objectiveSObject.action_plan_goal__r.sort_order__c) {
				return 1;
			}  else if ( this.objectiveSObject.action_plan_goal__r.sort_order__c == obj2.objectiveSObject.action_plan_goal__r.sort_order__c) {
				if (this.objectiveSObject.sort_order__c > obj2.objectiveSObject.sort_order__c) {
					return 1;
				} else if ( this.objectiveSObject.sort_order__c == obj2.objectiveSObject.sort_order__c ){
					if ( this.objectiveSObject.createddate > obj2.objectiveSObject.createddate) {
						return 1;
					} else {
						return -1;
					}
				} else {
					return -1;
				}
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

	public class Seizure implements Comparable {
		public DateTime createdDate { get; set; }
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public Long duration { get; set; }
		public Id observedById { get; set; }
		public String observedByName { get; set; }
		public Seizure__c seizureSObject { get; set; }

		public Seizure(Seizure__c seizure) {
			this.seizureSObject = seizure;
			this.createdDate = seizure.CreatedDate;
			this.startTime = seizure.Start_DateTime__c;
			this.endTime = seizure.End_DateTime__c;
			this.duration = (seizure.End_DateTime__c.getTime() - seizure.Start_DateTime__c.getTime()) / 1000;
			this.observedById = seizure.Observed_By__c;
			this.observedByName = seizure.Observed_By__r.Name;
		}

		public Seizure(String jsonString) {
			this((Seizure__c) JSON.deserialize(jsonString, Seizure__c.class));
		}

		public String serialize() {
			return JSON.serialize(this.seizureSObject);
		}

		public Integer compareTo(Object anotherSeizureObject) {
			Seizure anotherSeizure = (Seizure) anotherSeizureObject;
			if (this.startTime < anotherSeizure.startTime) {
				return -1;
			} else if (this.startTime == anotherSeizure.startTime) {
				return 0;
			} else {
				return 1;
			}
		}
	}

	public class IsolationEvent implements Comparable {
		public DateTime createdDate { get; set; }
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public String status { get; set; }
		public String type { get; set; }
		public Evaluation_Response__c eventSObject { get; set; }

		public IsolationEvent(Evaluation_Response__c event) {
			this.eventSObject = event;
			this.createdDate = event.CreatedDate;
			this.startTime = event.Isolation_Event_Start_Date__c;
			this.endTime = event.Isolation_Event_End_Date__c;
			this.status = event.Isolation_Status__c;
			this.type = event.Isolation_Type__c;
		}

		public IsolationEvent(String jsonString) {
			this((Evaluation_Response__c) JSON.deserialize(jsonString,
				Evaluation_Response__c.class));
		}

		public String serialize() {
			return JSON.serialize(this.eventSObject);
		}

		public Integer compareTo(Object anotherEventObject) {
			IsolationEvent anotherEvent = (IsolationEvent) anotherEventObject;
			if (this.createdDate < anotherEvent.createdDate) {
				return -1;
			} else if (this.createdDate == anotherEvent.createdDate) {
				return 0;
			} else {
				return 1;
			}
		}
	}

	public class RestraintEvent implements Comparable {
		public DateTime createdDate { get; set; }
		public DateTime startTime { get; set; }
		public DateTime endTime { get; set; }
		public String status { get; set; }
		public Decimal score { get; set; }

		public RestraintEvent(Evaluation__c event, Decimal score) {
			this.createdDate = event.CreatedDate;
			this.startTime = event.Shift_Start_Time__c;
			this.endTime = event.Shift_End_Time__c;
			this.status = event.Status__c;
			this.score = score;
		}

		public RestraintEvent(String jsonString) {
			RestraintEvent event = (RestraintEvent) JSON.deserialize(jsonString,
				RestraintEvent.class);
			this.createdDate = event.createdDate;
			this.startTime = event.startTime;
			this.endTime = event.endTime;
			this.status = event.status;
			this.score = event.score;
		}

		public String serialize() {
			return JSON.serialize(this);
		}

		public Integer compareTo(Object anotherEventObject) {
			RestraintEvent anotherEvent = (RestraintEvent) anotherEventObject;
			if (this.createdDate < anotherEvent.createdDate) {
				return -1;
			} else if (this.createdDate == anotherEvent.createdDate) {
				return 0;
			} else {
				return 1;
			}
		}
	}

	public class VitalsDetail implements Comparable {
		public DateTime createdDate { get; set; }
		public DateTime dateTaken { get; set; }
		public Decimal heartRate { get; set; }
		public String bloodPressure { get; set; }
		public String o2 { get; set; }
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
					if (result.Text_Under_250__c != null && result.Text_Under_250__c != '') {
						this.o2 = result.Text_Under_250__c;
					} else if (result.Number_No_Decimal__c != null) {
						this.o2 = String.valueOf(result.Number_No_Decimal__c);
					}
				} else if (result.Eval__r.Field_Name__c == 'Temperature' || result.Eval__r.Field_Name__c == 'Temperature (F)') {
					this.temperature = result.Text_Under_250__c;
				} else if (result.Eval__r.Field_Name__c == 'Date' || result.Eval__r.Field_Name__c == 'Date/Time' || result.Eval__r.Field_Name__c == 'Observed Date/Time') {
					this.dateTaken = result.Date_Time__c;
				}
				if (this.createdDate == null || result.CreatedDate < this.createdDate) {
					this.createdDate = result.CreatedDate;
				}
			}
		}

		public VitalsDetail(String jsonString) {
			VitalsDetail detail = (VitalsDetail) JSON.deserialize(jsonString,
				VitalsDetail.class);
			this.createdDate = detail.createdDate;
			this.dateTaken = detail.dateTaken;
			this.heartRate = detail.heartRate;
			this.bloodPressure = detail.bloodPressure;
			this.temperature = detail.temperature;
			this.o2 = detail.o2;
		}

		public String serialize() {
			return JSON.serialize(this);
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

	public class DiagnosticsIvEvaluation {
		public Action_Plan_Summary_Result__c resultSObject { get; set; }
		public String dressingChange { get; set; }
		public Decimal externalCatheterLength { get; set; }
		public Decimal armCircumference { get; set; }
		public Decimal totalCatheterLength { get; set; }
		public String sourceOfInformation { get; set; }
		public String comment { get; set; }

		public DiagnosticsIvEvaluation(String dressingChange, Decimal externalCatheterLength, Decimal armCircumference, Decimal totalCatheterLength, String sourceOfInformation, String comment) {
			// This constructor is only used for JSON (de-)serializing. Don't
			// use it for any other purpose
			this.dressingChange = dressingChange;
			this.externalCatheterLength = externalCatheterLength;
			this.armCircumference = armCircumference;
			this.totalCatheterLength = totalCatheterLength;
			this.sourceOfInformation = sourceOfInformation;
			this.comment = comment;
		}

		public DiagnosticsIvEvaluation(Id summaryId) {
			this.resultSObject = new Action_Plan_Summary_Result__c(
					Action_Plan_Summary__c = summaryId,
					Type__c = 'DiagnosticsIvEvaluation'
					);
		}
		public DiagnosticsIvEvaluation(Action_Plan_Summary_Result__c resultSObject) {
			this.resultSObject = resultSObject;
			DiagnosticsIvEvaluation r = (DiagnosticsIvEvaluation) JSON.deserialize(resultSObject.Data__c, DiagnosticsIvEvaluation.class);
			this.dressingChange = r.dressingChange;
			this.externalCatheterLength = r.externalCatheterLength;
			this.armCircumference = r.armCircumference;
			this.totalCatheterLength = r.totalCatheterLength;
			this.sourceOfInformation = r.sourceOfInformation;
			this.comment = r.comment;
		}
		public DiagnosticsIvEvaluation updateData() {
			// Update the data field for the underlying Summary Result object
			this.resultSObject.Data__c = JSON.serialize(
				new DiagnosticsIvEvaluation(
					this.dressingChange,
					this.externalCatheterLength,
					this.armCircumference,
					this.totalCatheterLength,
					this.sourceOfInformation,
					this.comment
				)
			);
			return this;
		}

	}

	private String getDiagnosticsIVs(Action_Summary__c summary) {
		String vals = '';
		//EC-169, 211 : requirement - Question 11 will be added to the Summaries only when PICC or Central is selected on a finalized PBS's Diagnostics/IV panel.
		Map<Id, Evaluation__c> evaluations = new Map<Id, Evaluation__c>([
			SELECT Id FROM Evaluation__c
			 WHERE ServiceAssignment__c = :summary.Service_Assignment__c
			   AND Head_to_toe_Status__c = 'Final'
			   AND Shift_Start_Time__c != null
			   AND Shift_End_Time__c <= :summary.End_Date__c
			   AND Shift_Start_Time__c >= :summary.Start_Date__c
		]);
		for (Eval_Value__c value: [
			SELECT Id, Text_Under_250__c
			  FROM Eval_Value__c
			 WHERE What_Id__c IN :evaluations.keySet()
			   AND Eval__r.Category__c = 'Diagnostics'
			   AND Eval__r.Sub_Category__c = 'IV'
			   AND Eval__r.htmlid__c = 'ivType'
			   AND Eval__r.Visible__c = true
		]) {
			if (value.Text_Under_250__c.toUpperCase().contains('PICC') || value.Text_Under_250__c.toUpperCase().contains('CENTRAL') ) {
				vals += value.Text_Under_250__c.toUpperCase();
			}
		}
		return vals;
	}

	public class totalInfo{
		public integer Occurrences {get; set;}
		public integer metObj {get; set;}
		public integer notMetObj {get; set;}
		public integer percMetObj {get; set;}


		public totalInfo(string i){
		}

	}
}