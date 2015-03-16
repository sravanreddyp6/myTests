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
		key = evalType+'~'+cat+'~'+subCat;
		showMainComponent = true;
		
		thisEval = [ select id, serviceassignment__c, serviceassignment__r.admission__c, serviceassignment__r.admission__r.person_being_served__c from Evaluation__c where ID = :evalID LIMIT 1];
		
		if ( thisEval != null ) {
			PBSID = thisEval.serviceassignment__r.admission__r.person_being_served__c;
			AdmID = thisEval.serviceassignment__r.admission__c;
			SAID = thisEval.serviceassignment__c;
		}
			
	}

	public void myAction(){
		string displayKey = evalType+'~'+cat+'~'+subCat;
		key = displayKey;
		
		if(key == 'Residential~Fall Risk Assessment~Fall Assessment' || key == 'Head to Toe~Skin/Body~Wound Detail' || key == 'Head to Toe~Skin/Body~Pressure Ulcer Details'
			|| key == 'Residential~Skin/Body~Skin Assessment'){
			createEvalValueRecord(key);
			showMainComponent = false;
		}
		else{
			showMainComponent = true;	
		}
		
	}
	
	
	private void createEvalValueRecord(String key){
		String sectionId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
        String sectionType = evalType;
		boolean isValidVal;
        List<Eval_Value__c> listEvalValues = [ select id from eval_value__c
                                                where what_id__c = :evalId
                                                  and what_id_object__c = 'Evaluation__c'
                                                  and eval__r.category__c = :cat
                                                  and eval__r.sub_category__c = :subcat];

        if (listEvalValues.size() == 0){
            list<Eval__c> evals = [ select id, Field_Name__c, Sub_Category__c from Eval__c
						             where eval_type__r.name = :evalType
						               and category__c = :cat
						               and sub_category__c = :subcat
						               and visible__c = true
						            order by category_sequence__c, sub_category_sequence__c, field_sequence__c];
        
	        list<Eval_Value__c> vals = new list<Eval_Value__c>();
         
	        for (Eval__c e : evals){
	        	  if (e.Field_Name__c=='IsValid' && (e.Sub_Category__c == 'Fall Assessment' || e.Sub_Category__c == 'Skin Assessment'))
                    isValidVal = !EvalDynamicExt.validateAssessmentError(evalId, e.Sub_Category__c == 'Fall Assessment' ? 'Fall Risk Assessment Domain' :'Skin Assessment Domain');
                  else
                    isValidVal = true;      
	              vals.add(new eval_value__c(Eval__c = e.id, 
	                                         Eval_Section_Id__c = sectionId,
	                                         Eval_Section_Type__c = sectionType,
	                                         Boolean__c = isValidVal,
	                                         what_id__c = evalID,
	                                         what_id_object__c = 'Evaluation__c'));
	        }
	        insert vals;        	
        } else {
            sectionType = 'Activity Log';
        }
		
	}
	
	 public static boolean validateAssessmentError(Id evalId, string DomainName){
        Boolean error = false;
        List<Assessment_Response__c> currentResponses = [SELECT Id, Rating__c FROM Assessment_Response__c WHERE Assessment__r.Evaluation__c = :evalId AND Question__r.Question_Domain__r.Name = :DomainName];
        for(Assessment_Response__c resp: currentResponses){
            if(resp.Rating__c == null){
                error = true;
                break;
            }
            
        }
        
        return error;
    }
    
	
}