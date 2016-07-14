@isTest
private class rptProviderTrackingTest {
	
	private static rptProviderTracking ctrl = new rptProviderTracking();
	
	@testSetup
	static void setUp() {
		Service_Location__c servLoc = new Service_Location__c();
		servLoc.Alias__c = '029435';
		servLoc.FacilityId__c = 13.0;
		servLoc.UniqueID__c = '1234';
		servLoc.Program__c = 'Test Program 1';
		servLoc.Name = 'Service Location 1';
		servLoc.ProgramId__c = '029435000';
		servLoc.Location_Nickname__c = 'Loc 1';
		servLoc.State__c = 'OR';
		servLoc.Service_Type__c = 'CM - Case Management';
		insert servLoc;
		
		servLoc = new Service_Location__c();
		servLoc.Alias__c = '564423';
		servLoc.FacilityId__c = 13.0;
		servLoc.UniqueID__c = '5678';
		servLoc.Program__c = 'Test Program 2';
		servLoc.Name = 'Service Location 2';
		servLoc.ProgramId__c = '564423000';
		servLoc.Location_Nickname__c = 'Loc 2';
		servLoc.State__c = 'OR';
		servLoc.Service_Type__c = 'CM - Case Management';
		insert servLoc;
		
		servLoc = new Service_Location__c();
		servLoc.Alias__c = '789546';
		servLoc.FacilityId__c = 13.0;
		servLoc.UniqueID__c = '9012';
		servLoc.Program__c = 'Test Program 3';
		servLoc.Name = 'Service Location 3';
		servLoc.ProgramId__c = '789546000';
		servLoc.Location_Nickname__c = 'Loc 3';
		servLoc.State__c = 'OR';
		servLoc.Service_Type__c = 'CM - Case Management';
		insert servLoc;
	}

	/**
	 * Validating default value for provider status
	 */
    static testMethod void initializingStatusFieldTest() {
    	String[] provStatus = ctrl.providerStatus;
		system.assertEquals(4, provStatus.size());
		system.assertEquals(new String[] {'Pending Approval', 'Approved', 'Expired', 'Disqualified'}, 
				provStatus);
    }
    
    /**
     * Ensuring that brokerages are initialized upon creation
     */
    static testMethod void initializingBrokerageFieldTest() {
		Service_Location__c[] locIds = [
                     SELECT Id
                       FROM Service_Location__c
                     WHERE State__c = 'OR'
                        AND Service_Type__c = 'CM - Case Management'
                     ORDER BY ProgramId__c
              ];
		
    	List<SelectOption> options = ctrl.getBrokerageOptions();
    	system.assertEquals(3, options.size());
    	system.assertEquals(locIds[0].Id, options[0].getValue());
    	system.assertEquals(locIds[1].Id, options[1].getValue());
    	system.assertEquals(locIds[2].Id, options[2].getValue());
    	
    	String[] brokerage = ctrl.brokerages;
    	
    	system.assertEquals(3, brokerage.size());
    	system.assertEquals(locIds[0].Id, brokerage[0]);
    	system.assertEquals(locIds[1].Id, brokerage[1]);
    	system.assertEquals(locIds[2].Id, brokerage[2]);
    }
    
    /**
     * Validate that the controller returns an error when no statuses are selected.
     */
    static testMethod void testNoStatus() {
    	ctrl.providerStatus = new String[]{};
    	
    	ctrl.runRpt();
    	
    	List<ApexPages.Message> messages = ApexPages.getMessages();
    	
    	system.assertEquals(1, messages.size());
    	system.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
    	system.assertEquals('Please choose at least one status value', messages[0].getSummary());
    }
    
    /**
     * Validate that the controller returns an error when no brokerages are selected
     */
    static testMethod void testNoBrokerages() {
    	ctrl.brokerages = new String[]{};
    	
    	ctrl.runRpt();
    	
    	List<ApexPages.Message> messages = ApexPages.getMessages();
    	
    	system.assertEquals(1, messages.size());
    	system.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
    	system.assertEquals('Please choose at least one brokerage', messages[0].getSummary());
    }
}