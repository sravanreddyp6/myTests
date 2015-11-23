public with sharing class Shift_Note_Narrative implements AuthenticatedAction {
	Progress_Note__c note = new Progress_Note__c();
	string userid = UserInfo.getUserId();

	public string noteStart_DateTime { get; set; }
	public string noteEnd_DateTime { get; set; }

	public string retURL { get; private set;}

	public boolean canFinalize { get; set; }

	public boolean editMode { get ; set; }

	public Shift_Note_Narrative() {
		// to support authentication handler
	}

	public Shift_Note_Narrative(ApexPages.StandardController controller) {
		if (!Test.isRunningTest()) {
			controller.AddFields (new List<String> {'Service_Assignment__c', 'Admission__c'});
		}
		note = (Progress_Note__c)controller.getRecord();

		note.Number_of_Required_Signatures__c = 0;
		note.Healthcare_Medical_Note__c = true;

		editMode = false;

		system.debug('Edit mode' + editMode);
		canFinalize = false;
		if(apexpages.currentpage().getparameters().get('edit')=='1' && !note.locked__c){
			editMode= true;
		}
		if(note.id ==null){
			note.service_assignment__c = apexpages.currentpage().getparameters().get('saID');
			note.admission__c = apexpages.currentpage().getparameters().get('admID');
			editMode = true;
			note.RecordTypeid = [select id from recordtype where DeveloperName='Shift_Note' and SobjectType='Progress_Note__c' limit 1].id;
			note.Person_Being_served__c = [select person_being_served__c from admission__c where id = :apexpages.currentpage().getparameters().get('admID')].person_being_served__c;
		}
		system.debug('Edit mode' + editMode);
		setPastNotes();
		retURL = apexpages.currentpage().getparameters().get('retURL');
		if (String.isBlank( retURL )) {
			retURL = '/home';
		}

		system.debug('Edit mode' + editMode);
	}


	public pagereference mySave(){
		try {
			note.Start_Time__c = DateTime.Now();
			note.End_Time__c = DateTime.Now().AddMinutes(1);
			if ( string.isblank(note.narrative__c) ) {
				ApexPages.addMessage( new ApexPages.Message(ApexPages.severity.error, 'Narrative text is required.'));
				return null;
			}
			upsert note;
			return null;
		} catch(DMLException e){
			ApexPages.addMessages(e);
			return null;
		} catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}
	}

	public pagereference myEdit(){
		editMode = true;

		return null;
	}


	public pagereference myCancel(){
		// might need to clean up if user has already clicked esign but then cancelled out.  the save occurs first.
		if (note.id != null) {
			Progress_Note__c thisnote = [ select id from progress_note__c where id = :note.id and status__c != 'Final' ];
			if ( thisnote != null )
				delete thisnote;
		}

		// get the return URL from the page
		PageReference pr = new PageReference(retURL);
		return pr;
	}

	public PageReference disregard() {
		note.Status__c = 'Disregard';
		update note;
		PageReference page = new PageReference('/' + note.Id);
		page.setRedirect(false);
		return page;
	}


	public List<Progress_note__c> pastnotes { get; private set; }
	public Map<ID, string> shortdescs { get; private set; }

	private void setpastnotes () {
		// EC-290 - 09/28/15 - update query to only pull notes from last 7 days and limit to 500 (just in case)
		pastnotes = [ select id, start_time__c, end_time__c, status__c, narrative__c, createddate, createdbyid, createdby.name from progress_note__c where service_assignment__c = :note.service_assignment__c and recordtype.developername='Shift_Note' and id != :note.id and createddate = LAST_N_DAYS:7 order by lastmodifieddate desc LIMIT 500];
		shortdescs = new Map<ID, string>();

		string shorttext;
		for ( Progress_note__c pn: pastnotes) {
			shorttext = pn.narrative__c;
			if ( shorttext.length() > 200)
				shorttext = shorttext.substring(0, 200) + '...';

			shortdescs.put( pn.id, shorttext);
		}

		system.debug('pastnotes' + pastnotes);
		system.debug('shortdescs' + shortdescs);
	}

	public PageReference handle(Id recordId, Id userId) {
		Progress_Note__c thisnote = [
			SELECT Id, Status__c, locked__c, approval_status__c, approval_status_date__c,
			       approval_user__c
			  FROM Progress_Note__c
			 WHERE Id=:recordId
		];

		if (thisnote != null) {
			thisnote.status__c = 'Final';
			thisnote.approval_status__c = 'Approved';
			thisnote.approval_status_date__c = Date.Today();
			thisnote.Approval_User__c = UserInfo.getUserId();
			thisnote.locked__c = true;
			thisnote.signature_on_file__c = 'Y';
		}

		try {
			update thisnote;
		} catch (exception e) {
			system.debug(e);
		}
		return null;
	}


}