public with sharing class Notes_ProgressNote_Create {


//varibles
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}

    public string RTid;
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public Id AZ_OPT_ID, SHIFT_NOTE_ID;
    public String pbsName { get; set; }

    public list<SelectOption> rtOptions = new list<SelectOption>();
    public list<SelectOption> getrtOptions(){return rtOptions ;}

	private Final Progress_Note__c pn;


//contructs
    public Notes_ProgressNote_Create(ApexPages.StandardController controller) {
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c'];
        for (RecordType rt: myRTs) {
            if (rt.Name == 'AZ - OPT') {
                AZ_OPT_ID = rt.Id;
            } 
			if (rt.Name == 'Shift Note') {
            	SHIFT_NOTE_ID = rt.Id;
            }
        }
        
        System.Debug('shift note id=' + SHIFT_NOTE_ID);
        String pbsId = ApexPages.currentPage().getParameters().get('person');
        if (!String.isBlank(pbsId)) {
            pbsName = [SELECT Name FROM Contact WHERE Id=:pbsId].Name;
        }
        if (!Test.isRunningTest()) {
            controller.addFields(new String[] {'RecordType.Name'});
            
        }
        pn = (Progress_Note__c) controller.getRecord();
        // If Progress Note is AZ-OPT, we have to default some fields here
        if (myState == 'AZ') {
            pn.Number_of_Required_Signatures__c = 1;
            pn.RecordTypeId = AZ_OPT_ID;
        } 
        
        // get the user's operating group
        //TMN_User__c currUserTMN = [ select operating_group__c from TMN_User__c where Salesforce_User_Account__c = :UserInfo.getUserId() LIMIT 1];
        User currUser = [ select id, Operating_Group__c from User where id = :UserInfo.getUserId()];
        System.Debug('user op group is: ' + currUser.Operating_Group__c );
        if (currUser != null ) {
        	if (( myState == 'MN' || myState == 'IN' || myState == 'CA') && currUser.Operating_Group__c == 'Redwood') {
	        	pn.RecordTypeId = SHIFT_NOTE_ID;
	        	
        	}
        } else {
        	// add error to page that shift note cannot be created
        }
        loadData();
    }
    public Notes_ProgressNote_Create() {
    	
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c'];
        loadData();
        System.Debug('in void controller');
    }
//load
    public void loadData(){
        //important - normalize the strings to lower case
        myState=myState.toLowerCase();
        
        //create record type selection option there is an escape option so is the filter is incorrect as a short term messure -go to the url and remove state in the VF page | (state=) < null or blank |
        SelectOption SO;
        
        for (RecordType thisRT : myRTs){
            string myName = thisRT.Name.toLowerCase();
            if(String.isBlank(myState)){
                SO = new SelectOption(thisRt.Id, thisRt.Name);
                rtOptions.Add(SO);
            }
            else if ( myName == 'shift note' && pn.RecordTypeId == SHIFT_NOTE_ID) {
            	SO = new SelectOption( thisRt.Id, thisRt.Name);
            	rtOptions.Add(SO);
            	break;
            }
            else {
                if(myName.StartsWith(myState)){
                    SO = new SelectOption(thisRt.Id, thisRt.Name);
                    rtOptions.Add(SO);
                }
            }
        }

    }

// redirect if necessary
	public PageReference redirect(){
		ID planID = ApexPages.currentPage().getParameters().get('plan');
		ID admID = ApexPages.currentPage().getParameters().get('admission');
		ID saID = ApexPages.currentPage().getParameters().get('service_assignment');
		if ( pn.RecordTypeId == SHIFT_NOTE_ID ) {
			PageReference prShiftNote = Page.shiftnote_basic_form;
			prShiftNote.getParameters().put('planID', planId);
			prShiftNote.getParameters().put('admID', admId);
			prShiftNote.getParameters().put('saID', saID);
	        prShiftNote.setRedirect(true);
	        return prShiftNote;
        }
        else
        	return null;
	        	
	}

}