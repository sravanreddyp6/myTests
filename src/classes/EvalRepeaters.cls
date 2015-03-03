public with sharing class EvalRepeaters {
	public ID evaluationID { get; set;}
	public string evalname{get; set;}
	public string operatingGroup{get; set;}
	
	public String evalDataKeys { get; set;}
	public Map<String, List<EvalValueWrapper>> evalDataList;
	public Map<String, List<EvalValueWrapper>> getEvalDataList() {
		
		Map<String, List<EvalValueWrapper>> evalData = new Map<String, List<EvalValueWrapper>>();
		
		List<AggregateResult> evalValues = [ select eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, min(createddate) created, owner.name, ownerid 
												from eval_value__c
												group by eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name, ownerid
												order by eval_section_type__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,  min(createddate) desc];

		String compositeKey = '';
		
		for (AggregateResult ag : evalValues){
			
			compositeKey = (string)ag.get('eval_section_type__c') + '~' + (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));									
			EvalValueWrapper evw = new EvalValueWrapper(String.valueof(ag.get('eval_section_type__c')), String.valueof(ag.get('eval_section_id__c')), String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')), 
												String.valueOf(ag.get('sub_sub_category__c')), String.valueOf(ag.get('name')), String.valueOf( ag.get('ownerid')), DateTime.valueOf( ag.get('created')), String.valueOf( ag.get('eval_section_id__c')) );
			
			
			if ( evalData.containsKey( compositeKey )) {
				// add this entry to the list		
				(evalData.get( compositeKey)).add(evw);
			}	else {
				// create a new list and add entry
				evalData.put( compositeKey, new List<EvalValueWrapper>{ evw });
			}	
		}
		system.debug(evalData);
		
		
		for ( String key: evalData.keySet()) {
			evalDataKeys += key + '||';
		}
		system.debug(evalDataKeys);
		return evalData;
		
	}
	
	public list<EvalRepeaterWrapper> evals;
	public list<EvalRepeaterWrapper> getEvals(){
		evals = new list<EvalRepeaterWrapper>();
		
		List<AggregateResult> evalTypes = [select	category__c, sub_category__c, sub_sub_category__c
											 from 	eval__c
											where	eval_type__r.name = :evalname 
											  and 	eval_type__r.Category__c = :operatingGroup
										group  by 	cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c, category__c, sub_category__c, sub_sub_category__c
										order by	cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c];
		
		
		string compositeKey = '';								
		for (AggregateResult ag : evalTypes){
			compositeKey = (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));									
			
			evals.add(new EvalRepeaterWrapper(String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')), 
												String.valueOf(ag.get('sub_sub_category__c')), compositeKey ));
			evalDataList.put( compositeKey, new List<EvalValueWrapper>());	// stick in an empty list
		}
		system.debug(evals);
		return evals;
	}
	
	public EvalRepeaters(){
		evalDataList = new Map<String, List<EvalValueWrapper>>();
		evalDataKeys = '';
		getEvalDataList();
		
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
		
		public EvalRepeaterWrapper(String cat, string subcat, string subsubcat, string compKey){
			this.cat = cat;
			this.subcat = subcat;
			this.subsubcat = subsubcat;
			this.compositeKey = compKey;
		}
	}

}