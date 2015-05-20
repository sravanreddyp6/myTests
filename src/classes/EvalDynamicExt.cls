public with sharing class EvalDynamicExt {

	public ID evalID;
	public ID PBSID { get; set; }
	public ID AdmID {get; set;}
	public ID SAID {get; set;}
	public ID accId{get; set;}
	public Evaluation__c thisEval {get; set;}
	public string evalType {get; set;}
	public string subCat {get; set;}
	public string cat {get; set;}
    public string evalSecId {get; set;}
    public string evalSecType {get; set;}
    public string restraintSecId;
    public Id currentAssessId {get; set;}
	public Boolean showMainComponent {get; set;}
	public string key {get; set;}

	public Boolean showDisregard {get; set;}
	public Boolean showRevise {get; set;}
	public Boolean showEsign{get; set;}
	public Boolean showshiftDone{get; set;}
	public Boolean showApprove {get; set;}
	public Boolean isUserOwner {get; set; }
	public Boolean isApprover { get; set; }

	public Boolean isEditable;

	public String getEvalStatusDate(){
		if (evalType == 'Head to Toe')
            return thisEval.Shift_Start_Time__c.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
        else
            return thisEval.CreatedDate.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
	}

	public string getshiftStartTime(){
		return Utility.getMilitarytime(thisEval.Shift_Start_Time__c);
	}

	public string getshiftEndTime(){
		return Utility.getMilitarytime(thisEval.Shift_End_Time__c);
	}

	public string getshiftCreatedDate(){
		return Utility.getMilitarytime(thisEval.CreatedDate);
	}

	public EvalDynamicExt(){
		// get the record
		evalID =  ApexPages.currentPage().getParameters().get('evalID');
		evalType = ApexPages.currentPage().getParameters().get('evaltype');
		cat = ApexPages.currentPage().getParameters().get('Category');
		subCat = ApexPages.currentPage().getParameters().get('SubCategory');
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		approvalHIstory = new List<ProcessInstanceHistory>();

		showMainComponent = true;
		showDisregard = false;
		showRevise = false;
		showEsign = false;
		showshiftDone = false;
		isUserOwner = false;
		isApprover = false;

		thisEval = [ select id, Name, Status__c, Head_to_Toe_Status__c, Owner.Name, ownerid, Shift_Start_Time__c, Shift_End_time__c, Recordtype.Name, CreatedDate, serviceassignment__c, serviceassignment__r.admission__c, serviceassignment__r.admission__r.person_being_served__c, serviceassignment__r.admission__r.person_being_served__r.AccountId,Has_Open_Assessment__c from Evaluation__c where ID = :evalID LIMIT 1];

		if ( thisEval != null ) {
			PBSID = thisEval.serviceassignment__r.admission__r.person_being_served__c;
			AdmID = thisEval.serviceassignment__r.admission__c;
			SAID = thisEval.serviceassignment__c;
			accId = thisEval.serviceassignment__r.admission__r.person_being_served__r.AccountId;
			if ( UserInfo.getUserId() == thisEval.OwnerID )
				isUserOwner = true;

			if ( UserInfo.getUserId() == getApprovalUserID( thisEval.Id))
				isApprover = true;

			isEditable = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :thisEval.Id LIMIT 1].HasEditAccess;

			controlButtons();
		}

	}

	public void myAction(){
		string displayKey = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		key = displayKey;

		system.debug('sectionIdonclickofplus+++++++'+evalSecId);
		if(key == 'Residential~Fall Risk Assessment~Fall Assessment~Residential' || key.contains('Head to Toe~Skin/Body~Wound Detail') || key.contains('Head to Toe~Skin/Body~Pressure Ulcer Detail') || key == 'Residential~Skin/Body~Skin Assessment~Residential'){

			createEvalValueRecord(key);
			showMainComponent = false;
		}
		else if(key.contains('Residential~Skin/Body~Pressure Ulcer Detail') || key.contains('Residential~Skin/Body~Wound Detail')){

			if(evalSecId == null || evalSecId == ''){
				createEvalValueRecord(key);
			}
			else{
				updateEvalValueRecord(key);
			}
			showMainComponent = false;
		}
		else if(key.contains('Restraint Event~Reduction Review~Reduction Review')){

			system.debug('I am in myaction+++++='+currentAssessId);
			if(evalSecId == null || evalSecId==''){
				createEvalValueRecord(key);
				//creating Assessment
				currentAssessId = EvalDynamicExt.createAssessmentforRestraint(restraintSecId, evalID, PBSID, SAID, AdmID, accId);
				system.debug('current Id after Creation++++' +currentAssessId);
				showMainComponent = false;

			}
			else{
				//Retreieving Assessment
				currentAssessId = EvalDynamicExt.retrieveAssessmentforRestraint(evalSecId, evalID);
				showMainComponent = false;
			}
		}
		else{
			showMainComponent = true;
		}

	}

	private void createEvalValueRecord(String key){
		String sectionId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
		restraintSecId = sectionId;
		boolean isValidVal = false;
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
	        	  if (e.Field_Name__c=='IsValid' && (e.Sub_Category__c == 'Fall Assessment' || e.Sub_Category__c == 'Skin Assessment')){
                    isValidVal = !EvalDynamicExt.validateAssessmentError(evalId, e.Sub_Category__c == 'Fall Assessment' ? 'Fall Risk Assessment Domain' :'Skin Assessment Domain');
	        	  }
	        	  else if(e.Field_Name__c=='IsValid' && e.Sub_Category__c == 'Reduction Review'){
	        	  		isValidVal = false; //Nothing will be filled during the initial Click.
	        	  }
                  else{
                    isValidVal = true;

                  }
	              vals.add(new eval_value__c(Eval__c = e.id,
	                                         Eval_Section_Id__c = sectionId,
	                                         Eval_Section_Type__c = evalSecType,
	                                         Boolean__c = isValidVal,
	                                         what_id__c = evalID,
	                                         what_id_object__c = 'Evaluation__c'));
	        }
        } else if ( repeatableEval.size() > 0 && (evalSecId == null || evalSecId == '') ){   // Activity log Entry - evalSecId will be empty only when Adding in a new entry.
            for (Eval__c e : evals){

            	if(!(e.Field_name__c == 'IsValid' && e.Sub_Category__c == 'Reduction Review')){ //Skip the Eval Value creation for isValid from the Second entry

	            	if (e.Field_Name__c=='IsValid'){
	            		isValidVal = true;
	            	}

	            	/*if(e.Field_Name__c == 'IsValid' && e.Sub_Category__c == 'Reduction Review'){
	            		isValidVal = false;// never true first time as users have to answer all the questions
	            	}*/

	                vals.add(new eval_value__c(Eval__c = e.id,
	                                             Eval_Section_Id__c = sectionId,
	                                             Eval_Section_Type__c = evalSecType,
	                                             Boolean__c = isValidVal,
	                                             what_id__c = evalID,
	                                             what_id_object__c = 'Evaluation__c'));
	            }

            }
        }
		insert vals;
	}

	private void updateEvalValueRecord(string key){
		List<Eval_value__c> isValid = [SELECT Id, Boolean__c FROM Eval_Value__c WHERE what_id__c = :evalId AND Eval__r.category__c = :cat AND Eval__r.sub_category__c = :subcat AND Eval__r.Field_Name__c = 'IsValid' AND Eval_Section_Id__c = :evalSecId LIMIT 1];
		if(isValid.size() > 0 && isValid[0].Boolean__c == false){
			isValid[0].Boolean__c = true;
			update isValid[0];
		}
		else{
			return;
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

    public static boolean validateRestraintReductionError(){
    	//logic to validate Reduction Review erors go here - Sravan - to do
    	return true;
    }

    public pageReference reviseAssessment() {

    	//Roll back all the DML operations in case of any failure in the process of Cloning. 04/4/2015 8:00 PM
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

		Savepoint sp2 = Database.setSavepoint(); // Make sure the whole transaction is rolled back to prevent side effects

		if(evalType == 'Residential' || evalType == 'CNA Workbook'){
			thisEval.Status__c = 'Disregard';
			try{
				update thisEval;
				PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
				pageRef.setRedirect(true);
				return pageRef;
			}
			catch(exception e){
				Database.rollback(sp2);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;
			}

		}

		else if(evalType == 'Head to Toe'){
			//Savepoint sp2 = Database.setSavepoint();
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

		else if(evalType == 'Restraint Event'){
			thisEval.Status__c = 'Disregard';
			try{
				update thisEval;
				List<Assessment__c> relatedAssessments = [SELECT Id, Status__C FROM Assessment__c WHERE EValuation__c = :thisEval.id];
				if(relatedAssessments.size() > 0){
					for(Assessment__c asmt : relatedAssessments){
						asmt.Status__C = 'Disregard';

					}
					update relatedAssessments;
				}
				PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
				pageRef.setRedirect(true);
				return pageRef;
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

		if ( evalType == 'CNA Workbook')
			return FinalizeCNA();

		//Commented by Sravan - 04/13/2015 as the whole logic is handled in CMShiftAssessmentEsign.cls -- CLciking the Complete button invokes Authentication Component but not this method.

		/*savepoint completeShiftSavepoint = Database.setSavepoint(); // Make sure the whole transaction is rolled back to prevent side effects

		if(evalType == 'Restraint Event'){
			thisEval.Status__c = 'Restraint Event Ended';
			try{
				update thisEval;
				List<Assessment__c> completedAsmts = [SELECT Id, Status__c FROM Assessment__c WHERE Evaluation__c =:thisEval.Id];
				if(completedAsmts.size() > 0){
					for(Assessment__c asmt : completedAsmts){
						asmt.Status__C = 'Completed';
					}
					update completedAsmts;
				}
			}
			catch (exception e){
				Database.rollback(completeShiftSavepoint);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;
			}
		}else{
			thisEval.Status__c = 'Completed';
			thisEval.Shift_End_time__c = system.Now();
			try{
				update thisEval;
				PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
				pageRef.setRedirect(true);
				return pageRef;
			}
			catch(exception e){
				Database.rollback(completeShiftSavepoint);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;
			}

		}*/
		return null;
	}
	
	public pageReference completeRestraintEvent(){
		update thisEval;
		return null;
		
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
    	//list<string> responseRectypes = new List<string>{'Allergy','Pressure Ulcer Detail','Wound Detail','Annotation'}; Commented to clone data from all record types
    	String responseQuery ='SELECT ';

    	for(Schema.FieldSetMember f : copyresponseFields.getFields()) {
                    responseQuery += f.getFieldPath() + ', ';
        }

        responseQuery += 'Name, RecordType.Name FROM Evaluation_Response__c WHERE Evaluation__c =:currentEvalId';
        list<Evaluation_Response__c> evalResponses = database.query(responseQuery);

        if(evalResponses.size() > 0){
         	for(Evaluation_Response__c erp : evalResponses){
                Evaluation_Response__c newRecord = erp.clone(false);
                newRecord.Evaluation__c = clonedEval.Id;
           /* if (newRecord.RecordType.Name == 'Allergy') {
                newRecord.Person_Being_Served__c = currentEval.serviceassignment__r.admission__r.person_being_served__c;
            	}*/
            	responsestobeCreated.add(newRecord);
        	}

             insert responsestobeCreated;
         }

    	return clonedEval;

	}
	//Start - Control the visibility of buttons
	public void controlButtons() {

		showApprove = false;
		showEsign = false;

		// do this first because the approval buttons happen regardless of record ownership
		if (evalType == 'CNA Workbook') {
			showRevise = false;
			showShiftDone = false;

			if ( thiseval.status__c == 'Draft' && isUserOwner) {
				showEsign = true;
				showDisregard = true;
			}

			if ( thiseval.status__c == 'Pending Approval' && isApprover) {
				showApprove = true;
			}
		}

		if (!isUserOwner && evalType != 'Restraint Event') {  // EC-153 Let other people finalize Restraint Events
			showEsign=false;
			showRevise = false;
			// show disregard for owner or supervisory user - TO DO: figure out who is in perm set above this user
			showDisregard = false;

			return;
		}


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
				showDisregard = true;
				showshiftDone = false;

			}

		}

		if(evalType == 'Restraint Event'){
			// Default
			showRevise = false;
			showEsign=false;
			showDisregard = false;

			if (thisEval.Status__c == 'Not Restrained') {
				if (isEditable) {
					showEsign = true;  // EC-153
				}
				if (isUserOwner) {
					showDisregard = true;
					showshiftDone = false;
				}
			} else if (thisEval.Status__c == 'Disregard' && isUserOwner) {
				showDisregard = false;
				showEsign = false;
				showshiftDone = false;
			} else if (thisEval.Status__c == 'Applied Alternative to Restraint' || thisEval.Status__c == 'Applied Restraint') {
				showEsign = false;
				if (isEditable) {
					showShiftDone = true;
					showDisregard = true;
				}
			}
		}


	}
	//End - Control the Visibility of Buttons

	public static Id createAssessmentforRestraint(string sectionId, Id evalId, Id PBSId, Id saId, Id admId, Id accId){

		//Create a New Assessment With Type as Restraint Reduction
			Assessment__c restraintReduction = new Assessment__c();
			restraintReduction.Name = sectionId;
			restraintReduction.Type__c = 'Restraint Reduction';
			restraintReduction.Evaluation__c = evalId;
			restraintReduction.Admission__c = admId;
			restraintReduction.Service_Assignment__c = saId;
			restraintReduction.AccountPerson__c = accId;
			restraintReduction.Status__c = 'Open';
			restraintReduction.Disregard__c = false;

			insert restraintReduction; //THis will invoke the trigger on Assessment object will in turn invoke AssessmentSetup.cls to create domains, domain results and dummy response.
										// Need to check if this is the best practice or write the whole AssessmentSetup logic in here - Sravan - 04/08/2015 2:00 PM
			Evaluation__c currentEval = [SELECT Id, Has_Open_Assessment__c FROM EValuation__c WHERE Id=: evalId];
			currentEval.Has_Open_Assessment__c = true;
			update currentEval;	// Update the Evaluation record's boolean flag to true when an open assessment Exists.

			string whatId = string.valueOf(evalId);

			//Update the Eval_Value__c as False as an Open Assessment record is created.
			List<Eval_Value__c> eVs = [SELECT Id, Boolean__c FROM Eval_Value__C WHERE What_id__c= :whatId AND Eval__r.Field_Name__c = 'IsValid' AND Eval__r.Category__c = 'Reduction Review' AND Eval__r.Sub_Category__c = 'Reduction Review'];
			if(eVs.size() > 0){
				Eval_Value__c v = eVs[0];
				v.Boolean__c = false;
				update v;
			}

			return [SELECT Id FROM Assessment__c where Id=:restraintReduction.Id LIMIT 1].Id;
	}

	public static id retrieveAssessmentforRestraint(string sectionId, Id evalId){
		List<Assessment__c> existingAssess = [SELECT Id, Name, Evaluation__c FROM Assessment__c WHERE Name=: sectionId AND Evaluation__c = :evalId AND Type__c = 'Restraint Reduction' LIMIT 1];
		if(existingAssess.size() > 0){
			return existingAssess[0].Id;
		}
		else{
			return null; // Which Should never happen -------Create a Custom Exception to do Sravan --------------
		}

	}


    public PageReference FinalizeCNA(){
        return new PageReference('/apex/EvalApproval?id=' + evalID);
    }

    public List<ProcessInstanceHistory> approvalHistory;
    public List<ProcessInstanceHistory> getApprovalHistory () {
    	List<ProcessInstance> pi = [SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate  FROM StepsAndWorkitems order by createddate desc)
									FROM ProcessInstance where  targetobjectid = :evalID
									order by createddate desc];

		for ( ProcessInstance p : pi ) {
			approvalHistory.addAll (p.stepsandworkitems);
		}
		return approvalHistory;

    }

    public string revcomments { get; set; }
    public string approvalaction { get; set; }
    public PageReference ApproveReject() {
    	executeNextApprovalStep(approvalaction, revcomments);
    	return new PageReference('/apex/home');
    }

    private void executeNextApprovalStep( string approvalAction, string comment) {

    	Approval.ProcessWorkitemRequest req =  new Approval.ProcessWorkitemRequest();
        req.setAction(approvalAction);
        req.setComments( comment);
        req.setNextApproverIds(null);

        // get the current work item
        List<ProcessInstanceWorkitem> pwi = [select id, actorid from processinstanceworkitem where processinstance.targetobjectid = :evalID];

        if ( pwi.size() == 0) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error approving item'));
        	return;
        }
       	req.setWorkitemId(pwi[0].id);

        // Submit the request for approval
        Approval.ProcessResult result =  Approval.process(req);
    }


    public ID getApprovalUserID( ID theID ) {

    	List<ProcessInstanceWorkitem> pwi = [select id, actorid from processinstanceworkitem where processinstance.targetobjectid = :theID];

    	if ( pwi.size() > 0) {
    		system.debug('Approver is:' + pwi[0].actorID);
    		return pwi[0].actorId;
    	} else {
    		return null;
    	}
    }

}