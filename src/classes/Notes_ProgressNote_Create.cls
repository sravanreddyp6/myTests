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
	
	// ADDED FOR WVPN-6 to give us a way to identify RecordType default for unsaved note when only one Record Type option is present.
	// J. Gilliam, 3/19/14.
	public RecordType defaultRt { get; set; }

    private Final Progress_Note__c pn;
    
    


//contructs
    public Notes_ProgressNote_Create(ApexPages.StandardController controller) {
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c' ORDER BY Name];
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
        
        ID saID = ApexPages.currentPage().getParameters().get('service_assignment');
        Service_Assignment__c sa = [select id, name, service_location__r.programid__c from service_assignment__c where id = :saID LIMIT 1];
        
        // If Progress Note is AZ-OPT, we have to default some fields here, but only for non-CM AZ
        if (myState == 'AZ') {
        	if ( sa.service_location__r.programid__c != '114165002') {
            	pn.Number_of_Required_Signatures__c = 1;
            	pn.RecordTypeId = AZ_OPT_ID;
        	} else {
        		pn.RecordTypeId = SHIFT_NOTE_ID;
        	}
        } 	
        
        
        // get the user's operating group
        //TMN_User__c currUserTMN = [ select operating_group__c from TMN_User__c where Salesforce_User_Account__c = :UserInfo.getUserId() LIMIT 1];
        User currUser = [ select id, Operating_Group__c from User where id = :UserInfo.getUserId()];
        System.Debug('user op group is: ' + currUser.Operating_Group__c );
        if (currUser != null ) {
            if (( myState == 'MN' || myState == 'IN' || myState == 'CA') && currUser.Operating_Group__c == 'Redwood') {
                pn.RecordTypeId = SHIFT_NOTE_ID;
                // special case for CM Ludlow is handled above in AZ
            }
        } else {
            // add error to page that shift note cannot be created
        }
        loadData();
    }
    public Notes_ProgressNote_Create() {
        
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c' ORDER BY Name];
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
        
        // START: ADDED FOR WVPN-6; default selection if only one record type is present on the page (J. Gilliam, 3/19/14)
        if(rtOptions.size()==1) {
        	Id defaultRtId;
        	for(SelectOption o : rtOptions) {
        		defaultRtId = o.getValue();
        	}
        	defaultRt = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :defaultRtId ];
        	pn.RecordTypeId = defaultRt.Id;
        }
        // END: ADDED FOR WVPN-6; default selection if only one record type is present on the page (J. Gilliam, 3/19/14)


		// WVPN-6
		// GET RECORD TYPES THAT SHOULD HAVE DEFAULT 0 FOR pn.Number_Of_Required_Signatures__c
		List<RecordType> rtsForZeroSigs = new List<RecordType>();
		rtsForZeroSigs = [ SELECT Name, DeveloperName FROM RecordType WHERE DeveloperName = 'IN_FCT' OR DeveloperName = 'MA_FCT'
							OR DeveloperName = 'MD_FCT' OR DeveloperName = 'OH_FCT' ];
		// LOOP THROUGH THOSE RECORD TYPES AND COMPARE TO RECORD TYPES OF THIS NOTE.  IF SAME, THEN DEFAULT SIGS TO 0
		for(RecordType rtForLoop : rtsForZeroSigs) {
			if(rtForLoop.Id==pn.RecordTypeId && pn.Number_of_Required_Signatures__c==null) {
				pn.Number_of_Required_Signatures__c = 0;
			}
		}

    }

// redirect if necessary
    public PageReference redirect(){
        ID planID = ApexPages.currentPage().getParameters().get('plan');
        ID admID = ApexPages.currentPage().getParameters().get('admission');
        ID saID = ApexPages.currentPage().getParameters().get('service_assignment');
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if ( pn.RecordTypeId == SHIFT_NOTE_ID ) {
            PageReference prShiftNote = Page.shiftnote_basic_form;
            prShiftNote.getParameters().put('planID', planId);
            prShiftNote.getParameters().put('admID', admId);
            prShiftNote.getParameters().put('saID', saID);
            prShiftNote.getParameters().put('retURL', retURL);
            prShiftNote.setRedirect(true);
            return prShiftNote;
        }
        else
            return null;
                
    }

}