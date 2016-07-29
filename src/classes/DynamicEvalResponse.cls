public with sharing class DynamicEvalResponse {
	public Integer numCols { get; set; }
	public Integer numRows { get; set; }
	public Boolean hasError { get; set; }
	public string username { get; set; }
	public string password { get; set; }
	public Boolean eSignable { get; set; }

	public string labels{ get; set; }

	public Boolean canCreate { get {
		Schema.DescribeSObjectResult oSchema = Evaluation_Response__c.sObjectType.getDescribe();
		return oSchema.isCreateable();
	}
		set; }

	public Boolean canEdit { get {
		Schema.DescribeSObjectResult oSchema = Evaluation_Response__c.sObjectType.getDescribe();
		return oSchema.isUpdateable();

	}
		 set; }

	public string currentUserOpGroup{get; set;}

	public set<string> reqFields { get; set; }

	public Id saId { get; set; }
	public Id cmplanId { get; set; }
	public Id evaluationId { get; set; }
	public Id pbsId { get; set; }
	public Id tmnProviderId { get; set; }
	public Id tmnProviderApplicationId { get; set; }

	public String frmTitle {
		get {
			if (frmTitle == null) {
				frmTitle = responseType;
			}
			return frmTitle;
		}
		set;
	}

	public String responseType { get; set; }
	public String[] columnsToFetch { get; set; }
	public Map<String, String> columnsToHeadersMap { get; set; }
	public Boolean dialogShown { get; set; }
	public Boolean isEdit { get; set; }

	// Apparently when a POST back is received, getResponses() is called before the save method,
	// and before getTable() is called. So we use the following variable to know when to actually
	// query the db (otherwise we end up with stale results)
	private transient Boolean responsesNeeded;

	private transient Evaluation_Response__c[] responses;

	public Evaluation_Response__c[] getResponses() {
		if (responseType == null || responsesNeeded == null) {
			return null;
		}
		if (responses != null) {
			return responses;
		}
		if (evaluationId != null) {
			responses = fetchResponses(evaluationId, responseType);
		}
		if (pbsId != null) {
			responses = fetchResponsesFromPBS(pbsId, responseType);
		}
		if (saId != null) {
			responses = fetchResponsesFromServAssign(saId, responseType);
		}
		if (cmPlanId != null) {
			responses = fetchResponsesFromCaseManagementPlan(cmplanId, responseType);
		}

		if (tmnProviderApplicationId != null) {
			responses = fetchResponsesFromTmnProviderApplication(tmnProviderApplicationId, responseType);
		}
		if (tmnProviderId != null) {
			responses = fetchResponsesFromTmnProviderApplication(tmnProviderId, responseType);
		}

		return responses;
	}
	public Integer numberOfResponses {
		get {
			if (responsesNeeded == null || getResponses() == null) {
				return 0;
			}
			return getResponses().size();
		}
		set;
	}
	public Evaluation_Response__c currentResponse { get; set; }
	public Id currentResponseId { get; set; }

	public DynamicEvalResponse() {
		currentResponse = new Evaluation_Response__c();
		dialogShown = false;
		isEdit = false;
		reqFields = new set<string>();
		hasError = false;
		currentUserOpGroup = [SELECT Id, Operating_Group__c FROM User WHERE Id= :Userinfo.getUserId()].Operating_Group__c;
	}

	public PageReference showAddResponse() {
		currentResponse = new Evaluation_Response__c();
		currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType(responseType);
		if ( responseType == 'Im_InvestigationLogEntry')
			currentResponse.IncidentInvestigation__c = evaluationId;
		else if ( responseType == 'Im_AddendumLogEntry')
			currentResponse.ImIncident__c = evaluationId;
		else
			currentResponse.Evaluation__c = evaluationId;

		currentResponse.Person_Being_Served__c = pbsId;
		currentResponse.Service_Assignment__c = saId;
		currentResponse.Case_Management_Plan__c = cmplanId;
		currentResponse.Tmn_Provider__c = tmnProviderId;
		currentResponse.Tmn_Provider_Application__c = tmnProviderApplicationId;
		dialogShown = true;
		isEdit = false;
		return null;
	}

	public PageReference showEditResponse() {
		String query = 'SELECT ID, Disregard__c, Status__c , eSigned_on__c, eSigned_By__c, service_assignment__c, Case_Management_Plan__c, ImIncident__c, IncidentInvestigation__c, ' + getNecessaryColumns(responseType) +
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

	public String timeObserved {
		get {
			return currentResponse.Time_Observed__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.Time_Observed__c);
		}
		set {
			currentResponse.Time_Observed__c = Utility.getDateTimeFromString(value+':00');
		}
	}

	public String timeGiven {
		get {
			return currentResponse.Time_Given__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.Time_Given__c);
		}
		set {
			currentResponse.Time_Given__c = Utility.getDateTimeFromString(value+':00');
		}
	}

	public String startDateTime {
		get {
			return currentResponse.Start_Date_Time__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.Start_Date_Time__c);
		}
		set {
			currentResponse.Start_Date_Time__c = Utility.getDateTimeFromString(value+':00');
		}
	}

	public String endDateTime {
		get {
			return currentResponse.End_Date_Time__c == null ? null : Utility.getMilitarytimeNoSeconds(currentResponse.End_Date_Time__c);
		}
		set {
			currentResponse.End_Date_Time__c = Utility.getDateTimeFromString(value+':00');
		}
	}

	public string getAdultimmunizationReport() {
		Report[] reports = [select id, developername from report where developername = 'Immunization_for_PBS' limit 1];
		string theId = '';
		if (reports.size() > 0) {
			theId = reports[0].Id;
		}
		return theId;
	}

	public string getChildimmunizationReport() {
		Report[] reports = [select id, developername from report where developername = 'Immunization_Child_for_PBS' limit 1];
		string theId = '';
		if (reports.size() > 0) {
			theId = reports[0].Id;
		}
		return theId;
	}

	public string getPBSName() {
		string name;
		name = [SELECT Name FROM Contact WHERE Id=: pbsId].Name;
		return name;
	}

	public void saveResponse() {
		saveRes(false);
	}

	public void saveFinalResponse() {
		saveRes(true);

	}

	public void saveRes(boolean Finalize) {
		hasError = false;

		// Start EC-116
		ID rtId = null;
		List<RecordType> rt = [select id from RecordType where DeveloperName = 'Isolation_Event' and sObjectType = 'Evaluation_Response__c' limit 1];
		if (rt.size() < 1){
			return;
		} else {
			rtId = rt[0].ID;
		}

		if (currentResponse.RecordTypeId == rtId) {
			if (currentResponse.Isolation_Event_Start_Date__c > currentResponse.Isolation_Event_End_Date__c) {
				currentResponse.addError( 'Isolation end date must be after the isolation start date!' );
				hasError = true;
			}
			if(currentResponse.Isolation_Event_End_Date__c > DateTime.newInstance(Date.Today().addDays(1), Time.newInstance(0,0,0,0) )){
				currentResponse.addError( 'Isolation end date cannot be in future!' );
				hasError = true;
			}
		}
		// End EC-116

		// IADAY-10 - date rules
		if (responseType == 'Time Log') {
			if(currentResponse.TMN_User__c == null && (currentResponse.Service_Type__c != 'Alone Time' && currentResponse.Service_Type__c != null)){
				currentResponse.addError( 'Accompanied By is Required' );
				hasError = true;
			}

			// compare start and end dates
			if ( currentResponse.End_Date_Time__c != null ) {
				// end date after start
				if (currentResponse.Start_Date_Time__c > currentResponse.End_Date_Time__c) {
					currentResponse.addError( 'End date must be after the start date.' );
					hasError = true;
				}
				// must be different
				if (currentResponse.Start_Date_Time__c == currentResponse.End_Date_Time__c) {
					currentResponse.addError('Start and End times must be different.');
					hasError = true;
				}
			}

			// can't be in the future
			if(currentResponse.Start_Date_Time__c > DateTime.now() || currentResponse.End_Date_Time__c > DateTime.now()) {
				currentResponse.addError( 'Date and time cannot be in future.');
				hasError = true;
			}

			if (!hasError) {
				// check for date overlap with another event
				List<Evaluation_Response__c> otherTimeLogs = [
					select id, start_date_time__c, end_date_time__c
					  from evaluation_response__c
					 where RecordTypeId = :Utility.getEvaluationResponseRecordType(responseType)
					   and id != :currentResponse.Id
					   and service_assignment__c = :currentResponse.service_assignment__c
					   and disregard__c = false
				];
				for (Evaluation_Response__c tl : otherTimeLogs) {
					if (checkOverlap(tl.start_date_time__c, tl.end_date_time__c, currentResponse.start_date_time__c, currentResponse.end_date_time__c)) {
						currentResponse.addError('A time log entry already exists for that time.  Please correct your entry.');
						hasError = true;
						break;
					}
				}
			}
		} // end IADAY-10

		// start PRI-483
		if (responseType.startsWith('Immunization')) {
			if (currentResponse.Date__c == null && !currentResponse.Date_Unknown__c) {
				currentResponse.addError( 'Date is Required');
				hasError = true;
			}
		}

		// Sravan - OR Combined ISP Rules
		if (responseType == 'K Plan Services' || responseType == 'Waiver Services' || responseType == 'Community Transportation Services') {
			if(currentResponse.ISP_Same_as_plan_year__c == false && (currentResponse.ISP_Start__c == null || currentResponse.ISP_End__c == null)) {
				currentResponse.addError('Either Same as Plan Year or Start and End is mandatory');
				hasError = true;
			}
			if(responseType == 'K Plan Services' && String.isNOTBLANK(currentResponse.ISP_List_Needs_Identified__c) && currentResponse.ISP_List_Needs_Identified__c.contains('Other') && string.isBlank(currentResponse.ISP_Specify_Other__c)){
				currentResponse.addError('Specify Other is mandatory');
				hasError = true;
			}
		}

		if(responseType == 'Evaluation' && currentResponse.ISP_Evaluation_Date__c != null && currentResponse.ISP_Evaluation_Date__c > system.Today()){
			currentResponse.addError('Evaluation date cannot be in future');
			hasError = true;
		}
		//End - OR Combined ISP Rules

		// end PRI-483
		if(finalize && currentResponse.End_Date_Time__c == null){
			currentResponse.addError('End Date/Time is Required to Finalize');
			hasError = true;
		}
		try {
			if(reqFields != null){
				for(string rCol : reqFields){
					if (columnsToHeadersMap.containsKey(rCol) && currentResponse.get(rCol) == null) {
						currentResponse.addError(columnsToHeadersMap.get(rCol) + ' is Required');
						hasError = true;
					}
				}
			}

			if (!hasError) {
				if (finalize) {
					currentResponse.Status__c = 'Final';
				}
				upsert currentResponse;
			}
		} catch (DMLException ex) {
			hasError = true;
			system.debug(ex);
			for (Integer i = 0; i < ex.getNumDml(); i++) {
				// Process exception here
				currentResponse.addError(ex.getDmlMessage(i));
			}
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
		} catch (DMLException ex) {
			hasError = true;

		}
	}

	public void finalizeResponse() {
		try {
			system.debug('finalizing - ' + currentResponse);
			hasError = false;
			Evaluation_response__c res = [SELECT Id, Status__c FROM Evaluation_Response__C WHERE id=: currentResponseId];
			res.Status__c = 'Final';
			update res;
		} catch (DMLException ex) {
			hasError = true;
		}
	}

	public void deleteResponse() {
		try{
			currentResponse = new Evaluation_Response__c(id=currentResponseId);
			delete currentResponse;
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
		auth.expressions.rerender = '{!$Component.evalResponseBlock_Alt1_Header.responseTableWrapper}, responseDialogMainBlock, responseDialogErrors';
		auth.expressions.oncomplete = 'closeAuthenticationDialog{!uniqueId}(); alert("This document was electronically signed by {!$User.FirstName} ({!$User.Email}) on {!NOW()}");';
		return auth;
	}

	public Component.Apex.PageBlockTable getTable() {
		// We use dynamic component here to cut down on the internal view state used by the page due
		// to nested <apex:repeat>

		responsesNeeded = true;
		Component.Apex.PageBlockTable table = new Component.Apex.PageBlockTable();
		table.expressions.value = '{!responses}';
		table.var = 'response';
		table.expressions.rendered= '{!numberOfResponses > 0}';
		table.headerClass = 'tbl-header';
		table.rowClasses = 'tmn-row-odd, tmn-row-even';

		Component.Apex.Column action = new Component.Apex.Column(width='80px', styleClass='actionCol');
		action.expressions.headerValue = '{!IF(AND(responses != null, responses.size>0, isPdf != true), \'Action\', \'\')}';
		action.expressions.rendered = '{!editEnabled && canEdit}';

		Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel(layout='none');
		panel.expressions.rendered = '{!OR(allowEditNonOwned, response.owner.id == $User.Id)}';

		Component.Apex.CommandLink customEdit = new Component.Apex.CommandLink(value='Edit');
		customEdit.expressions.onClick = '{!onEdit}(\'{!response.Id}\'); return false;';
		customEdit.expressions.rendered = '{!(onEdit != null) && !isPdf && (response.eSigned_By__c == null) && (response.Isolation_Event_End_Date__c == null) && response.Status__c != \'Final\'}';

		Component.Apex.CommandLink defaultEdit = new Component.Apex.CommandLink(value='Edit');
		defaultEdit.expressions.onClick = 'showEditResponse{!uniqueId}("{!response.Id}"); return false;';
		defaultEdit.expressions.rendered = '{!(onEdit == null) && !isPdf && (response.eSigned_By__c == null) && !response.Disregard__c && (response.Isolation_Event_End_Date__c == null) && response.Status__c != \'Final\'}';

		Component.Apex.CommandLink finalize = new Component.Apex.CommandLink(value='Finalize');
		finalize.expressions.onClick = 'finalize{!uniqueId}("{!response.Id}"); return false;';
		finalize.expressions.rendered = '{! finalize && !isPdf && !response.Disregard__c && response.Status__c != \'Final\' && response.End_Date_Time__c != null}';

		Component.Apex.CommandLink auth = new Component.Apex.CommandLink(value='E-Sign');
		auth.expressions.onClick = 'auth{!uniqueId}("{!response.Id}"); return false;';
		auth.expressions.rendered = '{! eSign && !isPdf && !response.Disregard__c && (response.esigned_by__c == null) && (( type == \'Time Log\' && response.End_Date_Time__c != null) || type != \'Time Log\')}';

		Component.Apex.CommandLink disregardLink = new Component.Apex.CommandLink(value='Disregard');
		disregardLink.expressions.onClick = 'showEditResponse{!uniqueId}("{!response.Id}"); return false;';
		disregardLink.expressions.rendered = '{!(onEdit == null) && !isPdf && (response.eSigned_By__c != null || response.Status__c == "Final") && !response.Disregard__c }';

		Component.Apex.CommandLink del = new Component.Apex.CommandLink(value='Del');
		del.expressions.onClick = 'deleteResponse{!uniqueId}("{!response.Id}"); return false;';
		del.expressions.rendered = '{!onEdit == null && delEnabled}';

		panel.childComponents.add(customEdit);
		panel.childComponents.add(defaultEdit);
		panel.childComponents.add(finalize);
		panel.childComponents.add(auth);
		panel.childComponents.add(disregardLink);
		panel.childComponents.add(del);

		action.childComponents.add(panel);

		Component.Apex.Repeat repeat = new Component.Apex.Repeat();
		repeat.expressions.value = '{!columnsToFetch}';
		repeat.var = 'column';

		Component.Apex.Column column = new Component.Apex.Column();
		column.expressions.value = '{!response[column]}';
		column.expressions.headerValue = '{!IF(column == null, \'\', columnsToHeadersMap[column])}';

		String[] excludedColumns = new String[] {
			'Hearing_Aid_Type__c',
			'Hearing_Aid_Present__c',
			'Glasses_Contacts_Purpose__c',
			'Glasses_Present__c',
			'Contacts_Type__c',
			'Contacts_Present__c',
			'JawWires_Present__c',
			'Denture_Type__c',
			'Side_Rail_Position__c',
			'Assistive_Device_Removable__c',
			'Assistive_Device_Restricts_Movement__c',
			'Isolation_Event_Start_Date__c',
			'Isolation_Event_End_Date__c',
			'Surrounding_Tissue_Color_and_Condition__c',
			'Undermining_in_cm__c',
			'Tunneling_in_cm__c',
			'Time_Observed__c',
			'End_Date_Time__c',
			'Start_Date_Time__c',
			'Chest_X_Ray_Attached__c',
			'Chest_X_Ray_Result__c',
			'Re_Test_Date__c',
			'Re_test_Result__c',
			'WheelChair_Type__c',
			'Prosthetic_Type__c',
			'Orthotics__c',
			'Narrative_Note__c'
		};
		column.expressions.rendered = '{!column != \'' + String.join(excludedColumns, '\' && column != \'') + '\'}';

		Component.Apex.Column standardNarrativeNote = new Component.Apex.Column();
		standardNarrativeNote.expressions.rendered = '{!AND(column == \'Narrative_Note__c\', type != \'TMN Provider Notes\', type != \'TMN Provider Application Notes\')}';
		standardNarrativeNote.expressions.value = '{!response[column]}';
		standardNarrativeNote.expressions.headerValue = '{!IF(column == null, \'\', columnsToHeadersMap[column])}';

		Component.Apex.Column providerNote = new Component.Apex.Column();
		providerNote.expressions.rendered = '{!AND(column == \'Narrative_Note__c\', OR(type == \'TMN Provider Notes\', type == \'TMN Provider Application Notes\'))}';
		providerNote.expressions.value = '{!response[column]}';
		providerNote.expressions.headerValue = '{!IF(column == null, \'\', columnsToHeadersMap[column])}';

		Component.Apex.Column dateTimeColumn = new Component.Apex.Column();
		dateTimeColumn.expressions.rendered = '{!column==\'Isolation_Event_Start_Date__c\' || column==\'Isolation_Event_End_Date__c\' || column==\'Time_Observed__c\' || column == \'Start_Date_Time__c\' || column == \'End_Date_Time__c\'}';
		dateTimeColumn.expressions.headerValue = '{!IF(column == null, \'\', columnsToHeadersMap[column])}';

		Component.c.MilitaryDateTime dateTimeComponent = new Component.c.MilitaryDateTime();
		dateTimeComponent.expressions.dateTimeVal = '{!response[column]}';

		dateTimeColumn.childComponents.add(dateTimeComponent);

		repeat.childComponents.add(column);
		repeat.childComponents.add(standardNarrativeNote);
		repeat.childComponents.add(dateTimeColumn);

		Component.Apex.Column disregard = new Component.Apex.Column();
		disregard.headerValue = 'Disregard';
		disregard.expressions.rendered = '{!showDisregard}';

		Component.Apex.OutputField disregardField = new Component.Apex.OutputField();
		disregardField.expressions.value = '{!response.Disregard__c}';

		disregard.childComponents.add(disregardField);

		Component.Apex.Column esign = new Component.Apex.Column();
		esign.headerValue = 'E-Sign Info';
		esign.expressions.rendered = '{!eSign}';

		// TODO fix this
		Component.Apex.OutputText esignDate = new Component.Apex.OutputText();
		esignDate.styleClass = 'view';
		esignDate.expressions.value = '{!response.eSigned_On__c} ';

		Component.Apex.OutputField esignBy = new Component.Apex.OutputField();
		esignBy.expressions.value = '{!response.eSigned_By__c}';

		esign.childComponents.add(esignDate);
		esign.childComponents.add(esignBy);

		Component.Apex.Column status = new Component.Apex.Column();
		status.headerValue = 'Status';
		status.expressions.value = '{!response.Status__c}';
		status.expressions.rendered = '{!finalize}';

		table.childComponents.add(action);
		table.childComponents.add(repeat);
		table.childComponents.add(disregard);
		table.childComponents.add(esign);
		table.childComponents.add(status);

		return table;
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
			if(column == 'Label__c'){lbl.styleClass='labelCol';}

			if ( column == 'Isolation_Event_Start_Date__c' || column == 'Isolation_Event_End_Date__c' || column == 'Time_Observed__c' || column == 'Time_Given__c' || column == 'Start_Date_Time__c' || column == 'End_Date_Time__c'){
				Component.Apex.InputText dialogInput = new Component.Apex.InputText(id=column);
				dialogInput.styleClass = 'militaryDateTime';
				if (column == 'Isolation_Event_Start_Date__c' ) dialogInput.expressions.value = '{!isolationEventStartDate}';
				else if (column == 'Isolation_Event_End_Date__c' ) dialogInput.expressions.value = '{!isolationEventEndDate}';
				else if (column == 'Time_Observed__c' ) dialogInput.expressions.value = '{!timeObserved}';
				else if (column == 'Time_Given__c' ) dialogInput.expressions.value = '{!timeGiven}';
				else if (column == 'Start_Date_Time__c') dialogInput.expressions.value = '{!startDateTime}';
				else if (column == 'End_Date_Time__c') dialogInput.expressions.value = '{!endDateTime}';
				PBSI.childComponents.add(lbl);
				PBSI.childComponents.add(dialogInput);
			}else{
				Component.Apex.InputField dialogInput = new Component.Apex.Inputfield(id=column);
				dialogInput.expressions.value = '{!currentResponse[\'' + column + '\']}';
				PBSI.childComponents.add(lbl);
				if(column != 'Label__c'){
					PBSI.childComponents.add(dialogInput);
				}

			}

			dialog.childComponents.add(PBSI);
		}
		return dialog;
	}

	private Evaluation_Response__c[] fetchResponses(Id evaluationId, String responseType) {
		if (responseType.startsWith('Im_')) {
			return fetchResponsesFromIncident(evaluationId, responseType);
		} else {
			String query = 'SELECT Id, Disregard__c, Status__c , eSigned_on__c, eSigned_By__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
					' FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId' +
					' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
					'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc' ;
			return Database.query(query);
		}
	}

	private Evaluation_Response__c[] fetchResponsesFromPBS(Id pbsId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Person_Being_Served__c = :pbsId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		System.debug(query);
		return Database.query(query);
	}

	private Evaluation_Response__c[] fetchResponsesFromServAssign(Id saId, String responseType) {
		String query = 'SELECT Id, Owner.Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, Service_Assignment__r.Person_Being_Served__c, ' + getNecessaryColumns(responseType);
		if ( responseType != 'Isolation Event')
			query += ', Isolation_Event_End_Date__c, Isolation_Event_Start_Date__c ';
		query += ' FROM Evaluation_Response__c WHERE Service_Assignment__c = :saId' +
		 		' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) + '\' ORDER BY ';
		if ( responseType == 'Isolation Event')
			query += 'Isolation_Event_Start_Date__c DESC NULLS LAST, ';
		else if (responseType == 'Time Log')
			query += 'Start_Date_Time__c DESC, End_Date_Time__c desc, ';
		query += ' CreatedDate Desc Limit ' + numRows;
		system.debug('Serv Assign Query: ' + query);
		return Database.query(query);
	}

	private Evaluation_Response__c[] fetchResponsesFromCaseManagementPlan(Id cmplanId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, Case_Management_Plan__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :cmplanId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		return Database.query(query);
	}

	private Evaluation_Response__c[] fetchResponsesFromIncident(Id evaluationId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, ImIncident__c, IncidentInvestigation__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c,' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE ' +
				' RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) + '\'';
		if ( responseType == 'Supporting Information' )
				query += ' AND ImIncident__c = :evaluationId ';
		else if ( responseType == 'Log Entry')
				query += ' AND IncidentInvestigation__c = :evaluationId ';

		query += ' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		return Database.query(query);
	}

	private Evaluation_Response__c[] fetchResponsesFromTmnProvider(Id tmnProviderId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, Tmn_Provider__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c,' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Tmn_Provider__c = :tmnProviderId AND' +
				' RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) + '\'';

		query += ' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		return Database.query(query);
	}

	private Evaluation_Response__c[] fetchResponsesFromTmnProviderApplication(Id tmnProviderApplicationId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, Status__c , eSigned_By__c, Tmn_Provider__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c,' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Tmn_Provider_Application__c = :tmnProviderApplicationId AND' +
				' RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) + '\'';

		query += ' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		return Database.query(query);
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

			if(currentUserOpGroup == 'NeuroRestorative' && (column.getFieldPath() == 'Depth__c' || column.getFieldPath() == 'Exudate_Type_Odor_Amount__c' || column.getFieldPath() == 'Undermining_in_cm__c' || column.getFieldPath() == 'Tunneling_in_cm__c' || column.getFieldPath() =='Surrounding_Tissue_Color_and_Condition__c'
				|| column.getFieldPath() == 'Associated_Pain__c' || column.getFieldPath() == 'Time_Observed__c' ) && recordType == 'Pressure Ulcer Detail')
				continue;

			columnsToFetch.add(column.getFieldPath());

			// check for custom label
			string label = (string)column.getLabel();
			Map<String,String> labelMap = new map<String, String>();

			if (!string.isempty( labels)) {
				labels= labels.unescapeHtml3();
				list<FieldLabelVal> objs = (list<FieldLabelVal>) JSON.deserialize(labels, list<FieldLabelVal>.class);

				for(FieldLabelVal d : objs){
					labelMap.put(d.field, d.label);
				}

			}

			if ( labelMap.size() > 0 ) {
				if ( labelMap.get( column.getFieldPath())!= null) {

					label = String.valueof(labelMap.get( column.getFieldPath()));
				}
			}
			columnsToHeadersMap.put(column.getFieldPath(), label);
			if( column.getRequired() ){
				reqFields.add( column.getFieldPath() );
			}
		}
		return String.join(columnsToFetch, ', ');

	}

	public class FieldLabelVal{
		public String field;
		public String label;
	}

	private boolean checkOverlap ( DateTime s1, DateTime e1, DateTime s2, DateTime e2) {

		Boolean overlaps = false;
		system.debug( 'end date is: ' + e1 );
		if ( e1 == null ) // first set is not a range - can't compare
			return overlaps;

		if ( s2 >= s1 && s2 <= e1 ) // starts within first timeframe
			overlaps = true;
		else {
			if ( e2 != null ) {
				if ( e2 > s1 && e2 < e1 ) // ends within first timeframe
					overlaps = true;
				else if ( s2 < s1 && e2 > e1) // covers first time span
					overlaps = true;
			}
		}
		system.debug('overlaps: ' + overlaps + ', ' + s1 + e1 + s2 + e2 );
		return overlaps;
	}
}