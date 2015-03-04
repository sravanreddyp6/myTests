public with sharing class EvalRepeaters {
	public ID evaluationID { get; set;}
	public string evalname{get; set;}
	public string operatingGroup{get; set;}
	public boolean anyErrors { get { return (numErrors > 0);} set; }
	public boolean anyEmpty{ get { return (numEmpty > 0);} set;}
	
	private integer numEmpty;
	private integer numErrors;
	
	public String evalDataKeys { get; set;}
	public Map<String, List<EvalValueWrapper>> evalDataList { get; set;}

	// this is the list of all possible cat/subcat for this eval type	
	public list<EvalRepeaterWrapper> evals;
	public list<EvalRepeaterWrapper> getEvals(){
		
		List<EvalRepeaterWrapper> evalWraps = new list<EvalRepeaterWrapper>();
		evalDataList = new Map<String, List<EvalValueWrapper>>() ;
		
		List<AggregateResult> evalTypes = [select	category__c, sub_category__c, sub_sub_category__c
											 from 	eval__c
											where	eval_type__r.name = :evalname 
											  and 	eval_type__r.Category__c = :operatingGroup
										group  by 	cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c, category__c, sub_category__c, sub_sub_category__c
										order by	cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c];
		
		
		string compositeKey = '';								
		for (AggregateResult ag : evalTypes){
			compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));									
			
			evalWraps.add(new EvalRepeaterWrapper(String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')), 
												String.valueOf(ag.get('sub_sub_category__c')), compositeKey ));
												
		}
		system.debug(evalWraps);
		
		// all sections are empty to start
		numEmpty = evalWraps.size();
		system.debug( 'STARTING EMPTY: ' + numEmpty);	
		buildEvalDataList( evalwraps );
		system.debug( 'ANY EMPTY? ' + numEmpty);
		system.debug( 'ANY ERRORS? ' + numErrors);
		return evalWraps;
	}
	
	
	private void buildEvalDataList( List<EvalRepeaterWrapper> workingEvals ) {
		
		evalDataKeys = '';
				
		List<AggregateResult> evalValues = [ select eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, min(createddate) created, owner.name, ownerid 
												from eval_value__c
												where what_id__c = :evaluationID
												and eval__r.field_name__c not in ('isValid', 'ErrorMsg')
												group by eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name, ownerid
												order by eval_section_type__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,  min(createddate) desc];

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
		system.debug('Data List keys ' +  evalDataList.keyset().size());
		system.debug(evalDataList);
		
		for ( String key: evalDataList.keySet()) {
			evalDataKeys += key + '||';
		}
		system.debug(evalDataKeys);
	
	
		List<AggregateResult> evalErrors = [ select count(id), eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, min(createddate) created, owner.name, ownerid 
												from eval_value__c
												where what_id__c = :evaluationID
												and eval__r.field_name__c = 'isValid'
												and boolean__c = false
												group by eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name, ownerid
												order by eval_section_type__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,  min(createddate) desc];
		compositeKey = '';
		
		for (AggregateResult ag : evalErrors){
			if ( (string)ag.get('eval_section_type__c') == evalname ) { // only look for errors in the base sections
				compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));									
				system.debug(compositeKey);
				for (EvalRepeaterWrapper e : workingEvals)
					if ( e.compositekey == compositeKey) 
						e.numErrors = (integer)ag.get('expr0');
			}
		}
		
		
	}
	
	
	public EvalRepeaters(){
		
		
	}


	public boolean getanyErrors() { 
		// return whether there is an error in any section for this eval 
		return false;
	}
	
	public class EvalValueWrapper {
		
		public string sectiontype { get; set;}
		public string sectionid { get; set;}
		public string cat { get; set;}
		public string subcat {get; set;}
		public string subsubcat { get; set;}
		public string owner { get; set ;}
		public datetime created { get; set; }
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
			this.entryID = entryid;
		}
	}


	public class EvalRepeaterWrapper{
		public string cat {get; set;}
		public string subcat{get; set;}
		public string subsubcat{get; set;}
		public string compositeKey{ get; set; }
		public integer numErrors { get; set; }
		
		public EvalRepeaterWrapper(String cat, string subcat, string subsubcat, string compKey){
			this.cat = cat;
			this.subcat = subcat;
			this.subsubcat = subsubcat;
			this.compositeKey = compKey;
			this.numErrors = 0;
		}
	}

}