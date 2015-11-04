
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

	
	cntl.enddate = Date.NewInstance( 2015, 12, 1);
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