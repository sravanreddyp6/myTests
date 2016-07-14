@isTest
private class Report_DraftAuths_Test {
	
	private static Report_DraftAuths cntl;
	
	@testSetup
	static void setUp() {
	    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
	    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
	    upsert myData.theSA;
	    
	    DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
	    DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
	    RecordType rt = [select id from recordtype where sobjecttype='Funding_source__c' and name='CareMeridian' LIMIT 1];
	    
	    Funding_Source__c fs = new Funding_Source__c( type_of_coverage__c = 'Primary', service_assignment__c = myData.theSA.ID, recordtypeid = rt.Id);
	    insert fs;
	    
	    rt = [ select id from recordtype where sobjecttype='Authorization__c' and name ='Funding Source Auth CM' LIMIT 1]; 
	    Authorization__c auth = new Authorization__c( funding_source__c = fs.id, payer_effective_date__c = Date.NewInstance(2014, 11, 1), payer_end_date__c = Date.NewInstance(2014, 12, 31),
	    						type__c = 'Defined Stay', authorization_status__c = 'Draft', recordtypeid=rt.Id, person_being_served__c = myData.contactID);
	    insert auth;
	    
	}
	
	/**
	 * Convenience method to initialize the controller being tested.
	 */
	private static void initController() {
	    PageReference ref = new PageReference('/apex/Report_DraftAuths');
	    Test.setCurrentPage(ref); 
	    cntl = new Report_DraftAuths();
	
	    cntl.select2PrmIds = new List<ID>();
	    cntl.selectedprograms = new List<ID>();
	  
	    if ( cntl.getprogramsList().size() > 0) {
	    	system.debug('programs list size=' + cntl.getProgramsList().size());
	    	for (SelectOption p : cntl.getprogramslist() ){
		    		cntl.selectedprograms.Add(p.getValue());
				}
	    }
	    cntl.AddPrograms();
	    
	    List<ID> pbs = new List<ID>();
	    pbs.Add( cntl.getPBSList().get(0).getValue());
	    
	    cntl.selectedPBS = pbs;
	}

	/**
	 * Test to verify that if start date is after end date that the appropriate
	 * error message is displayed.
	 */
	static testMethod void testInvertedDates() {
		
		initController();

	    cntl.startdate =  Date.newInstance(2015,10,1);
		cntl.enddate = Date.newInstance(2014,11,1);
	
	    System.debug('PBS List=' + cntl.getPBSList());
	    
	    cntl.runReport();
	
		// verify an error was thrown
		List<ApexPages.Message> msgList = ApexPages.getMessages();
		
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
	    	System.assertEquals('Please choose valid start and end dates', msg.getSummary());
	    	System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
		}
	}
	
	/**
	 * Test date range selected after active range of service assignment.
	 */
	static testMethod void testAfterRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2015, 10, 1);
		cntl.enddate = Date.NewInstance(2015, 12, 1);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(0, auths);
		}
	}
	
	/**
	 * Test date range selected with start date before end date of active range of service assignment 
	 * and selected end date after that.
	 */
	static testMethod void testStrattlingEndDateRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2014, 12, 1);
		cntl.enddate = Date.NewInstance(2015, 12, 1);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(1, auths);
		}
	}
	
	/**
	 * Test date range selected completely contained within the active range of service assignment.
	 */
	static testMethod void testEntirelyWithinRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2014, 11, 15);
		cntl.enddate = Date.NewInstance(2014, 12, 15);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(1, auths);
		}
	}
	
	/**
	 * Test date range selected with start date before start date of active range of service assignment 
	 * and selected end date within the range.
	 */
	static testMethod void testStrattlingStartDateRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2014, 1, 1);
		cntl.enddate = Date.NewInstance(2014, 12, 1);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(1, auths);
		}
	}
	
	/**
	 * Test date range selected entirely before active range of service assignment.
	 */
	static testMethod void testBeforeRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2014, 1, 1);
		cntl.enddate = Date.NewInstance(2014, 10, 31);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(0, auths);
		}
	}
	
	/**
	 * Test date range selected where start date is before and end date is after
	 * the service assignment range.
	 */
	static testMethod void testSurroundingRange() {
		
		initController();
	
	    cntl.startdate =  Date.newInstance(2014, 1, 1);
		cntl.enddate = Date.NewInstance( 2015, 12, 1);
		cntl.runreport();
		
		cntl.getLogMap();
		Map<id, String> ppl = cntl.getPeople();
		system.assertEquals(1, ppl.size());
	
		Map<id, integer> authct = cntl.getAuthCount();
		system.assertEquals(1, authct.size());
		
		for ( Id p : ppl.keyset() ) {
			Integer auths = authct.get( p);
			system.assertEquals(1, auths);
		}
	}
	
	/**
	 * Test that the remove function works.
	 */
	static testMethod void testRemovePrograms() {
		initController();
		
	    cntl.select2PrmIds.Add( cntl.selectedprograms[0]);
	    cntl.RemovePrograms();
	    
	    List<SelectOption> sel2 = cntl.getSelect2List();
	    system.assertEquals(0, sel2.size());
	}
	
	/**
	 * Stand alone test for cancel to new run
	 */
	static testMethod void testCancelToNewRun() {
		initController();
	
	    PageReference pr = cntl.cancelToNewRun();
		system.assert( pr.getURL().contains('Report_DraftAuths'));
	    
	}
	
}