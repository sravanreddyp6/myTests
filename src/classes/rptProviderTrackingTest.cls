@isTest
private class rptProviderTrackingTest {
	
	private static rptProviderTracking ctrl = new rptProviderTracking();
	
	@testSetup
	static void setUp() {
		
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
}