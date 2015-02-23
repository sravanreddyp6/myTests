public with sharing class EvalRepeaters {
	public ID evaluationID { get; set;}
	public string evalname{get; set;}
	public string operatingGroup{get; set;}
	
	public list<EvalRepeaterWrapper> evals;
	public list<EvalRepeaterWrapper> getEvals(){
		evals = new list<EvalRepeaterWrapper>();
		
		List<AggregateResult> evalTypes = [select	category__c, sub_category__c, sub_sub_category__c
											 from 	eval__c
											where	eval_type__r.name = :evalname 
											  and 	eval_type__r.Category__c = :operatingGroup
										group  by 	category__c, sub_category__c, sub_sub_category__c];
										
		for (AggregateResult ag : evalTypes){
			evals.add(new EvalRepeaterWrapper(String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')), 
												String.valueOf(ag.get('sub_sub_category__c')) ));
		}
		return evals;
	}
	
	public EvalRepeaters(){
		
	}






	public class EvalRepeaterWrapper{
		public string cat {get; set;}
		public string subcat{get; set;}
		public string subsubcat{get; set;}
		
		public EvalRepeaterWrapper(String cat, string subcat, string subsubcat){
			this.cat = cat;
			this.subcat = subcat;
			this.subsubcat = subsubcat;
		}
	}

}