public with sharing class EvaluationResponseTableController {
	public Integer numCols { get; set; }
	public Integer numRows { get; set; }
	public Boolean hasError { get; set; }
	public string username { get; set; }
	public string password { get; set; }
	public Boolean eSignable { get; set; }

	public set<string> reqFields { get; set; }
	public Id saId {
		get;
		set {
			saId = value;
			if(String.isNotEmpty(saId)){
				if(responseType != null) {
					fetchResponsesFromServAssign(saId, responseType);
				}
			}
		}
	}
	public Id evaluationId {
		get;
		set {
			evaluationId = value;
			if (responseType != null && String.isNotEmpty(evaluationId)) {
				fetchResponses(evaluationId, responseType);
			}
		}
	}
	public Id pbsId {
		get;
		set {
			pbsId = value;
			if (responseType != null && String.isNotEmpty(pbsID)) {
				fetchResponsesFromPBS(pbsId, responseType);
			}
		}
	}
	public String responseType {
		get;
		set {
			responseType = value;
			if (evaluationId != null) {
				fetchResponses(evaluationId, responseType);
			}
		}
	}
	public String[] columnsToFetch { get; set; }
	public Map<String, String> columnsToHeadersMap { get; set; }
	public Boolean dialogShown { get; set; }
	public Boolean isEdit { get; set; }

	public Evaluation_Response__c[] responses { get; set; }
	public Integer numberOfResponses {
		get {
			if (numberOfResponses == null) {
				return 0;
			}
			return numberOfResponses;
		}
		set;
	}
	public Evaluation_Response__c currentResponse { get; set; }
	public Id currentResponseId { get; set; }

	public EvaluationResponseTableController() {
		currentResponse = new Evaluation_Response__c();
		dialogShown = false;
		isEdit = false;
		reqFields = new set<string>();
		hasError = false;
	}

	public PageReference showAddResponse() {
		currentResponse = new Evaluation_Response__c();
		currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType(responseType);
		currentResponse.Evaluation__c = evaluationId;
		currentResponse.Person_Being_Served__c = pbsId;
		currentResponse.Service_Assignment__c = saId;
		dialogShown = true;
		isEdit = false;
		return null;
	}

	public PageReference showEditResponse() {
		String query = 'SELECT ID, Disregard__c, eSigned_on__c, eSigned_By__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Id = :currentResponseId';
		currentResponse = Database.query(query);
		dialogShown = true;
		isEdit = true;
		return null;
	}

	public String isolationEventStartDate {
		get {
			return currentResponse.Isolation_Event_Start_Date__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.Isolation_Event_Start_Date__c);
		}
		set {
			currentResponse.Isolation_Event_Start_Date__c = Utility.getDateTimeFromString(value+':00');
		}
	}
	public String isolationEventEndDate {
		get {
			return currentResponse.Isolation_Event_End_Date__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.Isolation_Event_End_Date__c);
		}
		set {
			currentResponse.Isolation_Event_End_Date__c = Utility.getDateTimeFromString(value+':00');
		}
	}

	public void saveResponse() {
		System.debug('saveResponse called, currentResponse: ' + currentResponse);
		//      Start EC-116
		ID rtId = null;
		List<RecordType> rt = [select id from RecordType where DeveloperName = 'Isolation_Event' and sObjectType = 'Evaluation_Response__c' limit 1];
		if(rt.size() < 1){
			return;
		} else {
			rtId = rt[0].ID;
		}
		if(currentResponse.RecordTypeId == rtId){
			if(currentResponse.Isolation_Event_Start_Date__c > currentResponse.Isolation_Event_End_Date__c){
				currentResponse.addError( 'Isolation end date must be after the isolation start date!' );
				hasError = true;
			}
			if(currentResponse.Isolation_Event_End_Date__c > DateTime.newInstance(Date.Today().addDays(1), Time.newInstance(0,0,0,0) )){
				currentResponse.addError( 'Isolation end date cannot be in future!' );
				hasError = true;
			}
		}
		//      End EC-116

		try {
			hasError = false;
			// string tmp = getNecessaryColumns(responseType);
			if(reqFields != null){
				for(string rCol : reqFields){
					if(columnsToHeadersMap.containsKey(rCol) && currentResponse.get(rCol) == null){
						currentResponse.addError( (columnsToHeadersMap.get(rCol) + ' is Required') );
						hasError = true;}
				}
			}

			if(!hasError){
				upsert currentResponse;
			}
		} catch (DMLException ex) {
			hasError = true;
			system.debug(ex);
			// SF will automatically create a PageMessage Error here, so we don't
			// have to do anything
		}
	}
	public PageReference eSignRecord(){
		try {
			hasError = false;
			if(password != null){
				AuthenticationController.auth( username, password, 'EvaluationResponseTable_Esign', currentResponseId );
			}
			password = null;
		}
		catch (DMLException ex) {
			hasError = true;

		}
		return null;
	}

	public void disregardResponse() {

		try {
			hasError = false;
			Evaluation_response__c disregardResponse = [SELECT Id, DIsregard__c FROM Evaluation_Response__C WHERE id=: currentResponseId]; // Using Explicit query here instead of 'currentResponse' because Kate SJ suggested that changes made to the fields should not be saved while disregarding - Sravan 04/22/2014
			disregardResponse.Disregard__c = true;
			update disregardResponse;
			// currentResponse.Disregard__c = true;
			//  upsert currentResponse;
		} catch (DMLException ex) {
			hasError = true;

		}
	}
	public Component.c.Authentication getAuthentication() {
		// We put this as a dynamic component, so that we don't waste internal
		// view state when e-signing is not necessary. Visualforce counts all
		// components to be in the internal view state regardless of its
		// rendered attribute. Using a dynamic component allows us to only
		// return the component when necessary.
		// Note: there's a bug in Salesforce w.r.t dynamic components and
		// Visualforce component execution order, see:
		// http://salesforce.stackexchange.com/questions/10763/dymamic-components-execution-order-issue
		// Basically eSignable will always be null at the initial page load
		// when this component is displayed. Because of that, before we can
		// do anything we have to rerender this component on the page so that
		// it actually shows up on the page.
		if (eSignable == null || !eSignable) {
			return null;
		}
		Component.c.Authentication auth = new Component.c.Authentication(
				formStyle = 'z-index: 200; ',
				handler = 'EvaluationResponseTable_Esign'
		);
		auth.expressions.formId = '{!formId}';
		auth.expressions.uniqueId = '{!uniqueId}';
		auth.expressions.rerender = '{!$Component.evalResponseBlock.responseTableWrapper}, responseDialogMainBlock, responseDialogErrors';
		auth.expressions.oncomplete = 'closeAuthenticationDialog{!uniqueId}(); alert("This document was electronically signed by {!$User.FirstName} ({!$User.Email}) on {!NOW()}");';
		return auth;
	}

	public Component.Apex.PageBlockSection getDialog() {
		// We use a dynamic component here in order to assign dynamic ids to
		// the form inputs (Visualforce doesn't let us do that using static
		// components)
		// a simple 2x check that we in fact have a value for the number of cols
		if(numCols == null){
			numCols = 2;
		}

		Component.Apex.PageBlockSection dialog = new Component.Apex.PageBlockSection(columns=numCols);
		if (columnsToFetch == null) {
			return dialog;
		}
		for (String column: columnsToFetch) {

			// don't show the last mod details on the entry screen
			if ( column == 'LastModifiedDate' || column == 'LastModifiedByID')
				continue;
			Component.Apex.PageBlockSectionItem PBSI = new Component.Apex.PageBlockSectionItem();
			Component.Apex.OutputLabel lbl = new Component.Apex.OutputLabel();
			lbl.value = columnsToHeadersMap.get(column);
			if(reqFields.contains(column) ){lbl.styleClass = 'evalCompReqField';}

			if ( column == 'Isolation_Event_Start_Date__c' || column == 'Isolation_Event_End_Date__c'){
				Component.Apex.InputText dialogInput = new Component.Apex.InputText(id=column);
				dialogInput.styleClass = 'militaryDateTime';
				if (column == 'Isolation_Event_Start_Date__c' ) dialogInput.expressions.value = '{!isolationEventStartDate}';
				else if (column == 'Isolation_Event_End_Date__c' ) dialogInput.expressions.value = '{!isolationEventEndDate}';
				PBSI.childComponents.add(lbl);
				PBSI.childComponents.add(dialogInput);
			}else{
				Component.Apex.InputField dialogInput = new Component.Apex.Inputfield(id=column);
				dialogInput.expressions.value = '{!currentResponse[\'' + column + '\']}';
				PBSI.childComponents.add(lbl);
				PBSI.childComponents.add(dialogInput);
			}

			dialog.childComponents.add(PBSI);
		}
		return dialog;
	}

	private void fetchResponses(Id evaluationId, String responseType) {
		if(numRows == null){numRows = 1000;}
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, eSigned_By__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc' ;
		responses = Database.query(query);
		numberOfResponses = responses.size();
	}

	private void fetchResponsesFromPBS(Id pbsId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, eSigned_By__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Person_Being_Served__c = :pbsId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		system.debug(query);
		responses = Database.query(query);
		numberOfResponses = responses.size();
	}

	private void fetchResponsesFromServAssign(Id saId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, eSigned_By__c, Service_Assignment__r.Person_Being_Served__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Service_Assignment__c = :saId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Isolation_Event_Start_Date__c DESC NULLS LAST, CreatedDate Limit ' + numRows;
		system.debug('Serv Assign Query: ' + query);
		responses = Database.query(query);
		numberOfResponses = responses.size();
	}

	private String getNecessaryColumns(String recordType) {
		// Convention: Record Type and Fieldset have the exact same label
		List<Schema.FieldSet> allFieldSets = Schema.SObjectType.Evaluation_Response__c.FieldSets.getMap().values();
		Schema.FieldSet fieldSetToUse;

		for (Schema.FieldSet fieldSet: allFieldSets) {
			if (fieldSet.getLabel() == recordType) {
				fieldSetToUse = fieldSet;
			}
		}
		Schema.FieldSetMember[] columns = fieldSetToUse.getFields();
		columnsToFetch = new String[] {};
		columnsToHeadersMap = new Map<String, String>();
		for (Schema.FieldSetMember column: columns) {
			columnsToFetch.add(column.getFieldPath());
			columnsToHeadersMap.put(column.getFieldPath(), column.getLabel());
			if( column.getRequired() ){
				reqFields.add( column.getFieldPath() );
			}
		}
		return String.join(columnsToFetch, ', ');
	}
}