public with sharing class EvalRepeaters {
	public ID evaluationID { get; set;}
	public ID evalTypeId { get; set;}
	public string evalname{get; set;}
	public string operatingGroup{get; set;}

	transient public boolean anyErrors;
	public boolean getAnyErrors() {return (numErrors > 0);}
	transient public boolean anyEmpty;
	public boolean getAnyEmpty() {
		// for restraint assessment we need a special case to reduce the # of empties by 1 since you can't fill out the 2nd subcat
		//&& condition addded by Sravan as Restraint Event Should behave normally when the first section is filled out especially disabling the Complete button when Second section is empty
		if ( evalname == 'Restraint Event' && parentEvalStatus == 'Not Restrained') {
			numEmpty -=1;
		}
		return (numEmpty > 0);}
	transient public ID parentEvalOwnerId { get; set; }
	transient public string parentEvalStatus { get; set; }
	transient public string parentShiftStatus { get; set; }
	transient public Boolean parentHasOpenAsmt{get; set;} //Used for restraints

	transient private integer numEmpty;
	transient private integer numErrors;
	transient public String evalDataKeys { get; set;}
	transient public Map<String, List<EvalValueWrapper>> evalDataList { get; set;}
	// this is the list of all possible cat/subcat for this eval type
	transient public list<EvalRepeaterWrapper> evals;
	transient public Map<String, Category> categoryMap { get; set; }
	transient public List<String> categories;

	public List<String> getCategories() {
		if (this.categories == null) {
			populateData();
		}
		return this.categories;
	}

	public EvalRepeaters(){
		evaluationID = ApexPages.CurrentPage().getParameters().get('evalId');
		evalname = ApexPages.CurrentPage().getParameters().get('evalType');
		operatingGroup = ApexPages.CurrentPage().getParameters().get('opGrp');
		numEmpty = 0;
		numErrors = 0;

		evalTypeId = [Select id from Eval_Type__c where name = :evalname and Category__c = :operatingGroup limit 1].id;

		refreshParentEval();
		initcanEditEvalType();
	}

	public list<EvalRepeaterWrapper> populateData(){
		if (this.evals == null ) {
			evals = new list<EvalRepeaterWrapper>();
			categoryMap = new Map<String, Category>();
			categories = new List<String>();
			evalDataList = new Map<String, List<EvalValueWrapper>>() ;

			// get list of all sections
			List<AggregateResult> evalTypes = [
				select category__c, sub_category__c, sub_sub_category__c
				  from eval__c
				 where eval_type__c = :evalTypeId
				group by cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c, category__c,
				         sub_category__c, sub_sub_category__c
				order by cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c];

			// get list of repeatables
			List<AggregateResult> evalRepeats = [
				select category__c, sub_category__c, sub_sub_category__c
				 from eval__c
				where eval_type__c = :evalTypeId
				  and eval__c.field_name__c = 'isRepeatable'
				  and eval__c.visible__c = false
				group by cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c, category__c,
				         sub_category__c, sub_sub_category__c
				order by cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c];

			// first throw the repeats into a map by composite key
			string compositeKey = '';
			Set<string> setRepeaters = new set<String>();
			for (AggregateResult ag : evalRepeats){
				compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));
				setRepeaters.add( compositeKey );
			}

			// now combine the results with the complete set of eval fields
			compositeKey = '';
			boolean rep = false;
			for (AggregateResult ag : evalTypes){
				compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));
				rep = setRepeaters.contains(compositeKey);
				evals.add(new EvalRepeaterWrapper(String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')),
					String.valueOf(ag.get('sub_sub_category__c')), compositeKey, rep ));

			}
			// all sections are empty to start
			numEmpty = evals.size();
			buildEvalDataList( evals );
		}
		return evals;
	}


	private void buildEvalDataList( List<EvalRepeaterWrapper> workingEvals ) {
		refreshParentEval();
		numErrors = 0;
		evalDataKeys = '';

		List<AggregateResult> evalValues = [
			select eval_section_type__c, eval_section_id__c, eval__r.category__c,
			       eval__r.sub_category__c, eval__r.sub_sub_category__c, min(createddate) created,
			       owner.name, ownerid
			  from eval_value__c
			 where what_id__c = :evaluationID
			group by eval_section_type__c, eval_section_id__c, eval__r.category__c,
			         eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name, ownerid
			order by eval_section_type__c, eval__r.category__c, eval__r.sub_category__c,
			         eval__r.sub_sub_category__c, min(createddate) desc];

		String compositeKey = '';

		for (AggregateResult ag : evalValues){
			compositeKey = (string)ag.get('eval_section_type__c') + '~' + (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));
			EvalValueWrapper evw = new EvalValueWrapper(String.valueof(ag.get('eval_section_type__c')), String.valueof(ag.get('eval_section_id__c')), String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')),
					String.valueOf(ag.get('sub_sub_category__c')), String.valueOf(ag.get('name')), String.valueOf( ag.get('ownerid')), DateTime.valueOf( ag.get('created')), String.valueOf( ag.get('eval_section_id__c')) );

			if ( evalDataList.containsKey( compositeKey )) {

				// if it's the base type, reduce the number of empty sections
				if ( evw.sectionType == evalname) {
					numEmpty -= (evalDataList.get(compositeKey)).size() == 0 ? 1 : 0;
					system.debug( compositeKey + ' is not empty');
				}

				// add this entry to the list
				(evalDataList.get( compositeKey)).add(evw);
			}	else {
				// reduce the number of empty sections
				if ( evw.sectionType == evalname){
					system.debug( compositeKey + ' is not empty');
					numEmpty -= 1;
				}

				// create a new list and add entry
				evalDataList.put( compositeKey, new List<EvalValueWrapper>{ evw });
			}
		}
		for ( String key: evalDataList.keySet()) {
			evalDataKeys += key + '||';
		}

		List<AggregateResult> evalErrors = [
			select eval_section_type__c, eval_section_id__c, eval__r.category__c,
			       eval__r.sub_category__c, eval__r.sub_sub_category__c
			  from eval_value__c
			 where what_id__c = :evaluationID
			   and eval__r.field_name__c = 'isValid'
			   and eval_section_type__c = :evalname	// only look for errors in the base sections
			   and boolean__c = false
			group by eval_section_type__c, eval_section_id__c, eval__r.category__c,
			         eval__r.sub_category__c, eval__r.sub_sub_category__c];

		compositeKey = '';

		for (AggregateResult ag : evalErrors){
			compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));
			//			system.debug(compositeKey);
			for (EvalRepeaterWrapper e : workingEvals)
				if ( e.compositekey == compositeKey) {
					e.numErrors = 1;
					numErrors += 1;
					break;
				}
		}

		for (EvalRepeaterWrapper repeater: evals) {
			if (!categoryMap.containsKey(repeater.cat)) {
				categories.add(repeater.cat);
				categoryMap.put(repeater.cat, new Category());
			}
			if (evalDataList.keySet().contains('Activity Log~' + repeater.compositeKey)) {
				repeater.hasActivityLogs = true;
			}
			if (evalDataList.keySet().contains(evalName + '~' + repeater.compositeKey)) {
				repeater.hasData = true;
			}
			if (repeater.numErrors > 0) {
				categoryMap.get(repeater.cat).hasError = true;
			}
			categoryMap.get(repeater.cat).panels.add(repeater);
		}

		for (Category category: categoryMap.values()) {
			Boolean completed = true;
			for (EvalRepeaterWrapper panel: category.panels) {
				if (panel.numErrors > 0 || !panel.hasData) {
					completed = false;
				}
			}
			category.completed = completed;
		}
	}

	private void refreshParentEval(){
		Evaluation__c[] parentEval = [ select id, ownerid, status__c, Has_Open_Assessment__c, head_to_toe_status__c from evaluation__c where id = :evaluationID ];
		if ( parentEval.size() == 1) {
			parentEvalOwnerID = parentEval[0].OwnerId;
			parentEvalStatus = parentEval[0].status__c;
			parentHasOpenAsmt = parentEval[0].Has_Open_Assessment__c;
			parentShiftStatus = parentEval[0].Head_to_Toe_status__c;
		}
		else {
			parentEvalOwnerID = null;
			parentEvalStatus = 'Completed'; // don't allow entry on anything
			parentHasOpenAsmt = false;
		}
	}

	public Boolean canEditEvalType {get;set;}
	// determines if this user can edit the given type of eval - used to show or hide the + button
	public Boolean initcanEditEvalType() {
		canEditEvalType = false;
		// only tier iii can add/edit resident, restraint, and nurses shift doc
		PermissionSetAssignment[] assignments = [
			SELECT Id, PermissionSet.Name
			  FROM PermissionSetAssignment
			 WHERE AssigneeId = :UserInfo.getUserId()
		];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Name);
		}

		// EC-305 - different users can add CNA entries now
		if ( permissionSets.contains('iServe_Tier_III') || permissionSets.contains('iServe_Tier_II')) {
			canEditEvalType = true;
		}
		if (evalname.indexOf('CNA') < 0 && permissionSets.contains('iServe_Tier_I')) {
			canEditEvalType = true;
		}

		return canEditEvalType;
	}

	public class EvalValueWrapper {

		public string sectiontype { get; set;}
		public string sectionid { get; set;}
		public string cat { get; set;}
		public string subcat {get; set;}
		public string subsubcat { get; set;}
		public string owner { get; set ;}
		public datetime created { get; set; }
		public string created24 { get; set; }
		public string entryID { get; set; }
		public string ownerID { get; set; }

		public EvalValueWrapper ( String sectiontype, String sectionid, String cat, String subcat, String subsubcat, String owner, String ownerID, Datetime created, string entryid){
			this.sectiontype = sectiontype;
			this.sectionid = sectionid;
			this.cat = cat;
			this.subcat = subcat;
			this.subsubcat = subsubcat;
			this.owner = owner;
			this.ownerID  = ownerID;
			this.created = created;
			this.created24 = created.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
			this.entryID = entryid;
		}
	}


	public class EvalRepeaterWrapper{
		public string cat { get; set; }
		public string subcat{ get; set; }
		public string subsubcat{ get; set; }
		public string compositeKey{ get; set; }
		public integer numErrors { get; set; }
		public boolean repeatable { get; set; }
		public Boolean hasData { get; set; }
		public Boolean hasActivityLogs { get; set; }

		public EvalRepeaterWrapper(String cat, string subcat, string subsubcat, string compKey, boolean repeats){
			this.cat = cat;
			this.subcat = subcat;
			this.subsubcat = subsubcat;
			this.compositeKey = compKey;
			this.numErrors = 0;
			this.repeatable= repeats;
			this.hasData = false;
			this.hasActivityLogs = false;
		}
	}

	private class Category {
		public Boolean completed { get; set; }
		public Boolean hasError { get; set; }
		public List<EvalRepeaterWrapper> panels { get; set; }

		public Category() {
			this.completed = false;
			this.hasError = false;
			this.panels = new List<EvalRepeaterWrapper>();
		}
	}

}