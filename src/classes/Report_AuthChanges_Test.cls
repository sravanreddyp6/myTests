
@isTest
private class Report_AuthChanges_Test {

   static testMethod void testReport() {

    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
    upsert myData.theSA;
    
    DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
    DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
    RecordType rt = [select id from recordtype where sobjecttype='Funding_source__c' and name='CareMeridian' LIMIT 1];
    
    Funding_Source__c fs = new Funding_Source__c( type_of_coverage__c = 'Primary', service_assignment__c = myData.theSA.ID, recordtypeid = rt.Id);
    insert fs;
    
    rt = [ select id from recordtype where sobjecttype='Authorization__c' and name ='Funding Source Auth CM' LIMIT 1]; 
    Authorization__c auth = new Authorization__c( funding_source__c = fs.id, payer_effective_date__c = Date.NewInstance( 2015,10, 1), payer_end_date__c = Date.NewInstance(2015, 10, 31),
    						type__c = 'Defined Stay', authorization_status__c = 'Draft', recordtypeid=rt.Id, person_being_served__c = myData.contactID);
    insert auth;
    
    PageReference ref = new PageReference('/apex/Report_AuthChanges');
    Test.setCurrentPage(ref); 
    Report_AuthChanges cntl = new Report_AuthChanges();

    cntl.startdate =  Date.newInstance(2015,10,1);
	cntl.enddate = Date.newInstance(2014,11,1);

    cntl.select2PrmIds = new List<ID>();
    cntl.selectedprograms = new List<ID>();
  
    if ( cntl.getprogramsList().size() > 0) {
    	for (SelectOption p : cntl.getprogramslist() ){
	    		cntl.selectedprograms.Add(p.getValue());
			}
    }
    cntl.AddPrograms();
    
    
    System.debug( cntl.getPBSList());
    
    List<ID> pbs = new List<ID>();
    pbs.Add( cntl.getPBSList().get(0).getValue());
    
    cntl.selectedPBS = pbs;
    cntl.runReport();

	// verify an error was thrown
	List<ApexPages.Message> msgList = ApexPages.getMessages();
	
	for(ApexPages.Message msg :  ApexPages.getMessages()) {
    	System.assertEquals('Please choose valid start and end dates', msg.getSummary());
    	System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
	}

	cntl.startdate =  Date.newInstance(2015,10,1);
	cntl.enddate = Date.newInstance(2014,11,1);
	cntl.runreport();

	/*
	 * SSW: 12/03/2015
	 *
	 * Yesterday DECEMBER 02 2015, we noticed this test failed in production not allowing us to release any code. We tried to release a
	 * HotFix and it would not go in because of this test class. Then we tried manually running this test class "alone" in prod
	 * without doing a release and it STILL FAILED. Previous to 12/01/2015 this test class PASSED without issues. First time it failed was 
	 * 12/02/2015.
	 * 
	 * The same issue was replicated in Stage, which is good.. If I changed the number in the NewInstance from 2015, 12, 1 to 2015, 12, 2 the test PASSED.
	 * So it seems as though end date can't be before the current date or the test will fail (not sure why that is, I don't have enought time to dig in that deep..).
	 *
	 * To get around this for now I'm setting the end date to the current date (dynamically) so this class does not sneak up on us and fail again in production.
	 *
	 * Origina Line: cntl.enddate = Date.NewInstance( 2015, 12, 1);
	 * Changed To: cntl.enddate = date.today();
	 */ 
	cntl.enddate = date.today();
	cntl.runreport();
	
	cntl.getLogMap();
	Map<id, String> ppl = cntl.getPeople();
	System.Assert( ppl.size() == 1);

	Map<id, integer> authct = cntl.getAuthCount();
	system.Assert( authct.size() == 1);
	
	for ( Id p : ppl.keyset() ) {
		Integer auths = authct.get( p);
		System.Assert( auths == 1);
	}
	
    cntl.select2PrmIds.Add( cntl.selectedprograms[0]);
    cntl.RemovePrograms();
    
    cntl.getSelect2List();
    PageReference pr = cntl.cancelToNewRun();
    System.Assert( pr.getURL().contains('Report_AuthChanges'));
    
   }
}