public with sharing class EvalDynamicExt {

	public ID evalID;
	public ID PBSID { get; set; }
	public ID AdmID {get; set;}
	public ID SAID {get; set;}
	public Evaluation__c thisEval {get; set;}
	public string evalType {get; set;}
	public string subCat {get; set;}
	public string cat {get; set;}
    public string evalSecId {get; set;}
    public string evalSecType {get; set;}
    
	public Boolean showMainComponent {get; set;}
	public string key {get; set;}
	
	
	public Boolean showDisregard {get; set;}
	public Boolean showRevise {get; set;}
	public Boolean showEsign{get; set;}
	public Boolean showshiftDone{get; set;}
	
	public EvalDynamicExt(){
		// get the record
		evalID =  ApexPages.currentPage().getParameters().get('evalID');
		evalType = ApexPages.currentPage().getParameters().get('evaltype');
		cat = ApexPages.currentPage().getParameters().get('Category');
		subCat = ApexPages.currentPage().getParameters().get('SubCategory');
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		
		
		showMainComponent = true;
		showDisregard = false;
		showRevise = false;
		showEsign = false;
		showshiftDone = false;
		
		thisEval = [ select id, Name, Status__c, Head_to_Toe_Status__c, Owner.Name, Shift_Start_Time__c, Shift_End_time__c, Recordtype.Name, CreatedDate, serviceassignment__c, serviceassignment__r.admission__c, serviceassignment__r.admission__r.person_being_served__c, serviceassignment__r.admission__r.person_being_served__r.AccountId from Evaluation__c where ID = :evalID LIMIT 1];
		
		if ( thisEval != null ) {
			PBSID = thisEval.serviceassignment__r.admission__r.person_being_served__c;
			AdmID = thisEval.serviceassignment__r.admission__c;
			SAID = thisEval.serviceassignment__c;
			
			controlButtons();
		}
				
	}

	public void myAction(){
		string displayKey = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		key = displayKey;
		
		if(key == 'Residential~Fall Risk Assessment~Fall Assessment~Residential' || key.contains('Head to Toe~Skin/Body~Wound Detail') || key.contains('Head to Toe~Skin/Body~Pressure Ulcer Details')
			|| key == 'Residential~Skin/Body~Skin Assessment~Residential'){
			createEvalValueRecord(key);
			showMainComponent = false;
		}
		else{
			showMainComponent = true;	
		}
		
	}
	
	private void createEvalValueRecord(String key){
		String sectionId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
		boolean isValidVal;
        List<Eval_Value__c> listEvalValues = [ select id from eval_value__c
                                                where what_id__c = :evalId
                                                  and what_id_object__c = 'Evaluation__c'
                                                  and eval__r.category__c = :cat
                                                  and eval__r.sub_category__c = :subcat];

        list<Eval__c> repeatableEval = [ select id from Eval__c
	                                     where eval_type__r.name = :evalType
	                                       and category__c = :cat
	                                       and sub_category__c = :subcat
	                                       and Field_Name__c = 'isRepeatable' 
	                                       and visible__c = false ];

        list<Eval__c> evals = [ select id, Field_Name__c, Sub_Category__c from Eval__c
                                     where eval_type__r.name = :evalType
                                       and category__c = :cat
                                       and sub_category__c = :subcat
                                       and visible__c = true
                                    order by category_sequence__c, sub_category_sequence__c, field_sequence__c];
        
        list<Eval_Value__c> vals = new list<Eval_Value__c>();

        if (listEvalValues.size() == 0 && (evalSecId == null || evalSecId == '') ){         // the initial entry 
	        for (Eval__c e : evals){
	        	  if (e.Field_Name__c=='IsValid' && (e.Sub_Category__c == 'Fall Assessment' || e.Sub_Category__c == 'Skin Assessment'))
                    isValidVal = !EvalDynamicExt.validateAssessmentError(evalId, e.Sub_Category__c == 'Fall Assessment' ? 'Fall Risk Assessment Domain' :'Skin Assessment Domain');
                  else
                    isValidVal = true;      
	              vals.add(new eval_value__c(Eval__c = e.id, 
	                                         Eval_Section_Id__c = sectionId,
	                                         Eval_Section_Type__c = evalSecType,
	                                         Boolean__c = isValidVal,
	                                         what_id__c = evalID,
	                                         what_id_object__c = 'Evaluation__c'));
	        }
        } else if ( repeatableEval.size() > 0 && (evalSecId == null || evalSecId == '') ){   // Activity log Entry - evalSecId will be empty only when Adding in a new entry. 
            for (Eval__c e : evals){
            	if (e.Field_Name__c=='IsValid')
            	       isValidVal = true;
            	             
                vals.add(new eval_value__c(Eval__c = e.id, 
                                             Eval_Section_Id__c = sectionId,
                                             Eval_Section_Type__c = evalSecType,
                                             Boolean__c = isValidVal,
                                             what_id__c = evalID,
                                             what_id_object__c = 'Evaluation__c'));
            }
        }        
		insert vals;
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
    
    public pageReference reviseAssessment() {
    
    	//Roll back all the DML operations in case of any failure in the process of Cloning.
    	Savepoint sp = Database.setSavepoint();
    		try{
    			Evaluation__c clonedEval = EvalDynamicExt.cloneEvalContent(thisEval, this.evalType, 'Care Meridian');
    			PageReference pg = new PageReference('/apex/EvalDynamic?evalId='+clonedEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
    			pg.setRedirect(true);
    			return pg;
    		}
    		catch(exception e){
    			Database.rollback(sp);
    			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
    			return null;
    			
    		}
	}
	
	
	public pageReference disregardAssessment() {
		
		
		
		if(evalType == 'Residential'){
			thisEval.Status__c = 'Disregard';
			try{
				update thisEval;
				PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
				pageRef.setRedirect(true);
				return pageRef;
			}
			catch(exception e){
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;	
			}
			
		}
		
		else if(evalType == 'Head to Toe'){
			
			Savepoint sp2 = Database.setSavepoint();
			
			thisEval.Status__c = 'Disregard';
			thisEval.Head_to_toe_Status__c = 'Disregard';
			
			try{
				
				update thisEval;
				Evaluation__c clonedShift = EvalDynamicExt.cloneEvalContent(thisEval, this.evalType, 'Care Meridian');
				PageReference pg = new PageReference('/apex/EvalDynamic?evalId='+clonedShift.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
	    		pg.setRedirect(true);
	    		return pg;
			}
			catch(exception e){
				Database.rollback(sp2);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;	
				
			}
			
		}
		
		return null;
	}
	
	public pageReference completeShift() {
		
		thisEval.Status__c = 'Completed';
		thisEval.Shift_End_time__c = system.Now();
		try{
			update thisEval;
			PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch(exception e){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
			return null;	
		}
		
	}
	
	//Generic Clone functionality to copy Eval Value records.
	public static Evaluation__c cloneEvalContent(Evaluation__c eval, string evalType, string operatingGroup){
		
		Evaluation__c currentEval = eval;
		id currentEvalId = currentEval.Id;
		//CLone the current Evaluation and Insert a new one with Draft Status
		Evaluation__c clonedEval = currentEval.clone(false);
		clonedEval.Status__c = 'Draft'; //Common for all types
		clonedEval.Signed_At__c = null;
		clonedEval.Head_to_toe_Signed_At__c = null;
		
		if(evalType == 'Head to Toe'){
			clonedEval.Head_to_toe_status__c = 'Draft';
		}
		
    	insert clonedEval;
    		
    	//Creation of Assessment records is specific to Residential Assessment. Not required in in Head to Toe!!
    	if(evalType == 'Residential') {
    		//Query the existing Assessment Responses and Assign the Score and Rating to the cloned Responses
    		Map<Id, Assessment_Response__c> responseMap = new Map<Id, Assessment_Response__c>();
    		for(Assessment_Response__c resp: [SELECT Id, Rating__c, Score__c, Question__c FROM Assessment_Response__c WHERE Assessment__r.Evaluation__c =: currentEval.Id AND Rating__c != null]){
    			responseMap.put(resp.Question__c, resp);
    		}
    		
    		Assessment__c fallSkinAsmt = new Assessment__c(Name=currentEval.Name+' Resident Assessment',Type__c ='Resident Assessment',Service_Assignment__c = currentEval.serviceassignment__c, Admission__c = currentEval.serviceassignment__r.admission__c, AccountPerson__c = currenteval.serviceassignment__r.admission__r.person_being_served__r.AccountId);
    		fallSkinAsmt.Evaluation__c = clonedEval.Id;
    		
    		insert fallSkinAsmt; // This line will invoke the trigger on the Assessment__c object and inserts Assessment domain results and Assessment response records.
    		
    		List<Assessment_Response__c> tobeUpdated = new list<Assessment_Response__c>();
    		for(Assessment_Response__c currentResponse: [SELECT Id, Rating__c, Question__c, Score__c FROM Assessment_Response__c WHERE Assessment__r.Evaluation__c = :clonedEval.Id AND Question__c IN: responseMap.keySet()]){
    				currentResponse.Rating__c = responseMap.get(currentResponse.Question__c).Rating__c;
    				currentResponse.Score__c = responseMap.get(currentResponse.Question__c).Score__c;
    				tobeUpdated.add(currentResponse);
    			
    		}
    		
    		update tobeUpdated;
    		
    	}
    	
    	//Clone the Eval Value Records and replace the WhatId with the cloned Eval id. This is common for all eval Types!!
    	
    	List<Eval_Value__c> currentEvalValues = [SELECT Id,Boolean__c, Currency__c, Date_Time__c,Eval__c, Eval_Section_Id__C, Eval_Section_Type__c, Number_No_Decimal__c, Text_Over_250__c, Text_Under_250__c, What_Id__c, What_Id_Object__c FROM Eval_Value__c WHERE What_Id__c = :currentEval.Id ];
    	List<Eval_value__c> clonedEvalValues = currentEvalValues.deepclone(false, false, false);
    	for(Eval_Value__c value: clonedEvalValues){
    		value.What_id__c = clonedEval.Id;
    	}
    	
    	insert clonedEvalValues;
    	//Copy Evaluation Responsem Records
    	list<Evaluation_Response__c> responsestobeCreated = new List<Evaluation_Response__c>();
    	FieldSet copyresponseFields = SObjectType.Evaluation_Response__c.FieldSets.CloneevalResponses;
    	list<string> responseRectypes = new List<string>{'Allergy','Pressure Ulcer Detail','Wound Detail','Annotation'};
    	String responseQuery ='SELECT ';
    	
    	for(Schema.FieldSetMember f : copyresponseFields.getFields()) {
                    responseQuery += f.getFieldPath() + ', ';
        }
        
        responseQuery += 'Name, RecordType.Name FROM Evaluation_Response__c WHERE RecordType.Name IN:responseRectypes AND Evaluation__c =:currentEvalId';
        list<Evaluation_Response__c> evalResponses = database.query(responseQuery);
        
        if(evalResponses.size() > 0){
         	for(Evaluation_Response__c erp : evalResponses){
                Evaluation_Response__c newRecord = erp.clone(false);
                newRecord.Evaluation__c = clonedEval.Id;
            if (newRecord.RecordType.Name == 'Allergy') {
                newRecord.Person_Being_Served__c = currentEval.serviceassignment__r.admission__r.person_being_served__c;
            	}
            	responsestobeCreated.add(newRecord);
        	}

             insert responsestobeCreated;
         }
        
    	return clonedEval;
    	
	}
	//Start - Control the visibility of buttons
	public void controlButtons() {
		if(evalType == 'Residential'){
			showshiftDone = false;
			List<Service_Assignment__c> servAssign = [SELECT ID, (SELECT Id, Status__c, CreatedDate FROM Evaluations__r Where Id != :thisEval.Id AND Status__c != 'Disregard' AND RecordType.Name ='NursesAssessment' order by CreatedDate desc) FROM Service_Assignment__c WHERE Id=: SAID LIMIT 1];
			if(thisEval.Status__c == 'Draft'){
				showEsign = true;
				showRevise = false;
				showDisregard = true;
			}
			else if(thisEval.Status__c == 'Final Admission' && servAssign[0].Evaluations__r.Size() == 0){
				showEsign = false;
				showRevise = true;
				showDisregard = true;
				
			}
			else if(thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r.Size() == 1 ){
				showEsign = false;
				showRevise = true;
				showDisregard = true;
				
			}
			else if(thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Draft'){
				
				showEsign = false;
				showRevise = false;
				showDisregard = false;
				
			}
			else if(thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Final Revision' && thisEval.CreatedDate < servAssign[0].Evaluations__r[0].CreatedDate ){
				
				showEsign = false;
				showRevise = false;
				showDisregard = false;
				
			}
			else if(thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Final Revision' && thisEval.CreatedDate > servAssign[0].Evaluations__r[0].CreatedDate ){
				
				showEsign = false;
				showRevise = true;
				showDisregard = true;
				
			}
		
		}
		
		if(evalType == 'Head to Toe'){
			
			showRevise = false; // No revision functionality for Head to toe. Clone will happen during disregard.
			
			if(thisEval.Head_to_toe_Status__c == 'Draft' && thisEval.Status__c == 'Draft'){
				showEsign = true;
				showDisregard = true;
				showshiftDone = false;

			}
			else if(thisEval.Head_to_toe_Status__c == 'Final' && thisEval.Status__c == 'Draft'){
				showEsign = false;
				showDisregard = true;
				showshiftDone = true;
				
			}
			else if(thisEval.Head_to_toe_Status__c == 'Final' && thisEval.Status__c == 'Completed' ){
				showEsign = false;
				showDisregard = false;
				showshiftDone = false;
				
			}
				
		}
			
	}
	//End - Control the Visibility of Buttons
	
	Public static string determineEvalStatus(id evalId){
		string status='';
		Evaluation__c currentEval = [SELECT Id,Recordtype.Name, ServiceAssignment__c FROM Evaluation__c WHERE Id=: evalId LIMIT 1];
		
			List<Service_Assignment__c> servAssign = [SELECT ID, (SELECT Id FROM Evaluations__r Where Status__c != 'Disregard' order by createdDate asc) FROM Service_Assignment__c WHERE Id=: currentEval.ServiceAssignment__c LIMIT 1];
			
			if(currentEval.RecordType.Name == 'CMShiftAssessment' ){
				status = 'Final';
			}
			else if(currentEval.Recordtype.Name == 'NursesAssessment' && currentEval.Id == servAssign[0].Evaluations__r[0].Id){
				status = 'Final Admission';
			}
			else if(currentEval.Recordtype.Name == 'NursesAssessment' && currentEval.Id != servAssign[0].Evaluations__r[0].Id){
				status = 'Final Revision';
			}
			else{
				status = 'Final';
			}
		
		return status;
	}
    
	
}