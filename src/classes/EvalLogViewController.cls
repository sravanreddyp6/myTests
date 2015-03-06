public with sharing class EvalLogViewController {

	public ID evalID { get; set;}
	public string evalname{get; set;}
	public string opGrp {get; set;}
	public string cat {get;set;}
	public string subcat {get;set;}
	public string subsubcat {get;set;}
	
	
	public List<EvalValueWrapper> evalDataList { get; set;}
	public EvalLogViewController(){
		evalID = ApexPages.currentPage().getParameters().get('evalID');
		evalname=ApexPages.currentPage().getParameters().get('evalname');
		opGrp = ApexPages.currentPage().getParameters().get('opGrp');
		cat=ApexPages.currentPage().getParameters().get('cat');
		subcat = ApexPages.currentPage().getParameters().get('subCat');
		evalDataList = new List<EvalValueWrapper>();
		
		List<AggregateResult> evalValues = [ select 
													eval_section_type__c, 
													eval_section_id__c, 
													eval__r.category__c, 
													eval__r.sub_category__c, 
													eval__r.sub_sub_category__c, 
													min(createddate) created, 
													owner.name, 
													ownerid 
												from eval_value__c
												where what_id__c = :evalID
												and	eval__r.category__c = :cat
												and eval__r.sub_category__c = :subcat
												and eval__r.field_name__c not in ('isValid', 'ErrorMsg')
												group by eval_section_type__c, eval_section_id__c, eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name, ownerid
												order by eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,  min(createddate)
											];
						
		String compositeKey = '';
		
		for (AggregateResult ag : evalValues){
			
			compositeKey = (string)ag.get('eval_section_type__c') + '~' + (string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c'));									
			EvalValueWrapper evw = new EvalValueWrapper(String.valueof(ag.get('eval_section_type__c')), String.valueof(ag.get('eval_section_id__c')), String.valueOf(ag.get('category__c')), String.valueOf(ag.get('sub_category__c')), 
												String.valueOf(ag.get('sub_sub_category__c')), String.valueOf(ag.get('name')), String.valueOf( ag.get('ownerid')), DateTime.valueOf( ag.get('created')), String.valueOf( ag.get('eval_section_id__c')) );
			evalDataList.add( evw );			
		}
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
	
	
}