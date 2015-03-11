public with sharing class EvalDynamicExt {

	public ID evalID;
	public ID PBSID { get; set; }
	public ID AdmID {get; set;}
	public ID SAID {get; set;}
	public Evaluation__c thisEval {get; set;}
	public string evalType {get; set;}
	public string subCat {get; set;}
	public string cat{get; set;}
	
	public Boolean showMainComponent {get; set;}
	public string key {get; set;}
	
	public EvalDynamicExt(){
		// get the record
		evalID =  ApexPages.currentPage().getParameters().get('evalID');
		evalType = ApexPages.currentPage().getParameters().get('evaltype');
		cat = ApexPages.currentPage().getParameters().get('Category');
		subCat = ApexPages.currentPage().getParameters().get('SubCategory');
		key = evalType+' ~ '+cat+' ~ '+subCat;
		showMainComponent = true;
		
		thisEval = [ select id, serviceassignment__c, serviceassignment__r.admission__c, serviceassignment__r.admission__r.person_being_served__c from Evaluation__c where ID = :evalID LIMIT 1];
		
		if ( thisEval != null ) {
			PBSID = thisEval.serviceassignment__r.admission__r.person_being_served__c;
			AdmID = thisEval.serviceassignment__r.admission__c;
			SAID = thisEval.serviceassignment__c;
		}
			
	}

	public void myAction(){
		string displayKey = evalType+' ~ '+cat+' ~ '+subCat;
		key = displayKey;
		
		if(key == 'Residential ~ Fall Risk Assessment ~ Fall Assessment'){
			showMainComponent = false;
		}
		else{
			showMainComponent = true;	
		}
		
	}
}