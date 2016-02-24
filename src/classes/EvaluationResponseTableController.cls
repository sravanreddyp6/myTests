public with sharing class EvaluationResponseTableController {
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
	public String frmTitle {
        get {
            if(frmTitle == null)
                frmTitle = responseType;
                return frmTitle;

        }
        set;
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
		currentUserOpGroup = [SELECT Id, Operating_Group__c FROM User WHERE Id= :Userinfo.getUserId()].Operating_Group__c;
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
		String query = 'SELECT ID, Disregard__c, eSigned_on__c, eSigned_By__c, service_assignment__c, ' + getNecessaryColumns(responseType) +
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

    public string getAdultimmunizationReport(){
    	string theId;
        theId= [select id, developername from report where developername = 'Immunization_for_PBS' limit 1].id;

        return theId;
    }

      public string getChildimmunizationReport(){
    	string theId;
        theId= [select id, developername from report where developername = 'Immunization_Child_for_PBS' limit 1].id;

        return theId;
    }

    public string getPBSName(){
    	string name;
    	name = [SELECT Name FROM Contact WHERE Id=: pbsId].Name;
    	return name;

    }
	public void saveResponse() {

		hasError = false;

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

		// IADAY-10 - date rules
		if ( responseType == 'Time Log') {
			// compare start and end dates
			if ( currentResponse.End_Date_Time__c != null ) {
				// end date after start
				if((currentResponse.Start_Date_Time__c > currentResponse.End_Date_Time__c) ){
					currentResponse.addError( 'End date must be after the start date.' );
					hasError = true;
				}
				// must be same day
				if (currentResponse.Start_date_Time__c.Date() != currentResponse.End_Date_Time__c.Date()) {
					currentResponse.addError('Start and End times must occur on the same day.');
					hasError = true;
				}
				// must be different
				if (currentResponse.Start_Date_Time__c == currentResponse.End_Date_Time__c ) {
					currentResponse.addError('Start and End times must be different.');
					hasError = true;
				}
			}
			// can't be in the future
			if(currentResponse.Start_Date_Time__c > DateTime.now() || currentResponse.End_Date_Time__c > DateTime.now()  ){
					currentResponse.addError( 'Date and time cannot be in future.' );
					hasError = true;
			}

			if (! hasError ) {
				// check for date overlap with another event
				system.debug(currentresponse);
				List<Evaluation_Response__c> otherTimeLogs = [ select id, start_date_time__c, end_date_time__c from evaluation_response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType(responseType) and id != :currentResponse.Id and service_assignment__c = :currentResponse.service_assignment__c and disregard__c = false];
				for ( Evaluation_Response__c tl : otherTimeLogs ) {
					if ( checkOverlap( tl.start_date_time__c, tl.end_date_time__c, currentResponse.start_date_time__c, currentResponse.end_date_time__c) ) {
						currentResponse.addError('A time log entry already exists for that time.  Please correct your entry.');
						hasError = true;
						break;
					}
				}
			}

		} // end IADAY-10
		
		// start PRI-483
		if ( responseType.startsWith('Immunization')) {
				if ( currentResponse.Date__c == null && !currentResponse.Date_Unknown__c) {
					currentResponse.addError( 'Date is Required');
					hasError = true;
				}
		}
		// end PRI-483
		
		try {
			// hasError = false;

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
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                currentResponse.addError( ex.getDmlMessage(i) );
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
		auth.expressions.rerender = '{!$Component.evalResponseBlock_Alt1_Header.responseTableWrapper}, responseDialogMainBlock, responseDialogErrors';
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
				if ( column == 'Location__c') {
					PBSI.helpText = 'Please provide the location on the person\'s body where the immunization was administered';
				}
				PBSI.childComponents.add(lbl);
				PBSI.childComponents.add(dialogInput);
			}

			dialog.childComponents.add(PBSI);
		}
		return dialog;
	}

	private void fetchResponses(Id evaluationId, String responseType) {
		if(numRows == null){numRows = 1000;}
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, eSigned_By__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Evaluation__c = :evaluationId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc' ;
		responses = Database.query(query);
		numberOfResponses = responses.size();
	}

	private void fetchResponsesFromPBS(Id pbsId, String responseType) {
		String query = 'SELECT Id, Disregard__c, eSigned_on__c, eSigned_By__c, Isolation_Event_Start_Date__c, Isolation_Event_End_Date__c, ' + getNecessaryColumns(responseType) +
				' FROM Evaluation_Response__c WHERE Person_Being_Served__c = :pbsId' +
				' AND RecordTypeId = \'' + Utility.getEvaluationResponseRecordType(responseType) +
				'\' ORDER BY Date__c Desc NULLS LAST, CreatedDate Desc Limit ' + numRows;
		system.debug(query);
		responses = Database.query(query);
		numberOfResponses = responses.size();
	}

	private void fetchResponsesFromServAssign(Id saId, String responseType) {
		String query = 'SELECT Id, Owner.Id, Disregard__c, eSigned_on__c, eSigned_By__c, Service_Assignment__r.Person_Being_Served__c, ' + getNecessaryColumns(responseType);
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