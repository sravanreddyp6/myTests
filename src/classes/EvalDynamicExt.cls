public with sharing class EvalDynamicExt {

	public ID evalID { get; set; }
	public ID PBSID { get; set; }
	public ID AdmID { get; set; }
	public ID SAID { get; set; }
	public ID accId{ get; set; }
	public Evaluation__c thisEval { get; set; }
	public string evalType { get; set; }
	public string subCat { get; set; }
	public string cat { get; set; }
	public string evalSecId { get; set; }
	public string evalSecType { get; set; }
	public Boolean canEdit { get; set; }
	public Id currentAssessId { get; set; }
	public String key { get; set; }
	public Evaluation_Response__c lateEntryNote { get; set; }  // EC-164
	public Evaluation_Response__c[] lateEntryNotes { get; set; }

	public Boolean showDisregard { get; set; }
	public Boolean showRevise { get; set; }
	public Boolean showEsign{ get; set; }
	public Boolean showshiftDone{ get; set; }
	public Boolean showApprove { get; set; }
	public Boolean isUserOwner { get; set; }
	public Boolean isApprover { get; set; }
	public Boolean showEndOfShiftDON { get; set; }  // EC-163

	public Boolean isBatchInsert { get; set; }
	public Boolean isBatchUpsert { get; set; }

	public Boolean isEditable;
	public Boolean isDON { get; set; }
	public Boolean isTierIII { get; set; }
	public Boolean isTierII { get; set; }

	public Boolean disregardCloneDisabled { get; set; }

	public String getEvalStatusDate() {
		if (evalType == 'Head to Toe') {
			return thisEval.Shift_Start_Time__c.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
		} else {
			return thisEval.CreatedDate.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
		}
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
		refreshLateEntryNotes();
		lateEntryNote = new Evaluation_Response__c(
			RecordTypeId = Utility.getEvaluationResponseRecordType('Late Entry Note'),
			Evaluation__c = evalId
		);

		showDisregard = false;
		showRevise = false;
		showEsign = false;
		showshiftDone = false;
		showEndOfShiftDON = false;
		isUserOwner = false;
		isApprover = false;

		PermissionSetAssignment[] assignments = [
			SELECT Id, PermissionSet.Name
			  FROM PermissionSetAssignment
			 WHERE AssigneeId = :UserInfo.getUserId()
		];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Name);
		}

		if (permissionSets.contains('iServe_DON')) {
			isDON = true;
		} else {
			isDON = false;
		}
		if (permissionSets.contains('iServe_Tier_III')) {
			isTierIII = true;
		} else {
			isTierIII = false;
		}
		if (permissionSets.contains('iServe_Tier_II')) {
			isTierII = true;
		} else {
			isTierII = false;
		}

		thisEval = [
			SELECT Id, Name, Status__c, Head_to_Toe_Status__c, Owner.Name, ownerid,
			       Shift_Start_Time__c, Shift_End_time__c, Signed_By__r.Name, Recordtype.Name,
			       CreatedDate, serviceassignment__c, serviceassignment__r.admission__c,
			       serviceassignment__r.admission__r.person_being_served__c,
			       serviceassignment__r.admission__r.person_being_served__r.AccountId,
			       Has_Open_Assessment__c, serviceassignment__r.person_being_served__c
			  FROM Evaluation__c
			 WHERE ID = :evalID
			 LIMIT 1
			];

		if ( thisEval != null ) {
			PBSID = thisEval.serviceassignment__r.admission__r.person_being_served__c;
			AdmID = thisEval.serviceassignment__r.admission__c;
			SAID = thisEval.serviceassignment__c;
			accId = thisEval.serviceassignment__r.admission__r.person_being_served__r.AccountId;
			if ( UserInfo.getUserId() == thisEval.OwnerID )
				isUserOwner = true;

			if ( UserInfo.getUserId() == getApprovalUserID( thisEval.Id))
				isApprover = true;

			isEditable = [
				SELECT RecordId, HasEditAccess
				  FROM UserRecordAccess
				 WHERE UserId = :UserInfo.getUserId()
				   AND RecordId = :thisEval.Id
				 LIMIT 1].HasEditAccess;
			controlButtons();
		}
	}

	public void refreshLateEntryNotes() {
		lateEntryNotes = [
		SELECT Id, CreatedDate, CreatedBy.Name
		  FROM Evaluation_Response__c
		 WHERE RecordTypeId = :Utility.getEvaluationResponseRecordType('Late Entry Note')
		   AND Evaluation__c = :evalId
		ORDER BY CreatedDate DESC
		];
	}

	public void refreshLateEntryNote() {
		String lateEntryNoteId = ApexPages.currentPage().getParameters().get('lateEntryNoteId');
		if (lateEntryNoteId == null || lateEntryNoteId == '') {
			lateEntryNote = new Evaluation_Response__c(
				RecordTypeId = Utility.getEvaluationResponseRecordType('Late Entry Note'),
				Evaluation__c = evalId
			);
		} else {
			lateEntryNote = [ SELECT Id, CreatedById, CreatedBy.Name, Late_Entry_Note__c, CreatedDate FROM Evaluation_Response__c WHERE Id = :lateEntryNoteId ];
		}
	}

	public void validateLateEntryNote() {
		if (lateEntryNote.Late_Entry_Note__c == '' || lateEntryNote.Late_Entry_Note__c == null) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Late Entry Note cannot be blank'));
		}
	}

	public void saveLateEntryNote() {
		Boolean errorFound = false;
		if (lateEntryNote.Late_Entry_Note__c == '' || lateEntryNote.Late_Entry_Note__c == null) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Late Entry Note cannot be blank'));
			errorFound = true;
		}
		if (!errorFound) {
			upsert lateEntryNote;
			refreshLateEntryNotes();
		}
	}

	public void myAction() {
		// TODO this is a stubbed method, remove it at a later release!
	}
	public void singleUpsert() {
		isBatchInsert = false;
		isBatchUpsert = false;
		if (evalSecId == '' || evalSecId == null) {
			evalSecId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
		}
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		if (key.contains('Restraint Event~Reduction Review~Reduction Review')) {
			currentAssessId = EvalDynamicExt.retrieveAssessmentforRestraint(evalSecId, evalID);
			if (currentAssessId == null) {
				currentAssessId = EvalDynamicExt.createAssessmentforRestraint(evalSecId, evalID, PBSID, SAID, AdmID, accId);
			}
		}
	}

	private void batchSetup() {
		canEdit = true;
		subCat = '';
		evalSecType = '';
		evalSecId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
	}
	public void batchInsert() {
		isBatchInsert = true;
		isBatchUpsert = false;
		batchSetup();
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		if (key.contains('Restraint Event~Reduction Review')) {
			currentAssessId = EvalDynamicExt.createAssessmentforRestraint(evalSecId, evalID, PBSID, SAID, AdmID, accId);
		}
	}
	public void batchUpsert() {
		isBatchUpsert = true;
		isBatchInsert = false;
		batchSetup();
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		if (key.contains('Restraint Event~Reduction Review')) {
			currentAssessId = EvalDynamicExt.retrieveAssessmentforRestraint(evalSecId, evalID);
			if (currentAssessId == null) {
				currentAssessId = EvalDynamicExt.createAssessmentforRestraint(evalSecId, evalID, PBSID, SAID, AdmID, accId);
			}
		}
	}

	public pageReference reviseAssessment() {
		//Roll back all the DML operations in case of any failure in the process of Cloning. 04/4/2015 8:00 PM
		Savepoint sp = Database.setSavepoint();
		try{
			Evaluation__c clonedEval = EvalDynamicExt.cloneEvalContent(thisEval, this.evalType, 'Care Meridian', PBSId);
			PageReference pg = new PageReference('/apex/EvalDynamic?evalId='+clonedEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
			pg.setRedirect(true);
			return pg;
		} catch(exception e){
			Database.rollback(sp);
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
			return null;

		}
	}


	public pageReference disregardAssessment() {
		Savepoint sp2 = Database.setSavepoint(); // Make sure the whole transaction is rolled back to prevent side effects

		if(evalType == 'Residential' || evalType == 'CNA Workbook'){

			try{
				// need to get record without sharing on in case CNA workbook was locked as part of approval process
				NoSharingRecord nsr = new NoSharingRecord( thisEval.id);
				nsr.setStatusAndSave('Disregard');
				PageReference pageRef = new PageReference('/apex/EvalDynamic?evalId='+thisEval.Id+'&evalType='+evalType+'&opGrp=Care Meridian');
				pageRef.setRedirect(true);
				return pageRef;
			}
			catch(exception e){
				Database.rollback(sp2);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;
			}
		} else if (evalType == 'Head to Toe'){
			//Savepoint sp2 = Database.setSavepoint();
			thisEval.Status__c = 'Disregard';
			thisEval.Head_to_toe_Status__c = 'Disregard';

			try{
				update thisEval;
				Id evalId = thisEval.Id;
				if (!disregardCloneDisabled) {
					Evaluation__c clonedShift = EvalDynamicExt.cloneEvalContent(thisEval, this.evalType, 'Care Meridian', PBSId);
					evalId = clonedShift.Id;
				}
				PageReference pg = new PageReference('/apex/EvalDynamic?evalId=' + evalId + '&evalType=' + evalType + '&opGrp=Care Meridian');
				pg.setRedirect(true);
				return pg;
			} catch (exception e){
				Database.rollback(sp2);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;

			}
		} else if (evalType == 'Restraint Event') {
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
			} catch(exception e){
				Database.rollback(sp2);
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()));
				return null;
			}
		}
		return null;
	}

	public pageReference completeShift() {
		if ( evalType == 'CNA Workbook' || evalType == 'Residential') {
			return SubmitForApproval();
		}
		return null;
	}

	public void completeRestraintEvent(){
		update thisEval;
	}

	public void endShiftDON() {
		update thisEval;
	}

	//Generic Clone functionality to copy Eval Value records.
	public static Evaluation__c cloneEvalContent(Evaluation__c eval, string evalType, string operatingGroup, ID pbsID){

		Evaluation__c currentEval = eval;
		id currentEvalId = currentEval.Id;
		//CLone the current Evaluation and Insert a new one with Draft Status
		Evaluation__c clonedEval = currentEval.clone(false);
		clonedEval.Status__c = 'Draft'; //Common for all types
		clonedEval.Signed_At__c = null;
		clonedEval.Head_to_toe_Signed_At__c = null;

		// EC-235 - rename the assessment on revise - needs new owner name and date of creation
		string assessmentName = '';
		Contact thisPBS = [ select firstname, lastname from contact where id = :pbsID];
		string pbsLastName = thisPBS.LastName != null ? thisPBS.LastName : '' ;
		string pbsFirstinitial = thisPBS.FirstName != null ? thisPBS.FirstName.substring(0, 1) : '';
		string ownerfirstInitial = userinfo.getFirstName() != null ? userinfo.getFirstName().Substring(0,1) : '';
		if(evalType == 'Head to Toe'){
			clonedEval.Head_to_toe_status__c = 'Draft';
			assessmentName = pbsFirstinitial+'. '+pbsLastName+' - '+DateTime.Now().format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString()) +' - '+'NSD'+' - '+ownerfirstInitial+'. '+userinfo.getLastName();
		} else if (evalType == 'Residential') {
			clonedEval.OwnerId = UserInfo.getUserId();
			assessmentName = pbsFirstinitial+'. '+pbsLastName+' - '+DateTime.Now().format('MM/dd/yy') +' - '+'Res.Asmt'+' - '+ownerfirstInitial+'. '+userinfo.getLastName();
		}
		clonedEval.name = assessmentName;

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
		showDisregard = false;

		// do this first because the approval buttons happen regardless of record ownership
		if (evalType == 'CNA Workbook') {
			showRevise = false;
			showShiftDone = false;

			// show esign only for Draft
			if (thiseval.status__c == 'Draft') {
				showEsign = true;
			}
			if ( isUserOwner) {
				// EC-198 - 06/10/2015 - show disregard for all statuses other than already diregarded!
				system.debug( ' isuserowner is true, status is ' + thiseval.status__c);
				if ( thiseval.status__c != 'Disregard') {
					showDisregard = true;
				}
			} else if (isDON) {
				showEndOfShiftDON = true;
			}

			if ( thiseval.status__c == 'Pending Approval' && isApprover) {
				showApprove = true;
			}
		}

		if (!isUserOwner && evalType != 'Restraint Event' && evalType != 'Residential' && evalType != 'CNA Workbook') {  // EC-153 - Let other people finalize Restraint Events, EC-219 - Let other people edit Residential
			showEsign=false;
			showRevise = false;
			// show disregard for owner or supervisory user - TO DO: figure out who is in perm set above this user
			showDisregard = false;

			if (isDON) {
				if (evalType == 'Head to Toe' && thisEval.Status__c == 'Draft') {  // EC-163
					showEndOfShiftDON = true;
				}
			}
			return;
		}

		if(evalType == 'Residential'){
			showshiftDone = false;
			List<Service_Assignment__c> servAssign = [SELECT ID, (SELECT Id, Status__c, CreatedDate FROM Evaluations__r Where Id != :thisEval.Id AND Status__c != 'Disregard' AND RecordType.Name ='NursesAssessment' order by CreatedDate desc) FROM Service_Assignment__c WHERE Id=: SAID LIMIT 1];
			if (thisEval.Status__c == 'Draft'){
				showEsign = true;
				showRevise = false;
				showDisregard = true;
			} else if (thisEval.Status__c == 'Final Admission' && servAssign[0].Evaluations__r.Size() == 0){
				showEsign = false;
				showRevise = true;
				showDisregard = true;
			} else if (thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r.Size() == 1 ){
				showEsign = false;
				showRevise = true;
				showDisregard = true;
			} else if (thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Draft'){
				showEsign = false;
				showRevise = false;
				showDisregard = false;
			} else if (thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Final Revision' && thisEval.CreatedDate < servAssign[0].Evaluations__r[0].CreatedDate ){
				showEsign = false;
				showRevise = false;
				showDisregard = false;
			} else if (thisEval.Status__c == 'Final Revision' && servAssign[0].Evaluations__r[0].Status__c == 'Final Revision' && thisEval.CreatedDate > servAssign[0].Evaluations__r[0].CreatedDate ){
				showEsign = false;
				showRevise = true;
				showDisregard = true;
			}

			if ( thiseval.status__c == 'Pending Approval' && isApprover) {
				showApprove = true;
			}
			// if user is not tier iii or ii don't display anything. This needs to be at the end because
			// it trumps everything else.
			if (!isTierIII && !isTierII) {
				showEsign = false;
				showRevise = false;
				showDisregard = false;
			}
		}

		if(evalType == 'Head to Toe'){

			showRevise = false; // No revision functionality for Head to toe. Clone will happen during disregard.

			if (thisEval.Head_to_toe_Status__c == 'Draft' && thisEval.Status__c == 'Draft'){
				showEsign = true;
				showDisregard = true;
				showshiftDone = false;

			} else if (thisEval.Head_to_toe_Status__c == 'Final' && thisEval.Status__c == 'Draft'){
				showEsign = false;
				showDisregard = true;
				showshiftDone = true;

			} else if (thisEval.Head_to_toe_Status__c == 'Final' && thisEval.Status__c == 'Completed' ){
				showEsign = false;
				showDisregard = true;
				showshiftDone = false;
			} else if (thisEval.Status__c == 'End of Shift') {
				showDisregard = true;
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
		} else {
			return null;
		}

	}


	public PageReference SubmitForApproval(){
		return new PageReference('/apex/EvalApproval?id=' + evalID);
	}

	transient public List<ProcessInstanceHistory> approvalHistory;
	public List<ProcessInstanceHistory> getApprovalHistory () {
		approvalHIstory = new List<ProcessInstanceHistory>();
		List<ProcessInstance> pi = [
			SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate
			              FROM StepsAndWorkitems
			            ORDER BY createddate desc)
			FROM ProcessInstance where  targetobjectid = :evalID
			ORDER BY createddate desc];

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

		// if a rejection, set up a task for the CNA owner
		if ( approvalAction == 'Reject') {
			DateTime n = DateTime.now();
			Task t;
			if (thisEval.Recordtype.Name == 'CNA Workbook') {
				t = new Task(Subject = 'Rejected CNA Workbook', Status = 'New', Priority = 'Normal', OwnerId = thiseval.ownerid, Description = 'CNA Workbook rejected by ' + UserInfo.getName() + ' at ' + utility.getmilitarytime(datetime.now()) + ' with comment: "' + comment + '"', WhoId = thiseval.ServiceAssignment__r.Person_Being_Served__c, WhatId = thiseval.Id, ActivityDate = Date.Today().AddDays(1));
			} else if (thisEval.Recordtype.Name == 'NursesAssessment') {
				t = new Task(Subject = 'Rejected Resident Assessment', Status = 'New', Priority = 'Normal', OwnerId = thiseval.ownerid, Description = 'Resident Assessment rejected by ' + UserInfo.getName() + ' at ' + utility.getmilitarytime(datetime.now()) + ' with comment: "' + comment + '"', WhoId = thiseval.ServiceAssignment__r.Person_Being_Served__c, WhatId = thiseval.Id, ActivityDate = Date.Today().AddDays(1));
			}
			insert t;
		}

		// get the current work item
		List<ProcessInstanceWorkitem> pwi = [select id, actorid from processinstanceworkitem where processinstance.targetobjectid = :evalID];

		if ( pwi.size() == 0) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error approving or rejecting item'));
			return;
		}
		req.setWorkitemId(pwi[0].id);

		// Submit the request for approval
		Approval.ProcessResult result =  Approval.process(req);

		//the below logic sets the resident assessment status to Final Admission/Final Revision
		NoSharingRecord nsr = new NoSharingRecord(thisEval.id);
		if (thisEval.Recordtype.Name == 'NursesAssessment' && approvalAction != 'Reject') {
			list<Service_Assignment__c> servAssign = [
				SELECT ID, (SELECT Id
				            FROM Evaluations__r
				            WHERE Status__c != 'Disregard'
				            AND Recordtype.Name ='NursesAssessment' order by createdDate asc)
				  FROM Service_Assignment__c
				 WHERE Id=: thisEval.ServiceAssignment__c
				 LIMIT 1
			];
			if(thisEval.Id == servAssign[0].Evaluations__r[0].Id){
				nsr.setStatusAndSave('Final Admission');
			} else {
				nsr.setStatusAndSave('Final Revision');
			}
		}
	}

	public ID getApprovalUserID(ID theID) {
		List<ProcessInstanceWorkitem> pwi = [select id, actorid from processinstanceworkitem where processinstance.targetobjectid = :theID];

		if (pwi.size() > 0) {
			system.debug('Approver is:' + pwi[0].actorID);
			return pwi[0].actorId;
		} else {
			return null;
		}
	}

	// need this to get around the eval that is locked through approval process
	public without sharing class NoSharingRecord {
		private ID evalID;
		public Evaluation__c theEval;

		public NoSharingRecord( ID theID ) {
			evalID = theID;
			theEval = (Evaluation__c)[ select id, status__c from evaluation__c where id = :evalID LIMIT 1 ];
		}

		public void setStatusAndSave( string newstatus) {
			theEval.status__c = newstatus;
			update theEval;
		}
	}
}