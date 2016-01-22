@isTest
private class Report_KidTraksExport_ControllerTEST {

    static testMethod void simpleTest() {
        Report_KidTraksExport_Controller controller = new Report_KidTraksExport_Controller();
        System.AssertEquals(1, controller.reportPrograms.size());
        System.AssertEquals( controller.theUser.Id, UserINfo.getUserId());
        
        controller.reportStartDate = Date.newInstance(2014,1,1);
        controller.reportEndDate = Date.newInstance(2014,12,31);
        controller.reportProgram = 'TEST PROGRAM VALUE';
        controller.submitParams();
        System.AssertEquals( true, controller.reportResultsDisplayed );
        System.AssertEquals( 0, controller.lineItems.size());


		// create a test case
		TMN_Generic_Core_TestData testdata = new TMN_Generic_Core_TestData();
		testdata.loadData('IN');
		serviceassignment_Servicecode_jo__c sasc = new serviceassignment_Servicecode_jo__c( Service_assignment__c = testdata.theSA.id, Service_code__c = testdata.theServiceCode.id); 
		insert sasc;
		
		testdata.theSA.program_Detail__c = 'TEST PROGRAM VALUE';
		update testdata.theSA;
		 
		
		Datetime pnstart = datetime.newinstance(2014,10,1,0,0,0);
		Datetime pnend = Datetime.newinstance(2014,10,1,2,0,0);
		
		
		Contact c = [ select id from contact where accountid = :testdata.theaccount.Id limit 1];
		Progress_Note__c pn = new Progress_Note__c(Service_Assignment__c = testdata.thesa.Id,
                                                                    Service_Code__c = testdata.theservicecode.id, 
                                                                    Admission__c = testdata.theadm.ID,
                                                                    Start_Time__c = pnstart,
                                                                    End_Time__c = pnend,
                                                                    Person_Being_Served__c = c.id,
                                                                    No_Approval_Needed__c = true,
                                                                    recordtypeId = [select id from recordtype where developername = 'IN_FCT' LIMIT 1].id,
                                                                    Approval_Status__c = 'Approved',
                                                                    Status__c = 'Final');
        insert pn;
        pn.status__c = 'Final';
        update pn;
        
        
        
    	
        controller.submitParams();
        system.assertequals( 1, controller.lineItems.size());
        
    }
}