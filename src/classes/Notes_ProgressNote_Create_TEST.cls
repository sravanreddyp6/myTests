@isTest
private class Notes_ProgressNote_Create_TEST {

    static testMethod void testAZ() {


		TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
		coredata.loadData( 'AZ');
		
		ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'AZ', '1-123456' );
		ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
		coredata.theSA.service_location__c = newSLid1;
		update coredata.theSA;
		
		Progress_Note__c p = new Progress_Note__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(p);

        PageReference pageRef = Page.Notes_ProgressNote_Create;
        Test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('state', 'AZ');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('service_assignment', coredata.theSA.ID);
        Notes_ProgressNote_Create objNpncTest = new Notes_ProgressNote_Create(sc);
        System.Assert( objNpncTest.myRTs.size() > 0 );
        System.AssertEquals(null, objNpncTest.redirect());

		coredata.theSA.service_location__c = newSLid1a;
		update coredata.theSA;

		Progress_Note__c p2 = new Progress_Note__c();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(p2);

        PageReference pageRef2 = Page.Notes_ProgressNote_Create;
        Test.setCurrentPageReference(pageRef2);

        ApexPages.currentPage().getParameters().put('state', 'AZ');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('service_assignment', coredata.theSA.ID);
        Notes_ProgressNote_Create objNpncTest2 = new Notes_ProgressNote_Create(sc2);
		
		System.Assert(objNpncTest2.redirect() != null); // redirect to shift note

        }

	static testMethod void testFL() {


		TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
		coredata.loadData( 'FL');
		
		ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'FL', '1-123456' );
		coredata.theSA.service_location__c = newSLid1;
		update coredata.theSA;
		
		Progress_Note__c p = new Progress_Note__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(p);

        PageReference pageRef = Page.Notes_ProgressNote_Create;
        Test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('state', 'FL');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('service_assignment', coredata.theSA.ID);
        Notes_ProgressNote_Create objNpncTest = new Notes_ProgressNote_Create(sc);
        System.Assert( objNpncTest.myRTs.size() > 0 );
        System.Assert( objNpncTest.getmyrts().size() > 0 );
        System.Assert( objNpncTest.getrtoptions().size() > 0 );
        System.Assert( objNpncTest.rtOptions.size() > 0 );
        System.AssertEquals(null, objNpncTest.redirect());


        }


	static testMethod void testShiftNote() {

		// create a user in Redwood operating group
		User rwuser = TMN_Generic_Core_TestData.createUser('ESD General', 'pntestcr', 'pntestcreate@lkjf.com', 'Progress', 'Notestest', 'Redwood');
		User currUser = [ select id, Operating_Group__c from User where id = :rwuser.id];
		 system.debug( currUser.operating_group__c);
		TMN_Generic_Core_TestData.permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Clinical_Data_User'}, rwuser.id);
		system.runas( rwuser) {
		TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
		coredata.loadData( 'IN');
		
		ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'IN', '1-123456' );
		coredata.theSA.service_location__c = newSLid1;
		update coredata.theSA;
		
		Progress_Note__c p = new Progress_Note__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(p);

        PageReference pageRef = Page.Notes_ProgressNote_Create;
        Test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('state', 'IN');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('service_assignment', coredata.theSA.ID);
        Notes_ProgressNote_Create objNpncTest = new Notes_ProgressNote_Create(sc);
        system.debug( 'Record type options:' + objNpncTest.rtoptions);
        System.Assert(objNpncTest.redirect() != null); // redirect to shift note
		}

        }

        
        static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
		
		Service_location__c newSL = new Service_location__c( alias__c = alias, programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
		insert newSL;
		
		return newSL.Id;
		
	}
	
}